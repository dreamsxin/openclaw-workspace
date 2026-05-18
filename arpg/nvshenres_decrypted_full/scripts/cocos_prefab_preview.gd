extends Control

const MAIN_DEMO := "res://scenes/main_demo.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const TEXTURE_MAP_PATH := "res://data/login_texture_map.json"
const LAYOUT_MANIFEST_PATH := "res://data/prefab_layouts.json"
const BAG_ITEM_LAYOUT_PATH := "res://data/prefab_layouts/GridBoxItemPre.json"
const EQUIPMENT_ICON_INDEX_PATH := "res://data/equipment_icon_index.json"
const HERO_105004_SPINE := "res://data/spine_runtime/105004.json"
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

var canvas: Control
var detail: Label
var title: Label
var current_layout := "登录选服"
var texture_map: Dictionary = {}
var layouts: Dictionary = {}
var layout_stats: Dictionary = {}
var equipment_icons: Array = []

func _ready() -> void:
	_load_texture_map()
	_load_layout_manifest()
	_load_equipment_icons()
	_build_ui()
	var requested_layout := _requested_layout()
	if requested_layout != "":
		current_layout = requested_layout
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
	if not layouts.has(layout_name):
		return
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
	_add_layout_mock()

func _add_node_rect(node: Dictionary) -> void:
	if _should_skip_node(node):
		return
	var size_arr: Array = node.get("size", [80, 36])
	var pos_arr: Array = node.get("global_position", node.get("position", [0, 0]))
	var anchor_arr: Array = node.get("anchor", [0.5, 0.5])
	var size := Vector2(float(size_arr[0]), float(size_arr[1]))
	var pos := Vector2(float(pos_arr[0]), -float(pos_arr[1]))
	var anchor := Vector2(float(anchor_arr[0]), 1.0 - float(anchor_arr[1]))
	var name := str(node.get("name", ""))
	var rect: Control
	var manual_texture_path := _texture_for_node(name) if _is_login_layout() else ""
	var texture_path := manual_texture_path
	if texture_path == "":
		texture_path = str(node.get("texture_path", ""))
	if texture_path != "":
		var tex := _load_node_texture("res://" + texture_path, node, manual_texture_path == "")
		if _is_sliced_sprite(node):
			var nine := NinePatchRect.new()
			nine.texture = tex
			_apply_nine_patch_margins(nine, node)
			nine.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = nine
		else:
			var img := TextureRect.new()
			img.texture = tex
			img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = img
	else:
		if _node_label_text(node) != "":
			var text_rect := Control.new()
			text_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = text_rect
		else:
			var panel := PanelContainer.new()
			panel.modulate = _color_for_name(name)
			panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = panel
	rect.position = _canvas_center() + pos - Vector2(size.x * anchor.x, size.y * anchor.y)
	rect.size = Vector2(max(size.x, 48.0), max(size.y, 28.0))
	rect.scale = _node_scale(node)
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

	var label_text := _node_label_text(node)
	if label_text != "":
		_add_text_label(rect, node, label_text)
	elif texture_path == "" or not _is_login_layout():
		var label := Label.new()
		label.text = name
		label.clip_text = true
		label.position = Vector2(4, 3)
		rect.add_child(label)

func _add_layout_mock() -> void:
	if current_layout == "英雄":
		_add_hero_panel_mock()
	elif current_layout == "背包":
		_add_bag_panel_mock()

func _add_hero_panel_mock() -> void:
	var player: Node2D = SimpleSpinePlayerScript.new()
	player.z_index = 30
	canvas.add_child(player)
	if not player.load_spine(HERO_105004_SPINE, "idle"):
		return
	player.update_preview_pose(0.0)
	var bounds: Rect2 = player.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var target: Rect2 = Rect2(_canvas_center() + Vector2(-430, -205), Vector2(270, 470))
	var scale_value: float = min(target.size.x / bounds.size.x, target.size.y / bounds.size.y)
	player.scale = Vector2(scale_value, scale_value)
	var bounds_center: Vector2 = bounds.position + bounds.size * 0.5
	var target_center: Vector2 = target.position + target.size * 0.5
	player.position = target_center - bounds_center * scale_value

func _add_bag_panel_mock() -> void:
	var names := ["神铸核心", "星辉宝箱", "召唤券", "经验药剂", "升星石", "秘银"]
	var start := _canvas_center() + Vector2(-395, -136)
	for i in 8:
		var icon_data := _equipment_icon(i)
		_add_bag_item_row(start + Vector2(0, i * 64), icon_data, names[i % names.size()], (i + 1) * 5, i == 0)

func _add_bag_item_row(origin: Vector2, icon_data: Dictionary, item_name: String, item_count: int, checked: bool) -> void:
	var row := Control.new()
	row.position = origin
	row.size = Vector2(251, 58)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(row)

	var bg := PanelContainer.new()
	bg.size = row.size
	bg.modulate = Color(0.11, 0.09, 0.13, 0.72)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bg)

	var item_box := _node_from_layout("ItemBox")
	var icon_box := PanelContainer.new()
	icon_box.position = Vector2(12, 5)
	icon_box.size = Vector2(54, 54)
	icon_box.modulate = Color(0.25, 0.22, 0.32, 0.95)
	icon_box.tooltip_text = JSON.stringify(item_box, "\t") if item_box else "GridBoxItemPre.ItemBox"
	row.add_child(icon_box)

	var icon := TextureRect.new()
	icon.position = Vector2(5, 5)
	icon.size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _load_indexed_texture(icon_data)
	icon_box.add_child(icon)

	var name_label := Label.new()
	name_label.text = item_name
	name_label.position = Vector2(76, 8)
	name_label.size = Vector2(130, 22)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.62, 1.0))
	row.add_child(name_label)

	var count_label := Label.new()
	count_label.text = "x%d" % item_count
	count_label.position = Vector2(76, 33)
	count_label.size = Vector2(80, 20)
	count_label.add_theme_font_size_override("font_size", 16)
	count_label.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0, 1.0))
	row.add_child(count_label)

	var check := _node_from_layout("chek2" if checked else "chek1")
	var check_rect := TextureRect.new()
	check_rect.position = Vector2(212, 18)
	check_rect.size = Vector2(24, 24)
	check_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	check_rect.stretch_mode = TextureRect.STRETCH_SCALE
	if check and str(check.get("texture_path", "")) != "":
		check_rect.texture = _load_node_texture("res://" + str(check.get("texture_path", "")), check)
	else:
		check_rect.modulate = Color(0.4, 0.52, 0.72, 0.85)
	row.add_child(check_rect)

func _node_from_layout(node_name: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(BAG_ITEM_LAYOUT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	for node in parsed.get("nodes", []):
		if typeof(node) == TYPE_DICTIONARY and str(node.get("name", "")) == node_name:
			return node
	return {}

func _equipment_icon(index: int) -> Dictionary:
	if equipment_icons.is_empty():
		return {}
	var sprite_entries := equipment_icons.filter(func(item: Dictionary) -> bool:
		return int(item.get("type_index", 0)) == 9 and str(item.get("texture_path", "")) != ""
	)
	if sprite_entries.is_empty():
		return equipment_icons[index % equipment_icons.size()]
	return sprite_entries[index % sprite_entries.size()]

func _load_indexed_texture(icon_data: Dictionary) -> Texture2D:
	var path := str(icon_data.get("texture_path", ""))
	if path == "":
		return null
	return _load_node_texture("res://" + path, icon_data, true)

func _node_label_text(node: Dictionary) -> String:
	return str(node.get("label_text", ""))

func _is_sliced_sprite(node: Dictionary) -> bool:
	if int(node.get("sprite_type", 0)) != 1:
		return false
	var insets: Array = node.get("sprite_cap_insets", [])
	if insets.size() < 4:
		return false
	return float(insets[0]) > 0.0 or float(insets[1]) > 0.0 or float(insets[2]) > 0.0 or float(insets[3]) > 0.0

func _apply_nine_patch_margins(nine: NinePatchRect, node: Dictionary) -> void:
	var insets: Array = node.get("sprite_cap_insets", [])
	if insets.size() < 4:
		return
	nine.patch_margin_left = int(round(float(insets[0])))
	nine.patch_margin_top = int(round(float(insets[1])))
	nine.patch_margin_right = int(round(float(insets[2])))
	nine.patch_margin_bottom = int(round(float(insets[3])))

func _add_text_label(parent: Control, node: Dictionary, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.clip_text = true
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", int(node.get("label_font_size", 18)))
	label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	label.horizontal_alignment = _to_horizontal_alignment(int(node.get("label_horizontal_align", 0)))
	label.vertical_alignment = _to_vertical_alignment(int(node.get("label_vertical_align", 0)))
	parent.add_child(label)

func _to_horizontal_alignment(value: int) -> HorizontalAlignment:
	if value == 1:
		return HORIZONTAL_ALIGNMENT_CENTER
	if value == 2:
		return HORIZONTAL_ALIGNMENT_RIGHT
	return HORIZONTAL_ALIGNMENT_LEFT

func _to_vertical_alignment(value: int) -> VerticalAlignment:
	if value == 1:
		return VERTICAL_ALIGNMENT_CENTER
	if value == 2:
		return VERTICAL_ALIGNMENT_BOTTOM
	return VERTICAL_ALIGNMENT_TOP

func _should_skip_node(node: Dictionary) -> bool:
	if not bool(node.get("active", true)):
		return true
	var name := str(node.get("name", ""))
	var texture_path := str(node.get("texture_path", ""))
	var parent_index: Variant = node.get("parent_index")
	if parent_index == null and texture_path == "" and name.to_lower().ends_with("pre"):
		return true
	return false

func _canvas_center() -> Vector2:
	if canvas.size.x > 0.0 and canvas.size.y > 0.0:
		return canvas.size * 0.5
	return Vector2(440, 310)

func _node_scale(node: Dictionary) -> Vector2:
	var scale_arr: Array = node.get("scale", [1.0, 1.0])
	if scale_arr.size() < 2:
		return Vector2.ONE
	var scale := Vector2(float(scale_arr[0]), float(scale_arr[1]))
	if is_zero_approx(scale.x):
		scale.x = 1.0
	if is_zero_approx(scale.y):
		scale.y = 1.0
	return scale

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

func _load_equipment_icons() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(EQUIPMENT_ICON_INDEX_PATH))
	if typeof(parsed) == TYPE_ARRAY:
		equipment_icons = parsed

func _requested_layout() -> String:
	var scene_args := Navigation.consume_scene_args()
	var layout := str(scene_args.get("layout", ""))
	if layout != "":
		return layout
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var index := args.find("--prefab-layout")
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

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
		var original_size := _arr_to_vec2i(node.get("sprite_original_size", []))
		var offset := _arr_to_vec2(node.get("sprite_offset", []))
		return _make_sprite_frame_texture(image, crop, bool(node.get("sprite_rotated", false)), original_size, offset)
	return ImageTexture.create_from_image(image)

func _make_sprite_frame_texture(atlas: Image, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(crop):
		return ImageTexture.create_from_image(atlas)
	var frame := atlas.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x <= 0 or original_size.y <= 0 or original_size == frame.get_size():
		return ImageTexture.create_from_image(frame)
	frame.convert(Image.FORMAT_RGBA8)
	var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
	var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
	canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
	return ImageTexture.create_from_image(canvas)

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

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

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
	args.append_array(OS.get_cmdline_user_args())
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
