class_name InGameReferenceShell
extends Control

signal produce_requested
signal out_game_requested
signal inventory_requested

const SPRITE_DIR := "res://assets/sprites/"
const BACKDROP_TEXTURE_PATH := SPRITE_DIR + "BG_gameboard2.png"
const WALLET_ICONS := {
	"ap": SPRITE_DIR + "CURRENCY_AP.png",
	"gold": SPRITE_DIR + "CURRENCY_GOLD.png",
	"jewel": SPRITE_DIR + "CURRENCY_JEWEL.png",
}
const ORIGINAL_BOTTOM_SIDE_BUTTON := 150.0
const ORIGINAL_BOTTOM_INFO_HEIGHT := 160.0
const ORIGINAL_BOTTOM_ACTION_BUTTON := 100.0

var source: Dictionary = {}
var wallet: Dictionary = {}
var selected: Dictionary = {}
var action_regions: Dictionary = {}
var backdrop_texture: Texture2D
var wallet_icon_textures: Dictionary = {}

func _ready() -> void:
	backdrop_texture = load(BACKDROP_TEXTURE_PATH)
	for key in WALLET_ICONS.keys():
		wallet_icon_textures[key] = load(WALLET_ICONS[key])
	set_process(true)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func set_source(next_source: Dictionary) -> void:
	source = next_source
	_rebuild_action_regions()
	queue_redraw()

func set_wallet(next_wallet: Dictionary) -> void:
	wallet = next_wallet.duplicate(true)
	queue_redraw()

func set_selected_block(next_selected: Dictionary) -> void:
	selected = next_selected.duplicate(true)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var action := _action_at(event.position)
		if action == "produce":
			emit_signal("produce_requested")
			accept_event()
		elif action == "out_game":
			emit_signal("out_game_requested")
			accept_event()
		elif action == "inventory":
			emit_signal("inventory_requested")
			accept_event()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_rebuild_action_regions()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.34, 0.22, 0.14, 1.0), true)
	if source.is_empty():
		_draw_fallback_shell()
		return
	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	_draw_game_backdrop(screen_rect)
	_draw_request_operation_strip(screen_rect)
	_draw_top_wallet(screen_rect)
	_draw_bottom_operation_bar(screen_rect)

func _draw_fallback_shell() -> void:
	var top_rect := Rect2(Vector2(0, 0), Vector2(size.x, 86))
	var bottom_rect := Rect2(Vector2(0, size.y - 150), Vector2(size.x, 150))
	draw_rect(top_rect, Color(0.1, 0.13, 0.13, 0.88), true)
	draw_rect(bottom_rect, Color(0.16, 0.11, 0.08, 0.9), true)
	_draw_top_wallet(Rect2(Vector2.ZERO, size))

func _draw_game_backdrop(screen_rect: Rect2) -> void:
	var wall_rect := Rect2(screen_rect.position, Vector2(screen_rect.size.x, screen_rect.size.y * 0.38))
	var floor_rect := Rect2(screen_rect.position + Vector2(0, screen_rect.size.y * 0.38), Vector2(screen_rect.size.x, screen_rect.size.y * 0.62))
	if backdrop_texture != null:
		draw_rect(wall_rect, Color(0.94, 0.82, 0.66, 0.98), true)
		draw_texture_rect(backdrop_texture, wall_rect, false, Color(1, 1, 1, 0.92))
		draw_rect(floor_rect, Color(0.62, 0.39, 0.24, 0.98), true)
	else:
		draw_rect(wall_rect, Color(0.94, 0.82, 0.66, 0.98), true)
		draw_rect(floor_rect, Color(0.62, 0.39, 0.24, 0.98), true)
	for index in range(5):
		var y := floor_rect.position.y + floor_rect.size.y * (float(index) + 1.0) / 6.0
		draw_line(Vector2(floor_rect.position.x, y), Vector2(floor_rect.end.x, y + 28.0), Color(0.2, 0.11, 0.06, 0.32), 2.0)
	draw_line(Vector2(screen_rect.position.x, floor_rect.position.y), Vector2(screen_rect.end.x, floor_rect.position.y), Color(0.25, 0.14, 0.07, 0.72), 3.0)

func _draw_top_wallet(screen_rect: Rect2) -> void:
	var top_rect := Rect2(screen_rect.position + Vector2(12, 12), Vector2(screen_rect.size.x - 24, 52))
	draw_rect(top_rect, Color(0.04, 0.05, 0.05, 0.82), true)
	draw_rect(top_rect, Color(0.86, 0.76, 0.52, 0.44), false, 1.5)
	var labels := [
		["ap", "%s" % wallet.get("ap", 0)],
		["gold", "%s" % wallet.get("gold", 0)],
		["jewel", "%s" % wallet.get("jewel", 0)],
	]
	var segment_width := top_rect.size.x / 3.0
	for index in range(labels.size()):
		var key: String = labels[index][0]
		var value: String = labels[index][1]
		var segment := Rect2(top_rect.position + Vector2(segment_width * index, 0), Vector2(segment_width, top_rect.size.y))
		var icon: Texture2D = wallet_icon_textures.get(key, null)
		var text_x := segment.position.x + segment_width * 0.48
		if icon != null:
			var icon_size := Vector2(26, 26)
			var icon_rect := Rect2(Vector2(segment.position.x + segment_width * 0.24 - icon_size.x * 0.5, segment.position.y + 13), icon_size)
			draw_texture_rect(icon, icon_rect, false, Color(1, 1, 1, 0.96))
		draw_string(ThemeDB.fallback_font, Vector2(text_x, segment.position.y + 34), value, HORIZONTAL_ALIGNMENT_LEFT, segment_width * 0.45, 18, Color(1, 0.94, 0.76, 0.95))

func _draw_recovered_panel(suffix: String, fill: Color, stroke: Color, reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var rect := _to_preview_rect_world(_rect_by_suffix(suffix), reference_size, scale_factor, origin)
	if rect.size == Vector2.ZERO:
		return
	if rect.size.x * rect.size.y < size.x * size.y * 0.42:
		draw_rect(rect, fill, true)
	draw_rect(rect, stroke, false, 1.5)

func _draw_request_operation_strip(screen_rect: Rect2) -> void:
	var layout := _request_layout(screen_rect)
	var strip_rect: Rect2 = layout.get("strip", Rect2())
	if strip_rect.size == Vector2.ZERO:
		return
	draw_rect(strip_rect, Color(0.09, 0.07, 0.045, 0.62), true)
	draw_rect(strip_rect, Color(0.78, 0.58, 0.34, 0.42), false, 1.0)
	_draw_request_card(layout.get("quest", Rect2()))
	var rewards: Array = layout.get("rewards", [])
	var reward_payloads := _request_reward_payloads()
	for index in range(rewards.size()):
		var payload: Dictionary = reward_payloads[index] if index < reward_payloads.size() else {}
		_draw_reward_slot(rewards[index], payload)
	_draw_skill_cards(layout.get("skills", []))

func _draw_request_card(card_rect: Rect2) -> void:
	if card_rect.size == Vector2.ZERO:
		return
	draw_rect(card_rect, Color(0.18, 0.12, 0.07, 0.92), true)
	draw_rect(card_rect, Color(0.95, 0.74, 0.42, 0.8), false, 1.2)
	var icon_rect := Rect2(card_rect.position + Vector2(8, 8), Vector2(minf(42.0, card_rect.size.x * 0.36), minf(42.0, card_rect.size.y - 16.0)))
	var payloads := _request_reward_payloads()
	var first_payload: Dictionary = payloads[0] if not payloads.is_empty() else selected
	if not first_payload.is_empty():
		var texture: Texture2D = load(String(first_payload.get("sprite", "")))
		if texture != null:
			draw_texture_rect(texture, icon_rect, false, Color(1, 1, 1, 0.96))
		else:
			draw_rect(icon_rect, Color(0.34, 0.25, 0.16, 0.94), true)
	else:
		draw_rect(icon_rect, Color(0.34, 0.25, 0.16, 0.94), true)
		draw_string(ThemeDB.fallback_font, icon_rect.position + Vector2(0, icon_rect.size.y * 0.58), "?", HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x, 16, Color(0.9, 0.8, 0.62, 0.86))
	var title := "Request"
	var detail := "Need block"
	if not first_payload.is_empty():
		title = String(first_payload.get("name", first_payload.get("id", "Request")))
		detail = "Need L%s block" % first_payload.get("level", "?")
	draw_string(ThemeDB.fallback_font, card_rect.position + Vector2(icon_rect.size.x + 16, 26), title, HORIZONTAL_ALIGNMENT_LEFT, card_rect.size.x - icon_rect.size.x - 24, 13, Color(1, 0.94, 0.74, 0.96))
	draw_string(ThemeDB.fallback_font, card_rect.position + Vector2(icon_rect.size.x + 16, 44), detail, HORIZONTAL_ALIGNMENT_LEFT, card_rect.size.x - icon_rect.size.x - 24, 10, Color(0.86, 0.76, 0.58, 0.88))

func _draw_reward_slot(slot_rect: Rect2, payload: Dictionary) -> void:
	if slot_rect.size == Vector2.ZERO:
		return
	draw_rect(slot_rect, Color(0.16, 0.11, 0.07, 0.9), true)
	draw_rect(slot_rect, Color(0.86, 0.66, 0.38, 0.64), false, 1.0)
	if payload.is_empty():
		draw_circle(slot_rect.position + slot_rect.size * 0.5, slot_rect.size.x * 0.18, Color(0.52, 0.42, 0.28, 0.78))
		return
	var texture: Texture2D = load(String(payload.get("sprite", "")))
	if texture != null:
		draw_texture_rect(texture, slot_rect.grow(-5.0), false, Color(1, 1, 1, 0.96))
	else:
		draw_circle(slot_rect.position + slot_rect.size * 0.5, slot_rect.size.x * 0.2, Color(0.82, 0.62, 0.34, 0.86))
	draw_string(ThemeDB.fallback_font, slot_rect.position + Vector2(0, slot_rect.size.y - 4), "x1", HORIZONTAL_ALIGNMENT_CENTER, slot_rect.size.x, 9, Color(1, 0.92, 0.72, 0.94))

func _draw_skill_cards(skill_rects: Array) -> void:
	for index in range(skill_rects.size()):
		var rect: Rect2 = skill_rects[index]
		draw_rect(rect, Color(0.08, 0.065, 0.052, 0.82), true)
		draw_rect(rect, Color(0.55, 0.44, 0.3, 0.52), false, 1.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.58), "S%s" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 9, Color(0.78, 0.68, 0.52, 0.86))

func _draw_bottom_operation_bar(screen_rect: Rect2) -> void:
	var layout := _operation_layout(screen_rect)
	var bar_rect: Rect2 = layout.get("bar", Rect2())
	if bar_rect.size == Vector2.ZERO:
		return
	draw_rect(bar_rect, Color(0.11, 0.075, 0.045, 0.9), true)
	draw_rect(bar_rect, Color(0.78, 0.58, 0.34, 0.5), false, 1.5)
	_draw_selected_block_info(screen_rect)
	_draw_side_action_button("inventory", "Bag", layout.get("inventory", Rect2()))
	_draw_side_action_button("out_game", "Cafe", layout.get("out_game", Rect2()))
	_draw_block_operation_buttons(layout)

func _draw_selected_block_info(screen_rect: Rect2) -> void:
	var info_rect: Rect2 = action_regions.get("block_info", Rect2())
	if info_rect.size == Vector2.ZERO:
		info_rect = Rect2(screen_rect.position + Vector2(22, screen_rect.size.y - 142), Vector2(screen_rect.size.x - 44, 88))
	draw_rect(info_rect, Color(0.04, 0.045, 0.045, 0.72), true)
	draw_rect(info_rect, Color(0.9, 0.72, 0.45, 0.4), false, 1.2)
	var label: String = "Select a block"
	var icon_rect := Rect2(info_rect.position + Vector2(10, 12), Vector2(minf(52.0, info_rect.size.y - 24.0), minf(52.0, info_rect.size.y - 24.0)))
	if not selected.is_empty():
		label = "%s  L%s\nEnergy %s/%s%s" % [
			selected.get("name", selected.get("id", "")),
			selected.get("level", "?"),
			selected.get("energy", 0),
			selected.get("max_energy", 0),
			"  Producer" if bool(selected.get("has_produce", false)) else "",
		]
		var texture: Texture2D = load(String(selected.get("sprite", "")))
		if texture != null:
			draw_texture_rect(texture, icon_rect, false, Color(1, 1, 1, 0.96))
		else:
			draw_rect(icon_rect, Color(0.25, 0.2, 0.14, 0.92), true)
	else:
		draw_rect(icon_rect, Color(0.2, 0.16, 0.11, 0.74), true)
		draw_string(ThemeDB.fallback_font, icon_rect.position + Vector2(0, icon_rect.size.y * 0.55 + 5), "?", HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x, 18, Color(0.85, 0.76, 0.58, 0.8))
	var text_left := icon_rect.end.x + 8.0
	var text_width := maxf(0.0, info_rect.size.x - (text_left - info_rect.position.x) - 170.0)
	draw_multiline_string(ThemeDB.fallback_font, Vector2(text_left, info_rect.position.y + 24), label, HORIZONTAL_ALIGNMENT_LEFT, text_width, 15, 3, Color(1, 0.93, 0.75, 0.96))

func _draw_side_action_button(action: String, label: String, rect: Rect2) -> void:
	if rect.size == Vector2.ZERO:
		return
	var hover: bool = rect.has_point(get_local_mouse_position())
	draw_rect(rect, Color(0.22, 0.17, 0.1, 0.92) if hover else Color(0.12, 0.1, 0.08, 0.82), true)
	draw_rect(rect, Color(1.0, 0.82, 0.48, 0.92) if hover else Color(0.92, 0.73, 0.42, 0.7), false, 2.0 if hover else 1.4)
	var icon_center := rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.42)
	draw_circle(icon_center, minf(rect.size.x, rect.size.y) * 0.2, Color(0.82, 0.62, 0.34, 0.85))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y - 15), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color(1, 0.94, 0.78, 0.98))

func _draw_block_operation_buttons(layout: Dictionary) -> void:
	var button_specs := [
		{"key": "produce", "label": "Open", "enabled": bool(selected.get("has_produce", false))},
		{"key": "use", "label": "Use", "enabled": not selected.is_empty()},
		{"key": "cool_time", "label": "Time", "enabled": bool(selected.get("has_produce", false))},
	]
	for spec in button_specs:
		var rect: Rect2 = layout.get(String(spec["key"]), Rect2())
		if rect.size == Vector2.ZERO:
			continue
		var enabled := bool(spec["enabled"])
		var hover := enabled and rect.has_point(get_local_mouse_position())
		var fill := Color(0.26, 0.18, 0.09, 0.96) if enabled else Color(0.08, 0.075, 0.065, 0.74)
		var stroke := Color(1.0, 0.8, 0.42, 0.96) if hover else Color(0.72, 0.55, 0.32, 0.62)
		draw_rect(rect, fill, true)
		draw_rect(rect, stroke, false, 1.4)
		var icon_color := Color(1.0, 0.77, 0.34, 0.92) if enabled else Color(0.42, 0.36, 0.28, 0.72)
		draw_circle(rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.38), rect.size.x * 0.18, icon_color)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y - 8), String(spec["label"]), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 10, Color(1, 0.9, 0.7, 0.92) if enabled else Color(0.58, 0.52, 0.44, 0.82))

	var premium_rects := [
		[layout.get("gold_open", Rect2()), "Gold"],
		[layout.get("cash", Rect2()), "Cash"],
	]
	for item in premium_rects:
		var rect: Rect2 = item[0]
		if rect.size == Vector2.ZERO:
			continue
		draw_rect(rect, Color(0.09, 0.08, 0.065, 0.72), true)
		draw_rect(rect, Color(0.52, 0.42, 0.28, 0.52), false, 1.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.58), String(item[1]), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 9, Color(0.62, 0.55, 0.43, 0.84))

func _reference_size() -> Vector2:
	var resolution: Dictionary = source.get("reference_resolution", {})
	return Vector2(float(resolution.get("width", 1080)), float(resolution.get("height", 1920)))

func _rect_by_suffix(suffix: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")).ends_with(suffix):
			return rect
	return {}

func _rect_by_path(path: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")) == path:
			return rect
	return {}

func _to_preview_rect_world(rect: Dictionary, reference_size: Vector2, scale_factor: float, origin: Vector2) -> Rect2:
	if rect.is_empty():
		return Rect2()
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

func _rebuild_action_regions() -> void:
	action_regions.clear()
	if size == Vector2.ZERO:
		return
	if source.is_empty():
		var bottom_y: float = size.y - 122
		action_regions["produce"] = Rect2(Vector2(size.x - 160, bottom_y + 58), Vector2(130, 38))
		action_regions["out_game"] = Rect2(Vector2(22, bottom_y + 58), Vector2(90, 38))
		action_regions["inventory"] = Rect2(Vector2(122, bottom_y + 58), Vector2(90, 38))
		action_regions["block_info"] = Rect2(Vector2(22, bottom_y - 24), Vector2(size.x - 44, 72))
		return
	var reference_size: Vector2 = _reference_size()
	var scale_factor: float = minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size: Vector2 = reference_size * scale_factor
	var origin: Vector2 = (size - viewport_size) * 0.5
	var layout := _operation_layout(Rect2(origin, viewport_size))
	action_regions["out_game"] = layout.get("out_game", Rect2())
	action_regions["inventory"] = layout.get("inventory", Rect2())
	action_regions["block_info"] = layout.get("block_info", Rect2())
	action_regions["produce"] = layout.get("produce", Rect2())

func _operation_layout(screen_rect: Rect2) -> Dictionary:
	var scale_factor := screen_rect.size.x / 1080.0
	var side_size := clampf(ORIGINAL_BOTTOM_SIDE_BUTTON * scale_factor, 72.0, 92.0)
	var info_height := clampf(ORIGINAL_BOTTOM_INFO_HEIGHT * scale_factor, 78.0, 104.0)
	var action_size := clampf(ORIGINAL_BOTTOM_ACTION_BUTTON * scale_factor, 42.0, 56.0)
	var margin_x := maxf(10.0, 20.0 * scale_factor)
	var bottom_margin := maxf(18.0, 32.0 * scale_factor)
	var bar_height := maxf(info_height + 34.0, side_size + 32.0)
	var bar_rect := Rect2(
		Vector2(screen_rect.position.x + margin_x, screen_rect.end.y - bar_height - bottom_margin),
		Vector2(screen_rect.size.x - margin_x * 2.0, bar_height)
	)
	var inventory_rect := Rect2(
		bar_rect.position + Vector2(10.0, (bar_rect.size.y - side_size) * 0.5),
		Vector2(side_size, side_size)
	)
	var out_game_rect := Rect2(
		Vector2(bar_rect.end.x - side_size - 10.0, inventory_rect.position.y),
		Vector2(side_size, side_size)
	)
	var block_info_rect := Rect2(
		Vector2(inventory_rect.end.x + 10.0, bar_rect.position.y + (bar_rect.size.y - info_height) * 0.5),
		Vector2(maxf(80.0, out_game_rect.position.x - inventory_rect.end.x - 20.0), info_height)
	)
	var action_gap := maxf(4.0, 8.0 * scale_factor)
	var action_y := block_info_rect.position.y + (block_info_rect.size.y - action_size) * 0.5
	var right_x := block_info_rect.end.x - action_size - 8.0
	var produce_rect := Rect2(Vector2(right_x - (action_size + action_gap) * 2.0, action_y), Vector2(action_size, action_size))
	var use_rect := Rect2(Vector2(right_x - (action_size + action_gap), action_y), Vector2(action_size, action_size))
	var cool_rect := Rect2(Vector2(right_x, action_y), Vector2(action_size, action_size))
	var mini_size := maxf(28.0, action_size * 0.58)
	return {
		"bar": bar_rect,
		"inventory": inventory_rect,
		"out_game": out_game_rect,
		"block_info": block_info_rect,
		"produce": produce_rect,
		"use": use_rect,
		"cool_time": cool_rect,
		"gold_open": Rect2(produce_rect.position + Vector2(0.0, -mini_size - 5.0), Vector2(mini_size, mini_size)),
		"cash": Rect2(use_rect.position + Vector2(0.0, -mini_size - 5.0), Vector2(mini_size, mini_size)),
	}

func _request_layout(screen_rect: Rect2) -> Dictionary:
	var scale_factor := screen_rect.size.x / 1080.0
	var top_offset := maxf(74.0, 148.0 * scale_factor)
	var strip_height := clampf(176.0 * scale_factor, 86.0, 122.0)
	var margin_x := maxf(10.0, 20.0 * scale_factor)
	var strip_rect := Rect2(
		Vector2(screen_rect.position.x + margin_x, screen_rect.position.y + top_offset),
		Vector2(screen_rect.size.x - margin_x * 2.0, strip_height)
	)
	var quest_size := Vector2(clampf(160.0 * scale_factor, 76.0, 104.0), strip_rect.size.y - 18.0)
	var quest_rect := Rect2(strip_rect.position + Vector2(10.0, 9.0), quest_size)
	var reward_size := clampf(150.0 * scale_factor, 50.0, 68.0)
	var reward_gap := maxf(6.0, 10.0 * scale_factor)
	var rewards: Array = []
	var reward_start := quest_rect.end.x + 12.0
	for index in range(3):
		rewards.append(Rect2(Vector2(reward_start + float(index) * (reward_size + reward_gap), strip_rect.position.y + 16.0), Vector2(reward_size, reward_size)))
	var skill_size := clampf(180.0 * scale_factor, 46.0, 62.0)
	var skills: Array = []
	var skill_x := strip_rect.end.x - 10.0 - skill_size
	for index in range(3):
		skills.push_front(Rect2(Vector2(skill_x - float(index) * (skill_size + 6.0), strip_rect.end.y - skill_size - 12.0), Vector2(skill_size, skill_size)))
	return {
		"strip": strip_rect,
		"quest": quest_rect,
		"rewards": rewards,
		"skills": skills,
	}

func _request_reward_payloads() -> Array:
	var payloads: Array = []
	if not selected.is_empty():
		payloads.append(selected)
	return payloads

func _largest_rect(rects: Array) -> Rect2:
	var best := Rect2()
	var best_area: float = -1.0
	for rect in rects:
		if typeof(rect) != TYPE_RECT2:
			continue
		var area: float = rect.size.x * rect.size.y
		if area > best_area:
			best = rect
			best_area = area
	return best

func _action_at(local_position: Vector2) -> String:
	for action in ["produce", "out_game", "inventory"]:
		var rect: Rect2 = action_regions.get(action, Rect2())
		if rect.has_point(local_position):
			return action
	return ""
