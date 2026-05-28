# UTF-8 source. HeroMainView/HeroDetailInfoView split from main.gd using source prefab inventories.
extends RefCounted

const DEFAULT_HERO_ID := 240030
const UI_HERO_BG_MAIN := "res://assets/ui/background/hero_bg_01.png"
const UI_HERO_BG_DETAIL := "res://assets/ui/background/hero_bg_10.png"
const UI_HERO_DETAIL_INFO_BG := "res://assets/ui/background/guessing_bg_03.png"
const UI_HERO_SELECTOR_BG := "res://assets/ui/hero/hero_img_36.png"
const UI_HERO_SELECTOR_TOP := "res://assets/ui/hero/hero_img_36a.png"
const UI_HERO_SORT_BTN := "res://assets/ui/hero/hero_btn_05.png"
const UI_HERO_FILTER_BG := "res://assets/ui/hero/hero_img_108.png"
const UI_HERO_HIGHLIGHT := "res://assets/ui/hero/hero_img_119.png"
const UI_HERO_STAR_SMALL := "res://assets/ui/hero/hero_img_60.png"
const UI_HERO_CAMP_FILTER_ICONS := [
	"res://assets/ui/hero/hero_img_109.png",
	"res://assets/ui/hero/hero_img_110.png",
	"res://assets/ui/hero/hero_img_113.png",
	"res://assets/ui/hero/hero_img_111.png",
	"res://assets/ui/hero/hero_img_112.png",
	"res://assets/ui/hero/hero_img_114.png",
]
const UI_HERO_OCCUPATION_FILTER_ICONS := [
	"res://assets/ui/hero/hero_img_109.png",
	"res://assets/ui/hero/hero_img_115.png",
	"res://assets/ui/hero/hero_img_118.png",
	"res://assets/ui/hero/hero_img_117.png",
	"res://assets/ui/hero/hero_img_116.png",
	"res://assets/ui/hero/hero_img_199.png",
]
const UI_COMMON_BTN_GOLD := "res://assets/ui/common/tongyong_btn_08.png"
const UI_COMMON_BTN_WHITE := "res://assets/ui/common/tongyong_btn_01.png"
const UI_COMMON_TAB_HIGHLIGHT := "res://assets/ui/common/common_btn_07.png"
const UI_COMMON_HEAD_FRAME := "res://assets/ui/common/common_img_07.png"
const UI_COMMON_LEVEL_BADGE := "res://assets/ui/common/common_img_61.png"
const UI_COMMON_HERO_HEAD_FRAME := "res://assets/ui/common/common_img_64.png"
const UI_COMMON_HERO_STAR_BAR := "res://assets/ui/common/common_img_62.png"
const UI_COMMON_RARE_BADGE := "res://assets/ui/common/common_img_163.png"
const UI_COMMON_STAR := "res://assets/ui/common/common_img_73.png"
const UI_COMMON_STAR_OFF := "res://assets/ui/common/common_img_74.png"
const UI_COMMON_SECTION := "res://assets/ui/common/common_img_199.png"
const UI_COMMON_SKILL_FRAME := "res://assets/ui/common/common_img_208.png"
const HERO_MAIN_BG_POS := Vector2(-195, -15)
const HERO_MAIN_BG_SIZE := Vector2(1670, 750)
const HERO_SELECTOR_PANEL_POS := Vector2(36, 90)
const HERO_SELECTOR_PANEL_SIZE := Vector2(100, 640)
const HERO_LIST_TAB_SIZE := Vector2(206, 62)
const HERO_LIST_ORDINATION_TAB_SIZE := Vector2(111, 44)
const HERO_LIST_FILTER_PANEL_POS := Vector2(836, 82)
const HERO_LIST_FILTER_PANEL_SIZE := Vector2(360, 130)
const HERO_DETAIL_INFO_SCALE := 0.5
const HERO_DETAIL_INFO_SIZE := Vector2(1080, 610) * HERO_DETAIL_INFO_SCALE
const UI_MAIN_LIMIT_ICONS := [
	"res://assets/ui/mainui/mainui_btn_15.png",
	"res://assets/ui/mainui/mainui_btn_16.png",
	"res://assets/ui/mainui/mainui_btn_17.png",
	"res://assets/ui/mainui/mainui_btn_20.png",
	"res://assets/ui/mainui/mainui_btn_18.png",
	"res://assets/ui/mainui/mainui_btn_19.png"
]

var app
var gallery_filter := "all"
var gallery_sort_mode := "level"
var gallery_sort_open := false
var gallery_camp_filter := "all"
var gallery_occupation_filter := "all"
var hero_detail_tab := "overview"

func _init(app_ref) -> void:
	app = app_ref

func _show_gallery() -> void:
	app._clear("幻靈")
	_draw_hero_list_background()
	_draw_hero_list_header()
	_draw_hero_list_filters()
	_draw_hero_sort_panel()
	_draw_hero_list_cards()

func _draw_hero_list_background() -> void:
	app._draw_image(UI_HERO_BG_MAIN, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.84))
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.018, 0.016, 0.025, 0.36)))
	app._draw_image(UI_HERO_BG_DETAIL, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.18))
	app._draw_image(UI_HERO_SELECTOR_BG, HERO_SELECTOR_PANEL_POS, HERO_SELECTOR_PANEL_SIZE, true, Color(1, 1, 1, 0.40))


func _draw_hero_list_header() -> void:
	var header: Label = app._label("幻靈圖鑑", 34)
	header.position = Vector2(38, 22)
	header.size = Vector2(240, 50)
	header.modulate = Color(1.0, 0.92, 0.76)
	app._view_container().add_child(header)

	var owned_count: int = app.save.get("owned", {}).size()
	var progress: Label = app._label("收集進度  %d / %d" % [owned_count, app.heroes.size()], 20, HORIZONTAL_ALIGNMENT_RIGHT)
	progress.position = Vector2(806, 30)
	progress.size = Vector2(396, 34)
	progress.modulate = Color(0.96, 0.90, 0.82)
	app._view_container().add_child(progress)

	app._draw_image(UI_HERO_FILTER_BG, HERO_LIST_FILTER_PANEL_POS, HERO_LIST_FILTER_PANEL_SIZE, false, Color(1, 1, 1, 0.86))
	_draw_hero_ordination_tab(_gallery_sort_label(gallery_sort_mode), Vector2(980, 90), true, func() -> void:
		gallery_sort_open = not gallery_sort_open
		_show_gallery()
	)
	app._draw_image(UI_HERO_SORT_BTN, Vector2(1142, 116), Vector2(42, 42), false, Color(1, 1, 1, 0.92))
	app._add_hit_button(Vector2(1134, 108), Vector2(58, 58), func() -> void:
		gallery_sort_open = not gallery_sort_open
		_show_gallery()
	)


func _draw_hero_sort_panel() -> void:
	if not gallery_sort_open:
		return
	app._draw_image(UI_HERO_FILTER_BG, HERO_LIST_FILTER_PANEL_POS, HERO_LIST_FILTER_PANEL_SIZE, false, Color(1, 1, 1, 0.96))
	app._view_container().add_child(app._panel(Vector2(848, 92), Vector2(336, 106), Color(0.030, 0.024, 0.038, 0.72)))
	var modes := [
		{"key": "level", "text": "等級"},
		{"key": "power", "text": "戰力"},
		{"key": "rarity", "text": "稀有"},
	]
	for index in range(modes.size()):
		var mode: Dictionary = modes[index]
		var mode_key := str(mode.get("key", "power"))
		var selected := gallery_sort_mode == mode_key
		var pos := Vector2(852 + index * 112.0, 92)
		var target_mode := mode_key
		_draw_hero_ordination_tab(str(mode.get("text", "")), pos, selected, func() -> void:
			gallery_sort_mode = target_mode
			gallery_sort_open = false
			_show_gallery()
		)
	var occupation_keys := ["all", "occupation1", "occupation2", "occupation3", "occupation4", "occupation5"]
	for index in range(occupation_keys.size()):
		var key := str(occupation_keys[index])
		var pos := Vector2(862 + index * 48.0, 138)
		var target_occupation := key
		_draw_hero_filter_icon(key, gallery_occupation_filter == key, str(UI_HERO_OCCUPATION_FILTER_ICONS[index]), pos, Vector2(36, 36), "全" if index == 0 else "", func() -> void:
			gallery_occupation_filter = target_occupation
			_show_gallery()
		)

	var camp_keys := ["all", "camp1", "camp2", "camp3", "camp4", "camp5"]
	for index in range(camp_keys.size()):
		var key := str(camp_keys[index])
		var pos := Vector2(862 + index * 48.0, 174)
		var target_camp := key
		_draw_hero_filter_icon(key, gallery_camp_filter == key, str(UI_HERO_CAMP_FILTER_ICONS[index]), pos, Vector2(36, 36), "全" if index == 0 else "", func() -> void:
			gallery_camp_filter = target_camp
			_show_gallery()
		)


func _draw_hero_ordination_tab(text: String, pos: Vector2, selected: bool, on_press: Callable) -> void:
	var bg_color := Color(0.70, 0.44, 0.18, 0.50) if selected else Color(0.09, 0.07, 0.10, 0.42)
	app._view_container().add_child(app._panel(pos, HERO_LIST_ORDINATION_TAB_SIZE, bg_color))
	var label: Label = app._label(text, 20, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = HERO_LIST_ORDINATION_TAB_SIZE
	label.modulate = Color(1.0, 0.92, 0.70) if selected else Color(0.88, 0.84, 0.82)
	app._view_container().add_child(label)
	app._add_hit_button(pos, HERO_LIST_ORDINATION_TAB_SIZE, on_press)


func _draw_hero_filter_icon(_key: String, active: bool, icon_path: String, pos: Vector2, size: Vector2, text: String, on_press: Callable) -> void:
	app._draw_image(icon_path, pos, size, false, Color(1, 1, 1, 0.94))
	if active:
		app._draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(6, 6), size + Vector2(12, 12), false, Color(1.0, 0.82, 0.32, 0.62))
	if not text.is_empty():
		var label: Label = app._label(text, 13, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + Vector2(-2, 9)
		label.size = Vector2(40, 18)
		app._view_container().add_child(label)
	app._add_hit_button(pos - Vector2(6, 6), size + Vector2(12, 12), on_press)


func _draw_hero_list_filters() -> void:
	var tabs := [
		{"text": "總覽", "filter": "all"},
		{"text": "已獲得", "filter": "owned"},
		{"text": "未獲得", "filter": "unowned"},
		{"text": "四星", "filter": "r4"},
		{"text": "三星", "filter": "r3"},
		{"text": "二星", "filter": "r2"},
	]
	var y := 116.0
	for tab in tabs:
		_draw_hero_list_tab(str(tab.get("text", "")), str(tab.get("filter", "")), Vector2(42, y))
		y += 72.0


func _draw_hero_list_tab(text: String, filter: String, pos: Vector2) -> void:
	var selected := gallery_filter == filter
	if selected:
		app._draw_image(UI_COMMON_TAB_HIGHLIGHT, pos, Vector2(206, 64), false, Color(1, 1, 1, 0.96))
	else:
		app._view_container().add_child(app._panel(pos + Vector2(10, 7), Vector2(186, 48), Color(0.10, 0.075, 0.10, 0.48)))

	var label: Label = app._label(text, 22, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos + Vector2(78, -8)
	label.size = Vector2(104, 76)
	label.modulate = Color(1.0, 0.92, 0.78) if selected else Color(0.86, 0.82, 0.78)
	app._view_container().add_child(label)
	var dot_color := Color(1.0, 0.64, 0.30, 0.95) if selected else Color(0.42, 0.36, 0.44, 0.75)
	app._view_container().add_child(app._panel(pos + Vector2(28, 22), Vector2(22, 22), dot_color))

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = HERO_LIST_TAB_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		gallery_filter = filter
		_show_gallery()
	)
	app._view_container().add_child(button)


func _draw_hero_list_cards() -> void:
	var filtered: Array = _gallery_filtered_heroes()
	if filtered.is_empty():
		var empty: Label = app._label("暫無符合條件的角色", 22, HORIZONTAL_ALIGNMENT_CENTER)
		empty.position = Vector2(382, 330)
		empty.size = Vector2(720, 40)
		app._view_container().add_child(empty)
		return

	var x := 290.0
	var y := 132.0
	var col := 0
	for hero in filtered:
		_draw_hero_list_card(hero, Vector2(x, y))
		col += 1
		x += 228.0
		if col >= 4:
			col = 0
			x = 290.0
			y += 178.0


func _draw_hero_list_card(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var copies := int(app.save.get("owned", {}).get(str(hero_id), 0))
	var shards := int(app.save.get("shards", {}).get(str(hero_id), 0))
	var owned := copies > 0
	var frame_color: Color = app._rarity_color(rarity, 0.26 if owned else 0.12)
	app._view_container().add_child(app._panel(pos, Vector2(196, 142), Color(0.045, 0.038, 0.058, 0.78)))
	app._view_container().add_child(app._panel(pos + Vector2(2, 2), Vector2(192, 138), frame_color))
	app._draw_image(UI_HERO_HIGHLIGHT, pos + Vector2(10, 8), Vector2(80, 80), false, Color(1, 1, 1, 0.55))

	var tint := Color(1, 1, 1, 1) if owned else Color(0.42, 0.42, 0.45, 1)
	app._draw_hero_round_thumb(hero, pos + Vector2(16, 12), Vector2(72, 72), tint)
	app._draw_image(UI_COMMON_HERO_HEAD_FRAME, pos + Vector2(16, 12), Vector2(72, 72), false, Color(1, 1, 1, 0.96 if owned else 0.58))
	_draw_hero_select_star_bar(rarity, pos + Vector2(17, 82))
	app._draw_image(UI_COMMON_LEVEL_BADGE, pos + Vector2(58, 56), Vector2(32, 32), false, Color(1, 1, 1, 0.95))
	var level_label: Label = app._label(str(level), 13, HORIZONTAL_ALIGNMENT_CENTER)
	level_label.position = pos + Vector2(63, 62)
	level_label.size = Vector2(24, 22)
	level_label.modulate = Color(1.0, 0.96, 0.76)
	app._view_container().add_child(level_label)

	var display_name := str(hero.get("name", "Unknown")) if owned else "未獲得"
	var name_label: Label = app._label(display_name, 19)
	name_label.position = pos + Vector2(96, 18)
	name_label.size = Vector2(88, 28)
	name_label.modulate = Color(1.0, 0.94, 0.82) if owned else Color(0.72, 0.70, 0.72)
	app._view_container().add_child(name_label)

	var state_text := "持有 %d  碎片 %d" % [copies, shards] if owned else "線索未解鎖"
	var state: Label = app._label(state_text, 14)
	state.position = pos + Vector2(96, 52)
	state.size = Vector2(88, 42)
	state.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(state)

	var power := _hero_power(hero)
	var power_label: Label = app._label("戰力 %d" % power, 14)
	power_label.position = pos + Vector2(96, 98)
	power_label.size = Vector2(88, 26)
	power_label.modulate = Color(1.0, 0.82, 0.52)
	app._view_container().add_child(power_label)

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = Vector2(196, 142)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		_show_hero_detail(hero_id)
	)
	app._view_container().add_child(button)

func _show_hero_detail(hero_id: int) -> void:
	var hero: Dictionary = app._hero_by_id(hero_id)
	app._clear(str(hero.get("name", "角色")))
	_draw_hero_detail_background()
	_draw_hero_selector_strip(hero_id)
	app._draw_hero_stage(hero, Vector2(236, 34), Vector2(520, 650), false)
	var info_pos := Vector2(688, 64)
	_draw_hero_detail_info_view_frame(hero, info_pos)
	_draw_hero_detail_tabs(hero, Vector2(720, 26))
	_draw_hero_detail_notice(info_pos + Vector2(22, 578 * HERO_DETAIL_INFO_SCALE))
	_draw_hero_detail_tab_content(hero, info_pos + Vector2(16, 338 * HERO_DETAIL_INFO_SCALE))
	_draw_hero_detail_nav(hero_id)

	var key := str(hero.get("id", 0))
	var copies := int(app.save.get("owned", {}).get(key, 0))
	var shards := int(app.save.get("shards", {}).get(key, 0))
	if copies <= 0:
		var mask: ColorRect = app._panel(Vector2(236, 34), Vector2(520, 650), Color(0.0, 0.0, 0.0, 0.42))
		app._view_container().add_child(mask)
		var locked: Label = app._label("未獲得", 36, HORIZONTAL_ALIGNMENT_CENTER)
		locked.position = Vector2(236, 304)
		locked.size = Vector2(520, 56)
		app._view_container().add_child(locked)
		app._add_action_button("前往喚靈", Vector2(1004, 636), app._show_gacha, Vector2(132, 44))
		if shards >= _hero_unlock_shard_cost(hero):
			app._add_action_button("碎片召喚", Vector2(1004, 586), func() -> void:
				_unlock_hero_with_shards(hero_id)
			, Vector2(132, 44))
	else:
		app._add_action_button("設主看板", Vector2(1004, 586), func() -> void:
			_set_hero_as_wallpaper(hero_id)
		, Vector2(132, 44))
		app._add_action_button("設Gal", Vector2(1004, 636), func() -> void:
			_set_hero_as_gal(hero_id)
		, Vector2(92, 44))
		app._add_action_button("收藏", Vector2(1102, 636), func() -> void:
			_toggle_favorite_hero(hero_id)
		, Vector2(84, 44))
	app._add_action_button("返回幻靈", Vector2(858, 636), _show_gallery, Vector2(132, 44))


func _draw_hero_detail_background() -> void:
	app._draw_image(UI_HERO_BG_MAIN, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.76))
	app._draw_image(UI_HERO_BG_DETAIL, HERO_MAIN_BG_POS, HERO_MAIN_BG_SIZE, true, Color(1, 1, 1, 0.32))
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.014, 0.012, 0.020, 0.30)))
	app._draw_image(UI_HERO_SELECTOR_BG, HERO_SELECTOR_PANEL_POS, HERO_SELECTOR_PANEL_SIZE, true, Color(1, 1, 1, 0.88))
	app._draw_image(UI_HERO_SELECTOR_BG, HERO_SELECTOR_PANEL_POS, HERO_SELECTOR_PANEL_SIZE, true, Color(1, 1, 1, 0.36))
	app._draw_image(UI_HERO_SELECTOR_TOP, HERO_SELECTOR_PANEL_POS + Vector2(-1, 1), Vector2(102, 49), false, Color(1, 1, 1, 0.96))
	app._draw_image(UI_HERO_SORT_BTN, HERO_SELECTOR_PANEL_POS + Vector2(23, 243), Vector2(54, 54), false, Color(1, 1, 1, 0.92))


func _draw_hero_selector_strip(selected_hero_id: int) -> void:
	var y := 132.0
	for hero in _hero_selector_heroes():
		var hero_id := int(hero.get("id", 0))
		var selected = hero_id == selected_hero_id
		_draw_hero_selector_grid(hero, Vector2(51, y), selected)
		y += 78.0


func _hero_selector_heroes() -> Array:
	var list: Array = app.heroes.duplicate(true)
	list.sort_custom(_sort_heroes_by_level)
	return list.slice(0, min(6, list.size()))


func _draw_hero_selector_grid(hero: Dictionary, pos: Vector2, selected: bool) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var level := int(app.save.get("hero_levels", {}).get(key, 1))
	var can_up := int(app.save.get("shards", {}).get(key, 0)) >= _hero_unlock_shard_cost(hero) or int(app.save.get("owned", {}).get(key, 0)) > 0
	if selected:
		app._draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(15, 15), Vector2(100, 100), false, Color(1, 1, 1, 0.86))
	app._draw_hero_round_thumb(hero, pos, Vector2(70, 70), Color(1, 1, 1, 1))
	app._draw_image(UI_COMMON_HERO_HEAD_FRAME, pos, Vector2(70, 70), false, Color(1, 1, 1, 0.96))
	_draw_hero_select_star_bar(rarity, pos + Vector2(0, 63))
	app._draw_image(UI_COMMON_LEVEL_BADGE, pos + Vector2(25, 25), Vector2(28, 28), false, Color(1, 1, 1, 0.92))
	var level_label: Label = app._label(str(level), 13, HORIZONTAL_ALIGNMENT_CENTER)
	level_label.position = pos + Vector2(28, 25)
	level_label.size = Vector2(23, 28)
	level_label.modulate = Color(1.0, 0.96, 0.76)
	app._view_container().add_child(level_label)
	if can_up:
		app._draw_red_dot(pos + Vector2(60, -6))

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos - Vector2(6, 6)
	button.size = Vector2(82, 82)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		_show_hero_detail(hero_id)
	)
	app._view_container().add_child(button)


func _draw_hero_select_star_bar(rarity: int, pos: Vector2) -> void:
	app._draw_image(UI_COMMON_HERO_STAR_BAR, pos, Vector2(70, 14), false, Color(1, 1, 1, 0.78))
	var count: int = clamp(rarity, 1, 5)
	var start_x := pos.x + (70.0 - float(count) * 14.0) * 0.5
	for i in range(count):
		app._draw_image(UI_HERO_STAR_SMALL, Vector2(start_x + i * 14.0, pos.y), Vector2(14, 14), false, Color(1, 1, 1, 0.95))


func _draw_hero_detail_tabs(hero: Dictionary, pos: Vector2) -> void:
	var tabs := [
		{"key": "overview", "text": "總覽"},
		{"key": "core", "text": "核心"},
		{"key": "attrs", "text": "屬性"},
		{"key": "skills", "text": "技能"},
		{"key": "equip", "text": "靈裝"},
		{"key": "bond", "text": "羈絆"},
	]
	var x := pos.x
	for raw_tab in tabs:
		var tab: Dictionary = raw_tab
		var tab_key := str(tab.get("key", "overview"))
		var is_selected := tab_key == hero_detail_tab
		if is_selected:
			app._draw_image(UI_COMMON_TAB_HIGHLIGHT, Vector2(x, pos.y), Vector2(92, 48), false, Color(1, 1, 1, 0.92))
		else:
			app._view_container().add_child(app._panel(Vector2(x + 6, pos.y + 6), Vector2(80, 36), Color(0.075, 0.058, 0.083, 0.62)))
		var label: Label = app._label(str(tab.get("text", "")), 18, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(x + 8, pos.y + 8)
		label.size = Vector2(76, 28)
		label.modulate = Color(1.0, 0.92, 0.74) if is_selected else Color(0.82, 0.78, 0.78)
		app._view_container().add_child(label)
		var button_pos := Vector2(x, pos.y)
		var hero_id := int(hero.get("id", 0))
		var target_tab := tab_key
		app._add_hit_button(button_pos, Vector2(92, 48), func() -> void:
			hero_detail_tab = target_tab
			_show_hero_detail(hero_id)
		)
		x += 86.0


func _draw_hero_detail_info_view_frame(hero: Dictionary, pos: Vector2) -> void:
	var scale := HERO_DETAIL_INFO_SCALE
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var level := int(app.save.get("hero_levels", {}).get(key, 1))
	var attrs := _hero_attrs(hero)

	app._draw_image(UI_HERO_DETAIL_INFO_BG, pos, HERO_DETAIL_INFO_SIZE, true, Color(1, 1, 1, 0.92))
	app._draw_image(UI_COMMON_HEAD_FRAME, pos + Vector2(12, 10) * scale, Vector2(140, 140) * scale, false, Color(1, 1, 1, 0.92))
	app._draw_hero_round_thumb(hero, pos + Vector2(19, 17) * scale, Vector2(126, 126) * scale, Color(1, 1, 1, 1))

	var title: Label = app._label(str(hero.get("name", "角色")), 24)
	title.position = pos + Vector2(166, 17) * scale
	title.size = Vector2(180, 32)
	title.modulate = Color(1.0, 0.92, 0.76)
	app._view_container().add_child(title)

	var subtitle: Label = app._label("Lv.%d  Spine %s" % [level, str(hero.get("spine", ""))], 13)
	subtitle.position = pos + Vector2(166, 54) * scale
	subtitle.size = Vector2(230, 22)
	subtitle.modulate = Color(0.90, 0.84, 0.78)
	app._view_container().add_child(subtitle)

	app._draw_image(UI_COMMON_RARE_BADGE, pos + Vector2(416, 10) * scale, Vector2(120, 54) * scale, false, Color(1, 1, 1, 0.86))
	var rare_label: Label = app._label("R%d" % rarity, 17, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(420, 20) * scale
	rare_label.size = Vector2(54, 22)
	rare_label.modulate = Color(1.0, 0.88, 0.62)
	app._view_container().add_child(rare_label)
	for i in range(clamp(rarity, 1, 5)):
		app._draw_image(UI_COMMON_STAR, pos + Vector2(158 + i * 34, 98) * scale, Vector2(44, 44) * scale, false, Color(1, 1, 1, 0.95))

	_draw_hero_detail_section_header("屬性詳情", pos + Vector2(16, 187) * scale, Vector2(510, 30) * scale)
	var entries := [
		["攻擊", str(attrs.get("攻擊", ""))],
		["防禦", str(attrs.get("防禦", ""))],
		["命中", str(attrs.get("命中", ""))],
		["暴擊", str(attrs.get("暴擊", ""))],
		["生命", str(attrs.get("生命", ""))],
		["速度", str(attrs.get("速度", ""))],
		["抗暴", str(attrs.get("抗暴", ""))],
		["戰力", str(attrs.get("戰力", ""))],
	]
	for index in range(entries.size()):
		var col := index / 4
		var row := index % 4
		var item: Array = entries[index]
		var item_pos := pos + Vector2(23 + col * 250, 232 + row * 30) * scale
		_draw_hero_detail_attr(str(item[0]), str(item[1]), item_pos, scale)


func _draw_hero_detail_summary(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var copies := int(app.save.get("owned", {}).get(key, 0))
	var shards := int(app.save.get("shards", {}).get(key, 0))
	var owned := copies > 0

	app._draw_image(UI_COMMON_HEAD_FRAME, pos, Vector2(118, 118), false, Color(1, 1, 1, 0.92))
	app._draw_hero_round_thumb(hero, pos + Vector2(10, 10), Vector2(98, 98), Color(1, 1, 1, 1) if owned else Color(0.48, 0.48, 0.50, 1))

	var title: Label = app._label(str(hero.get("name", "角色")), 34)
	title.position = pos + Vector2(136, 4)
	title.size = Vector2(240, 48)
	title.modulate = Color(1.0, 0.92, 0.76)
	app._view_container().add_child(title)

	var spine: Label = app._label("Spine  %s" % str(hero.get("spine", "")), 17)
	spine.position = pos + Vector2(138, 52)
	spine.size = Vector2(280, 26)
	spine.modulate = Color(0.90, 0.84, 0.78)
	app._view_container().add_child(spine)

	app._view_container().add_child(app._panel(pos + Vector2(388, 10), Vector2(98, 44), app._rarity_color(rarity, 0.50)))
	var rare_label: Label = app._label("R%d" % rarity, 20, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(388, 18)
	rare_label.size = Vector2(98, 28)
	rare_label.modulate = Color(1.0, 0.92, 0.72)
	app._view_container().add_child(rare_label)
	_draw_hero_card_stars(rarity, pos + Vector2(136, 86), 28)

	var state_text := "已獲得  持有 %d  碎片 %d" % [copies, shards] if owned else "未獲得  碎片 %d" % shards
	var state: Label = app._label(state_text, 18)
	state.position = pos + Vector2(300, 88)
	state.size = Vector2(220, 28)
	state.modulate = Color(1.0, 0.82, 0.58)
	app._view_container().add_child(state)

	var power_panel: ColorRect = app._panel(pos + Vector2(0, 144), Vector2(496, 52), Color(0.07, 0.052, 0.075, 0.78))
	app._view_container().add_child(power_panel)
	var power: Label = app._label("戰力  %d" % _hero_power(hero), 24)
	power.position = pos + Vector2(22, 152)
	power.size = Vector2(190, 36)
	power.modulate = Color(1.0, 0.82, 0.45)
	app._view_container().add_child(power)
	var route: Label = app._label("獲得途徑  喚靈 / 祈願 / 活動", 17, HORIZONTAL_ALIGNMENT_RIGHT)
	route.position = pos + Vector2(214, 156)
	route.size = Vector2(260, 30)
	route.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(route)


func _draw_hero_detail_notice(pos: Vector2) -> void:
	var notice := str(app.save.get("hero_detail_notice", ""))
	if notice.is_empty():
		return
	var note: Label = app._label(notice, 16, HORIZONTAL_ALIGNMENT_CENTER)
	note.position = pos
	note.size = Vector2(496, 28)
	note.modulate = Color(1.0, 0.88, 0.58)
	app._view_container().add_child(note)


func _draw_hero_detail_info_panel(hero: Dictionary, pos: Vector2) -> void:
	var scale := HERO_DETAIL_INFO_SCALE
	_draw_hero_detail_section_header("技能列表", pos + Vector2(0, 88) * scale, Vector2(510, 30) * scale)
	var skill_paths: Array = hero.get("skillResources", [])
	for i in range(4):
		var icon_pos := pos + Vector2(42 + i * 110.0, 132) * scale
		var icon_size := Vector2(84, 84) * scale
		app._draw_image(UI_COMMON_SKILL_FRAME, icon_pos, icon_size, false, Color(1, 1, 1, 0.82))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(7, 7), icon_size - Vector2(14, 14), false)
		var skill_label: Label = app._label("技能%d" % (i + 1), 11, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(-2, 42)
		skill_label.size = Vector2(46, 18)
		app._view_container().add_child(skill_label)

	_draw_hero_detail_section_header("靈裝 / 源神 / 神具", pos + Vector2(0, 242) * scale, Vector2(510, 30) * scale)
	var equip: Label = app._label("MVP 裝備槽位已按 HeroDetailInfoView 區塊預留，後續接裝備表即可填充。", 14)
	equip.position = pos + Vector2(20, 280) * scale
	equip.size = Vector2(238, 42)
	equip.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(equip)


func _draw_hero_detail_tab_content(hero: Dictionary, pos: Vector2) -> void:
	match hero_detail_tab:
		"core":
			_draw_hero_core_tab(hero, pos)
		"attrs":
			_draw_hero_attrs_tab(hero, pos)
		"skills":
			_draw_hero_skills_tab(hero, pos)
		"equip":
			_draw_hero_equip_tab(hero, pos)
		"bond":
			_draw_hero_bond_tab(hero, pos)
		_:
			_draw_hero_detail_info_panel(hero, pos)


func _draw_hero_attrs_tab(hero: Dictionary, pos: Vector2) -> void:
	var scale := HERO_DETAIL_INFO_SCALE
	_draw_hero_detail_section_header("屬性成長", pos, Vector2(510, 30) * scale)
	_draw_hero_detail_section_header("培養操作", pos + Vector2(520, 0) * scale, Vector2(500, 30) * scale)
	var attrs := _hero_attrs(hero)
	var index := 0
	for key in attrs.keys():
		var col := index / 4
		var row := index % 4
		var cell_pos := pos + Vector2(23 + col * 250.0, 48 + row * 30.0) * scale
		_draw_hero_detail_attr(str(key), str(attrs[key]), cell_pos, scale)
		index += 1
	var hero_id := int(hero.get("id", 0))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	app._add_action_button("培養 +1", pos + Vector2(302, 74), func() -> void:
		_train_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("升星", pos + Vector2(302, 126), func() -> void:
		_promote_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	var tip: Label = app._label("等級 Lv.%d\n培養會提升本地戰力，升星消耗碎片。" % level, 15)
	tip.position = pos + Vector2(302, 178)
	tip.size = Vector2(196, 48)
	tip.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(tip)


func _draw_hero_core_tab(hero: Dictionary, pos: Vector2) -> void:
	_draw_hero_detail_section_header("核心", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	_draw_hero_detail_section_header("核心操作", pos + Vector2(520, 0) * HERO_DETAIL_INFO_SCALE, Vector2(500, 30) * HERO_DETAIL_INFO_SCALE)
	var hero_id := int(hero.get("id", 0))
	var core_levels: Dictionary = _hero_state_dict("hero_core_levels")
	var center: Vector2 = pos + Vector2(156, 118)
	app._draw_hero_round_thumb(hero, center - Vector2(34, 34), Vector2(68, 68), Color(1, 1, 1, 1))
	app._draw_image(UI_COMMON_HERO_HEAD_FRAME, center - Vector2(34, 34), Vector2(68, 68), false, Color(1, 1, 1, 0.90))
	var slots := [
		Vector2(-116, -56),
		Vector2(116, -56),
		Vector2(-116, 56),
		Vector2(116, 56),
	]
	for index in range(slots.size()):
		var slot: int = index + 1
		var slot_key := _hero_slot_key(hero_id, slot)
		var level: int = int(core_levels.get(slot_key, 0))
		var slot_offset: Vector2 = slots[index]
		var slot_pos: Vector2 = center + slot_offset - Vector2(30, 30)
		app._draw_image(UI_COMMON_SKILL_FRAME, slot_pos + Vector2(4, 4), Vector2(52, 52), false, Color(1.0, 0.82, 0.36, 0.40 if level <= 0 else 0.86))
		var title: Label = app._label(str(slot), 15, HORIZONTAL_ALIGNMENT_CENTER)
		title.position = slot_pos + Vector2(10, 8)
		title.size = Vector2(40, 20)
		app._view_container().add_child(title)
		var level_label: Label = app._label("Lv.%d" % level, 11, HORIZONTAL_ALIGNMENT_CENTER)
		level_label.position = slot_pos + Vector2(4, 36)
		level_label.size = Vector2(52, 16)
		level_label.modulate = Color(1.0, 0.92, 0.68)
		app._view_container().add_child(level_label)
		var target_slot: int = slot
		app._add_hit_button(slot_pos, Vector2(60, 60), func() -> void:
			_upgrade_hero_core(hero_id, target_slot)
		)
	app._add_action_button("一鍵核心", pos + Vector2(302, 74), func() -> void:
		_upgrade_all_hero_cores(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("核心詳情", pos + Vector2(302, 126), func() -> void:
		_set_hero_notice("核心位對應原版 pnlCore/btnPos1-4")
		app._persist()
		_show_hero_detail(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	var total: int = _hero_core_total(hero_id)
	var tip: Label = app._label("四個核心位可點擊升級。\n核心總等級 %d，會提升戰力。" % total, 15)
	tip.position = pos + Vector2(302, 178)
	tip.size = Vector2(198, 48)
	tip.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(tip)


func _draw_hero_skills_tab(hero: Dictionary, pos: Vector2) -> void:
	_draw_hero_detail_section_header("技能", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	_draw_hero_detail_section_header("技能操作", pos + Vector2(520, 0) * HERO_DETAIL_INFO_SCALE, Vector2(500, 30) * HERO_DETAIL_INFO_SCALE)
	var hero_id := int(hero.get("id", 0))
	var skill_paths: Array = hero.get("skillResources", [])
	var selected_skill: int = clampi(int(app.save.get("hero_selected_skill", 0)), 0, 3)
	for i in range(4):
		var icon_pos: Vector2 = pos + Vector2(34 + i * 58.0, 74)
		if i == selected_skill:
			app._view_container().add_child(app._panel(icon_pos - Vector2(4, 4), Vector2(56, 78), Color(0.86, 0.60, 0.24, 0.24)))
		app._draw_image(UI_COMMON_SKILL_FRAME, icon_pos, Vector2(48, 48), false, Color(1, 1, 1, 0.78))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(4, 4), Vector2(40, 40), false)
		var skill_level: int = _hero_skill_level(hero_id, i)
		var skill_label: Label = app._label("Lv.%d" % skill_level, 12, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(-2, 50)
		skill_label.size = Vector2(52, 20)
		app._view_container().add_child(skill_label)
		var skill_index: int = i
		app._add_hit_button(icon_pos, Vector2(48, 70), func() -> void:
			_select_hero_skill(hero_id, skill_index)
		)
	app._add_action_button("升級技能%d" % (selected_skill + 1), pos + Vector2(302, 74), func() -> void:
		_upgrade_hero_skill(hero_id, selected_skill)
	, Vector2(150, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("查看演示", pos + Vector2(302, 126), func() -> void:
		app.save["hero_last_skill_preview"] = "%s:%d" % [hero_id, selected_skill]
		_set_hero_notice("已標記技能 %d 演示" % (selected_skill + 1))
		app._persist()
		_show_hero_detail(hero_id)
	, Vector2(150, 42), UI_COMMON_BTN_WHITE)
	var desc: Label = app._label("當前選中技能 %d。升級會記錄技能等級並刷新詳情。" % (selected_skill + 1), 15)
	desc.position = pos + Vector2(302, 182)
	desc.size = Vector2(196, 42)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)


func _draw_hero_equip_tab(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var sections: Array = [
		{"key": "equip", "title": "靈裝"},
		{"key": "slug", "title": "源神"},
		{"key": "weapon", "title": "神具"},
	]
	for index in range(sections.size()):
		var section: Dictionary = sections[index]
		var section_pos: Vector2 = pos + Vector2(18 + index * 170.0, 18)
		_draw_hero_section_header(str(section.get("title", "")), section_pos, Vector2(150, 30))
		for slot_index in range(2):
			var slot: int = slot_index + 1
			var item_pos: Vector2 = section_pos + Vector2(14 + slot_index * 68.0, 54)
			var level: int = _hero_equipment_level(hero_id, str(section.get("key", "")), slot)
			app._draw_image(UI_COMMON_SKILL_FRAME, item_pos, Vector2(58, 58), false, Color(1.0, 0.86, 0.28, 0.42 if level <= 0 else 0.88))
			var symbol: Label = app._label(_hero_equipment_symbol(str(section.get("key", ""))), 22, HORIZONTAL_ALIGNMENT_CENTER)
			symbol.position = item_pos + Vector2(4, 12)
			symbol.size = Vector2(50, 28)
			symbol.modulate = Color(1.0, 0.94, 0.70)
			app._view_container().add_child(symbol)
			var level_label: Label = app._label("Lv.%d" % level, 11, HORIZONTAL_ALIGNMENT_CENTER)
			level_label.position = item_pos + Vector2(2, 42)
			level_label.size = Vector2(54, 14)
			app._view_container().add_child(level_label)
			var target_kind: String = str(section.get("key", "equip"))
			var target_slot: int = slot
			app._add_hit_button(item_pos, Vector2(58, 58), func() -> void:
				_upgrade_hero_equipment(hero_id, target_kind, target_slot)
			)
	app._add_action_button("一鍵強化", pos + Vector2(302, 154), func() -> void:
		_upgrade_all_hero_equipment(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	var total: int = _hero_equipment_total(hero_id)
	var desc: Label = app._label("依 HeroDetailInfoView 的靈裝/源神/神具三區塊還原。\n點擊任一槽位可強化，總等級 %d。" % total, 15)
	desc.position = pos + Vector2(28, 158)
	desc.size = Vector2(250, 56)
	desc.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(desc)


func _draw_hero_bond_tab(hero: Dictionary, pos: Vector2) -> void:
	_draw_hero_detail_section_header("羈絆", pos, Vector2(510, 30) * HERO_DETAIL_INFO_SCALE)
	_draw_hero_detail_section_header("互動入口", pos + Vector2(520, 0) * HERO_DETAIL_INFO_SCALE, Vector2(500, 30) * HERO_DETAIL_INFO_SCALE)
	var hero_id := int(hero.get("id", 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var favorite := _favorite_heroes().has(str(hero_id))
	var lines := [
		"羈絆等級 Lv.%d" % bond,
		"收藏狀態：%s" % ("已收藏" if favorite else "未收藏"),
		"主看板：%s" % ("是" if int(app.save.get("selected_hero_id", DEFAULT_HERO_ID)) == hero_id else "否"),
		"Gal 看板：%s" % ("是" if int(app.save.get("selected_gal_hero_id", 0)) == hero_id else "否"),
	]
	for index in range(lines.size()):
		var label: Label = app._label(str(lines[index]), 16)
		label.position = pos + Vector2(34, 70 + index * 34)
		label.size = Vector2(220, 28)
		label.modulate = Color(0.96, 0.88, 0.82)
		app._view_container().add_child(label)
	app._add_action_button("羈絆 +1", pos + Vector2(302, 74), func() -> void:
		_raise_hero_bond(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_GOLD)
	app._add_action_button("進入Gal", pos + Vector2(302, 126), func() -> void:
		_set_hero_as_gal(hero_id, true)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)
	app._add_action_button("收藏切換", pos + Vector2(302, 178), func() -> void:
		_toggle_favorite_hero(hero_id)
	, Vector2(132, 42), UI_COMMON_BTN_WHITE)


func _draw_hero_detail_nav(hero_id: int) -> void:
	var filtered: Array = _gallery_filtered_heroes()
	if filtered.is_empty():
		filtered = app.heroes
	if filtered.is_empty():
		return
	var index := _hero_index_in_list(filtered, hero_id)
	if index < 0:
		index = 0
	var prev_hero: Dictionary = filtered[posmod(index - 1, filtered.size())]
	var next_hero: Dictionary = filtered[posmod(index + 1, filtered.size())]
	var prev_id := int(prev_hero.get("id", hero_id))
	var next_id := int(next_hero.get("id", hero_id))
	app._add_action_button("<", Vector2(276, 636), func() -> void:
		_show_hero_detail(prev_id)
	, Vector2(48, 44), UI_COMMON_BTN_WHITE)
	app._add_action_button(">", Vector2(800, 636), func() -> void:
		_show_hero_detail(next_id)
	, Vector2(48, 44), UI_COMMON_BTN_WHITE)


func _draw_hero_attr(label_text: String, value_text: String, pos: Vector2) -> void:
	var label: Label = app._label(label_text, 15)
	label.position = pos
	label.size = Vector2(66, 24)
	label.modulate = Color(0.92, 0.86, 0.80)
	app._view_container().add_child(label)
	var value: Label = app._label(value_text, 15, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(58, 0)
	value.size = Vector2(52, 24)
	value.modulate = Color(1.0, 0.86, 0.60)
	app._view_container().add_child(value)


func _draw_hero_section_header(text: String, pos: Vector2, size: Vector2) -> void:
	app._draw_image(UI_COMMON_SECTION, pos, size, true, Color(1, 1, 1, 0.78))
	var label: Label = app._label(text, 15, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = size
	label.modulate = Color(1.0, 0.92, 0.78)
	app._view_container().add_child(label)


func _draw_hero_detail_section_header(text: String, pos: Vector2, size: Vector2) -> void:
	app._draw_image(UI_COMMON_SECTION, pos, size, true, Color(1, 1, 1, 0.78))
	var label: Label = app._label(text, 13, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = size
	label.modulate = Color(1.0, 0.92, 0.78)
	app._view_container().add_child(label)


func _draw_hero_detail_attr(label_text: String, value_text: String, pos: Vector2, scale: float) -> void:
	var label: Label = app._label(label_text, 12)
	label.position = pos
	label.size = Vector2(72, 18)
	label.modulate = Color(0.92, 0.86, 0.80)
	app._view_container().add_child(label)
	var value: Label = app._label(value_text, 12, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(86, 0) * scale
	value.size = Vector2(56, 18)
	value.modulate = Color(1.0, 0.86, 0.60)
	app._view_container().add_child(value)


func _draw_hero_card_stars(rarity: int, pos: Vector2, size: int) -> void:
	if size < 20:
		for i in range(clamp(rarity, 1, 5)):
			app._draw_image(UI_HERO_STAR_SMALL, pos + Vector2(i * float(size), 0), Vector2(size, size), false, Color(1, 1, 1, 0.94))
		return
	for i in range(clamp(rarity, 1, 5)):
		var star_path := UI_COMMON_STAR if size >= 20 else UI_HERO_STAR_SMALL
		app._draw_image(star_path, pos + Vector2(i * (size * 0.74), 0), Vector2(size, size), false, Color(1, 1, 1, 0.96))


func _hero_power(hero: Dictionary) -> int:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var owned := int(app.save.get("owned", {}).get(str(hero_id), 0))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var promotion := int(app.save.get("hero_promotions", {}).get(str(hero_id), 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var core_total := _hero_core_total(hero_id)
	var equipment_total := _hero_equipment_total(hero_id)
	var skill_total := 0
	for skill_index in range(4):
		skill_total += _hero_skill_level(hero_id, skill_index)
	return 2600 + rarity * 920 + max(owned, 1) * 360 + (hero_id % 100) * 13 + level * 45 + promotion * 320 + bond * 60 + skill_total * 28 + core_total * 54 + equipment_total * 42


func _hero_attrs(hero: Dictionary) -> Dictionary:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var level := int(app.save.get("hero_levels", {}).get(str(hero_id), 1))
	var promotion := int(app.save.get("hero_promotions", {}).get(str(hero_id), 0))
	var bond := int(app.save.get("hero_bonds", {}).get(str(hero_id), 0))
	var core_total := _hero_core_total(hero_id)
	var equipment_total := _hero_equipment_total(hero_id)
	var power := _hero_power(hero)
	return {
		"攻擊": 900 + rarity * 220 + level * 18 + promotion * 70 + equipment_total * 12,
		"防禦": 520 + rarity * 150 + level * 10 + promotion * 46 + core_total * 8,
		"生命": 5200 + rarity * 1280 + level * 160 + promotion * 520 + core_total * 96,
		"速度": 92 + rarity * 7,
		"命中": "%d%%" % (82 + rarity * 3 + min(bond, 10)),
		"暴擊": "%d%%" % (12 + rarity * 4 + promotion * 2),
		"抗暴": "%d%%" % (8 + rarity * 3),
		"戰力": power,
	}


func _hero_unlock_shard_cost(hero: Dictionary) -> int:
	var rarity := int(hero.get("rarity", 1))
	if rarity >= 5:
		return 30
	if rarity >= 4:
		return 20
	return 12


func _hero_state_dict(key: String) -> Dictionary:
	var data = app.save.get(key, {})
	return data if typeof(data) == TYPE_DICTIONARY else {}


func _hero_slot_key(hero_id: int, slot: int) -> String:
	return "%d:%d" % [hero_id, slot]


func _hero_equipment_key(hero_id: int, kind: String, slot: int) -> String:
	return "%d:%s:%d" % [hero_id, kind, slot]


func _favorite_heroes() -> Array:
	var data = app.save.get("favorite_hero_ids", [])
	return data if typeof(data) == TYPE_ARRAY else []


func _set_hero_notice(text: String) -> void:
	app.save["hero_detail_notice"] = text


func _unlock_hero_with_shards(hero_id: int) -> void:
	var hero: Dictionary = app._hero_by_id(hero_id)
	var key := str(hero_id)
	var shards := _hero_state_dict("shards")
	var owned := _hero_state_dict("owned")
	var cost := _hero_unlock_shard_cost(hero)
	if int(shards.get(key, 0)) < cost:
		_set_hero_notice("碎片不足，召喚需要 %d" % cost)
	else:
		shards[key] = int(shards.get(key, 0)) - cost
		owned[key] = max(1, int(owned.get(key, 0)))
		app.save["shards"] = shards
		app.save["owned"] = owned
		app.save["selected_hero_id"] = hero_id
		_set_hero_notice("已使用碎片召喚")
	app._persist()
	_show_hero_detail(hero_id)


func _set_hero_as_wallpaper(hero_id: int) -> void:
	app.save["selected_hero_id"] = hero_id
	_set_hero_notice("已設為主界面看板")
	app._persist()
	_show_hero_detail(hero_id)


func _set_hero_as_gal(hero_id: int, open_gal := false) -> void:
	app.save["selected_gal_hero_id"] = hero_id
	_set_hero_notice("已設為 Gal 看板")
	app._persist()
	if open_gal:
		app._show_gal()
	else:
		_show_hero_detail(hero_id)


func _toggle_favorite_hero(hero_id: int) -> void:
	var key := str(hero_id)
	var favorites := _favorite_heroes().duplicate()
	if favorites.has(key):
		favorites.erase(key)
		_set_hero_notice("已取消收藏")
	else:
		favorites.append(key)
		_set_hero_notice("已加入收藏")
	app.save["favorite_hero_ids"] = favorites
	app._persist()
	_show_hero_detail(hero_id)


func _train_hero(hero_id: int) -> void:
	var key := str(hero_id)
	var levels := _hero_state_dict("hero_levels")
	var next_level: int = min(120, int(levels.get(key, 1)) + 1)
	levels[key] = next_level
	app.save["hero_levels"] = levels
	_set_hero_notice("培養成功，Lv.%d" % next_level)
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_hero_core(hero_id: int, slot: int) -> void:
	var levels := _hero_state_dict("hero_core_levels")
	var key := _hero_slot_key(hero_id, slot)
	var next_level: int = min(15, int(levels.get(key, 0)) + 1)
	levels[key] = next_level
	app.save["hero_core_levels"] = levels
	_set_hero_notice("核心位 %d 升至 Lv.%d" % [slot, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_all_hero_cores(hero_id: int) -> void:
	var levels := _hero_state_dict("hero_core_levels")
	for slot in range(1, 5):
		var key := _hero_slot_key(hero_id, slot)
		levels[key] = min(15, int(levels.get(key, 0)) + 1)
	app.save["hero_core_levels"] = levels
	_set_hero_notice("四個核心位已強化")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_core_total(hero_id: int) -> int:
	var levels := _hero_state_dict("hero_core_levels")
	var total := 0
	for slot in range(1, 5):
		total += int(levels.get(_hero_slot_key(hero_id, slot), 0))
	return total


func _hero_equipment_symbol(kind: String) -> String:
	match kind:
		"slug":
			return "源"
		"weapon":
			return "具"
		_:
			return "裝"


func _hero_equipment_level(hero_id: int, kind: String, slot: int) -> int:
	var levels := _hero_state_dict("hero_equipment_levels")
	return int(levels.get(_hero_equipment_key(hero_id, kind, slot), 0))


func _upgrade_hero_equipment(hero_id: int, kind: String, slot: int) -> void:
	var levels := _hero_state_dict("hero_equipment_levels")
	var key := _hero_equipment_key(hero_id, kind, slot)
	var next_level: int = min(20, int(levels.get(key, 0)) + 1)
	levels[key] = next_level
	app.save["hero_equipment_levels"] = levels
	_set_hero_notice("%s槽 %d 升至 Lv.%d" % [_hero_equipment_symbol(kind), slot, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_all_hero_equipment(hero_id: int) -> void:
	var levels := _hero_state_dict("hero_equipment_levels")
	for kind in ["equip", "slug", "weapon"]:
		for slot in range(1, 3):
			var key := _hero_equipment_key(hero_id, str(kind), slot)
			levels[key] = min(20, int(levels.get(key, 0)) + 1)
	app.save["hero_equipment_levels"] = levels
	_set_hero_notice("靈裝/源神/神具已一鍵強化")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_equipment_total(hero_id: int) -> int:
	var levels := _hero_state_dict("hero_equipment_levels")
	var total := 0
	for kind in ["equip", "slug", "weapon"]:
		for slot in range(1, 3):
			total += int(levels.get(_hero_equipment_key(hero_id, str(kind), slot), 0))
	return total


func _promote_hero(hero_id: int) -> void:
	var key := str(hero_id)
	var shards := _hero_state_dict("shards")
	var promotions := _hero_state_dict("hero_promotions")
	var current := int(promotions.get(key, 0))
	var cost := 10 + current * 10
	if int(shards.get(key, 0)) < cost:
		_set_hero_notice("碎片不足，升星需要 %d" % cost)
	else:
		shards[key] = int(shards.get(key, 0)) - cost
		promotions[key] = current + 1
		app.save["shards"] = shards
		app.save["hero_promotions"] = promotions
		_set_hero_notice("升星成功，星級 +1")
	app._persist()
	_show_hero_detail(hero_id)


func _hero_skill_key(hero_id: int, skill_index: int) -> String:
	return "%d:%d" % [hero_id, skill_index]


func _hero_skill_level(hero_id: int, skill_index: int) -> int:
	var levels := _hero_state_dict("hero_skill_levels")
	return max(1, int(levels.get(_hero_skill_key(hero_id, skill_index), 1)))


func _select_hero_skill(hero_id: int, skill_index: int) -> void:
	app.save["hero_selected_skill_hero"] = hero_id
	app.save["hero_selected_skill"] = clampi(skill_index, 0, 3)
	_set_hero_notice("已選中技能 %d" % (clampi(skill_index, 0, 3) + 1))
	app._persist()
	_show_hero_detail(hero_id)


func _upgrade_hero_skill(hero_id: int, skill_index: int) -> void:
	var levels := _hero_state_dict("hero_skill_levels")
	var key := _hero_skill_key(hero_id, skill_index)
	var next_level: int = min(20, int(levels.get(key, 1)) + 1)
	levels[key] = next_level
	app.save["hero_skill_levels"] = levels
	_set_hero_notice("技能 %d 升至 Lv.%d" % [skill_index + 1, next_level])
	app._persist()
	_show_hero_detail(hero_id)


func _raise_hero_bond(hero_id: int) -> void:
	var key := str(hero_id)
	var bonds := _hero_state_dict("hero_bonds")
	var next_bond: int = min(30, int(bonds.get(key, 0)) + 1)
	bonds[key] = next_bond
	app.save["hero_bonds"] = bonds
	_set_hero_notice("羈絆提升至 Lv.%d" % next_bond)
	app._persist()
	_show_hero_detail(hero_id)


func _hero_index_in_list(list: Array, hero_id: int) -> int:
	for index in range(list.size()):
		var hero: Dictionary = list[index]
		if int(hero.get("id", 0)) == hero_id:
			return index
	return -1

func _gallery_filtered_heroes() -> Array:
	var list := []
	for hero in app.heroes:
		var hero_id := int(hero.get("id", 0))
		var rarity := int(hero.get("rarity", 1))
		var owned := int(app.save.get("owned", {}).get(str(hero_id), 0)) > 0
		var camp := _hero_camp_key(hero)
		var occupation := _hero_occupation_key(hero)
		var include := true
		match gallery_filter:
			"owned":
				include = owned
			"unowned":
				include = not owned
			"r4":
				include = rarity >= 4
			"r3":
				include = rarity == 3
			"r2":
				include = rarity <= 2
			_:
				include = true
		if gallery_camp_filter != "all" and camp != gallery_camp_filter:
			include = false
		if gallery_occupation_filter != "all" and occupation != gallery_occupation_filter:
			include = false
		if include:
			list.append(hero)
	list.sort_custom(_sort_gallery_heroes)
	return list

func _sort_heroes_by_level(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))
	var a_owned := int(app.save.get("owned", {}).get(str(a_id), 0)) > 0
	var b_owned := int(app.save.get("owned", {}).get(str(b_id), 0)) > 0
	if a_owned != b_owned:
		return a_owned
	var a_level := int(app.save.get("hero_levels", {}).get(str(a_id), 1))
	var b_level := int(app.save.get("hero_levels", {}).get(str(b_id), 1))
	if a_level != b_level:
		return a_level > b_level
	var a_rarity := int(a.get("rarity", 1))
	var b_rarity := int(b.get("rarity", 1))
	if a_rarity != b_rarity:
		return a_rarity > b_rarity
	var a_power := _hero_power(a)
	var b_power := _hero_power(b)
	if a_power != b_power:
		return a_power > b_power
	return a_id < b_id

func _sort_gallery_heroes(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))
	var a_owned := int(app.save.get("owned", {}).get(str(a_id), 0)) > 0
	var b_owned := int(app.save.get("owned", {}).get(str(b_id), 0)) > 0
	if a_owned != b_owned:
		return a_owned
	match gallery_sort_mode:
		"level":
			return _sort_heroes_by_level(a, b)
		"power":
			var a_power := _hero_power(a)
			var b_power := _hero_power(b)
			if a_power != b_power:
				return a_power > b_power
		_:
			pass
	var a_rarity := int(a.get("rarity", 1))
	var b_rarity := int(b.get("rarity", 1))
	if a_rarity != b_rarity:
		return a_rarity > b_rarity
	return a_id < b_id

func _gallery_sort_label(mode: String) -> String:
	match mode:
		"level":
			return "等級"
		"rarity":
			return "稀有"
		_:
			return "戰力"

func _hero_camp_key(hero: Dictionary) -> String:
	var hero_id := int(hero.get("id", 0))
	return "camp%d" % ((hero_id % 5) + 1)

func _hero_occupation_key(hero: Dictionary) -> String:
	var hero_id := int(hero.get("id", 0))
	return "occupation%d" % ((int(hero_id / 10) % 5) + 1)
