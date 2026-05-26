#!/usr/bin/env python3
"""Export mp4/mp3 assets listed in the YooAsset physical map.

The shaonv YooAsset bundles XOR the first 222 bytes with 0x16.  VideoClip
payloads are stored in Unity external resource streams, while AudioClip assets
are exported by UnityPy as sample files, often WAV even when the manifest asset
address ends in .mp3.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import traceback
from pathlib import Path

import UnityPy


DEFAULT_PHYSICAL_MAP = "reverse-output/assets/yoo-physical-map/physical-asset-map.csv"
DEFAULT_OUT = "reverse-output/media-export"
MEDIA_EXTENSIONS = {".mp3", ".mp4"}


def parse_int(value: str) -> int:
    return int(value, 0)


def safe_part(value: str, fallback: str = "unnamed") -> str:
    value = value.replace("\\", "/").strip("/")
    value = re.sub(r"[<>:\"|?*\x00-\x1f]", "_", value)
    value = value.replace("..", "_")
    return value or fallback


def unique_path(path: Path) -> Path:
    if not path.exists():
        return path
    parent = path.parent
    stem = path.stem
    suffix = path.suffix
    for index in range(1, 100000):
        candidate = parent / f"{stem}_{index}{suffix}"
        if not candidate.exists():
            return candidate
    raise RuntimeError(f"too many duplicate names for {path}")


def xor_prefix(data: bytearray, prefix: int, key: int) -> None:
    for index in range(min(prefix, len(data))):
        data[index] ^= key


def load_source(path: Path, xor_prefix_len: int, xor_key: int):
    data = bytearray(path.read_bytes())
    if xor_prefix_len > 0:
        xor_prefix(data, xor_prefix_len, xor_key)
    return UnityPy.load(bytes(data))


def resource_key(source: str) -> str:
    return source.rsplit("/", 1)[-1]


def object_name(obj, data) -> str:
    for attr in ("m_Name", "name"):
        value = getattr(data, attr, None)
        if value:
            return str(value)
    return f"{obj.type.name}_{obj.path_id}"


def asset_output_base(out_root: Path, address: str) -> Path:
    parts = [safe_part(part) for part in address.replace("\\", "/").split("/") if part]
    return out_root.joinpath(*parts)


def export_video_clip(env, data, out_base: Path) -> list[Path]:
    resource = getattr(data, "m_ExternalResources", None)
    if resource is None:
        return []

    source = getattr(resource, "m_Source", "")
    size = int(getattr(resource, "m_Size", 0))
    offset = int(getattr(resource, "m_Offset", 0))
    if not source or size <= 0:
        return []

    wanted_resource = resource_key(source)
    stream = None
    for unity_file in env.files.values():
        files = getattr(unity_file, "files", {})
        if wanted_resource in files:
            stream = files[wanted_resource]
            break
    if stream is None:
        raise RuntimeError(f"resource stream not found: {source}")

    payload = bytes(stream.bytes[offset : offset + size])
    suffix = ".mp4" if payload[4:8] == b"ftyp" else ".bin"
    out_path = unique_path(out_base.with_suffix(suffix))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(payload)
    return [out_path]


def export_audio_clip(data, out_base: Path) -> list[Path]:
    samples = getattr(data, "samples", {}) or {}
    exported: list[Path] = []
    for sample_name, sample_data in samples.items():
        sample_path = out_base.parent / safe_part(sample_name, out_base.name)
        out_path = unique_path(sample_path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(sample_data)
        exported.append(out_path)
    return exported


def read_media_rows(map_path: Path, roots: set[str]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    with map_path.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            address = row.get("address", "")
            physical_path = row.get("physicalPath", "")
            ext = Path(address).suffix.lower()
            normalized = physical_path.replace("\\", "/").lower()
            if ext not in MEDIA_EXTENSIONS:
                continue
            if roots and not any(normalized == root or normalized.startswith(f"{root}/") for root in roots):
                continue
            rows.append(row)
    return rows


def export_row(row: dict[str, str], repo_root: Path, out_root: Path, xor_prefix_len: int, xor_key: int) -> tuple[list[Path], list[str]]:
    address = row["address"]
    physical_path = repo_root / row["physicalPath"]
    expected_type = "VideoClip" if Path(address).suffix.lower() == ".mp4" else "AudioClip"
    env = load_source(physical_path, xor_prefix_len, xor_key)
    out_base = asset_output_base(out_root, address)
    exported: list[Path] = []
    object_names: list[str] = []

    for obj in env.objects:
        if obj.type.name != expected_type:
            continue
        data = obj.read()
        object_names.append(object_name(obj, data))
        if expected_type == "VideoClip":
            exported.extend(export_video_clip(env, data, out_base))
        else:
            exported.extend(export_audio_clip(data, out_base))

    return exported, object_names


def main() -> int:
    parser = argparse.ArgumentParser(description="Export manifest mp4/mp3 assets from files/resources bundle roots.")
    parser.add_argument("--repo-root", default=".", help="Repository root.")
    parser.add_argument("--physical-map", default=DEFAULT_PHYSICAL_MAP, help="physical-asset-map.csv path.")
    parser.add_argument("--out", default=DEFAULT_OUT, help="Output directory.")
    parser.add_argument("--roots", default="files,resources", help="Comma-separated physical roots to include.")
    parser.add_argument("--xor-prefix", type=parse_int, default=222)
    parser.add_argument("--xor-key", type=parse_int, default=0x16)
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    map_path = (repo_root / args.physical_map).resolve()
    out_root = (repo_root / args.out).resolve()
    roots = {item.strip().replace("\\", "/").strip("/").lower() for item in args.roots.split(",") if item.strip()}

    rows = read_media_rows(map_path, roots)
    out_root.mkdir(parents=True, exist_ok=True)
    manifest_rows: list[dict[str, object]] = []
    failures = 0

    for row in rows:
        address = row.get("address", "")
        try:
            exported, object_names = export_row(row, repo_root, out_root, args.xor_prefix, args.xor_key)
            if not exported:
                raise RuntimeError("no matching media object exported")
            for out_path in exported:
                manifest_rows.append(
                    {
                        "address": address,
                        "assetExtension": Path(address).suffix.lower(),
                        "objectNames": object_names,
                        "physicalPath": row.get("physicalPath", ""),
                        "output": str(out_path.relative_to(repo_root)).replace("\\", "/"),
                        "bytes": out_path.stat().st_size,
                    }
                )
            print(f"exported {address} -> {len(exported)} file(s)")
        except Exception as exc:
            failures += 1
            manifest_rows.append(
                {
                    "address": address,
                    "assetExtension": Path(address).suffix.lower(),
                    "physicalPath": row.get("physicalPath", ""),
                    "error": str(exc),
                }
            )
            print(f"failed {address}: {exc}", file=sys.stderr)
            traceback.print_exc()

    manifest_path = out_root / "media-export-manifest.json"
    manifest_path.write_text(json.dumps(manifest_rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"media assets listed: {len(rows)}")
    print(f"media files exported: {sum(1 for item in manifest_rows if 'output' in item)}")
    print(f"failures: {failures}")
    print(f"manifest: {manifest_path}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
