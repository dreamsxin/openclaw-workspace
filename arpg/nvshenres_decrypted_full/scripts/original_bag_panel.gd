extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const BG_PATH := "res://assets/resources/native/ac/ac082229-4446-4cfe-bbaf-5e9849e208c3.png"
const TAB_POSITIONS := [
	Vector2(1082, 74),
	Vector2(1082, 159),
	Vector2(1082, 245),
	Vector2(1082, 331),
	Vector2(1082, 415.567),
]

const TABS := ["装备", "道具", "碎片", "符文", "神器"]
const ITEM_NAMES := [
	"神铸核心", "星辉宝箱", "召唤券", "经验药剂", "升星石", "秘银", "英雄碎片", "圣纹宝箱",
	"突破石", "高级召唤券", "金币宝袋", "装备精华", "灵魂晶石", "符文原石", "神器残片", "星辉徽章",
]

var design_root: Control
var item_grid: GridContainer
var detail_root: Control
var list_panel: Control
var tab_buttons: Array[Button] = []
var header_actions: Dictionary = {}
var bottom_actions: Dictionary = {}
var equipment_icons: Array = []
var selected_tab := 1
var selected_item := 0

func _ready() -> void:
	_load_equipment_icons()
	_build_ui()
	_apply_cmdline_args()
	_capture_if_requested()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.035, 0.04, 0.06, 1.0)
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.78, 0.84, 0.96, 0.62)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.48)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	_build_top_bar()
	_build_main_panel()
	_build_tabs()
	_build_detail_panel()
	_build_actions()
	_layout_design_root()
	_refresh_items()
	_refresh_detail()

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 1.0
	top.anchor_right = 1.0
	top.offset_left = -680
	top.offset_top = 676
	top.offset_right = -12
	top.offset_bottom = 710
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	add_child(top)

	var title := Label.new()
	title.text = "BagPre | 仓库"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	Navigation.add_buttons(top)
	_add_top_button(top, "主城", func(): Navigation.go(HOME_SCENE))
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "背包"}))

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _build_main_panel() -> void:
	list_panel = Control.new()
	list_panel.position = Vector2(134.226, 71.222)
	list_panel.size = Vector2(996, 560)
	design_root.add_child(list_panel)

	var panel_bg := ColorRect.new()
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_bg.color = Color(0.04, 0.045, 0.07, 0.76)
	panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list_panel.add_child(panel_bg)

	var header := HBoxContainer.new()
	header.position = Vector2(154, -44)
	header.size = Vector2(460, 48)
	header.add_theme_constant_override("separation", 12)
	list_panel.add_child(header)
	header_actions["sell_equip"] = _add_action_button(header, "出售装备", func(): _open_prefab_layout("背包出售装备"))
	header_actions["shenqi"] = _add_action_button(header, "神器图鉴", func(): _open_prefab_layout("神器图鉴"))
	header_actions["synthesis"] = _add_action_button(header, "一键合成", func(): _open_prefab_layout("背包合成提示"))
	header_actions["grid_box"] = _add_action_button(header, "自选礼包", func(): _open_prefab_layout("背包格子面板"))
	var count := Label.new()
	count.text = "容量  1/200"
	count.custom_minimum_size = Vector2(150, 42)
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count.add_theme_font_size_override("font_size", 18)
	count.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0))
	header.add_child(count)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	list_panel.add_child(scroll)

	item_grid = GridContainer.new()
	item_grid.columns = 8
	item_grid.add_theme_constant_override("h_separation", 10)
	item_grid.add_theme_constant_override("v_separation", 10)
	item_grid.custom_minimum_size = Vector2(950, 560)
	scroll.add_child(item_grid)

func _build_tabs() -> void:
	for i in TABS.size():
		var button := Button.new()
		button.text = TABS[i]
		button.position = TAB_POSITIONS[i]
		button.size = Vector2(198, 62)
		button.add_theme_font_size_override("font_size", 22)
		button.pressed.connect(_select_tab.bind(i))
		design_root.add_child(button)
		tab_buttons.append(button)

func _build_detail_panel() -> void:
	detail_root = Control.new()
	detail_root.position = Vector2(884, 512)
	detail_root.size = Vector2(320, 126)
	design_root.add_child(detail_root)

func _build_actions() -> void:
	var actions := HBoxContainer.new()
	actions.position = Vector2(874, 652)
	actions.size = Vector2(330, 46)
	actions.add_theme_constant_override("separation", 12)
	design_root.add_child(actions)
	bottom_actions["use"] = _add_action_button(actions, "使用", func(): _open_prefab_layout("背包批量使用"))
	bottom_actions["sell"] = _add_action_button(actions, "出售", func(): _open_prefab_layout("背包出售物品"))
	bottom_actions["get"] = _add_action_button(actions, "获取", func(): _open_prefab_layout("背包获取途径"))

func _add_action_button(parent: Container, text: String, callback := Callable()) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(104, 40)
	if callback.is_valid():
		button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _refresh_items() -> void:
	for child in item_grid.get_children():
		child.queue_free()
	for i in 20:
		var button := Button.new()
		button.custom_minimum_size = Vector2(110, 110)
		button.text = ""
		button.pressed.connect(_select_item.bind(i))
		item_grid.add_child(button)
		_draw_item(button, i)
	_update_tabs()

func _draw_item(parent: Control, index: int) -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.075, 0.11, 0.82)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)

	var icon_box := ColorRect.new()
	icon_box.position = Vector2.ZERO
	icon_box.size = Vector2(110, 110)
	icon_box.color = Color(0.12, 0.1, 0.16, 0.95)
	icon_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon_box)

	var icon := TextureRect.new()
	icon.position = Vector2(14, 12)
	icon.size = Vector2(82, 82)
	icon.texture = _load_indexed_texture(_equipment_icon(index + selected_tab * 5))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)

	var name := Label.new()
	name.text = ITEM_NAMES[(index + selected_tab * 3) % ITEM_NAMES.size()]
	name.position = Vector2(3, 84)
	name.size = Vector2(104, 22)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.clip_text = true
	name.add_theme_font_size_override("font_size", 16)
	name.add_theme_color_override("font_color", Color(0.98, 0.86, 0.52))
	parent.add_child(name)

	var count := Label.new()
	count.text = "x%d" % ((index + 1) * (selected_tab + 2))
	count.position = Vector2(58, 62)
	count.size = Vector2(48, 22)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.add_theme_font_size_override("font_size", 15)
	count.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0))
	parent.add_child(count)

	if index == selected_item:
		var selected := ColorRect.new()
		selected.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		selected.color = Color(1.0, 0.78, 0.18, 0.18)
		selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(selected)

func _select_tab(index: int) -> void:
	selected_tab = index
	selected_item = 0
	_refresh_items()
	_refresh_detail()

func _select_item(index: int) -> void:
	selected_item = index
	_refresh_items()
	_refresh_detail()
	_open_prefab_layout(_detail_layout_for_tab())

func _refresh_detail() -> void:
	for child in detail_root.get_children():
		child.queue_free()
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.045, 0.07, 0.82)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_root.add_child(bg)

	var icon := TextureRect.new()
	icon.position = Vector2(16, 18)
	icon.size = Vector2(82, 82)
	icon.texture = _load_indexed_texture(_equipment_icon(selected_item + selected_tab * 5))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_root.add_child(icon)

	var item_name: String = str(ITEM_NAMES[(selected_item + selected_tab * 3) % ITEM_NAMES.size()])
	_add_label(detail_root, item_name, Vector2(112, 16), Vector2(180, 28), 22, Color(1.0, 0.86, 0.48))
	_add_label(detail_root, "拥有数量：%d" % ((selected_item + 1) * (selected_tab + 2)), Vector2(112, 48), Vector2(180, 24), 16, Color(0.82, 0.92, 1.0))
	_add_label(detail_root, "获取途径：副本 / 活动 / 召唤奖励", Vector2(112, 74), Vector2(190, 44), 15, Color(0.72, 0.82, 0.96))

func _update_tabs() -> void:
	for i in tab_buttons.size():
		tab_buttons[i].disabled = i == selected_tab
	if header_actions.has("sell_equip"):
		header_actions["sell_equip"].visible = selected_tab == 0
	if header_actions.has("shenqi"):
		header_actions["shenqi"].visible = selected_tab == 4
	if header_actions.has("synthesis"):
		header_actions["synthesis"].visible = selected_tab == 2
	if header_actions.has("grid_box"):
		header_actions["grid_box"].visible = selected_tab == 1
	if bottom_actions.has("use"):
		bottom_actions["use"].visible = selected_tab in [1, 2]
	if bottom_actions.has("sell"):
		bottom_actions["sell"].visible = selected_tab in [0, 1, 3]
	if bottom_actions.has("get"):
		bottom_actions["get"].visible = selected_tab in [1, 2, 3, 4]

func _detail_layout_for_tab() -> String:
	if selected_tab == 0:
		return "背包出售物品"
	if selected_tab == 2:
		return "背包合成提示"
	if selected_tab == 3:
		return "背包符文提示"
	if selected_tab == 4:
		return "神器图鉴"
	return "背包获取途径"

func _open_prefab_layout(layout: String) -> void:
	Navigation.go_with_args(PREFAB_PREVIEW, {"layout": layout})

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)

func _load_equipment_icons() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/equipment_icon_index.json"))
	if typeof(parsed) == TYPE_ARRAY:
		equipment_icons = parsed

func _equipment_icon(index: int) -> Dictionary:
	var sprite_entries := equipment_icons.filter(func(item: Dictionary) -> bool:
		return int(item.get("type_index", 0)) == 9 and str(item.get("texture_path", "")) != ""
	)
	if sprite_entries.is_empty():
		return {}
	return sprite_entries[index % sprite_entries.size()]

func _load_indexed_texture(icon_data: Dictionary) -> Texture2D:
	var path := str(icon_data.get("texture_path", ""))
	if path == "":
		return null
	var rect_arr: Array = icon_data.get("sprite_rect", [])
	var original_size := _arr_to_vec2i(icon_data.get("sprite_original_size", []))
	var offset := _arr_to_vec2(icon_data.get("sprite_offset", []))
	if rect_arr.size() == 4:
		return _load_texture_region("res://" + path, Rect2i(int(rect_arr[0]), int(rect_arr[1]), int(rect_arr[2]), int(rect_arr[3])), bool(icon_data.get("sprite_rotated", false)), original_size, offset)
	return _load_texture("res://" + path)

func _apply_cmdline_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var tab_arg := _cmd_arg_value(args, "--bag-tab")
	if tab_arg.is_valid_int():
		selected_tab = clampi(int(tab_arg), 0, TABS.size() - 1)
	var item_arg := _cmd_arg_value(args, "--bag-item")
	if item_arg.is_valid_int():
		selected_item = clampi(int(item_arg), 0, 19)
	_refresh_items()
	_refresh_detail()

func _cmd_arg_value(args: Array, key: String) -> String:
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

func _layout_design_root() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(factor, factor)
	design_root.position = (viewport_size - DESIGN_SIZE * factor) * 0.5

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return _make_sprite_frame_texture(image, region, rotated, original_size, offset)

func _make_sprite_frame_texture(atlas: Image, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(crop):
		return ImageTexture.create_from_image(atlas)
	var frame := atlas.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x <= 0 or original_size.y <= 0:
		return ImageTexture.create_from_image(frame)
	if original_size == frame.get_size():
		return ImageTexture.create_from_image(frame)
	frame.convert(Image.FORMAT_RGBA8)
	var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
	var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
	canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
	return ImageTexture.create_from_image(canvas)

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-bag-panel" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-bag-panel")
	var output_path := "user://bag_panel.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
