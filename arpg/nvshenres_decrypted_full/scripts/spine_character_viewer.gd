extends Control

const DESIGN_SIZE := Vector2(1280, 720)
const DEFAULT_SPINE_PATH := "res://data/spine_runtime/YiKaLuoSi.json"
const ANIMATIONS := ["idle", "run", "attack", "skill1", "skill2", "hit", "victory", "die", "stun"]
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

var design_root: Control
var player: Node2D
var title: Label
var start_animation := "idle"
var spine_path := DEFAULT_SPINE_PATH
var spine_label := "YiKaLuoSi"
var debug_slots: Array = []

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

	player = SimpleSpinePlayerScript.new()
	player.position = Vector2(640, 520)
	player.scale = Vector2(1.9, 1.9)
	design_root.add_child(player)
	player.load_spine(spine_path, start_animation)
	player.set("only_slots", debug_slots)

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
	for anim in ANIMATIONS:
		var button := Button.new()
		button.text = anim
		button.custom_minimum_size = Vector2(82, 32)
		button.pressed.connect(_play_animation.bind(anim))
		top.add_child(button)

	_layout_design_root()

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
	player.play(anim)
	title.text = "Spine Viewer | %s | %s" % [spine_label, anim]

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
	image.save_png(output_path)
	get_tree().quit()
