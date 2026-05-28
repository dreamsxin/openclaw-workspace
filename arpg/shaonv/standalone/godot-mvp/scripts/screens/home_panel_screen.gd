# UTF-8 source. Home sub-panels split from main.gd.
extends RefCounted

var app

func _init(app_ref) -> void:
	app = app_ref


func show_player_info() -> void:
	var origin: Vector2 = app._show_home_panel("玩家資料", "MainUIView btnPlayerInfo 一級資料面板。")
	var profile: Dictionary = app.save.get("profile", {})
	var settings: Dictionary = app.save.get("settings", {})
	var hero: Dictionary = app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))
	app._draw_home_resource_card(origin, Vector2(640, 214), Color(1.0, 0.82, 0.42, 0.30), false)
	app._draw_image("res://assets/ui/mainui/mainui_img_02.png", origin + Vector2(14, 18), Vector2(240, 76), false, Color(1, 1, 1, 0.88))
	app._draw_image("res://assets/ui/mainui/mainui_img_03.png", origin + Vector2(42, 34), Vector2(76, 76), false, Color(1, 1, 1, 0.88))
	app._draw_image("res://assets/ui/mainui/mainui_img_04.png", origin + Vector2(38, 30), Vector2(84, 84), false, Color(1, 0.84, 0.28, 0.82))
	app._draw_hero_round_thumb(hero, origin + Vector2(45, 37), Vector2(70, 70), Color(1, 1, 1, 0.95))
	var info = app._label("名稱：%s\n等級：%d\n戰力：%d\n收集幻靈：%d\n累計喚靈：%d\n看板自動播放：%s" % [
		profile.get("name", "Player"),
		int(profile.get("level", 1)),
		app._player_power(),
		app.save.get("owned", {}).size(),
		int(app.save.get("draw_count", 0)),
		"開" if bool(settings.get("wallpaper_auto_play", true)) else "關"
	], 21)
	info.position = origin + Vector2(150, 24)
	info.size = Vector2(450, 166)
	app._view_container().add_child(info)
	app._add_action_button("設定", origin + Vector2(0, 246), app._show_settings)
	app._add_action_button("壁紙", origin + Vector2(146, 246), app._show_wallpaper_select, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("幻靈", origin + Vector2(292, 246), app._show_gallery, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)


func show_settings() -> void:
	var origin: Vector2 = app._show_home_panel("系統設定", "MainUIView 快捷選單中的本地設定入口。")
	var settings: Dictionary = app.save.get("settings", {})
	var rows := [
		{"label": "看板自動播放", "key": "wallpaper_auto_play", "value": bool(settings.get("wallpaper_auto_play", true)), "icon": "res://assets/ui/mainui/mainui_btn_12.png"},
		{"label": "音樂", "key": "music", "value": bool(settings.get("music", true)), "icon": "res://assets/ui/mainui/mainui_btn_10.png"},
		{"label": "音效", "key": "effects", "value": bool(settings.get("effects", true)), "icon": "res://assets/ui/mainui/mainui_btn_11.png"}
	]
	for index in range(rows.size()):
		var item: Dictionary = rows[index]
		var pos := origin + Vector2(0, index * 92)
		app._draw_home_resource_card(pos, Vector2(620, 72), Color(0.76, 0.88, 1.0, 0.28), index % 2 == 1)
		app._draw_image(str(item.get("icon", app.UI_MAIN_LIMIT_ICON_FRAME)), pos + Vector2(12, -7), Vector2(76, 76), false, Color(1, 1, 1, 0.90))
		var label: Label = app._label("%s：%s" % [str(item.get("label", "")), "開" if bool(item.get("value", true)) else "關"], 22)
		label.position = pos + Vector2(106, 14)
		label.size = Vector2(260, 40)
		label.modulate = Color(1.0, 0.93, 0.70)
		app._view_container().add_child(label)
		app._add_toggle_button(str(item.get("label", "")), str(item.get("key", "")), pos + Vector2(440, 14), bool(item.get("value", true)))
	app._add_action_button("玩家資料", origin + Vector2(0, 310), app._show_player_info)
	app._add_action_button("返回選單", origin + Vector2(146, 310), app._show_home_menu, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func show_home_menu() -> void:
	var origin = app._show_home_panel("快捷選單", "主屏右上角羅盤入口，收束公告、郵件、設定與資源修復。")
	var entries: Array = app._mainui_group("menu")
	for index in range(entries.size()):
		var item: Dictionary = entries[index]
		var col = index % 3
		var row = index / 3
		var pos = origin + Vector2(col * 304, row * 148)
		app._draw_home_resource_card(pos, Vector2(264, 112), Color(0.76, 0.88, 1.0, 0.30), index % 2 == 1)
		app._draw_image(str(item.get("icon", app.UI_MAIN_LIMIT_ICON_FRAME)), pos + Vector2(12, 14), Vector2(76, 76), false, Color(1, 1, 1, 0.92))
		var title = app._label(str(item.get("label", "")), 21)
		title.position = pos + Vector2(98, 14)
		title.size = Vector2(144, 28)
		title.modulate = Color(1.0, 0.94, 0.74)
		app._view_container().add_child(title)
		var desc = app._label(_menu_desc_for_target(str(item.get("target", ""))), 14)
		desc.position = pos + Vector2(98, 46)
		desc.size = Vector2(142, 46)
		desc.modulate = Color(0.90, 0.86, 0.82)
		app._view_container().add_child(desc)
		if app._mainui_red_dot_active(str(item.get("red_dot_key", "")), str(item.get("id", ""))):
			app._draw_red_dot(pos + Vector2(238, 8))
		app._add_hit_button(pos, Vector2(264, 112), app._mainui_entry_callable(item))


func _menu_desc_for_target(target: String) -> String:
	match target:
		"player_info":
			return "查看等級、戰力、收集與看板狀態。"
		"settings":
			return "音樂、音效與看板自動播放。"
		"mail":
			return "領取補償與系統獎勵。"
		"repair_notice":
			return "檢查本地 MVP 資源導出狀態。"
		"home_notice":
			return "查看本地公告與活動提示。"
		"assist":
			return "回到主屏小助手建議。"
		_:
			return "MainUIView 快捷功能入口。"


func show_home_notice() -> void:
	var origin = app._show_home_panel("公告", "本地 MVP 公告中心，對應右上快捷選單與登入公告。")
	var notices = [
		{"title": "資源恢復進度", "body": "Home、Gal、幻靈列表和詳情已接入本地導出的 UI/角色資源。"},
		{"title": "今日活動", "body": "每日補給、郵件、章節任務與萬象喚靈可形成完整離線循環。"},
		{"title": "測試提示", "body": "可用 SHAONV_MVP_START_VIEW 指定 main、charge、chapter 等入口回歸截圖。"},
	]
	for index in range(notices.size()):
		var notice: Dictionary = notices[index]
		var pos = origin + Vector2(0, index * 104)
		app._draw_home_resource_card(pos, Vector2(820, 82), Color(1.0, 0.82, 0.42, 0.25), index % 2 == 1)
		var title = app._label(str(notice.get("title", "")), 21)
		title.position = pos + Vector2(24, 8)
		title.size = Vector2(220, 30)
		title.modulate = Color(1.0, 0.94, 0.70)
		app._view_container().add_child(title)
		var body = app._label(str(notice.get("body", "")), 16)
		body.position = pos + Vector2(24, 42)
		body.size = Vector2(760, 28)
		body.modulate = Color(0.90, 0.86, 0.82)
		app._view_container().add_child(body)
	app._add_action_button("返回選單", Vector2(270, 580), app._show_home_menu, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func show_repair_notice() -> void:
	var origin = app._show_home_panel("資源修復", "本地資源檢查入口，方便核對導出和 Godot 映射。")
	var checks = [
		{"name": "MainUI 圖集", "path": "assets/ui/mainui", "ok": FileAccess.file_exists("res://assets/ui/mainui/mainui_btn_25.png")},
		{"name": "通用按鈕", "path": "assets/ui/common", "ok": FileAccess.file_exists("res://assets/ui/common/tongyong_btn_08.png")},
		{"name": "Mail 圖集", "path": "assets/ui/mail", "ok": FileAccess.file_exists("res://assets/ui/mail/mail_img_01.png")},
		{"name": "Task 圖集", "path": "assets/ui/task", "ok": FileAccess.file_exists("res://assets/ui/task/task_img_18.png")},
		{"name": "Welfare 圖集", "path": "assets/ui/welfare", "ok": FileAccess.file_exists("res://assets/ui/welfare/welfare_w1_img_01.png")},
		{"name": "英雄圓頭像", "path": "assets/ui/hero/round", "ok": FileAccess.file_exists("res://assets/ui/hero/round/yhero_037.png")},
		{"name": "Gal Spine", "path": "assets/spine/hero_037r_s01", "ok": FileAccess.file_exists("res://assets/spine/hero_037r_s01/hero_037r_s01.baked.json")},
	]
	for index in range(checks.size()):
		var item: Dictionary = checks[index]
		var pos = origin + Vector2(0, index * 72)
		app._draw_home_resource_card(pos, Vector2(820, 54), Color(0.70, 0.90, 1.0, 0.24), index % 2 == 1)
		var state = "已找到" if bool(item.get("ok", false)) else "待導出"
		var color = Color(0.66, 1.0, 0.54) if bool(item.get("ok", false)) else Color(1.0, 0.62, 0.44)
		var label = app._label("%s    %s    %s" % [item.get("name", ""), state, item.get("path", "")], 18)
		label.position = pos + Vector2(20, 8)
		label.size = Vector2(780, 34)
		label.modulate = color
		app._view_container().add_child(label)
	app._add_action_button("返回選單", Vector2(270, 580), app._show_home_menu, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func show_bag() -> void:
	var origin = app._show_home_panel("背包", "查看當前持有的喚靈券、源石、碎片和活動道具。")
	var items = [
		{"icon": "res://assets/ui/item/draw_07.png", "name": "喚靈券", "count": int(app.save.get("tickets", 0)), "desc": "用於喚靈抽取。"},
		{"icon": "res://assets/ui/item/draw_05.png", "name": "源石", "count": int(app.save.get("gems", 0)), "desc": "可在商店兌換喚靈券。"},
		{"icon": "res://assets/ui/item/draw_06.png", "name": "英雄碎片", "count": app.save.get("shards", {}).size(), "desc": "重複喚靈或關卡獎勵獲得。"},
		{"icon": "res://assets/ui/item/draw_04.png", "name": "活動道具", "count": int(app.save.get("event_tokens", 0)), "desc": "活動、福利與任務產出。"},
	]
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var col = index % 2
		var row = index / 2
		var pos = origin + Vector2(col * 470, row * 132)
		app._draw_home_resource_card(pos, Vector2(420, 104), app._rarity_color(2 + index % 3, 0.36), index % 2 == 1)
		app._draw_home_reward_icon(str(item.get("icon", "")), pos + Vector2(16, 4), "", "x%s" % str(item.get("count", 0)))
		var name = app._label("%s  x%s" % [str(item.get("name", "")), str(item.get("count", 0))], 22)
		name.position = pos + Vector2(106, 18)
		name.size = Vector2(280, 30)
		name.modulate = Color(1.0, 0.93, 0.70)
		app._view_container().add_child(name)
		var desc = app._label(str(item.get("desc", "")), 15)
		desc.position = pos + Vector2(106, 56)
		desc.size = Vector2(280, 24)
		desc.modulate = Color(0.90, 0.84, 0.80)
		app._view_container().add_child(desc)
	app._add_action_button("前往商店", Vector2(270, 580), app._show_shop, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("前往喚靈", Vector2(422, 580), app._show_gacha, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)


func show_relics() -> void:
	var origin = app._show_home_panel("遺器", "整理目前已發現的遺器線索，後續可接入完整遺器背包。")
	var rows = [
		{"name": "星核碎片", "slot": "攻擊", "state": "已裝備", "bonus": "攻擊 +8%"},
		{"name": "晨昏羽飾", "slot": "生命", "state": "可強化", "bonus": "生命 +12%"},
		{"name": "古域紋章", "slot": "速度", "state": "未裝備", "bonus": "速度 +5"},
	]
	for index in range(rows.size()):
		var item: Dictionary = rows[index]
		var pos = origin + Vector2(0, index * 104)
		app._draw_home_resource_card(pos, Vector2(780, 84), Color(0.70, 0.78, 1.0, 0.34), index % 2 == 1)
		app._draw_home_reward_icon("res://assets/ui/item/draw_0%d.png" % (index + 1), pos + Vector2(12, -6), str(item.get("slot", "")), "")
		var title = app._label(str(item.get("name", "")), 22)
		title.position = pos + Vector2(104, 12)
		title.size = Vector2(180, 30)
		title.modulate = Color(1.0, 0.93, 0.70)
		app._view_container().add_child(title)
		var meta = app._label("%s / %s / %s" % [item.get("slot", ""), item.get("state", ""), item.get("bonus", "")], 16)
		meta.position = pos + Vector2(314, 18)
		meta.size = Vector2(420, 28)
		meta.modulate = Color(0.92, 0.86, 0.82)
		app._view_container().add_child(meta)
	app._add_action_button("幻靈列表", Vector2(270, 580), app._show_remnants_list, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)


func show_develop() -> void:
	var origin = app._show_home_panel("養成", "角色養成入口：查看英雄、進入詳情、前往 Gal 看板或幻靈列表。")
	var actions = [
		{"name": "英雄列表", "desc": "查看所有英雄與持有狀態。", "callback": app._show_gallery, "icon": app.UI_MAIN_LIMIT_ICONS[0]},
		{"name": "當前英雄", "desc": "進入當前選中英雄詳情。", "callback": func() -> void: app._show_hero_detail(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID))), "icon": app.UI_MAIN_LIMIT_ICONS[1]},
		{"name": "Gal 看板", "desc": "進入現世互動與裝扮。", "callback": app._show_gal, "icon": "res://assets/ui/mainui/mainui_btn_25.png"},
		{"name": "幻靈列表", "desc": "查看幻靈列表與詳情。", "callback": app._show_remnants_list, "icon": app.UI_MAIN_LIMIT_ICONS[2]},
	]
	for index in range(actions.size()):
		var item: Dictionary = actions[index]
		var col = index % 2
		var row = index / 2
		var pos = origin + Vector2(col * 430, row * 128)
		app._draw_home_resource_card(pos, Vector2(380, 96), app._rarity_color(3 + row, 0.32), index % 2 == 1)
		app._draw_image(str(item.get("icon", app.UI_MAIN_LIMIT_ICON_FRAME)), pos + Vector2(12, 8), Vector2(72, 72), false, Color(1, 1, 1, 0.92))
		var title = app._label(str(item.get("name", "")), 22)
		title.position = pos + Vector2(98, 12)
		title.size = Vector2(150, 30)
		title.modulate = Color(1.0, 0.93, 0.70)
		app._view_container().add_child(title)
		var desc = app._label(str(item.get("desc", "")), 15)
		desc.position = pos + Vector2(98, 48)
		desc.size = Vector2(250, 24)
		desc.modulate = Color(0.92, 0.86, 0.82)
		app._view_container().add_child(desc)
		app._add_action_button("前往", pos + Vector2(284, 26), item.get("callback", app._show_home), Vector2(72, 38), app.UI_COMMON_BTN_GOLD)


func show_guild() -> void:
	var origin = app._show_home_panel("公會", "單機 MVP 公會入口：目前提供簽到、捐獻與成員概覽。")
	var level = int(app.save.get("guild_level", 1))
	var contribution = int(app.save.get("guild_contribution", 0))
	var info = app._label("公會：星塵旅團\n等級：Lv.%d\n貢獻：%d\n今日狀態：%s" % [
		level,
		contribution,
		"已簽到" if str(app.save.get("guild_checkin_date", "")) == Time.get_date_string_from_system() else "可簽到"
	], 22)
	app._draw_home_resource_card(origin, Vector2(520, 166), Color(0.72, 0.88, 1.0, 0.34), false)
	app._draw_image(app.UI_MAIN_CHARGE_ICONS[1], origin + Vector2(20, 32), Vector2(86, 86), false, Color(1, 1, 1, 0.92))
	info.position = origin + Vector2(126, 22)
	info.size = Vector2(420, 160)
	app._view_container().add_child(info)
	app._add_action_button("公會簽到", origin + Vector2(0, 190), func() -> void:
		if str(app.save.get("guild_checkin_date", "")) != Time.get_date_string_from_system():
			app.save["guild_checkin_date"] = Time.get_date_string_from_system()
			app.save["guild_contribution"] = int(app.save.get("guild_contribution", 0)) + 10
			app._grant_reward(1, 120)
			app._persist()
		show_guild()
	, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("查看任務", origin + Vector2(154, 190), app._show_tasks, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)


func show_assist() -> void:
	var origin = app._show_home_panel("小助手", "整理當前可做事項，對應主屏的小助手入口。")
	var tips = [
		"先收取右下角塵世探秘掛機獎勵。",
		"每日補給和郵件可以補充喚靈資源。",
		"喚靈後可到養成/英雄列表查看新角色。",
		"現世入口可進入 Gal 看板與甜蜜互動。"
	]
	for index in range(tips.size()):
		var pos = origin + Vector2(0, index * 58)
		app._draw_home_resource_card(pos, Vector2(760, 44), Color(0.74, 0.92, 1.0, 0.24), index % 2 == 1)
		var label = app._label("%d. %s" % [index + 1, tips[index]], 19)
		label.position = pos + Vector2(18, 5)
		label.size = Vector2(720, 34)
		app._view_container().add_child(label)


func show_chat() -> void:
	var origin = app._show_home_panel("聊天", "世界頻道入口，目前顯示本地系統消息。")
	var messages = [
		"[世界] 塵世：?",
		"[系統] 今日補給已刷新。",
		"[公會] 星塵旅團歡迎回來。",
		"[活動] 新手狂歡進行中。"
	]
	for index in range(messages.size()):
		var pos = origin + Vector2(0, index * 58)
		app._draw_image("res://assets/ui/mainui/mainui_btn_04.png", pos, Vector2(760, 42), true, Color(1, 1, 1, 0.56))
		var label = app._label(messages[index], 19)
		label.position = pos + Vector2(22, 4)
		label.size = Vector2(720, 34)
		app._view_container().add_child(label)


func show_wallpaper_select() -> void:
	var origin = app._show_home_panel("壁紙", "選擇主界面看板角色，或進入純看板互動模式。")
	var candidates = app._gallery_filtered_heroes()
	var max_count = mini(candidates.size(), 5)
	for index in range(max_count):
		var hero: Dictionary = candidates[index]
		var pos = origin + Vector2(index * 154, 16)
		app._draw_home_resource_card(pos, Vector2(126, 166), app._rarity_color(int(hero.get("rarity", 1)), 0.34), index % 2 == 1)
		app._draw_image(app.UI_COMMON_HERO_HEAD_FRAME, pos + Vector2(28, 16), Vector2(70, 70), false, Color(1, 1, 1, 0.88))
		app._draw_hero_round_thumb(hero, pos + Vector2(28, 16), Vector2(70, 70), Color(1, 1, 1, 0.95))
		app._draw_image(app.UI_COMMON_HERO_STAR_BAR, pos + Vector2(28, 82), Vector2(70, 12), false, Color(1, 1, 1, 0.40))
		var label = app._label(str(hero.get("name", "")), 15, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + Vector2(8, 112)
		label.size = Vector2(110, 24)
		app._view_container().add_child(label)
		var hero_id = int(hero.get("id", 0))
		var button = Button.new()
		button.text = ""
		button.flat = true
		button.position = pos
		button.size = Vector2(126, 166)
		button.pressed.connect(func() -> void:
			app.save["selected_hero_id"] = hero_id
			app._persist()
			app._show_home()
		)
		app._view_container().add_child(button)
		if int(app.save.get("selected_hero_id", 0)) == hero_id:
			app._draw_image(app.UI_HERO_HIGHLIGHT, pos + Vector2(13, 1), Vector2(100, 100), false, Color(0.78, 1.0, 0.22, 0.48))
			var selected = app._label("看板中", 13, HORIZONTAL_ALIGNMENT_CENTER)
			selected.position = pos + Vector2(22, 138)
			selected.size = Vector2(82, 20)
			selected.modulate = Color(1.0, 0.84, 0.30)
			app._view_container().add_child(selected)
	app._add_action_button("純看板模式", origin + Vector2(0, 250), app._show_home_wallpaper_focus, Vector2(146, 44), app.UI_COMMON_BTN_GOLD)


func show_mail() -> void:
	var origin = app._show_home_panel("郵件", "系統郵件與補償獎勵。")
	var title = app._label("郵件", 34)
	title.position = origin
	title.size = Vector2(420, 52)
	title.modulate = Color(1.0, 0.93, 0.70)
	app._view_container().add_child(title)
	var claimed: Dictionary = app.save.get("claimed_mail", {})
	var y = origin.y + 72.0
	for mail in app.mails:
		var mail_id = str(mail.get("id", ""))
		var is_claimed = bool(claimed.get(mail_id, false))
		var row_pos = Vector2(origin.x, y)
		app._draw_home_resource_card(row_pos, Vector2(820, 94), Color(0.72, 0.86, 1.0, 0.28), int(y) % 2 == 0)
		app._draw_image("res://assets/ui/mail/mail_img_02.png", row_pos + Vector2(8, 8), Vector2(78, 78), false, Color(1, 1, 1, 0.68))
		app._draw_image("res://assets/ui/mail/mail_img_01.png", row_pos + Vector2(18, 18), Vector2(58, 58), false, Color(1, 1, 1, 0.92))
		var row = app._label("%s\n%s\n獎勵：喚靈券 x%d  源石 x%d   %s" % [mail.get("title", ""), mail.get("body", ""), int(mail.get("tickets", 0)), int(mail.get("gems", 0)), "已領取" if is_claimed else "可領取"], 17)
		row.position = row_pos + Vector2(92, 8)
		row.size = Vector2(600, 78)
		app._view_container().add_child(row)
		if not is_claimed:
			app._add_action_button("領取", row_pos + Vector2(684, 26), func(id = mail_id, tickets = int(mail.get("tickets", 0)), gems = int(mail.get("gems", 0))) -> void:
				var mail_claimed: Dictionary = app.save.get("claimed_mail", {})
				mail_claimed[id] = true
				app.save["claimed_mail"] = mail_claimed
				app._grant_reward(tickets, gems)
				show_mail()
			, Vector2(104, 42), app.UI_COMMON_BTN_GOLD)
		y += 108
	app._add_action_button("返回主界面", Vector2(104, 580), app._show_home, Vector2(146, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("前往喚靈", Vector2(264, 580), app._show_gacha, Vector2(146, 44), app.UI_COMMON_BTN_GOLD)


func show_tasks() -> void:
	var origin = app._show_home_panel("章節任務", "推進主線、喚靈與養成任務。")
	var title = app._label("章節任務", 34)
	title.position = origin
	title.size = Vector2(420, 52)
	title.modulate = Color(1.0, 0.93, 0.70)
	app._view_container().add_child(title)
	var claimed: Dictionary = app.save.get("claimed_tasks", {})
	var y = origin.y + 72.0
	var shown_tasks = 0
	for task in app.tasks:
		if shown_tasks >= 3:
			break
		shown_tasks += 1
		var task_id = str(task.get("id", ""))
		var progress = app._task_progress(task_id)
		var target = int(task.get("target", 1))
		var done = progress >= target
		var is_claimed = bool(claimed.get(task_id, false))
		var row_pos = Vector2(origin.x, y)
		app._draw_home_resource_card(row_pos, Vector2(860, 90), Color(1.0, 0.80, 0.42, 0.24), int(y) % 2 == 0)
		app._draw_image("res://assets/ui/task/task_img_18.png", row_pos + Vector2(12, 8), Vector2(70, 70), false, Color(1, 1, 1, 0.88))
		app._draw_image("res://assets/ui/task/task_img_03.png", row_pos + Vector2(20, 16), Vector2(54, 54), false, Color(1, 1, 1, 0.82))
		var row = app._label("%s\n%s  %d/%d\n獎勵：喚靈券 x%d  源石 x%d" % [task.get("name", ""), task.get("desc", ""), progress, target, int(task.get("tickets", 0)), int(task.get("gems", 0))], 17)
		row.position = row_pos + Vector2(92, 8)
		row.size = Vector2(630, 72)
		app._view_container().add_child(row)
		if is_claimed:
			var claimed_label = app._label("已領取", 18, HORIZONTAL_ALIGNMENT_CENTER)
			claimed_label.position = row_pos + Vector2(724, 22)
			claimed_label.size = Vector2(110, 42)
			app._view_container().add_child(claimed_label)
		elif done:
			app._add_action_button("領取", row_pos + Vector2(724, 22), func(id = task_id, tickets = int(task.get("tickets", 0)), gems = int(task.get("gems", 0))) -> void:
				var task_claimed: Dictionary = app.save.get("claimed_tasks", {})
				task_claimed[id] = true
				app.save["claimed_tasks"] = task_claimed
				app._grant_reward(tickets, gems)
				show_tasks()
			, Vector2(110, 42), app.UI_COMMON_BTN_GOLD)
		else:
			var todo = app._label("進行中", 18, HORIZONTAL_ALIGNMENT_CENTER)
			todo.position = row_pos + Vector2(724, 22)
			todo.size = Vector2(110, 42)
			app._view_container().add_child(todo)
		y += 102
	app._add_action_button("返回主界面", Vector2(104, 580), app._show_home, Vector2(146, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("前往喚靈", Vector2(264, 580), app._show_gacha, Vector2(146, 44), app.UI_COMMON_BTN_GOLD)
