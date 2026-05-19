extends Control

const LAYOUT_PATH := "res://data/prefab_layouts/MainPre.json"
const FLOATING_CITY_SCENE := "res://scenes/original_main_city.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const SPINE_VIEWER := "res://scenes/spine_character_viewer.tscn"
const HERO_PANEL_SCENE := "res://scenes/original_hero_panel.tscn"
const BAG_PANEL_SCENE := "res://scenes/original_bag_panel.tscn"
const DRAW_CARD_SCENE := "res://scenes/original_draw_card_panel.tscn"
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
const MONEY_GOLD := "res://assets/resources/native/9e/9ec8c387-6381-46b4-93eb-7ebe016dbffc.png"
const MONEY_DIAMOND := "res://assets/resources/native/47/47e154d7-f9c2-4a5a-85c0-b299960f439b.png"
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
var background_image: TextureRect
var hero_image: TextureRect
var hero_spine: Node2D
var hero_hit_area: Button
var title_label: Label
var bg_index := 0
var hero_index := 1
var hero_tween: Tween
var hero_animation_index := 0

func _ready() -> void:
	_build_ui()
	_apply_cmdline_overrides()
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
	design_root.add_child(prefab_layer)

	hero_hit_area = Button.new()
	hero_hit_area.flat = true
	hero_hit_area.text = ""
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

	_add_player_panel()
	_add_currency_bar()
	_add_left_quick_buttons()
	_add_event_grid()
	_add_ad_banner()
	_add_right_ribbons()
	_add_bottom_nav()
	_add_chat_panel()

func _add_player_panel() -> void:
	var root := Control.new()
	root.position = Vector2(0, 0)
	root.size = Vector2(315, 86)
	prefab_layer.add_child(root)

	var avatar_bg := TextureRect.new()
	avatar_bg.position = Vector2(16, 0)
	avatar_bg.size = Vector2(84, 84)
	avatar_bg.texture = _load_texture_region(ATLAS_18A, Rect2i(3, 119, 110, 110))
	avatar_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(avatar_bg)

	var avatar := TextureRect.new()
	avatar.position = Vector2(25, 6)
	avatar.size = Vector2(66, 66)
	avatar.texture = _load_texture(PLAYER_HEAD)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(avatar)

	var name_bg := PanelContainer.new()
	name_bg.position = Vector2(94, 11)
	name_bg.size = Vector2(174, 30)
	name_bg.modulate = Color(0.04, 0.05, 0.09, 0.66)
	root.add_child(name_bg)

	var name := Label.new()
	name.text = "骑鹅大侠"
	name.position = Vector2(103, 12)
	name.size = Vector2(140, 28)
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

	var power_icon := TextureRect.new()
	power_icon.position = Vector2(100, 45)
	power_icon.size = Vector2(22, 32)
	power_icon.texture = _load_texture_region(ATLAS_18A, Rect2i(415, 568, 30, 30))
	power_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	power_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	power_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(power_icon)

	var power := Label.new()
	power.text = "3027113"
	power.position = Vector2(126, 49)
	power.size = Vector2(120, 24)
	power.add_theme_font_size_override("font_size", 18)
	power.add_theme_color_override("font_color", Color(0.96, 0.90, 0.68))
	root.add_child(power)

func _add_currency_bar() -> void:
	var shop := Button.new()
	shop.text = "SHOP"
	shop.position = Vector2(818, 10)
	shop.size = Vector2(96, 34)
	shop.add_theme_font_size_override("font_size", 18)
	shop.add_theme_color_override("font_color", Color(0.55, 0.22, 0.08))
	shop.tooltip_text = "商店"
	shop.pressed.connect(_open_prefab_layout.bind("商店"))
	prefab_layer.add_child(shop)

	_add_money_item(Vector2(930, 27), MONEY_GOLD, "2.25M", true)
	_add_money_item(Vector2(1110, 27), MONEY_DIAMOND, "878", true)

func _add_money_item(center: Vector2, icon_path: String, value: String, show_add := true) -> void:
	var box := Control.new()
	box.position = center - Vector2(86, 18)
	box.size = Vector2(172, 36)
	prefab_layer.add_child(box)

	var bg := TextureRect.new()
	bg.position = Vector2(-3, 0)
	bg.size = Vector2(179, 36)
	bg.texture = _load_texture_region(ATLAS_15, Rect2i(106, 400, 36, 179), true, Vector2i(179, 36))
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)

	var icon := TextureRect.new()
	icon.position = Vector2(-9, -9)
	icon.size = Vector2(54, 54)
	icon.texture = _load_texture(icon_path)
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
		var plus := Label.new()
		plus.text = "+"
		plus.position = Vector2(138, 2)
		plus.size = Vector2(28, 30)
		plus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		plus.add_theme_font_size_override("font_size", 28)
		plus.add_theme_color_override("font_color", Color(1.0, 0.92, 0.58))
		box.add_child(plus)

func _add_left_quick_buttons() -> void:
	var entries := [
		{"label": "好友", "pos": Vector2(-601.954, 226.0), "atlas": ATLAS_1A, "rect": Rect2i(260, 3, 60, 54)},
		{"label": "邮件", "pos": Vector2(-601.954, 163.0), "atlas": ATLAS_1A, "rect": Rect2i(326, 3, 60, 55)},
		{"label": "排行", "pos": Vector2(-601.954, 103.0), "atlas": ATLAS_1A, "rect": Rect2i(458, 3, 60, 55)},
		{"label": "新闻", "pos": Vector2(-601.954, 41.0), "atlas": ATLAS_1A, "rect": Rect2i(392, 3, 60, 55)},
		{"label": "战报", "pos": Vector2(-601.954, -20.0), "atlas": ATLAS_1A, "rect": Rect2i(524, 3, 60, 55)},
	]
	for item in entries:
		_add_icon_button(_cocos_center_to_screen(item.pos), Vector2(58, 58), item.label, item.atlas, item.rect)

func _add_event_grid() -> void:
	var entries := [
		{"label": "活动", "pos": Vector2(-510.0, 213.773), "atlas": ATLAS_1A, "rect": Rect2i(347, 64, 80, 71)},
		{"label": "福利", "pos": Vector2(-510.0, 111.773), "atlas": ATLAS_1A, "rect": Rect2i(433, 64, 80, 71)},
		{"label": "开服", "pos": Vector2(-510.0, 9.773), "atlas": ATLAS_1A, "rect": Rect2i(3, 120, 80, 80)},
		{"label": "礼包", "pos": Vector2(-400.0, 213.773), "atlas": ATLAS_1F, "rect": Rect2i(781, 348, 80, 80)},
		{"label": "限时", "pos": Vector2(-400.0, 111.773), "atlas": ATLAS_1A, "rect": Rect2i(519, 69, 80, 71)},
		{"label": "皮肤", "pos": Vector2(-400.0, 9.773), "atlas": ATLAS_1A, "rect": Rect2i(360, 141, 80, 80)},
		{"label": "竞技", "pos": Vector2(-290.0, 213.773), "atlas": ATLAS_1F, "rect": Rect2i(864, 929, 80, 71)},
		{"label": "升星", "pos": Vector2(-290.0, 111.773), "atlas": ATLAS_1A, "rect": Rect2i(261, 64, 80, 71)},
		{"label": "首充", "pos": Vector2(-290.0, 9.773), "atlas": ATLAS_1A, "rect": Rect2i(3, 120, 80, 80)},
		{"label": "特惠", "pos": Vector2(-180.0, 213.773), "atlas": ATLAS_1A, "rect": Rect2i(446, 146, 80, 80)},
		{"label": "广告", "pos": Vector2(-180.0, 111.773), "atlas": ATLAS_1F, "rect": Rect2i(864, 843, 72, 80)},
		{"label": "召唤", "pos": Vector2(-180.0, 9.773), "atlas": ATLAS_1F, "rect": Rect2i(707, 551, 34, 34)},
	]
	for item in entries:
		var atlas := str(item.get("atlas", ""))
		var rect: Rect2i = item.get("rect", Rect2i())
		_add_event_button(_cocos_center_to_screen(item.pos), str(item.label), atlas, rect, bool(item.get("rotated", false)))

func _add_ad_banner() -> void:
	var ad_size := Vector2(320, 150)
	var box := Control.new()
	box.position = _cocos_center_to_screen(Vector2(-464.409, -115.622)) - ad_size * 0.5
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
	hit.tooltip_text = "活动预览"
	hit.pressed.connect(_open_prefab_layout.bind("活动抽卡"))
	box.add_child(hit)

func _add_right_ribbons() -> void:
	var entries := [
		{"label": "通行证", "pos": Vector2(429.983, 220.949), "bg": Rect2i(639, 292, 364, 50), "bg_offset": Vector2(-10.5, 0), "icon": Rect2i(864, 757, 80, 73), "icon_atlas": ATLAS_1F, "icon_rotated": true},
		{"label": "仓库", "pos": Vector2(447.809, 171.94), "bg": Rect2i(639, 292, 364, 50), "bg_offset": Vector2(-10.5, 0), "icon": Rect2i(747, 551, 34, 34), "icon_atlas": ATLAS_1F},
		{"label": "竞技", "pos": Vector2(465.442, 122.605), "bg": Rect2i(675, 65, 341, 56), "bg_offset": Vector2(1, 0), "icon": Rect2i(667, 551, 34, 34), "icon_atlas": ATLAS_1F},
		{"label": "学院", "pos": Vector2(481.647, 65.805), "bg": Rect2i(675, 65, 341, 56), "bg_offset": Vector2(1, 0), "icon": Rect2i(3, 3, 34, 34), "icon_atlas": ATLAS_1A},
		{"label": "英魂", "entry": "召唤", "pos": Vector2(482.615, 8.606), "bg": Rect2i(675, 230, 336, 56), "bg_offset": Vector2(3.5, 0), "icon": Rect2i(707, 551, 34, 34), "icon_atlas": ATLAS_1F},
		{"label": "锻造", "pos": Vector2(477.315, -43.11), "bg": Rect2i(675, 3, 342, 56), "bg_offset": Vector2(0.5, 0), "icon": Rect2i(720, 984, 34, 34), "icon_atlas": ATLAS_1F},
		{"label": "占卜", "pos": Vector2(471.126, -95.893), "bg": Rect2i(684, 591, 387, 58), "bg_offset": Vector2(-22, 0), "bg_rotated": true, "icon": Rect2i(3, 225, 100, 95), "icon_atlas": ATLAS_1A},
		{"label": "寻星", "pos": Vector2(449.239, -148.14), "bg": Rect2i(684, 591, 387, 58), "bg_offset": Vector2(-22, 0), "bg_rotated": true, "icon": Rect2i(43, 3, 34, 34), "icon_atlas": ATLAS_1A},
		{"label": "商会", "pos": Vector2(419.342, -187.272), "bg": Rect2i(675, 3, 342, 56), "bg_offset": Vector2(0.5, 0), "icon": Rect2i(627, 551, 34, 34), "icon_atlas": ATLAS_1F},
	]
	for item in entries:
		_add_ribbon_button(_cocos_center_to_screen(item.pos), item)

func _add_ribbon_button(center: Vector2, item: Dictionary) -> void:
	var box := Control.new()
	box.position = center - Vector2(130, 17)
	box.size = Vector2(260, 34)
	box.rotation = deg_to_rad(-8)
	prefab_layer.add_child(box)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture_region(ATLAS_1F, item.bg, bool(item.get("bg_rotated", false)), Vector2i(431, 58), item.get("bg_offset", Vector2.ZERO))
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)

	var icon := TextureRect.new()
	icon.position = Vector2(11, 1)
	icon.size = Vector2(32, 32)
	icon.texture = _load_texture_region(str(item.icon_atlas), item.icon, bool(item.get("icon_rotated", false)))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)

	var label := Label.new()
	label.text = str(item.label)
	label.position = Vector2(105, 2)
	label.size = Vector2(92, 30)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.22, 0.17, 0.09))
	box.add_child(label)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = "%s 预览" % str(item.label)
	hit.pressed.connect(_open_home_entry.bind(str(item.get("entry", item.label))))
	box.add_child(hit)

func _add_bottom_nav() -> void:
	var entries := [
		{"label": "城镇", "pos": Vector2(-448.355, -295.829), "atlas": ATLAS_1F, "rect": Rect2i(787, 551, 152, 141), "size": Vector2(92, 84)},
		{"label": "英雄", "pos": Vector2(-280.898, -294.476), "atlas": ATLAS_1A, "rect": Rect2i(3, 334, 150, 142), "size": Vector2(92, 84), "entry": "英雄"},
		{"label": "召唤", "pos": Vector2(-95.901, -292.829), "atlas": ATLAS_1A, "rect": Rect2i(940, 89, 80, 80), "size": Vector2(78, 78), "entry": "召唤"},
		{"label": "冒险", "pos": Vector2(83.78, -295.192), "atlas": ATLAS_1A, "rect": Rect2i(159, 345, 150, 145), "size": Vector2(92, 86), "layout": "战斗"},
		{"label": "副本", "pos": Vector2(269.368, -295.829), "atlas": ATLAS_1A, "rect": Rect2i(879, 276, 134, 133), "size": Vector2(84, 82), "layout": "天空城"},
		{"label": "公会", "pos": Vector2(447.148, -295.829), "atlas": ATLAS_1A, "rect": Rect2i(345, 232, 119, 126), "size": Vector2(82, 82), "layout": "公会"},
	]
	for item in entries:
		var box := Control.new()
		var center := _cocos_center_to_screen(item.pos)
		box.position = center - Vector2(62, 52)
		box.size = Vector2(124, 96)
		prefab_layer.add_child(box)

		var image := TextureRect.new()
		var icon_size: Vector2 = item.size
		image.position = Vector2((124.0 - icon_size.x) * 0.5, 0)
		image.size = icon_size
		if item.has("path"):
			image.texture = _load_texture(str(item.path))
		else:
			image.texture = _load_texture_region(str(item.atlas), item.rect, bool(item.get("rotated", false)))
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(image)

		var text := Label.new()
		text.text = str(item.label)
		text.position = Vector2(0, 68)
		text.size = Vector2(124, 28)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.add_theme_font_size_override("font_size", 18)
		text.add_theme_color_override("font_color", Color(0.98, 0.93, 0.76))
		box.add_child(text)

		var hit := Button.new()
		hit.text = ""
		hit.flat = true
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var entry := str(item.get("entry", ""))
		var layout := str(item.get("layout", ""))
		if entry != "":
			hit.tooltip_text = "%s 预览" % str(item.label)
			hit.pressed.connect(_open_home_entry.bind(entry))
		elif layout != "":
			hit.tooltip_text = "%s 预览" % layout
			hit.pressed.connect(_open_prefab_layout.bind(layout))
		box.add_child(hit)

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

func _add_event_button(center: Vector2, text: String, atlas_path: String = "", rect: Rect2i = Rect2i(), rotated := false) -> void:
	var box := Control.new()
	box.position = center - Vector2(40, 40)
	box.size = Vector2(80, 80)
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
	label.position = Vector2(-10, 54)
	label.size = Vector2(100, 26)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color.WHITE)
	box.add_child(label)

	var red := ColorRect.new()
	red.position = Vector2(58, 3)
	red.size = Vector2(14, 14)
	red.color = Color(0.9, 0.05, 0.08, 1.0)
	box.add_child(red)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = text
	hit.pressed.connect(_open_home_entry.bind(text))
	box.add_child(hit)

func _open_home_entry(label: String) -> void:
	if label == "英雄":
		Navigation.go(HERO_PANEL_SCENE)
		return
	if label == "仓库":
		Navigation.go(BAG_PANEL_SCENE)
		return
	if label == "召唤":
		Navigation.go(DRAW_CARD_SCENE)
		return
	var layout_map := {
		"广告": "活动抽卡",
		"竞技": "竞技",
		"公会": "公会",
		"冒险": "战斗",
		"副本": "天空城",
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

func _cmd_arg_value(args: Array, key: String) -> String:
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

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
