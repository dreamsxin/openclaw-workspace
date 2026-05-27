extends Node2D

const BAKED_CANVAS_SCRIPT := "res://scripts/spine_baked_preview_canvas.gd"
const ALL_SPINES_INDEX := "res://assets/spine/all_spines_list.json"
const LEGACY_HERO_INDEX := "res://assets/spine/heroes_list.json"

var entries: Array = []
var current_index := 0
var anim_index := 0
var anim_names: Array[String] = []
var skeleton_anim_names: Array[String] = []
var speed := 1.0
var playing := true

var info_label: Label
var anim_label: Label
var status_label: Label
var canvas: Control
var list_box: VBoxContainer


func _ready() -> void:
	position = Vector2.ZERO
	_load_entries()
	_build_ui()
	if not entries.is_empty():
		_select_entry(0)


func _load_entries() -> void:
	entries = _read_all_spines()
	if entries.is_empty():
		entries = _read_legacy_heroes()


func _read_all_spines() -> Array:
	var file := FileAccess.open(ALL_SPINES_INDEX, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Array:
		return []

	var loaded: Array = []
	for item in parsed:
		if not item is Dictionary:
			continue
		var baked_path := String(item.get("baked", ""))
		if baked_path.is_empty() or not FileAccess.file_exists(baked_path):
			continue
		var entry: Dictionary = item.duplicate(true)
		entry["name"] = String(entry.get("name", entry.get("key", "?")))
		entry["label"] = "%s/%s" % [entry.get("category", "Spine"), entry.get("key", "?")]
		entry["baked_path"] = baked_path
		loaded.append(entry)
	return loaded


func _read_legacy_heroes() -> Array:
	var file := FileAccess.open(LEGACY_HERO_INDEX, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Array:
		return []

	var loaded: Array = []
	for item in parsed:
		if not item is Dictionary:
			continue
		var key := String(item.get("key", ""))
		var baked_path := "res://assets/spine/%s/%s.baked.json" % [key, key]
		if not FileAccess.file_exists(baked_path):
			continue
		var entry: Dictionary = item.duplicate(true)
		entry["label"] = "%s [%s]" % [entry.get("name", key), key]
		entry["baked_path"] = baked_path
		loaded.append(entry)
	return loaded


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.09)
	bg.size = Vector2(1670, 750)
	add_child(bg)

	var panel := ColorRect.new()
	panel.color = Color(0.10, 0.08, 0.14, 0.95)
	panel.size = Vector2(260, 750)
	add_child(panel)

	var title := _label("%d Spine" % entries.size(), 20, Vector2(0, 10), Vector2(260, 32), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(title)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(4, 46)
	scroll.size = Vector2(252, 666)
	scroll.name = "SpineScroll"
	add_child(scroll)

	list_box = VBoxContainer.new()
	list_box.name = "SpineList"
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_box)

	for index in entries.size():
		var entry: Dictionary = entries[index]
		var btn := Button.new()
		btn.text = String(entry.get("label", entry.get("key", "?")))
		btn.tooltip_text = String(entry.get("sourceDir", entry.get("baked_path", "")))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 32)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_select_entry.bind(index))
		list_box.add_child(btn)

	canvas = Control.new()
	canvas.position = Vector2(260, 0)
	canvas.size = Vector2(1020, 594)
	canvas.name = "Preview"
	add_child(canvas)

	info_label = _label("", 17, Vector2(270, 598), Vector2(520, 26))
	anim_label = _label("", 15, Vector2(270, 632), Vector2(610, 22))
	status_label = _label("", 14, Vector2(270, 662), Vector2(610, 20))
	add_child(info_label)
	add_child(anim_label)
	add_child(status_label)

	_button("<<", Vector2(890, 598), _clip_prev, 44, 32)
	_button("Play", Vector2(940, 598), _toggle_play, 62, 32)
	_button(">>", Vector2(1008, 598), _clip_next, 44, 32)
	_button("-", Vector2(1062, 598), _speed_down, 36, 32)
	_button("+", Vector2(1104, 598), _speed_up, 36, 32)
	_button("1x", Vector2(1146, 598), _reset_speed, 40, 32)
	_button("Flip", Vector2(1192, 598), _flip, 54, 32)
	_button("<", Vector2(890, 638), _prev_entry, 44, 32)
	_button(">", Vector2(940, 638), _next_entry, 44, 32)


func _select_entry(index: int) -> void:
	if index < 0 or index >= entries.size():
		return
	current_index = index
	anim_index = 0
	speed = 1.0
	playing = true

	for child in canvas.get_children():
		child.queue_free()

	var entry: Dictionary = entries[index]
	var baked_path := String(entry.get("baked_path", entry.get("baked", "")))
	anim_names = _clip_names(baked_path)
	skeleton_anim_names = _skeleton_animation_names(baked_path)
	if anim_names.is_empty():
		anim_label.text = "No baked clips"
		status_label.text = "Missing or empty baked JSON"
		return

	var baked_class = load(BAKED_CANVAS_SCRIPT)
	var preview := Control.new()
	preview.set_script(baked_class)
	preview.position = Vector2.ZERO
	preview.size = canvas.size
	preview.name = "Baked"
	preview.set_baked_path(baked_path, anim_names[0])
	preview.set_playback_speed(speed)
	canvas.add_child(preview)
	_update_labels()


func _clip_names(baked_path: String) -> Array[String]:
	var names: Array[String] = []
	var file := FileAccess.open(baked_path, FileAccess.READ)
	if file == null:
		return names
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return names
	var clips: Dictionary = parsed.get("clips", {})
	for key in clips.keys():
		var clip = clips[key]
		if clip is Dictionary and clip.get("frames", []).size() > 0:
			names.append(String(key))
	return names


func _skeleton_animation_names(baked_path: String) -> Array[String]:
	var names: Array[String] = []
	var file := FileAccess.open(baked_path, FileAccess.READ)
	if file == null:
		return names
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return names
	for animation in parsed.get("skeleton", {}).get("animations", []):
		if animation is Dictionary:
			names.append(String(animation.get("name", "")))
	return names


func _clip_next() -> void:
	if anim_names.size() <= 1:
		return
	anim_index = (anim_index + 1) % anim_names.size()
	_apply_clip()


func _clip_prev() -> void:
	if anim_names.size() <= 1:
		return
	anim_index = (anim_index - 1 + anim_names.size()) % anim_names.size()
	_apply_clip()


func _apply_clip() -> void:
	var preview := canvas.get_node_or_null("Baked") as Control
	if preview != null and preview.has_method("set_clip"):
		preview.set_clip(anim_names[anim_index])
		preview.set_playing(playing)
		preview.set_playback_speed(speed)
	_update_labels()


func _toggle_play() -> void:
	playing = not playing
	var preview := canvas.get_node_or_null("Baked") as Control
	if preview != null and preview.has_method("set_playing"):
		preview.set_playing(playing)
	_update_labels()


func _speed_up() -> void:
	speed = minf(speed * 1.25, 4.0)
	_apply_speed()


func _speed_down() -> void:
	speed = maxf(speed / 1.25, 0.25)
	_apply_speed()


func _reset_speed() -> void:
	speed = 1.0
	_apply_speed()


func _apply_speed() -> void:
	var preview := canvas.get_node_or_null("Baked") as Control
	if preview != null and preview.has_method("set_playback_speed"):
		preview.set_playback_speed(speed)
	_update_labels()


func _flip() -> void:
	var preview := canvas.get_node_or_null("Baked") as Control
	if preview != null:
		preview.scale.x *= -1.0


func _prev_entry() -> void:
	if entries.is_empty():
		return
	_select_entry((current_index - 1 + entries.size()) % entries.size())


func _next_entry() -> void:
	if entries.is_empty():
		return
	_select_entry((current_index + 1) % entries.size())


func _update_labels() -> void:
	if entries.is_empty():
		info_label.text = "No Spine entries"
		return
	var entry: Dictionary = entries[current_index]
	info_label.text = "%s" % String(entry.get("label", entry.get("key", "?")))
	if not anim_names.is_empty():
		anim_label.text = "Clip %d/%d: %s  @ %.2fx  %s" % [
			anim_index + 1,
			anim_names.size(),
			anim_names[anim_index],
			speed,
			"playing" if playing else "paused",
		]
	else:
		anim_label.text = "No clips"
	var baked_summary := "baked=%d" % anim_names.size()
	if not skeleton_anim_names.is_empty():
		var missing: Array[String] = []
		for animation_name in skeleton_anim_names:
			if not anim_names.has(animation_name):
				missing.append(animation_name)
		if not missing.is_empty():
			baked_summary = "%s / skeleton=%d / missing=%s" % [
				baked_summary,
				skeleton_anim_names.size(),
				", ".join(missing.slice(0, 6))
			]
	status_label.text = "%d/%d  %s  |  %s" % [
		current_index + 1,
		entries.size(),
		String(entry.get("sourceDir", "")),
		baked_summary
	]


func _label(text: String, font_size: int, pos: Vector2, rect_size: Vector2, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = pos
	label.size = rect_size
	label.modulate = Color(0.90, 0.86, 0.80)
	label.clip_text = true
	return label


func _button(text: String, pos: Vector2, cb: Callable, width: float, height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(width, height)
	button.pressed.connect(cb)
	add_child(button)
	return button
