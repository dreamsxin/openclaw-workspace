#!/usr/bin/env python3
"""Export Unity assets from AssetBundle files with UnityPy.

The shaonv APK bundles are encrypted with the game's YooAsset wrapper:
only the first 222 bytes are XORed with 0x16.  This script can either read
already-decoded bundles or apply that prefix XOR in memory before loading.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import os
import re
import sys
import traceback
from pathlib import Path
from typing import Iterable

try:
    import UnityPy
except ImportError:
    print(
        "UnityPy is not installed. Install it with:\n"
        "  python -m pip install UnityPy\n",
        file=sys.stderr,
    )
    raise


DEFAULT_TYPES = {
    "Texture2D",
    "Sprite",
    "TextAsset",
    "AudioClip",
    "Mesh",
    "Shader",
    "Material",
    "MonoBehaviour",
    "GameObject",
    "Transform",
    "RectTransform",
    "AnimatorController",
    "AnimationClip",
    "Font",
    "SpriteAtlas",
}


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
    stem = path.stem
    suffix = path.suffix
    parent = path.parent
    for i in range(1, 100000):
        candidate = parent / f"{stem}_{i}{suffix}"
        if not candidate.exists():
            return candidate
    raise RuntimeError(f"too many duplicate names for {path}")


def iter_files(source: Path, extensions: set[str] | None) -> Iterable[Path]:
    if source.is_file():
        yield source
        return
    for root, _, files in os.walk(source):
        for name in files:
            path = Path(root) / name
            if extensions and path.suffix.lower() not in extensions:
                continue
            yield path


def load_source(path: Path, xor_prefix: int, xor_key: int):
    if xor_prefix <= 0:
        return UnityPy.load(str(path))
    data = bytearray(path.read_bytes())
    n = min(xor_prefix, len(data))
    for i in range(n):
        data[i] ^= xor_key
    return UnityPy.load(bytes(data))


def raw_data(obj, data) -> bytes:
    for attr in ("script", "m_Script", "image_data"):
        value = getattr(data, attr, None)
        if isinstance(value, bytes):
            return value
        if isinstance(value, str):
            return value.encode("utf-8", errors="replace")
    try:
        return obj.get_raw_data()
    except Exception:
        return repr(data).encode("utf-8", errors="replace")


def export_object(obj, data, dest: Path, export_type: str) -> tuple[Path, str]:
    if export_type in {"Texture2D", "Sprite"} and hasattr(data, "image"):
        out = unique_path(dest.with_suffix(".png"))
        out.parent.mkdir(parents=True, exist_ok=True)
        data.image.save(out)
        return out, "png"

    if export_type == "TextAsset":
        blob = raw_data(obj, data)
        ext = ".bytes"
        if blob[:2] == b"MZ":
            ext = ".dll"
        elif blob[:4] == b"\x89PNG":
            ext = ".png"
        elif blob[:3] == b"Ogg":
            ext = ".ogg"
        out = unique_path(dest.with_suffix(ext))
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_bytes(blob)
        return out, ext.lstrip(".")

    if export_type == "AudioClip":
        samples = getattr(data, "samples", {}) or {}
        if samples:
            last_out = None
            for sample_name, sample_data in samples.items():
                sample_dest = dest.parent / safe_part(sample_name, dest.name)
                out = unique_path(sample_dest)
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(sample_data)
                last_out = out
            return last_out or dest, "audio"

    blob = raw_data(obj, data)
    out = unique_path(dest.with_suffix(".bin"))
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(blob)
    return out, "raw"


def object_name(obj, data) -> str:
    for attr in ("m_Name", "name"):
        value = getattr(data, attr, None)
        if value:
            return str(value)
    return f"{obj.type.name}_{obj.path_id}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", help="Input bundle file or folder")
    parser.add_argument("destination", help="Export destination folder")
    parser.add_argument("--types", default=",".join(sorted(DEFAULT_TYPES)), help="Comma-separated Unity object types")
    parser.add_argument("--extensions", default=".bundle,.bytes,.unity3d,", help="Input file extensions; empty part allows no-extension files")
    parser.add_argument("--xor-prefix", type=parse_int, default=0, help="XOR first N bytes before UnityPy.load, e.g. 222")
    parser.add_argument("--xor-key", type=parse_int, default=0x16, help="XOR key, default 0x16")
    parser.add_argument("--container-paths", action="store_true", help="Prefer env.container paths when available")
    parser.add_argument("--limit-files", type=int, default=0, help="Stop after N input files")
    parser.add_argument("--limit-objects", type=int, default=0, help="Stop after N exported objects")
    parser.add_argument("--dry-run", action="store_true", help="Only parse/list objects, do not export payloads")
    args = parser.parse_args()

    source = Path(args.source)
    destination = Path(args.destination)
    wanted_types = {item.strip() for item in args.types.split(",") if item.strip()}
    extensions = {item.strip().lower() for item in args.extensions.split(",")}
    if "" in extensions:
        extensions.add("")

    destination.mkdir(parents=True, exist_ok=True)
    manifest_path = destination / "unitypy-export-manifest.csv"
    error_path = destination / "unitypy-export-errors.log"

    total_files = 0
    total_objects = 0
    exported = 0
    rows: list[dict[str, str | int]] = []

    with error_path.open("w", encoding="utf-8") as error_log:
        for file_path in iter_files(source, extensions):
            if args.limit_files and total_files >= args.limit_files:
                break
            total_files += 1
            try:
                env = load_source(file_path, args.xor_prefix, args.xor_key)
            except Exception as exc:
                error_log.write(f"[LOAD] {file_path}: {exc}\n{traceback.format_exc()}\n")
                continue

            container_by_path_id = {}
            if args.container_paths:
                for container_path, container_obj in env.container.items():
                    container_by_path_id[getattr(container_obj, "path_id", None)] = container_path

            for obj in env.objects:
                type_name = obj.type.name
                total_objects += 1
                if type_name not in wanted_types:
                    continue
                try:
                    data = obj.read()
                    name = object_name(obj, data)
                    rel = container_by_path_id.get(getattr(obj, "path_id", None))
                    if rel:
                        base = destination / "by_container" / safe_part(rel)
                    else:
                        base = destination / "by_type" / type_name / safe_part(name)

                    if args.dry_run:
                        out_path = base
                        kind = "dry-run"
                    else:
                        out_path, kind = export_object(obj, data, base, type_name)
                        exported += 1

                    rows.append(
                        {
                            "source": str(file_path),
                            "type": type_name,
                            "name": name,
                            "path_id": getattr(obj, "path_id", ""),
                            "output": str(out_path),
                            "kind": kind,
                        }
                    )
                    if args.limit_objects and exported >= args.limit_objects:
                        break
                except Exception as exc:
                    error_log.write(f"[OBJECT] {file_path} path_id={getattr(obj, 'path_id', '')} type={type_name}: {exc}\n{traceback.format_exc()}\n")
            if args.limit_objects and exported >= args.limit_objects:
                break

    with manifest_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["source", "type", "name", "path_id", "output", "kind"])
        writer.writeheader()
        writer.writerows(rows)

    summary = {
        "source": str(source),
        "destination": str(destination),
        "files_seen": total_files,
        "objects_seen": total_objects,
        "objects_matched": len(rows),
        "objects_exported": exported,
        "xor_prefix": args.xor_prefix,
        "xor_key": hex(args.xor_key),
        "manifest": str(manifest_path),
        "errors": str(error_path),
    }
    for key, value in summary.items():
        print(f"{key}={value}")
    digest = hashlib.sha256("\n".join(f"{k}={v}" for k, v in summary.items()).encode("utf-8")).hexdigest()
    print(f"summary_sha256={digest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
