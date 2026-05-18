extends Control

const DESIGN_SIZE := Vector2(1280, 720)
const DEFAULT_SPINE_PATH := "res://data/spine_runtime/YiKaLuoSi.json"
const FALLBACK_ANIMATIONS := ["idle", "run", "attack", "skill1", "skill2", "hit", "victory", "die", "stun"]
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

var design_root: Control
var player: Node2D
var title: Label
var spine_list: ItemList
var animation_buttons: HBoxContainer
var start_animation := "idle"
var spine_path := DEFAULT_SPINE_PATH
var spine_label := "YiKaLuoSi"
var debug_slots: Array = []
var spine_entries: Array[Dictionary] = []

func _ready() -> void:
	print("SPINE_VIEWER_READY")
	_read_user_args()
	_build_ui()
	_capture_if_requested()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.045, 0.055)
	add_child(bg)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var panel := ColorRect.new()
	panel.position = Vector2(0, 0)
	panel.size = DESIGN_SIZE
	panel.color = Color(0.10, 0.11, 0.13)
	design_root.add_child(panel)

	var floor := ColorRect.new()
	floor.position = Vector2(0, 520)
	floor.size = Vector2(1280, 200)
	floor.color = Color(0.055, 0.058, 0.064)
	design_root.add_child(floor)

	_build_spine_list()

	player = SimpleSpinePlayerScript.new()
	design_root.add_child(player)
	player.load_spine(spine_path, start_animation)
	player.set("only_slots", debug_slots)
	_fit_player_to_view()

	var top := HBoxContainer.new()
	top.position = Vector2(14, 10)
	top.size = Vector2(1252, 40)
	top.add_theme_constant_override("separation", 8)
	design_root.add_child(top)

	title = Label.new()
	title.text = "Spine Viewer | %s | %s" % [spine_label, start_animation]
	title.custom_minimum_size = Vector2(320, 34)
	title.add_theme_font_size_override("font_size", 18)
	top.add_child(title)

	Navigation.add_buttons(top)
	animation_buttons = HBoxContainer.new()
	animation_buttons.add_theme_constant_override("separation", 8)
	top.add_child(animation_buttons)
	_rebuild_animation_buttons()

	_layout_design_root()

func _build_spine_list() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(14, 60)
	panel.size = Vector2(220, 640)
	design_root.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var label := Label.new()
	label.text = "Spine 列表"
	label.add_theme_font_size_override("font_size", 17)
	box.add_child(label)

	spine_list = ItemList.new()
	spine_list.custom_minimum_size = Vector2(206, 590)
	spine_list.select_mode = ItemList.SELECT_SINGLE
	spine_list.item_selected.connect(_on_spine_selected)
	box.add_child(spine_list)

	_load_spine_entries()

func _load_spine_entries() -> void:
	spine_entries.clear()
	if spine_list == null:
		return
	spine_list.clear()
	var dir := DirAccess.open("res://data/spine_runtime")
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir() or not file_name.ends_with(".json"):
			continue
		var path := "res://data/spine_runtime/%s" % file_name
		var label := file_name.get_basename()
		var animations: Array = []
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(parsed) == TYPE_DICTIONARY:
			label = str(parsed.get("name", label))
			var skeleton: Dictionary = parsed.get("skeleton", {})
			var animation_map: Dictionary = skeleton.get("animations", {})
			animations = animation_map.keys()
			animations.sort()
		spine_entries.append({"label": label, "path": path, "animations": animations})
	dir.list_dir_end()
	spine_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("label", "")) < str(b.get("label", ""))
	)
	for i in range(spine_entries.size()):
		var entry: Dictionary = spine_entries[i]
		spine_list.add_item(str(entry.get("label", "")))
		if str(entry.get("path", "")) == spine_path:
			spine_list.select(i)

func _on_spine_selected(index: int) -> void:
	if index < 0 or index >= spine_entries.size():
		return
	var entry: Dictionary = spine_entries[index]
	spine_path = str(entry.get("path", spine_path))
	spine_label = str(entry.get("label", spine_path.get_file().get_basename()))
	var animations: Array = entry.get("animations", [])
	start_animation = "idle" if animations.has("idle") else str(animations[0]) if not animations.is_empty() else "idle"
	player.load_spine(spine_path, start_animation)
	player.set("only_slots", debug_slots)
	_fit_player_to_view()
	_rebuild_animation_buttons()
	title.text = "Spine Viewer | %s | %s" % [spine_label, start_animation]

func _read_user_args() -> void:
	var nav_args := Navigation.consume_scene_args()
	if not nav_args.is_empty():
		spine_path = str(nav_args.get("spine_path", spine_path))
		start_animation = str(nav_args.get("animation", start_animation))
		spine_label = str(nav_args.get("label", spine_label))
	var args := OS.get_cmdline_user_args()
	var index := args.find("--spine-animation")
	if index >= 0 and index + 1 < args.size():
		start_animation = args[index + 1]
	index = args.find("--spine-path")
	if index >= 0 and index + 1 < args.size():
		spine_path = args[index + 1]
		spine_label = spine_path.get_file().get_basename()
	index = args.find("--debug-slots")
	if index >= 0 and index + 1 < args.size():
		debug_slots = Array(args[index + 1].split(",", false))

func _play_animation(anim: String) -> void:
	start_animation = anim
	player.play(anim)
	_fit_player_to_view()
	title.text = "Spine Viewer | %s | %s" % [spine_label, anim]

func _rebuild_animation_buttons() -> void:
	if animation_buttons == null:
		return
	for child in animation_buttons.get_children():
		child.queue_free()
	for anim in _available_animations():
		var button := Button.new()
		button.text = anim
		button.custom_minimum_size = Vector2(82, 32)
		button.pressed.connect(_play_animation.bind(anim))
		animation_buttons.add_child(button)

func _fit_player_to_view() -> void:
	if player == null:
		return
	player.update_preview_pose(0.0)
	var bounds: Rect2 = player.get_draw_bounds()
	var target := Rect2(Vector2(250, 76), Vector2(870, 584))
	var scale_factor: float = min(target.size.x / max(bounds.size.x, 1.0), target.size.y / max(bounds.size.y, 1.0))
	scale_factor = clamp(scale_factor, 0.18, 2.2)
	player.scale = Vector2(scale_factor, scale_factor)
	var local_center := bounds.position + bounds.size * 0.5
	var target_center := target.position + target.size * 0.5
	player.position = target_center - local_center * scale_factor

func _available_animations() -> Array:
	var text := FileAccess.get_file_as_string(spine_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		var skeleton: Dictionary = parsed.get("skeleton", {})
		var animations: Dictionary = skeleton.get("animations", {})
		if not animations.is_empty():
			var names := animations.keys()
			names.sort()
			return names
	return FALLBACK_ANIMATIONS

func _layout_design_root() -> void:
	var viewport_size := get_viewport_rect().size
	var factor: float = min(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(factor, factor)
	design_root.position = (viewport_size - DESIGN_SIZE * factor) * 0.5

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-spine-viewer" in args and not DisplayServer.get_name().contains("headless"):
		return
	for i in range(12):
		await get_tree().process_frame
	var index := args.find("--capture-spine-viewer")
	var output_path := "D:/work/openclaw-workspace/arpg/nvshenres_decrypted_full/spine_viewer_headless.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		get_tree().quit()
		return
	var image := viewport_texture.get_image()
	if image == null:
		get_tree().quit()
		return
	image.convert(Image.FORMAT_RGBA8)
	var opaque := Image.create_empty(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
	opaque.fill(Color(0.04, 0.045, 0.055, 1.0))
	opaque.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i.ZERO)
	opaque.save_png(output_path)
	get_tree().quit()
