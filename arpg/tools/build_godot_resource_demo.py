#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import shutil
from collections import Counter
from pathlib import Path


ROOT = Path(r"D:\work\openclaw-workspace\arpg\nvshenres_decrypted_full")
ASSETS = ROOT / "assets"
DATA_DIR = ROOT / "data"
SCENES_DIR = ROOT / "scenes"
SCRIPTS_DIR = ROOT / "scripts"


TYPE_NAMES = {
    "cc.Prefab": "prefab",
    "cc.LabelAtlas": "label_atlas",
    "cc.AnimationClip": "animation",
    "cc.TextAsset": "text",
    "cc.JsonAsset": "json",
    "cc.Material": "material",
    "cc.EffectAsset": "effect",
    "cc.TTFFont": "font",
    "cc.Texture2D": "texture",
    "cc.SpriteFrame": "sprite_frame",
    "cc.SpriteAtlas": "sprite_atlas",
    "sp.SkeletonData": "spine",
    "cc.Asset": "asset",
    "cc.AudioClip": "audio",
    "cc.ParticleAsset": "particle",
}

BASE64_VALUES = {char: index for index, char in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")}


def detect_kind(path: Path) -> str:
    data = path.read_bytes()[:32]
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png"
    if data.startswith(b"\xff\xd8\xff"):
        return "jpg"
    if data.startswith(b"ID3") or data.startswith((b"\xff\xfb", b"\xff\xf3", b"\xff\xf2")):
        return "mp3"
    if data.startswith(b"\x00\x01\x00\x00") or data.startswith(b"OTTO"):
        return "font"
    stripped = data.lstrip()
    if stripped.startswith((b"{", b"[")):
        return "json"
    if stripped:
        try:
            path.read_text(encoding="utf-8")
            return "text"
        except UnicodeDecodeError:
            pass
    return "binary"


def uuid_to_import_path(bundle_dir: Path, uuid: str) -> Path | None:
    file_name = decompress_cocos_uuid(uuid)
    subdir = file_name[:2]
    path = bundle_dir / "import" / subdir / f"{file_name}.json"
    return path if path.exists() else None


def uuid_to_native_candidates(bundle_dir: Path, uuid: str) -> list[Path]:
    file_name = decompress_cocos_uuid(uuid)
    subdir = file_name[:2]
    native_dir = bundle_dir / "native" / subdir
    if not native_dir.exists():
        return []
    return sorted(native_dir.glob(f"{file_name}*"))


def decompress_cocos_uuid(value: str) -> str:
    if "-" in value or len(value) != 22:
        return value

    hex_text = value[:2]
    encoded = value[2:]
    for index in range(0, len(encoded), 4):
        chunk = encoded[index:index + 4]
        if len(chunk) < 4 or any(char not in BASE64_VALUES for char in chunk):
            return value
        number = (
            (BASE64_VALUES[chunk[0]] << 18)
            | (BASE64_VALUES[chunk[1]] << 12)
            | (BASE64_VALUES[chunk[2]] << 6)
            | BASE64_VALUES[chunk[3]]
        )
        hex_text += f"{number:06x}"

    return f"{hex_text[:8]}-{hex_text[8:12]}-{hex_text[12:16]}-{hex_text[16:20]}-{hex_text[20:32]}"


def load_bundle(bundle_name: str) -> dict:
    bundle_dir = ASSETS / bundle_name
    config_path = bundle_dir / "config.json"
    if not config_path.exists():
        return {"name": bundle_name, "exists": False}
    config = json.loads(config_path.read_text(encoding="utf-8"))
    types = config.get("types", [])
    uuids = config.get("uuids", [])
    assets = []
    type_counts: Counter[str] = Counter()

    for key, item in config.get("paths", {}).items():
        if not isinstance(item, list) or len(item) < 2:
            continue
        index = int(key)
        path_name = item[0]
        type_index = item[1]
        type_name = types[type_index] if isinstance(type_index, int) and type_index < len(types) else str(type_index)
        uuid = uuids[index] if index < len(uuids) else ""
        short_type = TYPE_NAMES.get(type_name, type_name)
        import_path = uuid_to_import_path(bundle_dir, uuid)
        native_candidates = uuid_to_native_candidates(bundle_dir, uuid)
        native_path = native_candidates[0] if native_candidates else None
        kind = detect_kind(native_path) if native_path and native_path.is_file() else ""

        type_counts[short_type] += 1
        assets.append({
            "bundle": bundle_name,
            "path": path_name,
            "type": short_type,
            "cocos_type": type_name,
            "uuid": uuid,
            "import": rel(import_path) if import_path else "",
            "native": rel(native_path) if native_path else "",
            "native_kind": kind,
        })

    scenes = []
    for scene_path, uuid_index in config.get("scenes", {}).items():
        uuid = uuids[uuid_index] if isinstance(uuid_index, int) and uuid_index < len(uuids) else ""
        import_path = uuid_to_import_path(bundle_dir, uuid)
        native_candidates = uuid_to_native_candidates(bundle_dir, uuid)
        scenes.append({
            "bundle": bundle_name,
            "path": scene_path,
            "uuid": uuid,
            "import": rel(import_path) if import_path else "",
            "native": rel(native_candidates[0]) if native_candidates else "",
        })

    return {
        "name": bundle_name,
        "exists": True,
        "config": rel(config_path),
        "type_counts": dict(type_counts),
        "asset_count": len(assets),
        "scene_count": len(scenes),
        "assets": assets,
        "scenes": scenes,
    }


def rel(path: Path | None) -> str:
    if not path:
        return ""
    return path.resolve().relative_to(ROOT.resolve()).as_posix()


def summarize_cocos_import(import_rel_path: str) -> dict:
    if not import_rel_path:
        return {}
    path = ROOT / import_rel_path
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return {}
    if not isinstance(data, list):
        return {}

    strings: list[str] = []
    component_types: Counter[str] = Counter()
    node_names: Counter[str] = Counter()
    sprite_refs: Counter[str] = Counter()

    if len(data) > 2 and isinstance(data[2], list):
        strings.extend(item for item in data[2] if isinstance(item, str))
    if len(data) > 3 and isinstance(data[3], list):
        for item in data[3]:
            if isinstance(item, list) and item:
                class_name = item[0]
                if isinstance(class_name, str):
                    component_types[class_name] += 1

    for value in strings:
        if value.startswith(("cc.", "sp.")):
            component_types[value] += 1
        if any(token in value for token in ["Panel", "Btn", "btn", "Label", "label", "Layer", "layer", "bg", "icon", "Node"]):
            node_names[value] += 1
        if value.startswith(("image/", "Prefab/", "spine/", "uispine/", "sound/", "map/")):
            sprite_refs[value] += 1

    return {
        "string_count": len(strings),
        "component_types": [name for name, _ in component_types.most_common(30)],
        "node_names": [name for name, _ in node_names.most_common(50)],
        "asset_refs": [name for name, _ in sprite_refs.most_common(50)],
    }


def scan_native_files() -> list[dict]:
    records = []
    for path in ASSETS.rglob("*"):
        if not path.is_file():
            continue
        kind = detect_kind(path)
        ext = path.suffix.lower()
        displayable = kind in {"png", "jpg", "mp3", "font", "json", "text"}
        fixed_path = ensure_fixed_display_file(path, kind)
        records.append({
            "path": rel(path),
            "name": path.name,
            "ext": ext,
            "size": path.stat().st_size,
            "kind": kind,
            "displayable": displayable,
            "godot_path": f"res://{rel(fixed_path or path)}",
        })
    return records


def ensure_fixed_display_file(path: Path, kind: str) -> Path | None:
    wanted = { "png": ".png", "jpg": ".jpg", "mp3": ".mp3", "font": ".ttf" }.get(kind)
    if not wanted or path.suffix.lower() == wanted:
        return None
    out = ROOT / "converted" / kind / f"{path.stem}{wanted}"
    out.parent.mkdir(parents=True, exist_ok=True)
    if not out.exists() or out.stat().st_size != path.stat().st_size:
        shutil.copy2(path, out)
    return out


def write_godot_project() -> None:
    (ROOT / "project.godot").write_text(
        """; Engine configuration file.
; Generated by tools/build_godot_resource_demo.py

config_version=5

[application]

config/name="Nvshen Resource Demo"
run/main_scene="res://scenes/resource_browser.tscn"
config/features=PackedStringArray("4.2")

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
""",
        encoding="utf-8",
    )


def write_scene() -> None:
    SCENES_DIR.mkdir(parents=True, exist_ok=True)
    (SCENES_DIR / "resource_browser.tscn").write_text(
        """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resource_browser.gd" id="1_browser"]

[node name="ResourceBrowser" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_browser")
""",
        encoding="utf-8",
    )


def write_browser_script() -> None:
    SCRIPTS_DIR.mkdir(parents=True, exist_ok=True)
    (SCRIPTS_DIR / "resource_browser.gd").write_text(
        r'''extends Control

const CATALOG_PATH := "res://data/catalog.json"

var catalog: Dictionary = {}
var rows: Array = []
var current_kind := "image"

var list: ItemList
var preview: TextureRect
var text_preview: TextEdit
var title: Label
var detail: Label
var audio_player: AudioStreamPlayer
var type_buttons: HBoxContainer

func _ready() -> void:
	_build_ui()
	_load_catalog()
	_show_kind("image")

func _build_ui() -> void:
	var root := HBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(380, 0)
	root.add_child(left)

	title = Label.new()
	title.text = "Nvshen Resource Demo"
	title.add_theme_font_size_override("font_size", 22)
	left.add_child(title)

	type_buttons = HBoxContainer.new()
	type_buttons.add_theme_constant_override("separation", 4)
	left.add_child(type_buttons)
	for item in [["image", "Images"], ["prefab", "Prefabs"], ["scene", "Scenes"], ["audio", "Audio"], ["spine", "Spine"], ["text", "Text"]]:
		var b := Button.new()
		b.text = item[1]
		b.pressed.connect(_on_kind_button_pressed.bind(item[0]))
		type_buttons.add_child(b)

	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.item_selected.connect(_on_item_selected)
	left.add_child(list)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(right)

	detail = Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(detail)

	preview = TextureRect.new()
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(preview)

	text_preview = TextEdit.new()
	text_preview.editable = false
	text_preview.visible = false
	text_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(text_preview)

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func _load_catalog() -> void:
	var text := FileAccess.get_file_as_string(CATALOG_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		catalog = parsed

func _on_kind_button_pressed(kind: String) -> void:
	_show_kind(kind)

func _show_kind(kind: String) -> void:
	current_kind = kind
	list.clear()
	rows.clear()
	preview.texture = null
	text_preview.text = ""
	text_preview.visible = false
	preview.visible = true
	audio_player.stop()

	match kind:
		"image":
			for item in catalog.get("files", []):
				if item.get("kind", "") in ["png", "jpg"]:
					rows.append(item)
					list.add_item("%s  %s" % [item.get("kind", ""), item.get("path", "")])
		"audio":
			for item in catalog.get("files", []):
				if item.get("kind", "") == "mp3":
					rows.append(item)
					list.add_item(item.get("path", ""))
		"text":
			for item in catalog.get("files", []):
				if item.get("kind", "") in ["json", "text"]:
					rows.append(item)
					list.add_item(item.get("path", ""))
		"prefab":
			for item in catalog.get("prefabs", []):
				rows.append(item)
				list.add_item(item.get("path", ""))
		"scene":
			for item in catalog.get("scenes", []):
				rows.append(item)
				list.add_item(item.get("path", ""))
		"spine":
			for item in catalog.get("spine", []):
				rows.append(item)
				list.add_item(item.get("path", ""))
	title.text = "Nvshen Resource Demo - %s (%d)" % [kind, rows.size()]
	if rows.size() > 0:
		list.select(0)
		_on_item_selected(0)

func _on_item_selected(index: int) -> void:
	if index < 0 or index >= rows.size():
		return
	var item: Dictionary = rows[index]
	audio_player.stop()
	preview.texture = null
	text_preview.visible = false
	preview.visible = true
	detail.text = JSON.stringify(item, "\t")

	if current_kind == "image":
		var image_path: String = str(item.get("godot_path", ""))
		var image := Image.new()
		var err := image.load(image_path)
		if err == OK:
			preview.texture = ImageTexture.create_from_image(image)
	elif current_kind == "audio":
		var audio_path: String = str(item.get("godot_path", ""))
		var stream := AudioStreamMP3.load_from_file(audio_path)
		if stream != null:
			audio_player.stream = stream
			audio_player.play()
	elif current_kind == "text":
		preview.visible = false
		text_preview.visible = true
		var path: String = str(item.get("godot_path", ""))
		if path != "":
			text_preview.text = FileAccess.get_file_as_string(path).substr(0, 20000)
	elif current_kind in ["prefab", "scene", "spine"]:
		preview.visible = false
		text_preview.visible = true
		var summary: Variant = item.get("summary", {})
		var output: String = ""
		if typeof(summary) == TYPE_DICTIONARY and summary.size() > 0:
			output += "SUMMARY\n"
			output += JSON.stringify(summary, "\t")
			output += "\n\nRAW IMPORT\n"
		var import_path: String = str(item.get("import", ""))
		if import_path != "":
			output += FileAccess.get_file_as_string("res://" + import_path).substr(0, 50000)
			text_preview.text = output
		else:
			text_preview.text = output + detail.text
''',
        encoding="utf-8",
    )


def main() -> int:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    bundles = [load_bundle(name) for name in ["main", "resources", "internal"]]
    files = scan_native_files()

    prefabs = []
    scenes = []
    spine = []
    for bundle in bundles:
        if not bundle.get("exists"):
            continue
        for scene in bundle["scenes"]:
            scene["summary"] = summarize_cocos_import(scene.get("import", ""))
            scenes.append(scene)
        for item in bundle["assets"]:
            if item["type"] == "prefab":
                item["summary"] = summarize_cocos_import(item.get("import", ""))
                prefabs.append(item)
            elif item["type"] == "spine":
                spine.append(item)

    catalog = {
        "source": rel(ASSETS),
        "bundles": [{k: v for k, v in b.items() if k != "assets"} for b in bundles],
        "files": files,
        "prefabs": prefabs,
        "scenes": scenes,
        "spine": spine,
        "stats": {
            "files": len(files),
            "prefabs": len(prefabs),
            "scenes": len(scenes),
            "spine": len(spine),
            "file_kinds": dict(Counter(item["kind"] for item in files)),
        },
    }
    (DATA_DIR / "catalog.json").write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8")

    with (DATA_DIR / "prefabs.csv").open("w", newline="", encoding="utf-8-sig") as handle:
        fieldnames = ["bundle", "path", "type", "cocos_type", "uuid", "import", "native", "native_kind"]
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(prefabs)

    write_godot_project()
    write_scene()
    write_browser_script()
    print(json.dumps(catalog["stats"], ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
