extends Control

const SAVE_PATH := "user://shaonv_godot_mvp_save.json"
const HERO_DATA_PATH := "res://data/heroes_mvp.json"
const POOL_DATA_PATH := "res://data/gacha_pools_mvp.json"
const LIVE_OPS_DATA_PATH := "res://data/live_ops_mvp.json"

var heroes: Array = []
var pools: Array = []
var tasks: Array = []
var mails: Array = []
var daily := {}
var shop := {}
var save := {
	"profile": {
		"name": "Player",
		"level": 88,
		"base_power": 999999
	},
	"settings": {
		"wallpaper_auto_play": true,
		"music": true,
		"effects": true
	},
	"tickets": 120,
	"gems": 16800,
	"owned": {},
	"shards": {},
	"pity": {},
	"history": [],
	"draw_count": 0,
	"claimed_tasks": {},
	"claimed_mail": {},
	"daily_claimed_date": "",
	"selected_hero_id": 240065,
	"active_pool_id": "advanced"
}

var rng := RandomNumberGenerator.new()
var content: Control
var title_label: Label
var wallet_label: Label
var top_bar: Control
var current_view := "boot"

func _ready() -> void:
	rng.randomize()
	heroes = _read_json(HERO_DATA_PATH).get("heroes", [])
	pools = _read_json(POOL_DATA_PATH).get("pools", [])
	var live_ops := _read_json(LIVE_OPS_DATA_PATH)
	tasks = live_ops.get("tasks", [])
	mails = live_ops.get("mails", [])
	daily = live_ops.get("daily", {"tickets": 3, "gems": 480})
	shop = live_ops.get("shop", {"exchangeGemCost": 160, "ticketAmount": 1})
	_load_save()
	_build_root()
	_show_launch()

func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_warning("Missing or empty JSON: %s" % path)
		return {}
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid JSON object: %s" % path)
		return {}
	return parsed

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		save.merge(parsed, true)

func _persist() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save))

func _build_root() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.055, 0.055)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	top_bar = Control.new()
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(1280, 74)
	add_child(top_bar)

	var top_bg := ColorRect.new()
	top_bg.color = Color(0.055, 0.045, 0.04, 0.92)
	top_bg.position = Vector2(0, 0)
	top_bg.size = Vector2(1280, 74)
	top_bar.add_child(top_bg)

	var profile_button := Button.new()
	profile_button.text = _profile_summary()
	profile_button.position = Vector2(18, 10)
	profile_button.size = Vector2(220, 52)
	profile_button.pressed.connect(_show_player_info)
	top_bar.add_child(profile_button)

	title_label = _label("主界面", 28, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.position = Vector2(486, 16)
	title_label.size = Vector2(300, 42)
	add_child(title_label)

	wallet_label = _label("", 18, HORIZONTAL_ALIGNMENT_RIGHT)
	wallet_label.position = Vector2(840, 20)
	wallet_label.size = Vector2(410, 36)
	add_child(wallet_label)

	content = Control.new()
	content.position = Vector2(0, 74)
	content.size = Vector2(1280, 646)
	add_child(content)

func _set_chrome_visible(visible: bool) -> void:
	top_bar.visible = visible
	title_label.visible = visible
	wallet_label.visible = visible

func _clear(title: String) -> void:
	title_label.text = title
	for child in content.get_children():
		child.queue_free()
	_refresh_wallet()

func _show_launch() -> void:
	current_view = "launch"
	_set_chrome_visible(false)
	_clear("啟動")
	content.position = Vector2(0, 0)
	content.size = Vector2(1280, 720)
	content.add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.045, 0.038, 0.038)))
	var title := _label("少女回戰", 54, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(360, 210)
	title.size = Vector2(560, 82)
	content.add_child(title)
	var sub := _label("單機版 MVP", 24, HORIZONTAL_ALIGNMENT_CENTER)
	sub.position = Vector2(430, 302)
	sub.size = Vector2(420, 40)
	content.add_child(sub)
	_add_action_button("開始", Vector2(574, 420), _show_preloading, Vector2(132, 48))

func _show_preloading() -> void:
	current_view = "preloading"
	_set_chrome_visible(false)
	_clear("預載入")
	content.position = Vector2(0, 0)
	content.size = Vector2(1280, 720)
	content.add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.06, 0.052, 0.048)))
	var title := _label("PreloadingView", 34, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(390, 230)
	title.size = Vector2(500, 54)
	content.add_child(title)
	var info := _label("載入本地資料、角色資源與喚靈配置", 22, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = Vector2(330, 304)
	info.size = Vector2(620, 42)
	content.add_child(info)
	_draw_progress_bar(Vector2(360, 380), Vector2(560, 22), 0.65)
	_add_action_button("繼續", Vector2(574, 438), _show_login, Vector2(132, 48))

func _show_login() -> void:
	current_view = "login"
	_set_chrome_visible(false)
	_clear("登入")
	content.position = Vector2(0, 0)
	content.size = Vector2(1280, 720)
	content.add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.075, 0.062, 0.055)))
	var title := _label("LoginView", 38, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(390, 178)
	title.size = Vector2(500, 58)
	content.add_child(title)
	var panel := _panel(Vector2(430, 260), Vector2(420, 190), Color(0.11, 0.09, 0.075, 0.95))
	content.add_child(panel)
	var account := _label("離線帳號\nPlayer\n伺服器：Local MainScene", 21, HORIZONTAL_ALIGNMENT_CENTER)
	account.position = Vector2(456, 292)
	account.size = Vector2(368, 86)
	content.add_child(account)
	_add_action_button("離線登入", Vector2(574, 392), _show_loading, Vector2(132, 48))

func _show_loading() -> void:
	current_view = "loading"
	_set_chrome_visible(false)
	_clear("載入")
	content.position = Vector2(0, 0)
	content.size = Vector2(1280, 720)
	content.add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.045, 0.045, 0.052)))
	var title := _label("LoadingView", 34, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(390, 230)
	title.size = Vector2(500, 54)
	content.add_child(title)
	var info := _label("GameHelper.LoadMainScene -> MainUIView", 22, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = Vector2(330, 304)
	info.size = Vector2(620, 42)
	content.add_child(info)
	_draw_progress_bar(Vector2(360, 380), Vector2(560, 22), 1.0)
	_add_action_button("進入主界面", Vector2(554, 438), _enter_main_scene, Vector2(172, 48))

func _enter_main_scene() -> void:
	content.position = Vector2(0, 74)
	content.size = Vector2(1280, 646)
	_set_chrome_visible(true)
	_show_home()

func _refresh_wallet() -> void:
	if top_bar != null and top_bar.get_child_count() > 1 and top_bar.get_child(1) is Button:
		top_bar.get_child(1).text = _profile_summary()
	wallet_label.text = "郵件 %d   喚靈券 %s   源石 %s" % [_unclaimed_mail_count(), save.get("tickets", 0), save.get("gems", 0)]

func _show_home() -> void:
	current_view = "main"
	content.position = Vector2(0, 74)
	content.size = Vector2(1280, 646)
	_set_chrome_visible(true)
	_clear("主界面")
	var hero := _hero_by_id(int(save.get("selected_hero_id", 240065)))
	_draw_wallpaper_stage(hero)
	_draw_home_side_entries()
	_draw_home_bottom_bar()
	_draw_home_status()

func _show_gacha() -> void:
	_clear("抽卡")
	var bg := _panel(Vector2(0, 0), Vector2(1280, 646), Color(0.09, 0.075, 0.075))
	content.add_child(bg)

	var left_panel := _panel(Vector2(22, 22), Vector2(264, 586), Color(0.13, 0.105, 0.095, 0.92))
	content.add_child(left_panel)

	var x := 42.0
	var y := 52.0
	for pool in pools:
		var pool_id := str(pool.get("id", "advanced"))
		var button := Button.new()
		button.text = "%s%s" % ["✓ " if pool_id == str(save.get("active_pool_id", "advanced")) else "", str(pool.get("name", "Pool"))]
		button.position = Vector2(x, y)
		button.size = Vector2(210, 46)
		button.pressed.connect(func() -> void:
			save["active_pool_id"] = pool_id
			_persist()
			_show_gacha()
		)
		content.add_child(button)
		y += 58

	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	var hero := _hero_by_id(int(pool.get("featuredHeroIds", [240055])[0]))
	_draw_hero_stage(hero, Vector2(690, 14), Vector2(520, 560), false)

	var title := _label(str(pool.get("name", "高級喚靈")), 42)
	title.position = Vector2(326, 44)
	title.size = Vector2(500, 56)
	content.add_child(title)

	var featured_names := []
	for id in pool.get("featuredHeroIds", []):
		featured_names.append(_hero_by_id(int(id)).get("name", str(id)))
	var detail := _label("UP 角色\n%s\n\n保底 %d/%d\n消耗 喚靈券 x%d" % [" / ".join(featured_names), _pity(pool.get("id", "advanced")), int(pool.get("pityLimit", 60)), int(pool.get("ticketCost", 1))], 21)
	detail.position = Vector2(326, 132)
	detail.size = Vector2(430, 170)
	content.add_child(detail)

	_add_action_button("概率", Vector2(326, 334), _show_gacha_rate)
	_add_action_button("記錄", Vector2(472, 334), _show_history)
	_add_action_button("喚靈 1 次", Vector2(326, 468), func() -> void: _draw_and_show(1))
	_add_action_button("喚靈 10 次", Vector2(492, 468), func() -> void: _draw_and_show(10), Vector2(156, 50))
	_add_action_button("返回主界面", Vector2(22, 546), _show_home, Vector2(210, 44))

func _draw_and_show(count: int) -> void:
	var results := _perform_draw(count)
	_clear("結果")
	if results.is_empty():
		var warning := _label("喚靈券不足", 30)
		warning.position = Vector2(360, 150)
		content.add_child(warning)
		_add_action_button("返回", Vector2(360, 226), _show_gacha)
		return
	_draw_result_stage(results[0])
	var x := 66.0
	var y := 440.0
	for result in results:
		var hero: Dictionary = result.get("hero", {})
		var hero_id := int(hero.get("id", 0))
		var card := Button.new()
		card.text = "%s\n%s\n%s" % [_stars(int(result.get("rolled_rarity", 1))), hero.get("name", ""), "NEW" if result.get("is_new", false) else "碎片 +%d" % int(result.get("shards", 0))]
		card.position = Vector2(x, y)
		card.size = Vector2(108, 74)
		card.pressed.connect(func() -> void:
			_show_hero_detail(hero_id)
		)
		content.add_child(card)
		x += 118
	_add_action_button("再抽一次", Vector2(850, 538), func() -> void: _draw_and_show(count), Vector2(132, 46))
	_add_action_button("返回卡池", Vector2(994, 538), _show_gacha, Vector2(132, 46))
	_add_action_button("圖鑑", Vector2(1138, 538), _show_gallery, Vector2(92, 46))

func _show_gallery() -> void:
	_clear("圖鑑")
	var header := _label("武將圖鑑", 34)
	header.position = Vector2(40, 24)
	header.size = Vector2(280, 50)
	content.add_child(header)
	var x := 40.0
	var y := 96.0
	for hero in heroes:
		var button := Button.new()
		var hero_id := int(hero.get("id", 0))
		var copies := int(save.get("owned", {}).get(str(hero_id), 0))
		var shards := int(save.get("shards", {}).get(str(hero_id), 0))
		button.text = "%s\n%s x%d  碎%d" % [hero.get("name", "Unknown") if copies > 0 else "未獲得", _stars(int(hero.get("rarity", 1))), copies, shards]
		button.position = Vector2(x, y)
		button.size = Vector2(176, 94)
		button.pressed.connect(func() -> void:
			_show_hero_detail(hero_id)
		)
		content.add_child(button)
		x += 194
		if x > 1080:
			x = 40
			y += 110

func _show_history() -> void:
	_clear("記錄")
	var lines := []
	for row in save.get("history", []):
		lines.append("%s %s\n%s" % [row.get("time", ""), row.get("pool_name", ""), row.get("result_text", "")])
	var label := _label("\n\n".join(lines) if not lines.is_empty() else "暫無抽卡記錄", 18)
	label.position = Vector2(44, 44)
	label.size = Vector2(1080, 440)
	content.add_child(label)
	_add_action_button("重置存檔", Vector2(44, 524), func() -> void:
		save = {
			"tickets": 120,
			"gems": 16800,
			"profile": {
				"name": "Player",
				"level": 88,
				"base_power": 999999
			},
			"settings": {
				"wallpaper_auto_play": true,
				"music": true,
				"effects": true
			},
			"owned": {},
			"shards": {},
			"pity": {},
			"history": [],
			"draw_count": 0,
			"claimed_tasks": {},
			"claimed_mail": {},
			"daily_claimed_date": "",
			"selected_hero_id": 240065,
			"active_pool_id": "advanced"
		}
		_persist()
		_show_home()
	)
	_add_action_button("返回主界面", Vector2(190, 524), _show_home, Vector2(146, 44))

func _perform_draw(count: int) -> Array:
	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	var cost := count * int(pool.get("ticketCost", 1))
	if int(save.get("tickets", 0)) < cost:
		return []
	save["tickets"] = int(save.get("tickets", 0)) - cost
	save["draw_count"] = int(save.get("draw_count", 0)) + count
	var results: Array = []
	for i in range(count):
		results.append(_draw_one(pool))
	var history: Array = save.get("history", [])
	history.push_front({
		"time": Time.get_datetime_string_from_system(false, true),
		"pool_name": pool.get("name", ""),
		"result_text": "、".join(results.map(func(result): return "%s%s" % [result.get("hero", {}).get("name", ""), "(NEW)" if result.get("is_new", false) else ""]))
	})
	while history.size() > 30:
		history.pop_back()
	save["history"] = history
	_persist()
	return results

func _draw_one(pool: Dictionary) -> Dictionary:
	var pool_id := str(pool.get("id", "advanced"))
	var pity := _pity(pool_id) + 1
	var rarity := 2
	var roll := rng.randf()
	if pity >= int(pool.get("pityLimit", 60)) or roll < 0.02:
		rarity = 4
		pity = 0
	elif roll < 0.16:
		rarity = 3
	_set_pity(pool_id, pity)

	var candidates := []
	for hero in heroes:
		var hero_rarity := int(hero.get("rarity", 1))
		if rarity == 4:
			if hero_rarity == 4 or pool.get("featuredHeroIds", []).has(int(hero.get("id", 0))):
				candidates.append(hero)
		elif hero_rarity == rarity:
			candidates.append(hero)
	if candidates.is_empty():
		candidates = heroes.duplicate()

	var featured := []
	for hero in candidates:
		if pool.get("featuredHeroIds", []).has(int(hero.get("id", 0))):
			featured.append(hero)
	var list := featured if rarity >= 3 and not featured.is_empty() and rng.randf() < 0.55 else candidates
	var hero: Dictionary = list[rng.randi_range(0, list.size() - 1)]
	var owned: Dictionary = save.get("owned", {})
	var shards: Dictionary = save.get("shards", {})
	var key := str(hero.get("id", 0))
	var is_new := not owned.has(key)
	owned[key] = int(owned.get(key, 0)) + 1
	var shard_gain := 0 if is_new else _duplicate_shards(int(hero.get("rarity", 1)))
	if shard_gain > 0:
		shards[key] = int(shards.get(key, 0)) + shard_gain
	save["owned"] = owned
	save["shards"] = shards
	return {"hero": hero, "rolled_rarity": max(rarity, int(hero.get("rarity", 1))), "is_new": is_new, "shards": shard_gain}

func _show_hero_detail(hero_id: int) -> void:
	var hero := _hero_by_id(hero_id)
	_clear(str(hero.get("name", "角色")))
	_draw_hero_stage(hero, Vector2(706, 10), Vector2(520, 560))
	var key := str(hero.get("id", 0))
	var copies := int(save.get("owned", {}).get(key, 0))
	var shards := int(save.get("shards", {}).get(key, 0))
	var state := "已獲得" if copies > 0 else "未獲得"
	var detail := _label("%s\n持有: %d\n碎片: %d\n資源: %s\nSpine: %s" % [state, copies, shards, hero.get("artResource", ""), hero.get("spine", "")], 20)
	detail.position = Vector2(54, 108)
	detail.size = Vector2(560, 170)
	content.add_child(detail)
	_add_action_button("設為看板", Vector2(54, 340), func() -> void:
		save["selected_hero_id"] = hero_id
		_persist()
		_show_home()
	)
	_add_action_button("返回圖鑑", Vector2(200, 340), _show_gallery)
	_add_action_button("前往喚靈", Vector2(346, 340), _show_gacha)

func _show_player_info() -> void:
	_clear("玩家信息")
	var profile: Dictionary = save.get("profile", {})
	var settings: Dictionary = save.get("settings", {})
	var panel := _panel(Vector2(44, 44), Vector2(620, 360), Color(0.095, 0.078, 0.065, 0.94))
	content.add_child(panel)
	var info := _label("玩家資料\n名稱：%s\n等級：%d\n戰力：%d\n\n收集武將：%d\n累計喚靈：%d\n看板自動播放：%s" % [
		profile.get("name", "Player"),
		int(profile.get("level", 1)),
		_player_power(),
		save.get("owned", {}).size(),
		int(save.get("draw_count", 0)),
		"開" if bool(settings.get("wallpaper_auto_play", true)) else "關"
	], 21)
	info.position = Vector2(70, 70)
	info.size = Vector2(520, 230)
	content.add_child(info)
	_add_action_button("設定", Vector2(70, 330), _show_settings)
	_add_action_button("返回主界面", Vector2(216, 330), _show_home, Vector2(146, 44))

func _show_settings() -> void:
	_clear("設定")
	var settings: Dictionary = save.get("settings", {})
	var panel := _panel(Vector2(44, 44), Vector2(700, 370), Color(0.095, 0.078, 0.065, 0.94))
	content.add_child(panel)
	var title := _label("SystemSettingView MVP", 30)
	title.position = Vector2(70, 70)
	title.size = Vector2(440, 44)
	content.add_child(title)
	_add_toggle_button("看板自動播放", "wallpaper_auto_play", Vector2(70, 140), bool(settings.get("wallpaper_auto_play", true)))
	_add_toggle_button("音樂", "music", Vector2(70, 202), bool(settings.get("music", true)))
	_add_toggle_button("音效", "effects", Vector2(70, 264), bool(settings.get("effects", true)))
	_add_action_button("玩家信息", Vector2(70, 340), _show_player_info)
	_add_action_button("返回主界面", Vector2(216, 340), _show_home, Vector2(146, 44))

func _show_shop() -> void:
	_clear("商店")
	var title := _label("資源補給", 34)
	title.position = Vector2(44, 44)
	title.size = Vector2(420, 52)
	content.add_child(title)
	var desc := _label("單機 MVP 暫定兌換規則：源石 %d = 喚靈券 %d。日常、郵件和章節任務也會產出喚靈資源。" % [int(shop.get("exchangeGemCost", 160)), int(shop.get("ticketAmount", 1))], 20)
	desc.position = Vector2(44, 112)
	desc.size = Vector2(760, 72)
	content.add_child(desc)
	_add_action_button("兌換 1 張", Vector2(44, 210), func() -> void: _buy_tickets(1))
	_add_action_button("兌換 10 張", Vector2(190, 210), func() -> void: _buy_tickets(10))
	_add_action_button("每日補給", Vector2(336, 210), _show_daily)
	_add_action_button("郵件", Vector2(482, 210), _show_mail)
	_add_action_button("任務", Vector2(628, 210), _show_tasks)
	_add_action_button("前往喚靈", Vector2(44, 284), _show_gacha)

func _show_daily() -> void:
	_clear("每日補給")
	var today := Time.get_date_string_from_system()
	var claimed := str(save.get("daily_claimed_date", "")) == today
	var reward_tickets := int(daily.get("tickets", 3))
	var reward_gems := int(daily.get("gems", 480))
	var title := _label(str(daily.get("name", "每日補給")), 34)
	title.position = Vector2(44, 44)
	title.size = Vector2(420, 52)
	content.add_child(title)
	var text := "%s\n喚靈券 x%d\n源石 x%d\n\n狀態：%s" % [daily.get("desc", "今日補給"), reward_tickets, reward_gems, "已領取" if claimed else "可領取"]
	var label := _label(text, 22)
	label.position = Vector2(44, 126)
	label.size = Vector2(520, 180)
	content.add_child(label)
	if not claimed:
		_add_action_button("領取", Vector2(44, 330), func() -> void:
			save["daily_claimed_date"] = today
			_grant_reward(reward_tickets, reward_gems)
			_show_daily()
		)
	_add_action_button("返回商店", Vector2(190, 330), _show_shop, Vector2(146, 44))
	_add_action_button("前往喚靈", Vector2(350, 330), _show_gacha, Vector2(146, 44))

func _show_mail() -> void:
	_clear("郵件")
	var title := _label("郵件", 34)
	title.position = Vector2(44, 32)
	title.size = Vector2(420, 52)
	content.add_child(title)
	var claimed: Dictionary = save.get("claimed_mail", {})
	var y := 104.0
	for mail in mails:
		var mail_id := str(mail.get("id", ""))
		var is_claimed := bool(claimed.get(mail_id, false))
		var panel := _panel(Vector2(44, y), Vector2(760, 92), Color(0.095, 0.078, 0.065, 0.9))
		content.add_child(panel)
		var row := _label("%s\n%s\n獎勵：喚靈券 x%d  源石 x%d   %s" % [mail.get("title", ""), mail.get("body", ""), int(mail.get("tickets", 0)), int(mail.get("gems", 0)), "已領取" if is_claimed else "可領取"], 17)
		row.position = Vector2(60, y + 8)
		row.size = Vector2(600, 78)
		content.add_child(row)
		if not is_claimed:
			_add_action_button("領取", Vector2(670, y + 24), func(id := mail_id, tickets := int(mail.get("tickets", 0)), gems := int(mail.get("gems", 0))) -> void:
				var mail_claimed: Dictionary = save.get("claimed_mail", {})
				mail_claimed[id] = true
				save["claimed_mail"] = mail_claimed
				_grant_reward(tickets, gems)
				_show_mail()
			, Vector2(104, 42))
		y += 108
	_add_action_button("返回主界面", Vector2(44, 548), _show_home, Vector2(146, 44))
	_add_action_button("前往喚靈", Vector2(204, 548), _show_gacha, Vector2(146, 44))

func _show_tasks() -> void:
	_clear("任務")
	var title := _label("章節任務", 34)
	title.position = Vector2(44, 32)
	title.size = Vector2(420, 52)
	content.add_child(title)
	var claimed: Dictionary = save.get("claimed_tasks", {})
	var y := 104.0
	for task in tasks:
		var task_id := str(task.get("id", ""))
		var progress := _task_progress(task_id)
		var target := int(task.get("target", 1))
		var done := progress >= target
		var is_claimed := bool(claimed.get(task_id, false))
		var panel := _panel(Vector2(44, y), Vector2(820, 86), Color(0.095, 0.078, 0.065, 0.9))
		content.add_child(panel)
		var row := _label("%s\n%s  %d/%d\n獎勵：喚靈券 x%d  源石 x%d" % [task.get("name", ""), task.get("desc", ""), progress, target, int(task.get("tickets", 0)), int(task.get("gems", 0))], 17)
		row.position = Vector2(60, y + 8)
		row.size = Vector2(630, 72)
		content.add_child(row)
		if is_claimed:
			var claimed_label := _label("已領取", 18, HORIZONTAL_ALIGNMENT_CENTER)
			claimed_label.position = Vector2(724, y + 22)
			claimed_label.size = Vector2(110, 42)
			content.add_child(claimed_label)
		elif done:
			_add_action_button("領取", Vector2(724, y + 22), func(id := task_id, tickets := int(task.get("tickets", 0)), gems := int(task.get("gems", 0))) -> void:
				var task_claimed: Dictionary = save.get("claimed_tasks", {})
				task_claimed[id] = true
				save["claimed_tasks"] = task_claimed
				_grant_reward(tickets, gems)
				_show_tasks()
			, Vector2(110, 42))
		else:
			var todo := _label("進行中", 18, HORIZONTAL_ALIGNMENT_CENTER)
			todo.position = Vector2(724, y + 22)
			todo.size = Vector2(110, 42)
			content.add_child(todo)
		y += 102
	_add_action_button("返回主界面", Vector2(44, 548), _show_home, Vector2(146, 44))
	_add_action_button("前往喚靈", Vector2(204, 548), _show_gacha, Vector2(146, 44))

func _buy_tickets(count: int) -> void:
	var cost := count * int(shop.get("exchangeGemCost", 160))
	if int(save.get("gems", 0)) < cost:
		return
	save["gems"] = int(save.get("gems", 0)) - cost
	save["tickets"] = int(save.get("tickets", 0)) + count * int(shop.get("ticketAmount", 1))
	_persist()
	_show_shop()

func _duplicate_shards(rarity: int) -> int:
	if rarity >= 4:
		return 25
	if rarity == 3:
		return 8
	return 3

func _draw_wallpaper_stage(hero: Dictionary) -> void:
	var sky := _panel(Vector2(0, 0), Vector2(1280, 646), Color(0.11, 0.095, 0.085))
	content.add_child(sky)
	var floor := _panel(Vector2(0, 458), Vector2(1280, 188), Color(0.065, 0.055, 0.052))
	content.add_child(floor)
	var wallpaper := _panel(Vector2(254, 20), Vector2(772, 562), Color(0.16, 0.125, 0.105, 0.48))
	content.add_child(wallpaper)
	_draw_hero_stage(hero, Vector2(610, -6), Vector2(500, 580))

func _draw_home_side_entries() -> void:
	_add_action_button("戰役", Vector2(1064, 66), _show_home, Vector2(142, 44))
	_add_action_button("喚靈", Vector2(1064, 124), _show_gacha, Vector2(142, 44))
	_add_action_button("競技", Vector2(1064, 182), _show_home, Vector2(142, 44))
	_add_action_button("祈願", Vector2(1064, 240), _open_prayer_pool, Vector2(142, 44))
	_add_action_button("福利", Vector2(1064, 298), _show_daily, Vector2(142, 44))
	_add_action_button("收穫", Vector2(1064, 356), _show_shop, Vector2(142, 44))
	_add_action_button("郵件 %d" % _unclaimed_mail_count(), Vector2(1064, 414), _show_mail, Vector2(142, 44))
	_add_action_button("設定", Vector2(1064, 472), _show_settings, Vector2(142, 44))

func _open_prayer_pool() -> void:
	save["active_pool_id"] = "prayer"
	_persist()
	_show_gacha()

func _draw_home_bottom_bar() -> void:
	var bottom := _panel(Vector2(0, 552), Vector2(1280, 94), Color(0.055, 0.047, 0.043, 0.94))
	content.add_child(bottom)
	var buttons := [
		["約會", _show_home],
		["武將", _show_gallery],
		["背包", _show_shop],
		["寵物", _show_home],
		["養成", _show_gallery],
		["任務", _show_tasks],
		["軍團", _show_home]
	]
	var x := 260.0
	for item in buttons:
		_add_action_button(str(item[0]), Vector2(x, 574), item[1], Vector2(92, 44))
		x += 104

func _draw_home_status() -> void:
	var panel := _panel(Vector2(24, 92), Vector2(286, 156), Color(0.09, 0.075, 0.065, 0.78))
	content.add_child(panel)
	var next_task := _next_task_text()
	var info := _label("章節任務\n%s\n已收集 %d  抽卡 %d\n高級保底 %d/60" % [next_task, save.get("owned", {}).size(), int(save.get("draw_count", 0)), _pity("advanced")], 18)
	info.position = Vector2(44, 110)
	info.size = Vector2(246, 118)
	content.add_child(info)
	_add_action_button("玩家", Vector2(44, 274), _show_player_info, Vector2(112, 42))
	_add_action_button("變更", Vector2(168, 274), _show_gallery, Vector2(112, 42))

func _draw_result_stage(result: Dictionary) -> void:
	var hero: Dictionary = result.get("hero", _hero_by_id(240065))
	var rarity := int(result.get("rolled_rarity", hero.get("rarity", 1)))
	var bg_color := Color(0.33, 0.25, 0.13) if rarity >= 4 else Color(0.13, 0.11, 0.17)
	content.add_child(_panel(Vector2(0, 0), Vector2(1280, 646), bg_color))
	var title := _label("喚靈結果", 40, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(400, 24)
	title.size = Vector2(480, 56)
	content.add_child(title)
	var name := _label("%s  %s" % [_stars(rarity), hero.get("name", "")], 34, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = Vector2(382, 352)
	name.size = Vector2(520, 56)
	content.add_child(name)
	_draw_hero_stage(hero, Vector2(420, 70), Vector2(440, 340), false)

func _draw_hero_stage(hero: Dictionary, pos := Vector2(470, 0), size := Vector2(500, 560), show_text := true) -> void:
	if show_text:
		var name_label := _label(str(hero.get("name", "")), 42)
		name_label.position = Vector2(54, 28)
		name_label.size = Vector2(420, 58)
		content.add_child(name_label)

		var meta := _label("%s / %s" % [_stars(int(hero.get("rarity", 1))), hero.get("spine", "")], 20)
		meta.position = Vector2(54, 92)
		meta.size = Vector2(520, 40)
		content.add_child(meta)

	var texture := TextureRect.new()
	texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.position = pos
	texture.size = size
	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		texture.texture = load("res://%s.png" % resource_path.replace("Art/Spine", "assets/spine"))
	content.add_child(texture)

func _show_gacha_rate() -> void:
	_clear("概率")
	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	var text := "卡池：%s\n\nMVP 暫定概率：\n%s 2%%，保底 %d 抽\n%s 14%%\n其餘為普通角色\n\nUP 權重：高稀有命中後 55%% 從 UP 列表取角色" % [pool.get("name", ""), _stars(4), int(pool.get("pityLimit", 60)), _stars(3)]
	var label := _label(text, 22)
	label.position = Vector2(54, 60)
	label.size = Vector2(760, 260)
	content.add_child(label)
	_add_action_button("返回卡池", Vector2(54, 360), _show_gacha)

func _hero_by_id(id: int) -> Dictionary:
	for hero in heroes:
		if int(hero.get("id", 0)) == id:
			return hero
	return heroes[0] if not heroes.is_empty() else {}

func _pool_by_id(id: String) -> Dictionary:
	for pool in pools:
		if str(pool.get("id", "")) == id:
			return pool
	return pools[0] if not pools.is_empty() else {}

func _pity(pool_id: String) -> int:
	return int(save.get("pity", {}).get(pool_id, 0))

func _set_pity(pool_id: String, value: int) -> void:
	var pity: Dictionary = save.get("pity", {})
	pity[pool_id] = value
	save["pity"] = pity

func _grant_reward(tickets: int, gems: int) -> void:
	save["tickets"] = int(save.get("tickets", 0)) + tickets
	save["gems"] = int(save.get("gems", 0)) + gems
	_persist()

func _task_progress(task_id: String) -> int:
	var metric := ""
	for task in tasks:
		if str(task.get("id", "")) == task_id:
			metric = str(task.get("metric", ""))
			break
	if metric == "draw_count":
		return int(save.get("draw_count", 0))
	if metric == "owned_count":
		return save.get("owned", {}).size()
	return 0

func _next_task_text() -> String:
	var claimed: Dictionary = save.get("claimed_tasks", {})
	for task in tasks:
		var task_id := str(task.get("id", ""))
		if bool(claimed.get(task_id, false)):
			continue
		return "%s %d/%d" % [task.get("name", ""), _task_progress(task_id), int(task.get("target", 1))]
	return "章節任務已完成"

func _unclaimed_mail_count() -> int:
	var claimed: Dictionary = save.get("claimed_mail", {})
	var count := 0
	for mail in mails:
		if not bool(claimed.get(str(mail.get("id", "")), false)):
			count += 1
	return count

func _profile_summary() -> String:
	var profile: Dictionary = save.get("profile", {})
	return "Lv.%d  %s\n戰力 %d" % [int(profile.get("level", 1)), profile.get("name", "Player"), _player_power()]

func _player_power() -> int:
	var profile: Dictionary = save.get("profile", {})
	return int(profile.get("base_power", 0)) + save.get("owned", {}).size() * 24000 + int(save.get("draw_count", 0)) * 120

func _add_toggle_button(label: String, key: String, pos: Vector2, value: bool) -> void:
	_add_action_button("%s：%s" % [label, "開" if value else "關"], pos, func() -> void:
		var settings: Dictionary = save.get("settings", {})
		settings[key] = not bool(settings.get(key, true))
		save["settings"] = settings
		_persist()
		_show_settings()
	, Vector2(220, 44))

func _label(text: String, size: int, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = Color(0.96, 0.91, 0.84)
	return label

func _panel(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = pos
	panel.size = size
	panel.color = color
	return panel

func _draw_progress_bar(pos: Vector2, size: Vector2, ratio: float) -> void:
	var bg := _panel(pos, size, Color(0.025, 0.022, 0.02))
	content.add_child(bg)
	var fill := _panel(pos + Vector2(2, 2), Vector2((size.x - 4) * clamp(ratio, 0.0, 1.0), size.y - 4), Color(0.82, 0.62, 0.28))
	content.add_child(fill)

func _add_action_button(text: String, pos: Vector2, callback: Callable, size := Vector2(132, 44)) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = size
	button.pressed.connect(callback)
	content.add_child(button)

func _stars(count: int) -> String:
	return "★".repeat(clamp(count, 1, 5))
