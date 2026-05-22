class_name OutGameReferenceScreen
extends Control

signal ingame_requested
signal maid_lobby_requested
signal interaction_requested
signal app_navigation_requested(app_key: String)

const OUT_GAME_MAID_STANDIN := "res://assets/characters/maid_costume/Cos_Maid01_Casual_SD.png"
const SPRITE_DIR := "res://assets/sprites/"
const WALLET_ICON_PATHS := {
	"ap": SPRITE_DIR + "CURRENCY_AP.png",
	"gold": SPRITE_DIR + "CURRENCY_GOLD.png",
	"jewel": SPRITE_DIR + "CURRENCY_JEWEL.png",
}

var source: Dictionary = {}
var wallet: Dictionary = {"ap": 0, "gold": 0, "jewel": 0}
var action_regions: Dictionary = {}
var maid_standin_texture: Texture2D
var wallet_icon_textures: Dictionary = {}

func _ready() -> void:
	maid_standin_texture = load(OUT_GAME_MAID_STANDIN)
	for key in WALLET_ICON_PATHS.keys():
		wallet_icon_textures[key] = load(WALLET_ICON_PATHS[key])
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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var action := _action_at(event.position)
		if action == "ingame":
			emit_signal("ingame_requested")
			accept_event()
		elif action == "maid_lobby":
			emit_signal("maid_lobby_requested")
			accept_event()
		elif action == "interaction":
			emit_signal("interaction_requested")
			accept_event()
		elif action.begins_with("app_"):
			emit_signal("app_navigation_requested", action.trim_prefix("app_"))
			accept_event()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_rebuild_action_regions()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.03, 0.035, 0.94), true)
	if source.is_empty():
		return

	var screen_rect := _screen_rect()
	var layout := _home_layout(screen_rect)
	draw_rect(screen_rect, Color(0.1, 0.12, 0.13, 1.0), true)
	_draw_cafe_backdrop(screen_rect, layout)
	_draw_maid_layer(screen_rect, layout)
	_draw_village_progress(layout)
	_draw_home_entries(layout)
	_draw_bottom_navigation(layout)
	_draw_top_home_hud(screen_rect, layout)
	draw_rect(screen_rect, Color(0.78, 0.72, 0.55, 0.82), false, 2.0)

func _screen_rect() -> Rect2:
	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	return Rect2((size - viewport_size) * 0.5, viewport_size)

func _home_layout(screen_rect: Rect2) -> Dictionary:
	var s: float = screen_rect.size.x / 540.0
	var margin: float = 12.0 * s
	var top_h: float = clampf(58.0 * s, 50.0, 72.0)
	var bottom_h: float = clampf(92.0 * s, 78.0, 112.0)
	var progress_size := Vector2(screen_rect.size.x * 0.68, clampf(52.0 * s, 44.0, 62.0))
	var progress_rect := Rect2(
		Vector2(screen_rect.position.x + (screen_rect.size.x - progress_size.x) * 0.5, screen_rect.position.y + top_h + 12.0 * s),
		progress_size
	)
	var maid_rect := Rect2(
		Vector2(screen_rect.position.x + screen_rect.size.x * 0.02, screen_rect.position.y + screen_rect.size.y * 0.19),
		Vector2(screen_rect.size.x * 0.56, screen_rect.size.y * 0.58)
	)
	var dialog_rect := Rect2(
		Vector2(screen_rect.position.x + margin, screen_rect.position.y + screen_rect.size.y - bottom_h - 98.0 * s),
		Vector2(screen_rect.size.x - margin * 2.0, clampf(76.0 * s, 66.0, 92.0))
	)
	var ingame_size := Vector2(clampf(150.0 * s, 132.0, 176.0), clampf(123.0 * s, 104.0, 148.0))
	var ingame_rect := Rect2(
		Vector2(screen_rect.end.x - margin - ingame_size.x, dialog_rect.position.y - ingame_size.y - 18.0 * s),
		ingame_size
	)
	var maid_lobby_size := Vector2(clampf(102.0 * s, 90.0, 122.0), clampf(102.0 * s, 90.0, 122.0))
	var maid_lobby_rect := Rect2(
		Vector2(ingame_rect.position.x - maid_lobby_size.x - 10.0 * s, ingame_rect.position.y + ingame_rect.size.y - maid_lobby_size.y),
		maid_lobby_size
	)
	var interaction_rect := Rect2(
		Vector2(screen_rect.position.x, screen_rect.position.y + screen_rect.size.y * 0.24),
		Vector2(screen_rect.size.x * 0.54, screen_rect.size.y * 0.5)
	)
	var bottom_rect := Rect2(
		Vector2(screen_rect.position.x + margin, screen_rect.end.y - bottom_h + 8.0 * s),
		Vector2(screen_rect.size.x - margin * 2.0, bottom_h - 18.0 * s)
	)
	var furniture_rect := Rect2(
		Vector2(screen_rect.position.x + margin, progress_rect.end.y + 12.0 * s),
		Vector2(clampf(118.0 * s, 102.0, 138.0), clampf(58.0 * s, 50.0, 68.0))
	)
	return {
		"screen": screen_rect,
		"top": Rect2(screen_rect.position, Vector2(screen_rect.size.x, top_h)),
		"progress": progress_rect,
		"maid": maid_rect,
		"dialog": dialog_rect,
		"ingame": ingame_rect,
		"maid_lobby": maid_lobby_rect,
		"interaction": interaction_rect,
		"bottom": bottom_rect,
		"furniture": furniture_rect,
		"scale": s,
	}

func _draw_cafe_backdrop(screen_rect: Rect2, layout: Dictionary) -> void:
	var s: float = layout["scale"]
	var wall_rect := Rect2(screen_rect.position, Vector2(screen_rect.size.x, screen_rect.size.y * 0.6))
	var floor_rect := Rect2(
		Vector2(screen_rect.position.x, screen_rect.position.y + screen_rect.size.y * 0.58),
		Vector2(screen_rect.size.x, screen_rect.size.y * 0.42)
	)
	draw_rect(screen_rect, Color(0.34, 0.43, 0.39, 1.0), true)
	draw_rect(wall_rect, Color(0.66, 0.76, 0.68, 1.0), true)
	for index in range(5):
		var stripe_y := wall_rect.position.y + 86.0 * s + float(index) * 86.0 * s
		draw_line(Vector2(wall_rect.position.x, stripe_y), Vector2(wall_rect.end.x, stripe_y - 22.0 * s), Color(0.44, 0.58, 0.52, 0.26), 2.0 * s)

	var window_rect := Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.58, screen_rect.size.y * 0.15), Vector2(screen_rect.size.x * 0.32, screen_rect.size.y * 0.16))
	draw_rect(window_rect, Color(0.56, 0.78, 0.84, 0.75), true)
	draw_rect(window_rect, Color(0.92, 0.88, 0.72, 0.78), false, 3.0 * s)
	draw_line(window_rect.position + Vector2(window_rect.size.x * 0.5, 0), window_rect.position + Vector2(window_rect.size.x * 0.5, window_rect.size.y), Color(0.92, 0.88, 0.72, 0.55), 2.0 * s)
	draw_line(window_rect.position + Vector2(0, window_rect.size.y * 0.5), window_rect.position + Vector2(window_rect.size.x, window_rect.size.y * 0.5), Color(0.92, 0.88, 0.72, 0.55), 2.0 * s)

	var shelf_rect := Rect2(screen_rect.position + Vector2(screen_rect.size.x * 0.62, screen_rect.size.y * 0.35), Vector2(screen_rect.size.x * 0.28, 16.0 * s))
	draw_rect(shelf_rect, Color(0.44, 0.24, 0.15, 0.9), true)
	for index in range(4):
		var cup_pos := shelf_rect.position + Vector2(18.0 * s + float(index) * 34.0 * s, -18.0 * s)
		draw_rect(Rect2(cup_pos, Vector2(18.0 * s, 20.0 * s)), Color(0.95, 0.85, 0.65, 0.82), true)

	draw_rect(floor_rect, Color(0.5, 0.31, 0.2, 0.98), true)
	for index in range(5):
		var y := floor_rect.position.y + floor_rect.size.y * (float(index) + 1.0) / 6.0
		draw_line(Vector2(floor_rect.position.x, y), Vector2(floor_rect.end.x, y + 30.0 * s), Color(0.22, 0.13, 0.08, 0.24), 2.0 * s)

	var counter := Rect2(
		Vector2(screen_rect.position.x - screen_rect.size.x * 0.05, screen_rect.position.y + screen_rect.size.y * 0.64),
		Vector2(screen_rect.size.x * 1.1, screen_rect.size.y * 0.16)
	)
	draw_rect(counter, Color(0.56, 0.35, 0.22, 0.96), true)
	draw_rect(Rect2(counter.position, Vector2(counter.size.x, 18.0 * s)), Color(0.94, 0.78, 0.52, 0.9), true)
	draw_rect(counter, Color(0.32, 0.18, 0.12, 0.44), false, 2.0 * s)

	var furniture_rect: Rect2 = layout["furniture"]
	draw_rect(furniture_rect, Color(0.18, 0.16, 0.13, 0.62), true)
	draw_rect(furniture_rect, Color(0.95, 0.78, 0.45, 0.78), false, 2.0 * s)
	draw_string(ThemeDB.fallback_font, furniture_rect.position + Vector2(0, furniture_rect.size.y * 0.58), "Quest", HORIZONTAL_ALIGNMENT_CENTER, furniture_rect.size.x, int(16.0 * s), Color(1.0, 0.92, 0.68, 0.92))

func _draw_maid_layer(_screen_rect: Rect2, layout: Dictionary) -> void:
	var s: float = layout["scale"]
	var maid_rect: Rect2 = layout["maid"]
	var shadow_center := Vector2(maid_rect.get_center().x, maid_rect.end.y - 22.0 * s)
	draw_circle(shadow_center, maid_rect.size.x * 0.28, Color(0.08, 0.06, 0.05, 0.28))
	if maid_standin_texture != null:
		var texture_size := Vector2(maid_standin_texture.get_width(), maid_standin_texture.get_height())
		var draw_scale: float = minf(maid_rect.size.x / texture_size.x, maid_rect.size.y / texture_size.y)
		var draw_size := texture_size * draw_scale
		var draw_rect := Rect2(
			Vector2(maid_rect.get_center().x - draw_size.x * 0.5, maid_rect.end.y - draw_size.y),
			draw_size
		)
		draw_texture_rect(maid_standin_texture, draw_rect, false, Color(1, 1, 1, 0.98))
	else:
		var body_color := Color(0.92, 0.76, 0.84, 0.56)
		var outline := Color(0.98, 0.9, 0.94, 0.72)
		draw_circle(maid_rect.get_center() + Vector2(0, -maid_rect.size.y * 0.22), maid_rect.size.x * 0.17, body_color)
		draw_line(maid_rect.get_center() + Vector2(0, -maid_rect.size.y * 0.05), maid_rect.get_center() + Vector2(0, maid_rect.size.y * 0.24), outline, 7.0 * s)
		draw_rect(maid_rect, Color(1, 0.92, 0.96, 0.42), false, 1.5 * s)

	var dialog_rect: Rect2 = layout["dialog"]
	draw_rect(dialog_rect, Color(0.98, 0.94, 0.86, 0.94), true)
	draw_rect(dialog_rect, Color(0.36, 0.24, 0.18, 0.78), false, 2.0 * s)
	var tail_origin := dialog_rect.position + Vector2(dialog_rect.size.x * 0.22, 0)
	draw_line(tail_origin, tail_origin + Vector2(28.0 * s, -24.0 * s), Color(0.98, 0.94, 0.86, 0.78), 5.0 * s)
	draw_string(ThemeDB.fallback_font, dialog_rect.position + Vector2(18.0 * s, 30.0 * s), "Welcome back.", HORIZONTAL_ALIGNMENT_LEFT, dialog_rect.size.x - 36.0 * s, int(20.0 * s), Color(0.18, 0.12, 0.08, 0.95))

func _draw_village_progress(layout: Dictionary) -> void:
	var s: float = layout["scale"]
	var bar_rect: Rect2 = layout["progress"]
	draw_rect(bar_rect, Color(0.12, 0.11, 0.1, 0.88), true)
	draw_rect(bar_rect, Color(0.94, 0.78, 0.45, 0.9), false, 2.0 * s)
	var icon_rect := Rect2(bar_rect.position + Vector2(8.0 * s, 8.0 * s), Vector2(bar_rect.size.y - 16.0 * s, bar_rect.size.y - 16.0 * s))
	draw_circle(icon_rect.get_center(), icon_rect.size.x * 0.5, Color(0.86, 0.58, 0.28, 0.9))
	draw_string(ThemeDB.fallback_font, icon_rect.position + Vector2(0, icon_rect.size.y * 0.68), "!", HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x, int(20.0 * s), Color(1, 0.96, 0.72, 0.96))
	var inner := Rect2(bar_rect.position + Vector2(bar_rect.size.y, bar_rect.size.y * 0.48), Vector2(bar_rect.size.x - bar_rect.size.y - 14.0 * s, bar_rect.size.y * 0.22))
	draw_rect(inner, Color(0.05, 0.06, 0.05, 0.7), true)
	draw_rect(Rect2(inner.position, Vector2(inner.size.x * 0.57, inner.size.y)), Color(0.57, 0.86, 0.64, 0.92), true)
	draw_string(ThemeDB.fallback_font, bar_rect.position + Vector2(bar_rect.size.y, 22.0 * s), "Village ReBuild", HORIZONTAL_ALIGNMENT_LEFT, bar_rect.size.x - bar_rect.size.y, int(15.0 * s), Color(1.0, 0.92, 0.68, 0.95))

func _draw_home_entries(layout: Dictionary) -> void:
	var ingame_rect: Rect2 = layout["ingame"]
	var lobby_rect: Rect2 = layout["maid_lobby"]
	var interaction_rect: Rect2 = layout["interaction"]
	var ingame_hover: bool = action_regions.get("ingame", Rect2()).has_point(get_local_mouse_position())
	var lobby_hover: bool = action_regions.get("maid_lobby", Rect2()).has_point(get_local_mouse_position())
	var interaction_hover: bool = action_regions.get("interaction", Rect2()).has_point(get_local_mouse_position())
	if interaction_hover:
		draw_rect(interaction_rect, Color(0.94, 0.68, 0.82, 0.1), true)
		draw_rect(interaction_rect, Color(0.95, 0.72, 0.88, 0.36), false, 1.0)
	_draw_command_button(lobby_rect, "Maid", "Lobby", lobby_hover, Color(0.43, 0.54, 0.72, 1.0))
	_draw_command_button(ingame_rect, "Merge", "Game", ingame_hover, Color(0.74, 0.38, 0.36, 1.0))

func _draw_command_button(rect: Rect2, title: String, subtitle: String, hover := false, accent := Color(0.74, 0.38, 0.36, 1.0)) -> void:
	var s: float = rect.size.x / 150.0
	var fill := Color(0.16, 0.17, 0.16, 0.94) if hover else Color(0.11, 0.12, 0.12, 0.88)
	draw_rect(rect, fill, true)
	draw_rect(rect, Color(1.0, 0.88, 0.56, 0.95) if hover else Color(0.93, 0.78, 0.5, 0.84), false, 3.0 if hover else 2.0)
	var badge_center := rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.34)
	draw_circle(badge_center, minf(rect.size.x, rect.size.y) * 0.23, accent)
	draw_circle(badge_center + Vector2(0, -2.0 * s), minf(rect.size.x, rect.size.y) * 0.12, Color(1.0, 0.9, 0.65, 0.42))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.68), title, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(18.0 * s), Color(1, 0.94, 0.78, 0.96))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y * 0.84), subtitle, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(13.0 * s), Color(0.95, 0.82, 0.58, 0.76))

func _draw_bottom_navigation(layout: Dictionary) -> void:
	var bottom_rect: Rect2 = layout["bottom"]
	var s: float = layout["scale"]
	draw_rect(bottom_rect, Color(0.08, 0.08, 0.075, 0.9), true)
	draw_rect(bottom_rect, Color(0.86, 0.72, 0.46, 0.66), false, 1.5 * s)
	var entries := [
		{"label": "Shop", "action": "app_shop", "color": Color(0.5, 0.28, 0.42, 0.92)},
		{"label": "Story", "action": "app_story", "color": Color(0.34, 0.34, 0.54, 0.92)},
		{"label": "Maid", "action": "maid_lobby", "color": Color(0.32, 0.44, 0.58, 0.92)},
		{"label": "Bag", "action": "app_bag", "color": Color(0.38, 0.34, 0.23, 0.92)},
		{"label": "Menu", "action": "app_menu", "color": Color(0.28, 0.28, 0.27, 0.92)},
	]
	var cell_w := bottom_rect.size.x / float(entries.size())
	for index in range(entries.size()):
		var cell := Rect2(bottom_rect.position + Vector2(cell_w * float(index), 0), Vector2(cell_w, bottom_rect.size.y))
		var action := String(entries[index]["action"])
		var hover: bool = action_regions.get(action, Rect2()).has_point(get_local_mouse_position())
		var center := cell.position + Vector2(cell.size.x * 0.5, cell.size.y * 0.34)
		var icon_color: Color = entries[index]["color"]
		draw_rect(cell.grow(-3.0 * s), Color(0.18, 0.14, 0.1, 0.78) if hover else Color(0.0, 0.0, 0.0, 0.0), true)
		draw_circle(center, minf(cell.size.x, cell.size.y) * 0.24, icon_color)
		draw_rect(Rect2(center - Vector2(8.0 * s, 8.0 * s), Vector2(16.0 * s, 16.0 * s)), Color(0.94, 0.78, 0.48, 0.74), false, 1.5 * s)
		draw_string(ThemeDB.fallback_font, cell.position + Vector2(0, cell.size.y - 14.0 * s), String(entries[index]["label"]), HORIZONTAL_ALIGNMENT_CENTER, cell.size.x, int(12.0 * s), Color(0.96, 0.87, 0.68, 0.9))

func _draw_top_home_hud(screen_rect: Rect2, layout: Dictionary) -> void:
	var top_rect: Rect2 = layout["top"]
	var s: float = layout["scale"]
	draw_rect(top_rect, Color(0.07, 0.075, 0.07, 0.92), true)
	draw_rect(Rect2(top_rect.position + Vector2(0, top_rect.size.y - 2.0 * s), Vector2(top_rect.size.x, 2.0 * s)), Color(0.91, 0.76, 0.45, 0.72), true)
	var x := screen_rect.position.x + 10.0 * s
	_draw_wallet_item(Vector2(x, screen_rect.position.y + 10.0 * s), "ap", wallet.get("ap", 0), s)
	x += 128.0 * s
	_draw_wallet_item(Vector2(x, screen_rect.position.y + 10.0 * s), "gold", wallet.get("gold", 0), s)
	x += 138.0 * s
	_draw_wallet_item(Vector2(x, screen_rect.position.y + 10.0 * s), "jewel", wallet.get("jewel", 0), s)
	var side_x := screen_rect.end.x - 92.0 * s
	for index in range(2):
		var btn := Rect2(Vector2(side_x + float(index) * 40.0 * s, screen_rect.position.y + 12.0 * s), Vector2(30.0 * s, 30.0 * s))
		draw_rect(btn, Color(0.16, 0.17, 0.16, 0.92), true)
		draw_rect(btn, Color(0.88, 0.72, 0.46, 0.72), false, 1.5 * s)
		draw_circle(btn.get_center(), 5.0 * s, Color(0.92, 0.82, 0.62, 0.84))

func _draw_wallet_item(position: Vector2, key: String, value, s: float) -> void:
	var rect := Rect2(position, Vector2(116.0 * s, 34.0 * s))
	draw_rect(rect, Color(0.02, 0.025, 0.025, 0.56), true)
	draw_rect(rect, Color(0.77, 0.63, 0.38, 0.46), false, 1.0 * s)
	var icon_texture: Texture2D = wallet_icon_textures.get(key, null)
	var icon_rect := Rect2(rect.position + Vector2(5.0 * s, 4.0 * s), Vector2(26.0 * s, 26.0 * s))
	if icon_texture != null:
		draw_texture_rect(icon_texture, icon_rect, false, Color(1, 1, 1, 0.96))
	else:
		draw_circle(icon_rect.get_center(), icon_rect.size.x * 0.48, Color(0.86, 0.68, 0.32, 0.9))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(36.0 * s, 23.0 * s), _format_wallet_value(value), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 40.0 * s, int(15.0 * s), Color(1.0, 0.93, 0.72, 0.96))

func _format_wallet_value(value) -> String:
	var number := float(value)
	if is_equal_approx(number, roundf(number)):
		return str(int(roundf(number)))
	return str(number)

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
	if source.is_empty() or size == Vector2.ZERO:
		return
	var screen_rect := _screen_rect()
	var layout := _home_layout(screen_rect)
	action_regions["ingame"] = layout["ingame"]
	action_regions["maid_lobby"] = layout["maid_lobby"]
	action_regions["interaction"] = layout["interaction"]
	var bottom_rect: Rect2 = layout["bottom"]
	var app_actions := ["app_shop", "app_story", "maid_lobby", "app_bag", "app_menu"]
	var cell_w := bottom_rect.size.x / float(app_actions.size())
	for index in range(app_actions.size()):
		action_regions[app_actions[index]] = Rect2(bottom_rect.position + Vector2(cell_w * float(index), 0), Vector2(cell_w, bottom_rect.size.y))

func _action_at(local_position: Vector2) -> String:
	for action in ["ingame", "maid_lobby", "interaction", "app_shop", "app_story", "app_bag", "app_menu"]:
		var rect: Rect2 = action_regions.get(action, Rect2())
		if rect.has_point(local_position):
			return action
	return ""
