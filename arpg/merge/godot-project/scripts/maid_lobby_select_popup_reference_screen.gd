class_name MaidLobbySelectPopupReferenceScreen
extends Control

signal close_requested
signal maid_selected(index: int)

const FALLBACK_MAID := "res://assets/characters/maid_costume/Cos_Maid01_Casual_SD.png"

var open := false
var maids: Array = []
var selected_index := 0
var texture_cache: Dictionary = {}

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
	var title_rect := Rect2(panel.position, Vector2(panel.size.x, 62.0))
	draw_rect(title_rect, Color(0.2, 0.13, 0.09, 0.98), true)
	draw_rect(Rect2(title_rect.position + Vector2(0, title_rect.size.y - 2), Vector2(title_rect.size.x, 2)), Color(0.9, 0.72, 0.45, 0.72), true)
	draw_string(ThemeDB.fallback_font, title_rect.position + Vector2(24, 39), "Select Maid", HORIZONTAL_ALIGNMENT_LEFT, title_rect.size.x - 92, 23, Color(1.0, 0.91, 0.72, 0.96))

func _draw_list(panel: Rect2) -> void:
	var list_rect := Rect2(panel.position + Vector2(22, 82), Vector2(panel.size.x - 44, panel.size.y - 116))
	draw_rect(list_rect, Color(0.045, 0.04, 0.038, 0.84), true)
	draw_rect(list_rect, Color(0.64, 0.5, 0.32, 0.42), false, 1.2)
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
	var width := minf(size.x * 0.92, 500.0)
	var height := minf(size.y * 0.78, 700.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _item_rect(index: int) -> Rect2:
	var panel := _panel_rect()
	var list_pos := panel.position + Vector2(22, 82)
	var item_h := 78.0
	var gap := 8.0
	return Rect2(list_pos + Vector2(12, 12 + float(index) * (item_h + gap)), Vector2(panel.size.x - 68, item_h))

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
