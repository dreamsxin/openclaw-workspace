# UTF-8 source. Battle / AutoFight views split from main.gd.
extends RefCounted

var app

func _init(app_ref) -> void:
	app = app_ref


func show_auto_fight() -> void:
	var origin: Vector2 = app._show_home_panel("自動挑戰", "主屏冒險上方的自動挑戰橫幅，接入關卡推進與掛機收益。")
	var stage: Dictionary = app._next_stage()
	var stage_name: String = str(stage.get("name", "全部完成"))
	var stage_power: int = int(stage.get("power", 0))
	var enabled: bool = bool(app.save.get("auto_fight_enabled", true))
	var summary: Label = app._label("狀態：%s\n目標：%s\n推薦戰力：%d\n目前戰力：%d\n掛機時間：%s" % [
		"自動挑戰中" if enabled else "已暫停",
		stage_name,
		stage_power,
		app._player_power(),
		app._afk_time_display()
	], 22)
	app._draw_home_resource_card(origin, Vector2(640, 190), Color(0.84, 0.92, 1.0, 0.30), false)
	app._draw_image(app.UI_MAIN_FUNNY_ARENA, origin + Vector2(18, 30), Vector2(88, 102), false, Color(1, 1, 1, 0.86))
	app._draw_image(app.UI_MAIN_CHARGE_ICONS[0], origin + Vector2(452, 24), Vector2(86, 86), false, Color(1, 1, 1, 0.82))
	summary.position = origin + Vector2(126, 18)
	summary.size = Vector2(480, 160)
	app._view_container().add_child(summary)
	app._add_action_button("切換狀態", origin + Vector2(0, 214), func() -> void:
		app.save["auto_fight_enabled"] = not bool(app.save.get("auto_fight_enabled", true))
		app._persist()
		show_auto_fight()
	, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("挑戰一次", origin + Vector2(154, 214), app._fight_next_stage, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("收取掛機", origin + Vector2(308, 214), app._claim_afk_reward, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("查看戰役", origin + Vector2(462, 214), app._show_battle, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func show_battle(message := "") -> void:
	app._clear("戰役")
	app._draw_image(app.UI_MAIN_BG, Vector2(0, 0), app.CONTENT_SIZE, true, Color(1, 1, 1, 0.42))
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CONTENT_SIZE, Color(0.018, 0.014, 0.012, 0.50)))
	var title: Label = app._label("戰役推進", 34)
	title.position = Vector2(44, 32)
	title.size = Vector2(360, 52)
	app._view_container().add_child(title)
	var current_stage: Dictionary = app._next_stage()
	var player_power: int = app._player_power()
	var stage_power: int = int(current_stage.get("power", 0))
	var status: String = "可挑戰" if player_power >= stage_power else "戰力不足"
	if current_stage.is_empty():
		status = "章節已完成"
	var summary: Label = app._label("目前戰力: %d\n已通關: %s\n下一關: %s\n推薦戰力: %d\n狀態: %s" % [
		player_power,
		app._stage_name(int(app.save.get("max_stage_id", 0))),
		current_stage.get("name", "全部完成"),
		stage_power,
		status
	], 20)
	summary.position = Vector2(58, 102)
	summary.size = Vector2(430, 150)
	app._view_container().add_child(summary)
	if not message.is_empty():
		var result: Label = app._label(message, 19)
		result.position = Vector2(58, 268)
		result.size = Vector2(520, 92)
		result.modulate = Color(1.0, 0.86, 0.48, 1.0)
		app._view_container().add_child(result)

	var y := 94.0
	for chapter in app.chapters:
		var panel: ColorRect = app._panel(Vector2(586, y), Vector2(598, 120), Color(0.048, 0.038, 0.033, 0.82))
		app._view_container().add_child(panel)
		var name: Label = app._label(str(chapter.get("name", "")), 22)
		name.position = Vector2(606, y + 12)
		name.size = Vector2(360, 30)
		app._view_container().add_child(name)
		var stage_text := []
		for stage in chapter.get("stages", []):
			var sid := int(stage.get("id", 0))
			var mark := "已通關" if sid <= int(app.save.get("max_stage_id", 0)) else ("下一關" if sid == int(current_stage.get("id", 0)) else "未解鎖")
			stage_text.append("%s  %s  戰力%d" % [mark, stage.get("name", ""), int(stage.get("power", 0))])
		var rows: Label = app._label("\n".join(stage_text), 15)
		rows.position = Vector2(606, y + 48)
		rows.size = Vector2(548, 64)
		app._view_container().add_child(rows)
		y += 136

	if not current_stage.is_empty():
		app._add_action_button("挑戰", Vector2(58, 386), app._fight_next_stage, Vector2(132, 46))
	app._add_action_button("收取掛機", Vector2(210, 386), app._claim_afk_reward, Vector2(132, 46))
	app._add_action_button("前往喚靈", Vector2(362, 386), app._show_gacha, Vector2(132, 46))
	app._add_action_button("返回主界面", Vector2(58, 548), app._show_home, Vector2(146, 44))
