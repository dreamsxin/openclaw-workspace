#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export selected Unity bundle images and place them in the Godot MVP.

The original shaonv YooAsset bundles XOR the first bytes of each bundle.  The
``--plan`` mode reads a small JSON plan, resolves original asset addresses via
the reverse-engineered physical map CSV, exports only the requested image names,
and copies them into ``standalone/godot-mvp``.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import shutil
import sys
from pathlib import Path

import UnityPy


def parse_int(value: str) -> int:
    return int(value, 0)


def safe_name(name: str, fallback: str = "unnamed") -> str:
    value = re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", name).strip(" .")
    value = value.replace("..", "_")
    return value or fallback


def safe_rel_path(path: str) -> Path:
    if path.startswith("res://"):
        path = path.removeprefix("res://")
    rel = Path(path)
    if rel.is_absolute() or ".." in rel.parts:
        raise ValueError(f"unsafe relative path: {path}")
    return rel


def load_source(path: Path, xor_prefix: int, xor_key: int):
    if xor_prefix <= 0:
        return UnityPy.load(str(path))
    data = bytearray(path.read_bytes())
    for index in range(min(xor_prefix, len(data))):
        data[index] ^= xor_key
    return UnityPy.load(bytes(data))


def object_name(obj, data) -> str:
    for attr in ("m_Name", "name"):
        value = getattr(data, attr, None)
        if value:
            return str(value)
    return f"{obj.type.name}_{obj.path_id}"


def export_bundle(source: Path, destination: Path, xor_prefix: int = 0, xor_key: int = 0x16, wanted: set[str] | None = None) -> dict[str, Path]:
    wanted_lower = {item.lower() for item in wanted} if wanted else None
    env = load_source(source, xor_prefix, xor_key)
    exported: dict[str, Path] = {}
    for obj in env.objects:
        if obj.type.name not in {"Texture2D", "Sprite"}:
            continue
        if wanted_lower and obj.type.name == "Texture2D":
            continue
        data = obj.read()
        name = safe_name(object_name(obj, data))
        if wanted_lower and name.lower() not in wanted_lower:
            continue
        image = getattr(data, "image", None)
        if image is None:
            continue
        out_path = destination / f"{name}.png"
        out_path.parent.mkdir(parents=True, exist_ok=True)
        image.save(out_path)
        exported[name.lower()] = out_path
    return exported


def read_physical_map(path: Path) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            address = row.get("address", "")
            if address:
                rows[address.lower()] = row
    return rows


def read_plan(path: Path) -> list[dict[str, str]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    items = data.get("items", data if isinstance(data, list) else [])
    if not isinstance(items, list):
        raise ValueError("plan must be a JSON list or an object with an items list")
    return items


def export_plan(args: argparse.Namespace) -> int:
    repo_root = Path(args.repo_root).resolve()
    godot_root = (repo_root / args.godot_root).resolve()
    export_root = (repo_root / args.export_root).resolve()
    physical_map = read_physical_map((repo_root / args.physical_map).resolve())
    items = read_plan((repo_root / args.plan).resolve())
    manifest_rows: list[dict[str, str]] = []
    resolved_items: list[dict[str, str | Path]] = []
    wanted_by_bundle: dict[Path, set[str]] = {}
    export_dir_by_bundle: dict[Path, Path] = {}
    failures = 0

    for item in items:
        asset = item.get("asset", "")
        target = item.get("godot", "")
        if not asset or not target:
            print(f"skip invalid item: {item}")
            failures += 1
            continue
        row = physical_map.get(asset.lower())
        if not row:
            print(f"missing map row: {asset}")
            failures += 1
            continue
        physical_path = row.get("physicalPath", "")
        if not physical_path:
            print(f"missing physical path: {asset}")
            failures += 1
            continue

        bundle_path = (repo_root / physical_path).resolve()
        image_name = item.get("name") or Path(asset).stem
        wanted_by_bundle.setdefault(bundle_path, set()).add(image_name)
        export_dir_by_bundle.setdefault(bundle_path, export_root / safe_name(bundle_path.stem))
        resolved_items.append(
            {
                "asset": asset,
                "target": target,
                "bundle_path": bundle_path,
                "image_name": image_name,
            }
        )

    exported_by_bundle: dict[Path, dict[str, Path]] = {}
    for bundle_path, wanted_names in wanted_by_bundle.items():
        try:
            exported_by_bundle[bundle_path] = export_bundle(
                bundle_path,
                export_dir_by_bundle[bundle_path],
                args.xor_prefix,
                args.xor_key,
                wanted_names,
            )
        except Exception as exc:
            print(f"failed bundle: {bundle_path}: {exc}")
            failures += len(wanted_names)

    for item in resolved_items:
        asset = str(item["asset"])
        target = str(item["target"])
        bundle_path = item["bundle_path"]
        image_name = str(item["image_name"])
        try:
            exported = exported_by_bundle.get(bundle_path, {})
            source_image = exported.get(image_name.lower())
            if source_image is None:
                print(f"missing image in bundle: {asset} name={image_name}")
                failures += 1
                continue
            target_path = godot_root / safe_rel_path(target)
            if not args.dry_run:
                target_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source_image, target_path)
            manifest_rows.append(
                {
                    "godot": str(target_path.relative_to(godot_root)).replace("\\", "/"),
                    "asset": asset,
                    "source": str(bundle_path.relative_to(repo_root)).replace("\\", "/"),
                    "exported": str(source_image.relative_to(repo_root)).replace("\\", "/"),
                }
            )
            action = "would copy" if args.dry_run else "copied"
            print(f"{action}: {asset} -> {target_path.relative_to(godot_root)}")
        except Exception as exc:
            print(f"failed: {asset}: {exc}")
            failures += 1

    if not args.dry_run:
        manifest_path = export_root / "godot-plan-export-manifest.json"
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(json.dumps(manifest_rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"manifest: {manifest_path}")
    print(f"plan exported: {len(manifest_rows)} copied, {failures} failed")
    return 1 if failures else 0


def export_sources(args: argparse.Namespace) -> int:
    destination = Path(args.out)
    total = 0
    for raw_source in args.sources:
        source = Path(raw_source)
        if not source.exists():
            print(f"missing: {source}")
            continue
        try:
            exported = export_bundle(source, destination, args.xor_prefix, args.xor_key)
        except Exception as exc:
            print(f"failed: {source}: {exc}")
            continue
        total += len(exported)
        print(f"exported {len(exported)}: {source}")
    print(f"total exported: {total} -> {destination}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Export Texture2D/Sprite images from Unity bundles.")
    parser.add_argument("sources", nargs="*", help="Unity bundle or __data files for legacy export mode.")
    parser.add_argument("--out", help="Destination directory for legacy export mode.")
    parser.add_argument("--plan", help="JSON plan for curated Godot exports.")
    parser.add_argument("--repo-root", default=".", help="Repository root for plan mode.")
    parser.add_argument("--godot-root", default="standalone/godot-mvp", help="Godot project root for plan mode.")
    parser.add_argument("--physical-map", default="reverse-output/assets/yoo-physical-map/physical-asset-map.csv")
    parser.add_argument("--export-root", default="reverse-output/godot-resource-export")
    parser.add_argument("--xor-prefix", type=parse_int, default=222)
    parser.add_argument("--xor-key", type=parse_int, default=0x16)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if args.plan:
        return export_plan(args)
    if not args.out or not args.sources:
        parser.error("legacy mode requires --out and at least one source, or use --plan")
    return export_sources(args)


if __name__ == "__main__":
    sys.exit(main())
