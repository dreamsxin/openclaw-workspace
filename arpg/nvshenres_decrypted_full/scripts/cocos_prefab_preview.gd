extends Control

const MAIN_DEMO := "res://scenes/main_demo.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const TEXTURE_MAP_PATH := "res://data/login_texture_map.json"
const LAYOUT_MANIFEST_PATH := "res://data/prefab_layouts.json"

var canvas: Control
var detail: Label
var title: Label
var current_layout := "登录选服"
var texture_map: Dictionary = {}
var layouts: Dictionary = {}
var layout_stats: Dictionary = {}

func _ready() -> void:
	_load_texture_map()
	_load_layout_manifest()
	_build_ui()
	_load_layout(current_layout)
	_capture_if_requested()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 12
	root.offset_top = 10
	root.offset_right = -12
	root.offset_bottom = -10
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)

	title = Label.new()
	title.text = "原始 Cocos Prefab 预览"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)

	Navigation.add_buttons(top)

	var enter := Button.new()
	enter.text = "进入本地 Demo"
	enter.pressed.connect(func(): Navigation.go(MAIN_DEMO))
	top.add_child(enter)

	var resources := Button.new()
	resources.text = "资源浏览"
	resources.pressed.connect(func(): Navigation.go(RESOURCE_BROWSER))
	top.add_child(resources)

	var back := Button.new()
	back.text = "手工 Demo"
	back.pressed.connect(func(): Navigation.go(MAIN_DEMO))
	top.add_child(back)

	var layout_buttons := HFlowContainer.new()
	root.add_child(layout_buttons)

	for layout_name in layouts.keys():
		var btn := Button.new()
		btn.text = layout_name
		btn.pressed.connect(_load_layout.bind(layout_name))
		layout_buttons.add_child(btn)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)

	canvas = Control.new()
	canvas.custom_minimum_size = Vector2(880, 620)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.clip_contents = true
	body.add_child(canvas)

	detail = Label.new()
	detail.custom_minimum_size = Vector2(320, 0)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(detail)

func _load_layout(layout_name: String) -> void:
	current_layout = layout_name
	for child in canvas.get_children():
		child.queue_free()
	var layout_path: String = layouts.get(layout_name, "")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var nodes: Array = parsed.get("nodes", [])
	var stats: Dictionary = layout_stats.get(layout_name, {})
	title.text = "原始 Cocos Prefab 预览 - %s" % layout_name
	detail.text = "%s\nnodes: %d\ntexture nodes: %d\n\n这是从原始 Cocos Prefab 提取的节点布局预览。当前已尽量关联 SpriteFrame/native 图片；无法自动确认贴图的节点继续显示半透明矩形。" % [parsed.get("prefab", ""), nodes.size(), int(stats.get("texture_nodes", 0))]
	for node in _sorted_nodes(nodes):
		_add_node_rect(node)

func _add_node_rect(node: Dictionary) -> void:
	var size_arr: Array = node.get("size", [80, 36])
	var pos_arr: Array = node.get("position", [0, 0])
	var size := Vector2(float(size_arr[0]), float(size_arr[1]))
	var pos := Vector2(float(pos_arr[0]), -float(pos_arr[1]))
	var name := str(node.get("name", ""))
	var rect: Control
	var manual_texture_path := _texture_for_node(name) if _is_login_layout() else ""
	var texture_path := manual_texture_path
	if texture_path == "":
		texture_path = str(node.get("texture_path", ""))
	if texture_path != "":
		var tex := _load_node_texture("res://" + texture_path, node, manual_texture_path == "")
		var img := TextureRect.new()
		img.texture = tex
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect = img
	else:
		var panel := PanelContainer.new()
		panel.modulate = _color_for_name(name)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect = panel
	rect.position = Vector2(440, 310) + pos - size * 0.5
	rect.size = Vector2(max(size.x, 48.0), max(size.y, 28.0))
	rect.tooltip_text = JSON.stringify(node, "\t")
	canvas.add_child(rect)

	if _is_action_node(name):
		var hit := Button.new()
		hit.text = ""
		hit.flat = true
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hit.tooltip_text = "进入主城"
		hit.pressed.connect(_load_layout.bind("主城"))
		rect.add_child(hit)

	if texture_path == "" or not _is_login_layout():
		var label := Label.new()
		label.text = name
		label.clip_text = true
		label.position = Vector2(4, 3)
		rect.add_child(label)

func _texture_for_node(name: String) -> String:
	if texture_map.has(name):
		return str(texture_map[name])
	for key in texture_map.keys():
		var key_string := str(key)
		if name.to_lower().contains(key_string.to_lower()):
			return str(texture_map[key])
	return ""

func _load_texture_map() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEXTURE_MAP_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		texture_map = parsed

func _load_layout_manifest() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_MANIFEST_PATH))
	if typeof(parsed) != TYPE_ARRAY:
		return
	for item in parsed:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var label := str(item.get("label", ""))
		var layout_path := str(item.get("layout", ""))
		if label == "" or layout_path == "":
			continue
		layouts[label] = "res://" + layout_path
		layout_stats[label] = item

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_node_texture(path: String, node: Dictionary, crop_sprite: bool = true) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var sprite_rect: Array = node.get("sprite_rect", [])
	if crop_sprite and sprite_rect.size() == 4:
		var crop := Rect2i(
			int(sprite_rect[0]),
			int(sprite_rect[1]),
			int(sprite_rect[2]),
			int(sprite_rect[3])
		)
		if crop.size.x > 0 and crop.size.y > 0 and Rect2i(Vector2i.ZERO, image.get_size()).encloses(crop):
			image = image.get_region(crop)
	return ImageTexture.create_from_image(image)

func _is_login_layout() -> bool:
	return current_layout == "登录面板" or current_layout == "登录选服"

func _is_action_node(name: String) -> bool:
	return name in ["loginBtn", "btn_start", "btnStart"]

func _sorted_nodes(nodes: Array) -> Array:
	var sorted := nodes.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa := _draw_priority(str(a.get("name", "")), a)
		var pb := _draw_priority(str(b.get("name", "")), b)
		if pa == pb:
			return int(a.get("index", 0)) < int(b.get("index", 0))
		return pa < pb
	)
	return sorted

func _draw_priority(name: String, node: Dictionary) -> int:
	var lowered := name.to_lower()
	var size_arr: Array = node.get("size", [0, 0])
	var area := float(size_arr[0]) * float(size_arr[1]) if size_arr.size() >= 2 else 0.0
	if lowered in ["bg", "node_de"] or area > 800000.0:
		return 0
	if lowered.contains("alert") or lowered.contains("panel") or lowered.contains("frame"):
		return 10
	if lowered == "wenzidi" or lowered.contains("di") or lowered.contains("background"):
		return 20
	if lowered.contains("logo"):
		return 40
	if lowered.contains("btn") or lowered == "button":
		return 70
	if lowered.contains("label") or lowered.begins_with("txt") or lowered.begins_with("lbl"):
		return 90
	return 50

func _color_for_name(name: String) -> Color:
	if name.contains("btn") or name.contains("Btn"):
		return Color(0.35, 0.58, 1.0, 0.72)
	if name.contains("icon"):
		return Color(0.35, 1.0, 0.62, 0.70)
	if name.contains("bg") or name.contains("BG"):
		return Color(0.8, 0.62, 0.28, 0.48)
	if name.contains("panel") or name.contains("Panel"):
		return Color(0.8, 0.45, 0.95, 0.55)
	return Color(0.75, 0.78, 0.88, 0.42)

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	if not "--capture-prefab-preview" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-prefab-preview")
	var output_path := "user://prefab_preview.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
