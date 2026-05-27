# UTF-8 source. Shop / Charge / Daily views split from main.gd.
extends RefCounted

var app

func _init(app_ref) -> void:
	app = app_ref


func show_charge() -> void:
	var origin: Vector2 = app._show_home_panel("儲值", "右側儲值與左側首儲入口，先用本地模擬充值閉環替代原支付流程。")
	var first_claimed: bool = bool(app.save.get("first_charge_claimed", false))
	var packs: Array = [
		{"name": "首儲禮包", "desc": "首次領取：源石 x1980 / 喚靈券 x10", "gems": 1980, "tickets": 10, "key": "first_charge_claimed", "once": true, "icon": app.UI_MAIN_CHARGE_ICONS[3]},
		{"name": "月度源石", "desc": "源石 x980 / 喚靈券 x3", "gems": 980, "tickets": 3, "key": "charge_monthly_count", "once": false, "icon": app.UI_MAIN_CHARGE_ICONS[2]},
		{"name": "喚靈補給", "desc": "源石 x300 / 喚靈券 x5", "gems": 300, "tickets": 5, "key": "charge_ticket_count", "once": false, "icon": app.UI_MAIN_LIMIT_ICONS[5]},
	]
	for index in range(packs.size()):
		var pack: Dictionary = packs[index]
		var pos: Vector2 = origin + Vector2(0, index * 118)
		app._draw_home_resource_card(pos, Vector2(860, 94), Color(1.0, 0.76, 0.34, 0.28), index % 2 == 1)
		app._draw_image(str(pack.get("icon", app.UI_MAIN_CHARGE_ICONS[3])), pos + Vector2(12, 8), Vector2(78, 78), false, Color(1, 1, 1, 0.94))
		var title: Label = app._label(str(pack.get("name", "")), 22)
		title.position = pos + Vector2(106, 12)
		title.size = Vector2(190, 30)
		title.modulate = Color(1.0, 0.93, 0.70)
		app._view_container().add_child(title)
		var desc: Label = app._label(str(pack.get("desc", "")), 16)
		desc.position = pos + Vector2(106, 48)
		desc.size = Vector2(390, 26)
		desc.modulate = Color(0.92, 0.86, 0.82)
		app._view_container().add_child(desc)
		app._draw_home_reward_icon("res://assets/ui/item/draw_05.png", pos + Vector2(500, -4), "源石", "x%d" % int(pack.get("gems", 0)))
		app._draw_home_reward_icon("res://assets/ui/item/draw_07.png", pos + Vector2(586, -4), "喚靈券", "x%d" % int(pack.get("tickets", 0)))
		var is_once: bool = bool(pack.get("once", false))
		var claimed: bool = bool(app.save.get(str(pack.get("key", "")), false)) if is_once else false
		if claimed:
			var claimed_label: Label = app._label("已領取", 18, HORIZONTAL_ALIGNMENT_CENTER)
			claimed_label.position = pos + Vector2(724, 28)
			claimed_label.size = Vector2(110, 36)
			claimed_label.modulate = Color(0.70, 1.0, 0.58)
			app._view_container().add_child(claimed_label)
		else:
			app._add_action_button("領取" if index == 0 else "購買", pos + Vector2(724, 26), func(p := pack) -> void:
				app._buy_charge_pack(p)
			, Vector2(104, 42), app.UI_COMMON_BTN_GOLD)
	var wallet: Label = app._label("當前：源石 %s / 喚靈券 %s\n首儲狀態：%s" % [
		str(app.save.get("gems", 0)),
		str(app.save.get("tickets", 0)),
		"已完成" if first_claimed else "可領取"
	], 19)
	wallet.position = origin + Vector2(0, 372)
	wallet.size = Vector2(520, 64)
	wallet.modulate = Color(0.95, 0.90, 0.78)
	app._view_container().add_child(wallet)
	app._add_action_button("前往商店", origin + Vector2(600, 382), app._show_shop, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func show_shop() -> void:
	var origin: Vector2 = app._show_home_panel("商店", "資源補給與喚靈券兌換。")
	var title: Label = app._label("資源補給", 34)
	title.position = origin
	title.size = Vector2(420, 52)
	title.modulate = Color(1.0, 0.93, 0.70)
	app._view_container().add_child(title)
	var desc: Label = app._label("單機 MVP 暫定兌換規則：源石 %d = 喚靈券 %d。日常、郵件和章節任務也會產出喚靈資源。" % [int(app.shop.get("exchangeGemCost", 160)), int(app.shop.get("ticketAmount", 1))], 20)
	desc.position = origin + Vector2(0, 58)
	desc.size = Vector2(760, 72)
	app._view_container().add_child(desc)
	app._draw_home_reward_icon("res://assets/ui/item/draw_05.png", origin + Vector2(820, -10), "源石", str(app.save.get("gems", 0)))
	app._draw_home_reward_icon("res://assets/ui/item/draw_07.png", origin + Vector2(908, -10), "喚靈券", str(app.save.get("tickets", 0)))
	app._add_action_button("兌換 1 張", origin + Vector2(0, 140), func() -> void: app._buy_tickets(1), Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("兌換 10 張", origin + Vector2(146, 140), func() -> void: app._buy_tickets(10), Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("每日補給", origin + Vector2(292, 140), app._show_daily, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("郵件", origin + Vector2(438, 140), app._show_mail, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("任務", origin + Vector2(584, 140), app._show_tasks, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("前往喚靈", origin + Vector2(0, 214), app._show_gacha, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)


func show_daily() -> void:
	var origin: Vector2 = app._show_home_panel("每日補給", "每日刷新獎勵，補充基礎抽卡資源。")
	var today: String = Time.get_date_string_from_system()
	var claimed: bool = str(app.save.get("daily_claimed_date", "")) == today
	var reward_tickets: int = int(app.daily.get("tickets", 3))
	var reward_gems: int = int(app.daily.get("gems", 480))
	var title: Label = app._label(str(app.daily.get("name", "每日補給")), 34)
	title.position = origin
	title.size = Vector2(420, 52)
	title.modulate = Color(1.0, 0.93, 0.70)
	app._view_container().add_child(title)
	app._draw_home_reward_icon("res://assets/ui/item/draw_07.png", origin + Vector2(0, 78), "喚靈券", "x%d" % reward_tickets)
	app._draw_home_reward_icon("res://assets/ui/item/draw_05.png", origin + Vector2(92, 78), "源石", "x%d" % reward_gems)
	var text: String = "%s\n喚靈券 x%d\n源石 x%d\n\n狀態：%s" % [app.daily.get("desc", "今日補給"), reward_tickets, reward_gems, "已領取" if claimed else "可領取"]
	var label: Label = app._label(text, 22)
	label.position = origin + Vector2(220, 74)
	label.size = Vector2(520, 180)
	app._view_container().add_child(label)
	if not claimed:
		app._add_action_button("領取", origin + Vector2(0, 228), func() -> void:
			app.save["daily_claimed_date"] = today
			app._grant_reward(reward_tickets, reward_gems)
			show_daily()
		, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("返回商店", origin + Vector2(154, 228), app._show_shop, Vector2(146, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("前往喚靈", origin + Vector2(314, 228), app._show_gacha, Vector2(146, 44), app.UI_COMMON_BTN_GOLD)
