extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const HERO_DETAIL_SCENE := "res://scenes/original_hero_panel.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const HERO_CATALOG_PATH := "res://data/hero_catalog.json"
const HERO_SPINE_INDEX_PATH := "res://data/hero_spine_runtime_index.json"
const DESIGN_SIZE := Vector2(1280, 720)
const BG_PATH := "res://assets/resources/native/ac/ac082229-4446-4cfe-bbaf-5e9849e208c3.png"
const ATLAS_18A := "res://assets/resources/native/18/18b29ae48.png"
const ATLAS_14 := "res://assets/resources/native/14/14d2fafcf.png"
const ATLAS_C8 := "res://assets/resources/native/c8/c8384043-da3b-41dd-95e5-2ce3d2028977.png"
const CAMP_TAB_POS := Vector2(392, 4)
const HERO_CONTENT_POS := Vector2(175, 82)
const HERO_CONTENT_SIZE := Vector2(836, 492)
const HERO_SCROLL_POS := Vector2(32, 10)
const HERO_SCROLL_SIZE := Vector2(728, 430)
const HERO_CARD_SIZE := Vector2(86, 96)

const CAMP_TABS := [
	{"name": "全部", "id": 0, "path": "image/comHeroGrid/cm_icon_ZhenYing0"},
	{"name": "水", "id": 1, "path": "image/comHeroGrid/cm_icon_ZhenYing1"},
	{"name": "火", "id": 2, "path": "image/comHeroGrid/cm_icon_ZhenYing2"},
	{"name": "风", "id": 3, "path": "image/comHeroGrid/cm_icon_ZhenYing3"},
	{"name": "光", "id": 4, "path": "image/comHeroGrid/cm_icon_ZhenYing4"},
	{"name": "暗", "id": 5, "path": "image/comHeroGrid/cm_icon_ZhenYing5"},
]

const SIDE_TABS := ["英雄", "图鉴", "共鸣", "英魂", "法阵", "星辉"]
const QUALITY_ORDER := {"SSS": 0, "SSR": 1, "SR": 2, "R": 3, "N": 4}

const HEROES := [
	{"id": "105004", "name": "伊卡洛斯", "camp": 4, "job": "灵师", "power": "3027113", "level": "120", "stars": 5, "owned": true, "combat": true},
	{"id": "205008", "name": "苏拉", "camp": 2, "job": "战士", "power": "2864100", "level": "108", "stars": 5, "owned": true, "assist": true},
	{"id": "305006", "name": "尤朵拉", "camp": 1, "job": "射手", "power": "2719800", "level": "104", "stars": 5, "owned": true},
	{"id": "405007", "name": "拉瑞欧", "camp": 3, "job": "守护", "power": "2339000", "level": "96", "stars": 5, "owned": true},
	{"id": "505004", "name": "诺萨", "camp": 5, "job": "刺客", "power": "2188000", "level": "92", "stars": 5, "owned": true, "red": true},
	{"id": "204002", "name": "艾琳", "camp": 1, "job": "辅助", "power": "2013000", "level": "88", "stars": 5, "owned": true},
	{"id": "104002", "name": "莉莉", "camp": 2, "job": "法师", "power": "1884000", "level": "84", "stars": 5, "owned": true},
	{"id": "504002", "name": "奥斯曼", "camp": 5, "job": "守护", "power": "1722000", "level": "80", "stars": 3, "owned": false},
	{"id": "304001", "name": "米莉娅", "camp": 3, "job": "射手", "power": "1699000", "level": "78", "stars": 3, "owned": false},
	{"id": "204001", "name": "阿瓦隆", "camp": 1, "job": "战士", "power": "1586000", "level": "76", "stars": 3, "owned": false},
]

var design_root: Control
var grid: GridContainer
var count_label: Label
var title_label: Label
var detail_label: Label
var preview_panel: Control
var grid_panel_bg: ColorRect
var hero_scroll: ScrollContainer
var named_resources: Dictionary = {}
var hero_catalog: Array = []
var hero_spine_index: Dictionary = {}
var camp_buttons: Array[Button] = []
var side_buttons: Array[Button] = []
var selected_camp := 0
var selected_side_tab := 0

func _ready() -> void:
	_load_named_resources()
	_load_hero_catalog()
	_load_hero_spine_index()
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
	bg.modulate = Color(0.55, 0.62, 0.76, 0.72)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.48)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	_build_top_bar()
	_build_camp_tabs()
	_build_grid_panel()
	_build_side_tabs()
	_build_bottom_actions()
	_layout_design_root()
	_refresh()

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 1.0
	top.anchor_right = 1.0
	top.offset_left = -360
	top.offset_top = 8
	top.offset_right = -12
	top.offset_bottom = 42
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	top.visible = false
	add_child(top)

	title_label = Label.new()
	title_label.text = "HeroListPre"
	title_label.visible = false
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title_label)
	Navigation.add_buttons(top)
	_add_top_button(top, "主城", func(): Navigation.go(HOME_SCENE))
	_add_top_button(top, "详情", func(): Navigation.go(HERO_DETAIL_SCENE))
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄列表"}))

	var back_icon := Button.new()
	back_icon.text = "<"
	back_icon.position = Vector2(46, 18)
	back_icon.size = Vector2(42, 34)
	back_icon.add_theme_font_size_override("font_size", 22)
	back_icon.pressed.connect(func(): Navigation.go(HOME_SCENE))
	design_root.add_child(back_icon)

	var home_icon := Button.new()
	home_icon.text = "⌂"
	home_icon.position = Vector2(116, 16)
	home_icon.size = Vector2(52, 38)
	home_icon.add_theme_font_size_override("font_size", 20)
	home_icon.pressed.connect(func(): Navigation.go(HOME_SCENE))
	design_root.add_child(home_icon)

func _build_camp_tabs() -> void:
	var panel := HBoxContainer.new()
	panel.position = CAMP_TAB_POS
	panel.size = Vector2(310, 60)
	panel.add_theme_constant_override("separation", 14)
	design_root.add_child(panel)

	for i in CAMP_TABS.size():
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(40, 54)
		button.tooltip_text = str(CAMP_TABS[i].name)
		button.pressed.connect(_select_camp.bind(int(CAMP_TABS[i].id)))
		panel.add_child(button)
		camp_buttons.append(button)

func _build_grid_panel() -> void:
	var panel := Control.new()
	panel.position = HERO_CONTENT_POS
	panel.size = HERO_CONTENT_SIZE
	design_root.add_child(panel)

	grid_panel_bg = ColorRect.new()
	grid_panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid_panel_bg.color = Color(0.025, 0.035, 0.065, 0.18)
	grid_panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(grid_panel_bg)

	count_label = _add_label(design_root, "", Vector2(844, 12), Vector2(132, 30), 17, Color(0.88, 0.92, 1.0))
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var add_button := _add_action_button(design_root, "+", Vector2(980, 10), Vector2(28, 28), func(): _set_detail_text("本地 Demo：英雄容量入口。"))
	add_button.add_theme_font_size_override("font_size", 22)

	hero_scroll = ScrollContainer.new()
	hero_scroll.position = HERO_SCROLL_POS
	hero_scroll.size = HERO_SCROLL_SIZE
	hero_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hero_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(hero_scroll)

	grid = GridContainer.new()
	grid.columns = 7
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 14)
	hero_scroll.add_child(grid)

	var help := Button.new()
	help.text = "?"
	help.position = Vector2(830, -8)
	help.size = Vector2(36, 36)
	help.rotation = deg_to_rad(-45)
	help.add_theme_font_size_override("font_size", 22)
	help.pressed.connect(func(): _set_detail_text("本地 Demo：英雄列表帮助入口。"))
	panel.add_child(help)

func _build_side_tabs() -> void:
	var panel := Control.new()
	panel.position = Vector2.ZERO
	panel.size = DESIGN_SIZE
	design_root.add_child(panel)

	var tab_positions := [
		Vector2(1084, 18),
		Vector2(1084, 106),
		Vector2(1084, 194),
		Vector2(1084, 282),
		Vector2(1084, 370),
		Vector2(1084, 458),
	]
	for i in SIDE_TABS.size():
		var button := Button.new()
		button.text = SIDE_TABS[i]
		button.position = tab_positions[i]
		button.size = Vector2(150, 62)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_select_side_tab.bind(i))
		panel.add_child(button)
		side_buttons.append(button)

func _build_bottom_actions() -> void:
	var bottom := Control.new()
	bottom.position = Vector2(0, 0)
	bottom.size = DESIGN_SIZE
	design_root.add_child(bottom)
	detail_label = _add_label(bottom, "点击英雄卡片进入 HeroBookDetailPre 详情页。", Vector2(170, 646), Vector2(540, 26), 16, Color(0.78, 0.90, 1.0))
	detail_label.visible = false
	_build_bottom_nav(bottom)
	_add_action_button(bottom, "arrange", Vector2(1188, 512), Vector2(56, 44), func(): _select_side_tab(4))

func _build_bottom_nav(parent: Control) -> void:
	var labels := ["城镇", "英雄", "召唤", "冒险", "副本", "公会"]
	var targets := [
		func(): Navigation.go(HOME_SCENE),
		func(): _select_side_tab(0),
		func(): Navigation.go("res://scenes/original_draw_card_panel.tscn"),
		func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "冒险地图顶部"}),
		func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "冒险地图底部"}),
		func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "公会"}),
	]
	var centers := [260, 420, 580, 740, 900, 1060]
	for i in labels.size():
		var button := Button.new()
		button.text = labels[i]
		button.position = Vector2(centers[i] - 58, 632)
		button.size = Vector2(116, 62)
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(targets[i])
		parent.add_child(button)
		var glow := ColorRect.new()
		glow.position = Vector2(centers[i] - 46, 620)
		glow.size = Vector2(92, 4)
		glow.color = Color(0.95, 0.80, 0.44, 0.75 if i == 1 else 0.25)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(glow)

func _refresh() -> void:
	_refresh_camp_tabs()
	_refresh_side_tabs()
	_refresh_grid()
	var camp_name := str(CAMP_TABS[selected_camp].name) if selected_camp < CAMP_TABS.size() else "全部"
	title_label.text = "HeroListPre | %s | %s" % [SIDE_TABS[selected_side_tab], camp_name]

func _refresh_camp_tabs() -> void:
	for i in camp_buttons.size():
		var button := camp_buttons[i]
		button.visible = _is_camp_filter_visible(i)
		for child in button.get_children():
			child.queue_free()
		button.disabled = int(CAMP_TABS[i].id) == selected_camp
		var bg_color := Color(0.12, 0.14, 0.18, 0.92)
		if button.disabled:
			bg_color = Color(0.42, 0.28, 0.08, 0.96)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = bg_color
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(bg)
		if i == 0:
			var all_label := _add_label(button, "ALL", Vector2(0, 11), Vector2(40, 24), 15, Color(0.95, 0.96, 1.0))
			all_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			all_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		else:
			_add_named_image_to(button, str(CAMP_TABS[i].path), Vector2(0, 0), Vector2(40, 50))

func _refresh_side_tabs() -> void:
	for i in side_buttons.size():
		var button := side_buttons[i]
		button.disabled = i == selected_side_tab
		if i == selected_side_tab:
			button.modulate = Color(1.0, 0.86, 0.46, 1.0)
		else:
			button.modulate = Color(0.86, 0.88, 0.96, 1.0)

func _refresh_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	var filtered := _filtered_heroes()
	count_label.text = "%d/235" % filtered.size()
	count_label.visible = selected_side_tab in [0, 1]
	if selected_side_tab == 0:
		hero_scroll.position = HERO_SCROLL_POS
		hero_scroll.size = HERO_SCROLL_SIZE
		hero_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		hero_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		grid.columns = 7
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 14)
		for hero in filtered:
			_add_hero_card(hero)
	elif selected_side_tab == 1:
		hero_scroll.position = Vector2(10, 12)
		hero_scroll.size = Vector2(860, 432)
		hero_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		hero_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		grid.columns = max(filtered.size(), 1)
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 8)
		for hero in filtered:
			_add_book_card(hero)
	elif selected_side_tab == 2:
		grid.columns = 4
		_add_shared_level_cards(filtered)
	elif selected_side_tab == 3:
		grid.columns = 5
		for hero in filtered:
			_add_soul_card(hero)
	elif selected_side_tab == 4:
		grid.columns = 3
		_add_formation_cards(filtered)
	else:
		grid.columns = 4
		_add_star_material_cards()

func _add_hero_card(hero: Dictionary) -> void:
	var hero_id := str(hero.get("id", ""))
	var hero_name := str(hero.get("name", hero_id))
	var hero_level := str(hero.get("level", "1"))
	var hero_camp := int(hero.get("camp", 0))
	var hero_quality := str(hero.get("quality", "SSR"))
	var hero_owned := bool(hero.get("owned", true))
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = HERO_CARD_SIZE
	card.tooltip_text = "%s %s Lv.%s" % [hero_quality, hero_name, hero_level]
	card.pressed.connect(_open_hero_detail.bind(hero))
	grid.add_child(card)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.06, 0.09, 0.90) if hero_owned else Color(0.03, 0.03, 0.04, 0.86)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(bg)

	_add_named_image_to(card, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(0, 0), Vector2(86, 86))
	_add_named_image_to(card, "image/head/%s" % hero_id, Vector2(7, 7), Vector2(72, 72))
	_add_named_image_to(card, "image/comHeroGrid/cm_frame_TouXiangKuang6", Vector2(0, 0), Vector2(86, 86))
	_add_named_image_to(card, _camp_icon_path(hero_camp), Vector2(0, 0), Vector2(22, 28))
	var lv := _add_label(card, hero_level, Vector2(52, 1), Vector2(32, 17), 13, Color(0.72, 1.0, 0.92))
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_add_quality_label(card, hero_quality, Vector2(0, 66), Vector2(42, 20))
	var stars := int(hero.get("stars", 5))
	for i in stars:
		_add_named_image_to(card, "image/comHeroGrid/cm_icon_XingXing1_1", Vector2(37 + i * 9, 75), Vector2(13, 13))
	if bool(hero.get("combat", false)):
		_add_status_badge(card, "上阵", Vector2(56, 34), Color(0.16, 0.42, 0.78, 0.88))
	elif bool(hero.get("assist", false)):
		_add_status_badge(card, "助战", Vector2(56, 34), Color(0.78, 0.56, 0.22, 0.88))
	if bool(hero.get("red", false)):
		_add_named_image_to(card, "image/common/cm_icon_HongDian", Vector2(68, -4), Vector2(20, 20))
	if not hero_owned:
		var lock := ColorRect.new()
		lock.position = Vector2(0, 0)
		lock.size = card.custom_minimum_size
		lock.color = Color(0, 0, 0, 0.36)
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(lock)
		_add_label(card, "未获", Vector2(22, 34), Vector2(44, 20), 14, Color(0.9, 0.9, 0.95)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_book_card(hero: Dictionary) -> void:
	var hero_id := str(hero.get("id", ""))
	var hero_name := str(hero.get("name", hero_id))
	var hero_camp := int(hero.get("camp", 0))
	var hero_quality := str(hero.get("quality", "SSR"))
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = Vector2(108, 374)
	card.tooltip_text = "%s %s 图鉴" % [hero_quality, hero_name]
	card.pressed.connect(_open_hero_detail.bind(hero))
	grid.add_child(card)
	_add_named_image_to(card, "image/common/cm_frame_kadicheng", Vector2(0, 0), Vector2(108, 328))
	var book_image := _add_named_image_to(card, "image/heroBook/%s" % hero_id, Vector2(2, 16), Vector2(104, 302))
	if book_image == null:
		_add_named_image_to(card, "image/head/%s" % hero_id, Vector2(14, 112), Vector2(80, 80))
	_add_named_image_to(card, _camp_icon_path(hero_camp), Vector2(4, 10), Vector2(38, 48))
	_add_quality_label(card, hero_quality, Vector2(0, 58), Vector2(58, 26))
	_add_named_image_to(card, "image/com/HeroListPanel/yxtj_Frame_XinXiDi", Vector2(-2, 270), Vector2(112, 46))
	_add_label(card, hero_name, Vector2(4, 276), Vector2(100, 24), 16, Color(1.0, 0.86, 0.52)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_label(card, "星级 %s" % hero.get("stars", 3), Vector2(7, 322), Vector2(94, 20), 13, Color(0.90, 0.92, 1.0)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not bool(hero.get("owned", true)):
		var shade := ColorRect.new()
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shade.color = Color(0, 0, 0, 0.42)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(shade)
		_add_label(card, "未解锁", Vector2(23, 140), Vector2(80, 30), 18, Color(0.92, 0.92, 0.95)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_shared_level_cards(heroes: Array) -> void:
	for i in 8:
		var card := Button.new()
		card.text = ""
		card.custom_minimum_size = Vector2(198, 174)
		grid.add_child(card)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.04, 0.05, 0.08, 0.88)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(bg)
		if i < min(heroes.size(), 4):
			var hero: Dictionary = heroes[i]
			var hero_id := str(hero.get("id", ""))
			_add_named_image_to(card, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(44, 18), Vector2(110, 110))
			_add_named_image_to(card, "image/head/%s" % hero_id, Vector2(57, 31), Vector2(84, 84))
			_add_label(card, "%s  Lv.%s" % [hero.get("name", hero_id), hero.get("level", "1")], Vector2(10, 134), Vector2(178, 26), 16, Color(1.0, 0.86, 0.52)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		else:
			_add_label(card, "+", Vector2(0, 42), Vector2(198, 54), 42, Color(0.75, 0.86, 1.0)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_add_label(card, "添加共享英雄", Vector2(0, 112), Vector2(198, 26), 16, Color(0.86, 0.92, 1.0)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_soul_card(hero: Dictionary) -> void:
	var hero_id := str(hero.get("id", ""))
	var hero_name := str(hero.get("name", hero_id))
	var card := Button.new()
	card.text = ""
	card.custom_minimum_size = Vector2(152, 168)
	grid.add_child(card)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.04, 0.08, 0.90)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(bg)
	_add_named_image_to(card, "image/comHeroGrid/cm_frame_TouXiangDi4", Vector2(36, 12), Vector2(80, 80))
	_add_named_image_to(card, "image/head/%s" % hero_id, Vector2(46, 22), Vector2(60, 60))
	_add_label(card, "%s英魂" % hero_name, Vector2(8, 100), Vector2(136, 24), 16, Color(1.0, 0.86, 0.52)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_progress(card, Vector2(18, 132), Vector2(116, 12), 0.42 if bool(hero.get("owned", true)) else 0.18)
	_add_label(card, "42/100", Vector2(20, 144), Vector2(112, 20), 13, Color(0.86, 0.92, 1.0)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_formation_cards(heroes: Array) -> void:
	if heroes.is_empty():
		return
	for i in 6:
		var card := Button.new()
		card.text = ""
		card.custom_minimum_size = Vector2(260, 132)
		grid.add_child(card)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.035, 0.05, 0.075, 0.90)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(bg)
		_add_label(card, ["白羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座"][i], Vector2(18, 12), Vector2(120, 26), 18, Color(1.0, 0.86, 0.52))
		_add_label(card, "阵容等级 %d" % [30, 24, 20, 16, 12, 8][i], Vector2(18, 42), Vector2(130, 24), 15, Color(0.84, 0.92, 1.0))
		for j in 3:
			var hero: Dictionary = heroes[(i + j) % max(heroes.size(), 1)]
			_add_named_image_to(card, "image/comHeroGrid/cm_frame_TouXiangDi3", Vector2(154 + j * 32, 18), Vector2(30, 30))
			_add_named_image_to(card, "image/head/%s" % hero.get("id", ""), Vector2(158 + j * 32, 22), Vector2(22, 22))
		_add_label(card, "攻击 +%d%%  生命 +%d%%" % [8 + i, 12 + i], Vector2(18, 82), Vector2(220, 24), 14, Color(0.88, 0.95, 0.78))

func _add_star_material_cards() -> void:
	var items := [
		["四象星辉", "120/200", 0.60],
		["四象魔尘", "80/160", 0.50],
		["水相魔尘", "46/100", 0.46],
		["升星石", "300/500", 0.60],
		["英雄碎片", "42/100", 0.42],
		["转换预览", "预计获得 x80", 0.80],
	]
	for item in items:
		var card := Button.new()
		card.text = ""
		card.custom_minimum_size = Vector2(198, 150)
		grid.add_child(card)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.05, 0.045, 0.07, 0.90)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(bg)
		_add_label(card, str(item[0]), Vector2(12, 16), Vector2(174, 28), 18, Color(1.0, 0.86, 0.52)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_add_progress(card, Vector2(24, 70), Vector2(150, 14), float(item[2]))
		_add_label(card, str(item[1]), Vector2(20, 96), Vector2(158, 24), 15, Color(0.86, 0.92, 1.0)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_status_badge(parent: Control, text: String, position: Vector2, color: Color) -> void:
	var badge := ColorRect.new()
	badge.position = position
	badge.size = Vector2(46, 24)
	badge.color = color
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(badge)
	_add_label(parent, text, position, Vector2(46, 24), 13, Color.WHITE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_progress(parent: Control, position: Vector2, size: Vector2, value: float) -> void:
	var bg := ColorRect.new()
	bg.position = position
	bg.size = size
	bg.color = Color(0.02, 0.025, 0.04, 0.92)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	var fill := ColorRect.new()
	fill.position = position + Vector2(2, 2)
	fill.size = Vector2((size.x - 4) * clampf(value, 0.0, 1.0), size.y - 4)
	fill.color = Color(0.92, 0.58, 0.14, 1.0)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(fill)

func _select_camp(camp: int) -> void:
	if selected_side_tab == 1 and camp == 0:
		camp = 1
	selected_camp = camp
	_refresh()

func _select_side_tab(index: int) -> void:
	selected_side_tab = index
	if selected_side_tab == 0:
		selected_camp = 0
	elif selected_side_tab == 1 and selected_camp == 0:
		selected_camp = 1
	_refresh()
	var messages := [
		"英雄列表：点击任意英雄进入 HeroBookDetailPre。",
		"图鉴页：已按 HeroBookItemPre 的竖卡结构重建，后续补全立绘和收集状态。",
		"共鸣页：已按 HeroLevelSharedPre 的共享槽位做本地 mock。",
		"英魂入口：源码里 btnYingHun 打开 HeroPalacePanel，本地先显示碎片进度占位。",
		"法阵页：已按 HeroNormalarrayPre 的星座阵容做本地 mock。",
		"星辉页：已按 HeroStarPre 的材料/转换结构做本地 mock。",
	]
	_set_detail_text(messages[index])

func _is_camp_filter_visible(index: int) -> bool:
	if selected_side_tab == 0:
		return true
	if selected_side_tab == 1:
		return index != 0
	return false

func _open_hero_detail(hero: Dictionary) -> void:
	Navigation.go_with_args(HERO_DETAIL_SCENE, {"hero_id": str(hero.get("id", ""))})

func _open_hero_id(hero_id: String) -> void:
	for hero in _all_heroes():
		if str(hero.get("id", "")) == hero_id:
			_open_hero_detail(hero)
			return

func _filtered_heroes() -> Array:
	var result := []
	for hero in _all_heroes():
		if selected_camp == 0 or int(hero.get("camp", 0)) == selected_camp:
			result.append(hero)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var qa := _quality_sort_value(str(a.get("quality", "N")))
		var qb := _quality_sort_value(str(b.get("quality", "N")))
		if qa == qb:
			return str(a.get("id", "")) < str(b.get("id", ""))
		return qa < qb
	)
	return result

func _all_heroes() -> Array:
	var source: Array = HEROES if hero_catalog.is_empty() else hero_catalog
	if hero_spine_index.is_empty():
		return source
	var result := []
	for hero in source:
		if _has_spine_runtime(str(hero.get("id", ""))):
			result.append(hero)
	return result

func _has_spine_runtime(body_id: String) -> bool:
	return typeof(hero_spine_index.get(body_id, null)) == TYPE_DICTIONARY

func _quality_sort_value(quality: String) -> int:
	return int(QUALITY_ORDER.get(quality, 99))

func _quality_tag_path(quality: String) -> String:
	if quality == "SSS":
		return "image/comHeroGrid/cm_tag_SSR1"
	return "image/comHeroGrid/cm_tag_%s1" % quality

func _add_quality_label(parent: Control, quality: String, position: Vector2, size: Vector2) -> void:
	var label := _add_label(parent, quality, position, size, 13, Color(1.0, 0.92, 0.55))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _camp_icon_path(camp: int) -> String:
	return "image/comHeroGrid/cm_icon_ZhenYing%d" % clampi(camp, 0, 5)

func _set_detail_text(text: String) -> void:
	if detail_label:
		detail_label.text = text

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _add_action_button(parent: Control, text: String, position: Vector2, size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = size
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

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

func _load_hero_catalog() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_CATALOG_PATH))
	if typeof(parsed) == TYPE_ARRAY:
		hero_catalog = parsed

func _load_hero_spine_index() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_SPINE_INDEX_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		hero_spine_index = parsed.get("heroes", {})

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.clip_text = true
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _cocos_center_to_screen(position: Vector2) -> Vector2:
	return Vector2(DESIGN_SIZE.x * 0.5 + position.x, DESIGN_SIZE.y * 0.5 - position.y)

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

func _apply_cmdline_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var camp_arg := _cmd_arg_value(args, "--hero-list-camp")
	if camp_arg.is_valid_int():
		selected_camp = clampi(int(camp_arg), 0, CAMP_TABS.size() - 1)
	var tab_arg := _cmd_arg_value(args, "--hero-list-tab")
	if tab_arg.is_valid_int():
		selected_side_tab = clampi(int(tab_arg), 0, SIDE_TABS.size() - 1)
	_refresh()
	var open_id := _cmd_arg_value(args, "--hero-list-open-id")
	if open_id != "":
		call_deferred("_open_hero_id", open_id)
	var open_index := _cmd_arg_value(args, "--hero-list-open-index")
	if open_index.is_valid_int():
		var filtered := _filtered_heroes()
		var index := clampi(int(open_index), 0, max(filtered.size() - 1, 0))
		if not filtered.is_empty():
			call_deferred("_open_hero_detail", filtered[index])
	var click_arg := _cmd_arg_value(args, "--hero-list-click-at")
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

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-hero-list" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-hero-list")
	var output_path := "user://hero_list.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
