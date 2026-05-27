# UTF-8 source. HeroRecruitView / LotteryDrawFinishView MVP reconstruction.
extends RefCounted

const UI_RECRUIT_BG := "res://assets/ui/lottery/lottery_img_60.png"
const UI_RECRUIT_LIGHT_L := "res://assets/ui/lottery/lottery_img_60_l.png"
const UI_RECRUIT_LIGHT_R := "res://assets/ui/lottery/lottery_img_60_r.png"
const UI_RECRUIT_FX_L := "res://assets/ui/lottery/fx_lottery_img_60_l.png"
const UI_RECRUIT_FX_R := "res://assets/ui/lottery/fx_lottery_img_60_r.png"
const UI_RECRUIT_DISC := "res://assets/ui/lottery/lottery_img_62.png"
const UI_STAGE_DISC_A := "res://assets/ui/lottery/lottery_img_62a.png"
const UI_STAGE_DISC_B := "res://assets/ui/lottery/lottery_img_62b.png"
const UI_STAGE_DISC_C := "res://assets/ui/lottery/lottery_img_62c.png"
const UI_STAGE_DISC_F := "res://assets/ui/lottery/lottery_img_62f.png"
const UI_STAGE_DISC_I := "res://assets/ui/lottery/lottery_img_62i.png"
# Prayer / holy-relic stage assets (chest-themed, sourced from LotteryDraw atlas + BackGround/lottery_img_10)
const UI_PRAYER_STAGE_BG := "res://assets/ui/background/lottery_img_10.png"
const UI_PRAYER_DISC := "res://assets/ui/lottery/lottery_img_63.png"
const UI_PRAYER_DISC_A := "res://assets/ui/lottery/lottery_img_63a.png"
const UI_PRAYER_DISC_B := "res://assets/ui/lottery/lottery_img_63b.png"
const UI_PRAYER_DISC_C := "res://assets/ui/lottery/lottery_img_63c.png"
const UI_PRAYER_DISC_D := "res://assets/ui/lottery/lottery_img_63d.png"
const UI_PRAYER_DISC_E := "res://assets/ui/lottery/lottery_img_63e.png"
const UI_RECRUIT_GROUP := "res://assets/ui/lottery/lottery_img_01.png"
const UI_RESULT_CARD_BG := "res://assets/ui/lottery/lottery_img_55.png"
const UI_RESULT_CARD_BG_PRAYER := "res://assets/ui/lottery/lottery_img_57.png"
const UI_RESULT_SIDE_A := "res://assets/ui/lottery/lottery_img_11.png"
const UI_RESULT_SIDE_B := "res://assets/ui/lottery/lottery_img_12.png"
const UI_RESULT_SIDE_C := "res://assets/ui/lottery/lottery_img_13.png"
const UI_RESULT_SIDE_D := "res://assets/ui/lottery/lottery_img_14.png"
const UI_PRAYER_REWARD_BG := {
	2: "res://assets/ui/lottery/lottery_img_80.png",
	3: "res://assets/ui/lottery/lottery_img_83.png",
	4: "res://assets/ui/lottery/lottery_img_86.png",
	5: "res://assets/ui/lottery/lottery_img_89.png",
}
const UI_PRAYER_REWARD_MASK := {
	2: "res://assets/ui/lottery/lottery_img_81.png",
	3: "res://assets/ui/lottery/lottery_img_84.png",
	4: "res://assets/ui/lottery/lottery_img_87.png",
	5: "res://assets/ui/lottery/lottery_img_90.png",
}
const UI_PRAYER_REWARD_FRAME := {
	2: "res://assets/ui/lottery/lottery_img_82.png",
	3: "res://assets/ui/lottery/lottery_img_85.png",
	4: "res://assets/ui/lottery/lottery_img_88.png",
	5: "res://assets/ui/lottery/lottery_img_91.png",
}
const UI_PRAYER_REWARD_TAG := {
	2: "res://assets/ui/lottery/lottery_img_102.png",
	3: "res://assets/ui/lottery/lottery_img_103.png",
	4: "res://assets/ui/lottery/lottery_img_104.png",
	5: "res://assets/ui/lottery/lottery_img_105.png",
}
const UI_PRAYER_REWARD_RELIC_TAG := "res://assets/ui/lottery/lottery_img_107.png"
const UI_PRAYER_REWARD_RARE_SSR := "res://assets/ui/common/common_img_163.png"
const UI_PRAYER_REMNANT_SPINE_BAKED := "res://assets/spine/all_export/Other__yiqi/Other__yiqi.baked.json"
const UI_PRAYER_REMNANT_SPINE_FALLBACK := "res://assets/spine/all_export/Other__yiqi/yiqi.png"
const SPINE_BAKED_PREVIEW_CANVAS := preload("res://scripts/spine_baked_preview_canvas.gd")
const UI_TICKET_ICON := "res://assets/ui/item/draw_03.png"
const FX_CAPSULE_BLUE_GLOW := "res://assets/ui/effect/fx_capsule_open_blue/Tex_glow005.png"
const FX_CAPSULE_BLUE_RING := "res://assets/ui/effect/fx_capsule_open_blue/fx_047_tex_012.png"
const FX_CAPSULE_BLUE_STAR := "res://assets/ui/effect/fx_capsule_open_blue/tfx_star09.png"
const LOTTERY_STAGE_SCALE := Vector2(1280.0 / 1670.0, 720.0 / 750.0)
const RECRUIT_VIDEO_POS := Vector2(-195, -6)
const RECRUIT_VIDEO_SIZE := Vector2(1670, 732)

var app
var sequence_id := 0

func _init(app_ref) -> void:
	app = app_ref


func _stage_size(prefab_size: Vector2) -> Vector2:
	return Vector2(prefab_size.x * LOTTERY_STAGE_SCALE.x, prefab_size.y * LOTTERY_STAGE_SCALE.y)


func _stage_center_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((835.0 + center.x - size.x * 0.5) * LOTTERY_STAGE_SCALE.x, (375.0 - center.y - size.y * 0.5) * LOTTERY_STAGE_SCALE.y)

func show_draw_animation(count: int) -> void:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var cost := count * int(pool.get("ticketCost", 1))
	if int(app.save.get("tickets", 0)) < cost:
		show_empty_ticket_warning()
		return
	var results: Array = app._perform_draw(count)
	if results.is_empty():
		show_empty_ticket_warning()
		return
	var seq := _next_sequence()
	show_stage_view(results, count, seq)

func show_stage_view(results: Array, count: int, seq: int) -> void:
	app._play_sfx(app.AUDIO_SFX_UI_DRAW_ENTER, 0.78)
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var is_prayer := _is_prayer_pool(pool)
	var cost := count * int(pool.get("ticketCost", 1))
	var best := best_result(results)
	var hero: Dictionary = best.get("hero", app._hero_by_id(240065))
	var rarity := int(best.get("rolled_rarity", hero.get("rarity", 1)))
	app.current_view = "draw_stage"
	app._set_chrome_visible(false)
	app._clear("喚靈啟動")
	draw_stage_backdrop(rarity, is_prayer)
	var title: Label = app._label("喚靈儀式啟動", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(390, 48)
	title.size = Vector2(500, 62)
	app._view_container().add_child(title)

	var info: Label = app._label("%s\n本次喚靈 %d 次  已消耗 %d 張喚靈券\n保底進度 %d / %d" % [
		pool.get("name", "喚灵"),
		count,
		cost,
		app._pity(pool.get("id", "advanced")),
		int(pool.get("pityLimit", 60))
	], 21, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = Vector2(342, 546)
	info.size = Vector2(596, 90)
	info.modulate = Color(0.95, 0.88, 0.72)
	app._view_container().add_child(info)

	draw_stage_orbits(results, rarity, is_prayer)
	app._add_action_button("快速啟動", Vector2(438, 644), func() -> void:
		show_stage_color(results, count, seq)
	, Vector2(132, 46))
	app._add_action_button("跳過演出", Vector2(574, 644), func() -> void:
		_cancel_sequence()
		show_results(results, count)
	, Vector2(132, 46))
	app._add_action_button("返回卡池", Vector2(710, 644), func() -> void:
		_cancel_sequence()
		app._pop_view()
	, Vector2(132, 46))
	run_stage_auto.call_deferred(results, count, seq)

func show_stage_color(results: Array, count: int, seq: int) -> void:
	if not _is_sequence_live(seq):
		return
	app._play_sfx(app.AUDIO_SFX_DRAW_ANIMATION, 0.86)
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var is_prayer := _is_prayer_pool(pool)
	var best := best_result(results)
	var hero: Dictionary = best.get("hero", app._hero_by_id(240065))
	var rarity := int(best.get("rolled_rarity", hero.get("rarity", 1)))
	app.current_view = "draw_stage_color"
	app._set_chrome_visible(false)
	app._clear("喚靈共鳴")
	draw_stage_backdrop(rarity, is_prayer)
	draw_stage_cards(results, rarity, is_prayer)
	var title: Label = app._label("命運軌跡已鎖定", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(390, 76)
	title.size = Vector2(500, 62)
	title.modulate = frame_color(rarity, 1.0)
	app._view_container().add_child(title)
	var rare_text := "SSR 反應" if rarity >= 4 else ("SR 反應" if rarity == 3 else "靈能反應")
	var hint: Label = app._label("%s\n即將顯現最高稀有度幻靈" % rare_text, 24, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(392, 510)
	hint.size = Vector2(496, 70)
	hint.modulate = Color(1.0, 0.92, 0.72)
	app._view_container().add_child(hint)
	app._add_action_button("跳過", Vector2(1088, 34), func() -> void:
		_cancel_sequence()
		show_results(results, count)
	, Vector2(102, 40))
	run_color_auto.call_deferred(results, count, seq)

func show_recruit_reveal(count: int) -> void:
	var results: Array = app._perform_draw(count)
	if results.is_empty():
		show_empty_ticket_warning()
		return
	show_recruit_silhouette(results, count, _next_sequence())

func show_recruit_silhouette(results: Array, count: int, seq: int) -> void:
	if not _is_sequence_live(seq):
		return
	app._play_sfx(app.AUDIO_SFX_DRAW_ANIMATION, 0.86)
	var best := best_result(results)
	var hero: Dictionary = best.get("hero", app._hero_by_id(240065))
	var rarity := int(best.get("rolled_rarity", hero.get("rarity", 1)))
	if try_show_recruit_video(hero, rarity, results, count, seq):
		return
	app.current_view = "hero_recruit_silhouette"
	app._set_chrome_visible(false)
	app._clear("幻靈顯現")
	draw_recruit_backdrop(rarity)
	draw_spine_png_variant(hero, "_silhouette", Vector2(438, 18), Vector2(620, 668), Color(0, 0, 0, 0.82))
	draw_recruit_fx_layers(rarity, false)

	var title: Label = app._label("靈魂輪廓同步中", 34, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(90, 204)
	title.size = Vector2(360, 52)
	title.modulate = Color(0.94, 0.88, 0.72)
	app._view_container().add_child(title)
	var hint: Label = app._label("點擊可立即揭示\n%s 反應" % ("SSR" if rarity >= 4 else "稀有度"), 20, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(118, 270)
	hint.size = Vector2(304, 70)
	app._view_container().add_child(hint)
	app._add_hit_button(Vector2.ZERO, Vector2(1280, 720), func() -> void:
		show_recruit_revealed(results, count, seq)
	)
	app._add_action_button("跳過", Vector2(1088, 34), func() -> void:
		_cancel_sequence()
		show_results(results, count)
	, Vector2(102, 40))
	run_recruit_auto.call_deferred(results, count, seq)

func try_show_recruit_video(hero: Dictionary, rarity: int, results: Array, count: int, seq: int) -> bool:
	var video_path: String = app._hero_recruit_video_path(hero)
	if video_path.is_empty():
		return false
	print("HeroRecruit video: %s -> %s" % [hero.get("spine", ""), video_path])
	app.current_view = "hero_recruit_video"
	app._set_chrome_visible(false)
	app._clear("鎷涘嫙瑙嗛")
	draw_recruit_backdrop(rarity)
	var video: VideoStreamPlayer = app._draw_video(video_path, RECRUIT_VIDEO_POS, RECRUIT_VIDEO_SIZE, func() -> void:
		if _is_sequence_live(seq):
			show_recruit_revealed(results, count, seq)
	)
	if video == null:
		return false
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), frame_color(rarity, 0.06)))
	var reveal_callback := func() -> void:
		if _is_sequence_live(seq):
			show_recruit_revealed(results, count, seq)
	app._add_action_button("璺宠繃", Vector2(1088, 34), reveal_callback, Vector2(102, 40))
	app._add_hit_button(Vector2.ZERO, Vector2(1280, 720), reveal_callback)
	return true

func show_recruit_revealed(results: Array, count: int, seq: int) -> void:
	if not _is_sequence_live(seq):
		return
	var best := best_result(results)
	var hero: Dictionary = best.get("hero", app._hero_by_id(240065))
	var rarity := int(best.get("rolled_rarity", hero.get("rarity", 1)))

	app.current_view = "hero_recruit"
	app._set_chrome_visible(false)
	app._clear("招募演出")
	draw_recruit_backdrop(rarity)

	draw_spine_png_variant(hero, "_silhouette", Vector2(610, 36), Vector2(520, 620), Color(0, 0, 0, 0.18))
	app._draw_hero_stage(hero, Vector2(596, 28), Vector2(560, 636), false)
	draw_recruit_fx_layers(rarity, true)
	draw_quality_frame(rarity)

	var rare_label := "SSR" if rarity >= 4 else ("SR" if rarity == 3 else "R")
	var rare_tag: Label = app._label(rare_label, 54, HORIZONTAL_ALIGNMENT_CENTER)
	rare_tag.position = Vector2(78, 132)
	rare_tag.size = Vector2(260, 70)
	rare_tag.modulate = frame_color(rarity, 1.0)
	app._view_container().add_child(rare_tag)

	var new_tag: Label = app._label("NEW" if best.get("is_new", false) else "碎片 +%d" % int(best.get("shards", 0)), 28, HORIZONTAL_ALIGNMENT_CENTER)
	new_tag.position = Vector2(130, 202)
	new_tag.size = Vector2(220, 44)
	new_tag.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(new_tag)

	var name: Label = app._label(str(hero.get("name", "")), 44, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = Vector2(74, 252)
	name.size = Vector2(360, 58)
	app._view_container().add_child(name)

	var star: Label = app._label(app._stars(rarity), 26, HORIZONTAL_ALIGNMENT_CENTER)
	star.position = Vector2(82, 314)
	star.size = Vector2(344, 40)
	star.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(star)

	var hint: Label = app._label("點擊繼續查看本次結果", 18, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(72, 382)
	hint.size = Vector2(360, 34)
	hint.modulate = Color(0.92, 0.84, 0.68)
	app._view_container().add_child(hint)

	app._add_action_button("查看结果", Vector2(170, 620), func() -> void:
		_cancel_sequence()
		show_results(results, count)
	, Vector2(142, 46))
	app._add_action_button("返回卡池", Vector2(324, 620), func() -> void:
		_cancel_sequence()
		app._pop_view()
	, Vector2(132, 46))
	app._add_action_button("跳过", Vector2(1088, 34), func() -> void:
		_cancel_sequence()
		show_results(results, count)
	, Vector2(102, 40))
	app._add_hit_button(Vector2.ZERO, Vector2(1280, 720), func() -> void:
		_cancel_sequence()
		show_results(results, count)
	)
	run_revealed_auto.call_deferred(results, count, seq)

func draw_and_show(count: int) -> void:
	var results = app._perform_draw(count)
	show_results(results, count)

func show_prayer_rewards(count: int, play_reveal: bool) -> void:
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "prayer")))
	var cost := count * int(pool.get("ticketCost", 1))
	if int(app.save.get("tickets", 0)) < cost:
		show_empty_ticket_warning("祈願鑰匙不足", true)
		return
	var results: Array = app._perform_draw(count)
	if results.is_empty():
		show_empty_ticket_warning("祈願鑰匙不足", true)
		return
	var seq := _next_sequence()
	if play_reveal:
		if _is_holy_relic_prayer_pool(pool):
			show_prayer_holy_relic_reveal(results, count, seq)
		else:
			show_prayer_remnant_reveal(results, count, seq)
	else:
		show_prayer_result_view(results, count)

func show_prayer_remnant_reveal(results: Array, count: int, seq: int) -> void:
	if not _is_sequence_live(seq):
		return
	app._play_sfx(app.AUDIO_SFX_DRAW_ANIMATION, 0.86)
	var best := best_result(results)
	var rarity := int(best.get("rolled_rarity", 2))
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "source_prayer")))
	app.current_view = "prayer_remnant_recruit"
	app._set_chrome_visible(false)
	app._clear("祈願顯現")
	draw_prayer_remnant_reveal_backdrop(rarity)

	var title: Label = app._label(str(pool.get("name", "源神祈願")), 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(74, 104)
	title.size = Vector2(340, 60)
	title.modulate = Color(1.0, 0.92, 0.72)
	app._view_container().add_child(title)

	var rare_text := "SSR 共鳴" if rarity >= 4 else ("SR 共鳴" if rarity == 3 else "源質共鳴")
	var rare: Label = app._label(rare_text, 34, HORIZONTAL_ALIGNMENT_CENTER)
	rare.position = Vector2(78, 170)
	rare.size = Vector2(332, 52)
	rare.modulate = frame_color(rarity, 1.0)
	app._view_container().add_child(rare)

	var hint: Label = app._label("祈願儀式展開中\n點擊查看本次結果", 22, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(86, 236)
	hint.size = Vector2(316, 70)
	hint.modulate = Color(0.96, 0.88, 0.74)
	app._view_container().add_child(hint)

	app._add_hit_button(Vector2.ZERO, Vector2(1280, 720), func() -> void:
		_cancel_sequence()
		show_prayer_result_view(results, count)
	)
	app._add_action_button("查看结果", Vector2(162, 612), func() -> void:
		_cancel_sequence()
		show_prayer_result_view(results, count)
	, Vector2(142, 46))
	app._add_action_button("返回祈願", Vector2(318, 612), func() -> void:
		_cancel_sequence()
		app._pop_view()
	, Vector2(132, 46))
	app._add_action_button("跳过", Vector2(1088, 34), func() -> void:
		_cancel_sequence()
		show_prayer_result_view(results, count)
	, Vector2(102, 40))
	run_prayer_reveal_auto.call_deferred(results, count, seq)

func show_prayer_holy_relic_reveal(results: Array, count: int, seq: int) -> void:
	if not _is_sequence_live(seq):
		return
	app._play_sfx(app.AUDIO_SFX_DRAW_ANIMATION, 0.86)
	var best := best_result(results)
	var rarity := int(best.get("rolled_rarity", 2))
	var pool: Dictionary = app._pool_by_id(str(app.save.get("active_pool_id", "prayer")))
	app.current_view = "prayer_holy_relic_recruit"
	app._set_chrome_visible(false)
	app._clear("遺器顯現")
	draw_prayer_recruit_backdrop(rarity)

	var title: Label = app._label("遺器祈願", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(70, 112)
	title.size = Vector2(330, 60)
	title.modulate = Color(1.0, 0.92, 0.72)
	app._view_container().add_child(title)

	var rare_text := "SSR 遺器顯現" if rarity >= 4 else ("SR 遺器顯現" if rarity == 3 else "遺器顯現")
	var rare: Label = app._label(rare_text, 34, HORIZONTAL_ALIGNMENT_CENTER)
	rare.position = Vector2(70, 176)
	rare.size = Vector2(330, 52)
	rare.modulate = frame_color(rarity, 1.0)
	app._view_container().add_child(rare)

	var name: Label = app._label(_prayer_reward_name(best), 30, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = Vector2(74, 242)
	name.size = Vector2(322, 46)
	app._view_container().add_child(name)

	var detail: Label = app._label("%s\n%s  保底進度 %d / %d" % [
		app._stars(min(rarity + 1, 5)) if rarity >= 4 else app._stars(rarity),
		str(pool.get("name", "遺器祈願")),
		app._pity(str(pool.get("id", "prayer"))),
		int(pool.get("pityLimit", 30))
	], 19, HORIZONTAL_ALIGNMENT_CENTER)
	detail.position = Vector2(78, 306)
	detail.size = Vector2(314, 76)
	detail.modulate = Color(0.96, 0.88, 0.74)
	app._view_container().add_child(detail)

	app._add_action_button("查看结果", Vector2(162, 612), func() -> void:
		_cancel_sequence()
		show_prayer_result_view(results, count)
	, Vector2(142, 46))
	app._add_action_button("返回祈願", Vector2(318, 612), func() -> void:
		_cancel_sequence()
		app._pop_view()
	, Vector2(132, 46))
	app._add_action_button("跳过", Vector2(1088, 34), func() -> void:
		_cancel_sequence()
		show_prayer_result_view(results, count)
	, Vector2(102, 40))
	app._add_hit_button(Vector2.ZERO, Vector2(1280, 720), func() -> void:
		_cancel_sequence()
		show_prayer_result_view(results, count)
	)
	run_prayer_reveal_auto.call_deferred(results, count, seq)

func show_prayer_result_view(results: Array, count: int) -> void:
	app.current_view = "prayer_reward"
	app._set_chrome_visible(false)
	app._clear("祈願结果")
	if results.is_empty():
		show_empty_ticket_warning("祈願鑰匙不足", true)
		return
	app._play_sfx(app.AUDIO_SFX_GET_REWARD, 0.82)
	draw_prayer_result_backdrop(results)
	draw_prayer_reward_grid(results)
	app._add_action_button("再祈願一次", Vector2(780, 656), func() -> void:
		show_prayer_rewards(count, not bool(app.save.get("gacha_skip_animation", false)))
	, Vector2(148, 42))
	app._add_action_button("返回祈願", Vector2(944, 656), func() -> void: app._pop_view(), Vector2(132, 42))
	app._add_action_button("遺器", Vector2(1094, 656), app._show_relics, Vector2(92, 42))

func show_results(results: Array, count: int) -> void:
	app.current_view = "draw_result"
	app._set_chrome_visible(false)
	app._clear("喚灵结果")
	if results.is_empty():
		show_empty_ticket_warning()
		return
	app._play_sfx(app.AUDIO_SFX_DRAW_RESULT_1 if count <= 1 else app.AUDIO_SFX_DRAW_RESULT_10, 0.86)
	draw_finish_backdrop(results)
	draw_result_grid(results)
	app._add_action_button("再抽一次", Vector2(794, 656), func() -> void: show_draw_animation(count), Vector2(132, 42))
	app._add_action_button("返回卡池", Vector2(944, 656), func() -> void: app._pop_view(), Vector2(132, 42))
	app._add_action_button("图鉴", Vector2(1094, 656), app._show_gallery, Vector2(92, 42))

func show_empty_ticket_warning(message := "喚灵券不足", prayer := false) -> void:
	app._set_chrome_visible(false)
	app._clear("祈願结果" if prayer else "喚灵结果")
	if prayer:
		draw_prayer_result_backdrop([])
	else:
		draw_recruit_backdrop(2)
	var warning = app._label(message, 34, HORIZONTAL_ALIGNMENT_CENTER)
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

func draw_stage_backdrop(rarity: int, is_prayer: bool = false) -> void:
	var bg_path := UI_PRAYER_STAGE_BG if is_prayer else UI_RECRUIT_BG
	app._draw_image(bg_path, Vector2(-195, -6), Vector2(1670, 732), true, Color(1, 1, 1, 0.92))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.006, 0.008, 0.018, 0.48)))
	app._draw_image(UI_RECRUIT_LIGHT_L, _stage_center_pos(Vector2(-417.5, 0), Vector2(835, 750)), _stage_size(Vector2(835, 750)), true, Color(1, 1, 1, 0.36))
	app._draw_image(UI_RECRUIT_LIGHT_R, _stage_center_pos(Vector2(417.5, 0), Vector2(835, 750)), _stage_size(Vector2(835, 750)), true, Color(1, 1, 1, 0.36))
	app._draw_image(UI_RECRUIT_FX_L, _stage_center_pos(Vector2(-417.5, 0), Vector2(835, 750)), _stage_size(Vector2(835, 750)), true, frame_color(rarity, 0.20))
	app._draw_image(UI_RECRUIT_FX_R, _stage_center_pos(Vector2(417.5, 0), Vector2(835, 750)), _stage_size(Vector2(835, 750)), true, frame_color(rarity, 0.20))
	app._draw_image(UI_RECRUIT_GROUP, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.18))

func draw_stage_orbits(results: Array, rarity: int, is_prayer: bool = false) -> void:
	draw_new_stage_starmap(rarity, false, is_prayer)
	var pulse: Label = app._label("點擊星圖啟動", 20, HORIZONTAL_ALIGNMENT_CENTER)
	pulse.position = Vector2(548, 342)
	pulse.size = Vector2(184, 32)
	pulse.modulate = Color(1.0, 0.92, 0.68)
	app._view_container().add_child(pulse)

func draw_stage_cards(results: Array, rarity: int, is_prayer: bool = false) -> void:
	draw_new_stage_starmap(rarity, true, is_prayer)

func draw_new_stage_starmap(rarity: int, activated: bool, is_prayer: bool = false) -> void:
	var disc_main := UI_PRAYER_DISC if is_prayer else UI_RECRUIT_DISC
	var disc_a := UI_PRAYER_DISC_A if is_prayer else UI_STAGE_DISC_A
	var disc_b := UI_PRAYER_DISC_B if is_prayer else UI_STAGE_DISC_B
	var disc_c := UI_PRAYER_DISC_C if is_prayer else UI_STAGE_DISC_C
	var disc_f := UI_PRAYER_DISC_D if is_prayer else UI_STAGE_DISC_F
	var disc_i := UI_PRAYER_DISC_E if is_prayer else UI_STAGE_DISC_I
	app._draw_image(disc_main, _stage_center_pos(Vector2(0, 0), Vector2(725, 708)), _stage_size(Vector2(725, 708)), false, frame_color(rarity, 0.95 if activated else 0.76))
	app._draw_image(disc_i, _stage_center_pos(Vector2(0, 0), Vector2(700, 700)), _stage_size(Vector2(700, 700)), false, Color(1, 1, 1, 0.42 if activated else 0.24))
	app._draw_image(disc_f, _stage_center_pos(Vector2(0, 0), Vector2(400, 400)), _stage_size(Vector2(400, 400)), false, frame_color(rarity, 0.50 if activated else 0.26))
	app._draw_image(disc_a, _stage_center_pos(Vector2(0, 0), Vector2(210, 210)), _stage_size(Vector2(210, 210)), false, Color(1, 1, 1, 0.68))
	app._draw_image(disc_b, _stage_center_pos(Vector2(0, 0), Vector2(190, 190)), _stage_size(Vector2(190, 190)), false, frame_color(rarity, 0.72 if activated else 0.38))
	app._draw_image(disc_c, _stage_center_pos(Vector2(1, 6), Vector2(256, 256)), _stage_size(Vector2(256, 256)), false, Color(1, 1, 1, 0.46))
	var stars: Array = [
		{"center": Vector2(-516.5, 106), "size": Vector2(255, 270), "inner": Vector2(261, 261)},
		{"center": Vector2(-696, -64), "size": Vector2(200, 200), "inner": Vector2(180, 180)},
		{"center": Vector2(-472, -199), "size": Vector2(184, 184), "inner": Vector2(190, 190)},
		{"center": Vector2(-373.3, -62.8), "size": Vector2(200, 200), "inner": Vector2(270, 270)},
		{"center": Vector2(362.3, 245.1), "size": Vector2(200, 200), "inner": Vector2(270, 270)},
		{"center": Vector2(570.3, 222.1), "size": Vector2(270, 270), "inner": Vector2(261, 261)},
		{"center": Vector2(693.1, -41.9), "size": Vector2(285, 285), "inner": Vector2(400, 400)},
		{"center": Vector2(485.3, -209), "size": Vector2(200, 200), "inner": Vector2(270, 270)},
	]
	for index in range(stars.size()):
		var star: Dictionary = stars[index]
		var center: Vector2 = star["center"]
		var size: Vector2 = star["size"]
		var inner: Vector2 = star["inner"]
		var pos := _stage_center_pos(center, size)
		var inner_pos := _stage_center_pos(center, inner)
		var alpha := 0.34 + float(index % 3) * 0.10
		if activated:
			alpha += 0.22
		app._draw_image(disc_c, inner_pos, _stage_size(inner), false, frame_color(rarity, alpha))
		app._draw_image(disc_a, pos + _stage_size(Vector2(size.x * 0.24, size.y * 0.24)), _stage_size(Vector2(size.x * 0.36, size.y * 0.36)), false, Color(1, 1, 1, 0.62 if activated else 0.42))
		app._view_container().add_child(app._panel(pos + _stage_size(Vector2(size.x * 0.42, size.y * 0.42)), _stage_size(Vector2(size.x * 0.16, size.y * 0.16)), frame_color(rarity if activated and index == 6 else 3, 0.42)))
	if activated:
		app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), frame_color(rarity, 0.12)))

func draw_recruit_fx_layers(rarity: int, revealed: bool) -> void:
	var alpha := 0.74 if revealed else 0.38
	app._draw_image(UI_RECRUIT_DISC, Vector2(396, -72), Vector2(488, 488), false, frame_color(rarity, 0.28 * alpha))
	app._draw_image(UI_RECRUIT_FX_L, Vector2(-24, 0), Vector2(650, 720), true, frame_color(rarity, 0.24 * alpha))
	app._draw_image(UI_RECRUIT_FX_R, Vector2(654, 0), Vector2(650, 720), true, frame_color(rarity, 0.24 * alpha))
	for i in range(4):
		var x := 92.0 + float(i) * 292.0
		app._view_container().add_child(app._panel(Vector2(x, 450 + float(i % 2) * 18), Vector2(210, 5), frame_color(rarity, 0.38 * alpha)))

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
	draw_finish_light_masks(rarity)
	var title = app._label("喚灵结果", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(420, 46)
	title.size = Vector2(440, 60)
	app._view_container().add_child(title)
	var top = app._label("%s  %s" % [app._stars(rarity), hero.get("name", "")], 24, HORIZONTAL_ALIGNMENT_CENTER)
	top.position = Vector2(390, 108)
	top.size = Vector2(500, 44)
	top.modulate = app._rarity_color(rarity, 1.0)
	app._view_container().add_child(top)

func draw_finish_light_masks(rarity: int) -> void:
	var masks := [
		{"pos": Vector2(330, -64), "size": Vector2(452, 452), "alpha": 0.36},
		{"pos": Vector2(22, 108), "size": Vector2(230, 310), "alpha": 0.20},
		{"pos": Vector2(1008, 98), "size": Vector2(250, 320), "alpha": 0.20},
		{"pos": Vector2(230, 474), "size": Vector2(820, 54), "alpha": 0.22},
		{"pos": Vector2(476, 96), "size": Vector2(330, 330), "alpha": 0.26},
	]
	for mask in masks:
		app._draw_image(UI_RECRUIT_DISC, mask.get("pos", Vector2.ZERO), mask.get("size", Vector2.ZERO), false, frame_color(rarity, float(mask.get("alpha", 0.2))))

func draw_prayer_recruit_backdrop(rarity: int) -> void:
	app._draw_image(UI_PRAYER_STAGE_BG, Vector2(-195, -6), Vector2(1670, 732), true, Color(1, 1, 1, 0.94))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.012, 0.010, 0.42)))
	app._view_container().add_child(app._panel(Vector2(0, 452), Vector2(1280, 150), frame_color(rarity, 0.16)))
	app._draw_image(UI_RECRUIT_LIGHT_L, Vector2(-48, 148), Vector2(690, 430), true, Color(1.0, 0.86, 0.58, 0.26))
	app._draw_image(UI_RECRUIT_LIGHT_R, Vector2(638, 148), Vector2(690, 430), true, frame_color(rarity, 0.32))
	draw_fx_capsule_open_blue(Vector2(708, 286), rarity)
	app._draw_image(UI_PRAYER_REWARD_RARE_SSR, Vector2(956, 108), Vector2(118, 58), false, Color(1, 1, 1, 0.92 if rarity >= 4 else 0.38))


func draw_prayer_remnant_reveal_backdrop(rarity: int) -> void:
	app._draw_image(UI_PRAYER_STAGE_BG, Vector2(-195, -6), Vector2(1670, 732), true, Color(1, 1, 1, 0.90))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.014, 0.026, 0.24)))
	if FileAccess.file_exists(UI_PRAYER_REMNANT_SPINE_BAKED):
		var canvas: Control = SPINE_BAKED_PREVIEW_CANVAS.new()
		canvas.position = Vector2(0, 0)
		canvas.size = Vector2(1280, 720)
		canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		app._view_container().add_child(canvas)
		canvas.set_baked_path(UI_PRAYER_REMNANT_SPINE_BAKED, "1")
	elif FileAccess.file_exists(UI_PRAYER_REMNANT_SPINE_FALLBACK):
		app._draw_image(UI_PRAYER_REMNANT_SPINE_FALLBACK, Vector2(0, 0), Vector2(1280, 720), false)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(456, 720), Color(0.02, 0.016, 0.026, 0.42)))
	app._draw_image(UI_RECRUIT_LIGHT_L, Vector2(0, 0), Vector2(640, 720), true, frame_color(rarity, 0.18))
	app._draw_image(UI_RECRUIT_FX_R, Vector2(640, 0), Vector2(640, 720), true, frame_color(rarity, 0.12))


func draw_fx_capsule_open_blue(center: Vector2, rarity: int) -> void:
	# Source: Assets/Game/RawAssets/Prefabs/3d/fx_capsule_open_blue.prefab.
	# Unity structure is fx_capsule_open_blue/vfx_blue/gyunan + four gyun4 children,
	# each bound by UiParticles to one ParticleSystem. No disc/star-map atlas sprites.
	var layers := [
		{"node": "gyunan", "texture": FX_CAPSULE_BLUE_RING, "size": Vector2(600, 600), "color": Color(1, 1, 1, 0.58), "speed": 0.04, "pulse": 0.035},
		{"node": "gyun4 (1)", "texture": FX_CAPSULE_BLUE_GLOW, "size": Vector2(140, 140), "color": Color(0.155, 0.326, 0.802, 0.70), "speed": -0.10, "pulse": 0.08},
		{"node": "gyun4 (2)", "texture": FX_CAPSULE_BLUE_GLOW, "size": Vector2(100, 100), "color": Color(0.026, 0.145, 0.292, 0.48), "speed": 0.07, "pulse": 0.06},
		{"node": "gyun4 (3)", "texture": FX_CAPSULE_BLUE_STAR, "size": Vector2(120, 120), "color": Color(0.459, 0.918, 1.0, 0.96), "speed": 0.17, "pulse": 0.10},
		{"node": "gyun4 (5)", "texture": FX_CAPSULE_BLUE_STAR, "size": Vector2(110, 110), "color": Color(0.271, 0.145, 0.784, 0.58), "speed": -0.26, "pulse": 0.09},
	]
	for index in range(layers.size()):
		var layer: Dictionary = layers[index]
		var size: Vector2 = layer["size"]
		var rect: TextureRect = app._draw_image(str(layer["texture"]), center - size * 0.5, size, false, layer["color"])
		if rect == null:
			continue
		rect.name = str(layer["node"])
		rect.pivot_offset = size * 0.5
		rect.rotation = 0.18 * float(index)
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		rect.material = mat
		var tween: Tween = app.get_tree().create_tween()
		tween.set_loops()
		tween.tween_property(rect, "rotation", rect.rotation + TAU * sign(float(layer["speed"])), max(8.0, TAU / max(abs(float(layer["speed"])), 0.04))).from(rect.rotation)
		var pulse: Tween = app.get_tree().create_tween()
		pulse.set_loops()
		pulse.tween_property(rect, "scale", Vector2.ONE * (1.0 + float(layer["pulse"])), 0.72 + float(index) * 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(rect, "scale", Vector2.ONE, 0.72 + float(index) * 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func draw_prayer_result_backdrop(results: Array) -> void:
	var rarity := 3
	var title_name := "遺器祈願"
	if not results.is_empty():
		var best := best_result(results)
		rarity = int(best.get("rolled_rarity", 3))
		title_name = _prayer_reward_name(best)
	app._draw_image(UI_PRAYER_STAGE_BG, Vector2(-195, -6), Vector2(1670, 732), true, Color(1, 1, 1, 0.90))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.016, 0.012, 0.014, 0.54)))
	app._draw_image(UI_PRAYER_DISC, Vector2(410, -120), Vector2(460, 460), false, frame_color(rarity, 0.22))
	app._draw_image(UI_PRAYER_DISC_E, Vector2(940, 86), Vector2(248, 248), false, Color(1, 1, 1, 0.16))
	var title: Label = app._label("祈願结果", 42, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(420, 46)
	title.size = Vector2(440, 60)
	app._view_container().add_child(title)
	var top: Label = app._label("%s  %s" % [app._stars(min(rarity + 1, 5)) if rarity >= 4 else app._stars(rarity), title_name], 24, HORIZONTAL_ALIGNMENT_CENTER)
	top.position = Vector2(340, 108)
	top.size = Vector2(600, 44)
	top.modulate = frame_color(rarity, 1.0)
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

func draw_prayer_reward_grid(results: Array) -> void:
	var columns := 5 if results.size() > 1 else 1
	var card_size := Vector2(162, 210) if results.size() > 1 else Vector2(300, 360)
	var gap := Vector2(24, 24)
	var total_w := columns * card_size.x + (columns - 1) * gap.x
	var start_x := (1280.0 - total_w) * 0.5
	var start_y := 166.0 if results.size() > 1 else 176.0
	for i in range(results.size()):
		var result: Dictionary = results[i]
		var rarity := int(result.get("rolled_rarity", 2))
		var col := i % columns
		var row := i / columns
		var pos := Vector2(start_x + col * (card_size.x + gap.x), start_y + row * (card_size.y + gap.y))
		draw_prayer_reward_card(result, pos, card_size, rarity)

func draw_prayer_reward_card(result: Dictionary, pos: Vector2, card_size: Vector2, rarity: int) -> void:
	var color_idx := _prayer_reward_color_index(rarity)
	app._view_container().add_child(app._panel(pos, card_size, Color(0.022, 0.018, 0.018, 0.70)))
	app._draw_image(str(UI_PRAYER_REWARD_BG.get(color_idx, UI_PRAYER_REWARD_BG[2])), pos - Vector2(4, 4), card_size + Vector2(8, 8), false, Color(1, 1, 1, 0.92))
	app._draw_image(str(UI_PRAYER_REWARD_MASK.get(color_idx, UI_PRAYER_REWARD_MASK[2])), pos + Vector2(8, 8), card_size - Vector2(16, 58), false, Color(1, 1, 1, 0.52))
	app._draw_image(UI_PRAYER_DISC, pos + Vector2(card_size.x * 0.5 - 48, 34), Vector2(96, 96), false, frame_color(rarity, 0.90))
	app._draw_image(UI_PRAYER_DISC_A, pos + Vector2(card_size.x * 0.5 - 34, 48), Vector2(68, 68), false, Color(1, 1, 1, 0.86))
	app._draw_image(UI_PRAYER_DISC_B, pos + Vector2(card_size.x * 0.5 - 24, 58), Vector2(48, 48), false, frame_color(rarity, 0.92))
	app._draw_image(str(UI_PRAYER_REWARD_FRAME.get(color_idx, UI_PRAYER_REWARD_FRAME[2])), pos - Vector2(4, 4), card_size + Vector2(8, 8), false, Color(1, 1, 1, 0.95))
	app._draw_image(str(UI_PRAYER_REWARD_TAG.get(color_idx, UI_PRAYER_REWARD_TAG[2])), pos + Vector2(8, 8), Vector2(56, 24), false, Color(1, 1, 1, 0.90))
	app._draw_image(UI_PRAYER_REWARD_RELIC_TAG, pos + Vector2(card_size.x - 58, 8), Vector2(48, 24), false, Color(1, 1, 1, 0.78))
	if rarity >= 4:
		app._draw_image(UI_PRAYER_REWARD_RARE_SSR, pos + Vector2(10, card_size.y - 74), Vector2(74, 36), false, Color(1, 1, 1, 0.90))

	var name: Label = app._label(_prayer_reward_name(result), 17, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = pos + Vector2(8, card_size.y - 58)
	name.size = Vector2(card_size.x - 16, 28)
	app._view_container().add_child(name)

	var detail: Label = app._label("%s   %s" % [_prayer_reward_grade(rarity), "NEW" if result.get("is_new", false) else "精粹 +%d" % max(1, int(result.get("shards", 0)))], 14, HORIZONTAL_ALIGNMENT_CENTER)
	detail.position = pos + Vector2(8, card_size.y - 30)
	detail.size = Vector2(card_size.x - 16, 22)
	detail.modulate = frame_color(rarity, 1.0)
	app._view_container().add_child(detail)

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = card_size
	button.pressed.connect(func() -> void:
		app._show_relics()
	)
	app._view_container().add_child(button)

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

func _is_prayer_pool(pool: Dictionary) -> bool:
	var realm := str(pool.get("realm", ""))
	var pid := str(pool.get("id", ""))
	return realm == "prayer" or pid == "prayer" or pid == "self_select_prayer" or pid == "source_prayer" or pid == "saint_source_prayer"

func _is_holy_relic_prayer_pool(pool: Dictionary) -> bool:
	var pool_id := str(pool.get("id", "prayer"))
	return pool_id == "prayer" or pool_id == "self_select_prayer"

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

func _next_sequence() -> int:
	sequence_id += 1
	return sequence_id

func _cancel_sequence() -> void:
	sequence_id += 1

func _is_sequence_live(seq: int) -> bool:
	return seq == sequence_id

func run_stage_auto(results: Array, count: int, seq: int) -> void:
	await app.get_tree().create_timer(0.95).timeout
	if _is_sequence_live(seq):
		show_stage_color(results, count, seq)

func run_color_auto(results: Array, count: int, seq: int) -> void:
	await app.get_tree().create_timer(0.95).timeout
	if _is_sequence_live(seq):
		show_recruit_silhouette(results, count, seq)

func run_recruit_auto(results: Array, count: int, seq: int) -> void:
	await app.get_tree().create_timer(0.90).timeout
	if _is_sequence_live(seq):
		show_recruit_revealed(results, count, seq)

func run_revealed_auto(results: Array, count: int, seq: int) -> void:
	await app.get_tree().create_timer(1.35).timeout
	if _is_sequence_live(seq):
		show_results(results, count)

func run_prayer_reveal_auto(results: Array, count: int, seq: int) -> void:
	await app.get_tree().create_timer(2.20).timeout
	if _is_sequence_live(seq):
		show_prayer_result_view(results, count)

func _prayer_reward_color_index(rarity: int) -> int:
	if rarity >= 4:
		return 5
	if rarity == 3:
		return 4
	return 2

func _prayer_reward_grade(rarity: int) -> String:
	if rarity >= 4:
		return "SSR"
	if rarity == 3:
		return "SR"
	return "R"

func _prayer_reward_name(result: Dictionary) -> String:
	var hero: Dictionary = result.get("hero", {})
	var hero_name := str(hero.get("name", "星核"))
	if hero_name.is_empty():
		hero_name = "星核"
	return "遺器·%s" % hero_name

func frame_color(rarity: int, alpha: float) -> Color:
	if rarity >= 4:
		return Color(1.0, 0.62, 0.16, alpha)
	if rarity == 3:
		return Color(0.72, 0.38, 1.0, alpha)
	return Color(0.30, 0.66, 1.0, alpha)
