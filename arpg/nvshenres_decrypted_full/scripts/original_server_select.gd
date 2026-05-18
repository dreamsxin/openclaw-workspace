extends Control

const MAIN_CITY := "res://scenes/original_home_screen.tscn"
const LOGIN_SCENE := "res://scenes/original_login.tscn"
const BG_PATH := "res://assets/resources/native/11/1176e8f9-db52-4635-b647-5192e470dc81.png"
const LOGIN_ATLAS_PATH := "res://assets/resources/native/1d/1d1cac610.png"
const UI_ATLAS_PATH := "res://assets/resources/native/14/1430d496a.png"
const LOGIN_BUTTON_PATH := "res://assets/resources/native/5b/5bdf6505-27d4-4c65-93ef-f9d027895e2b.png"
const LOGO_RECT := Rect2i(3, 612, 400, 254)
const SERVER_BOX_RECT := Rect2i(987, 43, 29, 28)
const SERVER_TAG_HOT_RECT := Rect2i(987, 3, 34, 34)
const SERVER_TAG_NEW_RECT := Rect2i(955, 987, 34, 34)
const SWITCH_ICON_RECT := Rect2i(170, 996, 30, 24)
const ICON_ACCOUNT_RECT := Rect2i(787, 893, 58, 58)
const ICON_NOTICE_RECT := Rect2i(851, 957, 58, 58)

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
	logo.anchor_left = 0.0
	logo.anchor_top = 0.0
	logo.anchor_right = 0.0
	logo.anchor_bottom = 0.0
	logo.offset_left = 690
	logo.offset_top = 62
	logo.offset_right = 1090
	logo.offset_bottom = 316
	logo.texture = _load_texture_region(LOGIN_ATLAS_PATH, LOGO_RECT, true)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)

	var top_bar := HBoxContainer.new()
	top_bar.anchor_left = 1.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = -272
	top_bar.offset_top = 16
	top_bar.offset_right = -16
	top_bar.offset_bottom = 52
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	add_child(top_bar)
	Navigation.add_buttons(top_bar)

	_add_icon_button(Vector2(1150, 62), ICON_NOTICE_RECT, "公告", func(): _show_local_notice())
	_add_icon_button(Vector2(1068, 62), ICON_ACCOUNT_RECT, "切换账号", func(): Navigation.go(LOGIN_SCENE))

	var panel := VBoxContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_top = 0.5
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.5
	panel.offset_left = -500
	panel.offset_top = -92
	panel.offset_right = -72
	panel.offset_bottom = 190
	panel.add_theme_constant_override("separation", 12)
	add_child(panel)

	var server_row := Control.new()
	server_row.custom_minimum_size = Vector2(428, 72)
	panel.add_child(server_row)

	var server_bg := NinePatchRect.new()
	server_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	server_bg.texture = _load_texture_region(LOGIN_ATLAS_PATH, SERVER_BOX_RECT)
	server_bg.patch_margin_left = 10
	server_bg.patch_margin_top = 10
	server_bg.patch_margin_right = 10
	server_bg.patch_margin_bottom = 10
	server_row.add_child(server_bg)

	var server_label := Label.new()
	server_label.position = Vector2(34, 14)
	server_label.size = Vector2(292, 42)
	server_label.text = "本地演示服"
	server_label.add_theme_font_size_override("font_size", 28)
	server_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	server_row.add_child(server_label)

	var switch_icon := TextureRect.new()
	switch_icon.position = Vector2(358, 24)
	switch_icon.size = Vector2(30, 24)
	switch_icon.texture = _load_texture_region(UI_ATLAS_PATH, SWITCH_ICON_RECT)
	switch_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	switch_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	server_row.add_child(switch_icon)

	var start_box := Control.new()
	start_box.custom_minimum_size = Vector2(428, 104)
	panel.add_child(start_box)

	var start_image := TextureRect.new()
	start_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_image.texture = _load_texture(LOGIN_BUTTON_PATH)
	start_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	start_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	start_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_box.add_child(start_image)

	var start_hit := Button.new()
	start_hit.text = ""
	start_hit.flat = true
	start_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_hit.tooltip_text = "进入主城"
	start_hit.pressed.connect(_enter_main)
	start_box.add_child(start_hit)

	var tip := Label.new()
	tip.text = "离线模式：服务器数据为本地演示。"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16)
	panel.add_child(tip)

func _add_icon_button(pos: Vector2, rect: Rect2i, tooltip: String, callback: Callable) -> void:
	var box := Control.new()
	box.position = pos
	box.size = Vector2(58, 58)
	add_child(box)

	var image := TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.texture = _load_texture_region(UI_ATLAS_PATH, rect)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(image)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = tooltip
	hit.pressed.connect(callback)
	box.add_child(hit)

func _show_local_notice() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "公告"
	dialog.dialog_text = "本地 Demo：当前仅展示已解密资源和离线界面流程。"
	add_child(dialog)
	dialog.popup_centered()

func _enter_main() -> void:
	Navigation.go(MAIN_CITY)

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
	if not "--capture-server-select" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-server-select")
	var output_path := "user://server_select.png"
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
