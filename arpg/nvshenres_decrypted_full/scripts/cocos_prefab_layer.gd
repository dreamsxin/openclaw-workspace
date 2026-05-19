extends Control

const DESIGN_SIZE := Vector2(1280, 720)

@export_file("*.json") var layout_path := ""
@export var draw_placeholders := false
@export var crop_sprite_frames := true
var skip_names := []
var interactive_names := []

var node_pressed := {}

func _ready() -> void:
	render()

func render() -> void:
	for child in get_children():
		child.queue_free()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var nodes: Array = parsed.get("nodes", [])
	var mode := str(parsed.get("origin_mode", ""))
	if mode == "":
		mode = _origin_mode(nodes)
	for node in _sorted_nodes(nodes):
		_add_prefab_node(node, mode)

func _add_prefab_node(node: Dictionary, mode: String) -> void:
	var name := str(node.get("name", ""))
	if name in skip_names:
		return
	if not bool(node.get("active", true)):
		return
	var size := _arr_to_vec2(node.get("size", [0.0, 0.0]))
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var texture_path := str(node.get("texture_path", ""))
	var control: Control
	if texture_path != "":
		var texture := _load_node_texture("res://" + texture_path, node)
		if texture == null:
			return
		control = _make_sprite_control(texture, node)
	elif draw_placeholders and _should_placeholder(name):
		var panel := PanelContainer.new()
		panel.modulate = Color(0.08, 0.07, 0.06, 0.52)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var label := Label.new()
		label.text = _label_for_name(name)
		label.clip_text = true
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(label)
		control = panel
	else:
		if name in interactive_names:
			control = Control.new()
		else:
			return

	var rect := _node_rect(node, size, mode)
	control.position = rect.position
	control.size = rect.size
	var rotation_z := float(node.get("rotation_z", 0.0))
	if absf(rotation_z) > 0.01 and absf(rotation_z - 1.0) > 0.01:
		control.rotation = deg_to_rad(rotation_z)
	control.tooltip_text = name
	add_child(control)

	if name in interactive_names:
		var hit := Button.new()
		hit.text = ""
		hit.flat = true
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hit.pressed.connect(func(): _emit_node_pressed(name))
		control.add_child(hit)

func _make_sprite_control(texture: Texture2D, node: Dictionary) -> Control:
	var sprite_type := str(node.get("sprite_type_name", "simple"))
	var cap_insets: Array = node.get("sprite_cap_insets", [])
	if sprite_type == "sliced" and cap_insets.size() >= 4:
		var patch := NinePatchRect.new()
		patch.texture = texture
		patch.patch_margin_left = int(cap_insets[0])
		patch.patch_margin_top = int(cap_insets[1])
		patch.patch_margin_right = int(cap_insets[2])
		patch.patch_margin_bottom = int(cap_insets[3])
		patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return patch
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if sprite_type == "tiled":
		image.stretch_mode = TextureRect.STRETCH_TILE
	else:
		image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return image

func _node_rect(node: Dictionary, fallback_size: Vector2, mode: String) -> Rect2:
	var screen_rect: Array = node.get("screen_rect", [])
	if screen_rect.size() >= 4:
		return Rect2(
			Vector2(float(screen_rect[0]), float(screen_rect[1])),
			Vector2(float(screen_rect[2]), float(screen_rect[3]))
		)
	var position := _arr_to_vec2(node.get("global_position", node.get("position", [0.0, 0.0])))
	return Rect2(_cocos_to_screen(position, fallback_size, mode), fallback_size)

func _emit_node_pressed(name: String) -> void:
	if node_pressed.has(name):
		var callback: Callable = node_pressed[name]
		callback.call()

func _origin_mode(nodes: Array) -> String:
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var name := str(node.get("name", ""))
		var pos := _arr_to_vec2(node.get("global_position", [0.0, 0.0]))
		var size := _arr_to_vec2(node.get("size", [0.0, 0.0]))
		if name in ["root", "Canvas"] and size.distance_to(DESIGN_SIZE) < 2.0 and pos.distance_to(DESIGN_SIZE * 0.5) < 2.0:
			return "bottom_left"
	return "center"

func _cocos_to_screen(position: Vector2, size: Vector2, mode: String) -> Vector2:
	if mode == "bottom_left":
		return Vector2(position.x - size.x * 0.5, DESIGN_SIZE.y - position.y - size.y * 0.5)
	return Vector2(DESIGN_SIZE.x * 0.5 + position.x - size.x * 0.5, DESIGN_SIZE.y * 0.5 - position.y - size.y * 0.5)

func _load_node_texture(path: String, node: Dictionary) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var sprite_rect: Array = node.get("sprite_rect", [])
	if crop_sprite_frames and sprite_rect.size() == 4:
		var crop := Rect2i(int(sprite_rect[0]), int(sprite_rect[1]), int(sprite_rect[2]), int(sprite_rect[3]))
		var original_size := _arr_to_vec2i(node.get("sprite_original_size", []))
		var offset := _arr_to_vec2(node.get("sprite_offset", []))
		return _make_sprite_frame_texture(image, crop, bool(node.get("sprite_rotated", false)), original_size, offset)
	return ImageTexture.create_from_image(image)

func _make_sprite_frame_texture(atlas: Image, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(crop):
		return ImageTexture.create_from_image(atlas)
	var frame := atlas.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x <= 0 or original_size.y <= 0 or original_size == frame.get_size():
		return ImageTexture.create_from_image(frame)
	frame.convert(Image.FORMAT_RGBA8)
	var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
	var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
	canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
	return ImageTexture.create_from_image(canvas)

func _sorted_nodes(nodes: Array) -> Array:
	var sorted := nodes.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("index", 0)) < int(b.get("index", 0))
	)
	return sorted

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _should_placeholder(name: String) -> bool:
	var lower := name.to_lower()
	return lower.begins_with("btn") or lower.contains("server") or lower.contains("select")

func _label_for_name(name: String) -> String:
	var labels := {
		"btn_start": "START",
		"btnSelect": "SERVER",
		"btnSelect1": "SERVER",
		"btnGG": "NOTICE",
		"btnSwitchAcount": "ACCOUNT",
		"btnUserCenter": "ACCOUNT",
		"btnUserRule": "RULE",
		"loginBtn": "LOGIN",
	}
	return str(labels.get(name, name))
