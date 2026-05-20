extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const SPINE_VIEWER := "res://scenes/spine_character_viewer.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")
const AudioUtils := preload("res://scripts/audio_utils.gd")

const BG_PATH := "res://assets/resources/native/ac/ac082229-4446-4cfe-bbaf-5e9849e208c3.png"
const ATLAS_18A := "res://assets/resources/native/18/18b29ae48.png"
const ATLAS_1A := "res://assets/resources/native/1a/1a7921f32.png"
const ATLAS_1F := "res://assets/resources/native/1f/1f6b547b4.png"
const ATLAS_15 := "res://assets/resources/native/15/15a1d9111.png"
const NAV_SUMMON_RECT := Rect2i(477, 242, 125, 123)
const NAV_BG_TEXTURE := "res://assets/resources/native/f5/f58085bc-21e6-40ed-a4cf-b55f6b0cc8f9.png"
const HERO_TAB_ON_ATLAS := "res://assets/resources/native/15/15a1d9111.png"
const HERO_TAB_ON_RECT := Rect2i(530, 950, 64, 100)
const HERO_TAB_OFF_ATLAS := "res://assets/resources/native/18/18b29ae48.png"
const HERO_TAB_OFF_RECT := Rect2i(104, 349, 57, 100)
const HERO_MAIN_TAB_SIZES := [
	Vector2(64, 100),
	Vector2(57, 120),
	Vector2(57, 100),
	Vector2(57, 100),
	Vector2(57, 100),
]
const HERO_BOOK_TAG_TEX := "res://assets/resources/native/08/089f225e-78e8-428c-aeec-39bb5b669f43.png"
const HERO_105004_SPINE := "res://data/spine_runtime/105004.json"
const HERO_SULA_SPINE := "res://data/spine_runtime/SuLa_LH.json"
const HERO_YOUDUOLA_SPINE := "res://data/spine_runtime/YouDuoLa_LH.json"
const HERO_VOICE_INDEX_PATH := "res://data/hero_voice_index.json"
const HERO_CATALOG_PATH := "res://data/hero_catalog.json"
const HERO_SPINE_INDEX_PATH := "res://data/hero_spine_runtime_index.json"
const HERO_MAIN_LAYOUT_PATH := "res://data/prefab_layouts/HeroMainPre.json"
const HERO_BOOK_LAYOUT_PATH := "res://data/prefab_layouts/HeroBookDetailPre.json"
const HERO_TOUCH_SOUNDS := ["1", "2", "3", "5"]

const HEROES := [
	{"id": "105004", "name": "伊卡洛斯", "job": "灵师", "camp": 4, "stars": 5, "spine": HERO_105004_SPINE, "power": "3027113", "level": "120/360", "attrs": ["攻击 120360", "生命 568420", "防御 42310", "速度 1785"], "target": Rect2(Vector2(330, 88), Vector2(430, 600))},
	{"id": "205008", "name": "苏拉", "job": "战士", "camp": 2, "stars": 5, "spine": HERO_SULA_SPINE, "power": "2864100", "level": "108/300", "attrs": ["攻击 104820", "生命 612500", "防御 48990", "速度 1620"], "target": Rect2(Vector2(330, 80), Vector2(430, 610)), "skins": ["2050081"]},
	{"id": "305006", "name": "尤朵拉", "job": "射手", "camp": 1, "stars": 5, "spine": HERO_YOUDUOLA_SPINE, "power": "2719800", "level": "104/300", "attrs": ["攻击 132500", "生命 438200", "防御 36210", "速度 1915"], "target": Rect2(Vector2(330, 80), Vector2(430, 610))},
	{"id": "405007", "name": "拉瑞欧", "job": "守护", "camp": 3, "stars": 5, "power": "2339000", "level": "96/260", "attrs": ["攻击 82420", "生命 690000", "防御 62410", "速度 1210"], "skins": ["4050071"]},
	{"id": "505004", "name": "诺萨", "job": "刺客", "camp": 5, "stars": 5, "power": "2188000", "level": "92/260", "attrs": ["攻击 96800", "生命 402600", "防御 34200", "速度 1840"], "skins": ["5050041"]},
	{"id": "204002", "name": "艾琳", "job": "辅助", "camp": 1, "stars": 5, "power": "2013000", "level": "88/240", "attrs": ["攻击 68400", "生命 520800", "防御 41800", "速度 1505"]},
	{"id": "104002", "name": "莉莉", "job": "法师", "camp": 2, "stars": 5, "power": "1884000", "level": "84/240", "attrs": ["攻击 91200", "生命 376000", "防御 30200", "速度 1710"]},
	{"id": "504002", "name": "奥斯曼", "job": "守护", "camp": 5, "stars": 3, "power": "1722000", "level": "80/220", "attrs": ["攻击 63400", "生命 602000", "防御 55200", "速度 1180"]},
	{"id": "304001", "name": "米莉娅", "job": "射手", "camp": 3, "stars": 3, "power": "1699000", "level": "78/220", "attrs": ["攻击 84600", "生命 336000", "防御 28800", "速度 1765"]},
	{"id": "204001", "name": "阿瓦隆", "job": "战士", "camp": 1, "stars": 3, "power": "1586000", "level": "76/220", "attrs": ["攻击 74200", "生命 468000", "防御 39200", "速度 1450"]},
]

var design_root: Control
var hero_layer: Control
var hero_spine: Node2D
var hero_image: TextureRect
var power_label: Label
var top_bar: HBoxContainer
var title_label: Label
var detail_panel: Control
var detail_frame: TextureRect
var equipment_panel: Control
var tab_panel: Control
var side_panel: Control
var head_list: VBoxContainer
var voice_player: AudioStreamPlayer
var full_preview_exit_button: Button
var tab_buttons: Array[Button] = []
var prev_button: Button
var next_button: Button
var star_success_overlay: Control
var local_notice_overlay: Control
var local_notice_label: Label
var left_info_actions: Array[Button] = []
var quality_text_label: Label
var named_resources: Dictionary = {}
var main_layout_nodes: Dictionary = {}
var book_layout_nodes: Dictionary = {}
var main_layout_node_list: Array = []
var book_layout_node_list: Array = []
var voice_index: Dictionary = {}
var hero_spine_index: Dictionary = {}
var hero_catalog: Array = []
var selected_hero := 0
var selected_tab := 0
var selected_animation := 0
var selected_skin := 0
var equipped_skin_by_hero: Dictionary = {}
var voice_cursor := 0
var full_preview := false
var detail_mode := "main"

func _ready() -> void:
	_load_named_resources()
	main_layout_nodes = _load_layout_index(HERO_MAIN_LAYOUT_PATH)
	book_layout_nodes = _load_layout_index(HERO_BOOK_LAYOUT_PATH)
	main_layout_node_list = _load_layout_nodes(HERO_MAIN_LAYOUT_PATH)
	book_layout_node_list = _load_layout_nodes(HERO_BOOK_LAYOUT_PATH)
	_load_voice_index()
	_load_hero_spine_index()
	_load_hero_catalog()
	_build_ui()
	_apply_navigation_args()
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
	bg.modulate = Color(0.82, 0.88, 1.0, 0.74)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.36)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	_build_prefab_chrome()

	voice_player = AudioStreamPlayer.new()
	add_child(voice_player)

	_build_top_bar()
	_build_side_panel()
	_build_hero_stage()
	_build_power_strip()
	_build_equipment_panel()
	_build_tabs()
	_build_detail_panel()
	_build_bottom_nav()
	_build_star_success_overlay()
	_build_local_notice_overlay()
	_build_full_preview_exit()
	_layout_design_root()
	_apply_hero()
	_refresh_all()

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top_bar = top
	top.anchor_left = 0.0
	top.anchor_right = 0.0
	top.offset_left = 186
	top.offset_top = 12
	top.offset_right = 438
	top.offset_bottom = 42
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	add_child(top)

	title_label = Label.new()
	title_label.text = ""
	title_label.visible = false
	title_label.custom_minimum_size = Vector2.ZERO
	top.add_child(title_label)
	Navigation.add_buttons(top)
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄详情"}))
	_add_top_button(top, "Spine", func(): Navigation.go(SPINE_VIEWER))

func _build_prefab_chrome() -> void:
	var top_band := ColorRect.new()
	top_band.position = Vector2(0, 0)
	top_band.size = Vector2(DESIGN_SIZE.x, 58)
	top_band.color = Color(0.015, 0.018, 0.03, 0.34)
	top_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(top_band)

	var bottom_band := ColorRect.new()
	bottom_band.position = Vector2(0, 621)
	bottom_band.size = Vector2(DESIGN_SIZE.x, 99)
	bottom_band.color = Color(0.015, 0.018, 0.03, 0.42)
	bottom_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bottom_band)

	var side_split := ColorRect.new()
	side_split.position = Vector2(1004, 0)
	side_split.size = Vector2(2, DESIGN_SIZE.y)
	side_split.color = Color(0.88, 0.74, 0.43, 0.22)
	side_split.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(side_split)

	_add_resource_bar(Vector2(754, 12), "image/equipment/101", "2.25M")
	_add_resource_bar(Vector2(920, 12), "image/equipment/104", "102.70M")
	_add_resource_bar(Vector2(1090, 12), "image/equipment/102", "4579")

	var back := Button.new()
	back.text = "<"
	back.position = Vector2(46, 16)
	back.size = Vector2(54, 38)
	back.tooltip_text = "返回"
	back.pressed.connect(func(): Navigation.go(HOME_SCENE))
	design_root.add_child(back)

	var home := Button.new()
	home.text = ""
	home.position = Vector2(120, 16)
	home.size = Vector2(54, 38)
	home.tooltip_text = "主城"
	home.pressed.connect(func(): Navigation.go(HOME_SCENE))
	design_root.add_child(home)
	_add_sprite_frame_image(home, ATLAS_1F, Rect2i(787, 551, 152, 141), Vector2(8, -5), Vector2(42, 38))

func _add_resource_bar(position: Vector2, icon_path: String, text: String) -> void:
	var box := Control.new()
	box.position = position
	box.size = Vector2(144, 30)
	design_root.add_child(box)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.035, 0.04, 0.07, 0.80)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)
	_add_named_image_to(box, icon_path, Vector2(-4, -3), Vector2(38, 38))
	_add_label(box, text, Vector2(38, 3), Vector2(78, 24), 16, Color(0.95, 0.96, 1.0))
	_add_label(box, "+", Vector2(116, -1), Vector2(26, 28), 24, Color(1.0, 0.92, 0.58)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _build_side_panel() -> void:
	side_panel = Control.new()
	side_panel.position = Vector2.ZERO
	side_panel.size = DESIGN_SIZE
	design_root.add_child(side_panel)

	var name_bg := ColorRect.new()
	name_bg.position = Vector2(16, 76)
	name_bg.size = Vector2(220, 144)
	name_bg.color = Color(0.035, 0.04, 0.065, 0.76)
	name_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side_panel.add_child(name_bg)

	_add_named_image_to(side_panel, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(20.311, 77.206), Vector2(45, 57))
	_add_label(side_panel, "", Vector2(62, 86), Vector2(128, 28), 20, Color(1.0, 0.88, 0.52)).name = "hero_name"
	_add_label(side_panel, "", Vector2(62, 115), Vector2(118, 22), 15, Color(0.78, 0.86, 1.0)).name = "hero_job"
	var quality := TextureRect.new()
	quality.name = "quality_tag"
	quality.position = Vector2(22, 125)
	quality.size = Vector2(142, 70)
	quality.texture = _load_texture(HERO_BOOK_TAG_TEX)
	quality.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	quality.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	quality.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side_panel.add_child(quality)
	quality_text_label = _add_label(side_panel, "SSR", Vector2(26, 130), Vector2(126, 48), 38, Color(1.0, 0.72, 0.25))
	quality_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var action_positions := [Vector2(58, 314), Vector2(58, 372), Vector2(58, 430)]
	var action_icons := ["image/common/cm_btn_ShiZhuang", "image/common/cm_btn_PingLun", "image/common/cm_btn_FenXiang"]
	var action_tooltips := ["全屏预览", "评论", "分享/锁定"]
	var action_callbacks := [
		_toggle_full_preview,
		func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄评论"}),
		_show_share_menu
	]
	for i in 3:
		var icon := Button.new()
		icon.position = action_positions[i]
		icon.size = Vector2(42, 42)
		icon.text = ""
		icon.tooltip_text = action_tooltips[i]
		icon.add_theme_font_size_override("font_size", 12)
		icon.pressed.connect(action_callbacks[i])
		side_panel.add_child(icon)
		left_info_actions.append(icon)
		if _add_named_image_to(icon, action_icons[i], Vector2(4, 4), icon.size - Vector2(8, 8)) == null:
			var fallback := ColorRect.new()
			fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			fallback.color = Color(0.16, 0.18, 0.32, 0.58)
			fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.add_child(fallback)

	head_list = VBoxContainer.new()
	head_list.visible = false
	side_panel.add_child(head_list)

func _build_hero_stage() -> void:
	hero_layer = Control.new()
	hero_layer.position = Vector2.ZERO
	hero_layer.size = DESIGN_SIZE
	design_root.add_child(hero_layer)

	hero_image = TextureRect.new()
	hero_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_layer.add_child(hero_image)

	hero_spine = SimpleSpinePlayerScript.new()
	hero_layer.add_child(hero_spine)

	var hit := Button.new()
	hit.flat = true
	hit.text = ""
	hit.position = Vector2(248, 38)
	hit.size = Vector2(448, 612)
	hit.tooltip_text = "切换动作 / 播放语音"
	hit.pressed.connect(_on_hero_clicked)
	hero_layer.add_child(hit)

	prev_button = Button.new()
	prev_button.text = "<"
	prev_button.position = Vector2(120, 311)
	prev_button.size = Vector2(42, 78)
	prev_button.tooltip_text = "上一个英雄"
	prev_button.pressed.connect(_previous_hero)
	design_root.add_child(prev_button)

	next_button = Button.new()
	next_button.text = ">"
	next_button.position = Vector2(710, 311)
	next_button.size = Vector2(42, 78)
	next_button.tooltip_text = "下一个英雄"
	next_button.pressed.connect(_next_hero)
	design_root.add_child(next_button)

func _build_power_strip() -> void:
	var strip := ColorRect.new()
	strip.position = Vector2(235.823, 574.262)
	strip.size = Vector2(394, 38)
	strip.z_index = 45
	strip.color = Color(0.045, 0.04, 0.055, 0.82)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(strip)
	power_label = _add_label(design_root, "", Vector2(380.823, 576.262), Vector2(210, 34), 26, Color(1.0, 0.88, 0.54))
	power_label.z_index = 46

func _build_equipment_panel() -> void:
	equipment_panel = VBoxContainer.new()
	equipment_panel.position = Vector2(861.752, 97.361)
	equipment_panel.size = Vector2(82, 360)
	equipment_panel.z_index = 24
	equipment_panel.add_theme_constant_override("separation", 12)
	design_root.add_child(equipment_panel)
	var icons := ["yx_icon_zhuangbei0", "yx_icon_zhuangbei1", "yx_icon_zhuangbei2", "yx_icon_zhuangbei3"]
	for i in icons.size():
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(58, 58)
		equipment_panel.add_child(slot)
		var bg := ColorRect.new()
		bg.position = Vector2(0, 0)
		bg.size = Vector2(58, 58)
		bg.color = Color(0.03, 0.04, 0.065, 0.72)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(bg)
		_add_named_image_to(slot, "image/en/HeroPanel/%s" % icons[i], Vector2(8, 8), Vector2(42, 42))
		_add_label(slot, str([3, 3, 2, 2][i]), Vector2(38, 30), Vector2(18, 20), 15, Color(1.0, 0.88, 0.50)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_tabs() -> void:
	tab_panel = VBoxContainer.new()
	tab_panel.position = Vector2(1178, 65)
	tab_panel.size = Vector2(88, 500)
	tab_panel.z_index = 30
	tab_panel.add_theme_constant_override("separation", 14)
	design_root.add_child(tab_panel)
	for label in ["培养", "装备", "升星", "战意", "衣装"]:
		var index := tab_panel.get_child_count()
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(88, 84)
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_select_tab.bind(index))
		tab_panel.add_child(button)
		tab_buttons.append(button)

func _build_detail_panel() -> void:
	detail_panel = Control.new()
	detail_panel.position = Vector2(797, 86)
	detail_panel.size = Vector2(404, 527)
	detail_panel.z_index = 20
	design_root.add_child(detail_panel)

	var frame_bg := _add_named_image_to(detail_panel, "image/en/HeroPanel/yx_frame_BaiBan", Vector2.ZERO, detail_panel.size)
	if frame_bg:
		frame_bg.name = "panel_frame"
		detail_frame = frame_bg
	var shade := ColorRect.new()
	shade.name = "panel_bg"
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.055, 0.055, 0.065, 0.54)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_panel.add_child(shade)

func _build_bottom_nav() -> void:
	var nav := Control.new()
	nav.position = Vector2.ZERO
	nav.size = DESIGN_SIZE
	nav.z_index = 35
	design_root.add_child(nav)
	var bg := TextureRect.new()
	bg.position = Vector2(-493, 540.552)
	bg.size = Vector2(2266, 181)
	bg.texture = _load_texture(NAV_BG_TEXTURE)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.modulate = Color(1, 1, 1, 0.78)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nav.add_child(bg)
	var items := [
		{"label": "城镇", "atlas": ATLAS_1F, "rect": Rect2i(787, 551, 152, 141), "screen": Rect2(Vector2(115.645, 585.329), Vector2(152, 141)), "hit": Rect2(Vector2(68.78, 532.771), Vector2(120, 120)), "scene": HOME_SCENE},
		{"label": "英雄", "atlas": ATLAS_1A, "rect": Rect2i(3, 334, 150, 142), "screen": Rect2(Vector2(284.102, 583.476), Vector2(150, 142)), "hit": Rect2(Vector2(239.581, 535.51), Vector2(120, 120)), "scene": ""},
		{"label": "召唤", "atlas": ATLAS_1A, "rect": NAV_SUMMON_RECT, "screen": Rect2(Vector2(481.599, 591.329), Vector2(125, 123)), "hit": Rect2(Vector2(416.306, 533.768), Vector2(120, 120)), "scene": "res://scenes/original_draw_card_panel.tscn"},
		{"label": "冒险", "atlas": ATLAS_1A, "rect": Rect2i(159, 345, 150, 145), "screen": Rect2(Vector2(645.211, 582.972), Vector2(150, 145)), "hit": Rect2(Vector2(603.78, 535.192), Vector2(120, 120)), "scene": ""},
		{"label": "副本", "atlas": ATLAS_1A, "rect": Rect2i(879, 276, 134, 133), "screen": Rect2(Vector2(842.368, 589.329), Vector2(134, 133)), "hit": Rect2(Vector2(789.342, 537.51), Vector2(120, 120)), "scene": ""},
		{"label": "公会", "atlas": ATLAS_1A, "rect": Rect2i(345, 232, 119, 126), "screen": Rect2(Vector2(1027.648, 592.829), Vector2(119, 126)), "hit": Rect2(Vector2(968.54, 539.026), Vector2(120, 120)), "scene": "", "rotated": true},
	]
	for i in items.size():
		var button := Button.new()
		button.text = ""
		var hit_rect: Rect2 = items[i].hit
		button.position = hit_rect.position
		button.size = hit_rect.size
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		if str(items[i].scene) != "":
			button.pressed.connect(func(path := str(items[i].scene)): Navigation.go(path))
		nav.add_child(button)
		var icon_rect: Rect2 = items[i].screen
		_add_sprite_frame_image(button, str(items[i].atlas), items[i].rect, icon_rect.position - hit_rect.position, icon_rect.size, bool(items[i].get("rotated", false)))
		var text := _add_label(button, str(items[i].label), Vector2((button.size.x - 44) * 0.5, 82), Vector2(44, 28), 18, Color(0.98, 0.93, 0.76))
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.add_theme_color_override("font_shadow_color", Color(0.12, 0.08, 0.02, 0.85))
		text.add_theme_constant_override("shadow_offset_x", 1)
		text.add_theme_constant_override("shadow_offset_y", 1)

func _build_full_preview_exit() -> void:
	full_preview_exit_button = Button.new()
	full_preview_exit_button.text = "返回"
	full_preview_exit_button.position = Vector2(1116, 24)
	full_preview_exit_button.size = Vector2(92, 42)
	full_preview_exit_button.z_index = 80
	full_preview_exit_button.visible = false
	full_preview_exit_button.pressed.connect(_toggle_full_preview)
	design_root.add_child(full_preview_exit_button)

func _build_star_success_overlay() -> void:
	star_success_overlay = Control.new()
	star_success_overlay.visible = false
	star_success_overlay.position = Vector2.ZERO
	star_success_overlay.size = DESIGN_SIZE
	star_success_overlay.z_index = 90
	design_root.add_child(star_success_overlay)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_success_overlay.add_child(dim)
	var close_area := Button.new()
	close_area.text = ""
	close_area.flat = true
	close_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	close_area.pressed.connect(_hide_star_success)
	star_success_overlay.add_child(close_area)
	var panel := Control.new()
	panel.name = "HeroUpgradeStarPrePreview"
	panel.position = Vector2.ZERO
	panel.size = DESIGN_SIZE
	star_success_overlay.add_child(panel)
	var content_bg := ColorRect.new()
	content_bg.position = Vector2(411.963, 266.733)
	content_bg.size = Vector2(483, 155)
	content_bg.color = Color(0.96, 0.93, 0.86, 0.94)
	content_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content_bg)
	var title := _add_label(panel, "升星成功", Vector2(564, 77.168), Vector2(144, 46), 30, Color(1.0, 0.80, 0.32))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_named_image_to(panel, "image/com/HeroPalace/yhd_image_jiantou", Vector2(527, 179.296), Vector2(226, 66))
	var rows := [
		["战力", "4371", "+50", "4842", 266.541],
		["生命", "419", "+40%", "501", 298.159],
		["攻击", "267", "+50%", "264", 330.159],
		["防御", "4561", "+20", "5789", 362.159],
		["速度", "665", "+321", "234", 394.159],
	]
	for row in rows:
		_add_label(panel, row[0], Vector2(456.578, row[4]), Vector2(52, 28), 18, Color(0.40, 0.42, 0.56))
		_add_label(panel, row[1], Vector2(596.526, row[4]), Vector2(58, 28), 18, Color(0.40, 0.42, 0.56))
		_add_label(panel, row[2], Vector2(666.041, row[4]), Vector2(72, 28), 18, Color(0.74, 0.32, 0.54))
		_add_label(panel, row[3], Vector2(763.028, row[4]), Vector2(66, 28), 18, Color(0.40, 0.42, 0.56))
	var skill_tip := _add_label(panel, "下列技能提升1级", Vector2(492.391, 411.629), Vector2(296, 50), 20, Color(0.55, 0.36, 0.18))
	skill_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var close := Button.new()
	close.text = "确定"
	close.position = Vector2(575, 486)
	close.size = Vector2(130, 44)
	close.pressed.connect(_hide_star_success)
	panel.add_child(close)

func _show_star_success() -> void:
	if star_success_overlay:
		star_success_overlay.visible = true

func _hide_star_success() -> void:
	if star_success_overlay:
		star_success_overlay.visible = false

func _build_local_notice_overlay() -> void:
	local_notice_overlay = Control.new()
	local_notice_overlay.visible = false
	local_notice_overlay.position = Vector2.ZERO
	local_notice_overlay.size = DESIGN_SIZE
	local_notice_overlay.z_index = 95
	local_notice_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(local_notice_overlay)
	var panel := ColorRect.new()
	panel.position = Vector2(402, 315)
	panel.size = Vector2(476, 72)
	panel.color = Color(0.035, 0.04, 0.065, 0.90)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	local_notice_overlay.add_child(panel)
	local_notice_label = _add_label(local_notice_overlay, "", Vector2(430, 335), Vector2(420, 34), 18, Color(0.96, 0.92, 0.76))
	local_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	local_notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _show_local_notice(text: String) -> void:
	if local_notice_overlay == null:
		return
	local_notice_label.text = text
	local_notice_overlay.visible = true
	get_tree().create_timer(1.4).timeout.connect(func():
		if local_notice_overlay:
			local_notice_overlay.visible = false
	)

func _show_share_menu() -> void:
	var menu := PopupPanel.new()
	menu.exclusive = false
	menu.size = Vector2(188, 178)
	var box := VBoxContainer.new()
	box.position = Vector2(12, 12)
	box.size = Vector2(164, 154)
	menu.add_child(box)
	var title := _add_label(box, "分享", Vector2.ZERO, Vector2(164, 26), 18, Color(0.95, 0.88, 0.62))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var items := [
		["跨服频道", "源码 kuaiFuShare -> CHAT_TYPE_MIDDLE"],
		["世界频道", "源码 worldShare -> CHAT_TYPE_WORLD"],
		["公会频道", "源码 gongHuiShare -> CHAT_TYPE_UNION"],
	]
	for item in items:
		var btn := Button.new()
		btn.text = item[0]
		btn.custom_minimum_size = Vector2(164, 34)
		btn.pressed.connect(func(message := str(item[1]), popup := menu):
			popup.queue_free()
			_show_local_notice(message)
		)
		box.add_child(btn)
	design_root.add_child(menu)
	menu.popup(Rect2(Vector2(98, 318), menu.size))

func _select_hero(index: int) -> void:
	selected_hero = index
	selected_animation = 0
	selected_skin = 0
	_refresh_all()

func _select_tab(index: int) -> void:
	if detail_mode == "book":
		index = 1 if index == 4 else clampi(index, 0, 1)
	selected_tab = index
	if selected_tab != 4:
		selected_skin = 0
	_refresh_all()

func _previous_hero() -> void:
	selected_hero = wrapi(selected_hero - 1, 0, _all_heroes().size())
	selected_animation = 0
	selected_skin = 0
	_refresh_all()

func _next_hero() -> void:
	selected_hero = wrapi(selected_hero + 1, 0, _all_heroes().size())
	selected_animation = 0
	selected_skin = 0
	_refresh_all()

func _refresh_all() -> void:
	_apply_mode_layout()
	_apply_hero()
	_refresh_side_panel()
	_refresh_tabs()
	_refresh_detail()

func _apply_mode_layout() -> void:
	var pre_rect := _mode_layout_rect("btnPre", Rect2(Vector2(119.5, 311.0), Vector2(41.0, 78.0)))
	var next_rect := _mode_layout_rect("btnNext", Rect2(Vector2(710.5, 311.0), Vector2(41.0, 78.0)))
	var power_rect := _mode_layout_rect("ft_zhanli", Rect2(Vector2(380.823, 579.262), Vector2(104.17, 40.0)))
	if prev_button:
		prev_button.position = pre_rect.position
		prev_button.size = pre_rect.size
	if next_button:
		next_button.position = next_rect.position
		next_button.size = next_rect.size
	if power_label:
		power_label.position = power_rect.position
		power_label.size = power_rect.size + Vector2(90, 0)

func _apply_hero() -> void:
	var hero: Dictionary = _current_hero()
	var body_id := _preview_body_id(hero)
	title_label.text = "%s | %s | %s | body %s" % [_source_prefab_name(), hero.get("name", hero.get("id", "")), _current_animation_name(hero), body_id]
	var spine_path := _spine_path_for_body(body_id, hero)
	if spine_path != "" and body_id == str(hero.get("id", "")):
		hero_image.visible = false
		hero_spine.visible = true
		if hero_spine.load_spine(spine_path, _current_animation_name(hero)):
			_fit_spine(hero)
	else:
		hero_spine.visible = false
		hero_image.visible = true
		var texture := _texture_for_body(body_id)
		hero_image.texture = texture
		if full_preview:
			hero_image.position = Vector2(314, 24)
			hero_image.size = Vector2(650, 670)
		else:
			hero_image.position = Vector2(276, 64)
			hero_image.size = Vector2(452, 590)

func _on_hero_clicked() -> void:
	_cycle_animation()
	var sound_id := str(HERO_TOUCH_SOUNDS[voice_cursor % HERO_TOUCH_SOUNDS.size()])
	voice_cursor += 1
	_play_hero_voice(sound_id)

func _cycle_animation() -> void:
	var hero: Dictionary = _current_hero()
	if _spine_path_for_body(_current_body_id(hero), hero) == "":
		return
	var animations := _animation_names(hero)
	if animations.size() <= 1:
		return
	selected_animation = wrapi(selected_animation + 1, 0, animations.size())
	hero_spine.play(str(animations[selected_animation]))
	_fit_spine(hero)
	_refresh_all()

func _refresh_side_panel() -> void:
	if side_panel == null:
		return
	var hero: Dictionary = _current_hero()
	var name_label := side_panel.get_node_or_null("hero_name") as Label
	if name_label:
		var name_rect := _mode_layout_rect("lblHeroName", Rect2(Vector2(58.21, 82.272), Vector2(96.0, 30.24)))
		name_label.position = name_rect.position
		name_label.size = name_rect.size + Vector2(80, 0)
		name_label.text = str(hero.get("name", hero.get("id", "")))
	var job_label := side_panel.get_node_or_null("hero_job") as Label
	if job_label:
		var nickname_rect := _mode_nickname_rect()
		job_label.position = nickname_rect.position
		job_label.size = nickname_rect.size + Vector2(80, 0)
		job_label.text = str(hero.get("job", "未知"))
	if power_label:
		power_label.text = "⚡ %s" % hero.get("power", "0")
	if quality_text_label:
		quality_text_label.text = str(hero.get("quality", "SSR"))
	for child in side_panel.get_children():
		if child.name.begins_with("dynamic_star"):
			child.queue_free()
	for i in 5:
		var star_name := "image/comHeroGrid/cm_icon_XingXing1_1" if i < int(hero.get("stars", 5)) else "image/comHeroGrid/cm_icon_XingXing1"
		var star := _add_named_image_to(side_panel, star_name, Vector2(28 + i * 17, 182), Vector2(23, 24))
		if star:
			star.name = "dynamic_star_%d" % i
	for child in side_panel.get_children():
		if child.name == "dynamic_head":
			child.queue_free()
	var head_root := Control.new()
	head_root.name = "dynamic_head"
	head_root.position = Vector2.ZERO
	side_panel.add_child(head_root)
	var head_position := name_label.position - Vector2(37, -1) if name_label else Vector2(25, 83)
	_add_named_image_to(head_root, "image/head/%s" % hero.get("id", ""), head_position, Vector2(36, 36))
	_refresh_head_list()

func _refresh_head_list() -> void:
	if head_list == null:
		return
	for child in head_list.get_children():
		child.queue_free()
	var heroes := _all_heroes()
	for i in heroes.size():
		var hero: Dictionary = heroes[i]
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(64, 64)
		button.disabled = i == selected_hero
		button.pressed.connect(_select_hero.bind(i))
		head_list.add_child(button)
		_add_head_icon(button, hero, Vector2(2, 2), Vector2(60, 60))

func _refresh_tabs() -> void:
	var labels := _tab_labels()
	if detail_mode == "book":
		tab_panel.position = Vector2(608, 260)
		tab_panel.size = Vector2(64, 200)
		tab_panel.add_theme_constant_override("separation", 0)
	else:
		tab_panel.position = Vector2(608, 95.099)
		tab_panel.size = Vector2(64, 522)
		tab_panel.add_theme_constant_override("separation", 0)
	for i in tab_buttons.size():
		var button := tab_buttons[i]
		for child in button.get_children():
			child.queue_free()
		button.visible = i < labels.size()
		if not button.visible:
			continue
		var tab_size: Vector2 = Vector2(64, 100) if detail_mode == "book" else HERO_MAIN_TAB_SIZES[i]
		button.custom_minimum_size = tab_size
		button.disabled = i == selected_tab
		var tab_resource := "image/common/cm_tab2_on" if i == selected_tab else "image/common/cm_tab2_off"
		var tab_image := _add_named_image_to(button, tab_resource, Vector2.ZERO, tab_size)
		if tab_image != null:
			tab_image.stretch_mode = TextureRect.STRETCH_SCALE
		if i == selected_tab:
			if tab_image == null:
				_add_sprite_frame_image(button, HERO_TAB_ON_ATLAS, HERO_TAB_ON_RECT, Vector2.ZERO, tab_size, true, Vector2i(64, 100), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		elif tab_image == null:
			_add_sprite_frame_image(button, HERO_TAB_OFF_ATLAS, HERO_TAB_OFF_RECT, Vector2.ZERO, tab_size, false, Vector2i(57, 100), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		var label_rect := Rect2(Vector2(-28, 12), Vector2(120, 62)) if detail_mode == "book" else Rect2(Vector2(-70, 11), Vector2(200, 78))
		var tab_label := _add_label(button, labels[i], label_rect.position, label_rect.size, 18, Color(0.92, 0.9, 0.82))
		tab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tab_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _refresh_detail() -> void:
	_refresh_detail_background()
	for child in detail_panel.get_children():
		if child.name == "panel_bg" or child.name == "panel_frame":
			continue
		child.queue_free()
	var hero: Dictionary = _current_hero()
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if detail_mode == "book" and selected_tab == 0:
		var scroll_rect := _mode_layout_rect("scrollview", Rect2(Vector2(897.27, 177.157), Vector2(300, 420)))
		var local_scroll := Rect2(scroll_rect.position - detail_panel.position, scroll_rect.size)
		root.position = local_scroll.position
		root.size = local_scroll.size
		root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	elif detail_mode == "book":
		root.offset_left = 0
		root.offset_top = 0
		root.offset_right = 0
		root.offset_bottom = 0
	else:
		root.offset_left = 0
		root.offset_top = 0
		root.offset_right = 0
		root.offset_bottom = 0
	detail_panel.add_child(root)

	if detail_mode == "book":
		_add_detail_summary(root, hero, Vector2(0, 0), 292)
	elif selected_tab == 0:
		_add_hero_main_summary(root, hero)

	if detail_mode == "book":
		if selected_tab == 1:
			_add_skin_tab(root, 344)
		else:
			_add_book_info(root, hero, 318)
	elif selected_tab == 0:
		_add_culture_tab(root, hero, 442, true)
	elif selected_tab == 1:
		_add_equipment_tab(root)
	elif selected_tab == 2:
		_add_star_tab(root)
	elif selected_tab == 3:
		_add_will_tab(root)
	else:
		_add_skin_tab(root)

func _refresh_detail_background() -> void:
	if detail_frame == null:
		return
	var resource_path := "image/en/HeroPanel/yx_frame_BaiBan"
	if detail_mode == "main":
		match selected_tab:
			0:
				resource_path = "image/en/HeroPanel/yx_img_PeiYang"
			1:
				resource_path = "image/en/HeroPanel/yx_img_ZhuangBei"
			2:
				resource_path = "image/en/HeroPanel/yx_img_ShengXing"
			3:
				resource_path = "image/en/HeroPanel/yx_img_ZhanYi"
			4:
				resource_path = "image/en/HeroPanel/yx_skin_bg"
			_:
				resource_path = "image/en/HeroPanel/yx_frame_BaiBan"
	var texture := _texture_for_named_resource(resource_path)
	if texture != null:
		detail_frame.texture = texture
		detail_frame.stretch_mode = TextureRect.STRETCH_SCALE

func _add_detail_summary(root: Control, hero: Dictionary, position: Vector2, width: float) -> void:
	_add_label(root, str(hero.get("job", "灵师")), position + Vector2(18, 0), Vector2(width - 48, 30), 21, Color(0.28, 0.30, 0.45)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_label(root, "高输出  物理伤害", position + Vector2(0, 32), Vector2(width, 26), 16, Color(0.45, 0.48, 0.62)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var attrs: Array = hero.get("attrs", _generated_attrs(hero))
	for i in min(attrs.size(), 4):
		_add_label(root, str(attrs[i]), position + Vector2(0, 76 + i * 35), Vector2(width - 10, 28), 18, Color(0.42, 0.46, 0.64))
	_add_label(root, "品阶", position + Vector2(0, 238), Vector2(64, 24), 16, Color(0.45, 0.48, 0.62))
	for i in 6:
		var gem := ColorRect.new()
		gem.position = position + Vector2(62 + i * 20, 244)
		gem.size = Vector2(12, 12)
		gem.rotation = 0.785398
		gem.color = Color(0.72, 0.24, 0.62, 1.0) if i < int(hero.get("stars", 5)) else Color(0.72, 0.72, 0.78, 0.8)
		root.add_child(gem)
	_add_progress(root, position + Vector2(0, 304), Vector2(width - 2, 20), 1.0, "等级  %s" % hero.get("level", "1"))

func _add_hero_main_summary(root: Control, hero: Dictionary) -> void:
	_add_skill_column(root, Vector2(0, 90))
	_add_detail_summary(root, hero, Vector2(132, 20), 238)
	var detail_button := Button.new()
	detail_button.text = ""
	detail_button.position = Vector2(329, 202)
	detail_button.size = Vector2(54, 54)
	detail_button.tooltip_text = "属性详情"
	detail_button.pressed.connect(func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄属性详情"}))
	root.add_child(detail_button)
	_add_named_image_to(detail_button, "image/common/cm_btn_XiangQing", Vector2.ZERO, detail_button.size)

func _add_skill_column(root: Control, position: Vector2) -> void:
	var skill_icons := ["11021", "20931", "3010", "42031"]
	for i in skill_icons.size():
		var slot := Button.new()
		slot.text = ""
		slot.position = position + Vector2(0, i * 84.574)
		slot.size = Vector2(80, 72)
		slot.tooltip_text = "技能 %d" % (i + 1)
		slot.pressed.connect(func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄技能提示"}))
		root.add_child(slot)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.03, 0.035, 0.055, 0.66)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(bg)
		_add_named_image_to(slot, "image/common/cm_frame_JiNeng1", Vector2(3, 0), Vector2(64, 64))
		var icon := _add_named_image_to(slot, "image/skill/%s" % skill_icons[i], Vector2(9, 7), Vector2(50, 50))
		if icon:
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_add_label(slot, str([3, 3, 2, 2][i]), Vector2(48, 44), Vector2(22, 20), 14, Color(1.0, 0.9, 0.55)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_book_info(root: Control, hero: Dictionary, y_base := 126) -> void:
	_add_label(root, "图鉴详情", Vector2(0, y_base), Vector2(238, 28), 20, Color(0.42, 0.36, 0.16)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_label(root, "HeroBookDetailPanel", Vector2(0, y_base + 34), Vector2(238, 24), 15, Color(0.42, 0.46, 0.64)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_label(root, "图鉴单卡 / 单英雄查询入口", Vector2(0, y_base + 60), Vector2(238, 24), 15, Color(0.42, 0.46, 0.64)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_action_button(root, "全屏预览", Vector2(0, y_base + 108), Vector2(108, 38), _toggle_full_preview)
	_add_action_button(root, "评论", Vector2(122, y_base + 108), Vector2(108, 38), func(): _play_hero_voice("2"))

func _add_culture_tab(root: Control, hero: Dictionary, y_base := 126, source_layout := false) -> void:
	if source_layout:
		_add_label(root, "等级已达上限！！！", Vector2(112, y_base - 54), Vector2(275, 28), 18, Color(0.70, 0.46, 0.18)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_add_action_button(root, "升2级", Vector2(112, y_base), Vector2(275, 60), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄升级"}), "image/common/cm_btn_LvSe0")
		_add_action_button(root, "进阶", Vector2(112, y_base + 72), Vector2(132, 42), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄突破"}))
		_add_action_button(root, "重置", Vector2(255, y_base + 72), Vector2(132, 42), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄重置"}))
		return
	_add_label(root, "等级已达上限！！！", Vector2(0, y_base), Vector2(238, 28), 18, Color(0.70, 0.46, 0.18)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_action_button(root, "升2级", Vector2(6, y_base + 52), Vector2(102, 42), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄升级"}))
	_add_action_button(root, "进阶", Vector2(124, y_base + 52), Vector2(102, 42), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄突破"}))

func _detail_local(screen_position: Vector2) -> Vector2:
	return screen_position - detail_panel.position

func _add_equipment_tab(root: Control, y_base := 126) -> void:
	y_base = y_base
	var hero: Dictionary = _current_hero()
	var level_text := str(hero.get("level", "1")).split("/")[0]
	var hero_level := int(level_text)
	var hero_star := int(hero.get("stars", 5))
	var equips := [
		["武器", "yx_icon_zhuangbei0", Vector2(483.916, 157.163), "yx_frame_ZBHong"],
		["衣服", "yx_icon_zhuangbei1", Vector2(506.403, 260.246), "yx_frame_ZBCheng"],
		["护手", "yx_icon_zhuangbei2", Vector2(505.447, 365.441), "yx_frame_ZBLan"],
		["鞋子", "yx_icon_zhuangbei3", Vector2(483.827, 467.857), "yx_frame_ZBLv"],
		["纹章", "yx_icon_zhuangbei4", Vector2(588.697, 95.551), "yx_frame_ZBZi"],
		["神器", "yx_icon_zhuangbei5", Vector2(739.29, 96.919), "yx_frame_ZBHong"],
	]
	for i in equips.size():
		var pos := _detail_local(equips[i][2])
		var slot := Control.new()
		slot.position = pos
		slot.size = Vector2(94, 94)
		root.add_child(slot)
		var slot_hit := Button.new()
		slot_hit.text = ""
		slot_hit.flat = true
		slot_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var layout := "英雄装备替换"
		if i == 4:
			layout = "英雄水晶提示" if hero_level >= 40 else "英雄水晶获取"
		elif i == 5:
			layout = "英雄神器"
		slot_hit.pressed.connect(func(target_layout := layout): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": target_layout}))
		slot.add_child(slot_hit)
		var slot_bg := ColorRect.new()
		slot_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot_bg.color = Color(0.03, 0.035, 0.055, 0.72)
		slot_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(slot_bg)
		_add_named_image_to(slot, "image/en/HeroPanel/%s" % equips[i][3], Vector2(0, 0), slot.size)
		_add_named_image_to(slot, "image/en/HeroPanel/%s" % equips[i][1], Vector2(18, 18), Vector2(58, 58))
		var name_label := _add_label(slot, str(equips[i][0]), Vector2(0, 70), Vector2(94, 22), 15, Color(0.96, 0.90, 0.68))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if i < 4:
			_add_red_dot(slot, Vector2(68, 0))
		if i == 4 and hero_level < 40:
			_add_lock_overlay(slot, "40级")
		elif i == 5:
			_add_lock_overlay(slot, "敬请期待")
	var fuwen := [
		["符文", Vector2(667.622, 223.132), "100级解锁", hero_level >= 100],
		["神器", Vector2(667.622, 394.132), "七星解锁", hero_star >= 7],
	]
	for item in fuwen:
		var frame := Control.new()
		frame.position = _detail_local(item[1])
		frame.size = Vector2(88, 87)
		root.add_child(frame)
		var frame_hit := Button.new()
		frame_hit.text = ""
		frame_hit.flat = true
		frame_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame_hit.pressed.connect(func(unlocked := bool(item[3])): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "符文选择" if unlocked else "符文刷新"}))
		frame.add_child(frame_hit)
		_add_named_image_to(frame, "image/en/HeroPanel/yx_frame_ZBBai", Vector2.ZERO, frame.size)
		if bool(item[3]):
			_add_named_image_to(frame, "image/en/HeroPanel/yx_frame_JiNeng", Vector2(19, 18), Vector2(50, 50))
			_add_red_dot(frame, Vector2(62, 3))
		else:
			var title := _add_label(frame, "锁", Vector2(0, 18), Vector2(88, 28), 18, Color(0.75, 0.72, 0.82))
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var lock := _add_label(frame, str(item[2]), Vector2(-56, 92), Vector2(200, 26), 16, Color(0.72, 0.70, 0.78))
			lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var btn := _add_action_button(root, "一键穿戴", _detail_local(Vector2(609.622, 549.632)), Vector2(200, 60), func(): _show_local_notice("源码 btnQuickPut 走服务器，离线 Demo 已模拟穿戴"), "image/common/cm_btn_LvSe0")
	_add_red_dot(btn, Vector2(154, 2))

func _add_red_dot(parent: Control, position: Vector2) -> void:
	var dot := ColorRect.new()
	dot.position = position
	dot.size = Vector2(18, 18)
	dot.color = Color(0.86, 0.04, 0.10, 1.0)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(dot)
	var mark := _add_label(parent, "!", position - Vector2(1, 4), Vector2(20, 22), 14, Color.WHITE)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_lock_overlay(parent: Control, text: String) -> void:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.56)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(shade)
	var label := _add_label(parent, text, Vector2(0, 34), Vector2(parent.size.x, 24), 15, Color(0.90, 0.88, 0.78))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_star_tab(root: Control, y_base := 126) -> void:
	y_base = y_base
	var hero: Dictionary = _current_hero()
	var labels := [
		["等级上限", "+50", Vector2(568.115, 123.48), Vector2(667.453, 124.477)],
		["攻        击", "+40%", Vector2(582.312, 147.565), Vector2(685.859, 149.606)],
		["生       命", "+40%", Vector2(598.862, 173.228), Vector2(699.429, 174.233)],
	]
	for item in labels:
		_add_label(root, item[0], _detail_local(item[2]), Vector2(120, 26), 17, Color(0.42, 0.45, 0.62))
		_add_label(root, item[1], _detail_local(item[3]), Vector2(74, 26), 17, Color(0.70, 0.30, 0.52))
	var skill_tip := _add_label(root, "提升1级", _detail_local(Vector2(702.848, 233.291)), Vector2(100, 24), 16, Color(0.45, 0.48, 0.62))
	skill_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_named_image_to(root, "image/common/cm_frame_JiNeng1", _detail_local(Vector2(654.191, 344.174)), Vector2(30, 30))
	_add_label(root, "3", _detail_local(Vector2(677.728, 230.716)), Vector2(24, 30), 17, Color(0.95, 0.90, 0.64))
	_add_label(root, "当前星级", _detail_local(Vector2(410, 336)), Vector2(120, 26), 17, Color(0.42, 0.45, 0.62))
	_add_label(root, "%s  ->  %s" % [hero.get("stars", 5), int(hero.get("stars", 5)) + 1], _detail_local(Vector2(466, 366)), Vector2(160, 34), 25, Color(0.95, 0.82, 0.42))
	var material_data := [
		["heroBox1", Vector2(741.172, 501.184), "5星英雄\n(1/1)"],
		["heroBox2", Vector2(635.408, 502.814), "5星英雄\n(0/1)"],
		["heroBox3", Vector2(741.172, 369.755), "同阵营英雄\n(0/1)"],
		["heroBox4", Vector2(634.331, 369.781), "进阶材料\n(42/100)"],
	]
	var icon_positions := [
		Vector2(648, 405),
		Vector2(512, 405),
		Vector2(648, 230),
		Vector2(512, 230),
	]
	for i in material_data.size():
		var slot := Control.new()
		slot.position = _detail_local(icon_positions[i])
		slot.size = Vector2(74, 74)
		root.add_child(slot)
		if i < 3:
			_add_head_icon(slot, hero, Vector2.ZERO, Vector2(74, 74))
		else:
			_add_named_image_to(slot, "image/en/HeroPanel/yx_frame_JiNeng", Vector2.ZERO, Vector2(74, 74))
			_add_named_image_to(slot, "image/en/HeroPanel/yx_icon_zhuangbei4", Vector2(14, 14), Vector2(46, 46))
		var material_label := _add_label(root, material_data[i][2], _detail_local(material_data[i][1]), Vector2(92, 46), 16, Color(0.36, 0.34, 0.42))
		material_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		material_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_action_button(root, "英魂", _detail_local(Vector2(433.192, 537.997)), Vector2(130, 45), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英魂殿"}), "image/common/cm_btn_LvSe1")
	_add_action_button(root, "升星", _detail_local(Vector2(532.181, 548.426)), Vector2(292, 65), _show_star_success, "image/en/HeroPanel/yx_btn_ShengXing")

func _add_will_tab(root: Control, y_base := 126) -> void:
	y_base = y_base
	var hero: Dictionary = _current_hero()
	var star := int(hero.get("stars", 5))
	_add_named_image_to(root, "image/en/HeroPanel/yxzy_pic_ZhanYiDi", _detail_local(Vector2(506, 142)), Vector2(300, 360))
	var nodes := []
	if star < 13:
		nodes = [
			["战意一", Vector2(503.622, 325.047), Vector2(134, 134), 180.0, "9星解锁", Vector2(15, 24), Vector2(18, 83)],
			["战意二", Vector2(646.622, 185.632), Vector2(134, 134), 0.0, "10星解锁", Vector2(15, 3), Vector2(13, 81)],
		]
	else:
		nodes = [
			["战意一", Vector2(490.622, 303.632), Vector2(134, 134), 165.0, "9星解锁", Vector2(15, 24), Vector2(18, 83)],
			["战意二", Vector2(659.622, 304.632), Vector2(134, 134), -75.0, "10星解锁", Vector2(27, 15), Vector2(82, 12)],
			["战意三", Vector2(590.068, 154.132), Vector2(102, 166), 0.0, "13星解锁", Vector2(0, 21), Vector2(0, 97)],
		]
	for i in nodes.size():
		var item = nodes[i]
		var node := Control.new()
		node.position = _detail_local(item[1])
		node.size = item[2]
		node.rotation_degrees = item[3]
		root.add_child(node)
		var unlock_star := 9 + i
		var node_hit := Button.new()
		node_hit.text = ""
		node_hit.flat = true
		node_hit.tooltip_text = "战意"
		node_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		node_hit.pressed.connect(func(required_star := unlock_star, layout := "战意领悟"):
			if star < required_star:
				_show_local_notice("%d星解锁" % required_star)
			else:
				Navigation.go_with_args(PREFAB_PREVIEW, {"layout": layout})
		)
		node.add_child(node_hit)
		_add_named_image_to(node, "image/en/HeroPanel/yx_frame_ZhanYi", Vector2.ZERO, node.size)
		var head_box := Control.new()
		head_box.position = item[5]
		head_box.size = Vector2(72, 72)
		head_box.rotation_degrees = -node.rotation_degrees
		node.add_child(head_box)
		_add_head_icon(head_box, hero, Vector2.ZERO, Vector2(72, 72))
		var name_label := _add_label(node, str(item[0]), item[6], Vector2(86, 24), 16, Color(0.98, 0.91, 0.64))
		name_label.rotation_degrees = -node.rotation_degrees
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var lock_label := _add_label(node, item[4], Vector2(-8, node.size.y - 30), Vector2(node.size.x + 28, 24), 15, Color(0.78, 0.76, 0.86))
		lock_label.rotation_degrees = -node.rotation_degrees
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_action_button(root, "战意预览", _detail_local(Vector2(497.613, 547.874)), Vector2(300, 60), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "战意预览"}), "image/common/cm_btn_LvSe0")
	_add_action_button(root, "战意升级", _detail_local(Vector2(664.613, 547.874)), Vector2(132, 48), func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "战意升级"}), "image/common/cm_btn_LvSe1")
	_add_action_button(root, "?", _detail_local(Vector2(768.66, 107.244)), Vector2(54, 54), func(): _show_local_notice("源码 HelpManeger.HELP_MISC_58：战意规则帮助"))

func _add_skin_tab(root: Control, y_base := 126) -> void:
	y_base = y_base
	var hero: Dictionary = _current_hero()
	var skins := _skin_body_ids(hero)
	var body_id := _current_body_id(hero)
	if skins.size() <= 1 and _texture_for_named_resource("image/skin/showImg/%s" % body_id) == null:
		var no_skin_rect := _skin_layout_rect("noSkin", Rect2(Vector2(920.292, 292.112), Vector2(160, 50.4)))
		var no_skin := _add_label(root, "敬请期待", _detail_local(no_skin_rect.position), no_skin_rect.size, 18, Color(0.56, 0.57, 0.68))
		no_skin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_skin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		return
	var skin_img_rect := _skin_layout_rect("skinImg", Rect2(Vector2(863.775, 95.155), Vector2(169, 360)))
	var skin_image := _add_named_image_to(root, "image/skin/showImg/%s" % body_id, _detail_local(skin_img_rect.position), skin_img_rect.size)
	if skin_image:
		skin_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var name_rect := _skin_layout_rect("skinName", Rect2(Vector2(858, 386), Vector2(184, 32)))
	var name_label := _add_label(root, "%s  %s" % [hero.get("name", hero.get("id", "")), body_id], _detail_local(name_rect.position), name_rect.size, 20, Color(0.45, 0.36, 0.18))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var attrs := [
		["攻击:", "+100"],
		["生命:", "+1500"],
		["防御:", "+80"],
		["速度:", "+12"],
	]
	var attr_positions := [
		Vector2(802.221, 469.77),
		Vector2(1007.809, 469.77),
		Vector2(802.221, 499.77),
		Vector2(1007.809, 499.77),
	]
	for i in attrs.size():
		var pos := _detail_local(attr_positions[i])
		_add_label(root, attrs[i][0], pos, Vector2(72, 26), 16, Color(0.45, 0.48, 0.62))
		_add_label(root, attrs[i][1], pos + Vector2(72, 0), Vector2(58, 26), 16, Color(0.74, 0.34, 0.56))
	var equipped_skin := str(equipped_skin_by_hero.get(str(hero.get("id", "")), str(hero.get("id", ""))))
	var primary_text := "前往获取"
	var primary_button_name := "getBtn"
	var primary_action := func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "皮肤商店"})
	if selected_skin > 0:
		if body_id == equipped_skin:
			primary_text = "卸下衣装"
			primary_button_name = "takeBtn"
			primary_action = func(): _take_off_skin()
		else:
			primary_text = "穿戴衣装"
			primary_button_name = "wearBtn"
			primary_action = func(): _wear_current_skin()
	var primary_rect := _skin_layout_rect(primary_button_name, Rect2(Vector2(881.292, 537.333), Vector2(238, 66)))
	_add_action_button(root, primary_text, _detail_local(primary_rect.position), primary_rect.size, primary_action, "image/common/cm_btn_LvSe0")
	var play_rect := _skin_layout_rect("playBtn", Rect2(Vector2(1008.432, 90.563), Vector2(38, 38)))
	_add_action_button(root, "展示", _detail_local(play_rect.position), play_rect.size, _preview_current_skin)
	var next_rect := _skin_layout_rect("skinNext", Rect2(Vector2(1124.513, 309), Vector2(41, 78)))
	_add_action_button(root, ">", _detail_local(next_rect.position), next_rect.size, _next_skin)

func _add_progress(parent: Control, position: Vector2, size: Vector2, value: float, text: String) -> void:
	var bg := ColorRect.new()
	bg.position = position
	bg.size = size
	bg.color = Color(0.03, 0.04, 0.07, 0.86)
	parent.add_child(bg)
	var fill := ColorRect.new()
	fill.position = position + Vector2(2, 2)
	fill.size = Vector2((size.x - 4) * clampf(value, 0.0, 1.0), size.y - 4)
	fill.color = Color(0.95, 0.62, 0.12, 1.0)
	parent.add_child(fill)
	_add_label(parent, text, position + Vector2(0, -28), Vector2(size.x, 24), 16, Color(0.96, 0.9, 0.68))

func _add_action_button(parent: Control, text: String, position: Vector2, size: Vector2, callback := Callable(), image_path := "image/common/cm_btn_LvSe1") -> Button:
	var button := Button.new()
	button.text = ""
	button.position = position
	button.size = size
	if callback.is_valid():
		button.pressed.connect(callback)
	parent.add_child(button)
	_add_named_image_to(button, image_path, Vector2.ZERO, size)
	_add_label(button, text, Vector2.ZERO, size, 18, Color(0.95, 1.0, 0.92)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

func _add_head_icon(parent: Control, hero: Dictionary, position: Vector2, size: Vector2) -> void:
	_add_named_image_to(parent, "image/comHeroGrid/cm_frame_TouXiangDi5", position, size)
	_add_named_image_to(parent, "image/head/%s" % hero.get("id", ""), position + Vector2(8, 8), size - Vector2(16, 16))
	_add_named_image_to(parent, "image/comHeroGrid/cm_tag_SSR1", position, Vector2(34, 22))

func _add_named_image_to(parent: Control, resource_name: String, position: Vector2, size: Vector2) -> TextureRect:
	var texture := _texture_for_named_resource(resource_name)
	if texture == null:
		return null
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _add_sprite_frame_image(parent: Control, atlas_path: String, rect: Rect2i, position: Vector2, size: Vector2, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _load_texture_region(atlas_path, rect, rotated, original_size, offset)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _texture_for_named_resource(resource_name: String) -> Texture2D:
	var entry: Dictionary = named_resources.get(resource_name, {})
	if entry.is_empty():
		return null
	var native_path := "res://" + str(entry.get("native_path", entry.get("texture_path", "")))
	var rect_arr: Array = entry.get("rect", [])
	if rect_arr.is_empty():
		rect_arr = entry.get("sprite_rect", [])
	var rotated := bool(entry.get("rotated", false))
	if entry.has("sprite_rotated"):
		rotated = bool(entry.get("sprite_rotated", false))
	var original_size := _arr_to_vec2i(entry.get("original_size", []))
	if original_size == Vector2i.ZERO:
		original_size = _arr_to_vec2i(entry.get("sprite_original_size", []))
	var offset := _arr_to_vec2(entry.get("offset", []))
	if offset == Vector2.ZERO:
		offset = _arr_to_vec2(entry.get("sprite_offset", []))
	if rect_arr.size() == 4:
		return _load_texture_region(native_path, Rect2i(int(rect_arr[0]), int(rect_arr[1]), int(rect_arr[2]), int(rect_arr[3])), rotated, original_size, offset)
	return _load_texture(native_path)

func _load_named_resources() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/named_resource_index.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		named_resources = parsed

func _load_voice_index() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_VOICE_INDEX_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		voice_index = parsed

func _load_hero_spine_index() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_SPINE_INDEX_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		hero_spine_index = parsed.get("heroes", {})

func _load_hero_catalog() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_CATALOG_PATH))
	if typeof(parsed) != TYPE_ARRAY:
		return
	var known_by_id := {}
	for hero in HEROES:
		known_by_id[str(hero.get("id", ""))] = hero
	hero_catalog.clear()
	for item in parsed:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var hero: Dictionary = item.duplicate(true)
		var known: Dictionary = known_by_id.get(str(hero.get("id", "")), {})
		for key in known.keys():
			hero[key] = known[key]
		if not hero.has("attrs"):
			hero["attrs"] = _generated_attrs(hero)
		hero_catalog.append(hero)

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _load_layout_index(path: String) -> Dictionary:
	var index := {}
	if not FileAccess.file_exists(path):
		return index
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return index
	for node in parsed.get("nodes", []):
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var name := str(node.get("name", ""))
		if name != "" and not index.has(name):
			index[name] = node
	return index

func _load_layout_nodes(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	var nodes: Array = parsed.get("nodes", [])
	return nodes

func _mode_layout_rect(name: String, fallback: Rect2) -> Rect2:
	var source := book_layout_nodes if detail_mode == "book" else main_layout_nodes
	return _layout_rect_from(source, name, fallback)

func _mode_nickname_rect() -> Rect2:
	if detail_mode == "book":
		return _layout_rect_from(book_layout_nodes, "lblNickname", Rect2(Vector2(61.311, 108.366), Vector2(72.0, 22.68)))
	return _layout_rect_from(main_layout_nodes, "lblNickName", Rect2(Vector2(58.21, 108.679), Vector2(72.0, 22.68)))

func _hero_display_target(hero: Dictionary) -> Rect2:
	if detail_mode == "main":
		var skin_rect := _layout_rect_from(main_layout_nodes, "skinBodyBox", Rect2())
		if skin_rect.size.x > 0.0 and skin_rect.size.y > 0.0:
			return Rect2(skin_rect.position + Vector2(20, 20), skin_rect.size - Vector2(40, 40))
	if hero.has("target"):
		return hero.get("target", Rect2(Vector2(252, 34), Vector2(526, 626)))
	return Rect2(Vector2(252, 34), Vector2(526, 626))

func _skin_layout_rect(name: String, fallback: Rect2) -> Rect2:
	var source := book_layout_nodes if detail_mode == "book" else main_layout_nodes
	var nodes := book_layout_node_list if detail_mode == "book" else main_layout_node_list
	match name:
		"skinName":
			var name_fallback := Rect2(Vector2(946.571, 393.911), Vector2(184, 30.0)) if detail_mode == "book" else Rect2(Vector2(948.594, 389.185), Vector2(184, 30.24))
			return _layout_rect_by_parent(nodes, "name", 11 if detail_mode == "book" else 7, name_fallback)
		"skinNext":
			return _layout_rect_by_parent(nodes, "btnNext", 7 if detail_mode == "book" else 37, fallback)
		_:
			return _layout_rect_from(source, name, fallback)

func _layout_rect_by_parent(nodes: Array, name: String, parent_index: int, fallback: Rect2) -> Rect2:
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		if str(node.get("name", "")) != name or int(node.get("parent_index", -9999)) != parent_index:
			continue
		var rect: Array = node.get("screen_rect", [])
		if rect.size() >= 4:
			return Rect2(Vector2(float(rect[0]), float(rect[1])), Vector2(float(rect[2]), float(rect[3])))
	return fallback

func _layout_rect_from(source: Dictionary, name: String, fallback: Rect2) -> Rect2:
	if not source.has(name):
		return fallback
	var node: Dictionary = source[name]
	var rect: Array = node.get("screen_rect", [])
	if rect.size() >= 4:
		return Rect2(Vector2(float(rect[0]), float(rect[1])), Vector2(float(rect[2]), float(rect[3])))
	return fallback

func _fit_spine(hero: Dictionary) -> void:
	hero_spine.update_preview_pose(0.0)
	var bounds: Rect2 = hero_spine.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var target := _hero_display_target(hero)
	if full_preview:
		target = Rect2(Vector2(300, 28), Vector2(680, 660))
	var scale_value: float = min(target.size.x / bounds.size.x, target.size.y / bounds.size.y)
	hero_spine.scale = Vector2(scale_value, scale_value)
	var bounds_center := bounds.position + bounds.size * 0.5
	var target_center := target.position + target.size * 0.5
	hero_spine.position = target_center - bounds_center * scale_value

func _texture_for_body(body_id: String) -> Texture2D:
	var texture := _texture_for_named_resource("image/skin/showImg/%s" % body_id)
	if texture == null:
		texture = _texture_for_named_resource("image/heroBook/%s" % body_id)
	if texture == null:
		texture = _texture_for_named_resource("image/head/%s" % body_id)
	return texture

func _skin_body_ids(hero: Dictionary) -> Array[String]:
	var ids: Array[String] = [str(hero.get("id", ""))]
	for skin in hero.get("skins", []):
		var skin_id := str(skin)
		if skin_id != ids[0] and not ids.has(skin_id):
			ids.append(skin_id)
	return ids

func _current_body_id(hero: Dictionary) -> String:
	var skins := _skin_body_ids(hero)
	selected_skin = clampi(selected_skin, 0, max(skins.size() - 1, 0))
	return skins[selected_skin]

func _preview_body_id(hero: Dictionary) -> String:
	if selected_tab == 4:
		return _current_body_id(hero)
	return str(equipped_skin_by_hero.get(str(hero.get("id", "")), str(hero.get("id", ""))))

func _next_skin() -> void:
	var skins := _skin_body_ids(_current_hero())
	selected_skin = wrapi(selected_skin + 1, 0, max(skins.size(), 1))
	_refresh_all()

func _preview_current_skin() -> void:
	var hero := _current_hero()
	var body_id := _current_body_id(hero)
	Navigation.go_with_args("res://scenes/original_draw_hero_show.tscn", {
		"hero_id": str(hero.get("id", "")),
		"skin_body": body_id,
		"source": "hero_skin",
	})

func _wear_current_skin() -> void:
	var hero := _current_hero()
	var body_id := _current_body_id(hero)
	equipped_skin_by_hero[str(hero.get("id", ""))] = body_id
	_show_local_notice("源码 wearSkin -> CG_SKIN_ON：已本地穿戴 %s" % body_id)
	_refresh_all()

func _take_off_skin() -> void:
	var hero := _current_hero()
	equipped_skin_by_hero[str(hero.get("id", ""))] = str(hero.get("id", ""))
	_show_local_notice("源码 takeSkin -> CG_SKIN_OFF：已本地卸下衣装")
	_refresh_all()

func _toggle_full_preview() -> void:
	full_preview = not full_preview
	if top_bar:
		top_bar.visible = not full_preview
	if side_panel:
		side_panel.visible = not full_preview
	if tab_panel:
		tab_panel.visible = not full_preview
	if detail_panel:
		detail_panel.visible = not full_preview
	if equipment_panel:
		equipment_panel.visible = not full_preview
	if prev_button:
		prev_button.visible = not full_preview
	if next_button:
		next_button.visible = not full_preview
	if full_preview_exit_button:
		full_preview_exit_button.visible = full_preview
	_apply_hero()

func _play_hero_voice(sound_id: String) -> void:
	var hero_id := str(_current_hero().get("id", ""))
	var hero_voice: Dictionary = voice_index.get(hero_id, {})
	var entry: Dictionary = hero_voice.get(sound_id, {})
	if entry.is_empty():
		return
	var path := str(entry.get("path", ""))
	AudioUtils.play_mp3(voice_player, path)

func _current_animation_name(hero: Dictionary) -> String:
	var animations := _animation_names(hero)
	if animations.is_empty():
		return "idle"
	selected_animation = clampi(selected_animation, 0, animations.size() - 1)
	return str(animations[selected_animation])

func _animation_names(hero: Dictionary) -> Array:
	var path := _spine_path_for_body(str(hero.get("id", "")), hero)
	if path == "":
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return ["idle"]
	var skeleton: Dictionary = parsed.get("skeleton", {})
	var animation_dict: Dictionary = skeleton.get("animations", {})
	var names := animation_dict.keys()
	names.sort()
	if names.has("idle"):
		names.erase("idle")
		names.push_front("idle")
	return names

func _spine_path_for_body(body_id: String, hero: Dictionary) -> String:
	if body_id == str(hero.get("id", "")) and hero.has("spine"):
		return str(hero.get("spine", ""))
	var entry: Dictionary = hero_spine_index.get(body_id, {})
	return str(entry.get("runtime", ""))

func _apply_cmdline_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var mode_arg := _cmd_arg_value(args, "--hero-mode")
	if mode_arg in ["main", "book"]:
		detail_mode = mode_arg
	var hero_arg := _cmd_arg_value(args, "--hero-index")
	if hero_arg.is_valid_int():
		selected_hero = clampi(int(hero_arg), 0, _all_heroes().size() - 1)
	var hero_id := _cmd_arg_value(args, "--hero-id")
	if hero_id != "":
		_select_hero_id(hero_id)
	var tab_arg := _cmd_arg_value(args, "--hero-tab")
	if tab_arg.is_valid_int():
		selected_tab = clampi(int(tab_arg), 0, 4)
	var skin_arg := _cmd_arg_value(args, "--skin-body")
	if skin_arg != "":
		_select_skin_body(skin_arg)
	_refresh_all()
	if "--hero-full-preview" in args:
		call_deferred("_toggle_full_preview")
	if "--hero-click-once" in args:
		call_deferred("_on_hero_clicked")

func _apply_navigation_args() -> void:
	var scene_args := Navigation.consume_scene_args()
	var mode := str(scene_args.get("mode", ""))
	if mode in ["main", "book"]:
		detail_mode = mode
	var hero_id := str(scene_args.get("hero_id", ""))
	if hero_id == "":
		return
	var heroes := _all_heroes()
	for i in heroes.size():
		if str(heroes[i].get("id", "")) == hero_id:
			_select_hero(i)
			var tab_value: Variant = scene_args.get("tab", null)
			if tab_value != null:
				selected_tab = clampi(int(tab_value), 0, 4)
			var skin_body := str(scene_args.get("skin_body", ""))
			if skin_body != "":
				_select_skin_body(skin_body)
			_refresh_all()
			return

func _select_skin_body(body_id: String) -> void:
	var skins := _skin_body_ids(_current_hero())
	var index := skins.find(body_id)
	if index >= 0:
		selected_tab = 4
		selected_skin = index

func _select_hero_id(hero_id: String) -> void:
	var heroes := _all_heroes()
	for i in heroes.size():
		if str(heroes[i].get("id", "")) == hero_id:
			selected_hero = i
			selected_animation = 0
			return

func _all_heroes() -> Array:
	var source: Array = HEROES if hero_catalog.is_empty() else hero_catalog
	if hero_spine_index.is_empty():
		return source
	var result := []
	for hero in source:
		if _has_spine_runtime(str(hero.get("id", ""))):
			result.append(hero)
	return result

func _current_hero() -> Dictionary:
	var heroes := _all_heroes()
	if heroes.is_empty():
		return {}
	selected_hero = clampi(selected_hero, 0, heroes.size() - 1)
	return heroes[selected_hero]

func _source_prefab_name() -> String:
	return "HeroBookDetailPre" if detail_mode == "book" else "HeroMainPre"

func _tab_labels() -> Array[String]:
	if detail_mode == "book":
		return ["档案", "衣装"]
	return ["培养", "装备", "升星", "战意", "衣装"]

func _has_spine_runtime(body_id: String) -> bool:
	return typeof(hero_spine_index.get(body_id, null)) == TYPE_DICTIONARY

func _generated_attrs(hero: Dictionary) -> Array:
	var power := int(str(hero.get("power", "600000")))
	return [
		"攻击 %d" % max(1000, int(power / 25)),
		"生命 %d" % max(10000, int(power / 5)),
		"防御 %d" % max(500, int(power / 72)),
		"速度 %d" % (900 + int(str(hero.get("id", "0")).to_int() % 900)),
	]

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
	if not "--capture-hero-panel" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name().contains("headless"):
		push_warning("Skipping hero panel capture in headless mode.")
		get_tree().quit()
		return
	var index := args.find("--capture-hero-panel")
	var output_path := "user://hero_panel.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		push_warning("Skipping hero panel capture because the viewport texture is unavailable.")
		get_tree().quit()
		return
	var image := viewport_texture.get_image()
	if image == null:
		push_warning("Skipping hero panel capture because the viewport image is unavailable.")
		get_tree().quit()
		return
	image.save_png(output_path)
	get_tree().quit()
