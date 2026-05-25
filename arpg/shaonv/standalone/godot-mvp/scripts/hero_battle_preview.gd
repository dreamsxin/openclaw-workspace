# UTF-8 source. Hero battle resource previewer.
extends Node2D

const INDEX_PATH := "res://assets/battle/hero_battle_resources.json"
const BAKED_CANVAS_SCRIPT := preload("res://scripts/spine_baked_preview_canvas.gd")

var heroes: Array = []
var current_index := 0
var clip_index := 0
var clip_names: Array = []
var canvas: Control
var hero_list: VBoxContainer
var resource_list: VBoxContainer
var info_label: Label
var clip_label: Label
var status_label: Label
var counts_label: Label


func _ready() -> void:
	position = Vector2.ZERO
	_load_index()
	_build_ui()
	if heroes.size() > 0:
		var start_index := _initial_hero_index()
		_select_hero(start_index)
	else:
		status_label.text = "未找到战斗资源索引: %s" % INDEX_PATH
	if not OS.get_environment("SHAONV_MVP_CAPTURE").is_empty():
		call_deferred("_capture_debug_screenshot")


func _load_index() -> void:
	if not FileAccess.file_exists(INDEX_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(INDEX_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var next_heroes = parsed.get("heroes", [])
	if next_heroes is Array:
		heroes = next_heroes


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.045, 0.052, 0.082)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var glow := ColorRect.new()
	glow.color = Color(0.12, 0.18, 0.30, 0.38)
	glow.position = Vector2(214, 34)
	glow.size = Vector2(690, 520)
	add_child(glow)

	var left_panel := ColorRect.new()
	left_panel.color = Color(0.08, 0.09, 0.14, 0.96)
	left_panel.size = Vector2(236, 720)
	add_child(left_panel)

	var right_panel := ColorRect.new()
	right_panel.color = Color(0.08, 0.09, 0.14, 0.90)
	right_panel.position = Vector2(918, 0)
	right_panel.size = Vector2(362, 720)
	add_child(right_panel)

	add_child(_label("战斗动画 / 资源预览", 20, Vector2(12, 10), Vector2(212, 34), HORIZONTAL_ALIGNMENT_CENTER))
	counts_label = _label("", 13, Vector2(12, 42), Vector2(212, 24), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(counts_label)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(8, 76)
	scroll.size = Vector2(220, 634)
	add_child(scroll)

	hero_list = VBoxContainer.new()
	hero_list.name = "HeroBattleList"
	hero_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(hero_list)

	for index in heroes.size():
		var hero: Dictionary = heroes[index]
		var btn := Button.new()
		btn.text = "%s  %s" % [hero.get("name", "?"), hero.get("qKey", "?")]
		btn.tooltip_text = "id=%s spine=%s" % [hero.get("heroId", ""), hero.get("spine", "")]
		btn.custom_minimum_size = Vector2(0, 36)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.name = "hero_%d" % index
		btn.pressed.connect(_select_hero.bind(index))
		hero_list.add_child(btn)

	canvas = Control.new()
	canvas.name = "BattlePreviewCanvas"
	canvas.position = Vector2(246, 58)
	canvas.size = Vector2(650, 510)
	add_child(canvas)

	info_label = _label("", 22, Vector2(252, 12), Vector2(624, 34))
	add_child(info_label)
	clip_label = _label("", 16, Vector2(252, 590), Vector2(450, 24))
	add_child(clip_label)
	status_label = _label("", 14, Vector2(252, 622), Vector2(430, 56))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(status_label)

	_button("上一动作", Vector2(706, 584), _clip_prev, 78, 34)
	_button("播放/暂停", Vector2(792, 584), _toggle_play, 88, 34)
	_button("下一动作", Vector2(706, 626), _clip_next, 78, 34)
	_button("翻转", Vector2(792, 626), _flip, 88, 34)
	_button("上个角色", Vector2(604, 668), _prev_hero, 86, 34)
	_button("下个角色", Vector2(700, 668), _next_hero, 86, 34)

	add_child(_label("战斗资源清单", 20, Vector2(936, 12), Vector2(316, 34), HORIZONTAL_ALIGNMENT_CENTER))
	var hint := _label("hero_xxxq prefab / Skill prefab / Battle wav", 12, Vector2(936, 44), Vector2(316, 24), HORIZONTAL_ALIGNMENT_CENTER)
	hint.modulate = Color(0.72, 0.78, 0.86, 0.88)
	add_child(hint)

	var resource_scroll := ScrollContainer.new()
	resource_scroll.position = Vector2(930, 78)
	resource_scroll.size = Vector2(338, 632)
	add_child(resource_scroll)

	resource_list = VBoxContainer.new()
	resource_list.name = "BattleResourceList"
	resource_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_scroll.add_child(resource_list)

	var summary_prefabs := 0
	var summary_skill := 0
	var summary_sounds := 0
	var baked_count := 0
	for hero in heroes:
		summary_prefabs += (hero.get("prefabs3d", []) as Array).size()
		summary_skill += (hero.get("skillPrefabs", []) as Array).size()
		summary_sounds += (hero.get("sounds", []) as Array).size()
		if bool(hero.get("bakedExists", false)):
			baked_count += 1
	counts_label.text = "%d 角色  %d 预览" % [heroes.size(), baked_count]
	status_label.text = "prefab=%d  skill=%d  wav=%d" % [summary_prefabs, summary_skill, summary_sounds]


func _initial_hero_index() -> int:
	var wanted := OS.get_environment("SHAONV_MVP_HERO_ID")
	if wanted.is_empty():
		wanted = OS.get_environment("SHAONV_MVP_HERO")
	if wanted.is_empty():
		return 0
	for index in heroes.size():
		var hero: Dictionary = heroes[index]
		if str(hero.get("heroId", "")) == wanted or str(hero.get("spine", "")) == wanted or str(hero.get("qKey", "")) == wanted:
			return index
	return 0


func _select_hero(index: int) -> void:
	if index < 0 or index >= heroes.size():
		return
	current_index = index
	clip_index = 0
	for child in canvas.get_children():
		child.queue_free()
	for child in resource_list.get_children():
		child.queue_free()

	var hero: Dictionary = heroes[current_index]
	clip_names = hero.get("clips", [])
	info_label.text = "%s  [%s]  id=%d  spine=%s" % [
		hero.get("name", "?"),
		hero.get("qKey", "?"),
		int(hero.get("heroId", 0)),
		hero.get("spine", "?"),
	]
	_update_hero_buttons()
	_render_baked_preview(hero)
	_render_resources(hero)
	_update_labels()


func _render_baked_preview(hero: Dictionary) -> void:
	var baked_path := str(hero.get("baked", ""))
	if baked_path.is_empty() or not FileAccess.file_exists(baked_path):
		var missing := _label("暂无可播放本体 Spine baked 预览", 20, Vector2.ZERO, canvas.size, HORIZONTAL_ALIGNMENT_CENTER)
		missing.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		canvas.add_child(missing)
		return
	var baked := Control.new()
	baked.set_script(BAKED_CANVAS_SCRIPT)
	baked.name = "Baked"
	baked.position = Vector2.ZERO
	baked.size = canvas.size
	canvas.add_child(baked)
	var preferred_clip := str(clip_names[0]) if clip_names.size() > 0 else ""
	baked.set_baked_path(baked_path, preferred_clip)


func _render_resources(hero: Dictionary) -> void:
	_add_resource_section("3D Prefabs", hero.get("prefabs3d", []))
	_add_resource_section("Skill Prefabs", hero.get("skillPrefabs", []))
	_add_resource_section("Battle Sounds", hero.get("sounds", []))


func _add_resource_section(title: String, items_value) -> void:
	var items: Array = items_value if items_value is Array else []
	var header := _label("%s (%d)" % [title, items.size()], 16, Vector2.ZERO, Vector2(318, 28))
	header.modulate = Color(0.98, 0.86, 0.54)
	resource_list.add_child(header)
	if items.is_empty():
		var empty := _label("  无资源", 13, Vector2.ZERO, Vector2(318, 24))
		empty.modulate = Color(0.58, 0.62, 0.70)
		resource_list.add_child(empty)
		return
	for item in items:
		var entry: Dictionary = item
		var btn := Button.new()
		btn.text = _resource_title(entry)
		btn.tooltip_text = "%s\n%s" % [entry.get("address", ""), entry.get("physicalPath", "")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 32)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_select_resource.bind(entry))
		resource_list.add_child(btn)


func _select_resource(entry: Dictionary) -> void:
	status_label.text = "选中: %s\n%s" % [entry.get("name", ""), entry.get("address", "")]


func _resource_title(entry: Dictionary) -> String:
	var name := str(entry.get("name", ""))
	var exists := "✓" if bool(entry.get("physicalExists", false)) else "!"
	var size_kb := int(round(float(entry.get("fileSize", 0)) / 1024.0))
	return "%s  %s  %dKB" % [exists, name, size_kb]


func _clip_next() -> void:
	if clip_names.size() <= 1:
		return
	clip_index = (clip_index + 1) % clip_names.size()
	_apply_clip()


func _clip_prev() -> void:
	if clip_names.size() <= 1:
		return
	clip_index = (clip_index - 1 + clip_names.size()) % clip_names.size()
	_apply_clip()


func _apply_clip() -> void:
	var baked = canvas.get_node_or_null("Baked")
	if baked != null and baked.has_method("set_clip"):
		baked.set_clip(str(clip_names[clip_index]))
		baked.set_playing(true)
	_update_labels()


func _toggle_play() -> void:
	var baked = canvas.get_node_or_null("Baked")
	if baked != null and baked.has_method("set_playing"):
		baked.set_playing(not bool(baked.get("playing")))


func _flip() -> void:
	var baked = canvas.get_node_or_null("Baked")
	if baked != null:
		baked.scale.x *= -1.0


func _prev_hero() -> void:
	if heroes.is_empty():
		return
	_select_hero((current_index - 1 + heroes.size()) % heroes.size())


func _next_hero() -> void:
	if heroes.is_empty():
		return
	_select_hero((current_index + 1) % heroes.size())


func _update_labels() -> void:
	if heroes.is_empty():
		return
	var hero: Dictionary = heroes[current_index]
	var prefab_count := (hero.get("prefabs3d", []) as Array).size()
	var skill_count := (hero.get("skillPrefabs", []) as Array).size()
	var sound_count := (hero.get("sounds", []) as Array).size()
	if clip_names.size() > 0:
		clip_label.text = "本体 Spine clip [%d/%d]: %s" % [clip_index + 1, clip_names.size(), clip_names[clip_index]]
	else:
		clip_label.text = "本体 Spine clip: 无"
	status_label.text = "角色 %d/%d；%s 的 prefab/音效在右侧，中间播放本体 Spine。" % [
		current_index + 1,
		heroes.size(),
		hero.get("qKey", "?"),
	]
	counts_label.text = "3D=%d  Skill=%d  Wav=%d" % [prefab_count, skill_count, sound_count]


func _update_hero_buttons() -> void:
	if hero_list == null:
		return
	for index in hero_list.get_child_count():
		var btn := hero_list.get_child(index) as Button
		if btn == null:
			continue
		btn.disabled = index == current_index


func _label(text: String, size: int, pos: Vector2, sz: Vector2, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = pos
	label.size = sz
	label.modulate = Color(0.91, 0.92, 0.88)
	return label


func _button(text: String, pos: Vector2, cb: Callable, w: float, h: float) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(w, h)
	button.pressed.connect(cb)
	add_child(button)


func _capture_debug_screenshot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		push_warning("Hero battle preview screenshot skipped: headless has no renderable viewport texture.")
		return
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		push_warning("Hero battle preview screenshot skipped: viewport texture is null.")
		return
	var image := viewport_texture.get_image()
	if image == null or image.is_empty():
		push_warning("Hero battle preview screenshot skipped: viewport image is empty.")
		return
	var path := OS.get_environment("SHAONV_MVP_CAPTURE")
	image.save_png(path)
	print("Hero battle preview screenshot saved: %s" % path)
