class_name RequestDetailPopupReferenceScreen
extends Control

signal close_requested

const SPRITE_DIR := "res://assets/sprites/"
const REWARD_ICONS := {
	"ap": SPRITE_DIR + "CURRENCY_AP.png",
	"gold": SPRITE_DIR + "CURRENCY_GOLD.png",
	"jewel": SPRITE_DIR + "CURRENCY_JEWEL.png",
}

var open := false
var selected: Dictionary = {}
var board_items: Array = []
var wallet: Dictionary = {}
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_request_state(next_open: bool, next_selected: Dictionary, next_board_items: Array, next_wallet: Dictionary) -> void:
	open = next_open
	selected = next_selected.duplicate(true)
	board_items = next_board_items.duplicate(true)
	wallet = next_wallet.duplicate(true)
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
		if _deliver_rect().has_point(pos):
			emit_signal("close_requested")
			accept_event()
			return
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.44), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.1, 0.075, 0.06, 0.98), true)
	draw_rect(panel, Color(0.92, 0.72, 0.42, 0.92), false, 2.0)
	_draw_header(panel)
	_draw_required_item(panel)
	_draw_reward_row(panel)
	_draw_request_list(panel)
	_draw_deliver_button()
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 62))
	draw_rect(header, Color(0.2, 0.13, 0.085, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.92, 0.72, 0.42, 0.74), true)
	draw_string(ThemeDB.fallback_font, header.position + Vector2(22, 39), "Request", HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 90, 23, Color(1.0, 0.92, 0.72, 0.96))

func _draw_required_item(panel: Rect2) -> void:
	var request := _request_payload()
	var item_rect := Rect2(panel.position + Vector2(24, 84), Vector2(panel.size.x - 48, 122))
	draw_rect(item_rect, Color(0.05, 0.045, 0.038, 0.9), true)
	draw_rect(item_rect, Color(0.64, 0.5, 0.32, 0.48), false, 1.2)
	var icon_rect := Rect2(item_rect.position + Vector2(16, 16), Vector2(82, 82))
	draw_rect(icon_rect, Color(0.16, 0.11, 0.07, 0.94), true)
	var texture := _texture_for(String(request.get("sprite", "")))
	if texture != null:
		draw_texture_rect(texture, icon_rect.grow(-8), false, Color(1, 1, 1, 0.96))
	else:
		draw_string(ThemeDB.fallback_font, icon_rect.position + Vector2(0, 54), "?", HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x, 24, Color(0.9, 0.8, 0.62, 0.86))
	var name := String(request.get("name", request.get("id", "Item")))
	var level := String(request.get("level", "?"))
	draw_string(ThemeDB.fallback_font, item_rect.position + Vector2(116, 42), name, HORIZONTAL_ALIGNMENT_LEFT, item_rect.size.x - 138, 20, Color(1.0, 0.92, 0.72, 0.96))
	draw_string(ThemeDB.fallback_font, item_rect.position + Vector2(116, 72), "Need 1  Level %s" % level, HORIZONTAL_ALIGNMENT_LEFT, item_rect.size.x - 138, 15, Color(0.86, 0.76, 0.58, 0.88))

func _draw_reward_row(panel: Rect2) -> void:
	var reward_rect := Rect2(panel.position + Vector2(24, 222), Vector2(panel.size.x - 48, 88))
	draw_rect(reward_rect, Color(0.045, 0.04, 0.034, 0.88), true)
	draw_rect(reward_rect, Color(0.64, 0.5, 0.32, 0.42), false, 1.0)
	draw_string(ThemeDB.fallback_font, reward_rect.position + Vector2(14, 31), "Reward", HORIZONTAL_ALIGNMENT_LEFT, 96, 17, Color(0.94, 0.84, 0.64, 0.92))
	var rewards := [
		{"key": "gold", "value": 60},
		{"key": "ap", "value": 2},
		{"key": "jewel", "value": 1},
	]
	for index in range(rewards.size()):
		var reward: Dictionary = rewards[index]
		var slot := Rect2(reward_rect.position + Vector2(106 + float(index) * 84, 15), Vector2(72, 58))
		_draw_reward_slot(slot, String(reward["key"]), reward["value"])

func _draw_reward_slot(slot: Rect2, key: String, value) -> void:
	draw_rect(slot, Color(0.14, 0.1, 0.075, 0.92), true)
	draw_rect(slot, Color(0.72, 0.56, 0.34, 0.56), false, 1.0)
	var texture := _texture_for(String(REWARD_ICONS.get(key, "")))
	if texture != null:
		draw_texture_rect(texture, Rect2(slot.position + Vector2(8, 10), Vector2(28, 28)), false, Color(1, 1, 1, 0.96))
	draw_string(ThemeDB.fallback_font, slot.position + Vector2(38, 32), "x%s" % value, HORIZONTAL_ALIGNMENT_LEFT, slot.size.x - 42, 14, Color(1, 0.92, 0.72, 0.94))

func _draw_request_list(panel: Rect2) -> void:
	var list_rect := Rect2(panel.position + Vector2(24, 326), Vector2(panel.size.x - 48, 128))
	draw_rect(list_rect, Color(0.05, 0.045, 0.038, 0.82), true)
	draw_rect(list_rect, Color(0.54, 0.42, 0.28, 0.4), false, 1.0)
	draw_string(ThemeDB.fallback_font, list_rect.position + Vector2(14, 25), "Board candidates", HORIZONTAL_ALIGNMENT_LEFT, list_rect.size.x - 28, 15, Color(0.88, 0.78, 0.6, 0.86))
	var shown := mini(board_items.size(), 4)
	for index in range(shown):
		var item: Dictionary = board_items[index]
		var slot := Rect2(list_rect.position + Vector2(14 + float(index) * 58, 48), Vector2(48, 56))
		draw_rect(slot, Color(0.13, 0.095, 0.07, 0.9), true)
		var texture := _texture_for(String(item.get("sprite", "")))
		if texture != null:
			draw_texture_rect(texture, Rect2(slot.position + Vector2(5, 4), Vector2(38, 38)), false, Color(1, 1, 1, 0.94))
		draw_string(ThemeDB.fallback_font, slot.position + Vector2(0, 54), "L%s" % item.get("level", "?"), HORIZONTAL_ALIGNMENT_CENTER, slot.size.x, 10, Color(0.9, 0.8, 0.62, 0.84))

func _draw_deliver_button() -> void:
	var deliver := _deliver_rect()
	draw_rect(deliver, Color(0.26, 0.17, 0.08, 0.96), true)
	draw_rect(deliver, Color(1.0, 0.78, 0.4, 0.9), false, 1.5)
	draw_string(ThemeDB.fallback_font, deliver.position + Vector2(0, 32), "Deliver", HORIZONTAL_ALIGNMENT_CENTER, deliver.size.x, 17, Color(1, 0.92, 0.72, 0.96))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.92, 500.0)
	var height := minf(size.y * 0.7, 620.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _deliver_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.end - Vector2(142, 58), Vector2(116, 38))

func _request_payload() -> Dictionary:
	if not selected.is_empty():
		return selected
	if not board_items.is_empty():
		return board_items[0]
	return {}

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

