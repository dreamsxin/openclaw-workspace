class_name SceneLoadingReferenceScreen
extends Control

const LOADING_ASSET_DIR := "res://assets/loading/"

var source: Dictionary = {}
var progress := 0.0
var message := "Scene loading..."
var character_texture: Texture2D

func _ready() -> void:
	character_texture = load(LOADING_ASSET_DIR + "kokomi_Loading.png")

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func set_loading_state(next_progress: float, next_message: String) -> void:
	progress = clampf(next_progress, 0.0, 1.0)
	message = next_message
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.035, 0.04, 0.96), true)
	if source.is_empty():
		return

	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)

	draw_rect(screen_rect, Color(0.1, 0.16, 0.18, 1.0), true)
	_draw_background(reference_size, scale_factor, origin)
	_draw_character(screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.58, 0.78, 0.86, 0.85), false, 2.0)

func _draw_background(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var normal_bg := _rect_by_suffix("SceneObjects/TypeNormal/BG")
	var christmas_bg := _rect_by_suffix("SceneObjects/TypeChristMas (1)/BG")
	for rect in [normal_bg, christmas_bg]:
		if rect.is_empty():
			continue
		var preview_rect := _to_preview_rect(rect, reference_size, scale_factor, origin)
		draw_rect(preview_rect, Color(0.2, 0.42, 0.48, 0.34), true)
		draw_rect(preview_rect, Color(0.78, 0.95, 1.0, 0.26), false, 1.0)

func _draw_character(screen_rect: Rect2) -> void:
	var target := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.12, screen_rect.size.y * 0.2),
		Vector2(screen_rect.size.x * 0.76, screen_rect.size.y * 0.58)
	)
	if character_texture != null:
		draw_texture_rect(character_texture, target, false)
	else:
		draw_rect(target, Color(0.88, 0.72, 0.56, 0.72), true)
		draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y * 0.5), "Spine loading character", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 22, Color(0.1, 0.08, 0.06, 1.0))

func _draw_progress(screen_rect: Rect2) -> void:
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.18, screen_rect.size.y * 0.82),
		Vector2(screen_rect.size.x * 0.64, 18)
	)
	draw_rect(bar_rect, Color(0.04, 0.06, 0.07, 0.94), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.56, 0.88, 0.94, 0.92), true)
	draw_rect(bar_rect, Color(0.92, 0.96, 1.0, 0.8), false, 1.5)
	draw_string(ThemeDB.fallback_font, bar_rect.position + Vector2(0, -24), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(1, 1, 1, 0.92))

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
