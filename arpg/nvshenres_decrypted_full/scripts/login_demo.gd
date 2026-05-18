extends Control

const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const MAIN_DEMO := "res://scenes/main_demo.tscn"
const BG_PATHS := [
	"res://assets/resources/native/24/247375b4-3477-4384-8f97-172c5b1476e7.jpg",
	"res://assets/resources/native/62/62a35810-209e-494c-8aa8-0bcb8e30b4c0.jpg",
	"res://assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png",
	"res://assets/resources/native/a8/a84d3470-bde7-4589-9b33-65a957c34507.jpg",
]
const LOGO_PATH := "res://assets/resources/native/79/79c65354-c0eb-4370-be97-0d7a4dbf05e1.png"
const LOGIN_BUTTON_PATH := "res://assets/resources/native/5b/5bdf6505-27d4-4c65-93ef-f9d027895e2b.png"
const HERO_DECOR_PATH := "res://assets/resources/native/48/4899e8d7-22c9-49cf-8140-a75e78d32881.png"

var bg_index := 0
var background: TextureRect
var status_label: Label

func _ready() -> void:
	_build_ui()
	_set_background(0)

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	root.add_child(background)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.015, 0.025, 0.38)
	root.add_child(shade)

	var top_bar := HBoxContainer.new()
	top_bar.anchor_left = 0.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = 24
	top_bar.offset_top = 18
	top_bar.offset_right = -24
	top_bar.offset_bottom = 58
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(top_bar)

	var browse_button := Button.new()
	browse_button.text = "资源浏览"
	browse_button.pressed.connect(_open_resource_browser)
	top_bar.add_child(browse_button)

	var switch_button := Button.new()
	switch_button.text = "切换背景"
	switch_button.pressed.connect(_next_background)
	top_bar.add_child(switch_button)

	var center := VBoxContainer.new()
	center.anchor_left = 0.5
	center.anchor_top = 0.5
	center.anchor_right = 0.5
	center.anchor_bottom = 0.5
	center.offset_left = -260
	center.offset_top = -210
	center.offset_right = 260
	center.offset_bottom = 230
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	root.add_child(center)

	var logo := TextureRect.new()
	logo.custom_minimum_size = Vector2(460, 150)
	logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture = _load_texture(LOGO_PATH)
	center.add_child(logo)

	var subtitle := Label.new()
	subtitle.text = "本地资源演示 Demo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	center.add_child(subtitle)

	var form := PanelContainer.new()
	form.custom_minimum_size = Vector2(420, 190)
	center.add_child(form)

	var form_box := VBoxContainer.new()
	form_box.add_theme_constant_override("separation", 10)
	form_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	form_box.offset_left = 24
	form_box.offset_top = 18
	form_box.offset_right = -24
	form_box.offset_bottom = -18
	form.add_child(form_box)

	var account := LineEdit.new()
	account.placeholder_text = "账号"
	account.text = "local_demo"
	form_box.add_child(account)

	var server := OptionButton.new()
	server.add_item("本地演示服")
	server.add_item("资源预览服")
	form_box.add_child(server)

	var login := TextureButton.new()
	login.custom_minimum_size = Vector2(300, 82)
	var login_tex := _load_texture(LOGIN_BUTTON_PATH)
	login.texture_normal = login_tex
	login.texture_hover = login_tex
	login.texture_pressed = login_tex
	login.ignore_texture_size = true
	login.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	login.pressed.connect(_on_login_pressed)
	form_box.add_child(login)

	status_label = Label.new()
	status_label.text = "离线模式：不连接服务器，仅展示已解密资源。"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_box.add_child(status_label)

	var decor := TextureRect.new()
	decor.anchor_left = 1.0
	decor.anchor_top = 1.0
	decor.anchor_right = 1.0
	decor.anchor_bottom = 1.0
	decor.offset_left = -280
	decor.offset_top = -250
	decor.offset_right = -24
	decor.offset_bottom = -24
	decor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	decor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	decor.texture = _load_texture(HERO_DECOR_PATH)
	root.add_child(decor)

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _set_background(index: int) -> void:
	bg_index = index % BG_PATHS.size()
	background.texture = _load_texture(BG_PATHS[bg_index])

func _next_background() -> void:
	_set_background(bg_index + 1)

func _on_login_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_DEMO)

func _open_resource_browser() -> void:
	get_tree().change_scene_to_file(RESOURCE_BROWSER)
