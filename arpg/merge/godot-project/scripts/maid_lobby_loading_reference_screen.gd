class_name MaidLobbyLoadingReferenceScreen
extends Control

const LOADING_ASSET_DIR := "res://assets/loading/"

var source: Dictionary = {}
var progress := 0.0
var message := "Opening lobby..."
var logo_texture: Texture2D

func _ready() -> void:
	logo_texture = load(LOADING_ASSET_DIR + "MaidCafe_Logo_Kr.png")
	set_process(true)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func set_loading_state(next_progress: float, next_message: String) -> void:
	progress = clampf(next_progress, 0.0, 1.0)
	message = next_message
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.024, 0.022, 0.98), true)
	if source.is_empty():
		return
	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	_draw_lobby_backdrop(screen_rect)
	_draw_recovered_grid(reference_size, scale_factor, origin)
	_draw_cover(reference_size, scale_factor, origin, screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.94, 0.78, 0.52, 0.75), false, 2.0)

func _draw_lobby_backdrop(screen_rect: Rect2) -> void:
	draw_rect(screen_rect, Color(0.58, 0.42, 0.3, 1.0), true)
	var wall_rect := Rect2(screen_rect.position, Vector2(screen_rect.size.x, screen_rect.size.y * 0.58))
	var floor_rect := Rect2(screen_rect.position + Vector2(0, screen_rect.size.y * 0.58), Vector2(screen_rect.size.x, screen_rect.size.y * 0.42))
	draw_rect(wall_rect, Color(0.74, 0.62, 0.48, 0.95), true)
	draw_rect(floor_rect, Color(0.44, 0.26, 0.16, 0.96), true)
	for index in range(4):
		var y := floor_rect.position.y + floor_rect.size.y * (float(index) + 1.0) / 5.0
		draw_line(Vector2(floor_rect.position.x, y), Vector2(floor_rect.end.x, y + 30.0), Color(0.2, 0.1, 0.05, 0.34), 2.0)
	var counter_rect := Rect2(
		Vector2(screen_rect.position.x - screen_rect.size.x * 0.08, screen_rect.position.y + screen_rect.size.y * 0.68),
		Vector2(screen_rect.size.x * 1.16, screen_rect.size.y * 0.13)
	)
	draw_rect(counter_rect, Color(0.55, 0.34, 0.2, 0.96), true)
	draw_rect(counter_rect, Color(0.92, 0.76, 0.54, 0.42), false, 1.5)
	if logo_texture != null:
		var logo_size := Vector2(screen_rect.size.x * 0.5, screen_rect.size.x * 0.19)
		var logo_rect := Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.25, screen_rect.size.y * 0.1), logo_size)
		draw_texture_rect(logo_texture, logo_rect, false, Color(1, 1, 1, 0.92))

func _draw_recovered_grid(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var palette := [
		Color(0.96, 0.82, 0.52, 0.34),
		Color(0.86, 0.62, 0.42, 0.28),
		Color(0.96, 0.9, 0.72, 0.24),
		Color(0.56, 0.34, 0.22, 0.24),
	]
	for index in range(16):
		var rect := _to_preview_rect_world(_rect_by_suffix("GameObject/Image_%02d/%d" % [index, index]), reference_size, scale_factor, origin)
		if rect.size == Vector2.ZERO:
			continue
		var color: Color = palette[index % palette.size()]
		if index % 2 == 0:
			draw_rect(rect, color, true)
		draw_rect(rect, Color(color.r, color.g, color.b, 0.42), false, 1.0)
		for deco_index in range(3):
			var deco_name := "Deco" if deco_index == 0 else "Deco_%d" % deco_index
			var deco_rect := _to_preview_rect_world(_rect_by_suffix("GameObject/Image_%02d/%d/%s" % [index, index, deco_name]), reference_size, scale_factor, origin)
			if deco_rect.size == Vector2.ZERO:
				continue
			draw_rect(deco_rect, Color(1, 0.92, 0.66, 0.08), true)
			draw_rect(deco_rect, Color(1, 0.88, 0.56, 0.16), false, 1.0)

func _draw_cover(reference_size: Vector2, scale_factor: float, origin: Vector2, screen_rect: Rect2) -> void:
	var cover_rect := _to_preview_rect_world(_rect_by_suffix("Cover"), reference_size, scale_factor, origin)
	if cover_rect.size == Vector2.ZERO:
		cover_rect = screen_rect
	draw_rect(cover_rect, Color(0.04, 0.035, 0.028, 0.22 * (1.0 - progress)), true)

func _draw_progress(screen_rect: Rect2) -> void:
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.18, screen_rect.size.y * 0.84),
		Vector2(screen_rect.size.x * 0.64, 18)
	)
	draw_rect(bar_rect, Color(0.05, 0.04, 0.035, 0.9), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.93, 0.7, 0.42, 0.92), true)
	draw_rect(bar_rect, Color(1, 0.88, 0.6, 0.82), false, 1.4)
	draw_string(ThemeDB.fallback_font, bar_rect.position + Vector2(0, -24), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(1, 0.94, 0.78, 0.94))

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
