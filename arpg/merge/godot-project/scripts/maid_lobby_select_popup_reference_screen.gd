class_name MaidLobbySelectPopupReferenceScreen
extends Control

signal close_requested
signal maid_selected(index: int)

const FALLBACK_MAID := "res://assets/characters/maid_costume/Cos_Maid01_Casual_SD.png"

var open := false
var maids: Array = []
var selected_index := 0
var texture_cache: Dictionary = {}
var source: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_maids(next_maids: Array, next_selected := 0) -> void:
	maids = next_maids.duplicate(true)
	selected_index = clampi(next_selected, 0, maxi(maids.size() - 1, 0))
	queue_redraw()

func set_popup_open(next_open: bool) -> void:
	open = next_open
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
		for index in range(mini(maids.size(), 6)):
			if _item_rect(index).has_point(pos):
				emit_signal("maid_selected", index)
				accept_event()
				return
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.52), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.11, 0.08, 0.075, 0.98), true)
	draw_rect(panel, Color(0.9, 0.72, 0.45, 0.9), false, 2.0)
	_draw_header(panel)
	_draw_list(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var title_rect := _source_or_fallback("UIPopup_MaidLobbySelect/BG/Panel/TextTitle", Rect2(panel.position, Vector2(panel.size.x, 62.0)))
	draw_rect(title_rect, Color(0.2, 0.13, 0.09, 0.98), true)
	draw_rect(Rect2(title_rect.position + Vector2(0, title_rect.size.y - 2), Vector2(title_rect.size.x, 2)), Color(0.9, 0.72, 0.45, 0.72), true)
	draw_string(ThemeDB.fallback_font, title_rect.position + Vector2(24, 39), "Select Maid", HORIZONTAL_ALIGNMENT_LEFT, title_rect.size.x - 92, 23, Color(1.0, 0.91, 0.72, 0.96))

func _draw_list(panel: Rect2) -> void:
	var list_rect := _source_or_fallback("UIPopup_MaidLobbySelect/BG/Panel/MaidList", Rect2(panel.position + Vector2(22, 82), Vector2(panel.size.x - 44, panel.size.y - 116)))
	draw_rect(list_rect, Color(0.045, 0.04, 0.038, 0.84), true)
	draw_rect(list_rect, Color(0.64, 0.5, 0.32, 0.42), false, 1.2)
	var source_button := _source_rect("UIPopup_MaidLobbySelect/BG/Panel/BtnArea/Btn")
	if _is_usable_rect(source_button) and _is_reasonable_source_rect(source_button, panel):
		draw_rect(source_button, Color(0.82, 0.58, 0.32, 0.18), false, 1.0)
	var count: int = mini(maids.size(), 6)
	for index in range(count):
		_draw_item(index, _item_rect(index))
	if count == 0:
		draw_string(ThemeDB.fallback_font, list_rect.position + Vector2(0, list_rect.size.y * 0.5), "No maid data", HORIZONTAL_ALIGNMENT_CENTER, list_rect.size.x, 18, Color(0.9, 0.8, 0.64, 0.85))

func _draw_item(index: int, rect: Rect2) -> void:
	var is_selected := index == selected_index
	draw_rect(rect, Color(0.23, 0.16, 0.11, 0.96) if is_selected else Color(0.14, 0.11, 0.095, 0.94), true)
	draw_rect(rect, Color(0.96, 0.76, 0.42, 0.88) if is_selected else Color(0.56, 0.44, 0.3, 0.62), false, 1.4 if is_selected else 1.0)
	var avatar_rect := Rect2(rect.position + Vector2(10, 8), Vector2(52, 52))
	draw_rect(avatar_rect, Color(0.06, 0.05, 0.05, 0.96), true)
	var texture := _texture_for(index)
	if texture != null:
		draw_texture_rect(texture, avatar_rect.grow(-3), false, Color(1, 1, 1, 0.96))
	else:
		draw_circle(avatar_rect.get_center(), 18, Color(0.75, 0.55, 0.62, 0.82))
	var name := _maid_name(index)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(74, 30), name, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 120, 18, Color(1, 0.9, 0.72, 0.95))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(74, 54), "ID %s" % _maid_id(index), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 120, 13, Color(0.82, 0.72, 0.58, 0.82))
	if is_selected:
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 62, 45), "Set", HORIZONTAL_ALIGNMENT_CENTER, 46, 13, Color(1, 0.9, 0.7, 0.95))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var source_panel := _source_rect("UIPopup_MaidLobbySelect/BG/Panel")
	if _is_usable_rect(source_panel):
		return source_panel
	var source_bg := _source_rect("UIPopup_MaidLobbySelect/BG")
	if _is_usable_rect(source_bg) and source_bg.size.x > 180.0 and source_bg.size.y > 180.0:
		return source_bg
	var width := minf(size.x * 0.92, 500.0)
	var height := minf(size.y * 0.78, 700.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return _source_or_fallback("UIPopup_MaidLobbySelect/BG/Panel/Btn_Close", Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38)))

func _item_rect(index: int) -> Rect2:
	var panel := _panel_rect()
	var list_pos := panel.position + Vector2(22, 82)
	var item_h := 78.0
	var gap := 8.0
	var fallback := Rect2(list_pos + Vector2(12, 12 + float(index) * (item_h + gap)), Vector2(panel.size.x - 68, item_h))
	return _source_or_fallback(_source_item_path(index), fallback)

func _texture_for(index: int) -> Texture2D:
	var path := _preview_path(index)
	if path.is_empty():
		path = FALLBACK_MAID
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

func _preview_path(index: int) -> String:
	if index < 0 or index >= maids.size():
		return FALLBACK_MAID
	var maid: Dictionary = maids[index]
	var records: Array = maid.get("npc_records", [])
	if records.is_empty():
		return FALLBACK_MAID
	var npc: Dictionary = records[0]
	var preview: Dictionary = npc.get("preview", {})
	if String(preview.get("kind", "")) == "static_png_only":
		return String(preview.get("path", FALLBACK_MAID))
	return FALLBACK_MAID

func _maid_name(index: int) -> String:
	if index < 0 or index >= maids.size():
		return "Maid"
	var records: Array = maids[index].get("npc_records", [])
	if records.is_empty():
		return "Maid"
	var npc: Dictionary = records[0]
	return String(npc.get("name", "Maid"))

func _maid_id(index: int) -> String:
	if index < 0 or index >= maids.size():
		return "-"
	return _format_number(maids[index].get("maid_id", "-"))

func _format_number(value) -> String:
	if typeof(value) == TYPE_STRING:
		return value
	var number := float(value)
	if is_equal_approx(number, roundf(number)):
		return str(int(roundf(number)))
	return str(number)

func _source_item_path(index: int) -> String:
	if index <= 0:
		return "UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidNone"
	return "UIPopup_MaidLobbySelect/BG/Panel/MaidList/UIListitem_MaidSelect_%s" % index

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
