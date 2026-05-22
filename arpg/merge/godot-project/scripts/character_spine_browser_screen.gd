extends Control

signal close_requested

const MANIFEST_PATH := "res://data/character_spine_browser.json"
const PreviewCanvasScript := preload("res://scripts/spine_baked_preview_canvas.gd")

var entries: Array = []
var failures: Array = []
var selected_index := 0
var clip_index := 0

var preview_canvas: Control
var list: ItemList
var clip_select: OptionButton
var title_label: Label
var meta_label: Label
var failure_label: Label
var play_button: Button
var playing := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_load_manifest()
	_apply_layout()
	_select_character(0)

func set_browser_open(open: bool) -> void:
	visible = open
	mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	if open:
		if entries.is_empty():
			_load_manifest()
		_select_character(clampi(selected_index, 0, max(entries.size() - 1, 0)))

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0.025, 0.027, 0.032, 0.98)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	title_label = Label.new()
	title_label.text = "Character Spine Browser"
	title_label.add_theme_font_size_override("font_size", 24)
	add_child(title_label)

	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "Close"
	close_button.pressed.connect(func() -> void:
		close_requested.emit()
	)
	add_child(close_button)

	list = ItemList.new()
	list.name = "CharacterList"
	list.select_mode = ItemList.SELECT_SINGLE
	list.item_selected.connect(func(index: int) -> void:
		_select_character(index)
	)
	add_child(list)

	preview_canvas = PreviewCanvasScript.new()
	preview_canvas.name = "PreviewCanvas"
	add_child(preview_canvas)

	meta_label = Label.new()
	meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	meta_label.add_theme_font_size_override("font_size", 15)
	add_child(meta_label)

	clip_select = OptionButton.new()
	clip_select.item_selected.connect(func(index: int) -> void:
		_select_clip(index)
	)
	add_child(clip_select)

	play_button = Button.new()
	play_button.text = "Pause"
	play_button.pressed.connect(func() -> void:
		playing = not playing
		play_button.text = "Pause" if playing else "Play"
		preview_canvas.call("set_playing", playing)
	)
	add_child(play_button)

	var prev_button := Button.new()
	prev_button.name = "PrevButton"
	prev_button.text = "Prev"
	prev_button.pressed.connect(func() -> void:
		_select_character(posmod(selected_index - 1, max(entries.size(), 1)))
	)
	add_child(prev_button)

	var next_button := Button.new()
	next_button.name = "NextButton"
	next_button.text = "Next"
	next_button.pressed.connect(func() -> void:
		_select_character(posmod(selected_index + 1, max(entries.size(), 1)))
	)
	add_child(next_button)

	failure_label = Label.new()
	failure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	failure_label.add_theme_font_size_override("font_size", 13)
	failure_label.modulate = Color(1.0, 0.72, 0.55, 0.92)
	add_child(failure_label)

func _apply_layout() -> void:
	if title_label == null or list == null or preview_canvas == null:
		return
	var margin := 18.0
	var top_h := 44.0
	title_label.position = Vector2(margin, 12)
	title_label.size = Vector2(size.x - 180, top_h)
	var close_button := _get_named_button("CloseButton")
	if close_button != null:
		close_button.position = Vector2(size.x - 108, 12)
		close_button.size = Vector2(90, 34)

	var list_w := clampf(size.x * 0.28, 250.0, 360.0)
	list.position = Vector2(margin, 64)
	list.size = Vector2(list_w, size.y - 88)

	var right_x := margin + list_w + 18
	var right_w := size.x - right_x - margin
	var controls_y := size.y - 54
	var failure_y := controls_y - 44
	var meta_y := failure_y - 56
	var preview_h := maxf(meta_y - 76, 280.0)
	preview_canvas.position = Vector2(right_x, 64)
	preview_canvas.size = Vector2(right_w, preview_h)

	meta_label.position = Vector2(right_x, meta_y)
	meta_label.size = Vector2(right_w, 46)
	clip_select.position = Vector2(right_x, controls_y)
	clip_select.size = Vector2(minf(360.0, right_w - 284), 36)
	play_button.position = Vector2(right_x + clip_select.size.x + 10, controls_y)
	play_button.size = Vector2(74, 36)
	var prev_button := _get_named_button("PrevButton")
	if prev_button != null:
		prev_button.position = Vector2(right_x + clip_select.size.x + 94, controls_y)
		prev_button.size = Vector2(74, 36)
	var next_button := _get_named_button("NextButton")
	if next_button != null:
		next_button.position = Vector2(right_x + clip_select.size.x + 176, controls_y)
		next_button.size = Vector2(74, 36)
	failure_label.position = Vector2(right_x, failure_y)
	failure_label.size = Vector2(right_w, 34)

func _get_named_button(node_name: String) -> Button:
	return get_node_or_null(node_name) as Button

func _load_manifest() -> void:
	entries.clear()
	failures.clear()
	list.clear()
	if not FileAccess.file_exists(MANIFEST_PATH):
		failure_label.text = "Missing manifest: %s" % MANIFEST_PATH
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		failure_label.text = "Cannot open manifest: %s" % MANIFEST_PATH
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		failure_label.text = "Invalid manifest JSON."
		return
	entries = parsed.get("characters", [])
	failures = parsed.get("failures", [])
	for entry in entries:
		var category := String(entry.get("category", ""))
		var name := String(entry.get("name", ""))
		list.add_item("%s / %s" % [category, name])
	var totals: Dictionary = parsed.get("totals", {})
	if not failures.is_empty():
		var first_failure: Dictionary = failures[0]
		failure_label.text = "Baked %s/%s. Failed: %s (%s)" % [
			totals.get("baked", entries.size()),
			totals.get("candidates", entries.size() + failures.size()),
			first_failure.get("name", "unknown"),
			first_failure.get("error", "")
		]
	else:
		failure_label.text = "Baked %s character previews." % entries.size()

func _select_character(index: int) -> void:
	if entries.is_empty():
		return
	selected_index = clampi(index, 0, entries.size() - 1)
	list.select(selected_index)
	var entry: Dictionary = entries[selected_index]
	clip_select.clear()
	var clips: Array = entry.get("baked_clips", [])
	for clip in clips:
		clip_select.add_item(String(clip))
	clip_index = 0
	if clip_select.item_count > 0:
		clip_select.select(0)
	var preferred_clip := String(clips[0]) if not clips.is_empty() else ""
	preview_canvas.call("set_baked_path", String(entry.get("baked_path", "")), preferred_clip)
	preview_canvas.call("set_playing", playing)
	_refresh_meta(entry)

func _select_clip(index: int) -> void:
	if entries.is_empty():
		return
	var entry: Dictionary = entries[selected_index]
	var clips: Array = entry.get("baked_clips", [])
	if clips.is_empty():
		return
	clip_index = clampi(index, 0, clips.size() - 1)
	clip_select.select(clip_index)
	preview_canvas.call("set_clip", String(clips[clip_index]))

func _refresh_meta(entry: Dictionary) -> void:
	var skeleton: Dictionary = entry.get("skeleton", {})
	var animations: Array = skeleton.get("animations", [])
	meta_label.text = "%s / %s\nbones %s, slots %s, skins %s, animations %s, preview clips %s" % [
		entry.get("category", ""),
		entry.get("name", ""),
		skeleton.get("bones", 0),
		skeleton.get("slots", 0),
		skeleton.get("skins", []).size(),
		animations.size(),
		", ".join(PackedStringArray(entry.get("baked_clips", [])))
	]
