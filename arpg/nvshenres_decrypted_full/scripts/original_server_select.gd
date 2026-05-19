extends Control

const MAIN_CITY := "res://scenes/original_home_screen.tscn"
const LOGIN_SCENE := "res://scenes/original_login.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const LAYOUT_PATH := "res://data/prefab_layouts/pfLoginPanelPre.json"
const BG_PATH := "res://converted/png/a84d3470-bde7-4589-9b33-65a957c34507.png"
const LOGIN_ATLAS_PATH := "res://assets/resources/native/1d/1d1cac610.png"
const UI_ATLAS_PATH := "res://assets/resources/native/14/1430d496a.png"
const BUTTON_ATLAS_PATH := "res://assets/resources/native/14/14d2fafcf.png"
const LOGIN_BUTTON_SHEET := "res://assets/resources/native/11/1109b405e.png"
const BOTTOM_RECT := Rect2i(206, 996, 2, 34)
const SERVER_BOX_RECT := Rect2i(987, 43, 29, 28)
const SERVER_FLOAT_BG_RECT := Rect2i(976, 893, 43, 48)
const SERVER_TAG_HOT_RECT := Rect2i(987, 3, 34, 34)
const SERVER_TAG_NEW_RECT := Rect2i(955, 987, 34, 34)
const SERVER_TAG_MAINTAIN_RECT := Rect2i(915, 987, 34, 34)
const SWITCH_ICON_RECT := Rect2i(170, 996, 30, 24)
const ICON_ACCOUNT_RECT := Rect2i(787, 893, 58, 58)
const ICON_NOTICE_RECT := Rect2i(851, 957, 58, 58)
const START_BUTTON_RECT := Rect2i(3, 3, 414, 102)
const TOGGLE_OFF_RECT := Rect2i(451, 524, 30, 30)
const DESIGN_SIZE := Vector2(1280, 720)

var design_root: Control
var layout_nodes: Dictionary = {}

func _ready() -> void:
	_load_layout_index()
	_build_ui()
	_capture_if_requested()

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
	bg.texture = _load_texture(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var bottom := TextureRect.new()
	var bottom_rect := Rect2(Vector2(-147.5, 607.0), Vector2(1575, 113))
	bottom.position = bottom_rect.position
	bottom.size = bottom_rect.size
	bottom.texture = _load_texture_region(UI_ATLAS_PATH, BOTTOM_RECT, true)
	bottom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bottom.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bottom)

	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(920, 16)
	top_bar.size = Vector2(344, 38)
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	design_root.add_child(top_bar)
	Navigation.add_buttons(top_bar)
	var prefab := Button.new()
	prefab.text = "原始选服"
	prefab.pressed.connect(func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "登录选服"}))
	top_bar.add_child(prefab)

	_add_icon_button(_layout_rect("btnGG", Rect2(Vector2(1168, 103.559), Vector2(58, 58))), ICON_NOTICE_RECT, "公告", func(): _show_local_notice())
	_add_icon_button(_layout_rect("btnSwitchAcount", Rect2(Vector2(1168, 179.559), Vector2(58, 58))), ICON_ACCOUNT_RECT, "切换账号", func(): Navigation.go(LOGIN_SCENE))
	_add_icon_button(_layout_rect("btnDiscord", Rect2(Vector2(1168, 262.559), Vector2(58, 58))), ICON_NOTICE_RECT, "discord", func(): _show_local_notice())
	_add_icon_button(_layout_rect("btnFacebook", Rect2(Vector2(1168, 344.559), Vector2(58, 58))), ICON_NOTICE_RECT, "facebook", func(): _show_local_notice())

	var floating_bg_rect := _layout_rect("xuanfu_bg", Rect2(Vector2(903.073, 436.971), Vector2(247, 47)))
	var floating_bg := NinePatchRect.new()
	floating_bg.position = floating_bg_rect.position
	floating_bg.size = floating_bg_rect.size
	floating_bg.texture = _load_texture_region(UI_ATLAS_PATH, SERVER_FLOAT_BG_RECT)
	floating_bg.patch_margin_left = 15
	floating_bg.patch_margin_top = 15
	floating_bg.patch_margin_right = 13
	floating_bg.patch_margin_bottom = 17
	floating_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(floating_bg)

	var server_row := Control.new()
	var server_rect := _layout_rect("btnSelect1", Rect2(Vector2(904, 439.386), Vector2(242, 40)))
	server_row.position = server_rect.position
	server_row.size = server_rect.size
	design_root.add_child(server_row)

	var server_bg := NinePatchRect.new()
	server_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	server_bg.texture = _load_texture_region(LOGIN_ATLAS_PATH, SERVER_BOX_RECT)
	server_bg.patch_margin_left = 10
	server_bg.patch_margin_top = 10
	server_bg.patch_margin_right = 10
	server_bg.patch_margin_bottom = 10
	server_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	server_row.add_child(server_bg)

	var server_label := Label.new()
	var server_label_rect := _layout_rect("txtServer", Rect2(Vector2(1001.893, 442.168), Vector2(92, 35.28)))
	server_label.position = server_label_rect.position - server_rect.position - Vector2(50, 0)
	server_label.size = Vector2(150, server_label_rect.size.y)
	server_label.text = "本地演示服"
	server_label.add_theme_font_size_override("font_size", 20)
	server_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	server_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	server_row.add_child(server_label)

	var hot := TextureRect.new()
	hot.position = Vector2(184, 3)
	hot.size = Vector2(34, 34)
	hot.texture = _load_texture_region(LOGIN_ATLAS_PATH, SERVER_TAG_HOT_RECT)
	hot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	server_row.add_child(hot)

	var switch_icon := TextureRect.new()
	switch_icon.position = Vector2(212, 8)
	switch_icon.size = Vector2(30, 24)
	switch_icon.texture = _load_texture_region(UI_ATLAS_PATH, SWITCH_ICON_RECT)
	switch_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	switch_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	server_row.add_child(switch_icon)

	var start_box := Control.new()
	var start_rect := _layout_rect("btn_start", Rect2(Vector2(753.176, 492.225), Vector2(550, 102)))
	start_box.position = start_rect.position
	start_box.size = start_rect.size
	design_root.add_child(start_box)

	var start_image := TextureRect.new()
	start_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_image.texture = _load_texture_region(LOGIN_BUTTON_SHEET, START_BUTTON_RECT)
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
	_add_label(start_box, "进入游戏", Vector2.ZERO, start_box.size, 24, Color(1.0, 0.96, 0.74)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var banhao_rect := _layout_rect("lblBanhao", Rect2(Vector2(408.02, 637.166), Vector2(466.67, 56.5)))
	var banhao := _add_label(design_root, "批许文号：新广出审[2017]6390号  ISBN：978-7-7979-9552-8\n著作权人：长沙骁之翼网络有限公司    出版单位：长沙骁之翼有限公司", banhao_rect.position, banhao_rect.size, 13, Color(0.86, 0.86, 0.9))
	banhao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banhao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var tip_rect := _layout_rect("lblTip", Rect2(Vector2(393.015, 687.553), Vector2(496.68, 31.5)))
	_add_label(design_root, "本网络游戏适合年满16周岁以上的用户使用：请您确认已如实进行实名注册", tip_rect.position, tip_rect.size, 13, Color(0.86, 0.86, 0.9)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var version_rect := _layout_rect("vesiontxt", Rect2(Vector2(42.638, 688.346), Vector2(174.82, 28.98)))
	_add_label(design_root, "资源版本号:v1.0.0", version_rect.position, version_rect.size, 13, Color(0.86, 0.86, 0.9)).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_add_privacy_row()

	_layout_design_root()

func _load_layout_index() -> void:
	if not FileAccess.file_exists(LAYOUT_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for node in parsed.get("nodes", []):
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var name := str(node.get("name", ""))
		if name != "" and not layout_nodes.has(name):
			layout_nodes[name] = node

func _layout_rect(name: String, fallback: Rect2) -> Rect2:
	if not layout_nodes.has(name):
		return fallback
	var node: Dictionary = layout_nodes[name]
	var rect: Array = node.get("screen_rect", [])
	if rect.size() >= 4:
		return Rect2(Vector2(float(rect[0]), float(rect[1])), Vector2(float(rect[2]), float(rect[3])))
	return fallback

func _add_icon_button(bounds: Rect2, rect: Rect2i, tooltip: String, callback: Callable) -> void:
	var box := Control.new()
	box.position = bounds.position
	box.size = bounds.size
	design_root.add_child(box)

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
	var label := _add_label(design_root, tooltip, bounds.position + Vector2(-12, 60), Vector2(82, 26), 15, Color(0.92, 0.94, 1.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_privacy_row() -> void:
	var rich_rect := _layout_rect("richtext", Rect2(Vector2(832.036, 578.608), Vector2(440, 27.72)))
	var toggle_rect := Rect2(rich_rect.position - Vector2(34, 1), Vector2(30, 30))
	var toggle := TextureRect.new()
	toggle.position = toggle_rect.position
	toggle.size = toggle_rect.size
	toggle.texture = _load_texture_region(UI_ATLAS_PATH, TOGGLE_OFF_RECT)
	toggle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	toggle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	toggle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(toggle)
	var privacy := RichTextLabel.new()
	privacy.position = rich_rect.position
	privacy.size = rich_rect.size + Vector2(10, 8)
	privacy.bbcode_enabled = true
	privacy.fit_content = true
	privacy.scroll_active = false
	privacy.text = "[color=#e5e8ff]我已阅读并同意[/color][color=#8fd7ff]《用户协议》[/color][color=#e5e8ff]和[/color][color=#8fd7ff]《隐私政策》[/color]"
	privacy.add_theme_font_size_override("normal_font_size", 15)
	privacy.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	privacy.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	privacy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(privacy)

func _show_local_notice() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "公告"
	dialog.dialog_text = "本地 Demo：当前仅展示已解密资源和离线界面流程。"
	add_child(dialog)
	dialog.popup_centered()

func _enter_main() -> void:
	Navigation.go(MAIN_CITY)

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

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

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _layout_design_root() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var scale_value: float = min(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(scale_value, scale_value)
	design_root.position = (viewport_size - DESIGN_SIZE * scale_value) * 0.5

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
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
