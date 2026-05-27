#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export a searchable index of resource names found inside local YooAsset bundles.

This complements manifest-based maps by scanning the physical bundle files that
actually exist under:

- files/yoo/Default/BundleFiles/*/*/__data
- files/yoo/Default/UnpackBundleFiles/*/*/__data
- resources/assets/yoo/Default/*.bundle

The output is meant to answer questions like:

- "Which physical bundle contains hero_053_s02?"
- "What bundleName/hashFileName corresponds to this __data file?"

Manifest rows are joined when possible, but physical bundles without a manifest
match are still indexed so runtime-only cache files do not disappear from the
search surface.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

import UnityPy


SCAN_ROOTS = (
    Path("files/yoo/Default/BundleFiles"),
    Path("files/yoo/Default/UnpackBundleFiles"),
    Path("resources/assets/yoo/Default"),
)

SHOW_TYPES = {
    "Sprite",
    "Texture2D",
    "TextAsset",
    "GameObject",
    "MonoBehaviour",
    "AudioClip",
    "VideoClip",
    "Material",
}


def normalize_relpath(path: Path, root: Path) -> str:
    return str(path.relative_to(root)).replace("\\", "/")


def load_bundle(path: Path, xor_prefix: int, xor_key: int) -> UnityPy.Environment:
    data = bytearray(path.read_bytes())
    for index in range(min(xor_prefix, len(data))):
        data[index] ^= xor_key
    return UnityPy.load(bytes(data))


def object_name(data: Any, fallback: str) -> str:
    for attr in ("m_Name", "name"):
        value = getattr(data, attr, None)
        if value:
            return str(value)
    return fallback


def classify_row_name(name: str) -> str:
    lowered = name.lower()
    if lowered.endswith(".skel") or lowered.endswith(".skel.bytes"):
        return "spine-skeleton"
    if lowered.endswith(".atlas") or lowered.endswith(".atlas.txt"):
        return "spine-atlas"
    if "_skeletondata" in lowered:
        return "spine-skeletondata"
    if "_atlas" in lowered:
        return "spine-atlas-asset"
    if re.match(r"hero_\d{3}", lowered):
        return "hero-ish"
    return ""


def read_bundle_map(path: Path) -> tuple[dict[str, list[dict[str, str]]], dict[str, list[dict[str, str]]]]:
    by_physical: dict[str, list[dict[str, str]]] = defaultdict(list)
    by_hash: dict[str, list[dict[str, str]]] = defaultdict(list)
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            physical = row.get("physicalPath", "").replace("\\", "/").lower()
            if physical:
                by_physical[physical].append(row)
            hash_file = row.get("hashFileName", "").lower()
            if hash_file:
                by_hash[hash_file].append(row)
    return by_physical, by_hash


def discover_bundles(repo_root: Path) -> list[Path]:
    found: list[Path] = []
    for rel_root in SCAN_ROOTS:
        root = repo_root / rel_root
        if not root.exists():
            continue
        if rel_root.parts[-1] == "Default" and "resources" in rel_root.parts:
            found.extend(sorted(root.glob("*.bundle")))
        else:
            found.extend(sorted(root.glob("*/*/__data")))
    return found


def resolve_bundle_rows(
    bundle_path: Path,
    repo_root: Path,
    by_physical: dict[str, list[dict[str, str]]],
    by_hash: dict[str, list[dict[str, str]]],
) -> list[dict[str, str]]:
    rel = normalize_relpath(bundle_path, repo_root)
    rows = list(by_physical.get(rel.lower(), []))
    if rows:
        return rows

    name = bundle_path.name.lower()
    parent_hash = bundle_path.parent.name.lower()
    candidates: list[dict[str, str]] = []
    if name.endswith(".bundle"):
        candidates.extend(by_hash.get(name, []))
    if parent_hash:
        candidates.extend(by_hash.get(f"{parent_hash}.bundle", []))

    seen: set[tuple[str, str]] = set()
    deduped: list[dict[str, str]] = []
    for row in candidates:
        key = (row.get("bundleName", ""), row.get("hashFileName", ""))
        if key in seen:
            continue
        seen.add(key)
        deduped.append(row)
    return deduped


def scan_bundle(
    bundle_path: Path,
    repo_root: Path,
    xor_prefix: int,
    xor_key: int,
    bundle_rows: list[dict[str, str]],
) -> tuple[list[dict[str, Any]], dict[str, Any] | None]:
    rel = normalize_relpath(bundle_path, repo_root)
    physical_name = bundle_path.parent.name if bundle_path.name == "__data" else bundle_path.stem
    bundle_name = bundle_rows[0].get("bundleName", "") if bundle_rows else ""
    hash_file_name = bundle_rows[0].get("hashFileName", "") if bundle_rows else ""
    bundle_ids = "|".join(sorted({row.get("id", "") for row in bundle_rows if row.get("id", "")}))

    try:
        env = load_bundle(bundle_path, xor_prefix, xor_key)
    except Exception as exc:
        return [], {
            "physicalPath": rel,
            "bundleName": bundle_name,
            "hashFileName": hash_file_name,
            "bundleIDs": bundle_ids,
            "physicalName": physical_name,
            "error": str(exc),
        }

    rows: list[dict[str, Any]] = []
    for obj in env.objects:
        obj_type = obj.type.name
        if obj_type not in SHOW_TYPES:
            continue
        try:
            data = obj.read()
            name = object_name(data, f"{obj_type}_{obj.path_id}")
        except Exception:
            name = f"{obj_type}_{obj.path_id}"
        rows.append(
            {
                "resourceName": name,
                "resourceNameLower": name.lower(),
                "resourceKind": classify_row_name(name),
                "objectType": obj_type,
                "pathID": obj.path_id,
                "bundleName": bundle_name,
                "hashFileName": hash_file_name,
                "bundleIDs": bundle_ids,
                "physicalName": physical_name,
                "physicalPath": rel,
                "sourceRoot": rel.split("/", 1)[0],
            }
        )
    return rows, None


def write_csv(path: Path, rows: list[dict[str, Any]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="Export a searchable resource-name index from local YooAsset bundles.")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--bundle-map", default="reverse-output/assets/yoo-physical-map/physical-bundle-map.csv")
    parser.add_argument("--out-dir", default="reverse-output/assets/bundle-name-index")
    parser.add_argument("--xor-prefix", type=int, default=222)
    parser.add_argument("--xor-key", type=lambda value: int(value, 0), default=0x16)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    bundle_map_path = (repo_root / args.bundle_map).resolve()
    out_dir = (repo_root / args.out_dir).resolve()
    by_physical, by_hash = read_bundle_map(bundle_map_path)
    bundle_paths = discover_bundles(repo_root)

    index_rows: list[dict[str, Any]] = []
    error_rows: list[dict[str, Any]] = []
    summary_rows: list[dict[str, Any]] = []

    for bundle_path in bundle_paths:
        bundle_rows = resolve_bundle_rows(bundle_path, repo_root, by_physical, by_hash)
        scanned_rows, error_row = scan_bundle(bundle_path, repo_root, args.xor_prefix, args.xor_key, bundle_rows)
        if error_row is not None:
            error_rows.append(error_row)
            continue

        index_rows.extend(scanned_rows)
        type_counts: dict[str, int] = defaultdict(int)
        for row in scanned_rows:
            type_counts[row["objectType"]] += 1

        rel = normalize_relpath(bundle_path, repo_root)
        summary_rows.append(
            {
                "physicalPath": rel,
                "sourceRoot": rel.split("/", 1)[0],
                "physicalName": bundle_path.parent.name if bundle_path.name == "__data" else bundle_path.stem,
                "bundleName": bundle_rows[0].get("bundleName", "") if bundle_rows else "",
                "hashFileName": bundle_rows[0].get("hashFileName", "") if bundle_rows else "",
                "bundleIDs": "|".join(sorted({row.get("id", "") for row in bundle_rows if row.get("id", "")})),
                "objectCount": len(scanned_rows),
                "uniqueNameCount": len({row["resourceNameLower"] for row in scanned_rows}),
                "types": json.dumps(type_counts, ensure_ascii=False, sort_keys=True),
            }
        )

    index_rows.sort(key=lambda row: (row["resourceNameLower"], row["physicalPath"], row["pathID"]))
    summary_rows.sort(key=lambda row: row["physicalPath"])
    error_rows.sort(key=lambda row: row["physicalPath"])

    index_csv = out_dir / "bundle-resource-name-index.csv"
    bundle_csv = out_dir / "bundle-resource-summary.csv"
    error_csv = out_dir / "bundle-scan-errors.csv"
    summary_json = out_dir / "bundle-name-index-summary.json"

    write_csv(
        index_csv,
        index_rows,
        [
            "resourceName",
            "resourceNameLower",
            "resourceKind",
            "objectType",
            "pathID",
            "bundleName",
            "hashFileName",
            "bundleIDs",
            "physicalName",
            "physicalPath",
            "sourceRoot",
        ],
    )
    write_csv(
        bundle_csv,
        summary_rows,
        [
            "physicalPath",
            "sourceRoot",
            "physicalName",
            "bundleName",
            "hashFileName",
            "bundleIDs",
            "objectCount",
            "uniqueNameCount",
            "types",
        ],
    )
    write_csv(
        error_csv,
        error_rows,
        [
            "physicalPath",
            "bundleName",
            "hashFileName",
            "bundleIDs",
            "physicalName",
            "error",
        ],
    )

    summary = {
        "scannedPhysicalBundles": len(summary_rows),
        "failedBundles": len(error_rows),
        "indexedObjects": len(index_rows),
        "indexCsv": str(index_csv.relative_to(repo_root)).replace("\\", "/"),
        "bundleCsv": str(bundle_csv.relative_to(repo_root)).replace("\\", "/"),
        "errorCsv": str(error_csv.relative_to(repo_root)).replace("\\", "/"),
    }
    summary_json.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
