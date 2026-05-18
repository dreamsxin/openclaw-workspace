extends Control

const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const SERVER_SELECT := "res://scenes/original_server_select.tscn"
const BG_PATH := "res://assets/resources/native/11/1176e8f9-db52-4635-b647-5192e470dc81.png"
const LOGIN_ATLAS_PATH := "res://assets/resources/native/1d/1d1cac610.png"
const UI_ATLAS_PATH := "res://assets/resources/native/14/1430d496a.png"
const LOGIN_BUTTON_PATH := "res://assets/resources/native/5b/5bdf6505-27d4-4c65-93ef-f9d027895e2b.png"
const LOGO_RECT := Rect2i(3, 612, 400, 254)
const BOTTOM_RECT := Rect2i(206, 996, 2, 34)

func _ready() -> void:
	_build_ui()
	_capture_if_requested()

func _build_ui() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var logo := TextureRect.new()
	logo.anchor_left = 0.5
	logo.anchor_top = 0.0
	logo.anchor_right = 0.5
	logo.anchor_bottom = 0.0
	logo.offset_left = -240
	logo.offset_top = 56
	logo.offset_right = 240
	logo.offset_bottom = 250
	logo.texture = _load_texture_region(LOGIN_ATLAS_PATH, LOGO_RECT, true)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)

	var bottom := TextureRect.new()
	bottom.anchor_left = 0.0
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = -140
	bottom.offset_top = -126
	bottom.offset_right = 140
	bottom.offset_bottom = -8
	bottom.texture = _load_texture_region(UI_ATLAS_PATH, BOTTOM_RECT, true)
	bottom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bottom.stretch_mode = TextureRect.STRETCH_SCALE
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom)

	var login_box := Control.new()
	login_box.anchor_left = 0.5
	login_box.anchor_top = 1.0
	login_box.anchor_right = 0.5
	login_box.anchor_bottom = 1.0
	login_box.offset_left = -275
	login_box.offset_top = -118
	login_box.offset_right = 275
	login_box.offset_bottom = -16
	add_child(login_box)

	var login_image := TextureRect.new()
	login_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	login_image.texture = _load_texture(LOGIN_BUTTON_PATH)
	login_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	login_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	login_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	login_box.add_child(login_image)

	var login_hit := Button.new()
	login_hit.text = ""
	login_hit.flat = true
	login_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	login_hit.tooltip_text = "进入本地主城预览"
	login_hit.pressed.connect(_enter_main_preview)
	login_box.add_child(login_hit)

	var top_bar := HBoxContainer.new()
	top_bar.anchor_left = 1.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = -300
	top_bar.offset_top = 16
	top_bar.offset_right = -16
	top_bar.offset_bottom = 54
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	add_child(top_bar)

	Navigation.add_buttons(top_bar)

	var preview := Button.new()
	preview.text = "原始界面预览"
	preview.pressed.connect(func(): Navigation.go(PREFAB_PREVIEW))
	top_bar.add_child(preview)

	var resources := Button.new()
	resources.text = "资源浏览"
	resources.pressed.connect(func(): Navigation.go(RESOURCE_BROWSER))
	top_bar.add_child(resources)

func _enter_main_preview() -> void:
	Navigation.go(SERVER_SELECT)

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i, rotated: bool = false) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x > 0 and crop.size.y > 0 and Rect2i(Vector2i.ZERO, image.get_size()).encloses(crop):
		image = image.get_region(crop)
		if rotated:
			image.rotate_90(COUNTERCLOCKWISE)
	return ImageTexture.create_from_image(image)

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	if not "--capture-login" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-login")
	var output_path := "user://original_login.png"
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
