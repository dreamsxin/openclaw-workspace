# UTF-8 source. ChapterTaskView / ChapterTaskCell reconstruction split from main.gd.
extends RefCounted

const UI_CHAPTER_BG := "res://assets/ui/background/hero_bg_01.png"
const UI_CHAPTER_SPINE_MASK_BG := "res://assets/ui/background/task_bg_01.png"
const UI_CHAPTER_REWARD_DETAIL_BG := "res://assets/ui/background/common_bg_09.png"
const UI_CHAPTER_REVIEW_BTN := "res://assets/ui/task/task_btn_01.png"
const UI_CHAPTER_TIP_BAR := "res://assets/ui/task/task_img_39.png"
const UI_CHAPTER_GO_BTN := "res://assets/ui/task/task_img_37.png"
const UI_CHAPTER_DIVIDER := "res://assets/ui/task/task_img_13.png"
const UI_CHAPTER_TASK_CELL_BG := "res://assets/ui/task/task_img_18.png"
const UI_CHAPTER_TASK_PROGRESS_BG := "res://assets/ui/task/task_img_03.png"
const UI_CHAPTER_TASK_PROGRESS_FILL := "res://assets/ui/task/task_img_02.png"
const UI_CHAPTER_TASK_CLAIM_BTN := "res://assets/ui/common/common_btn_02.png"
const UI_CHAPTER_CLAIMED := "res://assets/ui/common/common_img_88.png"
const UI_CHAPTER_FULL_CLAIM_BTN := "res://assets/ui/common/common_btn_17.png"
const UI_CHAPTER_REWARD_ROW_BG := "res://assets/ui/common/common_img_44.png"
const UI_CHAPTER_REWARD_ROW_ICON := "res://assets/ui/common/common_img_46.png"
const UI_CHAPTER_CLOSE_BTN := "res://assets/ui/common/common_btn_16.png"
const UI_CHAPTER_ROLE_MASK := "res://assets/ui/hero/hero_img_253.png"
const UI_ITEM_TICKET := "res://assets/ui/item/draw_07.png"
const UI_ITEM_GEM := "res://assets/ui/item/draw_05.png"
const UI_ITEM_SHARD := "res://assets/ui/item/draw_06.png"
const CHAPTER_META_PATH := "res://data/chapter_meta_mvp.json"
const CTO_BASE := "res://assets/ui/changetoother/"
const UI_CTO_DI := CTO_BASE + "img_cto_di.png"
const UI_CTO_DARK := CTO_BASE + "img_cto_dark.png"
const UI_CTO_LIGHT1 := CTO_BASE + "img_cto_light1.png"
const UI_CTO_LIGHT2 := CTO_BASE + "img_cto_light2.png"
const UI_CTO_CLOCK01 := CTO_BASE + "img_cto_clock01.png"
const UI_CTO_CLOCK02 := CTO_BASE + "img_cto_clock02.png"
const UI_CTO_CLOCK03 := CTO_BASE + "img_cto_clock03.png"
const UI_CTO_CLOCK04 := CTO_BASE + "img_cto_clock04.png"
const UI_CTO_CLOCK05 := CTO_BASE + "img_cto_clock05.png"
const UI_CTO_CLOCK06 := CTO_BASE + "img_cto_clock06.png"
const UI_CTO_CLOCK06A := CTO_BASE + "img_cto_clock06a.png"
const UI_CTO_CLOCK07 := CTO_BASE + "img_cto_clock07.png"
const UI_CTO_CLOCK07B := CTO_BASE + "img_cto_clock07b.png"
const UI_CTO_CLOCK07C := CTO_BASE + "img_cto_clock07c.png"
const UI_CTO_CLOCK08 := CTO_BASE + "img_cto_clock08.png"
const UI_CTO_CLOCK09 := CTO_BASE + "img_cto_clock09.png"
const UI_CTO_CLOCK10 := CTO_BASE + "img_cto_clock10.png"
const UI_CTO_CLOCK11 := CTO_BASE + "img_cto_clock11.png"
const UI_CTO_CLOCK12 := CTO_BASE + "img_cto_clock12.png"
const UI_CTO_CLOCK13 := CTO_BASE + "img_cto_clock13.png"
const UI_CTO_CLOCK14 := CTO_BASE + "img_cto_clock14.png"
const UI_CTO_GD1 := CTO_BASE + "img_cto_gd1.png"
const UI_CTO_GD2 := CTO_BASE + "img_cto_gd2.png"

var app
var chapter_meta := {}
var _change_to_other_serial: int = 0
var _selected_chapter_index: int = 0

func _init(app_ref) -> void:
	app = app_ref
	chapter_meta = _read_json(CHAPTER_META_PATH)


func show_dust_transition() -> void:
	_change_to_other_serial += 1
	var transition_id: int = _change_to_other_serial
	app.current_view = "change_to_other"
	app._set_chrome_visible(false)
	app._clear("塵世探秘過渡")
	_draw_change_to_other()
	_complete_dust_transition(transition_id)


func _complete_dust_transition(transition_id: int) -> void:
	await app.get_tree().create_timer(1.18).timeout
	if transition_id != _change_to_other_serial:
		return
	if app.current_view != "change_to_other":
		return
	app._show_expedition_main()


func current_chapter_state() -> Dictionary:
	return _build_chapter_state(0)


func chapter_state_for_index(chapter_index: int) -> Dictionary:
	return _build_chapter_state(chapter_index)


func _build_chapter_state(chapter_index: int) -> Dictionary:
	var next_stage: Dictionary = app._next_stage()
	var max_stage_id: int = int(app.save.get("max_stage_id", 0))
	var next_stage_id: int = int(next_stage.get("id", 0))
	var current_chapter: Dictionary = {}
	var current_chapter_index: int = 1
	if chapter_index > 0 and chapter_index <= app.chapters.size():
		current_chapter = app.chapters[chapter_index - 1]
		current_chapter_index = chapter_index
	else:
		for index in range(app.chapters.size()):
			var chapter: Dictionary = app.chapters[index]
			for stage in chapter.get("stages", []):
				var stage_id: int = int(stage.get("id", 0))
				if stage_id == next_stage_id or (next_stage_id == 0 and stage_id <= max_stage_id):
					current_chapter = chapter
					current_chapter_index = index + 1
					break
			if not current_chapter.is_empty():
				break
	if current_chapter.is_empty() and not app.chapters.is_empty():
		current_chapter = app.chapters[app.chapters.size() - 1] if next_stage.is_empty() else app.chapters[0]
		current_chapter_index = app.chapters.size() if next_stage.is_empty() else 1
	var current_stages: Array = current_chapter.get("stages", [])
	var completed: int = 0
	for stage in current_stages:
		if int(stage.get("id", 0)) <= max_stage_id:
			completed += 1
	var stage_count: int = current_stages.size()
	var preview_stage: Dictionary = _preview_stage_for_chapter(current_stages, next_stage, max_stage_id, chapter_index <= 0)
	var effective_next_stage: Dictionary = next_stage if chapter_index <= 0 else preview_stage
	return {
		"chapter": current_chapter,
		"chapter_index": current_chapter_index,
		"completed": completed,
		"stage_count": max(stage_count, 1),
		"next_stage": effective_next_stage,
		"preview_stage": preview_stage,
		"chapter_rewards": chapter_reward_items(current_chapter),
		"preview_rewards": stage_reward_items(preview_stage),
		"preview_hero": preview_reward_hero(preview_stage),
	}


func _preview_stage_for_chapter(stages: Array, next_stage: Dictionary, max_stage_id: int, use_runtime_next_stage: bool) -> Dictionary:
	if use_runtime_next_stage and not next_stage.is_empty():
		return next_stage
	for stage in stages:
		if int(stage.get("id", 0)) > max_stage_id:
			return stage
	if not stages.is_empty():
		return stages[stages.size() - 1]
	return {}


func chapter_display_name(chapter: Dictionary, fallback_index: int = 1) -> String:
	var chapter_id: int = int(chapter.get("id", fallback_index))
	var meta := _chapter_meta(chapter_id)
	var resolved_name: String = str(meta.get("nameResolved", "")).strip_edges()
	if not resolved_name.is_empty():
		return resolved_name
	var raw_name: String = str(chapter.get("name", ""))
	if raw_name.begins_with("第"):
		var marker: int = raw_name.find("章")
		if marker >= 0 and marker + 1 < raw_name.length():
			var trimmed: String = raw_name.substr(marker + 1).strip_edges()
			if not trimmed.is_empty():
				return trimmed
	if not raw_name.is_empty():
		return raw_name
	return "第%d章" % fallback_index


func chapter_strip_text() -> String:
	var state: Dictionary = current_chapter_state()
	return "第%d章 %s %d/%d" % [
		int(state.get("chapter_index", 1)),
		chapter_display_name(state.get("chapter", {}), int(state.get("chapter_index", 1))),
		int(state.get("completed", 0)),
		int(state.get("stage_count", 1)),
	]


func chapter_reward_items(chapter: Dictionary) -> Array:
	var total_tickets: int = 0
	var total_gems: int = 0
	var total_shards: Dictionary = {}
	for stage in chapter.get("stages", []):
		total_tickets += int(stage.get("tickets", 0))
		total_gems += int(stage.get("gems", 0))
		_merge_shards(total_shards, stage.get("shards", {}))
	return _reward_items(total_tickets, total_gems, total_shards)


func stage_reward_items(stage: Dictionary) -> Array:
	return _reward_items(int(stage.get("tickets", 0)), int(stage.get("gems", 0)), stage.get("shards", {}))


func preview_reward_hero(stage: Dictionary) -> Dictionary:
	var shards: Dictionary = stage.get("shards", {})
	var best_id: int = 0
	var best_count: int = -1
	for raw_id in shards.keys():
		var shard_count: int = int(shards.get(raw_id, 0))
		if shard_count > best_count:
			best_id = int(raw_id)
			best_count = shard_count
	if best_id > 0:
		return app._hero_by_id(best_id)
	return app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))


func chapter_completed(chapter: Dictionary) -> bool:
	var stages: Array = chapter.get("stages", [])
	if stages.is_empty():
		return false
	var last_stage: Dictionary = stages[stages.size() - 1]
	return int(app.save.get("max_stage_id", 0)) >= int(last_stage.get("id", 0))


func show_dust_exploration() -> void:
	_selected_chapter_index = 0
	_show_dust_exploration_state(current_chapter_state())


func show_dust_exploration_for_chapter(chapter_index: int) -> void:
	_selected_chapter_index = max(chapter_index, 0)
	_show_dust_exploration_state(chapter_state_for_index(_selected_chapter_index))


func _show_selected_chapter_panel() -> void:
	if _selected_chapter_index > 0:
		show_dust_exploration_for_chapter(_selected_chapter_index)
		return
	show_dust_exploration()


func _show_dust_exploration_state(state: Dictionary) -> void:
	_change_to_other_serial += 1
	var current_chapter: Dictionary = state.get("chapter", {})
	var next_stage: Dictionary = state.get("next_stage", {})
	var chapter_id: int = int(current_chapter.get("id", state.get("chapter_index", 1)))
	var meta := _chapter_meta(chapter_id)
	var chapter_complete: bool = chapter_completed(current_chapter)
	var chapter_claimed: bool = _chapter_reward_claimed(chapter_id)
	var chapter_info_pos: Vector2 = Vector2(518, 74)
	var task_pos: Vector2 = Vector2(610, 268)

	app._clear("塵世探秘")
	app._draw_image(UI_CHAPTER_BG, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.94))
	app._draw_image(UI_CHAPTER_SPINE_MASK_BG, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.42))
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.012, 0.018, 0.036, 0.32)))

	var title: Label = app._label("塵世探秘", 38)
	title.position = Vector2(60, 36)
	title.size = Vector2(260, 52)
	title.modulate = Color(1.0, 0.94, 0.72)
	app._view_container().add_child(title)

	_draw_reward_preview(state)

	app._draw_image(UI_CHAPTER_REVIEW_BTN, Vector2(58, 100), Vector2(60, 60), false, Color(1, 1, 1, 0.94))
	var review_text: Label = app._label("獎勵預覽", 14, HORIZONTAL_ALIGNMENT_CENTER)
	review_text.position = Vector2(44, 156)
	review_text.size = Vector2(90, 24)
	review_text.modulate = Color(1.0, 0.94, 0.72)
	app._view_container().add_child(review_text)
	app._add_hit_button(Vector2(44, 96), Vector2(92, 90), show_chapter_reward_detail)

	app._draw_image(UI_CHAPTER_TIP_BAR, Vector2(62, 506), Vector2(420, 126), true, Color(1, 1, 1, 0.88))
	var next_text: String = str(next_stage.get("name", "全部完成"))
	var chapter_reward_hint: String = str(meta.get("descriptionResolved", "領取豐厚獎勵")).strip_edges()
	if chapter_reward_hint.is_empty():
		chapter_reward_hint = "領取豐厚獎勵"
	var tip_text: String = "下一關：%s\n推薦戰力：%d\n%s" % [
		next_text,
		int(next_stage.get("power", 0)),
		chapter_reward_hint,
	]
	if next_stage.is_empty():
		tip_text = "章節進度：已全部完成\n推薦戰力：%d\n%s" % [
			max(app._player_power(), 0),
			chapter_reward_hint,
		]
	var tip: Label = app._label(tip_text, 20)
	tip.position = Vector2(96, 538)
	tip.size = Vector2(300, 70)
	tip.modulate = Color(0.98, 0.93, 0.82)
	app._view_container().add_child(tip)
	app._draw_image(UI_CHAPTER_GO_BTN, Vector2(410, 548), Vector2(54, 54), false, Color(1, 1, 1, 0.94))
	app._add_hit_button(Vector2(398, 536), Vector2(78, 78), app._fight_next_stage)

	app._draw_image(UI_CHAPTER_DIVIDER, chapter_info_pos + Vector2(0, 54), Vector2(586, 8), true, Color(1, 1, 1, 0.82))
	var reward_title: Label = app._label("第%d章·%s" % [
		int(state.get("chapter_index", 1)),
		chapter_display_name(current_chapter, int(state.get("chapter_index", 1))),
	], 25)
	reward_title.position = chapter_info_pos
	reward_title.size = Vector2(360, 34)
	reward_title.modulate = Color(1.0, 0.95, 0.72)
	app._view_container().add_child(reward_title)
	var chapter_progress: Label = app._label("%d/%d" % [
		int(state.get("completed", 0)),
		int(state.get("stage_count", 1)),
	], 24, HORIZONTAL_ALIGNMENT_RIGHT)
	chapter_progress.position = chapter_info_pos + Vector2(520, 0)
	chapter_progress.size = Vector2(64, 34)
	chapter_progress.modulate = Color(0.82, 1.0, 0.45)
	app._view_container().add_child(chapter_progress)
	var rewards: Array = state.get("chapter_rewards", [])
	for index in range(min(rewards.size(), 3)):
		var reward: Dictionary = rewards[index]
		app._draw_home_reward_icon(
			str(reward.get("icon", "")),
			chapter_info_pos + Vector2(270 + index * 82, 70),
			str(reward.get("name", "")),
			str(reward.get("count", ""))
		)
	var claim_pos := chapter_info_pos + Vector2(22, 82)
	if chapter_claimed:
		app._draw_image(UI_CHAPTER_CLAIMED, claim_pos + Vector2(42, -12), Vector2(70, 70), false, Color(1, 1, 1, 0.92))
	else:
		app._draw_image(UI_CHAPTER_FULL_CLAIM_BTN, claim_pos, Vector2(154, 42), true, Color(1, 1, 1, 0.90 if chapter_complete else 0.52))
		var claim_label: Label = app._label("領取" if chapter_complete else "未完成", 22, HORIZONTAL_ALIGNMENT_CENTER)
		claim_label.position = claim_pos + Vector2(0, 6)
		claim_label.size = Vector2(154, 30)
		claim_label.modulate = Color(0.34, 0.20, 0.08) if chapter_complete else Color(0.42, 0.34, 0.28)
		app._view_container().add_child(claim_label)
		if chapter_complete:
			app._add_hit_button(claim_pos, Vector2(154, 42), func() -> void:
				_claim_chapter_reward(chapter_id, current_chapter)
			)

	var chapter_reward_text: String = str(meta.get("rewardDesResolved", "")).strip_edges()
	if chapter_reward_text.is_empty():
		chapter_reward_text = "塵世探秘第%d章節通關獎勵" % int(state.get("chapter_index", 1))
	var reward_desc: Label = app._label(chapter_reward_text, 15)
	reward_desc.position = chapter_info_pos + Vector2(184, 118)
	reward_desc.size = Vector2(392, 22)
	reward_desc.modulate = Color(0.90, 0.86, 0.80, 0.94)
	app._view_container().add_child(reward_desc)

	app._draw_image(UI_CHAPTER_DIVIDER, Vector2(596, 246), Vector2(604, 8), true, Color(1, 1, 1, 0.76))
	var visible_tasks: Array = _visible_tasks()
	var task_title: Label = app._label("章節任務", 25)
	task_title.position = Vector2(616, 214)
	task_title.size = Vector2(220, 34)
	task_title.modulate = Color(1.0, 0.94, 0.72)
	app._view_container().add_child(task_title)
	var task_count_label: Label = app._label("%d/%d" % [_completed_task_count(), app.tasks.size()], 18, HORIZONTAL_ALIGNMENT_RIGHT)
	task_count_label.position = Vector2(1038, 218)
	task_count_label.size = Vector2(132, 28)
	task_count_label.modulate = Color(0.82, 1.0, 0.45)
	app._view_container().add_child(task_count_label)
	var claimed: Dictionary = app.save.get("claimed_tasks", {})
	for index in range(min(visible_tasks.size(), 5)):
		var task: Dictionary = visible_tasks[index]
		draw_chapter_task_cell(task, task_pos + Vector2(0, index * 92), 0.77, bool(claimed.get(str(task.get("id", "")), false)))
	app._add_action_button("返回主界面", Vector2(60, 652), app._show_home, Vector2(146, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("挑戰", Vector2(222, 652), app._fight_next_stage, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("戰役詳情", Vector2(370, 652), app._show_battle, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func _draw_change_to_other() -> void:
	app._draw_image(UI_CTO_DI, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.90))
	app._draw_image(UI_CTO_DARK, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.96))
	_add_rotating_layer(UI_CTO_CLOCK13, Vector2(58, -42), Vector2(490, 490), 17.0, Color(1.0, 0.92, 0.72, 0.05))
	_add_rotating_layer(UI_CTO_CLOCK13, Vector2(742, 292), Vector2(490, 490), -15.0, Color(1.0, 0.92, 0.72, 0.05))
	_add_rotating_layer(UI_CTO_CLOCK13, Vector2(856, -84), Vector2(490, 490), 12.0, Color(1.0, 0.92, 0.72, 0.04))
	_add_rotating_layer(UI_CTO_CLOCK13, Vector2(-86, 252), Vector2(490, 490), -11.0, Color(1.0, 0.92, 0.72, 0.04))
	_add_rotating_layer(UI_CTO_CLOCK12, Vector2(186, 235), Vector2(138, 138), -28.0, Color(1.0, 0.92, 0.72, 0.04))
	_add_rotating_layer(UI_CTO_CLOCK12, Vector2(964, 344), Vector2(138, 138), 28.0, Color(1.0, 0.92, 0.72, 0.04))

	# Main clock stack from ChangeToOther.prefab.
	var main_outer := _add_rotating_layer(UI_CTO_CLOCK14, Vector2(152, -280), Vector2(976, 976), -18.0, Color(1.0, 0.92, 0.74, 0.92))
	var main_glow_back := _add_rotating_layer(UI_CTO_CLOCK10, Vector2(152, -280), Vector2(976, 976), 22.0, Color(1, 1, 1, 0.15))
	var main_glow_front := _add_rotating_layer(UI_CTO_CLOCK10, Vector2(152, -280), Vector2(976, 976), -11.0, Color(1, 1, 1, 0.70))
	var mid_ring := _add_rotating_layer(UI_CTO_CLOCK08, Vector2(287, -103), Vector2(706, 706), 14.0, Color(1, 1, 1, 0.98))
	var dial_ring := _add_rotating_layer(UI_CTO_CLOCK11, Vector2(352, -18), Vector2(576, 576), -9.0, Color(1, 1, 1, 0.98))
	var gear_a := _add_rotating_layer(UI_CTO_CLOCK09, Vector2(397, 27), Vector2(486, 486), 32.0, Color(1, 1, 1, 0.92))
	var gear_b := _add_rotating_layer(UI_CTO_GD1, Vector2(397, 27), Vector2(486, 486), -41.0, Color(1.0, 0.96, 0.88, 0.92))
	var gear_c := _add_rotating_layer(UI_CTO_GD2, Vector2(397, 27), Vector2(486, 486), 21.0, Color(1.0, 0.96, 0.88, 0.88))
	var core_a := _add_rotating_layer(UI_CTO_CLOCK07, Vector2(458, 88), Vector2(364, 364), -17.0, Color(1, 1, 1, 1))
	var core_b := _add_rotating_layer(UI_CTO_CLOCK07, Vector2(458, 88), Vector2(364, 364), 9.0, Color(1, 1, 1, 0.85))
	var core_shiny := _add_rotating_layer(UI_CTO_CLOCK07B, Vector2(458, 88), Vector2(364, 364), -30.0, Color(1, 1, 1, 0.96))
	var core_dark := _add_rotating_layer(UI_CTO_CLOCK07C, Vector2(458, 88), Vector2(364, 364), 0.0, Color(0.82, 0.82, 0.82, 1.0))
	var core_light := _add_rotating_layer(UI_CTO_CLOCK07C, Vector2(458, 88), Vector2(364, 364), 24.0, Color(1, 1, 1, 1.0))
	var center_a := _add_rotating_layer(UI_CTO_CLOCK06, Vector2(497, 127), Vector2(286, 286), 18.0, Color(1, 1, 1, 1.0))
	var center_b := _add_rotating_layer(UI_CTO_CLOCK06A, Vector2(497, 127), Vector2(286, 286), -22.0, Color(1, 1, 1, 0.92))
	app._draw_image(UI_CTO_CLOCK05, Vector2(551, 181), Vector2(178, 178), false, Color(1, 1, 1, 1.0))
	app._draw_image(UI_CTO_CLOCK04, Vector2(585, 215), Vector2(110, 110), false, Color(1, 1, 1, 1.0))
	app._draw_image(UI_CTO_CLOCK01, Vector2(596, 226), Vector2(88, 88), false, Color(1, 1, 1, 1.0))
	var pointer_left := _add_rotating_layer(UI_CTO_CLOCK02, Vector2(518, 237), Vector2(164, 68), 36.0, Color(1, 1, 1, 0.94))
	var pointer_right := _add_rotating_layer(UI_CTO_CLOCK03, Vector2(600, 250), Vector2(184, 48), -28.0, Color(1, 1, 1, 0.94))
	var light1: TextureRect = app._draw_image(UI_CTO_LIGHT1, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.90))
	var light2: TextureRect = app._draw_image(UI_CTO_LIGHT2, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.22))
	_pulse_node(main_outer, 1.018, 0.82)
	_pulse_node(main_glow_front, 1.030, 0.64)
	_pulse_node(mid_ring, 1.016, 0.76)
	_pulse_node(dial_ring, 1.020, 0.92)
	_pulse_node(gear_a, 1.022, 0.68)
	_pulse_node(gear_b, 1.026, 0.72)
	_pulse_node(gear_c, 1.018, 0.88)
	_pulse_node(core_a, 1.030, 0.58)
	_pulse_node(center_a, 1.022, 0.70)
	_shimmer_alpha(core_shiny, 0.62, 0.98, 0.54)
	_shimmer_alpha(core_light, 0.42, 1.0, 0.66)
	_shimmer_alpha(center_b, 0.54, 0.98, 0.48)
	_shimmer_alpha(pointer_left, 0.58, 1.0, 0.52)
	_shimmer_alpha(pointer_right, 0.58, 1.0, 0.56)
	_shimmer_alpha(light1, 0.68, 0.92, 0.70)
	_shimmer_alpha(light2, 0.06, 0.24, 0.62)
	_float_y(gear_b, 4.0, 0.84)
	_float_y(gear_c, -4.0, 0.94)
	_float_y(light1, -6.0, 0.90)
	_float_y(light2, 5.0, 1.02)

	var tip: Label = app._label("塵世探秘", 26, HORIZONTAL_ALIGNMENT_CENTER)
	tip.position = Vector2(0, 620)
	tip.size = Vector2(app.CANVAS_WIDTH, 32)
	tip.modulate = Color(1.0, 0.95, 0.80, 0.92)
	app._view_container().add_child(tip)
	var sub_tip: Label = app._label("載入章節與過渡場景...", 16, HORIZONTAL_ALIGNMENT_CENTER)
	sub_tip.position = Vector2(0, 652)
	sub_tip.size = Vector2(app.CANVAS_WIDTH, 24)
	sub_tip.modulate = Color(0.96, 0.90, 0.78, 0.72)
	app._view_container().add_child(sub_tip)
	_shimmer_alpha(tip, 0.70, 0.96, 0.74)
	_shimmer_alpha(sub_tip, 0.46, 0.76, 0.66)


func _add_rotating_layer(path: String, pos: Vector2, size: Vector2, speed_deg: float, tint: Color) -> TextureRect:
	var rect: TextureRect = app._draw_image(path, pos, size, false, tint)
	if rect == null:
		return null
	rect.pivot_offset = size * 0.5
	if abs(speed_deg) > 0.01:
		var tween: Tween = rect.create_tween()
		tween.set_loops()
		tween.tween_property(rect, "rotation_degrees", speed_deg, 1.0).as_relative().set_trans(Tween.TRANS_LINEAR)
	return rect


func _pulse_node(node: CanvasItem, scale_peak: float, duration: float) -> void:
	if node == null:
		return
	var control := node as Control
	if control == null:
		return
	control.scale = Vector2.ONE
	var tween: Tween = control.create_tween()
	tween.set_loops()
	tween.tween_property(control, "scale", Vector2.ONE * scale_peak, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _shimmer_alpha(node: CanvasItem, min_alpha: float, max_alpha: float, duration: float) -> void:
	if node == null:
		return
	var tween: Tween = node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate:a", max_alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", min_alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _float_y(node: CanvasItem, delta_y: float, duration: float) -> void:
	if node == null:
		return
	var control := node as Control
	if control == null:
		return
	var base_y: float = control.position.y
	var tween: Tween = control.create_tween()
	tween.set_loops()
	tween.tween_property(control, "position:y", base_y + delta_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "position:y", base_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _draw_reward_preview(state: Dictionary) -> void:
	var preview_stage: Dictionary = state.get("preview_stage", {})
	var preview_hero: Dictionary = state.get("preview_hero", {})
	var preview_rewards: Array = state.get("preview_rewards", [])
	var current_chapter: Dictionary = state.get("chapter", {})
	var chapter_id: int = int(current_chapter.get("id", state.get("chapter_index", 1)))
	var meta := _chapter_meta(chapter_id)
	var frame_outer: ColorRect = app._panel(Vector2(36, 76), Vector2(430, 396), Color(0.020, 0.030, 0.056, 0.28))
	var frame_inner: ColorRect = app._panel(Vector2(42, 82), Vector2(418, 384), Color(0.010, 0.016, 0.034, 0.40))
	app._view_container().add_child(frame_outer)
	app._view_container().add_child(frame_inner)
	app._draw_image(UI_CHAPTER_DIVIDER, Vector2(128, 126), Vector2(280, 8), true, Color(1, 1, 1, 0.46))

	var preview_title: Label = app._label("關卡預覽", 22)
	preview_title.position = Vector2(146, 92)
	preview_title.size = Vector2(180, 28)
	preview_title.modulate = Color(1.0, 0.95, 0.76)
	app._view_container().add_child(preview_title)
	var preview_name: Label = app._label(str(preview_stage.get("name", "章節完成")), 18)
	preview_name.position = Vector2(146, 128)
	preview_name.size = Vector2(248, 26)
	preview_name.modulate = Color(0.92, 0.86, 0.82)
	app._view_container().add_child(preview_name)
	var preview_desc: Label = app._label(str(meta.get("rewardDesResolved", "塵世探秘首通獎勵")), 15)
	preview_desc.position = Vector2(146, 152)
	preview_desc.size = Vector2(246, 40)
	preview_desc.modulate = Color(0.92, 0.84, 0.72, 0.90)
	app._view_container().add_child(preview_desc)

	if not preview_hero.is_empty():
		app._view_container().add_child(app._panel(Vector2(68, 184), Vector2(296, 188), Color(0.060, 0.086, 0.160, 0.46)))
		app._view_container().add_child(app._panel(Vector2(84, 198), Vector2(264, 158), Color(0.020, 0.030, 0.068, 0.52)))
		app._draw_hero_thumb(preview_hero, Vector2(92, 150), Vector2(252, 236), Color(1, 1, 1, 0.96))
		app._draw_image(UI_CHAPTER_ROLE_MASK, Vector2(58, 148), Vector2(324, 274), false, Color(1, 1, 1, 0.82))
		var hero_name: Label = app._label(str(preview_hero.get("name", "幻靈")), 22, HORIZONTAL_ALIGNMENT_CENTER)
		hero_name.position = Vector2(82, 358)
		hero_name.size = Vector2(268, 26)
		hero_name.modulate = Color(1.0, 0.95, 0.76)
		app._view_container().add_child(hero_name)

	var reward_x: float = 74.0
	for index in range(min(preview_rewards.size(), 3)):
		var reward: Dictionary = preview_rewards[index]
		app._draw_home_reward_icon(str(reward.get("icon", "")), Vector2(reward_x, 388), str(reward.get("name", "")), str(reward.get("count", "")))
		reward_x += 86.0
	var reward_hint: Label = app._label("本區預覽依 manifest 已落地的角色與獎勵貼圖重建。", 14)
	reward_hint.position = Vector2(62, 486)
	reward_hint.size = Vector2(360, 22)
	reward_hint.modulate = Color(0.88, 0.86, 0.82, 0.86)
	app._view_container().add_child(reward_hint)
	var afk_hint: Label = app._label("塵世探秘掛機收益：%s" % app._afk_time_display(), 14)
	afk_hint.position = Vector2(62, 506)
	afk_hint.size = Vector2(300, 20)
	afk_hint.modulate = Color(0.94, 0.86, 0.60, 0.86)
	app._view_container().add_child(afk_hint)


func draw_chapter_task_cell(task: Dictionary, pos: Vector2, scale: float = 1.0, is_claimed: bool = false) -> void:
	var cell_size: Vector2 = Vector2(786, 118) * scale
	app._draw_image(UI_CHAPTER_TASK_CELL_BG, pos, cell_size, true, Color(1, 1, 1, 0.92))
	var task_id: String = str(task.get("id", ""))
	var progress: int = app._task_progress(task_id)
	var target: int = max(int(task.get("target", 1)), 1)
	var done: bool = progress >= target
	var title: Label = app._label(str(task.get("desc", task.get("name", ""))), int(22 * scale))
	title.position = pos + Vector2(34, 18) * scale
	title.size = Vector2(340, 28) * scale
	title.modulate = Color(0.18, 0.16, 0.22)
	app._view_container().add_child(title)
	var bar_pos: Vector2 = pos + Vector2(128, 70) * scale
	var bar_size: Vector2 = Vector2(210, 12) * scale
	app._draw_image(UI_CHAPTER_TASK_PROGRESS_BG, bar_pos, bar_size, true, Color(1, 1, 1, 0.88))
	var fill_size: Vector2 = Vector2(bar_size.x * clamp(float(progress) / float(target), 0.0, 1.0), bar_size.y)
	app._draw_image(UI_CHAPTER_TASK_PROGRESS_FILL, bar_pos, fill_size, true, Color(1, 1, 1, 0.94))
	var num: Label = app._label("%d/%d" % [min(progress, target), target], int(18 * scale), HORIZONTAL_ALIGNMENT_CENTER)
	num.position = pos + Vector2(314, 62) * scale
	num.size = Vector2(60, 24) * scale
	num.modulate = Color(0.34, 0.28, 0.76)
	app._view_container().add_child(num)
	var reward_x: float = pos.x + 390.0 * scale
	app._draw_home_reward_icon(UI_ITEM_TICKET, Vector2(reward_x, pos.y + 12.0 * scale), "", "x%d" % int(task.get("tickets", 0)))
	app._draw_home_reward_icon(UI_ITEM_GEM, Vector2(reward_x + 70.0 * scale, pos.y + 12.0 * scale), "", "x%d" % int(task.get("gems", 0)))
	if is_claimed:
		app._draw_image(UI_CHAPTER_CLAIMED, pos + Vector2(690, 24) * scale, Vector2(70, 70) * scale, false, Color(1, 1, 1, 0.92))
	elif done:
		var btn_pos: Vector2 = pos + Vector2(630, 30) * scale
		app._draw_image(UI_CHAPTER_TASK_CLAIM_BTN, btn_pos, Vector2(140, 38) * scale, true, Color(1, 1, 1, 0.92))
		var claim: Label = app._label("領取", int(20 * scale), HORIZONTAL_ALIGNMENT_CENTER)
		claim.position = btn_pos + Vector2(0, 6) * scale
		claim.size = Vector2(140, 24) * scale
		claim.modulate = Color(0.30, 0.20, 0.08)
		app._view_container().add_child(claim)
		app._add_hit_button(btn_pos, Vector2(140, 38) * scale, func(id := task_id, tickets := int(task.get("tickets", 0)), gems := int(task.get("gems", 0))) -> void:
			var task_claimed: Dictionary = app.save.get("claimed_tasks", {})
			task_claimed[id] = true
			app.save["claimed_tasks"] = task_claimed
			app._grant_reward(tickets, gems)
			show_dust_exploration()
		)
	else:
		var status: Label = app._label("進行中", int(18 * scale), HORIZONTAL_ALIGNMENT_CENTER)
		status.position = pos + Vector2(642, 42) * scale
		status.size = Vector2(110, 28) * scale
		status.modulate = Color(0.38, 0.36, 0.46)
		app._view_container().add_child(status)


func show_chapter_reward_detail() -> void:
	app._clear("章節獎勵詳情")
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.006, 0.008, 0.016, 0.72)))
	app._draw_image(UI_CHAPTER_REWARD_DETAIL_BG, Vector2(125, 55), Vector2(1030, 610), true, Color(1, 1, 1, 0.96))
	var title: Label = app._label("章節獎勵詳情", 26)
	title.position = Vector2(206, 96)
	title.size = Vector2(260, 36)
	title.modulate = Color(1.0, 0.94, 0.72)
	app._view_container().add_child(title)
	app._draw_image(UI_CHAPTER_CLOSE_BTN, Vector2(1081, 82), Vector2(60, 60), false, Color(1, 1, 1, 0.96))
	app._add_hit_button(Vector2(1074, 76), Vector2(72, 72), _show_selected_chapter_panel)
	for index in range(min(app.chapters.size(), 4)):
		var chapter: Dictionary = app.chapters[index]
		var chapter_id: int = int(chapter.get("id", index + 1))
		var meta := _chapter_meta(chapter_id)
		var row_pos: Vector2 = Vector2(150, 160 + index * 110)
		var rewards: Array = chapter_reward_items(chapter)
		var claimed: bool = chapter_completed(chapter)
		var reward_claimed: bool = _chapter_reward_claimed(chapter_id)
		app._draw_image(UI_CHAPTER_REWARD_ROW_BG, row_pos, Vector2(980, 96), true, Color(1, 1, 1, 0.90))
		app._draw_image(UI_CHAPTER_REWARD_ROW_ICON, row_pos + Vector2(18, -2), Vector2(86, 86), false, Color(1, 1, 1, 0.88))
		var label: Label = app._label("通關第%d章·%s" % [index + 1, chapter_display_name(chapter, index + 1)], 22)
		label.position = row_pos + Vector2(126, 18)
		label.size = Vector2(280, 30)
		label.modulate = Color(0.25, 0.22, 0.28)
		app._view_container().add_child(label)
		var tip_text: String = str(meta.get("rewardDesResolved", "")).strip_edges()
		if tip_text.is_empty():
			tip_text = "已完成" if claimed else "未完成 %d/%d" % [_completed_stages_in_chapter(chapter), max(chapter.get("stages", []).size(), 1)]
		var tip: Label = app._label(tip_text, 18)
		tip.position = row_pos + Vector2(126, 48)
		tip.size = Vector2(280, 24)
		tip.modulate = Color(0.42, 0.36, 0.48) if not claimed else Color(0.78, 0.84, 0.22)
		app._view_container().add_child(tip)
		for reward_index in range(min(rewards.size(), 3)):
			var reward: Dictionary = rewards[reward_index]
			app._draw_home_reward_icon(str(reward.get("icon", "")), row_pos + Vector2(450 + reward_index * 90, 0), "", str(reward.get("count", "")))
		if reward_claimed:
			app._draw_image(UI_CHAPTER_CLAIMED, row_pos + Vector2(842, 14), Vector2(70, 70), false, Color(1, 1, 1, 0.88))
		else:
			var state_text: String = "可領取" if claimed else "未達成"
			var state_label: Label = app._label(state_text, 18, HORIZONTAL_ALIGNMENT_CENTER)
			state_label.position = row_pos + Vector2(822, 34)
			state_label.size = Vector2(100, 24)
			state_label.modulate = Color(0.72, 0.56, 0.24) if claimed else Color(0.42, 0.36, 0.48)
			app._view_container().add_child(state_label)


func _reward_items(tickets: int, gems: int, shards: Dictionary) -> Array:
	var items: Array = []
	if tickets > 0:
		items.append({"icon": UI_ITEM_TICKET, "name": "喚靈券", "count": "x%d" % tickets})
	var shard_total: int = 0
	for raw_id in shards.keys():
		shard_total += int(shards.get(raw_id, 0))
	if shard_total > 0:
		items.append({"icon": UI_ITEM_SHARD, "name": "碎片", "count": "x%d" % shard_total})
	if gems > 0:
		items.append({"icon": UI_ITEM_GEM, "name": "源石", "count": "x%d" % gems})
	return items


func _merge_shards(target: Dictionary, source: Dictionary) -> void:
	for raw_id in source.keys():
		var key: String = str(raw_id)
		target[key] = int(target.get(key, 0)) + int(source.get(raw_id, 0))


func _completed_stages_in_chapter(chapter: Dictionary) -> int:
	var completed: int = 0
	for stage in chapter.get("stages", []):
		if int(stage.get("id", 0)) <= int(app.save.get("max_stage_id", 0)):
			completed += 1
	return completed


func _chapter_meta(chapter_id: int) -> Dictionary:
	return chapter_meta.get(str(chapter_id), chapter_meta.get(str(int(chapter_id) + 1), {}))


func _visible_tasks() -> Array:
	var items: Array = []
	var claimed: Dictionary = app.save.get("claimed_tasks", {})
	for task in app.tasks:
		var task_id: String = str(task.get("id", ""))
		var progress: int = app._task_progress(task_id)
		var target: int = max(int(task.get("target", 1)), 1)
		var is_claimed: bool = bool(claimed.get(task_id, false))
		var done: bool = progress >= target
		var rank: int = 2
		if not is_claimed and done:
			rank = 0
		elif not is_claimed:
			rank = 1
		items.append({
			"task": task,
			"rank": rank,
			"progress": progress,
			"target": target,
			"is_claimed": is_claimed,
		})
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("rank", 0)) != int(b.get("rank", 0)):
			return int(a.get("rank", 0)) < int(b.get("rank", 0))
		var a_ratio: float = float(a.get("progress", 0)) / max(float(a.get("target", 1)), 1.0)
		var b_ratio: float = float(b.get("progress", 0)) / max(float(b.get("target", 1)), 1.0)
		if abs(a_ratio - b_ratio) > 0.001:
			return a_ratio > b_ratio
		return str(a.get("task", {}).get("id", "")) < str(b.get("task", {}).get("id", ""))
	)
	var result: Array = []
	for item in items:
		result.append(item.get("task", {}))
	return result


func _completed_task_count() -> int:
	var count: int = 0
	for task in app.tasks:
		var task_id: String = str(task.get("id", ""))
		if app._task_progress(task_id) >= max(int(task.get("target", 1)), 1):
			count += 1
	return count


func _chapter_reward_claimed(chapter_id: int) -> bool:
	return bool(app.save.get("claimed_chapter_rewards", {}).get(str(chapter_id), false))


func _claim_chapter_reward(chapter_id: int, chapter: Dictionary) -> void:
	if _chapter_reward_claimed(chapter_id):
		app._show_battle("本章節獎勵已領取。")
		return
	if not chapter_completed(chapter):
		app._show_battle("尚未通關當前章節，無法領取章節獎勵。")
		return
	var total_tickets: int = 0
	var total_gems: int = 0
	var total_shards: Dictionary = {}
	for stage in chapter.get("stages", []):
		total_tickets += int(stage.get("tickets", 0))
		total_gems += int(stage.get("gems", 0))
		_merge_shards(total_shards, stage.get("shards", {}))
	var claimed: Dictionary = app.save.get("claimed_chapter_rewards", {})
	claimed[str(chapter_id)] = true
	app.save["claimed_chapter_rewards"] = claimed
	app._grant_reward(total_tickets, total_gems)
	app._grant_shards(total_shards)
	app._persist()
	show_dust_exploration()


func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		return {}
	var parsed = JSON.parse_string(text)
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
