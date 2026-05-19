extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const DESIGN_SIZE := Vector2(1280, 720)

const TABS := [
	{"label": "英灵来袭", "off": "image/com/DrawCard/zh_btn_gaojioff", "on": "image/com/DrawCard/zh_btn_gaojion"},
	{"label": "普通", "off": "image/com/DrawCard/zh_btn_putongoff", "on": "image/com/DrawCard/zh_btn_putongon"},
	{"label": "友情", "off": "image/com/DrawCard/zh_btn_youqingoff", "on": "image/com/DrawCard/zh_btn_youqingon"},
	{"label": "高级", "off": "image/com/DrawCard/zh_btn_gaojioff", "on": "image/com/DrawCard/zh_btn_gaojion"},
	{"label": "天命", "off": "image/com/DrawCard/zh_btn_xianzhioff", "on": "image/com/DrawCard/zh_btn_xianzhion"},
]
const HERO_IDS := ["105004", "205008", "305006", "405007", "505004", "204001", "104002", "2050081"]

var design_root: Control
var named_resources: Dictionary = {}
var tab_buttons: Array[Button] = []
var hero_result_root: Control
var reward_root: Control
var info_label: Label
var progress_fill: ColorRect
var progress_label: Label
var selected_tab := 1
var summon_count := 11

func _ready() -> void:
	_load_named_resources()
	_build_ui()
	_apply_cmdline_args()
	_capture_if_requested()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.035, 0.04, 0.06, 1.0)
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var bg := _add_named_image(design_root, "image/com/DrawCard/zh_bg", Vector2.ZERO, DESIGN_SIZE)
	if bg:
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.modulate = Color(1, 1, 1, 0.82)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.22)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	_build_top_bar()
	_build_feature_panel()
	_build_reward_progress()
	_build_summon_controls()
	_build_result_preview()
	_build_tabs()
	_build_exchange_panel()
	_layout_design_root()
	_refresh_tabs()
	_refresh_progress()
	_refresh_results()

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 1.0
	top.anchor_right = 1.0
	top.offset_left = -690
	top.offset_top = 8
	top.offset_right = -12
	top.offset_bottom = 42
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	add_child(top)

	var title := Label.new()
	title.text = "DrawCardPre | 召唤"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	Navigation.add_buttons(top)
	_add_top_button(top, "主城", func(): Navigation.go(HOME_SCENE))
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "抽卡"}))

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _build_feature_panel() -> void:
	var panel := Control.new()
	panel.position = Vector2(118, 74)
	panel.size = Vector2(706, 350)
	design_root.add_child(panel)

	var card_resources := ["image/com/DrawCard/zh_image_pan2", "image/com/DrawCard/bx_icon_03", "image/com/DrawCard/bx_icon_02"]
	var names := ["限定英雄", "高级召唤", "友情召唤"]
	for i in 3:
		var card := Control.new()
		card.position = Vector2(36 + i * 214, 46)
		card.size = Vector2(176, 245)
		panel.add_child(card)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.08, 0.06, 0.12, 0.78)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(bg)
		_add_named_image(card, card_resources[i], Vector2(26, 20), Vector2(124, 124))
		_add_label(card, names[i], Vector2(0, 152), Vector2(176, 30), 21, Color(1.0, 0.88, 0.48), HORIZONTAL_ALIGNMENT_CENTER)
		var button := Button.new()
		button.text = "查看"
		button.position = Vector2(42, 194)
		button.size = Vector2(92, 34)
		card.add_child(button)

	info_label = _add_label(panel, "10连招募必出5星SR或SSR英雄", Vector2(80, 306), Vector2(520, 32), 20, Color(1.0, 0.92, 0.62), HORIZONTAL_ALIGNMENT_CENTER)

func _build_reward_progress() -> void:
	reward_root = Control.new()
	reward_root.position = Vector2(160, 432)
	reward_root.size = Vector2(528, 88)
	design_root.add_child(reward_root)

	var bg := ColorRect.new()
	bg.position = Vector2(38, 44)
	bg.size = Vector2(420, 16)
	bg.color = Color(0.03, 0.04, 0.07, 0.86)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_root.add_child(bg)

	progress_fill = ColorRect.new()
	progress_fill.position = Vector2(40, 46)
	progress_fill.size = Vector2(10, 12)
	progress_fill.color = Color(0.95, 0.61, 0.12)
	progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_root.add_child(progress_fill)

	for i in 4:
		_add_named_image(reward_root, "image/com/DrawCard/bx_icon_0%d" % (i + 1), Vector2(38 + i * 122, 0), Vector2(58, 58))
	progress_label = _add_label(reward_root, "", Vector2(156, 60), Vector2(210, 24), 16, Color(0.95, 0.9, 0.7), HORIZONTAL_ALIGNMENT_CENTER)

func _build_summon_controls() -> void:
	var panel := Control.new()
	panel.position = Vector2(96, 534)
	panel.size = Vector2(360, 132)
	design_root.add_child(panel)

	_add_label(panel, "召唤积分  360", Vector2(8, 0), Vector2(250, 28), 18, Color(1.0, 0.88, 0.52))
	_add_summon_button(panel, "召唤1次\n1000", Vector2(0, 46), 1)
	_add_summon_button(panel, "召唤10次\n9000", Vector2(142, 46), 10)

func _add_summon_button(parent: Control, text: String, position: Vector2, amount: int) -> void:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(126, 62)
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(_summon.bind(amount))
	parent.add_child(button)

func _build_result_preview() -> void:
	hero_result_root = Control.new()
	hero_result_root.position = Vector2(472, 532)
	hero_result_root.size = Vector2(382, 134)
	design_root.add_child(hero_result_root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.045, 0.07, 0.78)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_result_root.add_child(bg)
	_add_label(hero_result_root, "召唤结果预览", Vector2(0, 8), Vector2(382, 28), 20, Color(1.0, 0.88, 0.52), HORIZONTAL_ALIGNMENT_CENTER)

func _build_tabs() -> void:
	var tab_bg := _add_named_image(design_root, "image/com/DrawCard/zh_tab_di", Vector2(1016, 0), Vector2(245, 720))
	if tab_bg:
		tab_bg.stretch_mode = TextureRect.STRETCH_SCALE
	var box := VBoxContainer.new()
	box.position = Vector2(1028, 84)
	box.size = Vector2(206, 430)
	box.add_theme_constant_override("separation", 24)
	design_root.add_child(box)
	for i in TABS.size():
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(206, 68)
		button.pressed.connect(_select_tab.bind(i))
		box.add_child(button)
		tab_buttons.append(button)

func _build_exchange_panel() -> void:
	var panel := Control.new()
	panel.position = Vector2(910, 540)
	panel.size = Vector2(230, 126)
	design_root.add_child(panel)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.045, 0.07, 0.78)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(bg)
	_add_named_image(panel, "image/com/DrawCard/zh_btn_duihuan", Vector2(38, 12), Vector2(154, 46))
	_add_label(panel, "积分兑换\nSSR碎片 / 召唤券", Vector2(16, 66), Vector2(198, 48), 16, Color(0.86, 0.94, 1.0), HORIZONTAL_ALIGNMENT_CENTER)

func _select_tab(index: int) -> void:
	selected_tab = index
	_refresh_tabs()
	_refresh_results()

func _summon(amount: int) -> void:
	summon_count += amount
	_refresh_progress()
	_refresh_results()

func _refresh_tabs() -> void:
	for i in tab_buttons.size():
		var button := tab_buttons[i]
		for child in button.get_children():
			child.queue_free()
		var res := str(TABS[i].on if i == selected_tab else TABS[i].off)
		_add_named_image(button, res, Vector2.ZERO, Vector2(206, 68))
		_add_label(button, str(TABS[i].label), Vector2(0, 14), Vector2(206, 38), 20, Color(1.0, 0.92, 0.62), HORIZONTAL_ALIGNMENT_CENTER)
		button.disabled = i == selected_tab

func _refresh_progress() -> void:
	var value := clampf(float(summon_count % 120) / 120.0, 0.0, 1.0)
	progress_fill.size.x = 416.0 * value
	progress_label.text = "%d/120次" % (summon_count % 120)

func _refresh_results() -> void:
	for child in hero_result_root.get_children():
		if child is ColorRect or child is Label:
			continue
		child.queue_free()
	var offset := selected_tab * 2 + summon_count
	for i in 5:
		var hero_id: String = str(HERO_IDS[(offset + i) % HERO_IDS.size()])
		var x := 28 + i * 68
		_add_named_image(hero_result_root, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(x, 52), Vector2(56, 56))
		_add_named_image(hero_result_root, "image/head/%s" % hero_id, Vector2(x + 6, 58), Vector2(44, 44))
		_add_named_image(hero_result_root, "image/comHeroGrid/cm_tag_SSR1", Vector2(x, 52), Vector2(30, 18))
	info_label.text = "%s卡池：10连招募必出5星SR或SSR英雄" % str(TABS[selected_tab].label)

func _add_named_image(parent: Control, resource_name: String, position: Vector2, size: Vector2) -> TextureRect:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _texture_for_named_resource(resource_name)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _texture_for_named_resource(resource_name: String) -> Texture2D:
	var entry: Dictionary = named_resources.get(resource_name, {})
	if entry.is_empty():
		return null
	var native_path := "res://" + str(entry.get("native_path", entry.get("texture_path", "")))
	var rect_arr: Array = entry.get("rect", [])
	if rect_arr.is_empty():
		rect_arr = entry.get("sprite_rect", [])
	var rotated := bool(entry.get("rotated", entry.get("sprite_rotated", false)))
	var original_size := _arr_to_vec2i(entry.get("original_size", entry.get("sprite_original_size", [])))
	var offset := _arr_to_vec2(entry.get("offset", entry.get("sprite_offset", [])))
	if rect_arr.size() == 4:
		return _load_texture_region(native_path, Rect2i(int(rect_arr[0]), int(rect_arr[1]), int(rect_arr[2]), int(rect_arr[3])), rotated, original_size, offset)
	return _load_texture(native_path)

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _load_named_resources() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/named_resource_index.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		named_resources = parsed

func _apply_cmdline_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var tab_arg := _cmd_arg_value(args, "--draw-tab")
	if tab_arg.is_valid_int():
		selected_tab = clampi(int(tab_arg), 0, TABS.size() - 1)
	var count_arg := _cmd_arg_value(args, "--draw-count")
	if count_arg.is_valid_int():
		summon_count = maxi(0, int(count_arg))
	_refresh_tabs()
	_refresh_progress()
	_refresh_results()

func _cmd_arg_value(args: Array, key: String) -> String:
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

func _layout_design_root() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(factor, factor)
	design_root.position = (viewport_size - DESIGN_SIZE * factor) * 0.5

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return _make_sprite_frame_texture(image, region, rotated, original_size, offset)

func _make_sprite_frame_texture(atlas: Image, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(crop):
		return ImageTexture.create_from_image(atlas)
	var frame := atlas.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x <= 0 or original_size.y <= 0:
		return ImageTexture.create_from_image(frame)
	if original_size == frame.get_size():
		return ImageTexture.create_from_image(frame)
	frame.convert(Image.FORMAT_RGBA8)
	var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
	var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
	canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
	return ImageTexture.create_from_image(canvas)

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-draw-card" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-draw-card")
	var output_path := "user://draw_card.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
