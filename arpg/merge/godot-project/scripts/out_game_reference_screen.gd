class_name OutGameReferenceScreen
extends Control

var source: Dictionary = {}

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.03, 0.035, 0.94), true)
	if source.is_empty():
		return

	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)

	draw_rect(screen_rect, Color(0.1, 0.12, 0.13, 1.0), true)
	_draw_cafe_backdrop(screen_rect)
	_draw_maid_layer(reference_size, scale_factor, origin, screen_rect)
	_draw_bottom_buttons(reference_size, scale_factor, origin, screen_rect)
	_draw_village_progress(reference_size, scale_factor, origin, screen_rect)
	draw_rect(screen_rect, Color(0.78, 0.72, 0.55, 0.82), false, 2.0)

func _draw_cafe_backdrop(screen_rect: Rect2) -> void:
	var floor_rect := Rect2(
		Vector2(screen_rect.position.x, screen_rect.position.y + screen_rect.size.y * 0.58),
		Vector2(screen_rect.size.x, screen_rect.size.y * 0.42)
	)
	draw_rect(screen_rect, Color(0.26, 0.37, 0.38, 1.0), true)
	draw_rect(Rect2(screen_rect.position, Vector2(screen_rect.size.x, screen_rect.size.y * 0.62)), Color(0.52, 0.64, 0.62, 0.72), true)
	draw_rect(floor_rect, Color(0.38, 0.25, 0.18, 0.96), true)
	for index in range(4):
		var y := floor_rect.position.y + floor_rect.size.y * (float(index) + 1.0) / 5.0
		draw_line(Vector2(floor_rect.position.x, y), Vector2(floor_rect.end.x, y + 36.0), Color(0.2, 0.12, 0.08, 0.28), 3.0)
	var counter := Rect2(
		Vector2(screen_rect.position.x - screen_rect.size.x * 0.08, screen_rect.position.y + screen_rect.size.y * 0.7),
		Vector2(screen_rect.size.x * 1.16, screen_rect.size.y * 0.16)
	)
	draw_rect(counter, Color(0.5, 0.3, 0.18, 0.96), true)
	draw_rect(counter, Color(0.92, 0.78, 0.55, 0.36), false, 2.0)

func _draw_maid_layer(reference_size: Vector2, scale_factor: float, origin: Vector2, screen_rect: Rect2) -> void:
	var spine_pos := _to_preview_rect_world(_rect_by_suffix("UIMaidLD/SpinePos"), reference_size, scale_factor, origin)
	if spine_pos.size == Vector2.ZERO:
		spine_pos = Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.2, screen_rect.size.y * 0.12), Vector2(100, 100))
	var maid_rect := Rect2(
		Vector2(spine_pos.position.x - screen_rect.size.x * 0.18, screen_rect.position.y + screen_rect.size.y * 0.17),
		Vector2(screen_rect.size.x * 0.58, screen_rect.size.y * 0.62)
	)
	var body_color := Color(0.92, 0.76, 0.84, 0.56)
	var outline := Color(0.98, 0.9, 0.94, 0.72)
	draw_circle(maid_rect.get_center() + Vector2(0, -maid_rect.size.y * 0.22), maid_rect.size.x * 0.17, body_color)
	draw_line(maid_rect.get_center() + Vector2(0, -maid_rect.size.y * 0.05), maid_rect.get_center() + Vector2(0, maid_rect.size.y * 0.24), outline, 7.0)
	draw_line(maid_rect.get_center() + Vector2(0, maid_rect.size.y * 0.02), maid_rect.get_center() + Vector2(-maid_rect.size.x * 0.18, maid_rect.size.y * 0.16), outline, 5.0)
	draw_line(maid_rect.get_center() + Vector2(0, maid_rect.size.y * 0.02), maid_rect.get_center() + Vector2(maid_rect.size.x * 0.18, maid_rect.size.y * 0.16), outline, 5.0)
	draw_rect(maid_rect, Color(1, 0.92, 0.96, 0.42), false, 1.5)

	var dialog_rect := _to_preview_rect_world(_rect_by_suffix("Npc_Dialog"), reference_size, scale_factor, origin)
	if dialog_rect.size == Vector2.ZERO:
		dialog_rect = Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.12, screen_rect.size.y * 0.16), Vector2(screen_rect.size.x * 0.76, 78))
	draw_rect(dialog_rect, Color(0.98, 0.94, 0.86, 0.92), true)
	draw_rect(dialog_rect, Color(0.36, 0.24, 0.18, 0.78), false, 2.0)
	draw_string(ThemeDB.fallback_font, dialog_rect.position + Vector2(18, 34), "Welcome back.", HORIZONTAL_ALIGNMENT_LEFT, dialog_rect.size.x - 36, 22, Color(0.18, 0.12, 0.08, 0.95))

func _draw_bottom_buttons(reference_size: Vector2, scale_factor: float, origin: Vector2, screen_rect: Rect2) -> void:
	var in_game_rect := _to_preview_rect_world(_rect_by_suffix("InGameBtn"), reference_size, scale_factor, origin)
	if in_game_rect.size == Vector2.ZERO:
		in_game_rect = Rect2(screen_rect.position + Vector2(screen_rect.size.x - 175, screen_rect.size.y - 130), Vector2(150, 90))
	_draw_command_button(in_game_rect, "InGame")

	var lobby_rect := _to_preview_rect_world(_rect_by_suffix("MaidLobbyBtn"), reference_size, scale_factor, origin)
	if lobby_rect.size == Vector2.ZERO:
		lobby_rect = Rect2(screen_rect.position + Vector2(screen_rect.size.x - 280, screen_rect.size.y - 116), Vector2(100, 100))
	_draw_command_button(lobby_rect, "Maid")

	var interaction_rect := _to_preview_rect_world(_rect_by_suffix("Btn_ToInteraction"), reference_size, scale_factor, origin)
	if interaction_rect.size != Vector2.ZERO:
		draw_rect(interaction_rect, Color(0.94, 0.68, 0.82, 0.12), true)
		draw_rect(interaction_rect, Color(0.95, 0.72, 0.88, 0.42), false, 1.0)

func _draw_village_progress(reference_size: Vector2, scale_factor: float, origin: Vector2, screen_rect: Rect2) -> void:
	var bar_rect := _to_preview_rect_world(_rect_by_suffix("UIVillageReBuild/Fillbar"), reference_size, scale_factor, origin)
	if bar_rect.size == Vector2.ZERO:
		bar_rect = Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.5 - 140, 58), Vector2(280, 44))
	draw_rect(bar_rect, Color(0.1, 0.12, 0.12, 0.88), true)
	draw_rect(Rect2(bar_rect.position + Vector2(6, 6), Vector2((bar_rect.size.x - 12) * 0.57, maxf(bar_rect.size.y - 12, 4))), Color(0.58, 0.86, 0.68, 0.9), true)
	draw_rect(bar_rect, Color(0.86, 0.78, 0.56, 0.84), false, 1.5)

func _draw_command_button(rect: Rect2, label: String) -> void:
	draw_rect(rect, Color(0.12, 0.14, 0.15, 0.82), true)
	draw_rect(rect, Color(0.93, 0.78, 0.5, 0.86), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.5 + 7), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20, Color(1, 0.94, 0.78, 0.96))

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
