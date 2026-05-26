# UTF-8 source. LotteryDrawMainView first-screen reconstruction split from main.gd.
extends RefCounted

const UI_LOTTERY_ALPHA_L := "res://assets/ui/lottery/lottery_img_alpha_l.png"
const UI_LOTTERY_ALPHA_R := "res://assets/ui/lottery/lottery_img_alpha_r.png"
const UI_LOTTERY_BG_ADVANCED := "res://assets/ui/lottery/bg/lottery_bg_01.png"
const UI_LOTTERY_BG_EPIC := "res://assets/ui/lottery/bg/lottery_bg_03.png"
const UI_LOTTERY_BG_NORMAL := "res://assets/ui/lottery/bg/lottery_bg_02.png"
const UI_LOTTERY_BG_PRAYER := "res://assets/ui/lottery/bg/lottery_bg_08.png"
const UI_LOTTERY_BTN_SINGLE := "res://assets/ui/common/common_btn_46.png"
const UI_LOTTERY_BTN_TEN := "res://assets/ui/common/common_btn_47.png"
const UI_LOTTERY_ROLE_GROUP := "res://assets/ui/lottery/lottery_img_01.png"
const UI_LOTTERY_TAB_BG := "res://assets/ui/lottery/lottery_btn_01.png"
const UI_LOTTERY_TAB_HIGHLIGHT := "res://assets/ui/lottery/lottery_btn_03.png"
const UI_LOTTERY_TAB_CORNER := "res://assets/ui/lottery/lottery_btn_03a.png"
const UI_LOTTERY_WISH_BG := "res://assets/ui/lottery/lottery_img_05.png"
const UI_LOTTERY_COST_TICKET := "res://assets/ui/lottery/lottery_img_09.png"
const UI_LOTTERY_COST_GEM := "res://assets/ui/lottery/lottery_img_10.png"
const UI_LOTTERY_DRAW_COST := "res://assets/ui/lottery/lottery_img_42.png"
const UI_LOTTERY_POOL_FRAME := "res://assets/ui/lottery/lottery_img_55.png"
const UI_LOTTERY_PRAYER_FRAME := "res://assets/ui/lottery/lottery_img_57.png"
const UI_PRAYER_HOLY_RELIC_BOTTOM_FRAME := "res://assets/ui/lottery/lottery_img_76.png"
const UI_PRAYER_HOLY_RELIC_DIVIDER := "res://assets/ui/lottery/lottery_img_04.png"
const UI_PRAYER_HOLY_RELIC_FUNC_ICONS := [
	"res://assets/ui/lottery/lottery_btn_04.png",
	"res://assets/ui/lottery/lottery_btn_22.png",
	"res://assets/ui/lottery/lottery_btn_23.png",
	"res://assets/ui/lottery/lottery_btn_24.png",
]
const UI_PRAYER_HOLY_RELIC_INTEGRAL_BG := "res://assets/ui/lottery/lottery_img_95.png"
const UI_PRAYER_HOLY_RELIC_INTEGRAL_ICON := "res://assets/ui/lottery/lottery_btn_25.png"
const UI_PRAYER_HOLY_RELIC_INTEGRAL_FINISH := "res://assets/ui/lottery/lottery_img_115.png"
const UI_PRAYER_HOLY_RELIC_TAB_SELECT := "res://assets/ui/lottery/lottery_img_77.png"
const UI_PRAYER_HOLY_RELIC_TABS := [
	{"label": "遺器祈願", "count": "x9", "bg": "res://assets/ui/lottery/lottery_img_75.png", "icon": "res://assets/ui/lottery/lottery_btn_29.png", "select_icon": "res://assets/ui/lottery/lottery_btn_30.png"},
	{"label": "自選遺器", "count": "x0", "bg": "res://assets/ui/lottery/lottery_img_96.png", "icon": "res://assets/ui/lottery/lottery_btn_31.png", "select_icon": "res://assets/ui/lottery/lottery_btn_32.png"},
	{"label": "源神祈願", "count": "x0", "bg": "res://assets/ui/lottery/lottery_img_74.png", "icon": "res://assets/ui/lottery/lottery_btn_33.png", "select_icon": "res://assets/ui/lottery/lottery_btn_34.png"},
	{"label": "聖源祈願", "count": "x0", "bg": "res://assets/ui/lottery/lottery_img_97.png", "icon": "res://assets/ui/lottery/lottery_btn_35.png", "select_icon": "res://assets/ui/lottery/lottery_btn_36.png"},
]
const UI_LOTTERY_TICKET_ICON := "res://assets/ui/item/draw_01.png"
const UI_LOTTERY_GEM_ICON := "res://assets/ui/item/draw_05.png"
const UI_LOTTERY_PRAYER_KEY := "res://assets/ui/item/draw_07.png"
const UI_LOTTERY_PRAYER_ORB := "res://assets/ui/lottery/lottery_img_63.png"
const UI_LOTTERY_PRAYER_GLOW := "res://assets/ui/lottery/lottery_img_64.png"
const UI_LOTTERY_PRAYER_DISC := "res://assets/ui/lottery/lottery_img_66e.png"
const UI_LOTTERY_PRAYER_CARD := "res://assets/ui/lottery/lottery_img_141.png"
const UI_LOTTERY_PRAYER_DECOR := "res://assets/ui/lottery/lottery_img_135.png"
const UI_LOTTERY_WISH_SLOT := "res://assets/ui/common/common_img_71.png"
const UI_LOTTERY_WISH_ADD := "res://assets/ui/common/common_img_72.png"
const UI_LOTTERY_WISH_COLOR_A := "res://assets/ui/common/common_img_66.png"
const UI_LOTTERY_WISH_COLOR_B := "res://assets/ui/common/common_img_67.png"
const UI_LOTTERY_CHECK_OFF := "res://assets/ui/common/Resources_gouxuan_01.png"
const UI_LOTTERY_CHECK_ON := "res://assets/ui/common/Resources_gouxuan_02.png"
const UI_LOTTERY_CHECK_OFF_PANEL := "res://assets/ui/common/common_btn_09.png"
const UI_LOTTERY_CHECK_ON_PANEL := "res://assets/ui/common/common_btn_10.png"
const UI_LOTTERY_FUNC_ICONS := [
	"res://assets/ui/lottery/lottery_img_11.png",
	"res://assets/ui/lottery/lottery_img_12.png",
	"res://assets/ui/lottery/lottery_img_13.png",
	"res://assets/ui/lottery/lottery_img_14.png",
	"res://assets/ui/lottery/lottery_img_61.png",
]
const LOTTERY_PREFAB_SIZE := Vector2(1670, 750)
const LOTTERY_SCALE := Vector2(1280.0 / 1670.0, 720.0 / 750.0)
const LOTTERY_BTN_WHITE := "res://assets/ui/common/tongyong_btn_01.png"

var app

func _init(app_ref) -> void:
	app = app_ref


func _lottery_size(prefab_size: Vector2) -> Vector2:
	return Vector2(prefab_size.x * LOTTERY_SCALE.x, prefab_size.y * LOTTERY_SCALE.y)


func _lottery_center_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((835.0 + center.x - size.x * 0.5) * LOTTERY_SCALE.x, (375.0 - center.y - size.y * 0.5) * LOTTERY_SCALE.y)


func _lottery_right_bottom_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((1670.0 + center.x - size.x * 0.5) * LOTTERY_SCALE.x, (750.0 - center.y - size.y * 0.5) * LOTTERY_SCALE.y)


func _lottery_left_bottom_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((center.x - size.x * 0.5) * LOTTERY_SCALE.x, (750.0 - center.y - size.y * 0.5) * LOTTERY_SCALE.y)


func _lottery_child_pos(parent_center: Vector2, child_center: Vector2, child_size: Vector2) -> Vector2:
	return _lottery_center_pos(parent_center + child_center, child_size)


func show_gacha() -> void:
	var pool = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var realm = app._active_gacha_realm()
	app._set_chrome_visible(false)
	app._clear("現世" if realm == "present" else "祈願")
	app._draw_image(lottery_bg_for_pool(str(pool.get("id", "normal"))), Vector2(0, 0), Vector2(1280, 720), true)
	if realm == "prayer":
		draw_prayer_screen(pool)
		return
	app._draw_image(UI_LOTTERY_ROLE_GROUP, _lottery_center_pos(Vector2(0, 0), LOTTERY_PREFAB_SIZE), Vector2(1280, 720), false)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.014, 0.016, 0.04)))

	draw_header_resources()
	draw_pool_tabs(realm)
	draw_top_buttons()
	draw_pool_panel(pool, realm)
	draw_wish_panel(pool, realm)
	draw_draw_buttons(pool)
	app._add_action_button("◀  返回", Vector2(44, 18), app._show_home, Vector2(118, 38), LOTTERY_BTN_WHITE)
	app._add_action_button("?", Vector2(174, 18), app._show_player_info, Vector2(42, 38), LOTTERY_BTN_WHITE)

func draw_header_resources() -> void:
	var ticket_icon := UI_LOTTERY_PRAYER_KEY if app._active_gacha_realm() == "prayer" else UI_LOTTERY_TICKET_ICON
	var resources := [
		{"icon": ticket_icon, "value": str(app.save.get("tickets", 0)), "pos": Vector2(1168, 30)},
		{"icon": UI_LOTTERY_GEM_ICON, "value": str(app.save.get("gems", 0)), "pos": Vector2(1006, 30)},
	]
	for item in resources:
		var pos: Vector2 = item.get("pos", Vector2.ZERO)
		app._view_container().add_child(app._panel(pos - Vector2(88, 14), Vector2(134, 28), Color(0.02, 0.018, 0.03, 0.50)))
		app._draw_image(str(item.get("icon", "")), pos - Vector2(72, 17), Vector2(26, 30), false)
		var value: Label = app._label(str(item.get("value", "0")), 18, HORIZONTAL_ALIGNMENT_RIGHT)
		value.position = pos - Vector2(42, 13)
		value.size = Vector2(70, 26)
		app._view_container().add_child(value)
		app._add_action_button("+", pos + Vector2(34, -17), func() -> void: _show_gacha_shop(), Vector2(30, 30))


func draw_top_buttons() -> void:
	var labels := ["概率公示", "召喚商店", "碎片商店", "陣容推薦", "積分抽獎"]
	var callbacks := [
		func() -> void: app._show_gacha_rate(),
		func() -> void: _show_gacha_shop(),
		func() -> void: _show_gacha_shard_shop(),
		func() -> void: _show_gacha_formation(),
		func() -> void: _show_gacha_integral(),
	]
	if app._active_gacha_realm() == "prayer":
		labels = ["概率公示", "祈願商城", "遺器養成"]
		callbacks = [
			func() -> void: app._show_gacha_rate(),
			func() -> void: _show_gacha_shop(),
			func() -> void: app._show_relics(),
		]
	var base_pos := _lottery_left_bottom_pos(Vector2(64, 78), Vector2(60, 60))
	for index in range(labels.size()):
		var pos := base_pos + Vector2(index * 58, 0)
		app._draw_image(str(UI_LOTTERY_FUNC_ICONS[index % UI_LOTTERY_FUNC_ICONS.size()]), pos, Vector2(52, 52), false, Color(1, 1, 1, 0.88))
		var label: Label = app._label(labels[index], 13, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + Vector2(-10, 48)
		label.size = Vector2(74, 22)
		app._view_container().add_child(label)
		app._add_hit_button(pos, Vector2(60, 74), callbacks[index])
	if app._active_gacha_realm() != "prayer":
		var skip_pos := _lottery_right_bottom_pos(Vector2(-690, 73), Vector2(160, 36))
		app._draw_image(UI_LOTTERY_CHECK_ON if _skip_animation_enabled() else UI_LOTTERY_CHECK_OFF, skip_pos, Vector2(30, 22), false)
		var skip_label: Label = app._label("跳過動畫", 18, HORIZONTAL_ALIGNMENT_LEFT)
		skip_label.position = skip_pos + Vector2(34, -1)
		skip_label.size = Vector2(100, 26)
		skip_label.modulate = Color(0.24, 0.18, 0.10)
		app._view_container().add_child(skip_label)
		app._add_hit_button(skip_pos, Vector2(132, 34), func() -> void: _toggle_skip_animation())

func draw_prayer_screen(pool: Dictionary) -> void:
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.13, 0.085, 0.045, 0.18)))
	app._draw_image(UI_LOTTERY_PRAYER_DECOR, Vector2(212, -20), Vector2(360, 430), false, Color(1, 1, 1, 0.56))
	draw_header_resources()
	draw_pool_tabs("prayer")
	draw_prayer_hero_and_chest()
	draw_prayer_holy_relic_frame()
	draw_prayer_holy_relic_top_buttons()
	draw_prayer_right_panel(pool)
	draw_prayer_buttons(pool)
	draw_prayer_holy_relic_tabs()
	app._add_action_button("◀  返回", Vector2(44, 18), app._show_home, Vector2(118, 38), LOTTERY_BTN_WHITE)
	app._add_action_button("?", Vector2(174, 18), app._show_player_info, Vector2(42, 38), LOTTERY_BTN_WHITE)


func draw_prayer_holy_relic_frame() -> void:
	app._draw_image(UI_PRAYER_HOLY_RELIC_BOTTOM_FRAME, _lottery_left_bottom_pos(Vector2(835, 156.5), Vector2(1670, 313)), _lottery_size(Vector2(1670, 313)), false)
	app._draw_image(UI_PRAYER_HOLY_RELIC_DIVIDER, _lottery_left_bottom_pos(Vector2(835, 182.5), Vector2(1542, 7)), _lottery_size(Vector2(1542, 7)), false)


func draw_prayer_holy_relic_top_buttons() -> void:
	var items := [
		{"label": "概率公示", "icon": UI_PRAYER_HOLY_RELIC_FUNC_ICONS[0], "callback": func() -> void: app._show_gacha_rate()},
		{"label": "祈願商城", "icon": UI_PRAYER_HOLY_RELIC_FUNC_ICONS[1], "callback": func() -> void: _show_gacha_shop()},
		{"label": "儲值", "icon": UI_PRAYER_HOLY_RELIC_FUNC_ICONS[2], "callback": func() -> void: _show_gacha_shop()},
		{"label": "遺器", "icon": UI_PRAYER_HOLY_RELIC_FUNC_ICONS[3], "callback": func() -> void: app._show_relics()},
	]
	var base_pos := _lottery_left_bottom_pos(Vector2(64, 83.5), Vector2(60, 60))
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var pos := base_pos + _lottery_size(Vector2(index * 66, 0))
		app._draw_image(str(item.get("icon", "")), pos, _lottery_size(Vector2(60, 60)), false, Color(1, 1, 1, 0.95))
		var label: Label = app._label(str(item.get("label", "")), 13, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + _lottery_size(Vector2(-10, 58))
		label.size = _lottery_size(Vector2(80, 28))
		app._view_container().add_child(label)
		app._add_hit_button(pos, _lottery_size(Vector2(60, 84)), item.get("callback"))
	var integral_pos := base_pos + _lottery_size(Vector2(items.size() * 66, 0))
	app._draw_image(UI_PRAYER_HOLY_RELIC_INTEGRAL_BG, integral_pos, _lottery_size(Vector2(60, 60)), false, Color(1, 1, 1, 0.96))
	app._draw_image(UI_PRAYER_HOLY_RELIC_INTEGRAL_ICON, integral_pos + _lottery_size(Vector2(3, 3)), _lottery_size(Vector2(54, 54)), false, Color(1, 1, 1, 0.96))
	app._draw_image(UI_PRAYER_HOLY_RELIC_INTEGRAL_FINISH, integral_pos, _lottery_size(Vector2(60, 60)), false, Color(1, 1, 1, 0.25))
	var integral_label: Label = app._label("積分", 13, HORIZONTAL_ALIGNMENT_CENTER)
	integral_label.position = integral_pos + _lottery_size(Vector2(-10, 58))
	integral_label.size = _lottery_size(Vector2(80, 28))
	app._view_container().add_child(integral_label)
	app._add_hit_button(integral_pos, _lottery_size(Vector2(60, 84)), func() -> void: _show_gacha_integral())


func draw_prayer_hero_and_chest() -> void:
	var hero: Dictionary = app._hero_by_id(240102)
	app._draw_hero_stage(hero, Vector2(275, -18), Vector2(430, 500), false)
	app._draw_image(UI_LOTTERY_PRAYER_DISC, Vector2(260, 336), Vector2(560, 340), false, Color(1, 1, 1, 0.94))
	app._view_container().add_child(app._panel(Vector2(0, 432), Vector2(1280, 94), Color(1.0, 0.78, 0.38, 0.08)))


func draw_prayer_right_panel(pool: Dictionary) -> void:
	var title: Label = app._label(str(pool.get("name", "遺器祈願")), 44, HORIZONTAL_ALIGNMENT_RIGHT)
	title.position = Vector2(925, 92)
	title.size = Vector2(280, 58)
	title.modulate = Color(1, 1, 1, 0.98)
	app._view_container().add_child(title)
	var remain: int = max(int(pool.get("pityLimit", 30)) - app._pity(str(pool.get("id", "prayer"))), 0)
	var tip: Label = app._label("繼續祈願%d次\n必定獲得SSR遺器" % remain, 18, HORIZONTAL_ALIGNMENT_RIGHT)
	tip.position = Vector2(914, 150)
	tip.size = Vector2(286, 54)
	tip.modulate = Color(1, 1, 1, 0.96)
	app._view_container().add_child(tip)
	app._draw_image(UI_LOTTERY_PRAYER_GLOW, Vector2(1051, 222), Vector2(112, 112), false, Color(1.0, 0.92, 0.74, 0.88))
	app._draw_image(UI_LOTTERY_PRAYER_ORB, Vector2(1064, 235), Vector2(86, 86), false, Color(1, 1, 1, 0.96))
	var progress: Label = app._label("必出SSR+遺器\n2710/3000", 16, HORIZONTAL_ALIGNMENT_CENTER)
	progress.position = Vector2(1028, 326)
	progress.size = Vector2(154, 48)
	progress.modulate = Color(1, 1, 1, 0.96)
	app._view_container().add_child(progress)


func draw_prayer_buttons(pool: Dictionary) -> void:
	var one_size := _lottery_size(Vector2(324, 94))
	var ten_size := _lottery_size(Vector2(324, 94))
	var one_pos := _lottery_right_bottom_pos(Vector2(-544, 70), Vector2(324, 94))
	var ten_pos := _lottery_right_bottom_pos(Vector2(-214, 70), Vector2(324, 94))
	var skip_pos := _lottery_right_bottom_pos(Vector2(-830, 74.5), Vector2(32, 31))
	app._draw_image(UI_LOTTERY_CHECK_OFF_PANEL, skip_pos, _lottery_size(Vector2(32, 32)), false)
	if _skip_animation_enabled():
		app._draw_image(UI_LOTTERY_CHECK_ON_PANEL, skip_pos + _lottery_size(Vector2(1, 4)), _lottery_size(Vector2(29, 22)), false)
	var skip_label: Label = app._label("跳過動畫", 18, HORIZONTAL_ALIGNMENT_LEFT)
	skip_label.position = skip_pos + _lottery_size(Vector2(78.9, -13))
	skip_label.size = _lottery_size(Vector2(112, 28))
	skip_label.modulate = Color(0.24, 0.18, 0.10)
	app._view_container().add_child(skip_label)
	app._add_hit_button(skip_pos, _lottery_size(Vector2(164, 38)), func() -> void: _toggle_skip_animation())
	app._draw_image(UI_LOTTERY_BTN_SINGLE, one_pos, one_size, false)
	app._draw_image(UI_LOTTERY_BTN_TEN, ten_pos, ten_size, false)
	var one_cost: int = max(1, int(pool.get("ticketCost", 1)))
	_draw_draw_button_text(one_pos, "祈願1次", one_cost, Vector2(66, -26), 98.0, false)
	_draw_draw_button_text(ten_pos, "祈願10次", one_cost * 10, Vector2(42.9, -26), 120.0, true)
	app._add_hit_button(one_pos, one_size, func() -> void: _request_draw(1))
	app._add_hit_button(ten_pos, ten_size, func() -> void: _request_draw(10))
	var today: Label = app._label("今日剩餘次數：9979/9999", 15, HORIZONTAL_ALIGNMENT_RIGHT)
	today.position = Vector2(930, 674)
	today.size = Vector2(270, 28)
	app._view_container().add_child(today)


func draw_prayer_holy_relic_tabs() -> void:
	var base := _lottery_right_bottom_pos(Vector2(-64, 210), Vector2(0, 111))
	for index in range(UI_PRAYER_HOLY_RELIC_TABS.size()):
		var tab: Dictionary = UI_PRAYER_HOLY_RELIC_TABS[index]
		var size := _lottery_size(Vector2(104, 104))
		var pos := base - Vector2((index + 1) * (size.x + _lottery_size(Vector2(8, 0)).x), size.y * 0.5)
		var active := index == 0
		app._draw_image(str(tab.get("bg", "")), pos, size, false, Color(1, 1, 1, 0.96 if active else 0.72))
		app._draw_image(str(tab.get("icon", "")), pos + _lottery_size(Vector2(-7, -22)), _lottery_size(Vector2(118, 118)), false, Color(1, 1, 1, 0.92 if active else 0.48))
		if active:
			app._draw_image(UI_PRAYER_HOLY_RELIC_TAB_SELECT, pos + _lottery_size(Vector2(-3.5, -3.5)), _lottery_size(Vector2(111, 111)), false)
			app._draw_image(str(tab.get("select_icon", "")), pos + _lottery_size(Vector2(-7, -22)), _lottery_size(Vector2(118, 118)), false)
		var label: Label = app._label(str(tab.get("label", "")), 15, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + _lottery_size(Vector2(0, 67))
		label.size = _lottery_size(Vector2(104, 37))
		label.modulate = Color(1, 1, 1, 0.96 if active else 0.62)
		app._view_container().add_child(label)
		var count: Label = app._label(str(tab.get("count", "")), 16, HORIZONTAL_ALIGNMENT_RIGHT)
		count.position = pos + _lottery_size(Vector2(-52, 10))
		count.size = _lottery_size(Vector2(100, 37))
		count.modulate = Color(1, 1, 1, 0.92 if active else 0.56)
		app._view_container().add_child(count)
		app._add_hit_button(pos, size, func(tab := index) -> void:
			_show_lottery_notice("祈願分頁", "%s 對應 PrayerHolyRelicPanel/btnPrayer%d，待接完整分頁數據。" % [str(UI_PRAYER_HOLY_RELIC_TABS[tab].get("label", "")), tab + 1])
		)

func draw_pool_tabs(realm: String) -> void:
	var tab_centers := [Vector2(115, 188.8), Vector2(115, 92.8), Vector2(115, -3.2)]
	var tab_pools: Array = []
	for pool_item in app.pools:
		var pool_id := str(pool_item.get("id", "advanced"))
		if not app._pool_in_realm(pool_id, realm):
			continue
		tab_pools.append(pool_item)
	for index in range(min(tab_pools.size(), tab_centers.size())):
		var pool_item: Dictionary = tab_pools[index]
		var pool_id := str(pool_item.get("id", "advanced"))
		var active := pool_id == str(app.save.get("active_pool_id", "advanced"))
		var pos := _lottery_child_pos(Vector2(-835, 0), tab_centers[index], Vector2(216, 86))
		var size := _lottery_size(Vector2(216, 86))
		_draw_pool_tab(pool_item, pos, size, active, index)
		app._add_hit_button(pos, size, func() -> void:
			app.save["active_pool_id"] = pool_id
			app._persist()
			show_gacha()
		)


func _draw_pool_tab(pool_item: Dictionary, pos: Vector2, size: Vector2, active: bool, index: int) -> void:
	app._draw_image(UI_LOTTERY_TAB_BG, pos, size, false, Color(0.86, 0.92, 1.0, 0.92) if index == 0 else (Color(0.94, 0.80, 1.0, 0.90) if index == 1 else Color(0.74, 0.88, 1.0, 0.86)))
	var title_pic := str(pool_item.get("titlePic", ""))
	if not title_pic.is_empty():
		app._draw_image("res://assets/ui/lottery/%s.png" % title_pic, pos + Vector2(6, 7), size - Vector2(12, 14), false, Color(1, 1, 1, 0.98))
	if active:
		var highlight_size := _lottery_size(Vector2(230, 100))
		app._draw_image(UI_LOTTERY_TAB_HIGHLIGHT, pos - Vector2((highlight_size.x - size.x) * 0.5, (highlight_size.y - size.y) * 0.5), highlight_size, false)
		app._draw_image(UI_LOTTERY_TAB_CORNER, pos + Vector2(size.x - 18, -4), _lottery_size(Vector2(33, 33)), false)
	var display_name := str(pool_item.get("name", "Pool")).replace("高級", "進階").replace("喚靈", "喚靈")
	var name: Label = app._label(display_name, 18, HORIZONTAL_ALIGNMENT_LEFT)
	name.position = pos + Vector2(24, size.y * 0.34)
	name.size = Vector2(size.x - 78, 28)
	app._view_container().add_child(name)

func draw_pool_panel(pool: Dictionary, realm: String) -> void:
	var title_text := "普通喚靈" if str(pool.get("id", "")) == "normal" else str(pool.get("name", "高級喚靈"))
	var title: Label = app._label(title_text, 42, HORIZONTAL_ALIGNMENT_RIGHT)
	title.position = Vector2(932, 104)
	title.size = Vector2(268, 60)
	app._view_container().add_child(title)
	var pity_limit := 50 if str(pool.get("id", "")) == "normal" else int(pool.get("pityLimit", 60))
	var remain: int = max(pity_limit - app._pity(pool.get("id", "advanced")), 0)
	var reward_name := "SSR幻靈" if str(pool.get("id", "")) != "normal" else "SSR幻靈"
	var detail: Label = app._label("繼續喚靈%d次\n必定獲得%s" % [remain, reward_name], 18, HORIZONTAL_ALIGNMENT_RIGHT)
	detail.position = Vector2(948, 164)
	detail.size = Vector2(252, 56)
	app._view_container().add_child(detail)

func draw_wish_panel(pool: Dictionary, realm: String) -> void:
	var origin := _lottery_center_pos(Vector2(-62, -196), Vector2(304, 52))
	app._draw_image(UI_LOTTERY_WISH_BG, origin, _lottery_size(Vector2(304, 52)), false, Color(1, 1, 1, 0.82))
	var wish: Label = app._label("心願單：", 15)
	wish.position = origin + Vector2(8, 16)
	wish.size = Vector2(90, 24)
	app._view_container().add_child(wish)
	var pool_id := str(pool.get("id", "advanced"))
	var wishlist := _wishlist_for_pool(pool_id, 2)
	for i in range(2):
		var slot_pos := origin + Vector2(118 + i * 68, -9)
		app._draw_image(UI_LOTTERY_WISH_SLOT, slot_pos, Vector2(54, 54), false)
		var hero_id := int(wishlist[i])
		if hero_id > 0:
			var hero: Dictionary = app._hero_by_id(hero_id)
			app._draw_hero_round_thumb(hero, slot_pos + Vector2(4, 4), Vector2(46, 46))
			app._draw_image(UI_LOTTERY_WISH_COLOR_A if i == 0 else UI_LOTTERY_WISH_COLOR_B, slot_pos, Vector2(54, 54), false, Color(1, 1, 1, 0.74))
		else:
			app._draw_image(UI_LOTTERY_WISH_ADD, slot_pos + Vector2(11, 11), Vector2(32, 32), false)
		app._add_hit_button(slot_pos - Vector2(4, 4), Vector2(62, 62), func(slot := i) -> void:
			_show_wish_select(slot)
		)


func draw_draw_buttons(pool: Dictionary) -> void:
	var one_size := _lottery_size(Vector2(324, 94))
	var ten_size := _lottery_size(Vector2(324, 94))
	var one_pos := _lottery_right_bottom_pos(Vector2(-563, 75), Vector2(324, 94))
	var ten_pos := _lottery_right_bottom_pos(Vector2(-224, 75), Vector2(324, 94))
	app._draw_image(UI_LOTTERY_BTN_SINGLE, one_pos, one_size, false)
	app._draw_image(UI_LOTTERY_BTN_TEN, ten_pos, ten_size, false)
	var one_cost: int = max(1, int(pool.get("ticketCost", 1)))
	_draw_draw_button_text(one_pos, "喚靈1次", one_cost, Vector2(66, -26), 98.0, false)
	_draw_draw_button_text(ten_pos, "喚靈10次", one_cost * 10, Vector2(42.9, -26), 120.0, true)
	app._add_hit_button(one_pos, one_size, func() -> void: _request_draw(1))
	app._add_hit_button(ten_pos, ten_size, func() -> void: _request_draw(10))
	var today: Label = app._label("今日剩餘喚靈次數：9788/9999", 15, HORIZONTAL_ALIGNMENT_RIGHT)
	today.position = Vector2(930, 674)
	today.size = Vector2(270, 28)
	app._view_container().add_child(today)


func _draw_draw_button_text(pos: Vector2, label_text: String, cost: int, label_prefab_pos: Vector2, label_width: float, highlight: bool) -> void:
	var label: Label = app._label(label_text, 20, HORIZONTAL_ALIGNMENT_LEFT)
	label.position = pos + _lottery_size(Vector2(label_prefab_pos.x, 94 + label_prefab_pos.y - 36))
	label.size = _lottery_size(Vector2(label_width, 36))
	label.modulate = Color(0.24, 0.16, 0.10)
	app._view_container().add_child(label)
	var cost_pos := pos + _lottery_size(Vector2(175, 94 - 12 - 60))
	app._draw_image(_draw_cost_icon(), cost_pos, _lottery_size(Vector2(60, 60)), false)
	var cost_label: Label = app._label("x%d" % cost, 20, HORIZONTAL_ALIGNMENT_LEFT)
	cost_label.position = cost_pos + _lottery_size(Vector2(55, 12))
	cost_label.size = _lottery_size(Vector2(70, 36 if not highlight else 64))
	cost_label.modulate = Color(0.12, 0.10, 0.16) if highlight else Color(0.24, 0.16, 0.10)
	app._view_container().add_child(cost_label)


func _draw_cost_icon() -> String:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	return str(pool.get("costIcon", UI_LOTTERY_DRAW_COST))

func lottery_bg_for_pool(pool_id: String) -> String:
	match pool_id:
		"normal":
			return UI_LOTTERY_BG_NORMAL
		"epic":
			return UI_LOTTERY_BG_EPIC
		"prayer":
			return "res://assets/ui/lottery/bg/lottery_bg_05.png"
		"source_prayer":
			return UI_LOTTERY_BG_PRAYER
		_:
			return UI_LOTTERY_BG_ADVANCED


func _skip_animation_enabled() -> bool:
	return bool(app.save.get("gacha_skip_animation", true))


func _toggle_skip_animation() -> void:
	app.save["gacha_skip_animation"] = not _skip_animation_enabled()
	app._persist()
	show_gacha()


func _request_draw(count: int) -> void:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var cost := count * int(pool.get("ticketCost", 1))
	if int(app.save.get("tickets", 0)) < cost:
		_show_draw_blocked(cost)
		return
	if _skip_animation_enabled():
		app._draw_and_show(count)
	else:
		app._show_draw_animation(count)


func _show_draw_blocked(required_cost: int) -> void:
	var action_name := "祈願" if app._active_gacha_realm() == "prayer" else "喚靈"
	_show_lottery_panel("%s券不足" % action_name, "CheckCondition：資源不足時不進入 ReqLotteryDraw，先引導兌換或補給。")
	var root: Control = app._view_container()
	root.add_child(app._panel(Vector2(410, 236), Vector2(460, 202), Color(0.030, 0.024, 0.035, 0.88)))
	var warning: Label = app._label("本次需要%s券 x%d\n當前%s券 x%d" % [action_name, required_cost, action_name, int(app.save.get("tickets", 0))], 24, HORIZONTAL_ALIGNMENT_CENTER)
	warning.position = Vector2(438, 268)
	warning.size = Vector2(404, 72)
	root.add_child(warning)
	app._add_action_button("召喚商店", Vector2(480, 364), func() -> void: _show_gacha_shop(), Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("返回卡池", Vector2(668, 364), func() -> void: show_gacha(), Vector2(132, 44), LOTTERY_BTN_WHITE)


func _show_lottery_panel(title_text: String, subtitle: String) -> Vector2:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	app._set_chrome_visible(false)
	app._clear(title_text)
	app._draw_image(lottery_bg_for_pool(str(pool.get("id", "advanced"))), Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.82))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.010, 0.009, 0.016, 0.58)))
	draw_header_resources()
	app._add_action_button("◀  返回", Vector2(44, 18), func() -> void: show_gacha(), Vector2(118, 38), LOTTERY_BTN_WHITE)
	var title: Label = app._label(title_text, 36)
	title.position = Vector2(78, 84)
	title.size = Vector2(360, 52)
	title.modulate = Color(1.0, 0.92, 0.70)
	app._view_container().add_child(title)
	var desc: Label = app._label(subtitle, 18)
	desc.position = Vector2(80, 134)
	desc.size = Vector2(720, 34)
	desc.modulate = Color(0.90, 0.86, 0.78)
	app._view_container().add_child(desc)
	app._view_container().add_child(app._panel(Vector2(72, 184), Vector2(1136, 454), Color(0.035, 0.030, 0.044, 0.72)))
	return Vector2(96, 210)


func _show_gacha_shop() -> void:
	var action_name := "祈願" if app._active_gacha_realm() == "prayer" else "召喚"
	var origin := _show_lottery_panel("%s商店" % action_name, "對應 LotteryDrawMainView/btnShop2：在%s內完成券補給。" % action_name)
	var cost := int(app.shop.get("exchangeGemCost", 160))
	var amount := int(app.shop.get("ticketAmount", 1))
	var ticket_name := "祈願鑰匙" if app._active_gacha_realm() == "prayer" else "喚靈券"
	_draw_shop_exchange_card(origin, "%s補給" % ticket_name, "源石 %d = %s %d" % [cost, ticket_name, amount], 1)
	_draw_shop_exchange_card(origin + Vector2(0, 124), "十連補給", "源石 %d = %s %d" % [cost * 10, ticket_name, amount * 10], 10)
	_draw_resource_line(origin + Vector2(620, 16))
	app._add_action_button("每日補給", origin + Vector2(620, 116), app._show_daily, Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("郵件補償", origin + Vector2(772, 116), app._show_mail, Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("繼續喚靈", origin + Vector2(924, 116), func() -> void: show_gacha(), Vector2(132, 44), LOTTERY_BTN_WHITE)


func _draw_shop_exchange_card(pos: Vector2, title_text: String, desc_text: String, count: int) -> void:
	app._view_container().add_child(app._panel(pos, Vector2(540, 98), Color(1.0, 0.78, 0.35, 0.16)))
	app._draw_image(_draw_cost_icon(), pos + Vector2(18, 22), Vector2(54, 54), false)
	var title: Label = app._label(title_text, 23)
	title.position = pos + Vector2(88, 14)
	title.size = Vector2(260, 32)
	app._view_container().add_child(title)
	var desc: Label = app._label(desc_text, 17)
	desc.position = pos + Vector2(88, 48)
	desc.size = Vector2(280, 26)
	desc.modulate = Color(0.92, 0.86, 0.78)
	app._view_container().add_child(desc)
	app._add_action_button("兌換", pos + Vector2(400, 26), func() -> void:
		_exchange_tickets(count)
	, Vector2(104, 42), UI_LOTTERY_BTN_SINGLE)


func _exchange_tickets(count: int) -> void:
	var cost := count * int(app.shop.get("exchangeGemCost", 160))
	if int(app.save.get("gems", 0)) < cost:
		_show_lottery_notice("源石不足", "源石不足以兌換喚靈券，可先領取每日補給或郵件。")
		return
	app.save["gems"] = int(app.save.get("gems", 0)) - cost
	app.save["tickets"] = int(app.save.get("tickets", 0)) + count * int(app.shop.get("ticketAmount", 1))
	app._persist()
	_show_gacha_shop()


func _show_gacha_shard_shop() -> void:
	var origin := _show_lottery_panel("碎片商店", "對應 btnCrystalShop：展示重複喚靈轉化的角色碎片。")
	var shards: Dictionary = app.save.get("shards", {})
	var shown := 0
	for hero in app.heroes:
		var hero_id := int(hero.get("id", 0))
		var count := int(shards.get(str(hero_id), 0))
		if count <= 0:
			continue
		var col := shown % 3
		var row := shown / 3
		_draw_shard_card(hero, count, origin + Vector2(col * 350, row * 146))
		shown += 1
		if shown >= 6:
			break
	if shown == 0:
		var empty: Label = app._label("暫無角色碎片。\n重複喚靈後會按原邏輯轉化為碎片，之後可在此查看。", 24, HORIZONTAL_ALIGNMENT_CENTER)
		empty.position = origin + Vector2(244, 128)
		empty.size = Vector2(560, 110)
		app._view_container().add_child(empty)
	app._add_action_button("英雄列表", origin + Vector2(0, 360), app._show_gallery, Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("返回喚靈", origin + Vector2(152, 360), func() -> void: show_gacha(), Vector2(132, 44), LOTTERY_BTN_WHITE)


func _draw_shard_card(hero: Dictionary, count: int, pos: Vector2) -> void:
	app._view_container().add_child(app._panel(pos, Vector2(320, 118), Color(0.35, 0.44, 0.70, 0.22)))
	app._draw_image(UI_LOTTERY_WISH_SLOT, pos + Vector2(14, 20), Vector2(72, 72), false)
	app._draw_hero_round_thumb(hero, pos + Vector2(22, 28), Vector2(56, 56))
	var label: Label = app._label("%s\n碎片 x%d\n%s" % [hero.get("name", ""), count, app._stars(int(hero.get("rarity", 1)))], 18)
	label.position = pos + Vector2(104, 14)
	label.size = Vector2(178, 82)
	app._view_container().add_child(label)
	app._add_hit_button(pos, Vector2(320, 118), func() -> void:
		app._show_hero_detail(int(hero.get("id", 0)))
	)


func _show_gacha_formation() -> void:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var origin := _show_lottery_panel("陣容推薦", "對應 btnMarch：以當前卡池 UP / featuredHeroIds 生成推薦入口。")
	var list := _featured_heroes(pool)
	for index in range(list.size()):
		var hero: Dictionary = list[index]
		var pos := origin + Vector2(index * 260, 30)
		_draw_recommend_card(hero, pos)
	var hint: Label = app._label("點擊角色可查看詳情。推薦來源：%s / featuredHeroIds。" % str(pool.get("sourceStatic", {}).get("table", "mvp")), 18)
	hint.position = origin + Vector2(0, 310)
	hint.size = Vector2(760, 32)
	hint.modulate = Color(0.90, 0.86, 0.78)
	app._view_container().add_child(hint)
	app._add_action_button("英雄列表", origin + Vector2(0, 360), app._show_gallery, Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("返回喚靈", origin + Vector2(152, 360), func() -> void: show_gacha(), Vector2(132, 44), LOTTERY_BTN_WHITE)


func _draw_recommend_card(hero: Dictionary, pos: Vector2) -> void:
	app._view_container().add_child(app._panel(pos, Vector2(220, 260), app._rarity_color(int(hero.get("rarity", 1)), 0.18)))
	app._draw_hero_thumb(hero, pos + Vector2(24, 18), Vector2(172, 152))
	var name: Label = app._label(str(hero.get("name", "")), 22, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = pos + Vector2(12, 184)
	name.size = Vector2(196, 32)
	app._view_container().add_child(name)
	var detail: Label = app._label("%s  UP 推薦" % app._stars(int(hero.get("rarity", 1))), 17, HORIZONTAL_ALIGNMENT_CENTER)
	detail.position = pos + Vector2(12, 220)
	detail.size = Vector2(196, 28)
	detail.modulate = app._rarity_color(int(hero.get("rarity", 1)), 1.0)
	app._view_container().add_child(detail)
	app._add_hit_button(pos, Vector2(220, 260), func() -> void:
		app._show_hero_detail(int(hero.get("id", 0)))
	)


func _show_gacha_integral() -> void:
	var origin := _show_lottery_panel("積分抽獎", "對應 btnIntegral：累計喚靈次數換算積分，保留原界面入口節奏。")
	var points := int(app.save.get("gacha_integral", int(app.save.get("draw_count", 0)) * 10))
	var target := 100
	var ratio := float(points % target) / float(target)
	var title: Label = app._label("當前積分  %d" % points, 32)
	title.position = origin + Vector2(12, 28)
	title.size = Vector2(360, 46)
	title.modulate = Color(1.0, 0.92, 0.70)
	app._view_container().add_child(title)
	app._draw_progress_bar(origin + Vector2(12, 92), Vector2(520, 20), ratio)
	var desc: Label = app._label("每次喚靈累計 10 積分；滿 %d 積分可領取一次補給獎勵。" % target, 20)
	desc.position = origin + Vector2(12, 128)
	desc.size = Vector2(600, 38)
	app._view_container().add_child(desc)
	_draw_integral_reward_preview(origin + Vector2(680, 26))
	if points >= target:
		app._add_action_button("領取獎勵", origin + Vector2(12, 204), func() -> void:
			_claim_integral_reward(points, target)
		, Vector2(132, 44), UI_LOTTERY_BTN_TEN)
	else:
		var lack: Label = app._label("還差 %d 積分" % (target - points), 19)
		lack.position = origin + Vector2(12, 204)
		lack.size = Vector2(160, 44)
		app._view_container().add_child(lack)
	app._add_action_button("返回喚靈", origin + Vector2(160, 204), func() -> void: show_gacha(), Vector2(132, 44), LOTTERY_BTN_WHITE)


func _draw_integral_reward_preview(pos: Vector2) -> void:
	app._view_container().add_child(app._panel(pos, Vector2(320, 150), Color(1.0, 0.78, 0.35, 0.16)))
	app._draw_image(UI_LOTTERY_COST_TICKET, pos + Vector2(26, 42), Vector2(54, 54), false)
	app._draw_image(UI_LOTTERY_COST_GEM, pos + Vector2(112, 42), Vector2(54, 54), false)
	var label: Label = app._label("積分補給\n喚靈券 x1  源石 x160", 21)
	label.position = pos + Vector2(190, 36)
	label.size = Vector2(110, 78)
	app._view_container().add_child(label)


func _claim_integral_reward(points: int, target: int) -> void:
	app.save["gacha_integral"] = points - target
	app._grant_reward(1, 160)
	_show_gacha_integral()


func _show_wish_select(slot_index: int) -> void:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var origin := _show_lottery_panel("心願單", "對應 pnlNormalWish/btnWish：選擇想要提高展示權重的角色。")
	var list := _featured_heroes(pool)
	for index in range(list.size()):
		var hero: Dictionary = list[index]
		var pos := origin + Vector2(index * 220, 26)
		_draw_wish_select_card(hero, pos, slot_index)
	app._add_action_button("清空位置", origin + Vector2(0, 330), func() -> void:
		_set_wishlist_slot(slot_index, 0)
	, Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("返回喚靈", origin + Vector2(152, 330), func() -> void: show_gacha(), Vector2(132, 44), LOTTERY_BTN_WHITE)


func _draw_wish_select_card(hero: Dictionary, pos: Vector2, slot_index: int) -> void:
	app._view_container().add_child(app._panel(pos, Vector2(180, 238), app._rarity_color(int(hero.get("rarity", 1)), 0.18)))
	app._draw_hero_thumb(hero, pos + Vector2(20, 14), Vector2(140, 148))
	var name: Label = app._label(str(hero.get("name", "")), 20, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = pos + Vector2(10, 172)
	name.size = Vector2(160, 30)
	app._view_container().add_child(name)
	app._add_action_button("選擇", pos + Vector2(38, 206), func() -> void:
		_set_wishlist_slot(slot_index, int(hero.get("id", 0)))
	, Vector2(104, 36), LOTTERY_BTN_WHITE)


func _set_wishlist_slot(slot_index: int, hero_id: int) -> void:
	var pool_id := str(app.save.get("active_pool_id", "advanced"))
	var store: Dictionary = app.save.get("gacha_wishlist", {})
	var list := _wishlist_for_pool(pool_id, 2)
	list[slot_index] = hero_id
	store[pool_id] = list
	app.save["gacha_wishlist"] = store
	app._persist()
	show_gacha()


func _wishlist_for_pool(pool_id: String, slot_count: int) -> Array:
	var store: Dictionary = app.save.get("gacha_wishlist", {})
	var list: Array = store.get(pool_id, [])
	while list.size() < slot_count:
		list.append(0)
	return list


func _featured_heroes(pool: Dictionary) -> Array:
	var result := []
	for raw_id in pool.get("featuredHeroIds", []):
		result.append(app._hero_by_id(int(raw_id)))
	if result.is_empty():
		for hero in app.heroes:
			if int(hero.get("rarity", 1)) >= 4:
				result.append(hero)
			if result.size() >= 4:
				break
	return result.slice(0, min(result.size(), 4))


func _draw_resource_line(pos: Vector2) -> void:
	app._draw_image(UI_LOTTERY_COST_GEM, pos, Vector2(44, 44), false)
	app._draw_image(UI_LOTTERY_COST_TICKET, pos + Vector2(184, 0), Vector2(44, 44), false)
	var label: Label = app._label("源石  %s        喚靈券  %s" % [str(app.save.get("gems", 0)), str(app.save.get("tickets", 0))], 22)
	label.position = pos + Vector2(52, 6)
	label.size = Vector2(420, 36)
	app._view_container().add_child(label)


func _show_lottery_notice(title_text: String, body_text: String) -> void:
	var origin := _show_lottery_panel(title_text, body_text)
	app._add_action_button("每日補給", origin + Vector2(300, 170), app._show_daily, Vector2(132, 44), LOTTERY_BTN_WHITE)
	app._add_action_button("返回商店", origin + Vector2(452, 170), func() -> void: _show_gacha_shop(), Vector2(132, 44), LOTTERY_BTN_WHITE)
