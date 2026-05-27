# UTF-8 source. Remnants list/detail views split from main.gd.
extends RefCounted

var app
var remnants_page = 0
var selected_remnant_id = 0

func _init(app_ref) -> void:
	app = app_ref
	selected_remnant_id = app.DEFAULT_HERO_ID


func show_list() -> void:
	app.current_view = "remnants"
	app._set_chrome_visible(false)
	app._clear("幻靈列表")
	_draw_background()
	_draw_top_bar()
	_draw_side_filters()
	var list: Array = primary_heroes()
	var page_size: int = 10
	var page_count: int = max(1, int(ceil(float(list.size()) / float(page_size))))
	remnants_page = clamp(remnants_page, 0, page_count - 1)
	var start: int = remnants_page * page_size
	var page_items: Array = list.slice(start, min(start + page_size, list.size()))
	_draw_section("靈能原體", Vector2(260, 82), page_items, true)
	_draw_sync_section(Vector2(260, 586), list.size(), page_count)


func _draw_background() -> void:
	app._draw_image(app.UI_REMNANTS_BG, Vector2(0, 0), Vector2(1280, 720), true, Color(0.70, 0.76, 0.92, 0.86))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.010, 0.018, 0.035, 0.40)))
	app._view_container().add_child(app._panel(Vector2(0, 548), Vector2(1280, 172), Color(0.34, 0.43, 0.60, 0.30)))
	for i in range(7):
		var y = 80.0 + i * 80.0
		app._view_container().add_child(app._panel(Vector2(38, y), Vector2(2, 58), Color(0.45, 0.55, 0.72, 0.36)))
		app._view_container().add_child(app._panel(Vector2(31, y + 22), Vector2(14, 14), Color(0.90, 0.96, 1.0, 0.60)))


func _draw_top_bar() -> void:
	app._add_action_button("返回", Vector2(46, 18), app._show_home, Vector2(116, 38))
	app._add_action_button("?", Vector2(176, 18), app._show_player_info, Vector2(42, 38))
	var tabs = ["編隊", "陣容推薦", "戰力", "品質", "星級", "等級"]
	var x = 506.0
	for i in range(tabs.size()):
		var selected = i == 2
		app._view_container().add_child(app._panel(Vector2(x, 20), Vector2(96, 30), Color(0.10, 0.12, 0.18, 0.62)))
		var label = app._label(str(tabs[i]), 15, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(x, 24)
		label.size = Vector2(96, 22)
		label.modulate = Color(0.80, 1.0, 0.18) if selected else Color(0.95, 0.95, 0.98)
		app._view_container().add_child(label)
		x += 96


func _draw_side_filters() -> void:
	var filters = [
		["全部", Color(0.66, 0.94, 0.20, 1)],
		["水相", Color(0.82, 0.92, 1.0, 1)],
		["風相", Color(0.82, 1.0, 0.88, 1)],
		["火相", Color(1.0, 0.78, 0.62, 1)],
		["土相", Color(0.98, 0.90, 0.72, 1)],
		["輝星", Color(0.88, 0.90, 1.0, 1)]
	]
	var y = 120.0
	for i in range(filters.size()):
		var selected = i == 0
		if selected:
			app._view_container().add_child(app._panel(Vector2(58, y - 12), Vector2(108, 30), Color(0.38, 0.58, 0.12, 0.72)))
		var bullet = app._panel(Vector2(72, y - 5), Vector2(16, 16), filters[i][1])
		app._view_container().add_child(bullet)
		var label = app._label(str(filters[i][0]), 17)
		label.position = Vector2(106, y - 9)
		label.size = Vector2(86, 26)
		label.modulate = Color(0.88, 1.0, 0.58) if selected else Color(0.96, 0.96, 1.0)
		app._view_container().add_child(label)
		y += 64


func _draw_section(title: String, pos: Vector2, list: Array, featured: bool) -> void:
	_draw_section_header(title, pos)
	var columns = 5
	var start_x = pos.x + 98
	for i in range(list.size()):
		var col = i % columns
		var row = i / columns
		_draw_card(list[i], Vector2(start_x + col * 132.0, pos.y + 48 + row * 214.0), featured)


func _draw_sync_section(pos: Vector2, total_count: int, page_count: int) -> void:
	_draw_section_header("同調者", pos)
	var tip = app._label("當前共用養成：幻靈等級-86級  靈階-0星  靈裝-紫色Lv.30  靈裝強化-20級", 16)
	tip.position = pos + Vector2(190, 7)
	tip.size = Vector2(730, 26)
	tip.modulate = Color(1.0, 0.94, 0.58)
	app._view_container().add_child(tip)
	var count = app._label("全部幻靈：%d  第 %d/%d 頁" % [total_count, remnants_page + 1, page_count], 15, HORIZONTAL_ALIGNMENT_RIGHT)
	count.position = pos + Vector2(606, 7)
	count.size = Vector2(224, 24)
	count.modulate = Color(0.82, 0.94, 1.0)
	app._view_container().add_child(count)
	app._add_action_button("上一頁", pos + Vector2(646, 42), func() -> void:
		remnants_page = max(0, remnants_page - 1)
		show_list()
	, Vector2(82, 36))
	app._add_action_button("下一頁", pos + Vector2(742, 42), func() -> void:
		remnants_page = min(page_count - 1, remnants_page + 1)
		show_list()
	, Vector2(82, 36))


func _draw_section_header(title: String, pos: Vector2) -> void:
	app._view_container().add_child(app._panel(pos, Vector2(846, 30), Color(0.08, 0.10, 0.18, 0.76)))
	var marker = app._panel(pos + Vector2(12, 7), Vector2(18, 16), Color(0.68, 0.96, 0.22, 0.95))
	app._view_container().add_child(marker)
	var label = app._label(title, 18)
	label.position = pos + Vector2(42, 3)
	label.size = Vector2(180, 26)
	label.modulate = Color(0.78, 1.0, 0.32)
	app._view_container().add_child(label)


func _draw_card(hero: Dictionary, pos: Vector2, featured: bool) -> void:
	var rarity = int(hero.get("rarity", 1))
	var hero_id = int(hero.get("id", 0))
	var level = 78 + rarity * 4 + hero_id % 13
	var card_size = Vector2(118, 202)
	var frame_color = Color(0.92, 0.64, 0.20, 0.90) if rarity >= 4 else Color(0.34, 0.62, 0.92, 0.86)
	app._view_container().add_child(app._panel(pos, card_size, Color(0.04, 0.055, 0.085, 0.88)))
	app._view_container().add_child(app._panel(pos + Vector2(2, 2), card_size - Vector2(4, 4), Color(frame_color.r, frame_color.g, frame_color.b, 0.22)))
	app._draw_hero_thumb(hero, pos + Vector2(6, 6), Vector2(106, 142), Color(1, 1, 1, 1))
	app._view_container().add_child(app._panel(pos + Vector2(4, 150), Vector2(110, 48), Color(0.45, 0.25, 0.06, 0.84)))
	var rare = app._label("SSR", 24)
	rare.position = pos + Vector2(10, 154)
	rare.size = Vector2(58, 30)
	rare.modulate = Color(1.0, 0.82, 0.36)
	app._view_container().add_child(rare)
	var level_label = app._label("等級%d" % level, 12, HORIZONTAL_ALIGNMENT_RIGHT)
	level_label.position = pos + Vector2(58, 154)
	level_label.size = Vector2(54, 18)
	level_label.modulate = Color(1.0, 0.96, 0.88)
	app._view_container().add_child(level_label)
	var name = app._label(str(hero.get("name", "幻靈")), 13, HORIZONTAL_ALIGNMENT_RIGHT)
	name.position = pos + Vector2(48, 174)
	name.size = Vector2(62, 20)
	name.modulate = Color(1.0, 0.96, 0.88)
	app._view_container().add_child(name)
	if featured:
		app._draw_red_dot(pos + Vector2(104, -6))
		var tag = app._label("特薦", 13, HORIZONTAL_ALIGNMENT_CENTER)
		tag.position = pos + Vector2(75, 4)
		tag.size = Vector2(38, 18)
		tag.modulate = Color(1.0, 0.98, 0.20)
		app._view_container().add_child(tag)
	var button = Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = card_size
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		show_detail(hero_id)
	)
	app._view_container().add_child(button)


func show_detail(hero_id: int) -> void:
	selected_remnant_id = hero_id
	app.current_view = "remnant_detail"
	app._set_chrome_visible(false)
	var hero = app._hero_by_id(hero_id)
	app._clear("幻靈詳情")
	_draw_detail_background(hero)
	_draw_detail_left_strip(hero_id)
	_draw_detail_tabs()
	app._draw_hero_stage(hero, Vector2(160, -74), Vector2(760, 840), false)
	_draw_detail_panel(hero)


func _draw_detail_background(hero: Dictionary) -> void:
	app._draw_image(app.UI_HERO_BG_DETAIL, Vector2(0, 0), Vector2(1280, 720), true, Color(0.92, 0.94, 1.0, 0.96))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.018, 0.030, 0.32)))
	if int(hero.get("id", 0)) == 240069:
		app._draw_image(app.UI_REMNANT_STAGE_BG, Vector2(154, -394), Vector2(700, 1400), false, Color(1.0, 1.0, 1.0, 0.90))
		app._view_container().add_child(app._panel(Vector2(760, 0), Vector2(520, 720), Color(0.010, 0.014, 0.026, 0.38)))
	app._view_container().add_child(app._panel(Vector2(250, 0), Vector2(520, 720), Color(0.92, 0.78, 0.42, 0.05)))
	app._view_container().add_child(app._panel(Vector2(846, 26), Vector2(352, 520), Color(0.020, 0.024, 0.038, 0.42)))
	app._add_action_button("返回", Vector2(46, 18), app._show_remnants_list, Vector2(116, 38))
	app._add_action_button("?", Vector2(176, 18), app._show_player_info, Vector2(42, 38))


func _draw_detail_left_strip(selected_id: int) -> void:
	var list = primary_heroes()
	var selected_index = 0
	for i in range(list.size()):
		if int(list[i].get("id", 0)) == selected_id:
			selected_index = i
			break
	var start: int = clamp(selected_index - 2, 0, max(0, list.size() - 7))
	var visible = list.slice(start, min(start + 7, list.size()))
	app._draw_image(app.UI_HERO_SELECTOR_BG, Vector2(26, 66), Vector2(76, 628), false, Color(1, 1, 1, 0.90))
	app._draw_image(app.UI_HERO_SELECTOR_TOP, Vector2(26, 646), Vector2(76, 42), false, Color(1, 1, 1, 0.82))
	for i in range(visible.size()):
		var hero: Dictionary = visible[i]
		var pos = Vector2(33, 73 + i * 82.0)
		var is_selected = int(hero.get("id", 0)) == selected_id
		if is_selected:
			app._draw_image(app.UI_HERO_HIGHLIGHT, pos - Vector2(15, 15), Vector2(100, 100), false, Color(1, 1, 1, 0.86))
		app._draw_hero_round_thumb(hero, pos, Vector2(70, 70), Color(1, 1, 1, 1))
		app._draw_image(app.UI_COMMON_HERO_HEAD_FRAME, pos, Vector2(70, 70), false, Color(1, 1, 1, 0.92))
		app._draw_image(app.UI_COMMON_HERO_STAR_BAR, pos + Vector2(0, 62), Vector2(70, 12), false, Color(1, 1, 1, 0.42))
		var stars = app._label("★★★★★", 8, HORIZONTAL_ALIGNMENT_CENTER)
		stars.position = pos + Vector2(0, 61)
		stars.size = Vector2(70, 12)
		stars.modulate = Color(1.0, 1.0, 1.0, 0.72)
		app._view_container().add_child(stars)
		var level = app._label(str(remnant_level(hero)), 11, HORIZONTAL_ALIGNMENT_RIGHT)
		level.position = pos + Vector2(36, 2)
		level.size = Vector2(26, 16)
		level.modulate = Color(1.0, 0.96, 0.76)
		app._view_container().add_child(level)
		var hero_id = int(hero.get("id", 0))
		var button = Button.new()
		button.text = ""
		button.flat = true
		button.position = pos - Vector2(6, 6)
		button.size = Vector2(70, 78)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void:
			show_detail(hero_id)
		)
		app._view_container().add_child(button)


func _draw_detail_tabs() -> void:
	var tabs = [
		["主頁", app.UI_HERO_TAB_HOME, Color(0.70, 1.0, 0.22)],
		["養成", app.UI_HERO_TAB_CULTIVATE, Color(1, 1, 1)],
		["靈裝", app.UI_HERO_TAB_EQUIP, Color(1, 1, 1)],
		["靈階", app.UI_HERO_TAB_STAGE, Color(1, 1, 1)]
	]
	var y = 104.0
	for i in range(tabs.size()):
		var selected = i == 0
		if selected:
			app._view_container().add_child(app._panel(Vector2(130, y - 19), Vector2(104, 48), Color(0.08, 0.14, 0.09, 0.58)))
		app._draw_image(str(tabs[i][1]), Vector2(132, y - 26), Vector2(54, 54), false, Color(0.78, 1.0, 0.22, 1.0) if selected else Color(0.92, 0.96, 1.0, 0.96))
		var label = app._label(str(tabs[i][0]), 21)
		label.position = Vector2(190, y - 12)
		label.size = Vector2(86, 28)
		label.modulate = tabs[i][2]
		app._view_container().add_child(label)
		y += 72


func _draw_detail_panel(hero: Dictionary) -> void:
	var hero_id = int(hero.get("id", 0))
	var level = remnant_level(hero)
	var pos = Vector2(876, 54)
	var type_name = remnant_element_name(hero_id)
	var role = remnant_role_name(hero_id)
	var small = app._label(remnant_title_name(hero_id), 16)
	small.position = pos
	small.size = Vector2(180, 24)
	small.modulate = Color(1.0, 0.82, 0.34)
	app._view_container().add_child(small)
	var name = app._label(str(hero.get("name", "幻靈")), 30)
	name.position = pos + Vector2(0, 26)
	name.size = Vector2(210, 42)
	name.modulate = Color(1.0, 1.0, 1.0)
	app._view_container().add_child(name)
	var ssr = app._label("SSR", 36, HORIZONTAL_ALIGNMENT_RIGHT)
	ssr.position = pos + Vector2(224, 2)
	ssr.size = Vector2(96, 50)
	ssr.modulate = Color(1.0, 0.76, 0.24)
	app._view_container().add_child(ssr)
	app._view_container().add_child(app._panel(pos + Vector2(0, 88), Vector2(284, 2), Color(0.84, 0.90, 1.0, 0.22)))
	_draw_stars(remnant_star_level(hero), pos + Vector2(12, 108))
	var role_label = app._label("狂刃" if role == "attack" else "守護", 17, HORIZONTAL_ALIGNMENT_CENTER)
	role_label.position = pos + Vector2(176, 112)
	role_label.size = Vector2(70, 24)
	app._view_container().add_child(role_label)
	var element = app._label(type_name, 17, HORIZONTAL_ALIGNMENT_CENTER)
	element.position = pos + Vector2(260, 112)
	element.size = Vector2(70, 24)
	app._view_container().add_child(element)
	var desc = app._label("反擊疊暴    暴擊輸出", 15)
	desc.position = pos + Vector2(12, 150)
	desc.size = Vector2(260, 24)
	desc.modulate = Color(0.92, 0.92, 1.0)
	app._view_container().add_child(desc)
	app._view_container().add_child(app._panel(pos + Vector2(0, 188), Vector2(284, 2), Color(0.84, 0.90, 1.0, 0.18)))

	var power = remnant_power(hero)
	var level_label = app._label("等級", 17)
	level_label.position = pos + Vector2(10, 214)
	level_label.size = Vector2(90, 24)
	app._view_container().add_child(level_label)
	var level_value = app._label("%d/180" % level, 22)
	level_value.position = pos + Vector2(10, 240)
	level_value.size = Vector2(130, 30)
	level_value.modulate = Color(0.72, 1.0, 0.18)
	app._view_container().add_child(level_value)
	var power_title = app._label("戰力", 20, HORIZONTAL_ALIGNMENT_CENTER)
	power_title.position = pos + Vector2(178, 214)
	power_title.size = Vector2(106, 28)
	power_title.modulate = Color(1.0, 0.95, 0.48)
	app._view_container().add_child(power_title)
	var power_label = app._label(str(power), 20, HORIZONTAL_ALIGNMENT_CENTER)
	power_label.position = pos + Vector2(178, 244)
	power_label.size = Vector2(106, 30)
	power_label.modulate = Color(1.0, 0.90, 0.40)
	app._view_container().add_child(power_label)
	var attrs = remnant_attrs(hero)
	_draw_attr("攻擊", str(attrs["攻擊"]), pos + Vector2(10, 294))
	_draw_attr("生命", str(attrs["生命"]), pos + Vector2(178, 294))
	_draw_attr("防禦", str(attrs["防禦"]), pos + Vector2(10, 326))
	_draw_attr("速度", str(attrs["速度"]), pos + Vector2(178, 326))
	app._add_action_button("詳情屬性", pos + Vector2(0, 372), app._show_player_info, Vector2(284, 28))
	_draw_skill_badges(hero, pos + Vector2(8, 408))


func _draw_stars(rarity: int, pos: Vector2) -> void:
	for i in range(5):
		var path = app.UI_COMMON_STAR if i < rarity else app.UI_COMMON_STAR_OFF
		app._draw_image(path, pos + Vector2(i * 28.0, 0), Vector2(26, 26), false, Color(1, 1, 1, 0.96))


func _draw_skill_badges(hero: Dictionary, pos: Vector2) -> void:
	var skill_paths: Array = hero.get("skillResources", [])
	for i in range(4):
		var icon_pos = pos + Vector2(i * 68.0, 0)
		app._draw_image(app.UI_COMMON_SKILL_FRAME, icon_pos, Vector2(62, 62), false, Color(1.0, 0.86, 0.28, 0.36))
		if i < skill_paths.size():
			app._draw_image(app._godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(3, 3), Vector2(56, 56), false, Color(1, 1, 1, 0.98))
		else:
			var icon = app._label("威", 24, HORIZONTAL_ALIGNMENT_CENTER)
			icon.position = icon_pos + Vector2(3, 16)
			icon.size = Vector2(56, 30)
			icon.modulate = Color(1.0, 0.96, 0.62)
			app._view_container().add_child(icon)


func _draw_attr(label_text: String, value_text: String, pos: Vector2) -> void:
	var label = app._label(label_text, 15)
	label.position = pos
	label.size = Vector2(58, 22)
	label.modulate = Color(0.94, 0.94, 1.0)
	app._view_container().add_child(label)
	var value = app._label(value_text, 16, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(60, 0)
	value.size = Vector2(72, 22)
	value.modulate = Color(1.0, 1.0, 1.0)
	app._view_container().add_child(value)


func remnant_power(hero: Dictionary) -> int:
	var rarity = int(hero.get("rarity", 1))
	var hero_id = int(hero.get("id", 0))
	if hero_id == 240069:
		return 274369
	return 88000 + rarity * 42000 + (hero_id % 100) * 1137


func remnant_attrs(hero: Dictionary) -> Dictionary:
	var rarity = int(hero.get("rarity", 1))
	var hero_id = int(hero.get("id", 0))
	if hero_id == 240069:
		return {
			"攻擊": 23746,
			"生命": 212970,
			"防禦": 1805,
			"速度": 104,
		}
	return {
		"攻擊": 16400 + rarity * 1800 + hero_id % 900,
		"生命": 145000 + rarity * 18500 + (hero_id % 100) * 210,
		"防禦": 1300 + rarity * 120 + hero_id % 90,
		"速度": 96 + rarity * 2 + hero_id % 5,
	}


func remnant_level(hero: Dictionary) -> int:
	var hero_id = int(hero.get("id", 0))
	if hero_id == 240069:
		return 100
	return 78 + int(hero.get("rarity", 1)) * 4 + hero_id % 13


func remnant_star_level(hero: Dictionary) -> int:
	var hero_id = int(hero.get("id", 0))
	if hero_id == 240069:
		return 2
	return int(hero.get("rarity", 1))


func remnant_title_name(hero_id: int) -> String:
	if hero_id == 240069:
		return "昭陽"
	return remnant_element_name(hero_id)


func remnant_element_name(hero_id: int) -> String:
	if hero_id == 240069:
		return "土相"
	var names = ["水相", "風相", "火相", "土相", "輝星"]
	return names[hero_id % names.size()]


func remnant_role_name(hero_id: int) -> String:
	if hero_id == 240069:
		return "attack"
	return "attack" if hero_id % 2 == 0 else "guard"


func primary_heroes() -> Array:
	var list = app.heroes.duplicate(true)
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("rarity", 1)) > int(b.get("rarity", 1)) if int(a.get("rarity", 1)) != int(b.get("rarity", 1)) else int(a.get("id", 0)) < int(b.get("id", 0))
	)
	return list


func sync_heroes() -> Array:
	var list = primary_heroes()
	return list.slice(2, min(list.size(), 10))
