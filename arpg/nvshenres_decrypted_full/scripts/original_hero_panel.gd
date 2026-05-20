extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const SPINE_VIEWER := "res://scenes/spine_character_viewer.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

const BG_PATH := "res://assets/resources/native/ac/ac082229-4446-4cfe-bbaf-5e9849e208c3.png"
const ATLAS_18A := "res://assets/resources/native/18/18b29ae48.png"
const ATLAS_1A := "res://assets/resources/native/1a/1a7921f32.png"
const ATLAS_1F := "res://assets/resources/native/1f/1f6b547b4.png"
const ATLAS_15 := "res://assets/resources/native/15/15a1d9111.png"
const HERO_TAB_ON_ATLAS := "res://assets/resources/native/15/15a1d9111.png"
const HERO_TAB_ON_RECT := Rect2i(530, 950, 64, 100)
const HERO_TAB_OFF_ATLAS := "res://assets/resources/native/18/18b29ae48.png"
const HERO_TAB_OFF_RECT := Rect2i(104, 349, 57, 100)
const HERO_BOOK_TAG_TEX := "res://assets/resources/native/08/089f225e-78e8-428c-aeec-39bb5b669f43.png"
const HERO_105004_SPINE := "res://data/spine_runtime/105004.json"
const HERO_SULA_SPINE := "res://data/spine_runtime/SuLa_LH.json"
const HERO_YOUDUOLA_SPINE := "res://data/spine_runtime/YouDuoLa_LH.json"
const HERO_VOICE_INDEX_PATH := "res://data/hero_voice_index.json"
const HERO_CATALOG_PATH := "res://data/hero_catalog.json"
const HERO_SPINE_INDEX_PATH := "res://data/hero_spine_runtime_index.json"
const HERO_TOUCH_SOUNDS := ["1", "2", "3", "5"]

const HEROES := [
	{"id": "105004", "name": "伊卡洛斯", "job": "灵师", "camp": 4, "stars": 5, "spine": HERO_105004_SPINE, "power": "3027113", "level": "120/360", "attrs": ["攻击 120360", "生命 568420", "防御 42310", "速度 1785"], "target": Rect2(Vector2(330, 88), Vector2(430, 600))},
	{"id": "205008", "name": "苏拉", "job": "战士", "camp": 2, "stars": 5, "spine": HERO_SULA_SPINE, "power": "2864100", "level": "108/300", "attrs": ["攻击 104820", "生命 612500", "防御 48990", "速度 1620"], "target": Rect2(Vector2(330, 80), Vector2(430, 610))},
	{"id": "305006", "name": "尤朵拉", "job": "射手", "camp": 1, "stars": 5, "spine": HERO_YOUDUOLA_SPINE, "power": "2719800", "level": "104/300", "attrs": ["攻击 132500", "生命 438200", "防御 36210", "速度 1915"], "target": Rect2(Vector2(330, 80), Vector2(430, 610))},
	{"id": "405007", "name": "拉瑞欧", "job": "守护", "camp": 3, "stars": 5, "power": "2339000", "level": "96/260", "attrs": ["攻击 82420", "生命 690000", "防御 62410", "速度 1210"]},
	{"id": "505004", "name": "诺萨", "job": "刺客", "camp": 5, "stars": 5, "power": "2188000", "level": "92/260", "attrs": ["攻击 96800", "生命 402600", "防御 34200", "速度 1840"]},
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
var equipment_panel: Control
var tab_panel: Control
var side_panel: Control
var head_list: VBoxContainer
var voice_player: AudioStreamPlayer
var full_preview_exit_button: Button
var tab_buttons: Array[Button] = []
var prev_button: Button
var next_button: Button
var left_info_actions: Array[Button] = []
var quality_text_label: Label
var named_resources: Dictionary = {}
var voice_index: Dictionary = {}
var hero_spine_index: Dictionary = {}
var hero_catalog: Array = []
var selected_hero := 0
var selected_tab := 0
var selected_animation := 0
var selected_skin := 0
var voice_cursor := 0
var full_preview := false
var detail_mode := "main"

func _ready() -> void:
	_load_named_resources()
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
	var action_icons := ["image/common/cm_btn_PingLun", "image/common/cm_btn_ShiZhuang", "image/common/cm_icon_SuoDing"]
	var action_tooltips := ["全屏预览", "评论/分享", "未解锁功能"]
	for i in 3:
		var icon := Button.new()
		icon.position = action_positions[i]
		icon.size = Vector2(42, 42)
		icon.text = ""
		icon.tooltip_text = action_tooltips[i]
		icon.add_theme_font_size_override("font_size", 12)
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
	var shade := ColorRect.new()
	shade.name = "panel_bg"
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.055, 0.055, 0.065, 0.54)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_panel.add_child(shade)

func _build_bottom_nav() -> void:
	var nav := Control.new()
	nav.position = Vector2(216, 506)
	nav.size = Vector2(850, 90)
	nav.z_index = 35
	design_root.add_child(nav)
	var line := ColorRect.new()
	line.position = Vector2(0, 31)
	line.size = Vector2(850, 2)
	line.color = Color(0.9, 0.76, 0.42, 0.65)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nav.add_child(line)
	var items := [
		["城镇", ATLAS_1F, Rect2i(787, 551, 152, 141), Vector2(54, 48), HOME_SCENE],
		["英雄", ATLAS_1A, Rect2i(3, 334, 150, 142), Vector2(54, 48), ""],
		["召唤", ATLAS_1A, Rect2i(940, 89, 80, 80), Vector2(50, 50), "res://scenes/original_draw_card_panel.tscn"],
		["冒险", ATLAS_1A, Rect2i(159, 345, 150, 145), Vector2(54, 50), ""],
		["副本", ATLAS_1A, Rect2i(879, 276, 134, 133), Vector2(52, 50), ""],
		["公会", ATLAS_1A, Rect2i(345, 232, 119, 126), Vector2(50, 50), ""],
	]
	for i in items.size():
		var x := 20 + i * 142
		var button := Button.new()
		button.text = ""
		button.position = Vector2(x, 0)
		button.size = Vector2(104, 82)
		if str(items[i][4]) != "":
			button.pressed.connect(func(path := str(items[i][4])): Navigation.go(path))
		nav.add_child(button)
		var icon_size: Vector2 = items[i][3]
		_add_sprite_frame_image(button, str(items[i][1]), items[i][2], Vector2((104 - icon_size.x) * 0.5, 0), icon_size)
		_add_label(button, str(items[i][0]), Vector2(0, 49), Vector2(104, 28), 16, Color(1.0, 0.88, 0.54)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_full_preview_exit() -> void:
	full_preview_exit_button = Button.new()
	full_preview_exit_button.text = "返回"
	full_preview_exit_button.position = Vector2(1116, 24)
	full_preview_exit_button.size = Vector2(92, 42)
	full_preview_exit_button.z_index = 80
	full_preview_exit_button.visible = false
	full_preview_exit_button.pressed.connect(_toggle_full_preview)
	design_root.add_child(full_preview_exit_button)

func _select_hero(index: int) -> void:
	selected_hero = index
	selected_animation = 0
	selected_skin = 0
	_refresh_all()

func _select_tab(index: int) -> void:
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
	_apply_hero()
	_refresh_side_panel()
	_refresh_tabs()
	_refresh_detail()

func _apply_hero() -> void:
	var hero: Dictionary = _current_hero()
	var body_id := _current_body_id(hero)
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
		name_label.text = str(hero.get("name", hero.get("id", "")))
	var job_label := side_panel.get_node_or_null("hero_job") as Label
	if job_label:
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
	_add_named_image_to(head_root, "image/head/%s" % hero.get("id", ""), Vector2(25, 83), Vector2(36, 36))
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
	for i in tab_buttons.size():
		var button := tab_buttons[i]
		for child in button.get_children():
			child.queue_free()
		button.disabled = i == selected_tab
		if i == selected_tab:
			_add_sprite_frame_image(button, HERO_TAB_ON_ATLAS, HERO_TAB_ON_RECT, Vector2(12, -8), Vector2(64, 100), true, Vector2i(64, 100), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		else:
			_add_sprite_frame_image(button, HERO_TAB_OFF_ATLAS, HERO_TAB_OFF_RECT, Vector2(16, -8), Vector2(57, 100), false, Vector2i(57, 100), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		var tab_label := _add_label(button, labels[i], Vector2(-16, 12), Vector2(120, 62), 18, Color(0.92, 0.9, 0.82))
		tab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tab_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _refresh_detail() -> void:
	for child in detail_panel.get_children():
		if child.name == "panel_bg" or child.name == "panel_frame":
			continue
		child.queue_free()
	var hero: Dictionary = _current_hero()
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 130
	root.offset_top = 22
	root.offset_right = -18
	root.offset_bottom = -20
	detail_panel.add_child(root)

	_add_label(root, str(hero.get("job", "灵师")), Vector2(18, 0), Vector2(190, 30), 21, Color(0.28, 0.30, 0.45)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_label(root, "高输出  物理伤害", Vector2(0, 32), Vector2(238, 26), 16, Color(0.45, 0.48, 0.62)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var attrs: Array = hero.get("attrs", _generated_attrs(hero))
	for i in min(attrs.size(), 4):
		_add_label(root, str(attrs[i]), Vector2(0, 76 + i * 35), Vector2(228, 28), 18, Color(0.42, 0.46, 0.64))
	_add_label(root, "品阶", Vector2(0, 238), Vector2(64, 24), 16, Color(0.45, 0.48, 0.62))
	for i in 6:
		var gem := ColorRect.new()
		gem.position = Vector2(62 + i * 20, 244)
		gem.size = Vector2(12, 12)
		gem.rotation = 0.785398
		gem.color = Color(0.72, 0.24, 0.62, 1.0) if i < int(hero.get("stars", 5)) else Color(0.72, 0.72, 0.78, 0.8)
		root.add_child(gem)
	_add_progress(root, Vector2(0, 304), Vector2(236, 20), 1.0, "等级  %s" % hero.get("level", "1"))

	if detail_mode == "book":
		_add_book_info(root, hero, 344)
	elif selected_tab == 0:
		_add_culture_tab(root, hero, 344)
	elif selected_tab == 1:
		_add_equipment_tab(root, 344)
	elif selected_tab == 2:
		_add_star_tab(root, 344)
	elif selected_tab == 3:
		_add_will_tab(root, 344)
	else:
		_add_skin_tab(root, 344)

func _add_book_info(root: Control, hero: Dictionary, y_base := 126) -> void:
	_add_label(root, "图鉴详情", Vector2(0, y_base), Vector2(238, 28), 20, Color(0.42, 0.36, 0.16)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_label(root, "源码 HeroBookDetailPanel 由图鉴单卡或单英雄查询打开。", Vector2(0, y_base + 40), Vector2(238, 52), 15, Color(0.42, 0.46, 0.64)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_action_button(root, "信息", Vector2(0, y_base + 108), Vector2(108, 38), func(): _select_tab(0))
	_add_action_button(root, "衣装", Vector2(122, y_base + 108), Vector2(108, 38), func(): _select_tab(4))
	_add_action_button(root, "全屏预览", Vector2(0, y_base + 162), Vector2(108, 38), _toggle_full_preview)
	_add_action_button(root, "评论", Vector2(122, y_base + 162), Vector2(108, 38), func(): _play_hero_voice("2"))

func _add_culture_tab(root: Control, hero: Dictionary, y_base := 126) -> void:
	_add_label(root, "等级已达上限！！！", Vector2(0, y_base), Vector2(238, 28), 18, Color(0.70, 0.46, 0.18)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_action_button(root, "升2级", Vector2(6, y_base + 52), Vector2(102, 42))
	_add_action_button(root, "进阶", Vector2(124, y_base + 52), Vector2(102, 42))

func _add_equipment_tab(root: Control, y_base := 126) -> void:
	var equips := ["yx_icon_zhuangbei0", "yx_icon_zhuangbei1", "yx_icon_zhuangbei2", "yx_icon_zhuangbei3", "yx_icon_zhuangbei4", "yx_icon_zhuangbei5"]
	for i in equips.size():
		var pos := Vector2((i % 3) * 76, y_base + int(i / 3) * 76)
		var slot := Control.new()
		slot.position = pos
		slot.size = Vector2(72, 72)
		root.add_child(slot)
		var slot_bg := ColorRect.new()
		slot_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot_bg.color = Color(0.03, 0.035, 0.055, 0.72)
		slot_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(slot_bg)
		_add_named_image_to(slot, "image/en/HeroPanel/yx_frame_ZBCheng", Vector2(0, 0), Vector2(72, 72))
		_add_named_image_to(slot, "image/en/HeroPanel/%s" % equips[i], Vector2(13, 13), Vector2(46, 46))
	_add_action_button(root, "一键装备", Vector2(0, y_base + 166), Vector2(112, 42))
	_add_action_button(root, "强化", Vector2(126, y_base + 166), Vector2(104, 42))

func _add_star_tab(root: Control, y_base := 126) -> void:
	_add_label(root, "当前星级  SSR 3 星", Vector2(0, y_base), Vector2(238, 30), 19, Color(0.42, 0.36, 0.16))
	_add_progress(root, Vector2(0, y_base + 52), Vector2(236, 20), 0.42, "碎片 42/100")
	_add_action_button(root, "升星", Vector2(0, y_base + 120), Vector2(130, 42))

func _add_will_tab(root: Control, y_base := 126) -> void:
	for i in 4:
		_add_label(root, ["攻击 +100", "生命 +2200", "防御 +80", "速度 +12"][i], Vector2(0, y_base + i * 36), Vector2(238, 28), 18, Color(0.42, 0.46, 0.64))
	_add_action_button(root, "激活战意", Vector2(0, y_base + 166), Vector2(150, 42))

func _add_skin_tab(root: Control, y_base := 126) -> void:
	var hero: Dictionary = _current_hero()
	var skins := _skin_body_ids(hero)
	var body_id := _current_body_id(hero)
	_add_label(root, "衣装预览", Vector2(0, y_base), Vector2(238, 30), 21, Color(0.42, 0.36, 0.16))
	_add_label(root, "body: %s  (%d/%d)" % [body_id, selected_skin + 1, skins.size()], Vector2(0, y_base + 40), Vector2(238, 28), 16, Color(0.42, 0.46, 0.64))
	_add_action_button(root, "下个衣装", Vector2(0, y_base + 88), Vector2(108, 38), _next_skin)
	_add_action_button(root, "播放展示", Vector2(122, y_base + 88), Vector2(108, 38), func(): _play_hero_voice("7-1"))
	_add_action_button(root, "全屏预览", Vector2(0, y_base + 142), Vector2(108, 38), _toggle_full_preview)
	_add_action_button(root, "前往获取", Vector2(122, y_base + 142), Vector2(108, 38), func(): _play_hero_voice("10"))

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

func _add_action_button(parent: Control, text: String, position: Vector2, size: Vector2, callback := Callable()) -> Button:
	var button := Button.new()
	button.text = ""
	button.position = position
	button.size = size
	if callback.is_valid():
		button.pressed.connect(callback)
	parent.add_child(button)
	_add_named_image_to(button, "image/common/cm_btn_LvSe1", Vector2.ZERO, size)
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

func _fit_spine(hero: Dictionary) -> void:
	hero_spine.update_preview_pose(0.0)
	var bounds: Rect2 = hero_spine.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var target: Rect2 = hero.get("target", Rect2(Vector2(252, 34), Vector2(526, 626)))
	if not hero.has("target"):
		target = Rect2(Vector2(252, 34), Vector2(526, 626))
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

func _next_skin() -> void:
	var skins := _skin_body_ids(_current_hero())
	selected_skin = wrapi(selected_skin + 1, 0, max(skins.size(), 1))
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
	var stream := _load_mp3_stream(path)
	if stream:
		voice_player.stop()
		voice_player.stream = stream
		voice_player.play()

func _load_mp3_stream(path: String) -> AudioStreamMP3:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var stream := AudioStreamMP3.new()
	stream.data = file.get_buffer(file.get_length())
	return stream

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
			return

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
		return ["档案", "技能", "羁绊", "评论", "衣装"]
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
	var index := args.find("--capture-hero-panel")
	var output_path := "user://hero_panel.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
