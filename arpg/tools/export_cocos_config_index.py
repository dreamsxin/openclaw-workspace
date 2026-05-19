#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil
from collections import Counter, defaultdict
from pathlib import Path

from build_godot_resource_demo import decompress_cocos_uuid, detect_kind


ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
BUNDLE_NAME = "resources"
BUNDLE_DIR = ROOT / "assets" / BUNDLE_NAME
CONFIG_PATH = BUNDLE_DIR / "config.json"
OUT_DIR = ROOT / "data" / "config_index"

TYPE_ALIASES = {
    "cc.Prefab": "prefab",
    "cc.TextAsset": "text",
    "cc.JsonAsset": "json",
    "cc.Texture2D": "texture",
    "cc.SpriteFrame": "sprite_frame",
    "cc.SpriteAtlas": "sprite_atlas",
    "sp.SkeletonData": "spine",
    "cc.AudioClip": "audio",
    "cc.ParticleAsset": "particle",
}

IMPORTANT_PREFIXES = [
    "Prefab/loading",
    "Prefab/login",
    "Prefab/mainpanel",
    "Prefab/HeroPanel",
    "Prefab/HeroListPanel",
    "Prefab/DrawCard",
    "Prefab/Shop",
    "Prefab/BagPanel",
    "Prefab/comPrefab",
    "image/com/login",
    "image/com/mainpanel",
    "image/com/HeroPanel",
    "image/com/HeroListPanel",
    "image/com/DrawCard",
    "image/com/Shop",
    "image/com/BagPanel",
    "image/head",
    "spine",
    "spineBin",
    "uispine",
    "sound",
    "configs",
]


def main() -> None:
    if not CONFIG_PATH.exists():
        raise SystemExit(f"Missing config: {CONFIG_PATH}")

    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    resources = build_resource_records(config)

    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)
    (OUT_DIR / "by_type").mkdir(parents=True)
    (OUT_DIR / "by_path_prefix").mkdir(parents=True)

    write_json(OUT_DIR / "summary.json", build_summary(config, resources))
    write_json(OUT_DIR / "README.json", {
        "purpose": "Split index generated from assets/resources/config.json for UI/resource reverse lookup.",
        "regenerate": r"python tools\export_cocos_config_index.py",
        "files": {
            "summary.json": "Counts by Cocos type and logical path prefix.",
            "by_type/*.json": "Compact path/uuid indexes grouped by Cocos asset type.",
            "by_path_prefix/*.json": "Records grouped by selected UI/resource prefixes.",
        },
    })

    write_grouped(resources, "by_type", lambda item: item["type"], compact=True)
    write_selected_prefixes(resources)

    print(f"Exported {len(resources)} resources to {OUT_DIR}")


def build_resource_records(config: dict) -> list[dict]:
    types = config.get("types", [])
    uuids = config.get("uuids", [])
    paths = config.get("paths", {})
    records: list[dict] = []

    for key in sorted(paths, key=lambda value: int(value)):
        item = paths[key]
        if not isinstance(item, list) or len(item) < 2:
            continue
        index = int(key)
        logical_path = str(item[0])
        type_index = item[1] if isinstance(item[1], int) else -1
        type_name = types[type_index] if 0 <= type_index < len(types) else str(type_index)
        uuid = uuids[index] if index < len(uuids) else ""
        uuid_decompressed = decompress_cocos_uuid(uuid) if uuid else ""
        import_path = import_path_for_uuid(uuid)
        native_paths = native_paths_for_uuid(uuid)
        native_path = native_paths[0] if native_paths else None
        record = {
            "index": index,
            "path": logical_path,
            "type_index": type_index,
            "type": type_name,
            "type_alias": TYPE_ALIASES.get(type_name, type_name),
            "uuid": uuid,
            "uuid_decompressed": uuid_decompressed,
            "import": rel(import_path),
            "native": rel(native_path),
            "native_kind": detect_kind(native_path) if native_path else "",
        }
        if type_name == "cc.SpriteFrame":
            record["sprite_frame"] = parse_sprite_frame(import_path)
        elif type_name == "sp.SkeletonData":
            record["spine"] = parse_spine(import_path)
        records.append(record)
    return records


def build_summary(config: dict, resources: list[dict]) -> dict:
    type_counts = Counter(item["type"] for item in resources)
    prefix_counts = Counter(item["path"].split("/", 1)[0] if item["path"] else "_root" for item in resources)
    selected_prefix_counts = {
        prefix: sum(1 for item in resources if item["path"] == prefix or item["path"].startswith(prefix + "/"))
        for prefix in IMPORTANT_PREFIXES
    }
    return {
        "source": rel(CONFIG_PATH),
        "bundle": BUNDLE_NAME,
        "resource_count": len(resources),
        "type_count": len(type_counts),
        "importBase": config.get("importBase", ""),
        "nativeBase": config.get("nativeBase", ""),
        "encrypted": bool(config.get("encrypted", False)),
        "isZip": bool(config.get("isZip", False)),
        "types": dict(sorted(type_counts.items())),
        "prefixes": dict(sorted(prefix_counts.items())),
        "selected_prefixes": dict(sorted(selected_prefix_counts.items())),
    }


def parse_sprite_frame(import_path: Path | None) -> dict:
    if not import_path:
        return {}
    try:
        data = json.loads(import_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return {}
    if not isinstance(data, list) or len(data) < 6:
        return {}
    texture_uuid = data[1][0] if isinstance(data[1], list) and data[1] else ""
    texture_native = native_paths_for_uuid(texture_uuid)
    frame = data[5][0] if isinstance(data[5], list) and data[5] and isinstance(data[5][0], dict) else {}
    return {
        "texture_uuid": texture_uuid,
        "texture_uuid_decompressed": decompress_cocos_uuid(texture_uuid) if texture_uuid else "",
        "texture_native": rel(texture_native[0]) if texture_native else "",
        "name": frame.get("name", ""),
        "rect": frame.get("rect", []),
        "offset": frame.get("offset", []),
        "originalSize": frame.get("originalSize", []),
        "rotated": bool(frame.get("rotated", False)),
        "capInsets": frame.get("capInsets", []),
    }


def parse_spine(import_path: Path | None) -> dict:
    if not import_path:
        return {}
    try:
        data = json.loads(import_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return {}
    if not isinstance(data, list) or len(data) < 6:
        return {}
    objects = data[5] if isinstance(data[5], list) else []
    for item in objects:
        if not isinstance(item, list) or len(item) < 6 or not isinstance(item[1], str):
            continue
        skeleton_json = item[4] if isinstance(item[4], dict) else {}
        texture_names = item[3] if isinstance(item[3], list) else []
        textures = []
        for texture_uuid in data[1] if isinstance(data[1], list) else []:
            native_paths = native_paths_for_uuid(texture_uuid)
            if native_paths:
                textures.append(rel(native_paths[0]))
        animations = []
        if isinstance(skeleton_json.get("animations"), dict):
            animations = sorted(skeleton_json["animations"].keys())
        return {
            "name": item[1],
            "texture_names": texture_names,
            "textures": textures,
            "animations": animations,
        }
    return {}


def write_grouped(resources: list[dict], folder_name: str, key_fn, compact: bool = False) -> None:
    groups: dict[str, list[dict]] = defaultdict(list)
    for item in resources:
        groups[key_fn(item)].append(compact_record(item) if compact else item)
    for group_key, items in sorted(groups.items()):
        write_json(OUT_DIR / folder_name / f"{safe_name(group_key)}.json", items)


def write_selected_prefixes(resources: list[dict]) -> None:
    for prefix in IMPORTANT_PREFIXES:
        items = [item for item in resources if item["path"] == prefix or item["path"].startswith(prefix + "/")]
        if items:
            write_json(OUT_DIR / "by_path_prefix" / f"{safe_name(prefix)}.json", items)


def compact_record(item: dict) -> dict:
    record = {
        "index": item["index"],
        "path": item["path"],
        "uuid": item["uuid"],
        "uuid_decompressed": item["uuid_decompressed"],
        "import": item["import"],
        "native": item["native"],
    }
    sprite_frame = item.get("sprite_frame")
    if isinstance(sprite_frame, dict) and sprite_frame:
        record["texture_native"] = sprite_frame.get("texture_native", "")
        record["rect"] = sprite_frame.get("rect", [])
        record["originalSize"] = sprite_frame.get("originalSize", [])
        record["rotated"] = bool(sprite_frame.get("rotated", False))
    spine = item.get("spine")
    if isinstance(spine, dict) and spine:
        record["spine_name"] = spine.get("name", "")
        record["animations"] = spine.get("animations", [])
        record["textures"] = spine.get("textures", [])
    return record


def import_path_for_uuid(uuid: str) -> Path | None:
    if not uuid:
        return None
    file_name = decompress_cocos_uuid(uuid)
    path = BUNDLE_DIR / "import" / file_name[:2] / f"{file_name}.json"
    return path if path.exists() else None


def native_paths_for_uuid(uuid: str) -> list[Path]:
    if not uuid:
        return []
    file_name = decompress_cocos_uuid(uuid)
    native_dir = BUNDLE_DIR / "native" / file_name[:2]
    if not native_dir.exists():
        return []
    return sorted(path for path in native_dir.glob(f"{file_name}*") if path.is_file())


def rel(path: Path | None) -> str:
    if not path:
        return ""
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def safe_name(value: str) -> str:
    safe = re.sub(r"[^A-Za-z0-9._-]+", "__", value).strip("._-")
    return safe or "_root"


def write_json(path: Path, data: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
