extends Control

const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const SERVER_SELECT := "res://scenes/original_server_select.tscn"
const LAYOUT_PATH := "res://data/prefab_layouts/LoginPre.json"
const BG_PATH := "res://converted/png/a84d3470-bde7-4589-9b33-65a957c34507.png"
const UI_ATLAS_PATH := "res://assets/resources/native/14/1430d496a.png"
const LOGIN_BUTTON_ATLAS := "res://assets/resources/native/1d/1d1cac610.png"
const LOGIN_BUTTON_SHEET := "res://assets/resources/native/11/1109b405e.png"
const LOGIN_BUTTON_RECT := Rect2i(3, 3, 414, 102)
const BOTTOM_RECT := Rect2i(206, 996, 2, 34)
const EDIT_BG_RECT := Rect2i(653, 823, 198, 62)
const SIDE_ICON_RECTS := {
	"btnUserRule": Rect2i(851, 893, 58, 58),
	"btnUserCenter": Rect2i(787, 957, 58, 58),
	"btnGG": Rect2i(851, 957, 58, 58),
}
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

	var login_box := Control.new()
	var login_rect := _layout_rect("loginBtn", Rect2(Vector2(365, 614.871), Vector2(550, 102)))
	login_box.position = login_rect.position
	login_box.size = login_rect.size
	design_root.add_child(login_box)

	var login_image := TextureRect.new()
	login_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	login_image.texture = _load_texture_region(LOGIN_BUTTON_SHEET, LOGIN_BUTTON_RECT)
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
	_add_label(login_box, "进入游戏", Vector2(195, 26), Vector2(160, 50), 28, Color(1.0, 0.94, 0.72)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_add_debug_login_fields()

	var side_items := [
		{"label": "用户协议", "node": "btnUserRule", "pos": Vector2(1176, 271.097)},
		{"label": "用户中心", "node": "btnUserCenter", "pos": Vector2(1176, 186.097)},
		{"label": "公告", "node": "btnGG", "pos": Vector2(1176, 101.097)},
	]
	for item in side_items:
		var rect := _layout_rect(str(item.node), Rect2(item.pos, Vector2(58, 58)))
		_add_side_button(rect.position, rect.size, SIDE_ICON_RECTS.get(str(item.node), Rect2i()), item.label)

	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(876, 16)
	top_bar.size = Vector2(388, 38)
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	design_root.add_child(top_bar)

	Navigation.add_buttons(top_bar)

	var preview := Button.new()
	preview.text = "原始界面预览"
	preview.pressed.connect(func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "登录面板"}))
	top_bar.add_child(preview)

	var resources := Button.new()
	resources.text = "资源浏览"
	resources.pressed.connect(func(): Navigation.go(RESOURCE_BROWSER))
	top_bar.add_child(resources)

	var version_rect := _layout_rect("vesion", Rect2(Vector2(610.938, 678.55), Vector2(120, 18.9)))
	var version := _add_label(design_root, "资源版本号:v1.0.0", version_rect.position - Vector2(30, 0), Vector2(180, version_rect.size.y), 13, Color(0.88, 0.9, 0.95))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_layout_design_root()

func _enter_main_preview() -> void:
	Navigation.go(SERVER_SELECT)

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

func _add_side_button(pos: Vector2, size: Vector2, rect: Rect2i, text: String) -> void:
	var box := Button.new()
	box.text = ""
	box.flat = true
	box.position = pos
	box.size = size
	box.tooltip_text = text
	design_root.add_child(box)
	var icon := TextureRect.new()
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.texture = _load_texture_region(UI_ATLAS_PATH, rect)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)
	var label := _add_label(design_root, text, pos + Vector2(-5, 66), Vector2(68, 24), 16, Color(0.92, 0.94, 1.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_debug_login_fields() -> void:
	var rows := [
		{"node": "tbg1", "text": "127.0.0.1"},
		{"node": "tbg2", "text": "8080"},
		{"node": "tbg3", "text": "local_user"},
		{"node": "tbg4", "text": "password"},
	]
	for row in rows:
		var rect := _layout_rect(str(row.node), Rect2(Vector2(541, 232), Vector2(198, 42)))
		var field_bg := NinePatchRect.new()
		field_bg.position = rect.position
		field_bg.size = rect.size
		field_bg.texture = _load_texture_region(UI_ATLAS_PATH, EDIT_BG_RECT, true)
		field_bg.patch_margin_left = 22
		field_bg.patch_margin_top = 16
		field_bg.patch_margin_right = 18
		field_bg.patch_margin_bottom = 14
		field_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		design_root.add_child(field_bg)
		var label := _add_label(design_root, str(row.text), rect.position + Vector2(14, 2), rect.size - Vector2(28, 4), 18, Color(0.95, 0.96, 1.0))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

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
