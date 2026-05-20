extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const HERO_SHOW_SCENE := "res://scenes/original_draw_hero_show.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

const TABS := [
	{"label": "英灵来袭", "off": "image/com/DrawCard/zh_btn_gaojioff", "on": "image/com/DrawCard/zh_btn_gaojion", "spine": "res://data/spine_runtime/ZhaoHuan_GaoJi.json", "offset": Vector2(330, 0), "scale": 0.58},
	{"label": "普通", "off": "image/com/DrawCard/zh_btn_putongoff", "on": "image/com/DrawCard/zh_btn_putongon", "spine": "res://data/spine_runtime/ZhaoHuan_PuTong.json", "offset": Vector2(330, 0), "scale": 0.58},
	{"label": "友情", "off": "image/com/DrawCard/zh_btn_youqingoff", "on": "image/com/DrawCard/zh_btn_youqingon", "spine": "res://data/spine_runtime/ZhaoHuan_YouQing.json", "offset": Vector2(330, 0), "scale": 0.58},
	{"label": "高级", "off": "image/com/DrawCard/zh_btn_gaojioff", "on": "image/com/DrawCard/zh_btn_gaojion", "spine": "res://data/spine_runtime/ZhaoHuan_GaoJi.json", "offset": Vector2(330, 0), "scale": 0.58},
	{"label": "天命", "off": "image/com/DrawCard/zh_btn_xianzhioff", "on": "image/com/DrawCard/zh_btn_xianzhion", "spine": "res://data/spine_runtime/ZhaoHuan_XianZhi.json", "offset": Vector2(300, -12), "scale": 0.56},
]
const HERO_IDS := ["105004", "205008", "305006", "405007", "505004", "204001", "104002", "2050081"]

var design_root: Control
var named_resources: Dictionary = {}
var tab_buttons: Array[Button] = []
var hero_result_root: Control
var hero_ui_box: Control
var hero_ui_list: Control
var reward_root: Control
var info_label: Label
var progress_fill: ColorRect
var progress_label: Label
var pool_stage: Node2D
var pool_spine: Node2D
var summon_effect: Node2D
var selected_tab := 1
var summon_count := 11
var pool_spine_key := ""
var result_mode := false

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
	_build_hero_ui_box()
	_build_tabs()
	_build_exchange_panel()
	_layout_design_root()
	_refresh_tabs()
	_refresh_pool_spine()
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
	panel.position = Vector2(80, 52)
	panel.size = Vector2(824, 462)
	design_root.add_child(panel)

	var glow := ColorRect.new()
	glow.position = Vector2(64, 40)
	glow.size = Vector2(650, 326)
	glow.color = Color(0.05, 0.06, 0.12, 0.32)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(glow)

	pool_stage = Node2D.new()
	pool_stage.position = Vector2.ZERO
	panel.add_child(pool_stage)

	summon_effect = SimpleSpinePlayerScript.new()
	summon_effect.position = Vector2(248, 338)
	summon_effect.scale = Vector2(0.58, 0.58)
	summon_effect.visible = false
	pool_stage.add_child(summon_effect)
	if FileAccess.file_exists("res://data/spine_runtime/ZhaoHuan_ChouKa.json"):
		summon_effect.load_spine("res://data/spine_runtime/ZhaoHuan_ChouKa.json", "take")

	info_label = _add_label(panel, "普通卡池：10连招募必出5星SR或SSR英雄", Vector2(112, 360), Vector2(560, 32), 20, Color(1.0, 0.92, 0.62), HORIZONTAL_ALIGNMENT_CENTER)

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

func _build_hero_ui_box() -> void:
	hero_ui_box = Control.new()
	hero_ui_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hero_ui_box.visible = false
	design_root.add_child(hero_ui_box)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	hero_ui_box.add_child(dim)

	_add_label(hero_ui_box, "HeroUiBox | 召唤结果", Vector2(0, 58), Vector2(1280, 42), 28, Color(1.0, 0.86, 0.48), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(hero_ui_box, "点击头像打开 HeroShowPre 单英雄展示", Vector2(0, 102), Vector2(1280, 26), 17, Color(0.78, 0.88, 1.0), HORIZONTAL_ALIGNMENT_CENTER)

	hero_ui_list = Control.new()
	hero_ui_list.position = Vector2(145, 196)
	hero_ui_list.size = Vector2(990, 178)
	hero_ui_box.add_child(hero_ui_list)

	var back := Button.new()
	back.text = "返回召唤"
	back.position = Vector2(52, 34)
	back.size = Vector2(118, 38)
	back.pressed.connect(_close_result_mode)
	hero_ui_box.add_child(back)

	var call1 := Button.new()
	call1.text = "再召唤1次"
	call1.position = Vector2(460, 586)
	call1.size = Vector2(132, 52)
	call1.pressed.connect(func(): _summon(1))
	hero_ui_box.add_child(call1)

	var call10 := Button.new()
	call10.text = "再召唤10次"
	call10.position = Vector2(688, 586)
	call10.size = Vector2(142, 52)
	call10.pressed.connect(func(): _summon(10))
	hero_ui_box.add_child(call10)

	_refresh_hero_ui_box()

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
	result_mode = false
	_refresh_tabs()
	_refresh_pool_spine()
	_refresh_results()
	_refresh_hero_ui_box()
	_update_result_mode()

func _summon(amount: int) -> void:
	summon_count += amount
	result_mode = true
	_refresh_progress()
	_refresh_results()
	_refresh_hero_ui_box()
	_update_result_mode()
	_play_summon_effect()

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

func _refresh_hero_ui_box() -> void:
	if hero_ui_list == null:
		return
	for child in hero_ui_list.get_children():
		child.queue_free()
	var count := 10
	var offset := selected_tab * 2 + summon_count
	for i in count:
		var hero_id: String = str(HERO_IDS[(offset + i) % HERO_IDS.size()])
		var slot := Button.new()
		slot.text = ""
		slot.position = _hero_result_position(i)
		slot.size = Vector2(92, 124)
		slot.pressed.connect(_open_hero_show.bind(i, hero_id))
		hero_ui_list.add_child(slot)
		_add_named_image(slot, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(0, 0), Vector2(92, 92))
		_add_named_image(slot, "image/head/%s" % hero_id, Vector2(9, 9), Vector2(74, 74))
		_add_named_image(slot, "image/comHeroGrid/cm_tag_SSR1", Vector2(0, 0), Vector2(46, 24))
		_add_label(slot, "HeroBookItem%d" % i, Vector2(-10, 96), Vector2(112, 24), 14, Color(0.92, 0.9, 0.72), HORIZONTAL_ALIGNMENT_CENTER)

func _hero_result_position(index: int) -> Vector2:
	var cocos_positions := [
		Vector2(159.47, -100.66), Vector2(239.5, -65), Vector2(328.2, -35), Vector2(424, -15), Vector2(510, -8.85),
		Vector2(606, -8.5), Vector2(696, -14.8), Vector2(787, -34.7), Vector2(878.4, -64.8), Vector2(968, -99),
	]
	var pos: Vector2 = cocos_positions[index % cocos_positions.size()]
	return Vector2(pos.x - 96.0, 82.0 - pos.y * 0.35)

func _open_hero_show(index: int, id: String) -> void:
	Navigation.go_with_args(HERO_SHOW_SCENE, {"hero_show_index": index, "hero_id": id})

func _close_result_mode() -> void:
	result_mode = false
	_update_result_mode()

func _update_result_mode() -> void:
	if hero_ui_box:
		hero_ui_box.visible = result_mode

func _refresh_pool_spine() -> void:
	if pool_stage == null:
		return
	var tab: Dictionary = TABS[selected_tab]
	var data_path := str(tab.get("spine", ""))
	if data_path == pool_spine_key and pool_spine:
		return
	if pool_spine:
		pool_spine.queue_free()
		pool_spine = null
	pool_spine_key = data_path
	if not FileAccess.file_exists(data_path):
		return
	pool_spine = SimpleSpinePlayerScript.new()
	pool_stage.add_child(pool_spine)
	pool_spine.load_spine(data_path, "enter")
	_fit_spine_to_rect(pool_spine, Rect2(Vector2(86, 36), Vector2(628, 312)), float(tab.get("scale", 0.58)))
	pool_spine.position += tab.get("offset", Vector2.ZERO)

func _play_summon_effect() -> void:
	if summon_effect == null:
		return
	summon_effect.visible = true
	summon_effect.play("take")
	var tween := create_tween()
	tween.tween_interval(0.55)
	tween.tween_callback(func(): summon_effect.visible = false)

func _fit_spine_to_rect(player: Node2D, target: Rect2, max_scale: float) -> void:
	if not player.has_method("update_preview_pose") or not player.has_method("get_draw_bounds"):
		return
	player.update_preview_pose(0.4)
	var bounds: Rect2 = player.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var scale_value: float = minf(minf(target.size.x / bounds.size.x, target.size.y / bounds.size.y), max_scale)
	player.scale = Vector2(scale_value, scale_value)
	var bounds_center := bounds.position + bounds.size * 0.5
	player.position = target.position + target.size * 0.5 - bounds_center * scale_value

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
