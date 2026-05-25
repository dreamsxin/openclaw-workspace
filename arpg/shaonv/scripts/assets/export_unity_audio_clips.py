#!/usr/bin/env python3
"""Export selected Unity AudioClip samples into the Godot MVP."""

from __future__ import annotations

import argparse
import csv
import json
import re
import shutil
from pathlib import Path

import UnityPy


DEFAULT_PHYSICAL_MAP = "reverse-output/assets/yoo-physical-map/physical-asset-map.csv"


def parse_int(value: str) -> int:
    return int(value, 0)


def safe_rel_path(path: str) -> Path:
    if path.startswith("res://"):
        path = path.removeprefix("res://")
    rel = Path(path)
    if rel.is_absolute() or ".." in rel.parts:
        raise ValueError(f"unsafe relative path: {path}")
    return rel


def safe_name(name: str, fallback: str = "unnamed") -> str:
    value = re.sub(r"[<>:\"/\\|?*\x00-\x1f]", "_", name).strip(" .")
    return value or fallback


def read_physical_map(path: Path) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            address = row.get("address", "")
            if address:
                rows[address.lower()] = row
    return rows


def load_source(path: Path, xor_prefix: int, xor_key: int):
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


def export_bundle_audio(source: Path, destination: Path, wanted: set[str], xor_prefix: int, xor_key: int) -> dict[str, Path]:
    wanted_lower = {item.lower() for item in wanted}
    env = load_source(source, xor_prefix, xor_key)
    exported: dict[str, Path] = {}
    for obj in env.objects:
        if obj.type.name != "AudioClip":
            continue
        data = obj.read()
        clip_name = safe_name(object_name(obj, data))
        if clip_name.lower() not in wanted_lower:
            continue
        samples = getattr(data, "samples", {}) or {}
        for sample_name, sample_data in samples.items():
            out_path = destination / safe_name(sample_name)
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_bytes(sample_data)
            exported[clip_name.lower()] = out_path
    return exported


def read_plan(path: Path) -> list[dict[str, str]]:
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    items = data.get("items", data if isinstance(data, list) else [])
    if not isinstance(items, list):
        raise ValueError("plan must be a JSON list or an object with an items list")
    return items


def main() -> int:
    parser = argparse.ArgumentParser(description="Export selected Unity AudioClip samples.")
    parser.add_argument("--plan", required=True, help="JSON plan with asset/godot items.")
    parser.add_argument("--repo-root", default=".", help="Repository root.")
    parser.add_argument("--godot-root", default="standalone/godot-mvp", help="Godot project root.")
    parser.add_argument("--export-root", default="reverse-output/godot-resource-export/audio-clips", help="Raw export folder.")
    parser.add_argument("--physical-map", default=DEFAULT_PHYSICAL_MAP, help="physical-asset-map.csv path.")
    parser.add_argument("--xor-prefix", type=parse_int, default=222)
    parser.add_argument("--xor-key", type=parse_int, default=0x16)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    godot_root = (repo_root / args.godot_root).resolve()
    export_root = (repo_root / args.export_root).resolve()
    physical_map = read_physical_map((repo_root / args.physical_map).resolve())
    items = read_plan((repo_root / args.plan).resolve())

    wanted_by_bundle: dict[Path, set[str]] = {}
    export_dir_by_bundle: dict[Path, Path] = {}
    resolved_items: list[dict[str, object]] = []
    failures = 0

    for item in items:
        asset = item.get("asset", "")
        target = item.get("godot", "")
        if not asset or not target:
            print(f"skip invalid item: {item}")
            failures += 1
            continue
        row = physical_map.get(asset.lower())
        if row is None:
            print(f"missing map row: {asset}")
            failures += 1
            continue
        bundle_path = (repo_root / row.get("physicalPath", "")).resolve()
        clip_name = item.get("name") or Path(asset).stem
        wanted_by_bundle.setdefault(bundle_path, set()).add(clip_name)
        export_dir_by_bundle.setdefault(bundle_path, export_root / safe_name(bundle_path.parent.name))
        resolved_items.append({"asset": asset, "target": target, "bundle": bundle_path, "clip": clip_name})

    exported_by_bundle: dict[Path, dict[str, Path]] = {}
    for bundle_path, wanted_names in wanted_by_bundle.items():
        try:
            exported_by_bundle[bundle_path] = export_bundle_audio(
                bundle_path,
                export_dir_by_bundle[bundle_path],
                wanted_names,
                args.xor_prefix,
                args.xor_key,
            )
        except Exception as exc:
            print(f"failed bundle: {bundle_path}: {exc}")
            failures += len(wanted_names)

    manifest: list[dict[str, str]] = []
    for item in resolved_items:
        asset = str(item["asset"])
        target = str(item["target"])
        clip_name = str(item["clip"])
        bundle_path = item["bundle"]
        source_audio = exported_by_bundle.get(bundle_path, {}).get(clip_name.lower())
        if source_audio is None:
            print(f"missing audio in bundle: {asset} name={clip_name}")
            failures += 1
            continue
        target_path = godot_root / safe_rel_path(target)
        target_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_audio, target_path)
        manifest.append(
            {
                "godot": str(target_path.relative_to(godot_root)).replace("\\", "/"),
                "asset": asset,
                "source": str(bundle_path.relative_to(repo_root)).replace("\\", "/"),
                "exported": str(source_audio.relative_to(repo_root)).replace("\\", "/"),
            }
        )
        print(f"copied: {asset} -> {target_path.relative_to(godot_root)}")

    manifest_path = export_root / "godot-audio-export-manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"manifest: {manifest_path}")
    print(f"audio exported: {len(manifest)} copied, {failures} failed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
