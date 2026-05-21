class_name LoadingReferenceScreen
extends Control

var source: Dictionary = {}
var loading_progress := 0.62

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.025, 0.03, 0.92), true)
	if source.is_empty():
		return

	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)

	draw_rect(screen_rect, Color(0.14, 0.18, 0.2, 1.0), true)
	_draw_background_layers(reference_size, scale_factor, origin)
	_draw_logo(reference_size, scale_factor, origin)
	_draw_loading_bar(reference_size, scale_factor, origin)
	_draw_corner_labels(reference_size, scale_factor, origin)
	draw_rect(screen_rect, Color(0.92, 0.78, 0.48, 0.9), false, 2.0)

func _draw_background_layers(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var bg_base := _rect_by_suffix("Loading_Type/BG_Base/BG")
	var bg_event := _rect_by_suffix("Loading_Type/BG_Base/BG_Event")
	for rect in [bg_base, bg_event]:
		if rect.is_empty():
			continue
		var preview_rect := _to_preview_rect(rect, reference_size, scale_factor, origin)
		draw_rect(preview_rect, Color(0.23, 0.31, 0.34, 0.62), true)
		draw_rect(preview_rect, Color(0.58, 0.7, 0.74, 0.35), false, 1.0)

func _draw_logo(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var logo_rect := _to_preview_rect(_rect_by_suffix("LogoArea/LogoImage"), reference_size, scale_factor, origin)
	if logo_rect.size == Vector2.ZERO:
		logo_rect = _to_preview_rect(_rect_by_suffix("LogoArea/Logo_EN"), reference_size, scale_factor, origin)
	draw_rect(logo_rect, Color(0.88, 0.68, 0.28, 0.88), true)
	draw_rect(logo_rect, Color(1.0, 0.96, 0.72, 0.95), false, 2.0)
	draw_string(ThemeDB.fallback_font, logo_rect.position + Vector2(18, 54), "Maid Cafe", HORIZONTAL_ALIGNMENT_LEFT, logo_rect.size.x - 36, 32, Color(0.12, 0.08, 0.04, 1.0))

func _draw_loading_bar(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var bar_rect := _to_preview_rect(_rect_by_suffix("LoadingBar"), reference_size, scale_factor, origin)
	var fill_rect := _to_preview_rect(_rect_by_suffix("LoadingBar/Fill Area/Image"), reference_size, scale_factor, origin)
	if bar_rect.size == Vector2.ZERO:
		return
	draw_rect(bar_rect, Color(0.08, 0.1, 0.12, 0.95), true)
	draw_rect(bar_rect, Color(0.95, 0.85, 0.56, 0.95), false, 2.0)
	fill_rect.size.x *= loading_progress
	draw_rect(fill_rect, Color(0.42, 0.78, 0.9, 0.92), true)
	draw_string(ThemeDB.fallback_font, bar_rect.position + Vector2(0, -18), "Loading...", HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(1, 1, 1, 0.9))

func _draw_corner_labels(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var left_version := _to_preview_rect(_rect_by_suffix("Ver (1)"), reference_size, scale_factor, origin)
	var right_version := _to_preview_rect(_rect_by_suffix("Ver"), reference_size, scale_factor, origin)
	draw_string(ThemeDB.fallback_font, left_version.position + Vector2(0, 22), "ver left", HORIZONTAL_ALIGNMENT_LEFT, left_version.size.x, 18, Color(1, 1, 1, 0.82))
	draw_string(ThemeDB.fallback_font, right_version.position + Vector2(0, 22), "ver right", HORIZONTAL_ALIGNMENT_RIGHT, right_version.size.x, 18, Color(1, 1, 1, 0.82))

func _reference_size() -> Vector2:
	var resolution: Dictionary = source.get("reference_resolution", {})
	return Vector2(float(resolution.get("width", 1080)), float(resolution.get("height", 1920)))

func _rect_by_suffix(suffix: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")).ends_with(suffix):
			return rect
	return {}

func _to_preview_rect(rect: Dictionary, reference_size: Vector2, scale_factor: float, origin: Vector2) -> Rect2:
	if rect.is_empty():
		return Rect2()
	var anchor_min := _vec2(rect.get("anchor_min", {}))
	var anchor_max := _vec2(rect.get("anchor_max", {}))
	var anchored_position := _vec2(rect.get("anchored_position", {}))
	var size_delta := _vec2(rect.get("size_delta", {}))
	var pivot := _vec2(rect.get("pivot", {"x": 0.5, "y": 0.5}))

	if anchor_min.distance_to(anchor_max) > 0.001:
		var top_left := Vector2(anchor_min.x * reference_size.x, (1.0 - anchor_max.y) * reference_size.y)
		var bottom_right := Vector2(anchor_max.x * reference_size.x, (1.0 - anchor_min.y) * reference_size.y)
		var stretch_size := bottom_right - top_left + Vector2(size_delta.x, -size_delta.y)
		return Rect2(origin + top_left * scale_factor, stretch_size.abs() * scale_factor)

	var center := Vector2(
		anchor_min.x * reference_size.x + anchored_position.x,
		(1.0 - anchor_min.y) * reference_size.y - anchored_position.y
	)
	var top_left := center - Vector2(size_delta.x * pivot.x, size_delta.y * (1.0 - pivot.y))
	return Rect2(origin + top_left * scale_factor, size_delta.abs() * scale_factor)

func _vec2(value) -> Vector2:
	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	if typeof(value) == TYPE_ARRAY:
		return Vector2(float(value[0]) if value.size() > 0 else 0.0, float(value[1]) if value.size() > 1 else 0.0)
	return Vector2.ZERO
