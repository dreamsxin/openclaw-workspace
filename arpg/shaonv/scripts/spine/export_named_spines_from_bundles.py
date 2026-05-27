#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Export specific Spine directories by scanning local YooAsset bundles.

Use this when manifest rows exist but `physical-asset-map.csv` has no usable
physicalPath entry. The script scans local bundle files directly with UnityPy,
matches container paths by source directory, and writes the same export layout
as `scripts/assets/export_all_spine_resources.py` under `tmp/all-spine-export`.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Iterable

import UnityPy


REPO_ROOT = Path(__file__).resolve().parents[2]
EXPORT_ROOT = REPO_ROOT / "tmp/all-spine-export"
MANIFEST_CSV = EXPORT_ROOT / "spine-export-manifest.csv"

XOR_PREFIX = 222
XOR_KEY = 0x16


def load_bundle(path: Path):
    data = bytearray(path.read_bytes())
    for index in range(min(XOR_PREFIX, len(data))):
        data[index] ^= XOR_KEY
    return UnityPy.load(bytes(data))


def safe_asset_path(address: str) -> Path:
    return Path(*[part for part in address.replace("\\", "/").split("/") if part])


def text_asset_bytes(data) -> bytes:
    script = getattr(data, "m_Script", b"")
    if isinstance(script, bytes):
        return script
    return str(script).encode("utf-8", errors="surrogateescape")


def export_object(obj, address: str, out_path: Path) -> tuple[str, Path]:
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

    if obj_type == "TextAsset" or lower.endswith((".atlas.txt", ".skel.bytes", ".bytes", ".txt", ".json")):
        out_path.write_bytes(text_asset_bytes(data))
        return "text", out_path

    typetree_path = out_path.with_suffix(out_path.suffix + ".typetree.json")
    try:
        typetree_path.write_text(__import__("json").dumps(obj.read_typetree(), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        return "typetree", typetree_path
    except Exception:
        return "unsupported", out_path


def iter_local_bundles() -> Iterable[Path]:
    resources_root = REPO_ROOT / "resources/assets/yoo/Default"
    if resources_root.exists():
        yield from resources_root.glob("*.bundle")
    for relative in ("files/yoo/Default/BundleFiles", "files/yoo/Default/UnpackBundleFiles"):
        root = REPO_ROOT / relative
        if root.exists():
            for path in root.rglob("__data"):
                if path.is_file():
                    yield path


def read_manifest_rows() -> list[dict[str, str]]:
    if not MANIFEST_CSV.exists():
        return []
    with MANIFEST_CSV.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def write_manifest_rows(rows: list[dict[str, str]]) -> None:
    MANIFEST_CSV.parent.mkdir(parents=True, exist_ok=True)
    with MANIFEST_CSV.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["address", "output", "bundle", "objectType", "exportKind"])
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="Export specific Spine folders from local YooAsset bundles.")
    parser.add_argument("--source-dir", action="append", required=True, help="RawAssets Spine source dir, e.g. Assets/Game/RawAssets/Spine/Hero/hero_053_s02")
    args = parser.parse_args()

    targets = {item.replace("\\", "/").rstrip("/").lower() for item in args.source_dir}
    manifest_rows = read_manifest_rows()
    known_addresses = {row["address"].replace("\\", "/").lower() for row in manifest_rows}

    exported = 0
    for bundle_path in iter_local_bundles():
        try:
            env = load_bundle(bundle_path)
        except Exception:
            continue
        for cpath, obj in env.container.items():
            address = cpath.replace("\\", "/")
            source_dir = str(Path(address).parent).replace("\\", "/").lower()
            if source_dir not in targets:
                continue
            if address.lower() in known_addresses:
                continue
            target = EXPORT_ROOT / "assets" / safe_asset_path(address)
            try:
                export_kind, exported_path = export_object(obj, address, target)
            except Exception:
                continue
            manifest_rows.append(
                {
                    "address": address,
                    "output": str(exported_path.relative_to(EXPORT_ROOT)).replace("\\", "/"),
                    "bundle": str(bundle_path.relative_to(REPO_ROOT)).replace("\\", "/"),
                    "objectType": obj.type.name,
                    "exportKind": export_kind,
                }
            )
            known_addresses.add(address.lower())
            exported += 1

    write_manifest_rows(manifest_rows)
    print(f"exported_rows={exported}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
