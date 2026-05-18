#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from export_cocos_prefab_layout import find_native_path, rel, resolve_sprite_frame

ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
CONFIG_PATH = ROOT / "assets" / "resources" / "config.json"
OUT_PATH = ROOT / "data" / "equipment_icon_index.json"


def main() -> int:
    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    paths = config.get("paths", {})
    uuids = config.get("uuids", [])
    items = []
    for key, entry in paths.items():
        if not isinstance(entry, list) or len(entry) < 2:
            continue
        asset_path = str(entry[0])
        type_index = int(entry[1])
        if not asset_path.startswith("image/equipment/"):
            continue
        index = int(key)
        if index < 0 or index >= len(uuids):
            continue
        uuid = str(uuids[index])
        item = {
            "id": asset_path.rsplit("/", 1)[-1],
            "path": asset_path,
            "uuid": uuid,
            "type_index": type_index,
        }
        if type_index == 9:
            item.update(resolve_sprite_frame(uuid))
        elif type_index == 8:
            native_path = find_native_path(uuid)
            item["texture_path"] = rel(native_path) if native_path else ""
            item["sprite_name"] = asset_path.rsplit("/", 1)[-1]
            item["sprite_rect"] = []
            item["sprite_offset"] = []
            item["sprite_original_size"] = []
            item["sprite_rotated"] = False
            item["sprite_cap_insets"] = []
        if item.get("texture_path"):
            items.append(item)
    items.sort(key=lambda item: (len(str(item["id"])), str(item["id"])))
    OUT_PATH.write_text(json.dumps(items, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"wrote {OUT_PATH} ({len(items)} icons)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
