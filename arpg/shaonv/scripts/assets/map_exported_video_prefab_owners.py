#!/usr/bin/env python3
"""Map exported video files back to prefabs that depend on their bundles."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path


DEFAULT_MEDIA_MANIFEST = "reverse-output/media-export/media-export-manifest.json"
DEFAULT_ASSETS_CSV = "reverse-output/assets/manifest-parsed-py/manifest-parsed-assets.csv"
DEFAULT_BUNDLES_CSV = "reverse-output/assets/manifest-parsed-py/manifest-parsed-bundles.csv"
DEFAULT_OUT_CSV = "reverse-output/media-export/video-prefab-owners.csv"
DEFAULT_OUT_JSON = "reverse-output/media-export/video-prefab-owners.json"


def split_ids(value: str) -> set[str]:
    return {part for part in (value or "").split("|") if part}


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def load_media_manifest(path: Path) -> list[dict[str, object]]:
    return json.loads(path.read_text(encoding="utf-8"))


def media_key(row: dict[str, str]) -> set[str]:
    keys = {row.get("id", ""), row.get("bundleID", ""), row.get("resolvedBundleID", "")}
    return {key for key in keys if key}


def owner_row(media_item: dict[str, object], asset_row: dict[str, str], owners: list[dict[str, str]]) -> dict[str, object]:
    return {
        "address": media_item.get("address", ""),
        "output": media_item.get("output", ""),
        "bytes": media_item.get("bytes", ""),
        "assetId": asset_row.get("id", ""),
        "assetBundleID": asset_row.get("bundleID", ""),
        "resolvedBundleID": asset_row.get("resolvedBundleID", ""),
        "bundleName": asset_row.get("bundleName", ""),
        "ownerCount": len(owners),
        "owners": owners,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Return prefab owners for exported mp4 files.")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--media-manifest", default=DEFAULT_MEDIA_MANIFEST)
    parser.add_argument("--assets-csv", default=DEFAULT_ASSETS_CSV)
    parser.add_argument("--bundles-csv", default=DEFAULT_BUNDLES_CSV)
    parser.add_argument("--out-csv", default=DEFAULT_OUT_CSV)
    parser.add_argument("--out-json", default=DEFAULT_OUT_JSON)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    media_manifest = load_media_manifest(repo_root / args.media_manifest)
    assets = read_csv(repo_root / args.assets_csv)
    bundles = read_csv(repo_root / args.bundles_csv)

    assets_by_address = {row.get("address", ""): row for row in assets}
    prefab_assets = [row for row in assets if row.get("address", "").lower().endswith(".prefab")]
    prefab_by_bundle_id: dict[str, list[dict[str, str]]] = {}
    for prefab in prefab_assets:
        for key in (prefab.get("bundleID", ""), prefab.get("resolvedBundleID", "")):
            if key:
                prefab_by_bundle_id.setdefault(key, []).append(prefab)

    rows: list[dict[str, object]] = []
    csv_rows: list[dict[str, object]] = []

    for media_item in media_manifest:
        if str(media_item.get("assetExtension", "")).lower() != ".mp4":
            continue
        address = str(media_item.get("address", ""))
        asset_row = assets_by_address.get(address, {})
        keys = media_key(asset_row)
        owners: list[dict[str, str]] = []
        seen: set[tuple[str, str]] = set()

        for prefab in prefab_assets:
            direct_keys = split_ids(prefab.get("dependAssetIDs", "")) | split_ids(prefab.get("dependBundleIDs", ""))
            if keys & direct_keys:
                owner = {
                    "method": "prefab-depend-list",
                    "prefab": prefab.get("address", ""),
                    "prefabAssetId": prefab.get("id", ""),
                    "prefabBundleID": prefab.get("bundleID", ""),
                    "prefabResolvedBundleID": prefab.get("resolvedBundleID", ""),
                    "prefabBundleName": prefab.get("bundleName", ""),
                }
                marker = (owner["method"], owner["prefab"])
                if marker not in seen:
                    owners.append(owner)
                    seen.add(marker)

        for bundle in bundles:
            if not (keys & split_ids(bundle.get("dependBundleIDs", ""))):
                continue
            bundle_prefabs = prefab_by_bundle_id.get(bundle.get("id", ""), [])
            for prefab in bundle_prefabs:
                owner = {
                    "method": "bundle-depend-list",
                    "prefab": prefab.get("address", ""),
                    "prefabAssetId": prefab.get("id", ""),
                    "prefabBundleID": prefab.get("bundleID", ""),
                    "prefabResolvedBundleID": prefab.get("resolvedBundleID", ""),
                    "prefabBundleName": prefab.get("bundleName", ""),
                }
                marker = (owner["method"], owner["prefab"])
                if marker not in seen:
                    owners.append(owner)
                    seen.add(marker)

        row = owner_row(media_item, asset_row, owners)
        rows.append(row)
        if owners:
            for owner in owners:
                csv_rows.append({**{key: value for key, value in row.items() if key != "owners"}, **owner})
        else:
            csv_rows.append({**{key: value for key, value in row.items() if key != "owners"}, "method": "", "prefab": ""})

    out_json = repo_root / args.out_json
    out_csv = repo_root / args.out_csv
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_json.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    fieldnames = [
        "address",
        "output",
        "bytes",
        "assetId",
        "assetBundleID",
        "resolvedBundleID",
        "bundleName",
        "ownerCount",
        "method",
        "prefab",
        "prefabAssetId",
        "prefabBundleID",
        "prefabResolvedBundleID",
        "prefabBundleName",
    ]
    with out_csv.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(csv_rows)

    print(f"videos: {len(rows)}")
    print(f"owned videos: {sum(1 for row in rows if row['ownerCount'])}")
    print(f"owner links: {sum(int(row['ownerCount']) for row in rows)}")
    print(f"csv: {out_csv}")
    print(f"json: {out_json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
