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
var source: Dictionary = {}

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

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.075, 0.06, 0.052, 0.98), true)
	draw_rect(panel, Color(0.92, 0.72, 0.45, 0.9), false, 2.0)
	_draw_prefab_evidence(panel)
	_draw_header(panel)
	_draw_wallet(panel)
	_draw_tabs(panel)
	_draw_product_grid(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := _source_or_fallback("UIPopup_Shop/BG/Top/Title", Rect2(panel.position, Vector2(panel.size.x, 60)))
	draw_rect(header, Color(0.19, 0.12, 0.085, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.92, 0.72, 0.45, 0.75), true)
	var title := _source_or_fallback("UIPopup_Shop/BG/Top/Title/Text (TMP)", Rect2(header.position + Vector2(24, 0), Vector2(header.size.x - 92, header.size.y)))
	draw_string(ThemeDB.fallback_font, title.position + Vector2(0, minf(39.0, title.size.y - 12.0)), "Shop", HORIZONTAL_ALIGNMENT_LEFT, title.size.x, 24, Color(1.0, 0.92, 0.74, 0.98))
	draw_string(ThemeDB.fallback_font, header.position + Vector2(104, 38), "UIPopup_Shop / UIList_ShopNormal", HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 170, 13, Color(0.86, 0.74, 0.58, 0.86))

func _draw_wallet(panel: Rect2) -> void:
	var top := _source_or_fallback("UIPopup_Shop/BG/Top", Rect2(panel.position, Vector2(panel.size.x, 124)))
	var start := Vector2(panel.position.x + 24, maxf(panel.position.y + 74, top.end.y + 10))
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
	var scroll := _source_or_fallback("UIPopup_Shop/BG/Scroll View", Rect2(panel.position + Vector2(24, 166), Vector2(panel.size.x - 48, panel.size.y - 196)))
	var tab_y := maxf(panel.position.y + 126, scroll.position.y - 46)
	var tab_w := (panel.size.x - 64) / float(TAB_LABELS.size())
	for index in range(TAB_LABELS.size()):
		var tab := Rect2(Vector2(panel.position.x + 24 + float(index) * tab_w, tab_y), Vector2(tab_w - 4, 34))
		var active := index == 0
		draw_rect(tab, Color(0.27, 0.16, 0.09, 0.96) if active else Color(0.105, 0.086, 0.07, 0.9), true)
		draw_rect(tab, Color(0.92, 0.69, 0.42, 0.78) if active else Color(0.54, 0.42, 0.28, 0.45), false, 1.0)
		draw_string(ThemeDB.fallback_font, tab.position + Vector2(0, 23), String(TAB_LABELS[index]), HORIZONTAL_ALIGNMENT_CENTER, tab.size.x, 12, Color(1.0, 0.9, 0.72, 0.95))

func _draw_product_grid(panel: Rect2) -> void:
	var scroll := _source_or_fallback("UIPopup_Shop/BG/Scroll View/Viewport", Rect2(panel.position + Vector2(24, 176), Vector2(panel.size.x - 48, panel.size.y - 206)))
	var normal_list := _source_or_fallback("UIPopup_Shop/BG/Scroll View/Viewport/Content/UIList_ShopNormal", scroll)
	var grid := scroll.intersection(Rect2(panel.position + Vector2(24, 176), Vector2(panel.size.x - 48, panel.size.y - 206)))
	if not _rect_has_area(grid):
		grid = Rect2(panel.position + Vector2(24, 176), Vector2(panel.size.x - 48, panel.size.y - 206))
	_draw_shop_section_markers(panel, scroll, normal_list)
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
	var bg := _source_rect("UIPopup_Shop/BG")
	if _is_usable_rect(bg) and bg.size.y < size.y * 0.92:
		return bg
	var width := minf(size.x * 0.92, 560.0)
	var height := minf(size.y * 0.76, 530.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return _source_or_fallback("UIPopup_Shop/BG/Btn_Close", Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38)))

func _wallet_text(key: String) -> String:
	return str(int(wallet.get(key, 0)))

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

func _draw_prefab_evidence(panel: Rect2) -> void:
	var top := _source_or_fallback("UIPopup_Shop/BG/Top", Rect2(panel.position, Vector2(panel.size.x, 124)))
	draw_rect(top, Color(0.23, 0.13, 0.08, 0.42), true)
	var chat := _source_or_fallback("UIPopup_Shop/BG/Top/ChatBox", Rect2(top.position + Vector2(24, top.size.y - 44), Vector2(minf(top.size.x - 48, 270.0), 36)))
	draw_rect(chat, Color(0.12, 0.09, 0.07, 0.54), true)
	draw_rect(chat, Color(0.72, 0.56, 0.34, 0.34), false, 1.0)
	draw_string(ThemeDB.fallback_font, chat.position + Vector2(12, 24), "Welcome to the shop.", HORIZONTAL_ALIGNMENT_LEFT, chat.size.x - 24, 12, Color(0.9, 0.78, 0.58, 0.72))

func _draw_shop_section_markers(panel: Rect2, scroll: Rect2, normal_list: Rect2) -> void:
	var sections := [
		{"path": "UIPopup_Shop/BG/Scroll View/Viewport/Content/UIList_ShopNormal/Grid_Package", "label": "Package"},
		{"path": "UIPopup_Shop/BG/Scroll View/Viewport/Content/UIList_ShopNormal/BannerGroup", "label": "Ads"},
		{"path": "UIPopup_Shop/BG/Scroll View/Viewport/Content/UIList_ShopNormal/Grid_Costume", "label": "Costume"},
		{"path": "UIPopup_Shop/BG/Scroll View/Viewport/Content/UIList_ShopNormal/Grid_Daily", "label": "Daily"},
	]
	var marker_area := Rect2(scroll.position + Vector2(10, 8), Vector2(scroll.size.x - 20, 24))
	draw_rect(normal_list.intersection(scroll), Color(0.7, 0.5, 0.28, 0.08), false, 1.0)
	for index in range(sections.size()):
		var entry: Dictionary = sections[index]
		var fallback := Rect2(marker_area.position + Vector2(float(index) * (marker_area.size.x / float(sections.size())), 0), Vector2(marker_area.size.x / float(sections.size()) - 4, marker_area.size.y))
		var rect := _source_or_fallback(String(entry.get("path", "")), fallback)
		var visible_rect := rect.intersection(scroll)
		if not _rect_has_area(visible_rect) or visible_rect.size.y < 8.0:
			visible_rect = fallback
		draw_rect(visible_rect, Color(0.26, 0.16, 0.09, 0.34), true)
		draw_string(ThemeDB.fallback_font, visible_rect.position + Vector2(0, 17), String(entry.get("label", "")), HORIZONTAL_ALIGNMENT_CENTER, visible_rect.size.x, 10, Color(0.96, 0.82, 0.58, 0.75))

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

func _rect_has_area(rect: Rect2) -> bool:
	return rect.size.x > 0.0 and rect.size.y > 0.0

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
