class_name InGameReferenceShell
extends Control

var source: Dictionary = {}
var wallet: Dictionary = {}

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func set_wallet(next_wallet: Dictionary) -> void:
	wallet = next_wallet.duplicate(true)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.06, 0.075, 0.075, 0.98), true)
	if source.is_empty():
		_draw_fallback_shell()
		return
	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	_draw_game_backdrop(screen_rect)
	_draw_recovered_panel("Request", Color(0.12, 0.16, 0.17, 0.66), Color(0.74, 0.84, 0.78, 0.34), reference_size, scale_factor, origin)
	_draw_recovered_panel("Bottom/UIBlockInfo/Bg", Color(0.13, 0.1, 0.08, 0.78), Color(0.95, 0.78, 0.48, 0.56), reference_size, scale_factor, origin)
	_draw_recovered_panel("Bottom/UIInventory/Btn_Inven", Color(0.16, 0.13, 0.1, 0.78), Color(0.95, 0.8, 0.52, 0.58), reference_size, scale_factor, origin)
	_draw_recovered_panel("Bottom/Lobby", Color(0.16, 0.13, 0.1, 0.78), Color(0.95, 0.8, 0.52, 0.58), reference_size, scale_factor, origin)
	_draw_top_wallet(screen_rect)

func _draw_fallback_shell() -> void:
	var top_rect := Rect2(Vector2(0, 0), Vector2(size.x, 86))
	var bottom_rect := Rect2(Vector2(0, size.y - 150), Vector2(size.x, 150))
	draw_rect(top_rect, Color(0.1, 0.13, 0.13, 0.88), true)
	draw_rect(bottom_rect, Color(0.16, 0.11, 0.08, 0.9), true)
	_draw_top_wallet(Rect2(Vector2.ZERO, size))

func _draw_game_backdrop(screen_rect: Rect2) -> void:
	draw_rect(screen_rect, Color(0.16, 0.22, 0.21, 1.0), true)
	draw_rect(Rect2(screen_rect.position, Vector2(screen_rect.size.x, screen_rect.size.y * 0.32)), Color(0.28, 0.38, 0.36, 0.52), true)
	draw_rect(Rect2(screen_rect.position + Vector2(0, screen_rect.size.y * 0.32), Vector2(screen_rect.size.x, screen_rect.size.y * 0.68)), Color(0.22, 0.15, 0.1, 0.58), true)
	for index in range(5):
		var y := screen_rect.position.y + screen_rect.size.y * (0.36 + float(index) * 0.11)
		draw_line(Vector2(screen_rect.position.x, y), Vector2(screen_rect.end.x, y + 22.0), Color(0.09, 0.06, 0.04, 0.24), 2.0)

func _draw_top_wallet(screen_rect: Rect2) -> void:
	var top_rect := Rect2(screen_rect.position + Vector2(12, 12), Vector2(screen_rect.size.x - 24, 52))
	draw_rect(top_rect, Color(0.04, 0.05, 0.05, 0.72), true)
	draw_rect(top_rect, Color(0.86, 0.76, 0.52, 0.34), false, 1.5)
	var labels := [
		"AP %s" % wallet.get("ap", 0),
		"G %s" % wallet.get("gold", 0),
		"J %s" % wallet.get("jewel", 0),
	]
	var segment_width := top_rect.size.x / 3.0
	for index in range(labels.size()):
		var pos := top_rect.position + Vector2(segment_width * index, 33)
		draw_string(ThemeDB.fallback_font, pos, labels[index], HORIZONTAL_ALIGNMENT_CENTER, segment_width, 18, Color(1, 0.94, 0.76, 0.95))

func _draw_recovered_panel(suffix: String, fill: Color, stroke: Color, reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var rect := _to_preview_rect_world(_rect_by_suffix(suffix), reference_size, scale_factor, origin)
	if rect.size == Vector2.ZERO:
		return
	draw_rect(rect, fill, true)
	draw_rect(rect, stroke, false, 1.5)

func _reference_size() -> Vector2:
	var resolution: Dictionary = source.get("reference_resolution", {})
	return Vector2(float(resolution.get("width", 1080)), float(resolution.get("height", 1920)))

func _rect_by_suffix(suffix: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")).ends_with(suffix):
			return rect
	return {}

func _rect_by_path(path: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")) == path:
			return rect
	return {}

func _to_preview_rect_world(rect: Dictionary, reference_size: Vector2, scale_factor: float, origin: Vector2) -> Rect2:
	if rect.is_empty():
		return Rect2()
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
