extends Control

const LAYOUT_PATH := "res://data/prefab_layouts/MainPre.json"
const NAV_LAYOUT_PATH := "res://data/prefab_layouts/daohangPre.json"
const FLOATING_CITY_SCENE := "res://scenes/original_main_city.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const SPINE_VIEWER := "res://scenes/spine_character_viewer.tscn"
const HERO_LIST_SCENE := "res://scenes/original_hero_list_panel.tscn"
const BAG_PANEL_SCENE := "res://scenes/original_bag_panel.tscn"
const DRAW_CARD_SCENE := "res://scenes/original_draw_card_panel.tscn"
const SHOP_PANEL_SCENE := "res://scenes/original_shop_panel.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")
const ATLAS_1A := "res://assets/resources/native/1a/1a7921f32.png"
const ATLAS_1D := "res://assets/resources/native/1d/1d816a710.png"
const ATLAS_1F := "res://assets/resources/native/1f/1f6b547b4.png"
const ATLAS_14 := "res://assets/resources/native/14/140096250.png"
const ATLAS_19 := "res://assets/resources/native/19/19ac1e70d.png"
const ATLAS_15 := "res://assets/resources/native/15/15a1d9111.png"
const ATLAS_18A := "res://assets/resources/native/18/18b29ae48.png"
const ATLAS_18B := "res://assets/resources/native/18/18935b9e9.png"
const PLAYER_HEAD := "res://assets/resources/native/d7/d7bf0f4d-1dc9-4fda-80c0-65dfeee3316a.png"
const AD_BANNER := "res://assets/resources/native/00/002545b0-69b1-4515-ac70-e545a4c8b5d2.png"
const NAV_BG_PATH := "res://assets/resources/native/1f/1f6b547b4.png"
const NAV_BG_RECT := Rect2i(675, 127, 340, 97)
const RED_DOT_RECT := Rect2i(375, 295, 31, 31)
const MONEY_GOLD := "res://assets/resources/native/9e/9ec8c387-6381-46b4-93eb-7ebe016dbffc.png"
const MONEY_DIAMOND := "res://assets/resources/native/47/47e154d7-f9c2-4a5a-85c0-b299960f439b.png"
const MONEY_FRAME_ATLAS := "res://assets/resources/native/15/15a1d9111.png"
const MONEY_ICON_ATLAS_18 := "res://assets/resources/native/18/18b29ae48.png"
const SHOP_ICON_RECT := Rect2i(163, 3, 91, 53)
const NAV_SLOT3_RECT := Rect2i(477, 242, 125, 123)
const NAV_BG_TEXTURE := "res://assets/resources/native/f5/f58085bc-21e6-40ed-a4cf-b55f6b0cc8f9.png"
const NAV_BG_SIZE := Vector2(2266, 181)
const MONEY_FRAME_1_RECT := Rect2i(330, 400, 178, 36)
const MONEY_FRAME_2_RECT := Rect2i(106, 400, 179, 36)
const MONEY_FRAME_3_RECT := Rect2i(847, 288, 172, 36)
const MONEY_GOLD_RECT := Rect2i(516, 434, 53, 50)
const MONEY_DIAMOND_RECT := Rect2i(358, 781, 54, 41)
const MONEY_PURPLE_RECT := Rect2i(236, 742, 32, 36)
const MONEY_ADD_RECT := Rect2i(996, 828, 24, 24)
const MAIN_EVENT_GRID_MIN_X := 88.0
const NAV_SELECTED_LIGHT_ALPHA := 0.34
const HERO_105004_SPINE := "res://data/spine_runtime/105004.json"
const HERO_SULA_SPINE := "res://data/spine_runtime/SuLa_LH.json"
const HERO_YOUDUOLA_SPINE := "res://data/spine_runtime/YouDuoLa_LH.json"

const BACKGROUNDS := [
	{
		"name": "Native Star Gate",
		"path": "res://assets/resources/native/ac/ac082229-4446-4cfe-bbaf-5e9849e208c3.png",
	},
	{
		"name": "Native Sky",
		"path": "res://assets/resources/native/db/db6cdf6e-46e4-4e76-98e0-14281d468874.png",
	},
	{
		"name": "Native Academy",
		"path": "res://assets/resources/native/4f/4fe2dfa8-dcc7-455d-b274-485c00c73e0b.png",
	},
	{
		"name": "bigImage/1010 layer",
		"path": "res://assets/resources/native/e2/e2fb04e4-4282-407c-8a69-262bbe15238b.png",
	},
	{
		"name": "bigImage/1020 layer",
		"path": "res://assets/resources/native/d8/d8b50b8b-da67-4d37-bd49-e783c34755dc.png",
	},
]

const HEROES := [
	{
		"name": "Illustration",
		"path": "res://assets/resources/native/d2/d25fe7e6-9571-42ef-b9f6-066ae454dab6.png",
		"position": Vector2(438, 88),
		"size": Vector2(430, 620),
	},
	{
		"name": "Herolh/105004",
		"path": "res://assets/resources/native/96/964573c8-6b8e-41e3-8fe1-ec4de01897e0.png",
		"position": Vector2(462, 72),
		"size": Vector2(410, 640),
		"spine": HERO_105004_SPINE,
		"animation": "idle",
		"spine_origin_position": Vector2(640, 360),
		"spine_prefab_offset": Vector2(-68, 333),
		"spine_origin_scale": Vector2(1.0, 0.95),
	},
	{
		"name": "SuLa_LH",
		"spine": HERO_SULA_SPINE,
		"animation": "idle",
		"spine_target": Rect2(Vector2(420, 82), Vector2(430, 604)),
	},
	{
		"name": "YouDuoLa_LH",
		"spine": HERO_YOUDUOLA_SPINE,
		"animation": "idle",
		"spine_target": Rect2(Vector2(420, 82), Vector2(430, 604)),
	},
	{
		"name": "Herolh/104002",
		"path": "res://assets/resources/native/5c/5ce03677-2fe4-46e1-b641-704a3d885afd.png",
		"position": Vector2(452, 76),
		"size": Vector2(400, 630),
	},
	{
		"name": "Herolh/2050081",
		"path": "res://assets/resources/native/37/37e6b283-d20e-40a9-bfe1-b92c049e050b.png",
		"position": Vector2(430, 36),
		"size": Vector2(460, 680),
	},
	{
		"name": "Native Knight",
		"path": "res://assets/resources/native/64/645eff01-c534-4380-951e-72eeea0bbd45.png",
		"position": Vector2(450, 118),
		"size": Vector2(360, 560),
	},
]

var design_root: Control
var prefab_layer: Control
var bottom_nav_hit_layer: Control
var background_image: TextureRect
var hero_image: TextureRect
var hero_spine: Node2D
var hero_hit_area: Button
var title_label: Label
var right_ribbon_hit_layer: Control
var right_ribbon_hits: Array[Dictionary] = []
var bottom_nav_hits: Array[Dictionary] = []
var main_nodes_by_name: Dictionary = {}
var main_nodes_by_index: Dictionary = {}
var nav_nodes_by_name: Dictionary = {}
var nav_nodes_by_index: Dictionary = {}
var bg_index := 0
var hero_index := 1
var hero_tween: Tween
var hero_animation_index := 0

func _ready() -> void:
	_load_layout_indexes()
	_build_ui()
	_apply_cmdline_overrides()
	_capture_if_requested()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var design_position := _viewport_to_design(event.position)
		for i in range(bottom_nav_hits.size() - 1, -1, -1):
			var nav_item: Dictionary = bottom_nav_hits[i]
			var nav_rect: Rect2 = nav_item.rect
			if nav_rect.has_point(design_position):
				get_viewport().set_input_as_handled()
				var nav_entry := str(nav_item.get("entry", ""))
				if nav_entry != "":
					_open_home_entry(nav_entry)
				else:
					_open_prefab_layout(str(nav_item.get("layout", "")))
				return
		for i in range(right_ribbon_hits.size() - 1, -1, -1):
			var item: Dictionary = right_ribbon_hits[i]
			var rect: Rect2 = item.rect
			if rect.has_point(design_position):
				get_viewport().set_input_as_handled()
				_open_home_entry(str(item.entry))
				return

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.035, 0.04, 0.06, 1.0)
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	background_image = TextureRect.new()
	background_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(background_image)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.14)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	hero_image = TextureRect.new()
	hero_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(hero_image)

	hero_spine = SimpleSpinePlayerScript.new()
	hero_spine.visible = false
	hero_spine.z_index = 1
	design_root.add_child(hero_spine)

	prefab_layer = Control.new()
	prefab_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prefab_layer.z_index = 500
	prefab_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(prefab_layer)

	bottom_nav_hit_layer = Control.new()
	bottom_nav_hit_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottom_nav_hit_layer.z_index = 700
	bottom_nav_hit_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bottom_nav_hit_layer)

	right_ribbon_hit_layer = Control.new()
	right_ribbon_hit_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	right_ribbon_hit_layer.z_index = 650
	right_ribbon_hit_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(right_ribbon_hit_layer)

	hero_hit_area = Button.new()
	hero_hit_area.flat = true
	hero_hit_area.text = ""
	hero_hit_area.z_index = 400
	hero_hit_area.position = Vector2(500, 92)
	hero_hit_area.size = Vector2(360, 520)
	hero_hit_area.focus_mode = Control.FOCUS_NONE
	hero_hit_area.mouse_filter = Control.MOUSE_FILTER_STOP
	hero_hit_area.pressed.connect(_cycle_hero_animation)
	design_root.add_child(hero_hit_area)

	_layout_design_root()
	_apply_background()
	_apply_hero()
	_build_manual_main_city()
	if "--home-debug-ui" in OS.get_cmdline_args() or "--home-debug-ui" in OS.get_cmdline_user_args():
		_add_debug_bar()
	_update_title()

func _add_debug_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 0.0
	top.anchor_top = 0.0
	top.anchor_right = 0.0
	top.anchor_bottom = 0.0
	top.offset_left = 320
	top.offset_top = 4
	top.offset_right = 786
	top.offset_bottom = 32
	top.alignment = BoxContainer.ALIGNMENT_BEGIN
	top.add_theme_constant_override("separation", 4)
	add_child(top)

	title_label = Label.new()
	title_label.text = "MainPre prefab"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	Navigation.add_buttons(top)
	_add_top_button(top, "BG", func(): _cycle_background())
	_add_top_button(top, "Hero", func(): _cycle_hero())
	_add_top_button(top, "Res", func(): Navigation.go(RESOURCE_BROWSER))
	_add_top_button(top, "Pre", func(): Navigation.go(PREFAB_PREVIEW))
	_add_top_button(top, "Spine", func(): Navigation.go(SPINE_VIEWER))
	_add_top_button(top, "City", func(): Navigation.go(FLOATING_CITY_SCENE))

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(54, 28)
	button.pressed.connect(callback)
	parent.add_child(button)

func _build_manual_main_city() -> void:
	for child in prefab_layer.get_children():
		child.queue_free()
	for child in bottom_nav_hit_layer.get_children():
		child.queue_free()
	for child in right_ribbon_hit_layer.get_children():
		child.queue_free()
	right_ribbon_hits.clear()
	bottom_nav_hits.clear()

	_add_player_panel()
	_add_currency_bar()
	_add_left_quick_buttons()
	_add_event_grid()
	_add_ad_banner()
	_add_right_ribbons()
	_add_bottom_nav()
	_add_chat_panel()

func _load_layout_indexes() -> void:
	var main := _load_layout_nodes(LAYOUT_PATH)
	main_nodes_by_name = main.names
	main_nodes_by_index = main.indexes
	var nav := _load_layout_nodes(NAV_LAYOUT_PATH)
	nav_nodes_by_name = nav.names
	nav_nodes_by_index = nav.indexes

func _load_layout_nodes(path: String) -> Dictionary:
	var names := {}
	var indexes := {}
	if not FileAccess.file_exists(path):
		return {"names": names, "indexes": indexes}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"names": names, "indexes": indexes}
	for node in parsed.get("nodes", []):
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var node_name := str(node.get("name", ""))
		if node_name != "":
			if not names.has(node_name):
				names[node_name] = []
			names[node_name].append(node)
		indexes[int(node.get("index", -1))] = node
	return {"names": names, "indexes": indexes}

func _layout_rect(name: String, occurrence := 0, source := "main") -> Rect2:
	var node := _layout_node(name, occurrence, source)
	if node.is_empty():
		return Rect2()
	return _node_screen_rect(node)

func _layout_node(name: String, occurrence := 0, source := "main") -> Dictionary:
	var map := main_nodes_by_name if source == "main" else nav_nodes_by_name
	if not map.has(name):
		return {}
	var list: Array = map[name]
	if list.is_empty():
		return {}
	occurrence = clampi(occurrence, 0, list.size() - 1)
	return list[occurrence]

func _node_screen_rect(node: Dictionary) -> Rect2:
	var rect: Array = node.get("screen_rect", [])
	if rect.size() >= 4:
		return Rect2(Vector2(float(rect[0]), float(rect[1])), Vector2(float(rect[2]), float(rect[3])))
	var size := _arr_to_vec2(node.get("size", [0.0, 0.0]))
	return Rect2(_cocos_to_screen(_arr_to_vec2(node.get("global_position", node.get("position", [0.0, 0.0]))), size), size)

func _rect_center(rect: Rect2) -> Vector2:
	return rect.position + rect.size * 0.5

func _rect_or_fallback(name: String, fallback_center: Vector2, fallback_size: Vector2, occurrence := 0, source := "main") -> Rect2:
	var rect := _layout_rect(name, occurrence, source)
	if rect.size.x > 0.0 and rect.size.y > 0.0:
		return rect
	return Rect2(fallback_center - fallback_size * 0.5, fallback_size)

func _add_player_panel() -> void:
	var root := Control.new()
	root.position = Vector2.ZERO
	root.size = Vector2(315, 102)
	prefab_layer.add_child(root)

	var avatar_frame_rect := _layout_rect("cm_TX_TouXiangKuangi", 0, "nav")
	var avatar_rect := _layout_rect("cm_image_TouXiang1", 0, "nav")
	var name_bg_rect := _layout_rect("cm_TX_MingZiDi", 0, "nav")
	var power_bg_rect := _layout_rect("cm_frame9_zhanli", 0, "nav")

	var avatar_bg := TextureRect.new()
	avatar_bg.position = avatar_frame_rect.position if avatar_frame_rect.size.x > 0.0 else Vector2(-54, -52)
	avatar_bg.size = avatar_frame_rect.size if avatar_frame_rect.size.x > 0.0 else Vector2(210, 210)
	var avatar_frame_node := _layout_node("cm_TX_TouXiangKuangi", 0, "nav")
	avatar_bg.texture = _load_node_texture_from_layout(avatar_frame_node)
	if avatar_bg.texture == null:
		avatar_bg.texture = _load_texture_region(ATLAS_1F, Rect2i(679, 348, 96, 82))
	avatar_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(avatar_bg)

	var avatar := TextureRect.new()
	avatar.position = avatar_rect.position if avatar_rect.size.x > 0.0 else Vector2(16, 18)
	avatar.size = avatar_rect.size if avatar_rect.size.x > 0.0 else Vector2(70, 70)
	avatar.texture = _load_texture(PLAYER_HEAD)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(avatar)

	var name_bg := TextureRect.new()
	name_bg.position = name_bg_rect.position if name_bg_rect.size.x > 0.0 else Vector2(68, 14)
	name_bg.size = name_bg_rect.size if name_bg_rect.size.x > 0.0 else Vector2(176, 28)
	var name_bg_node := _layout_node("cm_TX_MingZiDi", 0, "nav")
	name_bg.texture = _load_node_texture_from_layout(name_bg_node)
	name_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	name_bg.stretch_mode = TextureRect.STRETCH_SCALE
	name_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(name_bg)

	var name := Label.new()
	name.text = "骑鹅大侠"
	name.position = name_bg.position + Vector2(18, 0)
	name.size = Vector2(maxf(80.0, name_bg.size.x - 34.0), name_bg.size.y)
	name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 17)
	name.add_theme_color_override("font_color", Color(0.92, 0.90, 0.82))
	root.add_child(name)

	var level := Label.new()
	level.text = "117"
	level.position = Vector2(54, 4)
	level.size = Vector2(38, 22)
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level.add_theme_font_size_override("font_size", 14)
	root.add_child(level)

	var power_bg := TextureRect.new()
	power_bg.position = power_bg_rect.position if power_bg_rect.size.x > 0.0 else Vector2(79, 57)
	power_bg.size = power_bg_rect.size if power_bg_rect.size.x > 0.0 else Vector2(176, 28)
	var power_bg_node := _layout_node("cm_frame9_zhanli", 0, "nav")
	power_bg.texture = _load_node_texture_from_layout(power_bg_node)
	power_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	power_bg.stretch_mode = TextureRect.STRETCH_SCALE
	power_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(power_bg)

	var power_icon := TextureRect.new()
	power_icon.position = power_bg.position + Vector2(18, -1)
	power_icon.size = Vector2(22, 32)
	power_icon.texture = _load_texture_region(ATLAS_18A, Rect2i(415, 568, 30, 30))
	power_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	power_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	power_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(power_icon)

	var power := Label.new()
	power.text = "3027113"
	power.position = power_bg.position + Vector2(45, 1)
	power.size = Vector2(maxf(92.0, power_bg.size.x - 58.0), power_bg.size.y)
	power.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	power.add_theme_font_size_override("font_size", 18)
	power.add_theme_color_override("font_color", Color(0.96, 0.90, 0.68))
	root.add_child(power)

func _add_currency_bar() -> void:
	var money_box := _layout_rect("moneyBox", 0, "nav")
	var money_y := money_box.position.y + money_box.size.y * 0.5 if money_box.size.y > 0.0 else 32.0
	var shop := Button.new()
	shop.text = ""
	shop.position = Vector2(818, 10)
	shop.size = Vector2(96, 56)
	shop.flat = true
	shop.tooltip_text = "商店"
	shop.pressed.connect(func(): Navigation.go(SHOP_PANEL_SCENE))
	prefab_layer.add_child(shop)

	var shop_icon := TextureRect.new()
	shop_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_icon.texture = _load_texture_region(ATLAS_1A, SHOP_ICON_RECT)
	shop_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shop_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shop_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop.add_child(shop_icon)

	_add_money_item(Vector2(1006, money_y), "2.25M", MONEY_FRAME_2_RECT, true, MONEY_ICON_ATLAS_18, MONEY_GOLD_RECT, true, true, Vector2(60, 60))
	_add_money_item(Vector2(1184, money_y), "102.70M", MONEY_FRAME_3_RECT, false, MONEY_FRAME_ATLAS, MONEY_PURPLE_RECT, true, true, Vector2(46, 50))

func _add_money_item(center: Vector2, value: String, bg_rect: Rect2i, bg_rotated: bool, icon_atlas: String, icon_rect: Rect2i, icon_rotated := false, show_add := true, icon_size := Vector2(54, 54)) -> void:
	var box := Control.new()
	box.position = center - Vector2(86, 18)
	box.size = Vector2(172, 36)
	prefab_layer.add_child(box)

	var bg := TextureRect.new()
	bg.position = Vector2(-3, 0)
	bg.size = Vector2(179, 36)
	bg.texture = _load_texture_region(MONEY_FRAME_ATLAS, bg_rect, bg_rotated, Vector2i(179, 36))
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)

	var icon := TextureRect.new()
	icon.position = Vector2(-9, (36.0 - icon_size.y) * 0.5)
	icon.size = icon_size
	icon.texture = _load_texture_region(icon_atlas, icon_rect, icon_rotated, Vector2i(int(icon_size.x), int(icon_size.y)))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)

	var label := Label.new()
	label.text = value
	label.position = Vector2(44, 4)
	label.size = Vector2(86, 28)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82))
	box.add_child(label)

	if show_add:
		var plus := TextureRect.new()
		plus.position = Vector2(139, 6)
		plus.size = Vector2(24, 24)
		plus.texture = _load_texture_region(ATLAS_15, MONEY_ADD_RECT)
		plus.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		plus.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(plus)

func _add_layout_image(name: String, occurrence := 0, source := "main", stretch_mode := TextureRect.STRETCH_KEEP_ASPECT_CENTERED, tint := Color.WHITE) -> TextureRect:
	var node := _layout_node(name, occurrence, source)
	if node.is_empty():
		return null
	var rect := _node_screen_rect(node)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return null
	var texture := _load_node_texture_from_layout(node)
	if texture == null:
		return null
	var image := TextureRect.new()
	image.position = rect.position
	image.size = rect.size
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch_mode
	image.modulate = tint
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prefab_layer.add_child(image)
	return image

func _add_left_quick_buttons() -> void:
	var entries := [
		{"label": "好友", "node": "zjm_btn_HaoYou", "atlas": ATLAS_1A, "rect": Rect2i(260, 3, 60, 54)},
		{"label": "邮件", "node": "zjm_btn_YouJian", "atlas": ATLAS_1A, "rect": Rect2i(326, 3, 60, 55)},
		{"label": "排行", "node": "zjm_btn_PaiHang", "atlas": ATLAS_1A, "rect": Rect2i(458, 3, 60, 55)},
		{"label": "客服", "node": "zjm_btn_XinWen", "atlas": ATLAS_1A, "rect": Rect2i(392, 3, 60, 55)},
		{"label": "战报", "node": "zjm_btn_ZhanBao", "atlas": ATLAS_1A, "rect": Rect2i(524, 3, 60, 55)},
		{"label": "绑定平台", "node": "zjm_btn_bind", "atlas": ATLAS_1F, "rect": Rect2i(747, 551, 34, 34)},
		{"label": "Discord活动", "node": "discordBtn", "atlas": ATLAS_1F, "rect": Rect2i(720, 984, 34, 34)},
	]
	for item in entries:
		var rect := _rect_or_fallback(str(item.node), _cocos_center_to_screen(Vector2(-601.954, 226.0)), Vector2(58, 58))
		_add_icon_button(_rect_center(rect), rect.size, item.label, item.atlas, item.rect)

func _add_event_grid() -> void:
	var entries := [
		{"label": "活动", "node": "zjm_icon_huodong", "atlas": ATLAS_1A, "rect": Rect2i(347, 64, 80, 71)},
		{"label": "福利", "node": "zjm_icon_FuLi", "atlas": ATLAS_1A, "rect": Rect2i(433, 64, 80, 71)},
		{"label": "新服", "node": "zjm_icon_kaifu", "atlas": ATLAS_1A, "rect": Rect2i(777, 78, 80, 71)},
		{"label": "打工", "node": "zjm_icon_dagong", "atlas": ATLAS_1A, "rect": Rect2i(3, 43, 80, 71)},
		{"label": "王者争霸", "node": "zjm_icon_wangzhe", "atlas": ATLAS_1A, "rect": Rect2i(605, 69, 80, 71)},
		{"label": "公会战", "node": "zjm_icon_ghz", "atlas": ATLAS_1A, "rect": Rect2i(861, 3, 80, 69)},
		{"label": "天梯", "node": "zjm_icon_tianti", "atlas": ATLAS_1F, "rect": Rect2i(864, 929, 80, 71), "rotated": true},
		{"label": "礼包", "node": "zjm_icon_libao", "occurrence": 1, "atlas": ATLAS_1F, "rect": Rect2i(781, 348, 80, 80)},
		{"label": "通行证", "node": "zjm_icon_pass", "atlas": ATLAS_1F, "rect": Rect2i(864, 757, 80, 73), "rotated": true},
		{"label": "限时", "node": "zjm_icon_xianshihuodong", "atlas": ATLAS_1A, "rect": Rect2i(519, 69, 80, 71)},
		{"label": "升阶礼包", "node": "zjm_icon_elevate", "atlas": ATLAS_1A, "rect": Rect2i(347, 64, 80, 71)},
		{"label": "皮肤", "node": "zjm_icon_skin", "atlas": ATLAS_1A, "rect": Rect2i(360, 141, 80, 80)},
		{"label": "组队竞技", "node": "zjm_icon_pvp", "atlas": ATLAS_1F, "rect": Rect2i(945, 688, 80, 75), "rotated": true},
		{"label": "升星", "node": "zjm_icon_star", "atlas": ATLAS_1A, "rect": Rect2i(261, 64, 80, 71)},
		{"label": "首充", "node": "zjm_icon_first", "atlas": ATLAS_1A, "rect": Rect2i(3, 120, 80, 80)},
		{"label": "特惠", "node": "zjm_icon_thank", "atlas": ATLAS_1A, "rect": Rect2i(446, 146, 80, 80)},
		{"label": "每日礼包", "node": "zjm_icon_daily", "atlas": ATLAS_1F, "rect": Rect2i(864, 843, 72, 80)},
		{"label": "召唤卡", "node": "zjm_icon_zhaohuanactivity", "atlas": ATLAS_1A, "rect": Rect2i(608, 247, 131, 123)},
		{"label": "竟榜抽奖", "node": "zjm_icon_pvpActivity", "atlas": ATLAS_1F, "rect": Rect2i(943, 774, 80, 78), "rotated": true},
		{"label": "食铁神兽", "node": "zjm_icon_stssActivity", "atlas": ATLAS_1A, "rect": Rect2i(89, 62, 80, 71)},
		{"label": "预注册", "node": "zjm_icon_prereg", "atlas": ATLAS_1F, "rect": Rect2i(547, 602, 131, 119)},
		{"label": "活动预告", "node": "zjm_btn_forecast", "atlas": ATLAS_1A, "rect": Rect2i(446, 146, 80, 80)},
		{"label": "广告奖励", "node": "advertisingbtn", "atlas": ATLAS_1F, "rect": Rect2i(864, 843, 72, 80)},
		{"label": "次元魔战", "node": "zjm_icon_cymz", "atlas": ATLAS_1A, "rect": Rect2i(89, 62, 80, 71)},
	]
	for item in entries:
		var atlas := str(item.get("atlas", ""))
		var rect: Rect2i = item.get("rect", Rect2i())
		var layout_node := _layout_node(str(item.node), int(item.get("occurrence", 0)))
		if not layout_node.is_empty() and not bool(layout_node.get("active", true)) and not bool(item.get("force_show", false)):
			continue
		var layout_rect := _node_screen_rect(layout_node) if not layout_node.is_empty() else Rect2()
		if layout_rect.size.x > 0.0:
			layout_rect.position.x = maxf(layout_rect.position.x, MAIN_EVENT_GRID_MIN_X)
		var center := _rect_center(layout_rect) if layout_rect.size.x > 0.0 else _cocos_center_to_screen(Vector2(-510.0, 213.773))
		var size := layout_rect.size if layout_rect.size.x > 0.0 else Vector2(80, 80)
		_add_event_button(center, str(item.label), atlas, rect, bool(item.get("rotated", false)), size)

func _add_ad_banner() -> void:
	var layout_rect := _layout_rect("zjm_image_GuanGao1")
	var ad_size := layout_rect.size if layout_rect.size.x > 0.0 else Vector2(320, 150)
	var box := Control.new()
	box.position = layout_rect.position if layout_rect.size.x > 0.0 else _cocos_center_to_screen(Vector2(-464.409, -115.622)) - ad_size * 0.5
	box.size = ad_size
	prefab_layer.add_child(box)

	var banner := TextureRect.new()
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.texture = _load_texture(AD_BANNER)
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(banner)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = "活动预告"
	hit.pressed.connect(_open_prefab_layout.bind("活动预告"))
	box.add_child(hit)

	_add_red_dot(box, Vector2(306, 16), Vector2(24, 24))

func _add_right_ribbons() -> void:
	var entries := [
		{"label": "宝具", "node": "zjm_btn_rukou0", "occurrence": 0, "icon_node": "zjm_icon_baoju", "bg": Rect2i(639, 292, 364, 50), "bg_offset": Vector2(-10.5, 0), "icon": Rect2i(864, 757, 80, 73), "icon_atlas": ATLAS_1F, "icon_rotated": true, "prefer_manual_icon": true},
		{"label": "仓库", "node": "zjm_btn_rukou0", "occurrence": 1, "icon_node": "zjm_icon_cangku", "bg": Rect2i(639, 292, 364, 50), "bg_offset": Vector2(-10.5, 0), "icon": Rect2i(747, 551, 34, 34), "icon_atlas": ATLAS_1F},
		{"label": "竞技", "node": "zjm_btn_rukou1", "occurrence": 0, "icon_node": "zjm_icon_jingji", "bg": Rect2i(675, 65, 341, 56), "bg_offset": Vector2(1, 0), "icon": Rect2i(667, 551, 34, 34), "icon_atlas": ATLAS_1F},
		{"label": "学院", "node": "zjm_btn_rukou1", "occurrence": 1, "icon_node": "zjm_icon_xueyuan", "bg": Rect2i(675, 65, 341, 56), "bg_offset": Vector2(1, 0), "icon": Rect2i(3, 3, 34, 34), "icon_atlas": ATLAS_1A},
		{"label": "英魂", "node": "zjm_btn_rukou2", "occurrence": 0, "icon_node": "zjm_icon_zhaohuan", "icon_occurrence": 0, "bg": Rect2i(675, 230, 336, 56), "bg_offset": Vector2(3.5, 0), "icon": Rect2i(83, 3, 34, 34), "icon_atlas": ATLAS_1A, "prefer_manual_icon": true},
		{"label": "锻造", "node": "zjm_btn_rukou3", "occurrence": 0, "icon_node": "zjm_icon_zhaohuan", "icon_occurrence": 1, "bg": Rect2i(675, 3, 342, 56), "bg_offset": Vector2(0.5, 0), "icon": Rect2i(720, 984, 34, 34), "icon_atlas": ATLAS_1F, "prefer_manual_icon": true},
		{"label": "占卜", "node": "zjm_btn_rukou4", "occurrence": 0, "icon_node": "zjm_icon_zhaohuan", "icon_occurrence": 2, "bg": Rect2i(684, 591, 387, 58), "bg_offset": Vector2(-22, 0), "bg_rotated": true, "icon": Rect2i(3, 225, 100, 95), "icon_atlas": ATLAS_1A, "prefer_manual_icon": true},
		{"label": "寻星", "node": "zjm_btn_rukou4", "occurrence": 1, "icon_node": "zjm_icon_zhaohuan", "icon_occurrence": 3, "bg": Rect2i(684, 591, 387, 58), "bg_offset": Vector2(-22, 0), "bg_rotated": true, "icon": Rect2i(43, 3, 34, 34), "icon_atlas": ATLAS_1A, "prefer_manual_icon": true},
		{"label": "商会", "node": "zjm_btn_rukou5", "occurrence": 0, "icon_node": "zjm_icon_zhaohuan", "icon_occurrence": 4, "bg": Rect2i(675, 3, 342, 56), "bg_offset": Vector2(0.5, 0), "icon": Rect2i(547, 551, 34, 34), "icon_atlas": ATLAS_1F, "prefer_manual_icon": true},
	]
	for item in entries:
		var rect := _layout_rect(str(item.node), int(item.get("occurrence", 0)))
		if rect.size.x <= 0.0:
			continue
		_add_ribbon_button(rect, item)

func _add_ribbon_button(source_rect: Rect2, item: Dictionary) -> void:
	var box := Control.new()
	box.position = source_rect.position
	box.size = source_rect.size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prefab_layer.add_child(box)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg_node := _layout_node(str(item.node), int(item.get("occurrence", 0)))
	bg.texture = _load_node_texture_from_layout(bg_node)
	if bg.texture == null:
		bg.texture = _load_texture_region(ATLAS_1F, item.bg, bool(item.get("bg_rotated", false)), Vector2i(431, 58), item.get("bg_offset", Vector2.ZERO))
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)

	var icon := TextureRect.new()
	var icon_rect := _layout_rect(str(item.get("icon_node", "")), int(item.get("icon_occurrence", 0)))
	icon.position = icon_rect.position - source_rect.position if icon_rect.size.x > 0.0 else Vector2(11, 1)
	icon.size = icon_rect.size if icon_rect.size.x > 0.0 else Vector2(32, 32)
	var icon_node := _layout_node(str(item.get("icon_node", "")), int(item.get("icon_occurrence", 0)))
	if not bool(item.get("prefer_manual_icon", false)):
		icon.texture = _load_node_texture_from_layout(icon_node)
	if icon.texture == null:
		icon.texture = _load_texture_region(str(item.icon_atlas), item.icon, bool(item.get("icon_rotated", false)))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)

	var label := Label.new()
	label.text = str(item.label)
	label.position = Vector2(box.size.x * 0.48, (box.size.y - 30.0) * 0.5)
	label.size = Vector2(92, 30)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.22, 0.17, 0.09))
	box.add_child(label)

	_add_ribbon_hit_area(source_rect, item)

func _add_ribbon_hit_area(source_rect: Rect2, item: Dictionary) -> void:
	var hit_rect := source_rect.grow(10.0)
	right_ribbon_hits.append({
		"rect": hit_rect,
		"entry": str(item.get("entry", item.label)),
	})
	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.position = hit_rect.position
	hit.size = hit_rect.size
	hit.focus_mode = Control.FOCUS_NONE
	hit.tooltip_text = "%s 预览" % str(item.label)
	hit.pressed.connect(_open_home_entry.bind(str(item.get("entry", item.label))))
	right_ribbon_hit_layer.add_child(hit)

func _add_bottom_nav() -> void:
	_add_nav_background()
	_add_nav_selected_light()

	var entries := [
		{"label": "城镇", "node": "cm_tab_ChengZhen1", "hit": "btn1", "path": "res://assets/resources/native/87/8715b80b-6cbc-4b88-bf7d-8c2ab401db4e.png"},
		{"label": "英雄", "node": "cm_tab_YingXiong1", "hit": "btn2", "path": "res://assets/resources/native/9a/9a9cb544-24ba-41c7-8cab-41a43a9e9c33.png", "entry": "英雄"},
		{"label": "召唤", "node": "cm_tab_ZhaoHuan", "hit": "btn3", "atlas": ATLAS_1A, "rect": NAV_SLOT3_RECT, "entry": "召唤", "force_atlas": true},
		{"label": "冒险", "node": "cm_tab_ChuJi1", "hit": "btn4", "atlas": ATLAS_1A, "rect": Rect2i(159, 345, 150, 145), "layout": "挂机主线"},
		{"label": "副本", "node": "cm_tab_FuBen", "hit": "btn5", "atlas": ATLAS_1A, "rect": Rect2i(879, 276, 134, 133), "layout": "冒险地图顶部"},
		{"label": "公会", "node": "cm_tab_GongHui1", "hit": "btn6", "atlas": ATLAS_1A, "rect": Rect2i(345, 232, 119, 126), "rotated": true, "layout": "公会"},
	]
	for item in entries:
		var box := Control.new()
		var icon_rect := _layout_rect(str(item.node), 0, "nav")
		if icon_rect.size.x <= 0.0:
			continue
		var hit_rect := _layout_rect(str(item.hit), 0, "nav")
		box.position = icon_rect.position
		box.size = icon_rect.size
		prefab_layer.add_child(box)

		var image := TextureRect.new()
		var icon_node := _layout_node(str(item.node), 0, "nav")
		if not bool(item.get("force_atlas", false)):
			image.texture = _load_node_texture_from_layout(icon_node)
		if image.texture != null and not bool(item.get("force_atlas", false)):
			pass
		elif item.has("path"):
			image.texture = _load_texture(str(item.path))
		else:
			image.texture = _load_texture_region(str(item.atlas), item.rect, bool(item.get("rotated", false)))
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		if item.has("draw_size"):
			image.size = item.draw_size
			image.position = (box.size - image.size) * 0.5 + item.get("draw_offset", Vector2.ZERO)
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		else:
			image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(image)

		var text := Label.new()
		text.text = str(item.label)
		text.position = Vector2(0, box.size.y - 37)
		text.size = Vector2(box.size.x, 28)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.add_theme_font_size_override("font_size", 18)
		text.add_theme_color_override("font_shadow_color", Color(0.12, 0.08, 0.02, 0.85))
		text.add_theme_constant_override("shadow_offset_x", 1)
		text.add_theme_constant_override("shadow_offset_y", 1)
		text.add_theme_color_override("font_color", Color(0.98, 0.93, 0.76))
		box.add_child(text)

		var hit := Button.new()
		hit.text = ""
		hit.flat = true
		hit.position = hit_rect.position if hit_rect.size.x > 0.0 else box.position
		hit.size = hit_rect.size if hit_rect.size.x > 0.0 else box.size
		hit.z_index = 60
		hit.focus_mode = Control.FOCUS_NONE
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		var entry := str(item.get("entry", ""))
		var layout := str(item.get("layout", ""))
		if entry != "":
			hit.tooltip_text = "%s 预览" % str(item.label)
			hit.pressed.connect(_open_home_entry.bind(entry))
		elif layout != "":
			hit.tooltip_text = "%s 预览" % layout
			hit.pressed.connect(_open_prefab_layout.bind(layout))
		bottom_nav_hit_layer.add_child(hit)
		bottom_nav_hits.append({
			"rect": Rect2(hit.position, hit.size),
			"entry": entry,
			"layout": layout,
		})

		if bool(item.get("show_red_dot", false)):
			_add_red_dot(box, Vector2(box.size.x - 18, 28), Vector2(24, 24))

func _add_nav_background() -> void:
	var layout_rect := _layout_rect("cm_menu_BeiJing", 0, "nav")
	if layout_rect.size.x <= 0.0:
		layout_rect = Rect2(Vector2(-493, 540.552), NAV_BG_SIZE)
	var image := TextureRect.new()
	image.position = layout_rect.position
	image.size = layout_rect.size
	image.texture = _load_texture(NAV_BG_TEXTURE)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.modulate = Color(1, 1, 1, 0.78)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prefab_layer.add_child(image)

func _add_nav_selected_light() -> void:
	var light := _add_layout_image("cm_menu_TaiYangGuang", 0, "nav", TextureRect.STRETCH_KEEP_ASPECT_CENTERED, Color(1, 1, 1, NAV_SELECTED_LIGHT_ALPHA))
	if light == null:
		return
	var btn1 := _layout_rect("btn1", 0, "nav")
	if btn1.size.x <= 0.0:
		return
	light.position.x = btn1.position.x + btn1.size.x * 0.5 - light.size.x * 0.5

func _add_chat_panel() -> void:
	var panel := Control.new()
	panel.position = Vector2(44, 562)
	panel.size = Vector2(330, 52)
	prefab_layer.add_child(panel)

	var text := Label.new()
	text.text = "陆上：欢迎来到离线主城预览。这里展示原始资源与手工还原的界面层。"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.offset_left = 12
	text.offset_top = 4
	text.offset_right = -12
	text.offset_bottom = -4
	text.add_theme_font_size_override("font_size", 15)
	text.add_theme_color_override("font_color", Color(0.74, 0.90, 1.0))
	panel.add_child(text)

func _add_icon_button(center: Vector2, size: Vector2, text: String, atlas_path: String, rect: Rect2i) -> void:
	var box := Control.new()
	box.position = center - size * 0.5
	box.size = size
	prefab_layer.add_child(box)

	var image := TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.texture = _load_texture_region(atlas_path, rect)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(image)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = text
	hit.pressed.connect(_open_home_entry.bind(text))
	box.add_child(hit)

	_add_red_dot(box, size - Vector2(8, 10), Vector2(22, 22))

func _add_event_button(center: Vector2, text: String, atlas_path: String = "", rect: Rect2i = Rect2i(), rotated := false, size := Vector2(80, 80)) -> void:
	var box := Control.new()
	box.position = center - size * 0.5
	box.size = size
	prefab_layer.add_child(box)

	if atlas_path != "":
		var image := TextureRect.new()
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		image.texture = _load_texture_region(atlas_path, rect, rotated)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(image)
	else:
		var circle := PanelContainer.new()
		circle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		circle.modulate = Color(0.86, 0.61, 0.24, 0.86)
		box.add_child(circle)

	var label := Label.new()
	label.text = text
	label.position = Vector2(-16, maxf(50.0, size.y - 26.0))
	label.size = Vector2(size.x + 32.0, 26)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color.WHITE)
	box.add_child(label)

	_add_red_dot(box, Vector2(64, 8), Vector2(24, 24))

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = text
	hit.pressed.connect(_open_home_entry.bind(text))
	box.add_child(hit)

func _add_red_dot(parent: Control, center: Vector2, size := Vector2(24, 24)) -> void:
	var dot := TextureRect.new()
	dot.position = center - size * 0.5
	dot.size = size
	dot.texture = _load_texture_region(ATLAS_18A, RED_DOT_RECT)
	dot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(dot)

func _open_home_entry(label: String) -> void:
	if label == "英雄":
		Navigation.go(HERO_LIST_SCENE)
		return
	if label == "仓库":
		Navigation.go(BAG_PANEL_SCENE)
		return
	if label == "召唤":
		Navigation.go(DRAW_CARD_SCENE)
		return
	if label == "商会" or label == "商店":
		Navigation.go(SHOP_PANEL_SCENE)
		return
	var layout_map := {
		"广告": "广告奖励",
		"好友": "好友",
		"邮件": "邮件",
		"排行": "排行",
		"客服": "客服",
		"新闻": "客服",
		"战报": "战报",
		"任务": "任务",
		"绑定平台": "绑定平台",
		"Discord活动": "Discord活动",
		"活动": "活动面板",
		"福利": "福利",
		"新服": "开服战神",
		"开服": "开服战神",
		"礼包": "礼包",
		"限时": "限时礼包",
		"皮肤": "皮肤商店",
		"升星": "升星计划",
		"首充": "首充",
		"特惠": "特惠活动",
		"每日礼包": "每日礼包",
		"打工": "打工",
		"王者争霸": "王者争霸",
		"公会战": "公会战",
		"天梯": "天梯",
		"组队竞技": "组队竞技",
		"召唤卡": "召唤卡",
		"竟榜抽奖": "竟榜抽奖",
		"食铁神兽": "食铁神兽",
		"预注册": "预注册",
		"升阶礼包": "升阶礼包",
		"活动预告": "活动预告",
		"广告奖励": "广告奖励",
		"次元魔战": "次元魔战",
		"宝具": "宝具",
		"通行证": "通行证",
		"竞技": "竞技",
		"学院": "学院",
		"英魂": "英魂殿",
		"锻造": "锻造",
		"占卜": "占卜",
		"寻星": "寻星",
		"公会": "公会",
		"商会": "商店",
		"商店": "商店",
		"战斗": "挂机主线",
		"初级": "战斗",
		"冒险": "挂机主线",
		"副本": "冒险地图顶部",
	}
	if layout_map.has(label):
		_open_prefab_layout(str(layout_map[label]))

func _open_prefab_layout(layout: String) -> void:
	Navigation.go_with_args(PREFAB_PREVIEW, {"layout": layout})

func _cycle_background() -> void:
	bg_index = wrapi(bg_index + 1, 0, BACKGROUNDS.size())
	_apply_background()

func _cycle_hero() -> void:
	hero_index = wrapi(hero_index + 1, 0, HEROES.size())
	hero_animation_index = 0
	_apply_hero()

func _apply_cmdline_overrides() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var hero_arg := _cmd_arg_value(args, "--home-hero")
	if hero_arg != "":
		var found_hero := _find_named_entry(HEROES, hero_arg)
		if found_hero >= 0:
			hero_index = found_hero
			hero_animation_index = 0
			_apply_hero()
	var animation_arg := _cmd_arg_value(args, "--home-animation")
	if animation_arg != "":
		_select_hero_animation(animation_arg)
	if "--home-click-hero-once" in args:
		_cycle_hero_animation()
	var time_arg := _cmd_arg_value(args, "--home-animation-time")
	if time_arg != "" and item_has_spine():
		hero_spine.update_preview_pose(float(time_arg))
	var bg_arg := _cmd_arg_value(args, "--home-bg")
	if bg_arg != "":
		var found_bg := _find_named_entry(BACKGROUNDS, bg_arg)
		if found_bg >= 0:
			bg_index = found_bg
			_apply_background()
	var entry_arg := _cmd_arg_value(args, "--home-open-entry")
	if entry_arg != "":
		call_deferred("_open_home_entry", entry_arg)
	var click_arg := _cmd_arg_value(args, "--home-click-at")
	if click_arg != "":
		call_deferred("_click_at_from_arg", click_arg)

func _cmd_arg_value(args: Array, key: String) -> String:
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

func _click_at_from_arg(value: String) -> void:
	var parts := value.split(",", false)
	if parts.size() != 2 or not parts[0].is_valid_float() or not parts[1].is_valid_float():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var position := Vector2(float(parts[0]), float(parts[1]))
	var viewport := get_viewport()
	if viewport == null:
		return
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	viewport.push_input(press)
	if not is_inside_tree():
		return
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	if viewport != null:
		viewport.push_input(release)

func item_has_spine() -> bool:
	return HEROES[hero_index].has("spine")

func _find_named_entry(entries: Array, query: String) -> int:
	if query.is_valid_int():
		var numeric_index := int(query)
		if numeric_index >= 0 and numeric_index < entries.size():
			return numeric_index
	var lower_query := query.to_lower()
	for i in entries.size():
		var item: Dictionary = entries[i]
		if str(item.get("name", "")).to_lower() == lower_query:
			return i
	return -1

func _apply_background() -> void:
	var item: Dictionary = BACKGROUNDS[bg_index]
	var texture := _load_texture(str(item.path))
	if texture:
		background_image.texture = texture
	_update_title()

func _apply_hero() -> void:
	var item: Dictionary = HEROES[hero_index]
	if item.has("spine"):
		hero_image.visible = false
		hero_spine.visible = true
		var animation := _selected_hero_animation(item)
		if hero_spine.load_spine(str(item.spine), animation):
			_fit_spine_hero(item)
		if hero_tween:
			hero_tween.kill()
		hero_hit_area.visible = true
	else:
		hero_spine.visible = false
		hero_image.visible = true
		hero_hit_area.visible = false
		var texture := _load_texture(str(item.path))
		if texture:
			hero_image.texture = texture
		hero_image.position = item.position
		hero_image.size = item.size
		hero_image.pivot_offset = hero_image.size * 0.5
		_start_hero_motion(item.position)
	_update_title()

func _update_title() -> void:
	if title_label == null:
		return
	var item: Dictionary = HEROES[hero_index]
	var suffix := ""
	if item.has("spine"):
		suffix = " | Anim: %s" % _selected_hero_animation(item)
	title_label.text = "MainPre | BG: %s | Hero: %s%s" % [BACKGROUNDS[bg_index].name, item.name, suffix]

func _cycle_hero_animation() -> void:
	var item: Dictionary = HEROES[hero_index]
	if not item.has("spine"):
		return
	var animations := _hero_animation_names(item)
	if animations.size() <= 1:
		return
	hero_animation_index = wrapi(hero_animation_index + 1, 0, animations.size())
	var animation := str(animations[hero_animation_index])
	hero_spine.play(animation)
	_fit_spine_hero(item)
	_update_title()

func _select_hero_animation(animation: String) -> void:
	var item: Dictionary = HEROES[hero_index]
	if not item.has("spine"):
		return
	var animations := _hero_animation_names(item)
	var index := animations.find(animation)
	if index < 0:
		return
	hero_animation_index = index
	hero_spine.play(animation)
	_fit_spine_hero(item)
	_update_title()

func _selected_hero_animation(item: Dictionary) -> String:
	var animations := _hero_animation_names(item)
	if animations.is_empty():
		return str(item.get("animation", "idle"))
	hero_animation_index = clampi(hero_animation_index, 0, animations.size() - 1)
	return str(animations[hero_animation_index])

func _hero_animation_names(item: Dictionary) -> Array:
	if item.has("animations"):
		return item.animations
	var path := str(item.get("spine", ""))
	if path == "":
		return [str(item.get("animation", "idle"))]
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return [str(item.get("animation", "idle"))]
	var skeleton: Dictionary = parsed.get("skeleton", {})
	var animation_dict: Dictionary = skeleton.get("animations", {})
	var names := animation_dict.keys()
	names.sort()
	if names.has("idle"):
		names.erase("idle")
		names.push_front("idle")
	return names

func _fit_spine_hero(item: Dictionary) -> void:
	hero_spine.update_preview_pose(0.0)
	var bounds: Rect2 = hero_spine.get_draw_bounds()
	if item.has("spine_origin_position"):
		var origin_scale := _scale_vector(item.get("spine_origin_scale", 1.0))
		hero_spine.scale = origin_scale
		hero_spine.position = item.get("spine_origin_position", Vector2(640, 360)) + item.get("spine_prefab_offset", Vector2.ZERO) + item.get("spine_offset", Vector2.ZERO)
		_update_hero_hit_area(bounds, hero_spine.position, origin_scale)
		return
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		hero_spine.position = item.get("spine_position", Vector2(620, 670))
		hero_spine.scale = item.get("spine_scale", Vector2(0.58, 0.58))
		_update_hero_hit_area(bounds, hero_spine.position, _scale_vector(hero_spine.scale))
		return
	var target: Rect2 = item.get("spine_target", Rect2(Vector2(420, 96), Vector2(430, 590)))
	var scale_value: float = min(target.size.x / bounds.size.x, target.size.y / bounds.size.y)
	scale_value *= float(item.get("spine_scale_bias", 1.0))
	hero_spine.scale = Vector2(scale_value, scale_value)
	var bounds_center := bounds.position + bounds.size * 0.5
	var target_center := target.position + target.size * 0.5
	hero_spine.position = target_center - bounds_center * scale_value + item.get("spine_offset", Vector2.ZERO)
	_update_hero_hit_area(bounds, hero_spine.position, Vector2(scale_value, scale_value))

func _scale_vector(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	var scalar := float(value)
	return Vector2(scalar, scalar)

func _update_hero_hit_area(bounds: Rect2, origin: Vector2, scale_value: Vector2) -> void:
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		hero_hit_area.position = Vector2(500, 92)
		hero_hit_area.size = Vector2(360, 520)
		return
	var screen_rect := Rect2(origin + bounds.position * scale_value, bounds.size * scale_value)
	hero_hit_area.position = screen_rect.position
	hero_hit_area.size = screen_rect.size

func _start_hero_motion(base_position: Vector2) -> void:
	if hero_tween:
		hero_tween.kill()
	hero_tween = create_tween()
	hero_tween.set_loops()
	hero_tween.tween_property(hero_image, "position:y", base_position.y - 7.0, 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	hero_tween.tween_property(hero_image, "position:y", base_position.y + 2.0, 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _render_main_prefab() -> void:
	for child in prefab_layer.get_children():
		child.queue_free()

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var nodes: Array = parsed.get("nodes", [])
	for node in _sorted_nodes(nodes):
		_add_prefab_node(node)

func _add_prefab_node(node: Dictionary) -> void:
	if not bool(node.get("active", true)):
		return
	var name := str(node.get("name", ""))
	if name in ["MainPre", "zjm_BG2", "lihui", "main", "uiLayer", "contentBox", "markBg"]:
		return

	var texture_path := str(node.get("texture_path", ""))
	var should_draw_placeholder := _is_key_missing_node(name) and texture_path == ""
	if texture_path == "" and not should_draw_placeholder:
		return
	if texture_path != "" and not _is_trusted_texture_node(name, node):
		return

	var size := _arr_to_vec2(node.get("size", [80.0, 36.0]))
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var position := _arr_to_vec2(node.get("global_position", node.get("position", [0.0, 0.0])))

	var rect: Control
	if texture_path != "":
		var image := TextureRect.new()
		image.texture = _load_node_texture("res://" + texture_path, node)
		if image.texture == null:
			return
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_SCALE
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect = image
	else:
		var panel := PanelContainer.new()
		panel.modulate = _color_for_name(name)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect = panel
		var label := Label.new()
		label.text = _label_for_node(name)
		label.clip_text = true
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(label)

	rect.size = size
	rect.position = _cocos_to_screen(position, size)
	rect.rotation = deg_to_rad(float(node.get("rotation_z", 0.0)))
	rect.tooltip_text = "%s\n%s" % [name, JSON.stringify(node)]
	prefab_layer.add_child(rect)

func _is_trusted_texture_node(name: String, node: Dictionary) -> bool:
	var sprite_rect: Array = node.get("sprite_rect", [])
	var size := _arr_to_vec2(node.get("size", [0.0, 0.0]))
	if sprite_rect.is_empty() and size.x > 220.0 and size.y > 90.0:
		return false
	if sprite_rect.size() == 4:
		var rect_size := Vector2(float(sprite_rect[2]), float(sprite_rect[3]))
		if rect_size.x <= 0.0 or rect_size.y <= 0.0:
			return false
		if size.x > rect_size.x * 4.0 or size.y > rect_size.y * 4.0:
			return false
		if rect_size.x > 520.0 or rect_size.y > 260.0:
			return name.contains("GuanGao")
		if size.x > 520.0 or size.y > 260.0:
			return name.contains("GuanGao")
		return true
	return false

func _is_key_missing_node(name: String) -> bool:
	return false

func _label_for_node(name: String) -> String:
	var labels := {
		"zjm_btn_baoju": "Treasure",
		"zjm_btn_cangku": "Storage",
		"zjm_btn_teach": "Quest",
		"zjm_btn_jingji": "Arena",
		"zjm_btn_yinghun": "Soul",
		"zjm_btn_duanzao": "Forge",
		"zjm_btn_zhanbu": "Oracle",
		"zjm_btn_xunxing": "Search",
		"zjm_btn_shop": "Shop",
		"zjm_icon_huodong": "Event",
		"zjm_icon_FuLi": "Gift",
		"zjm_icon_star": "Star",
		"zjm_icon_first": "Topup",
	}
	return str(labels.get(name, name.replace("zjm_", "")))

func _cocos_to_screen(position: Vector2, size: Vector2) -> Vector2:
	return Vector2(DESIGN_SIZE.x * 0.5 + position.x - size.x * 0.5, DESIGN_SIZE.y * 0.5 - position.y - size.y * 0.5)

func _cocos_center_to_screen(position: Vector2) -> Vector2:
	return Vector2(DESIGN_SIZE.x * 0.5 + position.x, DESIGN_SIZE.y * 0.5 - position.y)

func _viewport_to_design(position: Vector2) -> Vector2:
	if design_root == null:
		return position
	return (position - design_root.position) / design_root.scale

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

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
	if name == "zjm_BG2":
		return 0
	if name == "lihui":
		return 10
	if name.contains("image_GuanGao"):
		return 30
	if name.begins_with("zjm_btn_"):
		return 60
	if name.begins_with("zjm_icon_"):
		return 70
	if name == "hongdian":
		return 90
	return int(node.get("index", 0))

func _color_for_name(name: String) -> Color:
	if name.begins_with("zjm_btn_"):
		return Color(0.08, 0.06, 0.04, 0.62)
	if name.begins_with("zjm_icon_"):
		return Color(0.9, 0.68, 0.22, 0.68)
	if name == "msg":
		return Color(0.02, 0.02, 0.05, 0.55)
	return Color(0.2, 0.24, 0.32, 0.50)

func _layout_design_root() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(factor, factor)
	design_root.position = (viewport_size - DESIGN_SIZE * factor) * 0.5

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return _make_sprite_frame_texture(image, region, rotated, original_size, offset)

func _load_node_texture(path: String, node: Dictionary) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var sprite_rect: Array = node.get("sprite_rect", [])
	if sprite_rect.size() == 4:
		var crop := Rect2i(int(sprite_rect[0]), int(sprite_rect[1]), int(sprite_rect[2]), int(sprite_rect[3]))
		var original_size := _arr_to_vec2i(node.get("sprite_original_size", []))
		var offset := _arr_to_vec2(node.get("sprite_offset", []))
		return _make_sprite_frame_texture(image, crop, bool(node.get("sprite_rotated", false)), original_size, offset)
	return ImageTexture.create_from_image(image)

func _load_node_texture_from_layout(node: Dictionary) -> Texture2D:
	if node.is_empty():
		return null
	var texture_path := str(node.get("texture_path", ""))
	if texture_path == "":
		return null
	return _load_node_texture("res://" + texture_path, node)

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

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-home-screen" in args:
		return
	for i in 8:
		await get_tree().process_frame
	var index := args.find("--capture-home-screen")
	var output_path := "user://home_screen.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
