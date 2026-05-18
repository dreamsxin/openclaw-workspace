#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from export_cocos_prefab_layout import find_native_path, rel, resolve_sprite_frame

ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
CONFIG_PATH = ROOT / "assets" / "resources" / "config.json"
OUT_PATH = ROOT / "data" / "named_resource_index.json"
PREFIXES = [
    "image/com/ActivityPanel/NewHeroComing/",
    "image/com/ActivityPanel/ZhaoHuan/",
    "image/com/ActivityPanel/thousandDrawCardActivity/",
    "image/com/Battle",
    "image/com/DrawCard/",
    "image/com/FuBen/",
    "image/com/Guild/",
    "image/com/Jingji/",
    "image/com/map/",
    "image/com/pvpActivity/",
    "image/com/skyCity/",
    "image/common/gh_",
    "image/guildFlag/",
    "image/head/",
    "map/worldMap/",
]


def main() -> int:
    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    paths = config.get("paths", {})
    uuids = config.get("uuids", [])
    index = {}
    for key, entry in paths.items():
        if not isinstance(entry, list) or len(entry) < 2:
            continue
        asset_path = str(entry[0])
        if not any(asset_path.startswith(prefix) for prefix in PREFIXES):
            continue
        path_index = int(key)
        if path_index < 0 or path_index >= len(uuids):
            continue
        uuid = str(uuids[path_index])
        type_index = int(entry[1])
        item = {"path": asset_path, "uuid": uuid, "type_index": type_index}
        if type_index == 9:
            item.update(resolve_sprite_frame(uuid))
        elif type_index == 8:
            native_path = find_native_path(uuid)
            item.update({
                "texture_path": rel(native_path) if native_path else "",
                "sprite_name": asset_path.rsplit("/", 1)[-1],
                "sprite_rect": [],
                "sprite_offset": [],
                "sprite_original_size": [],
                "sprite_rotated": False,
                "sprite_cap_insets": [],
            })
        if item.get("texture_path"):
            index[asset_path] = item
    OUT_PATH.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {OUT_PATH} ({len(index)} resources)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
