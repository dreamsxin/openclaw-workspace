class_name OutGameAppPopupReferenceScreen
extends Control

signal close_requested

const ICON_PATHS := {
	"shop": "res://assets/sprites/CURRENCY_JEWEL.png",
	"story": "res://assets/sprites/SubStory_MemoryBox.png",
	"bag": "res://assets/characters/maid_chat/Appicon_MaidChatBot.png",
	"menu": "res://assets/loading/LoadingIcon64.png",
	"mail": "res://assets/characters/maid_chat/ProfileImg_QuestionMaiChat.png",
	"settings": "res://assets/loading/LoadingIcon64.png",
	"gift": "res://assets/sprites/CURRENCY_JEWEL.png",
	"profile": "res://assets/characters/maid_costume/Cos_Maid01_Casual_SD.png",
}

var open := false
var app_key := "shop"
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_popup_state(next_open: bool, next_app_key := "shop") -> void:
	open = next_open
	app_key = next_app_key
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
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.48), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.09, 0.075, 0.065, 0.98), true)
	draw_rect(panel, Color(0.9, 0.72, 0.45, 0.9), false, 2.0)
	_draw_header(panel)
	_draw_body(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 62.0))
	draw_rect(header, Color(0.2, 0.13, 0.09, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.9, 0.72, 0.45, 0.72), true)
	draw_string(ThemeDB.fallback_font, header.position + Vector2(24, 40), _title(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 92, 23, Color(1.0, 0.91, 0.72, 0.96))

func _draw_body(panel: Rect2) -> void:
	var body := Rect2(panel.position + Vector2(22, 84), Vector2(panel.size.x - 44, panel.size.y - 116))
	draw_rect(body, Color(0.045, 0.04, 0.038, 0.86), true)
	draw_rect(body, Color(0.64, 0.5, 0.32, 0.42), false, 1.2)
	var icon_rect := Rect2(body.position + Vector2(22, 22), Vector2(72, 72))
	draw_rect(icon_rect, Color(0.12, 0.095, 0.075, 0.95), true)
	draw_rect(icon_rect, Color(0.72, 0.56, 0.34, 0.62), false, 1.2)
	var texture := _icon_texture()
	if texture != null:
		draw_texture_rect(texture, icon_rect.grow(-10), false, Color(1, 1, 1, 0.96))
	else:
		draw_circle(icon_rect.get_center(), 22, Color(0.82, 0.62, 0.34, 0.86))
	draw_multiline_string(
		ThemeDB.fallback_font,
		body.position + Vector2(112, 38),
		_body_text(),
		HORIZONTAL_ALIGNMENT_LEFT,
		body.size.x - 136,
		18,
		4,
		Color(1, 0.9, 0.72, 0.95)
	)
	_draw_placeholder_slots(body)

func _draw_placeholder_slots(body: Rect2) -> void:
	var slot_y := body.position.y + 128
	var slot_w := (body.size.x - 56) / 3.0
	for index in range(3):
		var slot := Rect2(Vector2(body.position.x + 18 + float(index) * (slot_w + 10), slot_y), Vector2(slot_w, 72))
		draw_rect(slot, Color(0.13, 0.1, 0.08, 0.9), true)
		draw_rect(slot, Color(0.62, 0.48, 0.3, 0.5), false, 1.0)
		draw_circle(slot.position + Vector2(slot.size.x * 0.5, 26), 12, Color(0.76, 0.58, 0.34, 0.72))
		draw_string(ThemeDB.fallback_font, slot.position + Vector2(0, 58), _slot_label(index), HORIZONTAL_ALIGNMENT_CENTER, slot.size.x, 11, Color(0.86, 0.76, 0.58, 0.86))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.92, 500.0)
	var height := minf(size.y * 0.48, 430.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _icon_texture() -> Texture2D:
	var path := String(ICON_PATHS.get(app_key, ""))
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

func _title() -> String:
	var titles := {
		"shop": "Shop",
		"story": "Story / Memory",
		"bag": "Cafe App",
		"menu": "Menu",
		"mail": "Mail",
		"settings": "Settings",
		"gift": "Gift",
		"profile": "Maid Profile",
	}
	return String(titles.get(app_key, "Cafe App"))

func _body_text() -> String:
	var bodies := {
		"shop": "Recovered as a home navigation surface. Product data, ad rewards, and IAP values still need table/runtime confirmation.",
		"story": "Story, memory, event, and echo archive surfaces are visible in UI layout evidence. Content binding is pending.",
		"bag": "This app surface will host inventory, maid chat, and collection-style entries outside the merge board.",
		"menu": "Settings, mail, account, support, and other utility popups still need exact prefab and service mapping.",
		"mail": "Mailbox and notification surfaces are restored here as a first UI shell. Message data and rewards still need table/runtime mapping.",
		"settings": "Settings, account, support, language, and service toggles are grouped here until exact original popup prefabs are mapped.",
		"gift": "Gift interaction is exposed from UIOutGame/UIMaidLD interaction mode. Favorite/hate gift rules still need exact table binding.",
		"profile": "Profile interaction is exposed from UIOutGame/UIMaidLD interaction mode. Detailed maid profile layout still needs exact prefab mapping.",
	}
	return String(bodies.get(app_key, "Out-game popup surface pending exact original prefab mapping."))

func _slot_label(index: int) -> String:
	var labels := {
		"shop": ["Goods", "Ads", "IAP"],
		"story": ["Memory", "Event", "Archive"],
		"bag": ["Items", "Chat", "Collection"],
		"menu": ["Mail", "Config", "Info"],
		"mail": ["Inbox", "Gift", "Notice"],
		"settings": ["Sound", "Account", "Help"],
		"gift": ["Favorite", "Present", "Reward"],
		"profile": ["Info", "Skill", "Costume"],
	}
	var selected_labels: Array = labels.get(app_key, ["Entry", "Entry", "Entry"])
	return String(selected_labels[index])
