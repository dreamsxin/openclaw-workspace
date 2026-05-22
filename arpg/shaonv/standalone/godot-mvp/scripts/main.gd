extends Control

const SAVE_PATH := "user://shaonv_godot_mvp_save.json"
const HERO_DATA_PATH := "res://data/heroes_mvp.json"
const POOL_DATA_PATH := "res://data/gacha_pools_mvp.json"

var heroes: Array = []
var pools: Array = []
var save := {
	"tickets": 120,
	"gems": 16800,
	"owned": {},
	"shards": {},
	"pity": {},
	"history": [],
	"draw_count": 0,
	"selected_hero_id": 240065,
	"active_pool_id": "advanced"
}

var rng := RandomNumberGenerator.new()
var content: Control
var title_label: Label
var wallet_label: Label

func _ready() -> void:
	rng.randomize()
	heroes = _read_json(HERO_DATA_PATH).get("heroes", [])
	pools = _read_json(POOL_DATA_PATH).get("pools", [])
	_load_save()
	_build_root()
	_show_home()

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
	bg.color = Color(0.08, 0.075, 0.07)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var nav := ColorRect.new()
	nav.color = Color(0.13, 0.12, 0.11)
	nav.anchor_left = 0
	nav.anchor_top = 0
	nav.anchor_right = 0
	nav.anchor_bottom = 0
	nav.custom_minimum_size = Vector2(220, 0)
	nav.size = Vector2(220, 720)
	add_child(nav)

	var brand := _label("單機版\n喚靈測試", 22, HORIZONTAL_ALIGNMENT_LEFT)
	brand.position = Vector2(24, 24)
	brand.size = Vector2(170, 56)
	nav.add_child(brand)

	_add_nav_button(nav, "主界面", 96, _show_home)
	_add_nav_button(nav, "抽卡", 150, _show_gacha)
	_add_nav_button(nav, "圖鑑", 204, _show_gallery)
	_add_nav_button(nav, "記錄", 258, _show_history)
	_add_nav_button(nav, "商店", 312, _show_shop)

	title_label = _label("主界面", 32, HORIZONTAL_ALIGNMENT_LEFT)
	title_label.position = Vector2(244, 24)
	title_label.size = Vector2(480, 54)
	add_child(title_label)

	wallet_label = _label("", 18, HORIZONTAL_ALIGNMENT_RIGHT)
	wallet_label.position = Vector2(860, 34)
	wallet_label.size = Vector2(380, 36)
	add_child(wallet_label)

	content = Control.new()
	content.position = Vector2(244, 92)
	content.size = Vector2(1012, 604)
	add_child(content)

func _add_nav_button(parent: Control, text: String, y: float, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = Vector2(18, y)
	button.size = Vector2(174, 42)
	button.pressed.connect(callback)
	parent.add_child(button)

func _clear(title: String) -> void:
	title_label.text = title
	for child in content.get_children():
		child.queue_free()
	_refresh_wallet()

func _refresh_wallet() -> void:
	wallet_label.text = "喚靈券 %s   源石 %s" % [save.get("tickets", 0), save.get("gems", 0)]

func _show_home() -> void:
	_clear("主界面")
	var hero := _hero_by_id(int(save.get("selected_hero_id", 240065)))
	_draw_hero_stage(hero)
	var info := _label("已收集 %d  |  抽卡 %d 次  |  高級保底 %d/60" % [save.get("owned", {}).size(), int(save.get("draw_count", 0)), _pity("advanced")], 20)
	info.position = Vector2(24, 138)
	info.size = Vector2(760, 40)
	content.add_child(info)
	_add_action_button("前往喚靈", Vector2(24, 206), _show_gacha)
	_add_action_button("查看圖鑑", Vector2(170, 206), _show_gallery)
	_add_action_button("補充資源", Vector2(316, 206), _show_shop)

func _show_gacha() -> void:
	_clear("抽卡")
	var x := 24.0
	for pool in pools:
		var pool_id := str(pool.get("id", "advanced"))
		var button := Button.new()
		button.text = "%s%s" % ["✓ " if pool_id == str(save.get("active_pool_id", "advanced")) else "", str(pool.get("name", "Pool"))]
		button.position = Vector2(x, 0)
		button.size = Vector2(132, 42)
		button.pressed.connect(func() -> void:
			save["active_pool_id"] = pool_id
			_persist()
			_show_gacha()
		)
		content.add_child(button)
		x += 144

	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	var title := _label(str(pool.get("name", "高級喚靈")), 36)
	title.position = Vector2(24, 92)
	title.size = Vector2(500, 48)
	content.add_child(title)

	var featured_names := []
	for id in pool.get("featuredHeroIds", []):
		featured_names.append(_hero_by_id(int(id)).get("name", str(id)))
	var detail := _label("UP: %s\n保底: %d/%d\n消耗: 喚靈券 x%d" % [" / ".join(featured_names), _pity(pool.get("id", "advanced")), int(pool.get("pityLimit", 60)), int(pool.get("ticketCost", 1))], 20)
	detail.position = Vector2(24, 154)
	detail.size = Vector2(840, 108)
	content.add_child(detail)
	_add_action_button("喚靈 1 次", Vector2(24, 270), func() -> void: _draw_and_show(1))
	_add_action_button("喚靈 10 次", Vector2(170, 270), func() -> void: _draw_and_show(10))

func _draw_and_show(count: int) -> void:
	var results := _perform_draw(count)
	_clear("結果")
	if results.is_empty():
		var warning := _label("喚靈券不足", 30)
		warning.position = Vector2(24, 32)
		content.add_child(warning)
		_add_action_button("返回", Vector2(24, 104), _show_gacha)
		return
	_draw_hero_stage(results[0].get("hero", _hero_by_id(240065)))
	var x := 24.0
	var y := 142.0
	for result in results:
		var hero: Dictionary = result.get("hero", {})
		var hero_id := int(hero.get("id", 0))
		var card := Button.new()
		card.text = "%s\n%s\n%s" % [_stars(int(result.get("rolled_rarity", 1))), hero.get("name", ""), "NEW" if result.get("is_new", false) else "碎片 +%d" % int(result.get("shards", 0))]
		card.position = Vector2(x, y)
		card.size = Vector2(142, 88)
		card.pressed.connect(func() -> void:
			_show_hero_detail(hero_id)
		)
		content.add_child(card)
		x += 154
		if x > 780:
			x = 24
			y += 100
	_add_action_button("再抽一次", Vector2(24, 486), func() -> void: _draw_and_show(count))
	_add_action_button("返回卡池", Vector2(170, 486), _show_gacha)
	_add_action_button("查看圖鑑", Vector2(316, 486), _show_gallery)

func _show_gallery() -> void:
	_clear("圖鑑")
	var x := 0.0
	var y := 0.0
	for hero in heroes:
		var button := Button.new()
		var hero_id := int(hero.get("id", 0))
		var copies := int(save.get("owned", {}).get(str(hero_id), 0))
		var shards := int(save.get("shards", {}).get(str(hero_id), 0))
		button.text = "%s\n%s x%d  碎%d" % [hero.get("name", "Unknown") if copies > 0 else "未獲得", _stars(int(hero.get("rarity", 1))), copies, shards]
		button.position = Vector2(x, y)
		button.size = Vector2(150, 84)
		button.pressed.connect(func() -> void:
			_show_hero_detail(hero_id)
		)
		content.add_child(button)
		x += 164
		if x > 820:
			x = 0
			y += 96

func _show_history() -> void:
	_clear("記錄")
	var lines := []
	for row in save.get("history", []):
		lines.append("%s %s\n%s" % [row.get("time", ""), row.get("pool_name", ""), row.get("result_text", "")])
	var label := _label("\n\n".join(lines) if not lines.is_empty() else "暫無抽卡記錄", 18)
	label.position = Vector2(24, 24)
	label.size = Vector2(900, 440)
	content.add_child(label)
	_add_action_button("重置存檔", Vector2(24, 504), func() -> void:
		save = {
			"tickets": 120,
			"gems": 16800,
			"owned": {},
			"shards": {},
			"pity": {},
			"history": [],
			"draw_count": 0,
			"selected_hero_id": 240065,
			"active_pool_id": "advanced"
		}
		_persist()
		_show_home()
	)

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
	_draw_hero_stage(hero)
	var key := str(hero.get("id", 0))
	var copies := int(save.get("owned", {}).get(key, 0))
	var shards := int(save.get("shards", {}).get(key, 0))
	var state := "已獲得" if copies > 0 else "未獲得"
	var detail := _label("%s\n持有: %d\n碎片: %d\n資源: %s\nSpine: %s" % [state, copies, shards, hero.get("artResource", ""), hero.get("spine", "")], 20)
	detail.position = Vector2(24, 138)
	detail.size = Vector2(560, 170)
	content.add_child(detail)
	_add_action_button("設為看板", Vector2(24, 340), func() -> void:
		save["selected_hero_id"] = hero_id
		_persist()
		_show_home()
	)
	_add_action_button("返回圖鑑", Vector2(170, 340), _show_gallery)
	_add_action_button("前往喚靈", Vector2(316, 340), _show_gacha)

func _show_shop() -> void:
	_clear("商店")
	var title := _label("資源補給", 34)
	title.position = Vector2(24, 24)
	title.size = Vector2(420, 52)
	content.add_child(title)
	var desc := _label("單機 MVP 暫定兌換規則：源石 160 = 喚靈券 1。後續可替換為原遊戲商城/任務/郵件規則。", 20)
	desc.position = Vector2(24, 92)
	desc.size = Vector2(760, 72)
	content.add_child(desc)
	_add_action_button("兌換 1 張", Vector2(24, 190), func() -> void: _buy_tickets(1))
	_add_action_button("兌換 10 張", Vector2(170, 190), func() -> void: _buy_tickets(10))
	_add_action_button("測試補給", Vector2(316, 190), func() -> void:
		save["tickets"] = int(save.get("tickets", 0)) + 30
		save["gems"] = int(save.get("gems", 0)) + 4800
		_persist()
		_show_shop()
	)
	_add_action_button("前往喚靈", Vector2(24, 264), _show_gacha)

func _buy_tickets(count: int) -> void:
	var cost := count * 160
	if int(save.get("gems", 0)) < cost:
		return
	save["gems"] = int(save.get("gems", 0)) - cost
	save["tickets"] = int(save.get("tickets", 0)) + count
	_persist()
	_show_shop()

func _duplicate_shards(rarity: int) -> int:
	if rarity >= 4:
		return 25
	if rarity == 3:
		return 8
	return 3

func _draw_hero_stage(hero: Dictionary) -> void:
	var name_label := _label(str(hero.get("name", "")), 42)
	name_label.position = Vector2(24, 20)
	name_label.size = Vector2(420, 58)
	content.add_child(name_label)

	var meta := _label("%s / %s" % [_stars(int(hero.get("rarity", 1))), hero.get("spine", "")], 20)
	meta.position = Vector2(24, 84)
	meta.size = Vector2(520, 40)
	content.add_child(meta)

	var texture := TextureRect.new()
	texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.position = Vector2(470, 0)
	texture.size = Vector2(500, 560)
	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		texture.texture = load("res://%s.png" % resource_path.replace("Art/Spine", "assets/spine"))
	content.add_child(texture)

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

func _label(text: String, size: int, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = Color(0.96, 0.91, 0.84)
	return label

func _add_action_button(text: String, pos: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(132, 44)
	button.pressed.connect(callback)
	content.add_child(button)

func _stars(count: int) -> String:
	return "★".repeat(clamp(count, 1, 5))
