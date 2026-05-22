class_name InventoryPopupReferenceScreen
extends Control

signal close_requested

var open := false
var selected: Dictionary = {}
var board_blocks: Array = []
var wallet: Dictionary = {}
var source: Dictionary = {}

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

func set_source(next_source: Dictionary) -> void:
	source = next_source
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
	var source_bg := _source_rect("UIPopup_Inventory/BG")
	if _is_usable_rect(source_bg) and source_bg.size.y < size.y * 0.86:
		draw_rect(source_bg, Color(0.7, 0.5, 0.28, 0.18), false, 1.0)
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
	var produce_tab := _source_or_fallback("UIPopup_Inventory/BG/ProduceInventory/Cover/Iron/Text (TMP)", Rect2(popup_rect.position + Vector2(24, 98), Vector2(popup_rect.size.x * 0.42, 34)))
	var normal_tab := _source_or_fallback("UIPopup_Inventory/BG/NormalInventory/BGGroup/Text (TMP)", Rect2(popup_rect.position + Vector2(popup_rect.size.x * 0.52, 98), Vector2(popup_rect.size.x * 0.42, 34)))
	draw_rect(produce_tab, Color(0.33, 0.22, 0.1, 0.96), true)
	draw_rect(normal_tab, Color(0.18, 0.15, 0.11, 0.96), true)
	draw_rect(produce_tab, Color(0.95, 0.76, 0.42, 0.74), false, 1.2)
	draw_rect(normal_tab, Color(0.62, 0.5, 0.36, 0.58), false, 1.2)
	var font := ThemeDB.fallback_font
	draw_string(font, produce_tab.position + Vector2(0, 23), "ProduceInventory", HORIZONTAL_ALIGNMENT_CENTER, produce_tab.size.x, 15, Color(1, 0.92, 0.74, 0.95))
	draw_string(font, normal_tab.position + Vector2(0, 23), "NormalInventory", HORIZONTAL_ALIGNMENT_CENTER, normal_tab.size.x, 15, Color(0.88, 0.82, 0.72, 0.92))

func _draw_slot_sections(popup_rect: Rect2) -> void:
	var left_rect := _source_or_fallback("UIPopup_Inventory/BG/ProduceInventory/ScrollViewMask", Rect2(popup_rect.position + Vector2(24, 148), Vector2(popup_rect.size.x * 0.45, popup_rect.size.y - 194)))
	var right_rect := _source_or_fallback("UIPopup_Inventory/BG/NormalInventory/BGGroup", Rect2(popup_rect.position + Vector2(popup_rect.size.x * 0.52, 148), Vector2(popup_rect.size.x * 0.42, popup_rect.size.y - 194)))
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
	return _source_or_fallback("UIPopup_Inventory/BG/Btn_Close", Rect2(popup_rect.position + Vector2(popup_rect.size.x - 50, 12), Vector2(38, 38)))

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
