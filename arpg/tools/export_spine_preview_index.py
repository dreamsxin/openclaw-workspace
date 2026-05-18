#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from build_godot_resource_demo import decompress_cocos_uuid

ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
OUT_PATH = ROOT / "data" / "spine_preview_index.json"
BUNDLES = ["resources", "main", "internal"]


def rel(path: Path | None) -> str:
    if not path:
        return ""
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def find_native_path(uuid: str) -> Path | None:
    if not uuid:
        return None
    file_name = decompress_cocos_uuid(uuid)
    for bundle in BUNDLES:
        native_dir = ROOT / "assets" / bundle / "native" / file_name[:2]
        if not native_dir.exists():
            continue
        for ext in [".png", ".jpg", ".jpeg"]:
            path = native_dir / f"{file_name}{ext}"
            if path.exists():
                return path
        candidates = sorted(
            path for path in native_dir.glob(f"{file_name}*")
            if path.suffix.lower() in {".png", ".jpg", ".jpeg"}
        )
        if candidates:
            return candidates[0]
    return None


def read_spine(import_path: Path) -> dict:
    data = json.loads(import_path.read_text(encoding="utf-8"))
    uuid_table = data[1] if isinstance(data, list) and len(data) > 1 and isinstance(data[1], list) else []
    objects = data[5] if isinstance(data, list) and len(data) > 5 and isinstance(data[5], list) else []

    for item in objects:
        if not isinstance(item, list) or len(item) < 6:
            continue
        name = item[1] if isinstance(item[1], str) else ""
        atlas_text = item[2] if isinstance(item[2], str) else ""
        texture_names = item[3] if isinstance(item[3], list) else []
        skeleton_json = item[4] if isinstance(item[4], dict) else {}
        textures = []
        for uuid in uuid_table:
            native = find_native_path(str(uuid))
            if native:
                textures.append(rel(native))
        animations = sorted((skeleton_json.get("animations") or {}).keys()) if isinstance(skeleton_json, dict) else []
        bones = skeleton_json.get("bones") or []
        slots = skeleton_json.get("slots") or []
        skins = skeleton_json.get("skins") or []
        return {
            "name": name,
            "atlas_text": atlas_text,
            "texture_names": texture_names,
            "textures": textures,
            "animations": animations,
            "bone_count": len(bones) if isinstance(bones, list) else 0,
            "slot_count": len(slots) if isinstance(slots, list) else 0,
            "skin_count": len(skins) if isinstance(skins, list) else 0,
            "spine_version": ((skeleton_json.get("skeleton") or {}).get("spine") if isinstance(skeleton_json, dict) else "") or "",
        }
    return {}


def main() -> int:
    catalog = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))
    index = {}
    for item in catalog.get("spine", []):
        import_path = ROOT / item.get("import", "")
        if not import_path.exists():
            continue
        info = read_spine(import_path)
        if not info:
            continue
        key = item.get("uuid") or item.get("path")
        info.update({
            "path": item.get("path", ""),
            "uuid": item.get("uuid", ""),
            "import": item.get("import", ""),
        })
        index[key] = info
    OUT_PATH.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {OUT_PATH} ({len(index)} spine records)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
