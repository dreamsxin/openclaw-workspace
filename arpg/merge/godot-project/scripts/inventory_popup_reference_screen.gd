class_name InventoryPopupReferenceScreen
extends Control

signal close_requested

var open := false
var selected: Dictionary = {}
var board_blocks: Array = []
var wallet: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func set_popup_open(next_open: bool) -> void:
	open = next_open
	visible = open
	mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_inventory_state(next_selected: Dictionary, next_board_blocks: Array, next_wallet: Dictionary) -> void:
	selected = next_selected.duplicate(true)
	board_blocks = next_board_blocks.duplicate(true)
	wallet = next_wallet.duplicate(true)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not open:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _close_rect().has_point(event.position) or not _popup_rect().has_point(event.position):
			emit_signal("close_requested")
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.48), true)
	var popup_rect := _popup_rect()
	draw_rect(popup_rect, Color(0.12, 0.09, 0.07, 0.98), true)
	draw_rect(popup_rect, Color(0.92, 0.74, 0.44, 0.9), false, 2.0)
	_draw_header(popup_rect)
	_draw_tabs(popup_rect)
	_draw_slot_sections(popup_rect)
	_draw_close_button()

func _draw_header(popup_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(popup_rect.position, Vector2(popup_rect.size.x, 58)), Color(0.2, 0.13, 0.08, 0.98), true)
	draw_string(font, popup_rect.position + Vector2(24, 38), "Inventory", HORIZONTAL_ALIGNMENT_LEFT, popup_rect.size.x - 96, 24, Color(1.0, 0.92, 0.74, 0.98))
	draw_string(font, popup_rect.position + Vector2(24, 78), "UIPopup_Inventory / ProduceInventory / NormalInventory", HORIZONTAL_ALIGNMENT_LEFT, popup_rect.size.x - 48, 14, Color(0.86, 0.76, 0.62, 0.86))

func _draw_tabs(popup_rect: Rect2) -> void:
	var produce_tab := Rect2(popup_rect.position + Vector2(24, 98), Vector2(popup_rect.size.x * 0.42, 34))
	var normal_tab := Rect2(popup_rect.position + Vector2(popup_rect.size.x * 0.52, 98), Vector2(popup_rect.size.x * 0.42, 34))
	draw_rect(produce_tab, Color(0.33, 0.22, 0.1, 0.96), true)
	draw_rect(normal_tab, Color(0.18, 0.15, 0.11, 0.96), true)
	draw_rect(produce_tab, Color(0.95, 0.76, 0.42, 0.74), false, 1.2)
	draw_rect(normal_tab, Color(0.62, 0.5, 0.36, 0.58), false, 1.2)
	var font := ThemeDB.fallback_font
	draw_string(font, produce_tab.position + Vector2(0, 23), "ProduceInventory", HORIZONTAL_ALIGNMENT_CENTER, produce_tab.size.x, 15, Color(1, 0.92, 0.74, 0.95))
	draw_string(font, normal_tab.position + Vector2(0, 23), "NormalInventory", HORIZONTAL_ALIGNMENT_CENTER, normal_tab.size.x, 15, Color(0.88, 0.82, 0.72, 0.92))

func _draw_slot_sections(popup_rect: Rect2) -> void:
	var left_rect := Rect2(popup_rect.position + Vector2(24, 148), Vector2(popup_rect.size.x * 0.45, popup_rect.size.y - 194))
	var right_rect := Rect2(popup_rect.position + Vector2(popup_rect.size.x * 0.52, 148), Vector2(popup_rect.size.x * 0.42, popup_rect.size.y - 194))
	_draw_section(left_rect, "Produce slots", true)
	_draw_section(right_rect, "Normal slots", false)

func _draw_section(section_rect: Rect2, title: String, produce_slots: bool) -> void:
	draw_rect(section_rect, Color(0.045, 0.04, 0.035, 0.84), true)
	draw_rect(section_rect, Color(0.74, 0.6, 0.38, 0.42), false, 1.2)
	var font := ThemeDB.fallback_font
	draw_string(font, section_rect.position + Vector2(14, 26), title, HORIZONTAL_ALIGNMENT_LEFT, section_rect.size.x - 28, 17, Color(1.0, 0.9, 0.7, 0.94))
	var slots := _slot_payloads(produce_slots)
	var columns := 3
	var gap := 8.0
	var slot_size := minf((section_rect.size.x - 28.0 - gap * float(columns - 1)) / float(columns), 62.0)
	for index in range(9):
		var col := index % columns
		var row := index / columns
		var pos := section_rect.position + Vector2(14 + float(col) * (slot_size + gap), 44 + float(row) * (slot_size + 28))
		var slot_data: Dictionary = slots[index] if index < slots.size() else {}
		_draw_slot(Rect2(pos, Vector2(slot_size, slot_size)), slot_data, produce_slots, index)
	draw_string(font, section_rect.position + Vector2(14, section_rect.size.y - 14), "%s/%s" % [mini(slots.size(), 9), 9], HORIZONTAL_ALIGNMENT_LEFT, section_rect.size.x - 28, 14, Color(0.86, 0.78, 0.64, 0.86))

func _draw_slot(slot_rect: Rect2, slot_data: Dictionary, produce_slot: bool, index: int) -> void:
	draw_rect(slot_rect, Color(0.16, 0.12, 0.08, 0.96), true)
	draw_rect(slot_rect, Color(0.94, 0.72, 0.42, 0.65), false, 1.2)
	var font := ThemeDB.fallback_font
	if slot_data.is_empty():
		draw_string(font, slot_rect.position + Vector2(0, slot_rect.size.y * 0.5 + 5), "+", HORIZONTAL_ALIGNMENT_CENTER, slot_rect.size.x, 22, Color(0.74, 0.62, 0.44, 0.7))
		return
	var texture_path := String(slot_data.get("sprite", ""))
	var texture: Texture2D = load(texture_path) if not texture_path.is_empty() else null
	if texture != null:
		draw_texture_rect(texture, slot_rect.grow(-6.0), false, Color(1, 1, 1, 0.96))
	else:
		draw_rect(slot_rect.grow(-8.0), Color(0.38, 0.32, 0.22, 0.88), true)
	draw_string(font, slot_rect.position + Vector2(4, 15), "L%s" % slot_data.get("level", "?"), HORIZONTAL_ALIGNMENT_LEFT, slot_rect.size.x - 8, 12, Color(1, 0.96, 0.8, 0.96))
	if produce_slot:
		draw_string(font, slot_rect.position + Vector2(0, slot_rect.size.y + 14), "P%s" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, slot_rect.size.x, 11, Color(0.86, 0.78, 0.64, 0.88))

func _draw_close_button() -> void:
	var close_rect := _close_rect()
	draw_rect(close_rect, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close_rect, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close_rect.position + Vector2(0, 27), "X", HORIZONTAL_ALIGNMENT_CENTER, close_rect.size.x, 21, Color(1, 0.92, 0.78, 0.96))

func _slot_payloads(produce_slots: bool) -> Array:
	var payloads: Array = []
	if produce_slots and not selected.is_empty() and bool(selected.get("has_produce", false)):
		payloads.append(selected)
	for block in board_blocks:
		if typeof(block) != TYPE_DICTIONARY:
			continue
		var is_produce := bool(block.get("has_produce", false))
		if is_produce == produce_slots and payloads.size() < 9:
			payloads.append(block)
	return payloads

func _popup_rect() -> Rect2:
	var width := minf(size.x * 0.9, 500.0)
	var height := minf(size.y * 0.68, 620.0)
	var top := clampf(size.y * 0.28, 170.0, maxf(170.0, size.y - height - 36.0))
	return Rect2(Vector2((size.x - width) * 0.5, top), Vector2(width, height))

func _close_rect() -> Rect2:
	var popup_rect := _popup_rect()
	return Rect2(popup_rect.position + Vector2(popup_rect.size.x - 50, 12), Vector2(38, 38))
