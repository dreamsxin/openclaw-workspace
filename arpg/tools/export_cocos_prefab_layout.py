#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from build_godot_resource_demo import decompress_cocos_uuid

ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
OUT_DIR = ROOT / "data" / "prefab_layouts"
MANIFEST_PATH = ROOT / "data" / "prefab_layouts.json"
BUNDLES = ["resources", "main", "internal"]
PREFABS = [
    ("启动加载", "Prefab/loading/LoadingPre"),
    ("加载进度", "Prefab/loading/loadingProgress"),
    ("登录面板", "Prefab/login/LoginPre"),
    ("登录选服", "Prefab/login/pfLoginPanelPre"),
    ("主城", "Prefab/mainpanel/MainPre"),
    ("主城导航", "Prefab/mainpanel/daohangPre"),
    ("主城头像", "Prefab/mainpanel/heroHead"),
    ("英雄", "Prefab/HeroPanel/HeroMainPre"),
    ("背包", "Prefab/BagPanel/BagPre"),
    ("背包格子", "Prefab/BagPanel/GridBoxItemPre"),
    ("抽卡", "Prefab/DrawCard/drawCardPre"),
    ("战斗", "Prefab/Battle/battle"),
    ("活动抽卡", "Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityPre"),
    ("活动抽卡-登录领取", "Prefab/ActivityPanel/DrawCardActivity/13002"),
    ("活动抽卡-循环礼包", "Prefab/ActivityPanel/DrawCardActivity/13003"),
    ("活动抽卡-抽数任务", "Prefab/ActivityPanel/DrawCardActivity/13004"),
    ("活动抽卡-许愿礼包", "Prefab/ActivityPanel/DrawCardActivity/13005"),
    ("活动抽卡页签", "Prefab/ActivityPanel/DrawCardActivity/DrawCardActivityToggle"),
    ("公会", "Prefab/Guild/GuildMainPre"),
    ("竞技", "Prefab/JingjiPrefab/JingjiPre"),
    ("天空城", "Prefab/SkyCityPanel/SkyCityPre"),
]


def is_vec2(value: object) -> bool:
    return isinstance(value, list) and len(value) == 3 and value[0] == 5 and all(isinstance(x, (int, float)) for x in value[1:])


def is_trs(value: object) -> bool:
    return (
        isinstance(value, list)
        and len(value) == 10
        and all(isinstance(x, (int, float)) for x in value)
    )


def export_layout(prefab_path: str) -> dict:
    catalog = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))
    prefab = next(item for item in catalog["prefabs"] if item["path"] == prefab_path)
    data = json.loads((ROOT / prefab["import"]).read_text(encoding="utf-8"))
    objects = data[5] if len(data) > 5 and isinstance(data[5], list) else []
    uuid_table = data[1] if len(data) > 1 and isinstance(data[1], list) else []
    classes = data[3] if len(data) > 3 and isinstance(data[3], list) else []
    templates = data[4] if len(data) > 4 and isinstance(data[4], list) else []

    node_records = {}
    for index, item in enumerate(objects):
        if not isinstance(item, list) or len(item) < 2 or not isinstance(item[1], str):
            continue
        node_class, node_values = decode_component(item, classes, templates)
        name = str(node_values.get("_name") or item[1])
        if name.startswith("_") or name in {"data"}:
            continue
        size = vec2_from_cocos(node_values.get("_contentSize"))
        trs = node_values.get("_trs")
        if not is_trs(trs):
            trs = None
        for value in item:
            if size is None and is_vec2(value):
                size = [float(value[1]), float(value[2])]
            elif trs is None and is_trs(value):
                trs = value
        if size is None and trs is None:
            continue
        anchor = anchor_from_cocos(node_values.get("_anchorPoint"))
        parent_index = node_values.get("_parent")
        if not isinstance(parent_index, int):
            parent_index = None
        active = node_values.get("_active", True)
        sprite_uuid = ""
        sprite_info = {}
        skeleton_uuid = ""
        skeleton_info = {}
        label_info = {}
        widget_info = {}
        for component in iter_components(item):
            class_name, values = decode_component(component, classes, templates)
            if class_name == "cc.Label":
                label_info = resolve_label(values)
            elif class_name == "cc.Widget":
                widget_info = resolve_widget(values)
        if should_auto_texture(name):
            for component in iter_components(item):
                class_name, values = decode_component(component, classes, templates)
                if class_name in {"cc.Sprite", "cc.Button"}:
                    for ref in sprite_frame_refs(class_name, values):
                        candidate_uuid = uuid_from_ref(ref, uuid_table)
                        candidate_info = resolve_sprite_frame(candidate_uuid)
                        if candidate_info.get("texture_path"):
                            sprite_uuid = candidate_uuid
                            sprite_info = candidate_info
                            if class_name == "cc.Sprite":
                                sprite_info["sprite_type"] = int(values.get("_type", 0) or 0)
                                sprite_info["sprite_size_mode"] = int(values.get("_sizeMode", 0) or 0)
                            break
                    if sprite_info:
                        break
                elif class_name == "sp.Skeleton":
                    candidate_uuid = uuid_from_ref(values.get("_N$skeletonData"), uuid_table)
                    candidate_info = resolve_skeleton_data(candidate_uuid)
                    if candidate_info:
                        skeleton_uuid = candidate_uuid
                        skeleton_info = candidate_info
        node_records[index] = {
            "index": index,
            "name": name,
            "active": bool(active),
            "parent_index": parent_index,
            "size": size or [80.0, 36.0],
            "anchor": anchor or [0.5, 0.5],
            "position": [float(trs[0]), float(trs[1])] if trs else [0.0, 0.0],
            "global_position": [0.0, 0.0],
            "scale": [float(trs[6]), float(trs[7])] if trs else [1.0, 1.0],
            "rotation_z": float(trs[9]) if trs else 0.0,
            "sprite_uuid": sprite_uuid,
            "texture_path": sprite_info.get("texture_path", ""),
            "sprite_name": sprite_info.get("sprite_name", ""),
            "sprite_rect": sprite_info.get("sprite_rect", []),
            "sprite_offset": sprite_info.get("sprite_offset", []),
            "sprite_original_size": sprite_info.get("sprite_original_size", []),
            "sprite_rotated": bool(sprite_info.get("sprite_rotated", False)),
            "sprite_cap_insets": sprite_info.get("sprite_cap_insets", []),
            "sprite_type": int(sprite_info.get("sprite_type", 0) or 0),
            "sprite_size_mode": int(sprite_info.get("sprite_size_mode", 0) or 0),
            "skeleton_uuid": skeleton_uuid,
            "skeleton_name": skeleton_info.get("name", ""),
            "skeleton_textures": skeleton_info.get("textures", []),
            "skeleton_animations": skeleton_info.get("animations", []),
            "label_text": label_info.get("text", ""),
            "label_font_size": label_info.get("font_size", 0),
            "label_line_height": label_info.get("line_height", 0),
            "label_horizontal_align": label_info.get("horizontal_align", 0),
            "label_vertical_align": label_info.get("vertical_align", 0),
            "widget": widget_info,
        }

    apply_widget_layout(node_records)

    global_cache = {}
    for index, node in node_records.items():
        node["global_position"] = global_position(index, node_records, global_cache)

    return {"prefab": prefab_path, "import": prefab["import"], "nodes": list(node_records.values())}


def vec2_from_cocos(value: object) -> list[float] | None:
    if is_vec2(value):
        return [float(value[1]), float(value[2])]
    return None


def anchor_from_cocos(value: object) -> list[float] | None:
    if isinstance(value, list) and len(value) == 3 and all(isinstance(x, (int, float)) for x in value[1:]):
        return [float(value[1]), float(value[2])]
    return None


def apply_widget_layout(node_records: dict[int, dict]) -> None:
    for _ in range(3):
        for node in node_records.values():
            widget = node.get("widget") or {}
            if not widget:
                continue
            parent_index = node.get("parent_index")
            if not isinstance(parent_index, int) or parent_index not in node_records:
                continue
            parent = node_records[parent_index]
            apply_widget_to_node(node, parent, widget)


def apply_widget_to_node(node: dict, parent: dict, widget: dict) -> None:
    flags = int(widget.get("align_flags", 0) or 0)
    if flags <= 0:
        return
    parent_size = parent.get("size", [0.0, 0.0])
    size = [float(node.get("size", [0.0, 0.0])[0]), float(node.get("size", [0.0, 0.0])[1])]
    pos = [float(node.get("position", [0.0, 0.0])[0]), float(node.get("position", [0.0, 0.0])[1])]
    anchor = node.get("anchor", [0.5, 0.5])
    parent_w = float(parent_size[0])
    parent_h = float(parent_size[1])
    anchor_x = float(anchor[0])
    anchor_y = float(anchor[1])

    top = float(widget.get("top", 0.0) or 0.0)
    bottom = float(widget.get("bottom", 0.0) or 0.0)
    left = float(widget.get("left", 0.0) or 0.0)
    right = float(widget.get("right", 0.0) or 0.0)
    hcenter = float(widget.get("horizontal_center", 0.0) or 0.0)
    vcenter = float(widget.get("vertical_center", 0.0) or 0.0)

    # Cocos Creator widget flags: TOP=1, MID=2, BOT=4, LEFT=8, CENTER=16, RIGHT=32.
    if flags & 8 and flags & 32:
        size[0] = max(0.0, parent_w - left - right)
        pos[0] = -parent_w * 0.5 + left + size[0] * anchor_x
    elif flags & 8:
        pos[0] = -parent_w * 0.5 + left + size[0] * anchor_x
    elif flags & 32:
        pos[0] = parent_w * 0.5 - right - size[0] * (1.0 - anchor_x)
    elif flags & 16:
        pos[0] = hcenter

    if flags & 1 and flags & 4:
        size[1] = max(0.0, parent_h - top - bottom)
        pos[1] = parent_h * 0.5 - top - size[1] * (1.0 - anchor_y)
    elif flags & 1:
        pos[1] = parent_h * 0.5 - top - size[1] * (1.0 - anchor_y)
    elif flags & 4:
        pos[1] = -parent_h * 0.5 + bottom + size[1] * anchor_y
    elif flags & 2:
        pos[1] = vcenter

    node["size"] = size
    node["position"] = pos
    node["widget_applied"] = True


def global_position(index: int, node_records: dict[int, dict], cache: dict[int, list[float]]) -> list[float]:
    if index in cache:
        return cache[index]
    node = node_records[index]
    local = node.get("position", [0.0, 0.0])
    x = float(local[0])
    y = float(local[1])
    parent_index = node.get("parent_index")
    if isinstance(parent_index, int) and parent_index in node_records and parent_index != index:
        parent = global_position(parent_index, node_records, cache)
        x += float(parent[0])
        y += float(parent[1])
    cache[index] = [x, y]
    return cache[index]


def resolve_sprite_frame(sprite_uuid: str) -> dict:
    if not sprite_uuid:
        return {}
    import_path = find_import_path(sprite_uuid)
    if not import_path:
        return {}
    try:
        data = json.loads(import_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return {}
    if not isinstance(data, list) or len(data) < 6:
        return {}
    texture_uuid = data[1][0] if isinstance(data[1], list) and data[1] else ""
    frame = data[5][0] if isinstance(data[5], list) and data[5] and isinstance(data[5][0], dict) else {}
    texture_path = find_native_path(texture_uuid)
    return {
        "texture_uuid": texture_uuid,
        "texture_path": rel(texture_path) if texture_path else "",
        "sprite_name": frame.get("name", ""),
        "sprite_rect": frame.get("rect", []),
        "sprite_offset": frame.get("offset", []),
        "sprite_original_size": frame.get("originalSize", []),
        "sprite_rotated": bool(frame.get("rotated", False)),
        "sprite_cap_insets": frame.get("capInsets", []),
    }


def resolve_skeleton_data(skeleton_uuid: str) -> dict:
    if not skeleton_uuid:
        return {}
    import_path = find_import_path(skeleton_uuid)
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
        if not isinstance(item, list) or len(item) < 2:
            continue
        if isinstance(item[1], str) and len(item) >= 6:
            skeleton_json = item[4] if isinstance(item[4], dict) else {}
            texture_names = item[3] if isinstance(item[3], list) else []
            textures = []
            for texture_uuid in data[1] if isinstance(data[1], list) else []:
                texture_path = find_native_path(texture_uuid)
                if texture_path:
                    textures.append(rel(texture_path))
            animations = []
            if isinstance(skeleton_json, dict) and isinstance(skeleton_json.get("animations"), dict):
                animations = sorted(skeleton_json["animations"].keys())
            return {
                "name": item[1],
                "texture_names": texture_names,
                "textures": textures,
                "animations": animations,
            }
    return {}


def resolve_label(values: dict) -> dict:
    text = values.get("_string", "")
    if text is None:
        text = ""
    return {
        "text": str(text),
        "font_size": int(values.get("_fontSize", 18) or 18),
        "line_height": int(values.get("_lineHeight", values.get("_fontSize", 18)) or 18),
        "horizontal_align": int(values.get("_N$horizontalAlign", 0) or 0),
        "vertical_align": int(values.get("_N$verticalAlign", 0) or 0),
    }


def resolve_widget(values: dict) -> dict:
    return {
        "align_flags": int(values.get("_alignFlags", 0) or 0),
        "left": float(values.get("_left", 0.0) or 0.0),
        "right": float(values.get("_right", 0.0) or 0.0),
        "top": float(values.get("_top", 0.0) or 0.0),
        "bottom": float(values.get("_bottom", 0.0) or 0.0),
        "horizontal_center": float(values.get("_horizontalCenter", 0.0) or 0.0),
        "vertical_center": float(values.get("_verticalCenter", 0.0) or 0.0),
        "original_width": float(values.get("_originalWidth", 0.0) or 0.0),
        "original_height": float(values.get("_originalHeight", 0.0) or 0.0),
    }


def find_import_path(uuid: str) -> Path | None:
    file_name = decompress_cocos_uuid(uuid)
    for bundle in BUNDLES:
        path = ROOT / "assets" / bundle / "import" / file_name[:2] / f"{file_name}.json"
        if path.exists():
            return path
    return None


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
        candidates = sorted(path for path in native_dir.glob(f"{file_name}*") if path.suffix.lower() in {".png", ".jpg", ".jpeg"})
        if candidates:
            return candidates[0]
    return None


def rel(path: Path | None) -> str:
    if not path:
        return ""
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def iter_components(item: list) -> list:
    for value in item:
        if not isinstance(value, list):
            continue
        if value and all(isinstance(part, list) for part in value):
            return value
    return []


def decode_component(component: list, classes: list, templates: list) -> tuple[str, dict]:
    if not component or not isinstance(component[0], int):
        return "", {}
    template_index = component[0]
    if template_index < 0 or template_index >= len(templates):
        return "", {}
    template = templates[template_index]
    if not isinstance(template, list) or not template or not isinstance(template[0], int):
        return "", {}
    class_index = template[0]
    if class_index < 0 or class_index >= len(classes):
        return "", {}
    class_info = classes[class_index]
    if not isinstance(class_info, list) or len(class_info) < 2:
        return "", {}
    fields = class_info[1] if isinstance(class_info[1], list) else []
    values = {}
    for value_offset, field_index in enumerate(template[1:], start=1):
        if value_offset >= len(component):
            break
        if isinstance(field_index, int) and 0 <= field_index < len(fields):
            values[fields[field_index]] = component[value_offset]
    return str(class_info[0]), values


def sprite_frame_refs(class_name: str, values: dict) -> list[int]:
    if class_name == "cc.Sprite":
        return [extract_ref(values.get("_spriteFrame"))]
    if class_name == "cc.Button":
        return [
            extract_ref(values.get("_N$normalSprite")),
            extract_ref(values.get("_N$pressedSprite")),
            extract_ref(values.get("_N$hoverSprite")),
            extract_ref(values.get("_N$disabledSprite")),
        ]
    return []


def extract_ref(value: object) -> int:
    if isinstance(value, int):
        return value
    if isinstance(value, list) and len(value) == 1 and isinstance(value[0], int):
        return value[0]
    if isinstance(value, list) and len(value) >= 2 and isinstance(value[0], int) and isinstance(value[1], int):
        return value[0]
    return -1


def uuid_from_ref(ref: int, uuid_table: list) -> str:
    if not isinstance(ref, int):
        return ""
    if ref < 0 or ref >= len(uuid_table):
        return ""
    return str(uuid_table[ref])


def should_auto_texture(name: str) -> bool:
    lowered = name.lower()
    if lowered in {"new label", "label", "text_label", "placeholder_label", "richtext", "color", "tmptxt"}:
        return False
    if lowered.startswith(("txt", "lbl")):
        return False
    return True


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = []
    for label, prefab in PREFABS:
        layout = export_layout(prefab)
        name = prefab.split("/")[-1]
        output = OUT_DIR / f"{name}.json"
        output.write_text(json.dumps(layout, ensure_ascii=False, indent=2), encoding="utf-8")
        texture_count = sum(1 for node in layout["nodes"] if node.get("texture_path"))
        manifest.append({
            "label": label,
            "prefab": prefab,
            "layout": rel(output),
            "nodes": len(layout["nodes"]),
            "texture_nodes": texture_count,
        })
        print(prefab, len(layout["nodes"]), "textures", texture_count)
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
