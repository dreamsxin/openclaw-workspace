class_name UILayoutReferencePreview
extends Control

var source: Dictionary = {}

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.05, 0.06, 0.86), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.84, 0.78, 0.56, 0.95), false, 2.0)
	if source.is_empty():
		return

	var resolution: Dictionary = source.get("reference_resolution", {})
	var reference_size := Vector2(
		float(resolution.get("width", 1080)),
		float(resolution.get("height", 1920))
	)
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	draw_rect(Rect2(origin, viewport_size), Color(0.1, 0.12, 0.15, 0.92), true)
	draw_rect(Rect2(origin, viewport_size), Color(0.45, 0.58, 0.78, 0.7), false, 1.0)

	var rects: Array = source.get("key_rects", [])
	for index in range(mini(24, rects.size())):
		var rect: Dictionary = rects[index]
		var preview_rect := _to_preview_rect(rect, reference_size, scale_factor, origin)
		if preview_rect.size.x < 1.0 or preview_rect.size.y < 1.0:
			continue
		var color := Color(0.35, 0.78, 0.93, 0.45)
		if rect.get("layout_kind", "") == "full_stretch":
			color = Color(0.93, 0.65, 0.32, 0.42)
		draw_rect(preview_rect, color, false, 1.25)

func _to_preview_rect(rect: Dictionary, reference_size: Vector2, scale_factor: float, origin: Vector2) -> Rect2:
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
