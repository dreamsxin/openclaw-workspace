extends Control

const LOGIN_SCENE := "res://scenes/original_login.tscn"
const LOADING_BG := "res://assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png"
const DESIGN_SIZE := Vector2(1280, 720)

var progress_bar: ProgressBar
var progress_label: Label
var status_label: Label
var percent := 0.0

func _ready() -> void:
	_build_ui()
	_capture_if_requested()

func _process(delta: float) -> void:
	percent = minf(percent + delta * 48.0, 100.0)
	progress_bar.value = percent
	progress_label.text = "%d%%" % int(percent)
	if percent >= 100.0:
		set_process(false)
		await get_tree().create_timer(0.25).timeout
		Navigation.go(LOGIN_SCENE)

func _build_ui() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(LOADING_BG)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var bottom := VBoxContainer.new()
	bottom.anchor_left = 0.5
	bottom.anchor_top = 1.0
	bottom.anchor_right = 0.5
	bottom.anchor_bottom = 1.0
	bottom.offset_left = -520
	bottom.offset_top = -86
	bottom.offset_right = 520
	bottom.offset_bottom = -24
	bottom.add_theme_constant_override("separation", 8)
	add_child(bottom)

	status_label = Label.new()
	status_label.text = "增加加载公共资源，请稍候..."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_color", Color(0.98, 0.92, 0.74))
	bottom.add_child(status_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	bottom.add_child(row)

	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.custom_minimum_size = Vector2(0, 18)
	row.add_child(progress_bar)

	progress_label = Label.new()
	progress_label.text = "0%"
	progress_label.custom_minimum_size = Vector2(70, 24)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.add_theme_color_override("font_color", Color(1, 1, 1))
	row.add_child(progress_label)

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

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
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
