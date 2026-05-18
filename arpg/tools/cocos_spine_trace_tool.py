#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from build_godot_resource_demo import BASE64_VALUES, decompress_cocos_uuid
from export_spine_runtime_data import export as export_spine_runtime

ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
ASSETS = ROOT / "assets"
BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


def compress_cocos_uuid(value: str) -> str:
    hex_text = value.strip().lower().replace("-", "")
    if len(hex_text) != 32:
        return value
    try:
        int(hex_text, 16)
    except ValueError:
        return value

    encoded = hex_text[:2]
    tail = hex_text[2:]
    for index in range(0, len(tail), 6):
        number = int(tail[index:index + 6], 16)
        encoded += BASE64_CHARS[(number >> 18) & 0x3F]
        encoded += BASE64_CHARS[(number >> 12) & 0x3F]
        encoded += BASE64_CHARS[(number >> 6) & 0x3F]
        encoded += BASE64_CHARS[number & 0x3F]
    return encoded


def uuid_from_native_path(path: Path) -> str:
    stem = path.stem
    if len(stem) == 36 and "-" in stem:
        return stem
    if len(stem) == 32:
        return f"{stem[:8]}-{stem[8:12]}-{stem[12:16]}-{stem[16:20]}-{stem[20:32]}"
    raise ValueError(f"Cannot derive uuid from native filename: {path}")


def iter_import_jsons() -> list[Path]:
    paths: list[Path] = []
    for bundle in ["resources", "main", "internal"]:
        import_root = ASSETS / bundle / "import"
        if import_root.exists():
            paths.extend(sorted(import_root.rglob("*.json")))
    return paths


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def skeleton_summary(path: Path, data) -> dict | None:
    objects = data[5] if isinstance(data, list) and len(data) > 5 and isinstance(data[5], list) else []
    for item in objects:
        if isinstance(item, list) and len(item) >= 6 and isinstance(item[1], str) and isinstance(item[4], dict):
            skeleton = item[4]
            return {
                "name": item[1],
                "import": str(path),
                "uuid": import_path_to_uuid(path),
                "textures": item[3],
                "animations": sorted(skeleton.get("animations", {}).keys()),
                "bones": len(skeleton.get("bones", [])),
                "slots": len(skeleton.get("slots", [])),
                "skins": len(skeleton.get("skins", {})),
            }
    return None


def import_path_to_uuid(path: Path) -> str:
    return decompress_cocos_uuid(path.stem)


def trace_native(native_path: Path) -> list[dict]:
    texture_uuid = uuid_from_native_path(native_path)
    compressed = compress_cocos_uuid(texture_uuid)
    matches: list[dict] = []
    for import_path in iter_import_jsons():
        text = import_path.read_text(encoding="utf-8", errors="ignore")
        if texture_uuid not in text and compressed not in text:
            continue
        data = load_json(import_path)
        summary = skeleton_summary(import_path, data)
        if summary:
            summary["matched_texture_uuid"] = texture_uuid
            summary["matched_texture_uuid_compressed"] = compressed
            matches.append(summary)
    return matches


def print_json(payload) -> None:
    print(json.dumps(payload, ensure_ascii=False, indent=2))


def command_uuid(args: argparse.Namespace) -> int:
    value = args.value.strip()
    payload = {
        "input": value,
        "decompressed": decompress_cocos_uuid(value),
        "compressed": compress_cocos_uuid(decompress_cocos_uuid(value)),
    }
    print_json(payload)
    return 0


def command_trace_native(args: argparse.Namespace) -> int:
    native_path = Path(args.native)
    matches = trace_native(native_path)
    print_json({
        "native": str(native_path),
        "texture_uuid": uuid_from_native_path(native_path),
        "texture_uuid_compressed": compress_cocos_uuid(uuid_from_native_path(native_path)),
        "matches": matches,
    })
    return 0 if matches else 2


def command_export_native(args: argparse.Namespace) -> int:
    native_path = Path(args.native)
    matches = trace_native(native_path)
    if not matches:
        print(f"No SkeletonData import references {native_path}", file=sys.stderr)
        return 2
    for summary in matches:
        name = summary["name"] or summary["uuid"]
        out = Path(args.out_dir) / f"{name}.json"
        export_spine_runtime(summary["uuid"], out)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Trace Cocos Creator UUID/native PNG to Spine SkeletonData.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    uuid_parser = subparsers.add_parser("uuid", help="Compress/decompress a Cocos Creator UUID.")
    uuid_parser.add_argument("value")
    uuid_parser.set_defaults(func=command_uuid)

    trace_parser = subparsers.add_parser("trace-native", help="Find SkeletonData imports that reference a native image.")
    trace_parser.add_argument("native")
    trace_parser.set_defaults(func=command_trace_native)

    export_parser = subparsers.add_parser("export-native", help="Trace a native image and export matching Spine runtime JSON.")
    export_parser.add_argument("native")
    export_parser.add_argument("--out-dir", default=str(ROOT / "data" / "spine_runtime"))
    export_parser.set_defaults(func=command_export_native)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
