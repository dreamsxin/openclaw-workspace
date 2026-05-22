class_name ShopPopupReferenceScreen
extends Control

signal close_requested

const TAB_LABELS := ["Normal", "Ads", "Package", "Event"]
const PRODUCT_ROWS := [
	{
		"title": "Daily AP",
		"tag": "Rewarded",
		"price": "Watch Ad",
		"icon": "res://assets/sprites/CURRENCY_AP.png",
		"note": "AP refill surfaced by ad/service evidence.",
	},
	{
		"title": "Gold Pack",
		"tag": "Normal",
		"price": "120 Jewel",
		"icon": "res://assets/sprites/CURRENCY_GOLD.png",
		"note": "Currency shop row placeholder for UIList_ShopNormal.",
	},
	{
		"title": "Maid Gift Box",
		"tag": "Package",
		"price": "300 Jewel",
		"icon": "res://assets/sprites/CURRENCY_JEWEL.png",
		"note": "Gift and package flow pending table binding.",
	},
	{
		"title": "Memory Ticket",
		"tag": "Event",
		"price": "Event",
		"icon": "res://assets/sprites/SubStory_MemoryBox.png",
		"note": "Memory/event shop variants are present in prefab evidence.",
	},
]

var open := false
var wallet: Dictionary = {}
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_popup_state(next_open: bool, next_wallet: Dictionary = {}) -> void:
	open = next_open
	wallet = next_wallet
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
	draw_rect(panel, Color(0.075, 0.06, 0.052, 0.98), true)
	draw_rect(panel, Color(0.92, 0.72, 0.45, 0.9), false, 2.0)
	_draw_header(panel)
	_draw_wallet(panel)
	_draw_tabs(panel)
	_draw_product_grid(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 60))
	draw_rect(header, Color(0.19, 0.12, 0.085, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.92, 0.72, 0.45, 0.75), true)
	draw_string(ThemeDB.fallback_font, header.position + Vector2(24, 39), "Shop", HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 92, 24, Color(1.0, 0.92, 0.74, 0.98))
	draw_string(ThemeDB.fallback_font, header.position + Vector2(104, 38), "UIPopup_Shop / UIList_ShopNormal", HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 170, 13, Color(0.86, 0.74, 0.58, 0.86))

func _draw_wallet(panel: Rect2) -> void:
	var start := panel.position + Vector2(24, 74)
	var entries := [
		{"label": "AP", "value": _wallet_text("ap"), "icon": "res://assets/sprites/CURRENCY_AP.png"},
		{"label": "Gold", "value": _wallet_text("gold"), "icon": "res://assets/sprites/CURRENCY_GOLD.png"},
		{"label": "Jewel", "value": _wallet_text("jewel"), "icon": "res://assets/sprites/CURRENCY_JEWEL.png"},
	]
	var pill_width := minf((panel.size.x - 72) / 3.0, 145.0)
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var pill := Rect2(start + Vector2(float(index) * (pill_width + 12), 0), Vector2(pill_width, 34))
		draw_rect(pill, Color(0.13, 0.1, 0.075, 0.92), true)
		draw_rect(pill, Color(0.64, 0.5, 0.32, 0.5), false, 1.0)
		var icon_rect := Rect2(pill.position + Vector2(8, 7), Vector2(20, 20))
		var texture := _texture_for(String(entry.get("icon", "")))
		if texture != null:
			draw_texture_rect(texture, icon_rect, false)
		else:
			draw_circle(icon_rect.get_center(), 8, Color(0.82, 0.62, 0.34, 0.86))
		draw_string(ThemeDB.fallback_font, pill.position + Vector2(34, 22), "%s %s" % [String(entry.get("label", "")), String(entry.get("value", ""))], HORIZONTAL_ALIGNMENT_LEFT, pill.size.x - 42, 12, Color(0.94, 0.84, 0.66, 0.95))

func _draw_tabs(panel: Rect2) -> void:
	var tab_y := panel.position.y + 126
	var tab_w := (panel.size.x - 64) / float(TAB_LABELS.size())
	for index in range(TAB_LABELS.size()):
		var tab := Rect2(Vector2(panel.position.x + 24 + float(index) * tab_w, tab_y), Vector2(tab_w - 4, 34))
		var active := index == 0
		draw_rect(tab, Color(0.27, 0.16, 0.09, 0.96) if active else Color(0.105, 0.086, 0.07, 0.9), true)
		draw_rect(tab, Color(0.92, 0.69, 0.42, 0.78) if active else Color(0.54, 0.42, 0.28, 0.45), false, 1.0)
		draw_string(ThemeDB.fallback_font, tab.position + Vector2(0, 23), String(TAB_LABELS[index]), HORIZONTAL_ALIGNMENT_CENTER, tab.size.x, 12, Color(1.0, 0.9, 0.72, 0.95))

func _draw_product_grid(panel: Rect2) -> void:
	var grid := Rect2(panel.position + Vector2(24, 176), Vector2(panel.size.x - 48, panel.size.y - 206))
	var columns := 2
	var gap := Vector2(12, 12)
	var card_size := Vector2((grid.size.x - gap.x) / 2.0, (grid.size.y - gap.y) / 2.0)
	for index in range(PRODUCT_ROWS.size()):
		var column := index % columns
		var row := int(index / columns)
		var card := Rect2(grid.position + Vector2(float(column) * (card_size.x + gap.x), float(row) * (card_size.y + gap.y)), card_size)
		_draw_product_card(card, PRODUCT_ROWS[index])

func _draw_product_card(card: Rect2, product: Dictionary) -> void:
	draw_rect(card, Color(0.115, 0.09, 0.07, 0.94), true)
	draw_rect(card, Color(0.62, 0.48, 0.3, 0.55), false, 1.0)
	var tag := Rect2(card.position + Vector2(10, 9), Vector2(72, 22))
	draw_rect(tag, Color(0.24, 0.14, 0.08, 0.96), true)
	draw_string(ThemeDB.fallback_font, tag.position + Vector2(0, 16), String(product.get("tag", "")), HORIZONTAL_ALIGNMENT_CENTER, tag.size.x, 10, Color(0.98, 0.82, 0.56, 0.95))
	var icon_rect := Rect2(card.position + Vector2(12, 42), Vector2(50, 50))
	draw_rect(icon_rect.grow(4), Color(0.06, 0.052, 0.045, 0.88), true)
	var texture := _texture_for(String(product.get("icon", "")))
	if texture != null:
		draw_texture_rect(texture, icon_rect, false)
	else:
		draw_circle(icon_rect.get_center(), 18, Color(0.82, 0.62, 0.34, 0.86))
	var text_x := card.position.x + 76
	draw_string(ThemeDB.fallback_font, Vector2(text_x, card.position.y + 54), String(product.get("title", "")), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 88, 15, Color(1.0, 0.91, 0.72, 0.96))
	draw_multiline_string(ThemeDB.fallback_font, Vector2(text_x, card.position.y + 76), String(product.get("note", "")), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 88, 10, 3, Color(0.78, 0.68, 0.54, 0.86))
	var button := Rect2(card.position + Vector2(card.size.x - 102, card.size.y - 36), Vector2(88, 26))
	draw_rect(button, Color(0.31, 0.18, 0.08, 0.98), true)
	draw_rect(button, Color(0.96, 0.72, 0.42, 0.82), false, 1.0)
	draw_string(ThemeDB.fallback_font, button.position + Vector2(0, 18), String(product.get("price", "")), HORIZONTAL_ALIGNMENT_CENTER, button.size.x, 10, Color(1.0, 0.91, 0.74, 0.95))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.92, 560.0)
	var height := minf(size.y * 0.76, 530.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _wallet_text(key: String) -> String:
	return str(int(wallet.get(key, 0)))

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]
