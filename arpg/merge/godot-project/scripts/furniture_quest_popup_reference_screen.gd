class_name FurnitureQuestPopupReferenceScreen
extends Control

signal close_requested

const REWARD_ICON := "res://assets/sprites/CURRENCY_GOLD.png"

var open := false
var wallet: Dictionary = {}
var texture_cache: Dictionary = {}
var source: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_popup_state(next_open: bool, next_wallet: Dictionary) -> void:
	open = next_open
	wallet = next_wallet.duplicate(true)
	visible = open
	mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not open:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var pos: Vector2 = event.position
		if _close_rect().has_point(pos) or not _panel_rect().has_point(pos):
			emit_signal("close_requested")
			accept_event()
			return
		if _claim_rect().has_point(pos):
			emit_signal("close_requested")
			accept_event()
			return
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.48), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.095, 0.08, 0.065, 0.98), true)
	draw_rect(panel, Color(0.9, 0.72, 0.45, 0.9), false, 2.0)
	_draw_header(panel)
	_draw_prefab_entry_evidence(panel)
	_draw_progress(panel)
	_draw_task_list(panel)
	_draw_claim_button()
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var button := _source_or_fallback("UIFurnitureQuest/Button", Rect2(panel.position + Vector2(16, 12), Vector2(54, 54)))
	var header := Rect2(panel.position, Vector2(panel.size.x, maxf(62.0, button.size.y + 20.0)))
	draw_rect(header, Color(0.2, 0.13, 0.09, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.9, 0.72, 0.45, 0.74), true)
	draw_string(ThemeDB.fallback_font, header.position + Vector2(82, 39), "Furniture Quest", HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 150, 23, Color(1.0, 0.92, 0.72, 0.96))

func _draw_progress(panel: Rect2) -> void:
	var area := Rect2(panel.position + Vector2(24, 84), Vector2(panel.size.x - 48, 118))
	draw_rect(area, Color(0.045, 0.04, 0.035, 0.9), true)
	draw_rect(area, Color(0.62, 0.48, 0.3, 0.48), false, 1.2)
	draw_string(ThemeDB.fallback_font, area.position + Vector2(18, 32), "Village ReBuild", HORIZONTAL_ALIGNMENT_LEFT, area.size.x - 36, 19, Color(1, 0.9, 0.7, 0.96))
	draw_string(ThemeDB.fallback_font, area.position + Vector2(18, 58), "Restores the cafe home progression surface from UIOutGame/UIVillageReBuild.", HORIZONTAL_ALIGNMENT_LEFT, area.size.x - 36, 13, Color(0.82, 0.72, 0.58, 0.84))
	var bar := Rect2(area.position + Vector2(18, 82), Vector2(area.size.x - 36, 16))
	draw_rect(bar, Color(0.05, 0.055, 0.045, 0.85), true)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * 0.57, bar.size.y)), Color(0.56, 0.84, 0.6, 0.92), true)
	draw_rect(bar, Color(0.9, 0.72, 0.45, 0.56), false, 1.0)

func _draw_task_list(panel: Rect2) -> void:
	var list := Rect2(panel.position + Vector2(24, 218), Vector2(panel.size.x - 48, 208))
	var main := _source_or_fallback("UIFurnitureQuest/Button/Main", Rect2(list.position + Vector2(12, 12), Vector2(50, 50)))
	var sub := _source_or_fallback("UIFurnitureQuest/Button/Sub", Rect2(list.position + Vector2(72, 12), Vector2(50, 50)))
	draw_rect(list, Color(0.045, 0.04, 0.034, 0.86), true)
	draw_rect(list, Color(0.54, 0.42, 0.28, 0.4), false, 1.0)
	draw_rect(main, Color(0.32, 0.2, 0.1, 0.34), false, 1.0)
	draw_rect(sub, Color(0.32, 0.2, 0.1, 0.28), false, 1.0)
	var tasks := [
		{"title": "Repair counter", "need": "Submit merged cafe tools", "progress": 0.57},
		{"title": "Clean seating area", "need": "Use cleaning-chain items", "progress": 0.35},
		{"title": "Decorate wall", "need": "Unlock furniture reward", "progress": 0.18},
	]
	for index in range(tasks.size()):
		_draw_task_item(list, index, tasks[index])

func _draw_task_item(list: Rect2, index: int, task: Dictionary) -> void:
	var row := Rect2(list.position + Vector2(12, 12 + float(index) * 62), Vector2(list.size.x - 24, 52))
	draw_rect(row, Color(0.13, 0.095, 0.07, 0.92), true)
	draw_rect(row, Color(0.62, 0.48, 0.3, 0.46), false, 1.0)
	var title := String(task.get("title", "Quest"))
	var need := String(task.get("need", "Need item"))
	draw_string(ThemeDB.fallback_font, row.position + Vector2(12, 22), title, HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 108, 15, Color(1, 0.9, 0.72, 0.94))
	draw_string(ThemeDB.fallback_font, row.position + Vector2(12, 40), need, HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 108, 11, Color(0.82, 0.72, 0.58, 0.82))
	var icon_rect := Rect2(row.end - Vector2(82, 42), Vector2(30, 30))
	var texture := _texture_for(REWARD_ICON)
	if texture != null:
		draw_texture_rect(texture, icon_rect, false, Color(1, 1, 1, 0.94))
	draw_string(ThemeDB.fallback_font, row.end - Vector2(50, 18), "x%s" % (20 + index * 15), HORIZONTAL_ALIGNMENT_LEFT, 42, 12, Color(1, 0.9, 0.7, 0.9))

func _draw_claim_button() -> void:
	var claim := _claim_rect()
	draw_rect(claim, Color(0.24, 0.16, 0.08, 0.96), true)
	draw_rect(claim, Color(1.0, 0.78, 0.4, 0.9), false, 1.5)
	draw_string(ThemeDB.fallback_font, claim.position + Vector2(0, 32), "Go", HORIZONTAL_ALIGNMENT_CENTER, claim.size.x, 17, Color(1, 0.92, 0.72, 0.96))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.92, 500.0)
	var height := minf(size.y * 0.64, 580.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _claim_rect() -> Rect2:
	var panel := _panel_rect()
	return _source_or_fallback("UIFurnitureQuest/Button/Text (TMP)", Rect2(panel.end - Vector2(118, 58), Vector2(92, 38)))

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

func _draw_prefab_entry_evidence(panel: Rect2) -> void:
	var button := _source_or_fallback("UIFurnitureQuest/Button", Rect2(panel.position + Vector2(16, 12), Vector2(54, 54)))
	draw_rect(button, Color(0.14, 0.1, 0.07, 0.9), true)
	draw_rect(button, Color(0.96, 0.75, 0.42, 0.75), false, 1.2)
	var icon := _source_or_fallback("UIFurnitureQuest/Button/Image (2)", button.grow(-9.0))
	draw_rect(icon, Color(0.28, 0.18, 0.09, 0.68), true)
	var ring := _source_or_fallback("UIFurnitureQuest/Button/Image", button.grow(-15.0))
	draw_rect(ring, Color(0.96, 0.75, 0.42, 0.36), false, 1.0)
	draw_string(ThemeDB.fallback_font, icon.position + Vector2(0, icon.size.y * 0.5 + 5), "F", HORIZONTAL_ALIGNMENT_CENTER, icon.size.x, 18, Color(1.0, 0.9, 0.68, 0.92))
	var noti := _source_or_fallback("UIFurnitureQuest/Button/UFX_Noti_V2/Noti", Rect2(button.end - Vector2(20, 20), Vector2(18, 18)))
	draw_circle(noti.get_center(), minf(noti.size.x, noti.size.y) * 0.5, Color(0.9, 0.18, 0.16, 0.92))

func _source_or_fallback(path: String, fallback: Rect2) -> Rect2:
	var rect := _source_rect(path)
	if _is_usable_rect(rect) and _is_reasonable_source_rect(rect, fallback):
		return rect
	return fallback

func _source_rect(path: String) -> Rect2:
	var rect := _rect_by_path(path)
	if rect.is_empty():
		return Rect2()
	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	return _to_preview_rect_world(rect, reference_size, scale_factor, origin)

func _rect_by_path(path: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")) == path:
			return rect
	return {}

func _reference_size() -> Vector2:
	var resolution: Dictionary = source.get("reference_resolution", {})
	return Vector2(float(resolution.get("width", 1080)), float(resolution.get("height", 1920)))

func _is_usable_rect(rect: Rect2) -> bool:
	return rect.size.x > 8.0 and rect.size.y > 8.0

func _is_reasonable_source_rect(rect: Rect2, fallback: Rect2) -> bool:
	var grow_amount := maxf(96.0, maxf(fallback.size.x, fallback.size.y) * 0.85)
	var allowed := fallback.grow(grow_amount)
	if not allowed.has_point(rect.get_center()):
		return false
	var max_width := maxf(fallback.size.x * 2.2, fallback.size.x + 96.0)
	var max_height := maxf(fallback.size.y * 2.2, fallback.size.y + 96.0)
	return rect.size.x <= max_width and rect.size.y <= max_height

func _to_preview_rect_world(rect: Dictionary, reference_size: Vector2, scale_factor: float, origin: Vector2) -> Rect2:
	var path := String(rect.get("node_path", ""))
	var parts := path.split("/")
	var parent_rect := Rect2(Vector2.ZERO, reference_size)
	var current_rect := Rect2()
	var prefix := ""
	for part in parts:
		prefix = part if prefix.is_empty() else prefix + "/" + part
		var current_data := _rect_by_path(prefix)
		if current_data.is_empty():
			current_rect = _rect_to_parent_reference_rect(rect, parent_rect)
			return Rect2(origin + current_rect.position * scale_factor, current_rect.size * scale_factor)
		current_rect = _rect_to_parent_reference_rect(current_data, parent_rect)
		parent_rect = current_rect
	return Rect2(origin + current_rect.position * scale_factor, current_rect.size * scale_factor)

func _rect_to_parent_reference_rect(rect: Dictionary, parent_rect: Rect2) -> Rect2:
	var anchor_min := _vec2(rect.get("anchor_min", {}))
	var anchor_max := _vec2(rect.get("anchor_max", {}))
	var anchored_position := _vec2(rect.get("anchored_position", {}))
	var size_delta := _vec2(rect.get("size_delta", {}))
	var pivot := _vec2(rect.get("pivot", {"x": 0.5, "y": 0.5}))
	var parent_size := parent_rect.size
	var anchor_span := anchor_max - anchor_min
	var rect_size := Vector2(
		parent_size.x * anchor_span.x + size_delta.x,
		parent_size.y * anchor_span.y + size_delta.y
	).abs()
	var center_from_bottom := Vector2(
		(anchor_min.x + anchor_span.x * pivot.x) * parent_size.x + anchored_position.x,
		(anchor_min.y + anchor_span.y * pivot.y) * parent_size.y + anchored_position.y
	)
	var local_top_left := Vector2(
		center_from_bottom.x - rect_size.x * pivot.x,
		parent_size.y - center_from_bottom.y - rect_size.y * (1.0 - pivot.y)
	)
	return Rect2(parent_rect.position + local_top_left, rect_size)

func _vec2(value) -> Vector2:
	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	if typeof(value) == TYPE_ARRAY:
		return Vector2(float(value[0]) if value.size() > 0 else 0.0, float(value[1]) if value.size() > 1 else 0.0)
	return Vector2.ZERO
