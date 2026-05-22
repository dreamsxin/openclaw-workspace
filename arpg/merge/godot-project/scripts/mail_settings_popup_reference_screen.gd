class_name MailSettingsPopupReferenceScreen
extends Control

signal close_requested

const MAIL_ROWS := [
	{"title": "System Notice", "tag": "Notice", "body": "News and maintenance messages are surfaced from the out-game utility entry.", "reward": "Read"},
	{"title": "Reward Mail", "tag": "Gift", "body": "Claimable rewards are represented as a mailbox row until mail table data is mapped.", "reward": "AP + Gold"},
	{"title": "Event Letter", "tag": "Event", "body": "Event announcements connect the home screen to active popup/event surfaces.", "reward": "Open"},
]

const SETTINGS_ROWS := [
	{"title": "Sound", "tag": "Audio", "body": "BGM and SE toggles are grouped here for the first settings surface.", "value": "On"},
	{"title": "Account", "tag": "Service", "body": "Login, bind, support, and platform service hooks remain pending runtime mapping.", "value": "Guest"},
	{"title": "Language", "tag": "Config", "body": "Table_Language is confirmed in IL2CPP; exact UI binding is still pending.", "value": "Auto"},
]

const ICON_PATHS := {
	"mail": "res://assets/characters/maid_chat/ProfileImg_QuestionMaiChat.png",
	"settings": "res://assets/loading/LoadingIcon64.png",
}

var open := false
var mode := "mail"
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_popup_state(next_open: bool, next_mode := "mail") -> void:
	open = next_open
	mode = next_mode
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

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.065, 0.067, 0.061, 0.98), true)
	draw_rect(panel, Color(0.9, 0.74, 0.5, 0.86), false, 2.0)
	_draw_header(panel)
	_draw_mode_tabs(panel)
	_draw_body(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 62))
	draw_rect(header, Color(0.15, 0.125, 0.095, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.9, 0.74, 0.5, 0.74), true)
	var icon_rect := Rect2(header.position + Vector2(20, 14), Vector2(34, 34))
	var texture := _texture_for(String(ICON_PATHS.get(mode, "")))
	if texture != null:
		draw_texture_rect(texture, icon_rect, false, Color(1, 1, 1, 0.92))
	else:
		draw_circle(icon_rect.get_center(), 14, Color(0.84, 0.67, 0.42, 0.86))
	draw_string(ThemeDB.fallback_font, header.position + Vector2(66, 39), _title(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 132, 23, Color(1.0, 0.92, 0.74, 0.98))
	draw_string(ThemeDB.fallback_font, header.position + Vector2(156, 38), _subtitle(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 220, 12, Color(0.84, 0.74, 0.6, 0.82))

func _draw_mode_tabs(panel: Rect2) -> void:
	var tabs := [
		{"label": "Mail", "key": "mail"},
		{"label": "Settings", "key": "settings"},
	]
	var tab_y := panel.position.y + 78
	var tab_w := (panel.size.x - 48) / 2.0
	for index in range(tabs.size()):
		var tab_data: Dictionary = tabs[index]
		var tab := Rect2(Vector2(panel.position.x + 24 + float(index) * tab_w, tab_y), Vector2(tab_w - 6, 34))
		var active := String(tab_data.get("key", "")) == mode
		draw_rect(tab, Color(0.28, 0.17, 0.09, 0.95) if active else Color(0.105, 0.096, 0.082, 0.92), true)
		draw_rect(tab, Color(0.92, 0.7, 0.42, 0.84) if active else Color(0.52, 0.44, 0.32, 0.5), false, 1.0)
		draw_string(ThemeDB.fallback_font, tab.position + Vector2(0, 23), String(tab_data.get("label", "")), HORIZONTAL_ALIGNMENT_CENTER, tab.size.x, 12, Color(1.0, 0.9, 0.72, 0.95))

func _draw_body(panel: Rect2) -> void:
	var body := Rect2(panel.position + Vector2(24, 126), Vector2(panel.size.x - 48, panel.size.y - 156))
	draw_rect(body, Color(0.043, 0.044, 0.041, 0.84), true)
	draw_rect(body, Color(0.56, 0.48, 0.35, 0.45), false, 1.0)
	var intro := _intro_text()
	draw_multiline_string(ThemeDB.fallback_font, body.position + Vector2(18, 26), intro, HORIZONTAL_ALIGNMENT_LEFT, body.size.x - 36, 13, 4, Color(0.88, 0.78, 0.62, 0.88))
	var rows: Array = MAIL_ROWS if mode == "mail" else SETTINGS_ROWS
	var row_y := body.position.y + 88
	var row_h := minf(86, (body.size.y - 112) / 3.0)
	for index in range(rows.size()):
		var row := Rect2(Vector2(body.position.x + 16, row_y + float(index) * (row_h + 10)), Vector2(body.size.x - 32, row_h))
		var entry: Dictionary = rows[index]
		_draw_entry_row(row, entry)

func _draw_entry_row(row: Rect2, entry: Dictionary) -> void:
	draw_rect(row, Color(0.12, 0.105, 0.085, 0.94), true)
	draw_rect(row, Color(0.62, 0.5, 0.33, 0.55), false, 1.0)
	var tag := Rect2(row.position + Vector2(12, 11), Vector2(72, 22))
	draw_rect(tag, Color(0.23, 0.14, 0.08, 0.96), true)
	draw_string(ThemeDB.fallback_font, tag.position + Vector2(0, 16), String(entry.get("tag", "")), HORIZONTAL_ALIGNMENT_CENTER, tag.size.x, 10, Color(0.98, 0.82, 0.56, 0.95))
	var text_x := row.position.x + 98
	draw_string(ThemeDB.fallback_font, Vector2(text_x, row.position.y + 29), String(entry.get("title", "")), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 190, 14, Color(1.0, 0.9, 0.72, 0.96))
	draw_multiline_string(ThemeDB.fallback_font, Vector2(text_x, row.position.y + 51), String(entry.get("body", "")), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 190, 10, 2, Color(0.76, 0.68, 0.54, 0.88))
	var action := Rect2(row.position + Vector2(row.size.x - 86, row.size.y * 0.5 - 14), Vector2(72, 28))
	draw_rect(action, Color(0.28, 0.17, 0.09, 0.98), true)
	draw_rect(action, Color(0.92, 0.69, 0.42, 0.78), false, 1.0)
	var action_text := String(entry.get("reward", entry.get("value", "")))
	draw_string(ThemeDB.fallback_font, action.position + Vector2(0, 19), action_text, HORIZONTAL_ALIGNMENT_CENTER, action.size.x, 10, Color(1.0, 0.9, 0.72, 0.94))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.92, 540.0)
	var height := minf(size.y * 0.64, 500.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _title() -> String:
	return "Mail" if mode == "mail" else "Settings"

func _subtitle() -> String:
	return "Inbox / rewards / notices" if mode == "mail" else "Sound / account / language"

func _intro_text() -> String:
	if mode == "mail":
		return "Top-right UIOutGame Mail now has an independent shell. Exact inbox payloads, claim states, and reward IDs still need table/runtime binding."
	return "Top-right UIOutGame Settings now has an independent shell. Audio, account, support, and language controls are staged until exact popup evidence is mapped."

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]
