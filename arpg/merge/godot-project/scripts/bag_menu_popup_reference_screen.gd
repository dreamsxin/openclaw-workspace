class_name BagMenuPopupReferenceScreen
extends Control

signal close_requested

const BAG_CARDS := [
	{"title": "Items", "tag": "Bag", "body": "Normal items, gift items, and consumables surfaced outside the merge board.", "state": "List"},
	{"title": "Maid Chat", "tag": "App", "body": "Recovered maid-chat assets imply a home app entry for character communication.", "state": "Open"},
	{"title": "Collection", "tag": "Archive", "body": "CollectionSaveData and block collection tables are staged from IL2CPP/table evidence.", "state": "View"},
	{"title": "Inventory Link", "tag": "Merge", "body": "The exact UIPopup_Inventory shell currently lives under UIInGame Bag.", "state": "Sync"},
]

const MENU_CARDS := [
	{"title": "Profile", "tag": "Account", "body": "Player/account surface placeholder until service binding is reconstructed.", "state": "Guest"},
	{"title": "Announcements", "tag": "Info", "body": "Event and notice shortcuts complement the top Mail popup.", "state": "Open"},
	{"title": "Support", "tag": "Help", "body": "Contact/support entry mirrors the recovered Reload contact button surface.", "state": "Link"},
	{"title": "Credits", "tag": "Info", "body": "Legal, version, and external service details are staged here.", "state": "Info"},
]

const ICON_PATHS := {
	"bag": "res://assets/characters/maid_chat/Appicon_MaidChatBot.png",
	"menu": "res://assets/loading/LoadingIcon64.png",
}

var open := false
var mode := "bag"
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_popup_state(next_open: bool, next_mode := "bag") -> void:
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
	draw_rect(panel, Color(0.058, 0.06, 0.056, 0.98), true)
	draw_rect(panel, Color(0.88, 0.72, 0.48, 0.86), false, 2.0)
	_draw_header(panel)
	_draw_cards(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 74))
	draw_rect(header, Color(0.14, 0.12, 0.095, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.88, 0.72, 0.48, 0.74), true)
	var icon_rect := Rect2(header.position + Vector2(22, 16), Vector2(42, 42))
	var texture := _texture_for(String(ICON_PATHS.get(mode, "")))
	if texture != null:
		draw_texture_rect(texture, icon_rect, false, Color(1, 1, 1, 0.94))
	else:
		draw_circle(icon_rect.get_center(), 17, Color(0.82, 0.64, 0.38, 0.88))
	draw_string(ThemeDB.fallback_font, header.position + Vector2(78, 40), _title(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 150, 24, Color(1.0, 0.92, 0.74, 0.98))
	draw_string(ThemeDB.fallback_font, header.position + Vector2(78, 60), _subtitle(), HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 150, 12, Color(0.84, 0.74, 0.6, 0.84))

func _draw_cards(panel: Rect2) -> void:
	var body := Rect2(panel.position + Vector2(22, 94), Vector2(panel.size.x - 44, panel.size.y - 124))
	draw_rect(body, Color(0.04, 0.043, 0.04, 0.84), true)
	draw_rect(body, Color(0.56, 0.48, 0.35, 0.42), false, 1.0)
	var cards: Array = BAG_CARDS if mode == "bag" else MENU_CARDS
	var columns := 2
	var gap := Vector2(12, 12)
	var card_size := Vector2((body.size.x - 44 - gap.x) / 2.0, (body.size.y - 44 - gap.y) / 2.0)
	for index in range(cards.size()):
		var column := index % columns
		var row := int(index / columns)
		var rect := Rect2(body.position + Vector2(16 + float(column) * (card_size.x + gap.x), 18 + float(row) * (card_size.y + gap.y)), card_size)
		var card: Dictionary = cards[index]
		_draw_card(rect, card)

func _draw_card(rect: Rect2, card: Dictionary) -> void:
	draw_rect(rect, Color(0.118, 0.1, 0.078, 0.94), true)
	draw_rect(rect, Color(0.62, 0.5, 0.32, 0.55), false, 1.0)
	var badge := Rect2(rect.position + Vector2(10, 10), Vector2(72, 22))
	draw_rect(badge, Color(0.24, 0.15, 0.08, 0.96), true)
	draw_string(ThemeDB.fallback_font, badge.position + Vector2(0, 16), String(card.get("tag", "")), HORIZONTAL_ALIGNMENT_CENTER, badge.size.x, 10, Color(0.98, 0.82, 0.56, 0.95))
	var marker_center := rect.position + Vector2(35, 68)
	draw_circle(marker_center, 20, Color(0.34, 0.28, 0.2, 0.95))
	draw_rect(Rect2(marker_center - Vector2(10, 10), Vector2(20, 20)), Color(0.92, 0.72, 0.42, 0.76), false, 1.4)
	var text_x := rect.position.x + 72
	draw_string(ThemeDB.fallback_font, Vector2(text_x, rect.position.y + 58), String(card.get("title", "")), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 84, 15, Color(1.0, 0.9, 0.72, 0.96))
	draw_multiline_string(ThemeDB.fallback_font, Vector2(text_x, rect.position.y + 80), String(card.get("body", "")), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 84, 10, 3, Color(0.76, 0.68, 0.54, 0.88))
	var action := Rect2(rect.position + Vector2(rect.size.x - 78, rect.size.y - 34), Vector2(64, 24))
	draw_rect(action, Color(0.28, 0.17, 0.09, 0.98), true)
	draw_rect(action, Color(0.92, 0.69, 0.42, 0.78), false, 1.0)
	draw_string(ThemeDB.fallback_font, action.position + Vector2(0, 17), String(card.get("state", "")), HORIZONTAL_ALIGNMENT_CENTER, action.size.x, 10, Color(1.0, 0.9, 0.72, 0.94))

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
	return "Cafe App" if mode == "bag" else "Menu"

func _subtitle() -> String:
	return "Items / chat / collection" if mode == "bag" else "Profile / notices / support"

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]
