class_name MaidDialogPopupReferenceScreen
extends Control

signal close_requested
signal next_requested

const FALLBACK_MAID := "res://assets/characters/maid_costume/Cos_Maid01_Casual_SD.png"

var open := false
var maid: Dictionary = {}
var dialogs: Array = []
var dialog_index := 0
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_dialog_state(next_maid: Dictionary, next_dialogs: Array, next_index := 0) -> void:
	maid = next_maid.duplicate(true)
	dialogs = next_dialogs.duplicate(true)
	dialog_index = clampi(next_index, 0, maxi(dialogs.size() - 1, 0))
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
		if _next_rect().has_point(pos):
			emit_signal("next_requested")
			accept_event()
			return
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.46), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.11, 0.085, 0.08, 0.98), true)
	draw_rect(panel, Color(0.9, 0.72, 0.45, 0.9), false, 2.0)
	_draw_header(panel)
	_draw_portrait(panel)
	_draw_dialog_body(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 58))
	draw_rect(header, Color(0.2, 0.13, 0.09, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.9, 0.72, 0.45, 0.72), true)
	draw_string(ThemeDB.fallback_font, header.position + Vector2(22, 37), _maid_name(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 90, 22, Color(1.0, 0.91, 0.72, 0.96))

func _draw_portrait(panel: Rect2) -> void:
	var portrait := Rect2(panel.position + Vector2(24, 78), Vector2(132, 158))
	draw_rect(portrait, Color(0.045, 0.04, 0.038, 0.92), true)
	draw_rect(portrait, Color(0.64, 0.5, 0.32, 0.52), false, 1.2)
	var texture := _maid_texture()
	if texture != null:
		var texture_size := Vector2(texture.get_width(), texture.get_height())
		var draw_scale := minf(portrait.size.x / texture_size.x, portrait.size.y / texture_size.y)
		var draw_size := texture_size * draw_scale
		var rect := Rect2(Vector2(portrait.get_center().x - draw_size.x * 0.5, portrait.end.y - draw_size.y), draw_size)
		draw_texture_rect(texture, rect, false, Color(1, 1, 1, 0.96))
	draw_string(ThemeDB.fallback_font, portrait.position + Vector2(0, portrait.size.y + 18), "ID %s" % _maid_id(), HORIZONTAL_ALIGNMENT_CENTER, portrait.size.x, 13, Color(0.85, 0.75, 0.6, 0.86))

func _draw_dialog_body(panel: Rect2) -> void:
	var body := Rect2(panel.position + Vector2(176, 78), Vector2(panel.size.x - 202, panel.size.y - 104))
	draw_rect(body, Color(0.98, 0.94, 0.86, 0.96), true)
	draw_rect(body, Color(0.36, 0.24, 0.18, 0.78), false, 1.5)
	var text := _dialog_text()
	draw_multiline_string(ThemeDB.fallback_font, body.position + Vector2(18, 34), text, HORIZONTAL_ALIGNMENT_LEFT, body.size.x - 36, 22, -1, Color(0.18, 0.12, 0.08, 0.96))
	var meta := "%s/%s" % [mini(dialog_index + 1, dialogs.size()), dialogs.size()]
	draw_string(ThemeDB.fallback_font, body.position + Vector2(18, body.size.y - 18), meta, HORIZONTAL_ALIGNMENT_LEFT, body.size.x - 120, 12, Color(0.36, 0.26, 0.18, 0.62))
	var next := _next_rect()
	draw_rect(next, Color(0.24, 0.15, 0.1, 0.92), true)
	draw_rect(next, Color(0.9, 0.68, 0.42, 0.8), false, 1.2)
	draw_string(ThemeDB.fallback_font, next.position + Vector2(0, next.size.y * 0.68), "Next", HORIZONTAL_ALIGNMENT_CENTER, next.size.x, 13, Color(1, 0.9, 0.72, 0.95))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.96, 520.0)
	var height := minf(size.y * 0.42, 390.0)
	var top := clampf(size.y * 0.48, 300.0, maxf(120.0, size.y - height - 28.0))
	return Rect2(Vector2((size.x - width) * 0.5, top), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 10), Vector2(38, 38))

func _next_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.end - Vector2(90, 46), Vector2(68, 30))

func _dialog_text() -> String:
	if dialogs.is_empty():
		return "Welcome back, Master."
	var entry: Dictionary = dialogs[dialog_index]
	var text_dict: Dictionary = entry.get("text", {})
	var text := String(text_dict.get("eng", ""))
	if text.is_empty():
		text = String(text_dict.get("jp", ""))
	if text.is_empty():
		text = "Welcome back, Master."
	return text.replace("\\n", "\n")

func _maid_texture() -> Texture2D:
	var path := _preview_path()
	if path.is_empty():
		path = FALLBACK_MAID
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

func _preview_path() -> String:
	var records: Array = maid.get("npc_records", [])
	if records.is_empty():
		return FALLBACK_MAID
	var npc: Dictionary = records[0]
	var preview: Dictionary = npc.get("preview", {})
	if String(preview.get("kind", "")) == "static_png_only":
		return String(preview.get("path", FALLBACK_MAID))
	return FALLBACK_MAID

func _maid_name() -> String:
	var records: Array = maid.get("npc_records", [])
	if records.is_empty():
		return "Maid"
	var npc: Dictionary = records[0]
	return String(npc.get("name", "Maid"))

func _maid_id() -> String:
	return _format_number(maid.get("maid_id", "-"))

func _format_number(value) -> String:
	if typeof(value) == TYPE_STRING:
		return value
	var number := float(value)
	if is_equal_approx(number, roundf(number)):
		return str(int(roundf(number)))
	return str(number)
