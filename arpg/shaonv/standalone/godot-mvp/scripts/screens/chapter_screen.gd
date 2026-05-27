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

var app

func _init(app_ref) -> void:
	app = app_ref


func current_chapter_state() -> Dictionary:
	var next_stage: Dictionary = app._next_stage()
	var max_stage_id: int = int(app.save.get("max_stage_id", 0))
	var next_stage_id: int = int(next_stage.get("id", 0))
	var current_chapter: Dictionary = {}
	var current_chapter_index: int = 1
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
	var preview_stage: Dictionary = next_stage
	if preview_stage.is_empty() and not current_stages.is_empty():
		preview_stage = current_stages[current_stages.size() - 1]
	return {
		"chapter": current_chapter,
		"chapter_index": current_chapter_index,
		"completed": completed,
		"stage_count": max(stage_count, 1),
		"next_stage": next_stage,
		"preview_stage": preview_stage,
		"chapter_rewards": chapter_reward_items(current_chapter),
		"preview_rewards": stage_reward_items(preview_stage),
		"preview_hero": preview_reward_hero(preview_stage),
	}


func chapter_display_name(chapter: Dictionary, fallback_index: int = 1) -> String:
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
	var state: Dictionary = current_chapter_state()
	var current_chapter: Dictionary = state.get("chapter", {})
	var next_stage: Dictionary = state.get("next_stage", {})
	var chapter_info_pos: Vector2 = Vector2(518, 74)
	var task_pos: Vector2 = Vector2(610, 268)

	app._clear("塵世探秘")
	app._draw_image(UI_CHAPTER_BG, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.94))
	app._draw_image(UI_CHAPTER_SPINE_MASK_BG, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.42))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.018, 0.036, 0.32)))

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
	var tip_text: String = "下一關：%s\n推薦戰力：%d\n掛機收益：%s" % [
		next_text,
		int(next_stage.get("power", 0)),
		app._afk_time_display(),
	]
	if next_stage.is_empty():
		tip_text = "章節進度：已全部完成\n推薦戰力：%d\n掛機收益：%s" % [
			max(app._player_power(), 0),
			app._afk_time_display(),
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
	app._draw_image(UI_CHAPTER_FULL_CLAIM_BTN, chapter_info_pos + Vector2(22, 82), Vector2(154, 42), true, Color(1, 1, 1, 0.90))
	var claim_label: Label = app._label("領取", 22, HORIZONTAL_ALIGNMENT_CENTER)
	claim_label.position = chapter_info_pos + Vector2(22, 88)
	claim_label.size = Vector2(154, 30)
	claim_label.modulate = Color(0.34, 0.20, 0.08)
	app._view_container().add_child(claim_label)
	app._add_hit_button(chapter_info_pos + Vector2(22, 82), Vector2(154, 42), app._claim_afk_reward)

	app._draw_image(UI_CHAPTER_DIVIDER, Vector2(596, 246), Vector2(604, 8), true, Color(1, 1, 1, 0.76))
	var task_title: Label = app._label("章節任務", 25)
	task_title.position = Vector2(616, 214)
	task_title.size = Vector2(220, 34)
	task_title.modulate = Color(1.0, 0.94, 0.72)
	app._view_container().add_child(task_title)
	var claimed: Dictionary = app.save.get("claimed_tasks", {})
	for index in range(min(app.tasks.size(), 4)):
		var task: Dictionary = app.tasks[index]
		draw_chapter_task_cell(task, task_pos + Vector2(0, index * 92), 0.77, bool(claimed.get(str(task.get("id", "")), false)))
	app._add_action_button("返回主界面", Vector2(60, 652), app._show_home, Vector2(146, 44), app.UI_COMMON_BTN_WHITE)
	app._add_action_button("挑戰", Vector2(222, 652), app._fight_next_stage, Vector2(132, 44), app.UI_COMMON_BTN_GOLD)
	app._add_action_button("戰役詳情", Vector2(370, 652), app._show_battle, Vector2(132, 44), app.UI_COMMON_BTN_WHITE)


func _draw_reward_preview(state: Dictionary) -> void:
	var preview_stage: Dictionary = state.get("preview_stage", {})
	var preview_hero: Dictionary = state.get("preview_hero", {})
	var preview_rewards: Array = state.get("preview_rewards", [])
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

	if not preview_hero.is_empty():
		app._view_container().add_child(app._panel(Vector2(68, 160), Vector2(296, 210), Color(0.060, 0.086, 0.160, 0.46)))
		app._view_container().add_child(app._panel(Vector2(84, 176), Vector2(264, 178), Color(0.020, 0.030, 0.068, 0.52)))
		app._draw_hero_thumb(preview_hero, Vector2(92, 136), Vector2(252, 248), Color(1, 1, 1, 0.96))
		app._draw_image(UI_CHAPTER_ROLE_MASK, Vector2(58, 134), Vector2(324, 274), false, Color(1, 1, 1, 0.82))
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
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.006, 0.008, 0.016, 0.72)))
	app._draw_image(UI_CHAPTER_REWARD_DETAIL_BG, Vector2(125, 55), Vector2(1030, 610), true, Color(1, 1, 1, 0.96))
	var title: Label = app._label("章節獎勵詳情", 26)
	title.position = Vector2(206, 96)
	title.size = Vector2(260, 36)
	title.modulate = Color(1.0, 0.94, 0.72)
	app._view_container().add_child(title)
	app._draw_image(UI_CHAPTER_CLOSE_BTN, Vector2(1081, 82), Vector2(60, 60), false, Color(1, 1, 1, 0.96))
	app._add_hit_button(Vector2(1074, 76), Vector2(72, 72), show_dust_exploration)
	for index in range(min(app.chapters.size(), 4)):
		var chapter: Dictionary = app.chapters[index]
		var row_pos: Vector2 = Vector2(150, 160 + index * 110)
		var rewards: Array = chapter_reward_items(chapter)
		var claimed: bool = chapter_completed(chapter)
		app._draw_image(UI_CHAPTER_REWARD_ROW_BG, row_pos, Vector2(980, 96), true, Color(1, 1, 1, 0.90))
		app._draw_image(UI_CHAPTER_REWARD_ROW_ICON, row_pos + Vector2(18, -2), Vector2(86, 86), false, Color(1, 1, 1, 0.88))
		var label: Label = app._label("通關第%d章·%s" % [index + 1, chapter_display_name(chapter, index + 1)], 22)
		label.position = row_pos + Vector2(126, 18)
		label.size = Vector2(260, 30)
		label.modulate = Color(0.25, 0.22, 0.28)
		app._view_container().add_child(label)
		var tip: Label = app._label(
			"已完成" if claimed else "未完成 %d/%d" % [_completed_stages_in_chapter(chapter), max(chapter.get("stages", []).size(), 1)],
			18
		)
		tip.position = row_pos + Vector2(126, 48)
		tip.size = Vector2(220, 24)
		tip.modulate = Color(0.42, 0.36, 0.48) if not claimed else Color(0.78, 0.84, 0.22)
		app._view_container().add_child(tip)
		for reward_index in range(min(rewards.size(), 3)):
			var reward: Dictionary = rewards[reward_index]
			app._draw_home_reward_icon(str(reward.get("icon", "")), row_pos + Vector2(450 + reward_index * 90, 0), "", str(reward.get("count", "")))
		if claimed:
			app._draw_image(UI_CHAPTER_CLAIMED, row_pos + Vector2(842, 14), Vector2(70, 70), false, Color(1, 1, 1, 0.88))


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
