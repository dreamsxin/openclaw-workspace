# UTF-8 source. HeroRecruitView / LotteryDrawFinishView MVP reconstruction.
extends RefCounted

const UI_RECRUIT_BG := "res://assets/ui/lottery/lottery_img_60.png"
const UI_RECRUIT_LIGHT_L := "res://assets/ui/lottery/lottery_img_60_l.png"
const UI_RECRUIT_LIGHT_R := "res://assets/ui/lottery/lottery_img_60_r.png"
const UI_RECRUIT_FX_L := "res://assets/ui/lottery/fx_lottery_img_60_l.png"
const UI_RECRUIT_FX_R := "res://assets/ui/lottery/fx_lottery_img_60_r.png"
const UI_RECRUIT_DISC := "res://assets/ui/lottery/lottery_img_62.png"
const UI_RECRUIT_GROUP := "res://assets/ui/lottery/lottery_img_01.png"
const UI_RESULT_CARD_BG := "res://assets/ui/lottery/lottery_img_55.png"
const UI_RESULT_CARD_BG_PRAYER := "res://assets/ui/lottery/lottery_img_57.png"
const UI_RESULT_SIDE_A := "res://assets/ui/lottery/lottery_img_11.png"
const UI_RESULT_SIDE_B := "res://assets/ui/lottery/lottery_img_12.png"
const UI_RESULT_SIDE_C := "res://assets/ui/lottery/lottery_img_13.png"
const UI_RESULT_SIDE_D := "res://assets/ui/lottery/lottery_img_14.png"
const UI_TICKET_ICON := "res://assets/ui/item/draw_03.png"

var app

func _init(app_ref) -> void:
	app = app_ref

func show_draw_animation(count: int) -> void:
	var pool = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var cost = count * int(pool.get("ticketCost", 1))
	app.current_view = "draw_animation"
	app._set_chrome_visible(false)
	app._clear("喚灵演出")
	draw_recruit_backdrop(3)
	app._draw_image(UI_RECRUIT_DISC, Vector2(454, 70), Vector2(372, 372), false, Color(1, 1, 1, 0.84))
	app._draw_image(UI_TICKET_ICON, Vector2(590, 292), Vector2(76, 88), false, Color(1, 1, 1, 0.96))

	var title = app._label("喚灵仪式", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(390, 92)
	title.size = Vector2(500, 62)
	app._view_container().add_child(title)

	var info = app._label("%s\n本次喚灵 %d 次  消耗 %d / %d\n保底 %d / %d" % [
		pool.get("name", "喚灵"),
		count,
		cost,
		int(app.save.get("tickets", 0)),
		app._pity(pool.get("id", "advanced")),
		int(pool.get("pityLimit", 60))
	], 21, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = Vector2(342, 448)
	info.size = Vector2(596, 96)
	info.modulate = Color(0.95, 0.88, 0.72)
	app._view_container().add_child(info)

	if int(app.save.get("tickets", 0)) < cost:
		var warning = app._label("喚灵券不足", 28, HORIZONTAL_ALIGNMENT_CENTER)
		warning.position = Vector2(430, 552)
		warning.size = Vector2(420, 42)
		app._view_container().add_child(warning)
		app._add_action_button("返回卡池", Vector2(574, 620), func() -> void: app._pop_view(), Vector2(132, 46))
		return

	app._add_action_button("开始喚灵", Vector2(438, 620), func() -> void: show_recruit_reveal(count), Vector2(132, 46))
	app._add_action_button("跳过演出", Vector2(574, 620), func() -> void: draw_and_show(count), Vector2(132, 46))
	app._add_action_button("返回卡池", Vector2(710, 620), func() -> void: app._pop_view(), Vector2(132, 46))

func show_recruit_reveal(count: int) -> void:
	var results = app._perform_draw(count)
	if results.is_empty():
		show_empty_ticket_warning()
		return
	var best = best_result(results)
	var hero = best.get("hero", app._hero_by_id(240065))
	var rarity = int(best.get("rolled_rarity", hero.get("rarity", 1)))

	app.current_view = "hero_recruit"
	app._set_chrome_visible(false)
	app._clear("招募演出")
	draw_recruit_backdrop(rarity)

	draw_spine_png_variant(hero, "_silhouette", Vector2(618, 36), Vector2(520, 620), Color(0, 0, 0, 0.72))
	app._draw_hero_stage(hero, Vector2(596, 28), Vector2(560, 636), false)
	draw_quality_frame(rarity)

	var new_tag = app._label("NEW" if best.get("is_new", false) else "碎片 +%d" % int(best.get("shards", 0)), 28, HORIZONTAL_ALIGNMENT_CENTER)
	new_tag.position = Vector2(130, 202)
	new_tag.size = Vector2(220, 44)
	new_tag.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(new_tag)

	var name = app._label(str(hero.get("name", "")), 44, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = Vector2(74, 252)
	name.size = Vector2(360, 58)
	app._view_container().add_child(name)

	var star = app._label(app._stars(rarity), 26, HORIZONTAL_ALIGNMENT_CENTER)
	star.position = Vector2(82, 314)
	star.size = Vector2(344, 40)
	star.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(star)

	var hint = app._label("点击继续查看本次结果", 18, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(72, 382)
	hint.size = Vector2(360, 34)
	hint.modulate = Color(0.92, 0.84, 0.68)
	app._view_container().add_child(hint)

	app._add_action_button("查看结果", Vector2(170, 620), func() -> void: show_results(results, count), Vector2(142, 46))
	app._add_action_button("返回卡池", Vector2(324, 620), func() -> void: app._pop_view(), Vector2(132, 46))
	app._add_action_button("跳过", Vector2(1088, 34), func() -> void: show_results(results, count), Vector2(102, 40))

func draw_and_show(count: int) -> void:
	var results = app._perform_draw(count)
	show_results(results, count)

func show_results(results: Array, count: int) -> void:
	app.current_view = "draw_result"
	app._set_chrome_visible(false)
	app._clear("喚灵结果")
	if results.is_empty():
		show_empty_ticket_warning()
		return
	draw_finish_backdrop(results)
	draw_result_grid(results)
	app._add_action_button("再抽一次", Vector2(794, 656), func() -> void: show_draw_animation(count), Vector2(132, 42))
	app._add_action_button("返回卡池", Vector2(944, 656), func() -> void: app._pop_view(), Vector2(132, 42))
	app._add_action_button("图鉴", Vector2(1094, 656), app._show_gallery, Vector2(92, 42))

func show_empty_ticket_warning() -> void:
	app._set_chrome_visible(false)
	app._clear("喚灵结果")
	draw_recruit_backdrop(2)
	var warning = app._label("喚灵券不足", 34, HORIZONTAL_ALIGNMENT_CENTER)
	warning.position = Vector2(390, 260)
	warning.size = Vector2(500, 58)
	app._view_container().add_child(warning)
	app._add_action_button("返回卡池", Vector2(574, 384), func() -> void: app._pop_view(), Vector2(132, 46))

func draw_recruit_backdrop(rarity: int) -> void:
	app._draw_image(UI_RECRUIT_BG, Vector2(-195, -6), Vector2(1670, 732), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.010, 0.014, 0.34)))
	app._draw_image(UI_RECRUIT_LIGHT_L, Vector2(-48, 148), Vector2(690, 430), true, frame_color(rarity, 0.56))
	app._draw_image(UI_RECRUIT_LIGHT_R, Vector2(638, 148), Vector2(690, 430), true, frame_color(rarity, 0.56))
	app._draw_image(UI_RECRUIT_FX_L, Vector2(-18, 0), Vector2(640, 720), true, Color(1, 1, 1, 0.30))
	app._draw_image(UI_RECRUIT_FX_R, Vector2(658, 0), Vector2(640, 720), true, Color(1, 1, 1, 0.30))
	app._view_container().add_child(app._panel(Vector2(52, 168), Vector2(420, 286), Color(0.018, 0.014, 0.016, 0.54)))

func draw_quality_frame(rarity: int) -> void:
	var color = frame_color(rarity, 0.36)
	app._view_container().add_child(app._panel(Vector2(0, 450), Vector2(1280, 150), color))
	app._draw_image(UI_RESULT_SIDE_A, Vector2(0, 452), Vector2(190, 88), false, frame_color(rarity, 0.96))
	app._draw_image(UI_RESULT_SIDE_B, Vector2(1088, 452), Vector2(190, 88), false, frame_color(rarity, 0.96))
	app._draw_image(UI_RESULT_SIDE_C, Vector2(218, 470), Vector2(148, 80), false, frame_color(rarity, 0.72))
	app._draw_image(UI_RESULT_SIDE_D, Vector2(914, 470), Vector2(148, 80), false, frame_color(rarity, 0.72))

func draw_finish_backdrop(results: Array) -> void:
	var best = best_result(results)
	var hero = best.get("hero", app._hero_by_id(240065))
	var rarity = int(best.get("rolled_rarity", hero.get("rarity", 1)))
	app._draw_image(UI_RECRUIT_BG, Vector2(-195, -6), Vector2(1670, 732), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.014, 0.012, 0.014, 0.48)))
	app._draw_image(UI_RECRUIT_DISC, Vector2(414, -110), Vector2(452, 452), false, frame_color(rarity, 0.36))
	var title = app._label("喚灵结果", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(420, 46)
	title.size = Vector2(440, 60)
	app._view_container().add_child(title)
	var top = app._label("%s  %s" % [app._stars(rarity), hero.get("name", "")], 24, HORIZONTAL_ALIGNMENT_CENTER)
	top.position = Vector2(390, 108)
	top.size = Vector2(500, 44)
	top.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(top)

func draw_result_grid(results: Array) -> void:
	var columns = 5 if results.size() > 1 else 1
	var card_size = Vector2(176, 188) if results.size() > 1 else Vector2(300, 330)
	var gap = Vector2(22, 22)
	var total_w = columns * card_size.x + (columns - 1) * gap.x
	var start_x = (1280.0 - total_w) * 0.5
	var start_y = 166.0 if results.size() > 1 else 178.0
	for i in range(results.size()):
		var result = results[i]
		var hero = result.get("hero", {})
		var rarity = int(result.get("rolled_rarity", hero.get("rarity", 1)))
		var col = i % columns
		var row = i / columns
		var pos = Vector2(start_x + col * (card_size.x + gap.x), start_y + row * (card_size.y + gap.y))
		draw_result_card(result, pos, card_size, rarity)

func draw_result_card(result: Dictionary, pos: Vector2, card_size: Vector2, rarity: int) -> void:
	var hero = result.get("hero", {})
	app._view_container().add_child(app._panel(pos, card_size, Color(0.02, 0.016, 0.015, 0.68)))
	app._view_container().add_child(app._panel(pos + Vector2(4, 4), card_size - Vector2(8, 8), frame_color(rarity, 0.20)))
	app._draw_image(UI_RESULT_CARD_BG if rarity < 4 else UI_RESULT_CARD_BG_PRAYER, pos + Vector2(-4, -4), card_size + Vector2(8, 8), false, Color(1, 1, 1, 0.72))
	draw_card_portrait(hero, pos + Vector2(20, 18), Vector2(card_size.x - 40, card_size.y - 86))

	var name = app._label(str(hero.get("name", "")), 19, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = pos + Vector2(10, card_size.y - 68)
	name.size = Vector2(card_size.x - 20, 28)
	app._view_container().add_child(name)

	var detail = app._label("%s   %s" % [app._stars(rarity), "NEW" if result.get("is_new", false) else "碎片 +%d" % int(result.get("shards", 0))], 15, HORIZONTAL_ALIGNMENT_CENTER)
	detail.position = pos + Vector2(8, card_size.y - 38)
	detail.size = Vector2(card_size.x - 16, 24)
	detail.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(detail)

	var button = Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = card_size
	button.pressed.connect(func() -> void:
		app._show_hero_detail(int(hero.get("id", 0)))
	)
	app._view_container().add_child(button)

func draw_spine_png_variant(hero: Dictionary, suffix: String, pos: Vector2, draw_size: Vector2, tint: Color) -> TextureRect:
	var resource_path = str(hero.get("artResource", ""))
	if resource_path.is_empty():
		return null
	var spine_base_path = "res://%s" % resource_path.replace("Art/Spine", "assets/spine")
	var path = "%s%s.png" % [spine_base_path, suffix]
	var texture = app._load_png_source_texture(path)
	if texture == null:
		return null
	var rect = TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.modulate = tint
	app._view_container().add_child(rect)
	return rect

func draw_card_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2) -> void:
	var texture = app._hero_portrait_texture(hero)
	if texture == null:
		return
	var rect = TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.clip_contents = true
	app._view_container().add_child(rect)

func best_result(results: Array) -> Dictionary:
	var best = results[0] if not results.is_empty() else {}
	for result in results:
		var hero = result.get("hero", {})
		var best_hero = best.get("hero", {})
		var rarity = int(result.get("rolled_rarity", hero.get("rarity", 1)))
		var best_rarity = int(best.get("rolled_rarity", best_hero.get("rarity", 1)))
		if rarity > best_rarity:
			best = result
	return best

func frame_color(rarity: int, alpha: float) -> Color:
	if rarity >= 4:
		return Color(1.0, 0.62, 0.16, alpha)
	if rarity == 3:
		return Color(0.72, 0.38, 1.0, alpha)
	return Color(0.30, 0.66, 1.0, alpha)
