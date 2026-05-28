# UTF-8 source. Activity / Welfare / MonthCard / Competition views split from main.gd.
extends RefCounted

var app

func _init(app_ref) -> void:
	app = app_ref


func show_activity_center() -> void:
	var origin: Vector2 = app._show_home_panel("活動", "限時活動與主屏左側入口統一收束到這裡。")
	var activities: Array = app._mainui_group("activity_list")
	for index in range(activities.size()):
		var item: Dictionary = activities[index]
		if not app._mainui_entry_visible(item):
			continue
		var pos: Vector2 = origin + Vector2(0, index * 82)
		app._draw_home_resource_card(pos, Vector2(760, 68), Color(1.0, 0.74, 0.38, 0.30), index % 2 == 1)
		app._draw_image(str(item.get("icon", app.UI_MAIN_LIMIT_ICON_FRAME)), pos + Vector2(8, -10), Vector2(76, 76), false, Color(1, 1, 1, 0.92))
		var title: Label = app._label(str(item.get("label", "")), 20)
		title.position = pos + Vector2(96, 10)
		title.size = Vector2(180, 30)
		title.modulate = Color(1.0, 0.93, 0.70)
		app._view_container().add_child(title)
		var time_label: Label = app._label(app._mainui_entry_timer(item), 16, HORIZONTAL_ALIGNMENT_CENTER)
		time_label.position = pos + Vector2(488, 12)
		time_label.size = Vector2(96, 26)
		time_label.modulate = Color(1.0, 0.80, 0.28)
		app._view_container().add_child(time_label)
		if app._mainui_red_dot_active(str(item.get("red_dot_key", "")), str(item.get("id", ""))):
			app._draw_red_dot(pos + Vector2(66, -4))
		app._add_action_button("前往", pos + Vector2(628, 12), app._mainui_entry_callable(item), Vector2(82, 38), app.UI_COMMON_BTN_GOLD)


func show_welfare() -> void:
	var origin: Vector2 = app._show_home_panel("福利", "每日、郵件與任務獎勵的快捷入口。")
	var entries: Array = app._mainui_group("welfare_entries")
	for index in range(entries.size()):
		var item: Dictionary = entries[index]
		var pos: Vector2 = origin + Vector2(index * 170, 0)
		app._draw_home_feature_icon(str(item.get("icon", app.UI_MAIN_LIMIT_ICON_FRAME)), pos, str(item.get("label", "")), app._mainui_entry_callable(item))
		if app._mainui_red_dot_active(str(item.get("red_dot_key", "")), str(item.get("id", ""))):
			app._draw_red_dot(pos + Vector2(66, 0))
	var tip: Label = app._label("福利入口按原 MainUIView 紅點語義收束每日、郵件、章節任務與問卷禮包。", 18)
	tip.position = origin + Vector2(0, 132)
	tip.size = Vector2(520, 90)
	tip.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(tip)


func show_month_card() -> void:
	var origin: Vector2 = app._show_home_panel("月卡", "本地 MVP 月卡狀態與每日領取。")
	var active: bool = bool(app.save.get("month_card_active", false))
	var claimed: bool = str(app.save.get("month_card_claimed_date", "")) == Time.get_date_string_from_system()
	var info: Label = app._label("狀態：%s\n每日獎勵：源石 x120 / 喚靈券 x1\n今日：%s" % [
		"已開通" if active else "試用未開通",
		"已領取" if claimed else "可領取"
	], 22)
	app._draw_home_resource_card(origin, Vector2(560, 154), Color(1.0, 0.82, 0.42, 0.34), false)
	app._draw_image(app.UI_MAIN_CHARGE_ICONS[2], origin + Vector2(22, 30), Vector2(86, 86), false, Color(1, 1, 1, 0.94))
	app._draw_home_reward_icon("res://assets/ui/item/draw_05.png", origin + Vector2(404, 22), "源石", "x120")
	app._draw_home_reward_icon("res://assets/ui/item/draw_07.png", origin + Vector2(486, 22), "喚靈券", "x1")
	info.position = origin + Vector2(126, 18)
	info.size = Vector2(520, 120)
	app._view_container().add_child(info)
	app._add_action_button("開通試用", origin + Vector2(0, 154), func() -> void:
		app.save["month_card_active"] = true
		app._persist()
		show_month_card()
	, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("領取", origin + Vector2(154, 154), func() -> void:
		if bool(app.save.get("month_card_active", false)) and str(app.save.get("month_card_claimed_date", "")) != Time.get_date_string_from_system():
			app.save["month_card_claimed_date"] = Time.get_date_string_from_system()
			app._grant_reward(1, 120)
			app._persist()
		show_month_card()
	, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)


func show_competition() -> void:
	var origin: Vector2 = app._show_home_panel("競技", "競技入口先接入離線挑戰摘要，後續可替換排行榜與防守陣容。")
	var rank: int = int(app.save.get("arena_rank", 1205))
	var text: Label = app._label("當前排名：%d\n今日挑戰：%d / 5\n推薦戰力：%d\n\n挑戰成功可獲得源石與任務進度。" % [
		rank,
		int(app.save.get("arena_count", 0)),
		max(app._player_power() - 12000, 10000)
	], 22)
	app._draw_home_resource_card(origin, Vector2(560, 190), Color(0.92, 0.74, 1.0, 0.32), false)
	app._draw_image(app.UI_MAIN_FUNNY_ARENA, origin + Vector2(18, 28), Vector2(88, 102), false, Color(1, 1, 1, 0.90))
	text.position = origin + Vector2(128, 18)
	text.size = Vector2(520, 180)
	app._view_container().add_child(text)
	app._add_action_button("模擬挑戰", origin + Vector2(0, 210), func() -> void:
		app.save["arena_count"] = mini(int(app.save.get("arena_count", 0)) + 1, 5)
		app.save["arena_rank"] = maxi(int(app.save.get("arena_rank", 1205)) - 12, 1)
		app._grant_reward(0, 60)
		app._persist()
		show_competition()
	, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
