extends Control

const AudioUtils := preload("res://scripts/audio_utils.gd")

const CATALOG_PATH := "res://data/catalog.json"
const SPINE_INDEX_PATH := "res://data/spine_preview_index.json"
const SPINE_VIEWER := "res://scenes/spine_character_viewer.tscn"

var catalog: Dictionary = {}
var spine_index: Dictionary = {}
var rows: Array = []
var current_kind := "image"

var list: ItemList
var preview: TextureRect
var text_preview: TextEdit
var title: Label
var detail: Label
var audio_player: AudioStreamPlayer
var type_buttons: HBoxContainer
var spine_actions: HBoxContainer
var current_spine_info: Dictionary = {}

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

	spine_actions = HBoxContainer.new()
	spine_actions.visible = false
	spine_actions.add_theme_constant_override("separation", 8)
	right.add_child(spine_actions)

	var open_spine := Button.new()
	open_spine.text = "Open Spine Viewer"
	open_spine.pressed.connect(_open_current_spine)
	spine_actions.add_child(open_spine)

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
	var spine_text := FileAccess.get_file_as_string(SPINE_INDEX_PATH)
	var spine_parsed = JSON.parse_string(spine_text)
	if typeof(spine_parsed) == TYPE_DICTIONARY:
		spine_index = spine_parsed

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
	spine_actions.visible = false
	current_spine_info = {}
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
		AudioUtils.play_mp3(audio_player, audio_path)
	elif current_kind == "text":
		preview.visible = false
		text_preview.visible = true
		var path: String = str(item.get("godot_path", ""))
		if path != "":
			text_preview.text = FileAccess.get_file_as_string(path).substr(0, 20000)
	elif current_kind == "spine":
		_show_spine_item(item)
	elif current_kind in ["prefab", "scene"]:
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

func _show_spine_item(item: Dictionary) -> void:
	preview.visible = true
	text_preview.visible = true
	var key := str(item.get("uuid", ""))
	var info: Dictionary = spine_index.get(key, {})
	if info.is_empty():
		text_preview.text = detail.text
		return
	current_spine_info = info
	spine_actions.visible = _runtime_path_for_spine(info) != ""

	detail.text = "%s\nspine=%s  bones=%d  slots=%d  skins=%d  animations=%d" % [
		info.get("path", item.get("path", "")),
		info.get("spine_version", ""),
		int(info.get("bone_count", 0)),
		int(info.get("slot_count", 0)),
		int(info.get("skin_count", 0)),
		(info.get("animations", []) as Array).size(),
	]

	var textures: Array = info.get("textures", [])
	if not textures.is_empty():
		var image := Image.new()
		if image.load("res://" + str(textures[0])) == OK:
			preview.texture = ImageTexture.create_from_image(image)

	var output := "SPINE PREVIEW INDEX\n"
	output += "path: %s\n" % info.get("path", "")
	output += "import: %s\n" % info.get("import", "")
	output += "textures:\n"
	for texture_path in textures:
		output += "  - %s\n" % texture_path
	output += "\nanimations:\n"
	for animation_name in info.get("animations", []):
		output += "  - %s\n" % animation_name
	output += "\ntextureNames:\n"
	for texture_name in info.get("texture_names", []):
		output += "  - %s\n" % texture_name
	output += "\nNOTE\n"
	var runtime_path := _runtime_path_for_spine(info)
	if runtime_path != "":
		output += "已导出 runtime：%s，可点击 Open Spine Viewer 播放。\n" % runtime_path
	else:
		output += "尚未导出 runtime。可用 tools/export_spine_runtime_data.py 导出后播放。\n"
	text_preview.text = output

func _open_current_spine() -> void:
	var runtime_path := _runtime_path_for_spine(current_spine_info)
	if runtime_path == "":
		return
	var animations: Array = current_spine_info.get("animations", [])
	var animation := "idle"
	if not animations.has(animation) and not animations.is_empty():
		animation = str(animations[0])
	Navigation.go_with_args(SPINE_VIEWER, {
		"spine_path": runtime_path,
		"animation": animation,
		"label": str(current_spine_info.get("name", runtime_path.get_file().get_basename())),
	})

func _runtime_path_for_spine(info: Dictionary) -> String:
	var name := str(info.get("name", ""))
	var candidates := [
		"res://data/spine_runtime/%s.json" % name,
		"res://data/spine_runtime/%s.json" % str(info.get("path", "")).get_file().get_basename(),
	]
	for candidate in candidates:
		if FileAccess.file_exists(candidate):
			return candidate
	return ""
