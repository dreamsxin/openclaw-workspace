#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export all Spine preview resources from YooAsset bundles.

The output keeps the original ``Assets/Game/RawAssets/Spine/...`` directory
shape so each ``.skel.bytes`` sits beside its matching ``.atlas.txt`` and PNG
page images for manual inspection in a Spine viewer.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

import UnityPy


TEXT_ASSET_SUFFIXES = {
    ".atlas.txt",
    ".skel.bytes",
    ".bytes",
    ".txt",
    ".json",
}


def safe_part(value: str) -> str:
    cleaned = re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", value).strip(" .")
    return cleaned or "_"


def safe_asset_path(address: str) -> Path:
    parts = [safe_part(part) for part in address.replace("\\", "/").split("/") if part]
    if not parts or any(part == ".." for part in parts):
        raise ValueError(f"unsafe asset address: {address}")
    return Path(*parts)


def load_bundle(path: Path, xor_prefix: int, xor_key: int):
    if xor_prefix <= 0:
        return UnityPy.load(str(path))
    data = bytearray(path.read_bytes())
    for index in range(min(xor_prefix, len(data))):
        data[index] ^= xor_key
    return UnityPy.load(bytes(data))


def read_physical_map(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def wanted_spine_row(row: dict[str, str], include_unavailable: bool = False) -> bool:
    address = row.get("address", "").replace("\\", "/")
    if "/RawAssets/Spine/" not in address:
        return False
    if include_unavailable:
        return True
    return bool(row.get("physicalPath")) and row.get("physicalExists", "True") == "True"


def object_container_path(obj: Any, data: Any) -> str:
    for attr in ("container", "assets_file"):
        value = getattr(obj, attr, None)
        if isinstance(value, str) and value:
            return value
    for attr in ("m_Name", "name"):
        value = getattr(data, attr, None)
        if value:
            return str(value)
    return f"{obj.type.name}_{obj.path_id}"


def text_asset_bytes(data: Any) -> bytes:
    script = getattr(data, "m_Script", b"")
    if isinstance(script, bytes):
        return script
    return str(script).encode("utf-8", errors="surrogateescape")


def write_typetree_json(obj: Any, out_path: Path) -> bool:
    try:
        tree = obj.read_typetree()
    except Exception:
        return False
    out_path.write_text(json.dumps(tree, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return True


def export_object(obj: Any, address: str, out_path: Path) -> tuple[str, Path]:
    data = obj.read()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    obj_type = obj.type.name
    lower = address.lower()

    if obj_type == "Texture2D":
        image = getattr(data, "image", None)
        if image is None:
            raise ValueError("Texture2D has no image")
        image.save(out_path)
        return "image", out_path

    if obj_type == "Sprite":
        image = getattr(data, "image", None)
        if image is None:
            raise ValueError("Sprite has no image")
        image.save(out_path)
        return "sprite", out_path

    if obj_type == "TextAsset" or any(lower.endswith(suffix) for suffix in TEXT_ASSET_SUFFIXES):
        out_path.write_bytes(text_asset_bytes(data))
        return "text", out_path

    typetree_path = out_path.with_suffix(out_path.suffix + ".typetree.json")
    if write_typetree_json(obj, typetree_path):
        return "typetree", typetree_path

    return "unsupported", out_path


def build_bundle_work(rows: list[dict[str, str]], repo_root: Path, include_unavailable: bool) -> dict[Path, list[dict[str, str]]]:
    work: dict[Path, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        if not wanted_spine_row(row, include_unavailable=include_unavailable):
            continue
        physical_path = row.get("physicalPath", "")
        if not physical_path:
            continue
        bundle_path = (repo_root / physical_path).resolve()
        work[bundle_path].append(row)
    return work


def write_csv(path: Path, rows: list[dict[str, Any]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def atlas_page_names(path: Path) -> list[str]:
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return []

    pages: list[str] = []
    previous_blank = True
    for raw_line in lines:
        line = raw_line.strip()
        if not line:
            previous_blank = True
            continue
        if previous_blank and not line.endswith(":") and ":" not in line:
            pages.append(line)
        previous_blank = False
    return pages


def main() -> int:
    parser = argparse.ArgumentParser(description="Export all RawAssets/Spine resources for manual preview.")
    parser.add_argument("--repo-root", default=".", help="Repository root.")
    parser.add_argument("--physical-map", default="reverse-output/assets/yoo-physical-map/physical-asset-map.csv")
    parser.add_argument("--out", default="tmp/all-spine-export")
    parser.add_argument("--xor-prefix", type=int, default=222)
    parser.add_argument("--xor-key", type=lambda value: int(value, 0), default=0x16)
    parser.add_argument("--include-unavailable", action="store_true")
    parser.add_argument("--limit", type=int, default=0, help="Debug limit by bundle count.")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_root = (repo_root / args.out).resolve()
    map_path = (repo_root / args.physical_map).resolve()
    rows = read_physical_map(map_path)
    work = build_bundle_work(rows, repo_root, args.include_unavailable)
    if args.limit > 0:
        work = dict(list(work.items())[: args.limit])

    manifest_rows: list[dict[str, Any]] = []
    failure_rows: list[dict[str, Any]] = []
    total_wanted = sum(len(items) for items in work.values())
    exported = 0
    skipped_missing_bundle = 0

    for bundle_index, (bundle_path, bundle_rows) in enumerate(sorted(work.items(), key=lambda item: str(item[0])), start=1):
        if not bundle_path.exists():
            skipped_missing_bundle += len(bundle_rows)
            for row in bundle_rows:
                failure_rows.append(
                    {
                        "address": row.get("address", ""),
                        "bundle": str(bundle_path.relative_to(repo_root)) if bundle_path.is_relative_to(repo_root) else str(bundle_path),
                        "reason": "missing bundle file",
                    }
                )
            continue

        wanted_by_address = {row["address"].replace("\\", "/").lower(): row for row in bundle_rows}
        wanted_by_name = {Path(row["address"]).name.lower(): row for row in bundle_rows}

        try:
            env = load_bundle(bundle_path, args.xor_prefix, args.xor_key)
        except Exception as exc:
            for row in bundle_rows:
                failure_rows.append(
                    {
                        "address": row.get("address", ""),
                        "bundle": str(bundle_path.relative_to(repo_root)) if bundle_path.is_relative_to(repo_root) else str(bundle_path),
                        "reason": f"bundle load failed: {exc}",
                    }
                )
            continue

        matched: set[str] = set()
        for cpath, obj in env.container.items():
            normalized_cpath = cpath.replace("\\", "/").lower()
            row = wanted_by_address.get(normalized_cpath)
            if row is None:
                row = wanted_by_name.get(Path(cpath).name.lower())
            if row is None:
                continue

            address = row["address"].replace("\\", "/")
            target = out_root / "assets" / safe_asset_path(address)
            try:
                exported_kind, exported_path = export_object(obj, address, target)
            except Exception as exc:
                failure_rows.append(
                    {
                        "address": address,
                        "bundle": str(bundle_path.relative_to(repo_root)) if bundle_path.is_relative_to(repo_root) else str(bundle_path),
                        "reason": f"export failed: {exc}",
                    }
                )
                matched.add(address.lower())
                continue

            if exported_kind != "unsupported":
                exported += 1
            manifest_rows.append(
                {
                    "address": address,
                    "output": str(exported_path.relative_to(out_root)).replace("\\", "/"),
                    "bundle": str(bundle_path.relative_to(repo_root)) if bundle_path.is_relative_to(repo_root) else str(bundle_path),
                    "objectType": obj.type.name,
                    "exportKind": exported_kind,
                }
            )
            matched.add(address.lower())

        for row in bundle_rows:
            address = row["address"].replace("\\", "/")
            if address.lower() not in matched:
                failure_rows.append(
                    {
                        "address": address,
                        "bundle": str(bundle_path.relative_to(repo_root)) if bundle_path.is_relative_to(repo_root) else str(bundle_path),
                        "reason": "asset not found in bundle container",
                    }
                )

        if bundle_index % 25 == 0:
            print(f"processed bundles: {bundle_index}/{len(work)} exported={exported} failures={len(failure_rows)}")

    rows_by_address = {row["address"].lower(): row for row in manifest_rows}
    pngs_by_dir: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in manifest_rows:
        if row["address"].lower().endswith(".png"):
            pngs_by_dir[str(Path(row["address"]).parent).replace("\\", "/").lower()].append(row)

    preview_rows = []
    for row in sorted(manifest_rows, key=lambda item: item["address"]):
        address = row["address"]
        if not address.endswith(".skel.bytes"):
            continue
        source_dir = str(Path(address).parent).replace("\\", "/")
        base_address = address[: -len(".skel.bytes")]
        atlas_address = f"{base_address}.atlas.txt"
        atlas_row = rows_by_address.get(atlas_address.lower())
        atlas_output = atlas_row["output"] if atlas_row else ""

        page_outputs: list[str] = []
        if atlas_output:
            atlas_path = out_root / atlas_output
            page_names = atlas_page_names(atlas_path)
            for page_name in page_names:
                page_address = f"{source_dir}/{page_name}".lower()
                page_row = rows_by_address.get(page_address)
                if page_row:
                    page_outputs.append(page_row["output"])

        if not page_outputs:
            for png_row in pngs_by_dir.get(source_dir.lower(), []):
                if Path(png_row["address"]).stem == Path(base_address).name:
                    page_outputs.append(png_row["output"])

        if not page_outputs:
            page_outputs = [png_row["output"] for png_row in pngs_by_dir.get(source_dir.lower(), [])]

        preview_rows.append(
            {
                "sourceDir": source_dir,
                "skeleton": row["output"],
                "atlas": atlas_output,
                "pngCount": len(page_outputs),
                "pngs": "|".join(sorted(dict.fromkeys(page_outputs))),
                "previewReady": bool(row["output"] and atlas_output and page_outputs),
            }
        )

    set_rows = []
    grouped: dict[str, dict[str, Any]] = defaultdict(lambda: {"skeletons": 0, "ready": 0, "png": set()})
    for row in preview_rows:
        item = grouped[row["sourceDir"]]
        item["skeletons"] += 1
        if row["previewReady"]:
            item["ready"] += 1
        for png in row["pngs"].split("|"):
            if png:
                item["png"].add(png)
    for source_dir, item in sorted(grouped.items()):
        set_rows.append(
            {
                "sourceDir": source_dir,
                "skeletonCount": item["skeletons"],
                "previewReadyCount": item["ready"],
                "pngCount": len(item["png"]),
            }
        )

    write_csv(out_root / "spine-export-manifest.csv", manifest_rows, ["address", "output", "bundle", "objectType", "exportKind"])
    write_csv(out_root / "spine-preview-files.csv", preview_rows, ["sourceDir", "skeleton", "atlas", "pngCount", "pngs", "previewReady"])
    write_csv(out_root / "spine-preview-sets.csv", set_rows, ["sourceDir", "skeletonCount", "previewReadyCount", "pngCount"])
    write_csv(out_root / "spine-export-failures.csv", failure_rows, ["address", "bundle", "reason"])

    summary = {
        "wantedAssets": total_wanted,
        "bundles": len(work),
        "exportedObjects": exported,
        "manifestRows": len(manifest_rows),
        "previewFiles": len(preview_rows),
        "previewSets": len(set_rows),
        "previewReadyFiles": sum(1 for row in preview_rows if row["previewReady"]),
        "previewReadySets": sum(1 for row in set_rows if row["previewReadyCount"] == row["skeletonCount"]),
        "failures": len(failure_rows),
        "missingBundleAssets": skipped_missing_bundle,
    }
    (out_root / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 1 if failure_rows else 0


if __name__ == "__main__":
    sys.exit(main())
