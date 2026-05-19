extends Control

const LOGIN_SCENE := "res://scenes/original_login.tscn"
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")
const LOADING_BG := "res://assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png"
const PROGRESS_ATLAS := "res://assets/resources/native/14/1430d496a.png"
const PROGRESS_FILL_RECT := Rect2i(3, 3, 1018, 10)
const PROGRESS_BG_RECT := Rect2i(134, 1000, 30, 8)
const PROGRESS_CURSOR_RECT := Rect2i(122, 1000, 6, 21)
const PROGRESS_SPINE := "res://data/spine_runtime/loading_jindutiao.json"
const DESIGN_SIZE := Vector2(1280, 720)
const PROGRESS_POS := Vector2(130, 690)
const PROGRESS_SIZE := Vector2(1018, 10)
const PROGRESS_TRACK_Y := 691.0

var design_root: Control
var progress_mask: Control
var progress_fill: TextureRect
var progress_cursor: TextureRect
var progress_spark: Node2D
var progress_label: Label
var status_label: Label
var percent := 0.0

func _ready() -> void:
	_build_ui()
	_capture_if_requested()

func _process(delta: float) -> void:
	percent = minf(percent + delta * 48.0, 100.0)
	_update_progress_visual()
	progress_label.text = "%d%%" % int(percent)
	if percent >= 100.0:
		set_process(false)
		await get_tree().create_timer(0.25).timeout
		Navigation.go(LOGIN_SCENE)

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color.BLACK
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(LOADING_BG)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	status_label = Label.new()
	status_label.text = "正在连接服务器"
	status_label.position = Vector2(552, 494)
	status_label.size = Vector2(176, 32)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 25)
	status_label.add_theme_color_override("font_color", Color(0.98, 0.92, 0.74))
	design_root.add_child(status_label)

	var progress_bg := TextureRect.new()
	progress_bg.position = Vector2(PROGRESS_POS.x, PROGRESS_TRACK_Y)
	progress_bg.size = Vector2(PROGRESS_SIZE.x, 8)
	progress_bg.texture = _load_texture_region(PROGRESS_ATLAS, PROGRESS_BG_RECT)
	progress_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	progress_bg.stretch_mode = TextureRect.STRETCH_TILE
	progress_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(progress_bg)

	progress_mask = Control.new()
	progress_mask.clip_contents = true
	progress_mask.position = PROGRESS_POS
	progress_mask.size = PROGRESS_SIZE
	progress_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(progress_mask)

	progress_fill = TextureRect.new()
	progress_fill.position = Vector2.ZERO
	progress_fill.size = PROGRESS_SIZE
	progress_fill.texture = _load_texture_region(PROGRESS_ATLAS, PROGRESS_FILL_RECT)
	progress_fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	progress_fill.stretch_mode = TextureRect.STRETCH_SCALE
	progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_mask.add_child(progress_fill)

	progress_cursor = TextureRect.new()
	progress_cursor.position = Vector2(PROGRESS_POS.x - 3, 684.5)
	progress_cursor.size = Vector2(6, 21)
	progress_cursor.texture = _load_texture_region(PROGRESS_ATLAS, PROGRESS_CURSOR_RECT)
	progress_cursor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	progress_cursor.stretch_mode = TextureRect.STRETCH_SCALE
	progress_cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(progress_cursor)

	progress_spark = SimpleSpinePlayerScript.new()
	progress_spark.visible = false
	progress_spark.z_index = 4
	design_root.add_child(progress_spark)
	if FileAccess.file_exists(PROGRESS_SPINE) and progress_spark.load_spine(PROGRESS_SPINE, "animation"):
		progress_spark.visible = true
		progress_spark.scale = Vector2(1.0, 1.0)

	var loading_text := Label.new()
	loading_text.text = "增加加载公共资源，请稍候..."
	loading_text.position = Vector2(138, 664)
	loading_text.size = Vector2(300, 28)
	loading_text.add_theme_font_size_override("font_size", 18)
	loading_text.add_theme_color_override("font_color", Color(0.98, 0.92, 0.74))
	design_root.add_child(loading_text)

	progress_label = Label.new()
	progress_label.text = "0%"
	progress_label.position = Vector2(1110, 664)
	progress_label.size = Vector2(54, 28)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.add_theme_color_override("font_color", Color(1, 1, 1))
	design_root.add_child(progress_label)

	_update_progress_visual()
	_layout_design_root()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	if Rect2i(Vector2i.ZERO, image.get_size()).encloses(region):
		image = image.get_region(region)
	return ImageTexture.create_from_image(image)

func _update_progress_visual() -> void:
	var ratio := clampf(percent / 100.0, 0.0, 1.0)
	var fill_width := PROGRESS_SIZE.x * ratio
	if progress_mask:
		progress_mask.size = Vector2(fill_width, PROGRESS_SIZE.y)
	if progress_cursor:
		progress_cursor.position.x = PROGRESS_POS.x + fill_width - 3.0
		progress_cursor.visible = fill_width > 1.0
	if progress_spark:
		progress_spark.position = Vector2(PROGRESS_POS.x + fill_width - 4.0, 694.0)
		progress_spark.visible = fill_width > 14.0 and fill_width < PROGRESS_SIZE.x - 2.0

func _layout_design_root() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var scale_value: float = min(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(scale_value, scale_value)
	design_root.position = (viewport_size - DESIGN_SIZE * scale_value) * 0.5

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	if not "--capture-loading" in args:
		return
	for i in 6:
		await get_tree().process_frame
	var index := args.find("--capture-loading")
	var output_path := "user://original_loading.png"
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
