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
	_draw_recovered_panel("Request", Color(0.12, 0.16, 0.17, 0.24), Color(0.74, 0.84, 0.78, 0.34), reference_size, scale_factor, origin)
	_draw_recovered_panel("Bottom/UIBlockInfo/Bg", Color(0.13, 0.1, 0.08, 0.46), Color(0.95, 0.78, 0.48, 0.56), reference_size, scale_factor, origin)
	_draw_recovered_panel("Bottom/UIInventory/Btn_Inven", Color(0.16, 0.13, 0.1, 0.48), Color(0.95, 0.8, 0.52, 0.58), reference_size, scale_factor, origin)
	_draw_recovered_panel("Bottom/Lobby", Color(0.16, 0.13, 0.1, 0.48), Color(0.95, 0.8, 0.52, 0.58), reference_size, scale_factor, origin)
	_draw_top_wallet(screen_rect)
	_draw_selected_block_info(screen_rect)
	_draw_action_button("produce", "Produce")
	_draw_action_button("out_game", "Cafe")
	_draw_action_button("inventory", "Bag")

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

func _draw_selected_block_info(screen_rect: Rect2) -> void:
	var info_rect: Rect2 = action_regions.get("block_info", Rect2())
	if info_rect.size == Vector2.ZERO:
		info_rect = Rect2(screen_rect.position + Vector2(22, screen_rect.size.y - 142), Vector2(screen_rect.size.x - 44, 88))
	draw_rect(info_rect, Color(0.04, 0.045, 0.045, 0.72), true)
	draw_rect(info_rect, Color(0.9, 0.72, 0.45, 0.4), false, 1.2)
	var label: String = "Select a block"
	if not selected.is_empty():
		label = "%s  L%s\nEnergy %s/%s%s" % [
			selected.get("name", selected.get("id", "")),
			selected.get("level", "?"),
			selected.get("energy", 0),
			selected.get("max_energy", 0),
			"  Producer" if bool(selected.get("has_produce", false)) else "",
		]
	draw_multiline_string(ThemeDB.fallback_font, info_rect.position + Vector2(14, 26), label, HORIZONTAL_ALIGNMENT_LEFT, info_rect.size.x - 28, 17, 3, Color(1, 0.93, 0.75, 0.96))

func _draw_action_button(action: String, label: String) -> void:
	var rect: Rect2 = action_regions.get(action, Rect2())
	if rect.size == Vector2.ZERO:
		return
	var hover: bool = rect.has_point(get_local_mouse_position())
	draw_rect(rect, Color(0.22, 0.17, 0.1, 0.92) if hover else Color(0.12, 0.1, 0.08, 0.82), true)
	draw_rect(rect, Color(1.0, 0.82, 0.48, 0.92) if hover else Color(0.92, 0.73, 0.42, 0.7), false, 2.0 if hover else 1.4)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.5 + 6), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 16, Color(1, 0.94, 0.78, 0.98))

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
	action_regions["out_game"] = _largest_rect([
		_to_preview_rect_world(_rect_by_suffix("Bottom/Lobby/GoToOutGame"), reference_size, scale_factor, origin),
		_to_preview_rect_world(_rect_by_suffix("Bottom/Lobby"), reference_size, scale_factor, origin),
	])
	action_regions["inventory"] = _largest_rect([
		_to_preview_rect_world(_rect_by_suffix("Bottom/UIInventory/Btn_Inven"), reference_size, scale_factor, origin),
		_to_preview_rect_world(_rect_by_suffix("Bottom/UIInventory/Btn_Inven/BG"), reference_size, scale_factor, origin),
	])
	action_regions["block_info"] = _to_preview_rect_world(_rect_by_suffix("Bottom/UIBlockInfo/Bg"), reference_size, scale_factor, origin)
	var produce_candidate: Rect2 = _largest_rect([
		_to_preview_rect_world(_rect_by_suffix("Bottom/UIBlockInfo/Bg/Grid/Btn_BoxOpen/BG"), reference_size, scale_factor, origin),
		_to_preview_rect_world(_rect_by_suffix("Bottom/UIBlockInfo/Bg/Grid/Btn_Use/BG"), reference_size, scale_factor, origin),
		_to_preview_rect_world(_rect_by_suffix("Bottom/UIBlockInfo/Bg/Grid/Btn_CoolTime/BG"), reference_size, scale_factor, origin),
	])
	if produce_candidate.size == Vector2.ZERO:
		var block_info: Rect2 = action_regions.get("block_info", Rect2())
		produce_candidate = Rect2(block_info.end - Vector2(148, 48), Vector2(128, 38))
	action_regions["produce"] = produce_candidate

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
