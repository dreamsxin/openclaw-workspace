class_name MaidLobbyReferenceScreen
extends Control

signal back_requested
signal dialog_requested
signal select_requested

const FALLBACK_MAID := "res://assets/characters/maid_costume/Cos_Maid01_Casual_SD.png"

var maids: Array = []
var selected_index := 0
var selected_texture: Texture2D
var source: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func set_maids(next_maids: Array, next_index := 0) -> void:
	maids = next_maids.duplicate(true)
	selected_index = clampi(next_index, 0, maxi(maids.size() - 1, 0))
	_load_selected_texture()
	queue_redraw()

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var pos: Vector2 = event.position
		if _back_rect().has_point(pos):
			emit_signal("back_requested")
			accept_event()
			return
		if _dialog_button_rect().has_point(pos):
			emit_signal("dialog_requested")
			accept_event()
			return
		if _select_rect().has_point(pos):
			emit_signal("select_requested")
			accept_event()
			return

func _draw() -> void:
	var screen_rect := _screen_rect()
	var layout := _layout(screen_rect)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.03, 0.035, 0.94), true)
	draw_rect(screen_rect, Color(0.18, 0.14, 0.16, 1.0), true)
	_draw_background(screen_rect, layout)
	_draw_character(layout)
	_draw_gradient(layout)
	_draw_top_bar(layout)
	_draw_dialog(layout)
	_draw_side_panel(layout)
	draw_rect(screen_rect, Color(0.84, 0.68, 0.42, 0.78), false, 2.0)

func _screen_rect() -> Rect2:
	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	return Rect2((size - viewport_size) * 0.5, viewport_size)

func _layout(screen_rect: Rect2) -> Dictionary:
	var s: float = screen_rect.size.x / 540.0
	var top_h := clampf(58.0 * s, 50.0, 72.0)
	var dialog_h := clampf(92.0 * s, 78.0, 112.0)
	var dialog_rect := Rect2(
		Vector2(screen_rect.position.x + 14.0 * s, screen_rect.end.y - dialog_h - 22.0 * s),
		Vector2(screen_rect.size.x - 28.0 * s, dialog_h)
	)
	var source_dialog_rect := _source_rect("UIMaidLobby/Npc_Dialog", screen_rect)
	if _is_usable_rect(source_dialog_rect):
		dialog_rect = source_dialog_rect
	var maid_rect := Rect2(
		Vector2(screen_rect.position.x + screen_rect.size.x * 0.06, screen_rect.position.y + screen_rect.size.y * 0.17),
		Vector2(screen_rect.size.x * 0.66, screen_rect.size.y * 0.68)
	)
	var side_panel := Rect2(
		Vector2(screen_rect.end.x - 150.0 * s, screen_rect.position.y + top_h + 24.0 * s),
		Vector2(132.0 * s, 254.0 * s)
	)
	var source_dialog_btn_rect := _source_rect("UIMaidLobby/DialogBtn", screen_rect)
	var dialog_button_rect := Rect2(dialog_rect.end - Vector2(84.0 * s, 44.0 * s), Vector2(68.0 * s, 30.0 * s))
	if _is_usable_rect(source_dialog_btn_rect):
		dialog_button_rect = source_dialog_btn_rect
	return {
		"screen": screen_rect,
		"scale": s,
		"top": Rect2(screen_rect.position, Vector2(screen_rect.size.x, top_h)),
		"maid": maid_rect,
		"dialog": dialog_rect,
		"bg": _source_rect("UIMaidLobby/BG", screen_rect),
		"white": _source_rect("UIMaidLobby/White", screen_rect),
		"spine_pos": _source_rect("UIMaidLobby/SpinePos", screen_rect),
		"gradient": _source_rect("UIMaidLobby/Gradient", screen_rect),
		"side_panel": side_panel,
		"back": Rect2(screen_rect.position + Vector2(12.0 * s, 12.0 * s), Vector2(40.0 * s, 34.0 * s)),
		"select": Rect2(side_panel.position + Vector2(12.0 * s, 158.0 * s), Vector2(side_panel.size.x - 24.0 * s, 38.0 * s)),
		"dialog_button": dialog_button_rect,
	}

func _draw_background(screen_rect: Rect2, layout: Dictionary) -> void:
	var s: float = layout["scale"]
	var wall_rect := Rect2(screen_rect.position, Vector2(screen_rect.size.x, screen_rect.size.y * 0.62))
	var floor_rect := Rect2(screen_rect.position + Vector2(0, screen_rect.size.y * 0.62), Vector2(screen_rect.size.x, screen_rect.size.y * 0.38))
	draw_rect(wall_rect, Color(0.38, 0.32, 0.38, 1.0), true)
	draw_rect(floor_rect, Color(0.34, 0.2, 0.16, 1.0), true)
	var bg_rect: Rect2 = layout.get("bg", Rect2())
	if bg_rect.size.x > 0.0 and bg_rect.size.y > 0.0:
		draw_rect(bg_rect, Color(0.5, 0.4, 0.46, 0.32), true)
		draw_rect(bg_rect, Color(0.86, 0.72, 0.48, 0.36), false, 1.2 * s)
	var white_rect: Rect2 = layout.get("white", Rect2())
	if white_rect.size.x > 0.0 and white_rect.size.y > 0.0:
		draw_rect(white_rect, Color(1, 0.96, 0.9, 0.08), true)
	for index in range(6):
		var x := screen_rect.position.x + float(index) * screen_rect.size.x / 5.0
		draw_line(Vector2(x, wall_rect.position.y), Vector2(x - 56.0 * s, wall_rect.end.y), Color(0.22, 0.18, 0.23, 0.22), 2.0 * s)
	for index in range(5):
		var y := floor_rect.position.y + float(index) * 42.0 * s
		draw_line(Vector2(floor_rect.position.x, y), Vector2(floor_rect.end.x, y + 24.0 * s), Color(0.16, 0.09, 0.07, 0.28), 2.0 * s)
	var frame := Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.56, screen_rect.size.y * 0.16), Vector2(screen_rect.size.x * 0.3, screen_rect.size.y * 0.18))
	draw_rect(frame, Color(0.16, 0.13, 0.16, 0.86), true)
	draw_rect(frame, Color(0.84, 0.68, 0.42, 0.72), false, 2.0 * s)
	draw_string(ThemeDB.fallback_font, frame.position + Vector2(0, frame.size.y * 0.55), "Lobby", HORIZONTAL_ALIGNMENT_CENTER, frame.size.x, int(18.0 * s), Color(0.95, 0.84, 0.62, 0.9))

func _draw_character(layout: Dictionary) -> void:
	var s: float = layout["scale"]
	var maid_rect: Rect2 = layout["maid"]
	var spine_rect: Rect2 = layout.get("spine_pos", Rect2())
	if spine_rect.size.x > 0.0:
		draw_rect(spine_rect, Color(0.9, 0.72, 0.88, 0.14), false, 1.0 * s)
	draw_circle(Vector2(maid_rect.get_center().x, maid_rect.end.y - 26.0 * s), maid_rect.size.x * 0.28, Color(0.05, 0.035, 0.03, 0.32))
	if selected_texture != null:
		var texture_size := Vector2(selected_texture.get_width(), selected_texture.get_height())
		var draw_scale := minf(maid_rect.size.x / texture_size.x, maid_rect.size.y / texture_size.y)
		var draw_size := texture_size * draw_scale
		var rect := Rect2(Vector2(maid_rect.get_center().x - draw_size.x * 0.5, maid_rect.end.y - draw_size.y), draw_size)
		draw_texture_rect(selected_texture, rect, false, Color(1, 1, 1, 0.98))
	else:
		draw_rect(maid_rect.grow(-28.0 * s), Color(0.9, 0.72, 0.82, 0.28), true)
		draw_rect(maid_rect.grow(-28.0 * s), Color(0.98, 0.88, 0.9, 0.56), false, 1.5 * s)

func _draw_gradient(layout: Dictionary) -> void:
	var screen_rect: Rect2 = layout["screen"]
	var s: float = layout["scale"]
	var gradient_rect := Rect2(screen_rect.position + Vector2(0, screen_rect.size.y * 0.66), Vector2(screen_rect.size.x, screen_rect.size.y * 0.22))
	var source_gradient_rect: Rect2 = layout.get("gradient", Rect2())
	if source_gradient_rect.size.x > 0.0 and source_gradient_rect.size.y > 0.0:
		gradient_rect = source_gradient_rect
	draw_rect(gradient_rect, Color(0.03, 0.03, 0.035, 0.18), true)
	draw_rect(Rect2(gradient_rect.position + Vector2(0, gradient_rect.size.y - 32.0 * s), Vector2(gradient_rect.size.x, 32.0 * s)), Color(0.02, 0.018, 0.02, 0.28), true)

func _draw_top_bar(layout: Dictionary) -> void:
	var top_rect: Rect2 = layout["top"]
	var back_rect: Rect2 = layout["back"]
	var s: float = layout["scale"]
	draw_rect(top_rect, Color(0.07, 0.065, 0.07, 0.92), true)
	draw_rect(Rect2(top_rect.position + Vector2(0, top_rect.size.y - 2.0 * s), Vector2(top_rect.size.x, 2.0 * s)), Color(0.84, 0.68, 0.42, 0.78), true)
	draw_rect(back_rect, Color(0.15, 0.13, 0.13, 0.94), true)
	draw_rect(back_rect, Color(0.9, 0.72, 0.45, 0.86), false, 1.5 * s)
	draw_string(ThemeDB.fallback_font, back_rect.position + Vector2(0, back_rect.size.y * 0.68), "<", HORIZONTAL_ALIGNMENT_CENTER, back_rect.size.x, int(22.0 * s), Color(1, 0.92, 0.72, 0.96))
	draw_string(ThemeDB.fallback_font, top_rect.position + Vector2(64.0 * s, 34.0 * s), "Maid Lobby", HORIZONTAL_ALIGNMENT_LEFT, top_rect.size.x - 128.0 * s, int(20.0 * s), Color(1.0, 0.9, 0.7, 0.96))

func _draw_dialog(layout: Dictionary) -> void:
	var dialog_rect: Rect2 = layout["dialog"]
	var button_rect: Rect2 = layout["dialog_button"]
	var s: float = layout["scale"]
	draw_rect(dialog_rect, Color(0.98, 0.94, 0.86, 0.95), true)
	draw_rect(dialog_rect, Color(0.36, 0.24, 0.18, 0.78), false, 2.0 * s)
	draw_string(ThemeDB.fallback_font, dialog_rect.position + Vector2(20.0 * s, 34.0 * s), _selected_name(), HORIZONTAL_ALIGNMENT_LEFT, dialog_rect.size.x - 120.0 * s, int(19.0 * s), Color(0.18, 0.12, 0.08, 0.96))
	draw_string(ThemeDB.fallback_font, dialog_rect.position + Vector2(20.0 * s, 62.0 * s), "Welcome back.", HORIZONTAL_ALIGNMENT_LEFT, dialog_rect.size.x - 120.0 * s, int(13.0 * s), Color(0.32, 0.22, 0.16, 0.72))
	draw_rect(button_rect, Color(0.24, 0.15, 0.1, 0.92), true)
	draw_rect(button_rect, Color(0.9, 0.68, 0.42, 0.8), false, 1.2 * s)
	draw_string(ThemeDB.fallback_font, button_rect.position + Vector2(0, button_rect.size.y * 0.68), "Talk", HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, int(13.0 * s), Color(1, 0.9, 0.72, 0.95))

func _draw_side_panel(layout: Dictionary) -> void:
	var panel: Rect2 = layout["side_panel"]
	var select_rect: Rect2 = layout["select"]
	var s: float = layout["scale"]
	draw_rect(panel, Color(0.09, 0.08, 0.085, 0.84), true)
	draw_rect(panel, Color(0.82, 0.66, 0.42, 0.62), false, 1.5 * s)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(0, 28.0 * s), "Maid", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(16.0 * s), Color(1, 0.9, 0.68, 0.94))
	for index in range(3):
		var slot := Rect2(panel.position + Vector2(16.0 * s + float(index) * 34.0 * s, 52.0 * s), Vector2(28.0 * s, 28.0 * s))
		draw_rect(slot, Color(0.2, 0.16, 0.14, 0.9), true)
		draw_rect(slot, Color(0.78, 0.62, 0.4, 0.54), false, 1.0 * s)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(12.0 * s, 116.0 * s), "ID %s" % _selected_id(), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 24.0 * s, int(13.0 * s), Color(0.94, 0.84, 0.68, 0.86))
	draw_rect(select_rect, Color(0.19, 0.16, 0.12, 0.94), true)
	draw_rect(select_rect, Color(0.9, 0.7, 0.42, 0.82), false, 1.2 * s)
	draw_string(ThemeDB.fallback_font, select_rect.position + Vector2(0, select_rect.size.y * 0.65), "Select", HORIZONTAL_ALIGNMENT_CENTER, select_rect.size.x, int(14.0 * s), Color(1, 0.9, 0.72, 0.95))
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(12.0 * s, panel.size.y - 18.0 * s), "%s/%s" % [mini(selected_index + 1, maids.size()), maids.size()], HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 24.0 * s, int(12.0 * s), Color(0.84, 0.74, 0.6, 0.82))

func _back_rect() -> Rect2:
	return _layout(_screen_rect())["back"]

func _dialog_button_rect() -> Rect2:
	return _layout(_screen_rect())["dialog_button"]

func _select_rect() -> Rect2:
	return _layout(_screen_rect())["select"]

func _load_selected_texture() -> void:
	var path := _selected_preview_path()
	selected_texture = load(path) if not path.is_empty() else load(FALLBACK_MAID)

func _selected_preview_path() -> String:
	if maids.is_empty():
		return FALLBACK_MAID
	var maid: Dictionary = maids[selected_index]
	var records: Array = maid.get("npc_records", [])
	if not records.is_empty():
		var npc: Dictionary = records[0]
		var preview: Dictionary = npc.get("preview", {})
		if String(preview.get("kind", "")) == "static_png_only":
			var path := String(preview.get("path", ""))
			if not path.is_empty():
				return path
	return FALLBACK_MAID

func _selected_name() -> String:
	if maids.is_empty():
		return "Maid"
	var records: Array = maids[selected_index].get("npc_records", [])
	if not records.is_empty():
		var npc: Dictionary = records[0]
		return String(npc.get("name", "Maid"))
	return "Maid"

func _selected_id() -> String:
	if maids.is_empty():
		return "-"
	var maid: Dictionary = maids[selected_index]
	return _format_number(maid.get("maid_id", "-"))

func _format_number(value) -> String:
	if typeof(value) == TYPE_STRING:
		return value
	var number := float(value)
	if is_equal_approx(number, roundf(number)):
		return str(int(roundf(number)))
	return str(number)

func _reference_size() -> Vector2:
	var resolution: Dictionary = source.get("reference_resolution", {})
	return Vector2(float(resolution.get("width", 1080)), float(resolution.get("height", 1920)))

func _rect_by_path(path: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")) == path:
			return rect
	return {}

func _source_rect(path: String, screen_rect: Rect2) -> Rect2:
	var rect := _rect_by_path(path)
	if rect.is_empty():
		return Rect2()
	var reference_size := _reference_size()
	var scale_factor := screen_rect.size.x / reference_size.x
	return _to_preview_rect_world(rect, reference_size, scale_factor, screen_rect.position)

func _is_usable_rect(rect: Rect2) -> bool:
	return rect.size.x > 8.0 and rect.size.y > 8.0

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
