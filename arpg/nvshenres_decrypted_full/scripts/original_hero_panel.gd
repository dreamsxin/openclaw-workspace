extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const SPINE_VIEWER := "res://scenes/spine_character_viewer.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

const BG_PATH := "res://assets/resources/native/ac/ac082229-4446-4cfe-bbaf-5e9849e208c3.png"
const ATLAS_18A := "res://assets/resources/native/18/18b29ae48.png"
const ATLAS_1A := "res://assets/resources/native/1a/1a7921f32.png"
const ATLAS_1F := "res://assets/resources/native/1f/1f6b547b4.png"
const HERO_TAB_ON_ATLAS := "res://assets/resources/native/15/15a1d9111.png"
const HERO_TAB_ON_RECT := Rect2i(530, 950, 64, 100)
const HERO_TAB_OFF_ATLAS := "res://assets/resources/native/18/18b29ae48.png"
const HERO_TAB_OFF_RECT := Rect2i(104, 349, 57, 100)
const HERO_105004_SPINE := "res://data/spine_runtime/105004.json"
const HERO_SULA_SPINE := "res://data/spine_runtime/SuLa_LH.json"
const HERO_YOUDUOLA_SPINE := "res://data/spine_runtime/YouDuoLa_LH.json"

const HEROES := [
	{"id": "105004", "name": "伊卡洛斯", "job": "灵师", "spine": HERO_105004_SPINE, "power": "3027113", "level": "120/360", "attrs": ["攻击 120360", "生命 568420", "防御 42310", "速度 1785"], "target": Rect2(Vector2(330, 88), Vector2(430, 600))},
	{"id": "205008", "name": "苏拉", "job": "战士", "spine": HERO_SULA_SPINE, "power": "2864100", "level": "108/300", "attrs": ["攻击 104820", "生命 612500", "防御 48990", "速度 1620"], "target": Rect2(Vector2(330, 80), Vector2(430, 610))},
	{"id": "305006", "name": "尤朵拉", "job": "射手", "spine": HERO_YOUDUOLA_SPINE, "power": "2719800", "level": "104/300", "attrs": ["攻击 132500", "生命 438200", "防御 36210", "速度 1915"], "target": Rect2(Vector2(330, 80), Vector2(430, 610))},
	{"id": "405007", "name": "拉瑞欧", "job": "守护", "head": "res://assets/resources/native/64/645eff01-c534-4380-951e-72eeea0bbd45.png", "power": "2339000", "level": "96/260", "attrs": ["攻击 82420", "生命 690000", "防御 62410", "速度 1210"]},
]

var design_root: Control
var hero_layer: Control
var hero_spine: Node2D
var hero_image: TextureRect
var title_label: Label
var detail_panel: Control
var tab_panel: Control
var side_panel: Control
var head_list: VBoxContainer
var tab_buttons: Array[Button] = []
var prev_button: Button
var next_button: Button
var named_resources: Dictionary = {}
var selected_hero := 0
var selected_tab := 0
var selected_animation := 0

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

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.82, 0.88, 1.0, 0.74)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.36)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	_build_top_bar()
	_build_side_panel()
	_build_hero_stage()
	_build_tabs()
	_build_detail_panel()
	_layout_design_root()
	_apply_hero()
	_refresh_all()

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 1.0
	top.anchor_right = 1.0
	top.offset_left = -720
	top.offset_top = 8
	top.offset_right = -12
	top.offset_bottom = 42
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	add_child(top)

	title_label = Label.new()
	title_label.text = "HeroMainPre"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title_label)
	Navigation.add_buttons(top)
	_add_top_button(top, "主城", func(): Navigation.go(HOME_SCENE))
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "英雄"}))
	_add_top_button(top, "Spine", func(): Navigation.go(SPINE_VIEWER))

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _build_side_panel() -> void:
	side_panel = Control.new()
	side_panel.position = Vector2(18, 80)
	side_panel.size = Vector2(216, 560)
	design_root.add_child(side_panel)

	var name_bg := ColorRect.new()
	name_bg.position = Vector2(0, 0)
	name_bg.size = Vector2(196, 146)
	name_bg.color = Color(0.04, 0.045, 0.075, 0.72)
	name_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side_panel.add_child(name_bg)

	_add_named_image_to(side_panel, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(14, 14), Vector2(68, 68))
	_add_label(side_panel, "", Vector2(90, 18), Vector2(104, 28), 20, Color(1.0, 0.88, 0.52)).name = "hero_name"
	_add_label(side_panel, "", Vector2(90, 50), Vector2(104, 24), 15, Color(0.78, 0.86, 1.0)).name = "hero_job"

	for i in 5:
		_add_named_image_to(side_panel, "image/comHeroGrid/cm_icon_XingXing1_1", Vector2(16 + i * 27, 100), Vector2(24, 24))

	for i in 3:
		var icon := Button.new()
		icon.position = Vector2(18, 232 + i * 68)
		icon.size = Vector2(54, 54)
		icon.text = ""
		icon.add_theme_font_size_override("font_size", 12)
		side_panel.add_child(icon)
		_add_named_image_to(icon, ["image/common/cm_btn_PingLun", "image/common/cm_btn_ShiZhuang", "image/common/cm_icon_GongJi"][i], Vector2(5, 5), Vector2(44, 44))

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(86, 156)
	scroll.size = Vector2(76, 398)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_panel.add_child(scroll)

	head_list = VBoxContainer.new()
	head_list.add_theme_constant_override("separation", 10)
	scroll.add_child(head_list)

func _build_hero_stage() -> void:
	hero_layer = Control.new()
	hero_layer.position = Vector2.ZERO
	hero_layer.size = DESIGN_SIZE
	design_root.add_child(hero_layer)

	hero_image = TextureRect.new()
	hero_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_layer.add_child(hero_image)

	hero_spine = SimpleSpinePlayerScript.new()
	hero_layer.add_child(hero_spine)

	var hit := Button.new()
	hit.flat = true
	hit.text = ""
	hit.position = Vector2(220, 54)
	hit.size = Vector2(430, 600)
	hit.tooltip_text = "切换动作"
	hit.pressed.connect(_cycle_animation)
	hero_layer.add_child(hit)

	prev_button = Button.new()
	prev_button.text = "<"
	prev_button.position = Vector2(166, 322)
	prev_button.size = Vector2(42, 78)
	prev_button.tooltip_text = "上一个英雄"
	prev_button.pressed.connect(_previous_hero)
	design_root.add_child(prev_button)

	next_button = Button.new()
	next_button.text = ">"
	next_button.position = Vector2(708, 322)
	next_button.size = Vector2(42, 78)
	next_button.tooltip_text = "下一个英雄"
	next_button.pressed.connect(_next_hero)
	design_root.add_child(next_button)

func _build_tabs() -> void:
	tab_panel = VBoxContainer.new()
	tab_panel.position = Vector2(666, 118)
	tab_panel.size = Vector2(88, 500)
	tab_panel.add_theme_constant_override("separation", 14)
	design_root.add_child(tab_panel)
	for label in ["培养", "装备", "升星", "战意", "衣装"]:
		var index := tab_panel.get_child_count()
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(88, 84)
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_select_tab.bind(index))
		tab_panel.add_child(button)
		tab_buttons.append(button)

func _build_detail_panel() -> void:
	detail_panel = Control.new()
	detail_panel.position = Vector2(786, 86)
	detail_panel.size = Vector2(404, 527)
	design_root.add_child(detail_panel)

	var frame_bg := _add_named_image_to(detail_panel, "image/en/HeroPanel/yx_frame_BaiBan", Vector2.ZERO, detail_panel.size)
	if frame_bg:
		frame_bg.name = "panel_frame"
	var shade := ColorRect.new()
	shade.name = "panel_bg"
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.58)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_panel.add_child(shade)

func _select_hero(index: int) -> void:
	selected_hero = index
	selected_animation = 0
	_refresh_all()

func _select_tab(index: int) -> void:
	selected_tab = index
	_refresh_all()

func _previous_hero() -> void:
	selected_hero = wrapi(selected_hero - 1, 0, HEROES.size())
	selected_animation = 0
	_refresh_all()

func _next_hero() -> void:
	selected_hero = wrapi(selected_hero + 1, 0, HEROES.size())
	selected_animation = 0
	_refresh_all()

func _refresh_all() -> void:
	_apply_hero()
	_refresh_side_panel()
	_refresh_tabs()
	_refresh_detail()

func _apply_hero() -> void:
	var hero: Dictionary = HEROES[selected_hero]
	title_label.text = "HeroMainPre | %s | %s" % [hero.name, _current_animation_name(hero)]
	if hero.has("spine"):
		hero_image.visible = false
		hero_spine.visible = true
		if hero_spine.load_spine(str(hero.spine), _current_animation_name(hero)):
			_fit_spine(hero)
	else:
		hero_spine.visible = false
		hero_image.visible = true
		var texture := _load_texture(str(hero.get("head", "")))
		hero_image.texture = texture
		hero_image.position = Vector2(270, 80)
		hero_image.size = Vector2(360, 520)

func _cycle_animation() -> void:
	var hero: Dictionary = HEROES[selected_hero]
	if not hero.has("spine"):
		return
	var animations := _animation_names(hero)
	if animations.size() <= 1:
		return
	selected_animation = wrapi(selected_animation + 1, 0, animations.size())
	hero_spine.play(str(animations[selected_animation]))
	_fit_spine(hero)
	_refresh_all()

func _refresh_side_panel() -> void:
	if side_panel == null:
		return
	var hero: Dictionary = HEROES[selected_hero]
	var name_label := side_panel.get_node_or_null("hero_name") as Label
	if name_label:
		name_label.text = str(hero.name)
	var job_label := side_panel.get_node_or_null("hero_job") as Label
	if job_label:
		job_label.text = str(hero.job)
	for child in side_panel.get_children():
		if child.name == "dynamic_head":
			child.queue_free()
	var head_root := Control.new()
	head_root.name = "dynamic_head"
	head_root.position = Vector2.ZERO
	side_panel.add_child(head_root)
	_add_named_image_to(head_root, "image/head/%s" % hero.id, Vector2(22, 22), Vector2(52, 52))
	_refresh_head_list()

func _refresh_head_list() -> void:
	if head_list == null:
		return
	for child in head_list.get_children():
		child.queue_free()
	for i in HEROES.size():
		var hero: Dictionary = HEROES[i]
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(64, 64)
		button.disabled = i == selected_hero
		button.pressed.connect(_select_hero.bind(i))
		head_list.add_child(button)
		_add_head_icon(button, hero, Vector2(2, 2), Vector2(60, 60))

func _refresh_tabs() -> void:
	for i in tab_buttons.size():
		var button := tab_buttons[i]
		for child in button.get_children():
			child.queue_free()
		button.disabled = i == selected_tab
		if i == selected_tab:
			_add_sprite_frame_image(button, HERO_TAB_ON_ATLAS, HERO_TAB_ON_RECT, Vector2(12, -8), Vector2(64, 100), true, Vector2i(64, 100), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		else:
			_add_sprite_frame_image(button, HERO_TAB_OFF_ATLAS, HERO_TAB_OFF_RECT, Vector2(16, -8), Vector2(57, 100), false, Vector2i(57, 100), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		_add_label(button, ["培养", "装备", "升星", "战意", "衣装"][i], Vector2(0, 12), button.custom_minimum_size, 18, Color(0.92, 0.9, 0.82)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _refresh_detail() -> void:
	for child in detail_panel.get_children():
		if child.name == "panel_bg" or child.name == "panel_frame":
			continue
		child.queue_free()
	var hero: Dictionary = HEROES[selected_hero]
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 22
	root.offset_top = 18
	root.offset_right = -20
	root.offset_bottom = -18
	detail_panel.add_child(root)

	_add_label(root, "%s  Lv.%s" % [hero.name, hero.level], Vector2(0, 0), Vector2(340, 34), 24, Color(1.0, 0.87, 0.5))
	_add_label(root, "%s  高输出 物理伤害" % hero.job, Vector2(0, 34), Vector2(340, 28), 16, Color(0.77, 0.86, 1.0))
	_add_named_image_to(root, "image/en/HeroPanel/yx_frame_ZhanLi", Vector2(-6, 70), Vector2(360, 36))
	_add_label(root, "战力  %s" % hero.power, Vector2(0, 70), Vector2(340, 34), 22, Color(1.0, 0.96, 0.78))

	if selected_tab == 0:
		_add_culture_tab(root, hero)
	elif selected_tab == 1:
		_add_equipment_tab(root)
	elif selected_tab == 2:
		_add_star_tab(root)
	elif selected_tab == 3:
		_add_will_tab(root)
	else:
		_add_skin_tab(root)

func _add_culture_tab(root: Control, hero: Dictionary) -> void:
	for i in hero.attrs.size():
		_add_label(root, str(hero.attrs[i]), Vector2(0, 126 + i * 40), Vector2(230, 30), 18, Color(0.9, 0.96, 1.0))
	_add_progress(root, Vector2(0, 306), Vector2(260, 20), 0.72, "等级  %s" % hero.level)
	_add_action_button(root, "升2级", Vector2(42, 374), Vector2(130, 42))
	_add_action_button(root, "进阶", Vector2(194, 374), Vector2(130, 42))

func _add_equipment_tab(root: Control) -> void:
	var equips := ["yx_icon_zhuangbei0", "yx_icon_zhuangbei1", "yx_icon_zhuangbei2", "yx_icon_zhuangbei3", "yx_icon_zhuangbei4", "yx_icon_zhuangbei5"]
	for i in equips.size():
		var pos := Vector2((i % 3) * 88, 126 + int(i / 3) * 88)
		var slot := Control.new()
		slot.position = pos
		slot.size = Vector2(72, 72)
		root.add_child(slot)
		var slot_bg := ColorRect.new()
		slot_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot_bg.color = Color(0.03, 0.035, 0.055, 0.72)
		slot_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(slot_bg)
		_add_named_image_to(slot, "image/en/HeroPanel/yx_frame_ZBCheng", Vector2(0, 0), Vector2(72, 72))
		_add_named_image_to(slot, "image/en/HeroPanel/%s" % equips[i], Vector2(13, 13), Vector2(46, 46))
	_add_action_button(root, "一键装备", Vector2(0, 374), Vector2(130, 42))
	_add_action_button(root, "强化", Vector2(150, 374), Vector2(130, 42))

func _add_star_tab(root: Control) -> void:
	_add_label(root, "当前星级  SSR 3 星", Vector2(0, 126), Vector2(300, 30), 20, Color(1.0, 0.9, 0.48))
	_add_progress(root, Vector2(0, 178), Vector2(280, 20), 0.42, "碎片 42/100")
	_add_action_button(root, "升星", Vector2(0, 246), Vector2(130, 42))

func _add_will_tab(root: Control) -> void:
	for i in 4:
		_add_label(root, ["攻击 +100", "生命 +2200", "防御 +80", "速度 +12"][i], Vector2(0, 126 + i * 42), Vector2(260, 30), 18, Color(0.9, 0.96, 1.0))
	_add_action_button(root, "激活战意", Vector2(0, 374), Vector2(150, 42))

func _add_skin_tab(root: Control) -> void:
	_add_label(root, "敬请期待", Vector2(0, 160), Vector2(320, 44), 24, Color(0.92, 0.92, 0.96))
	_add_action_button(root, "前往获取", Vector2(0, 374), Vector2(150, 42))

func _add_progress(parent: Control, position: Vector2, size: Vector2, value: float, text: String) -> void:
	var bg := ColorRect.new()
	bg.position = position
	bg.size = size
	bg.color = Color(0.03, 0.04, 0.07, 0.86)
	parent.add_child(bg)
	var fill := ColorRect.new()
	fill.position = position + Vector2(2, 2)
	fill.size = Vector2((size.x - 4) * clampf(value, 0.0, 1.0), size.y - 4)
	fill.color = Color(0.95, 0.62, 0.12, 1.0)
	parent.add_child(fill)
	_add_label(parent, text, position + Vector2(0, -28), Vector2(size.x, 24), 16, Color(0.96, 0.9, 0.68))

func _add_action_button(parent: Control, text: String, position: Vector2, size: Vector2) -> void:
	var button := Button.new()
	button.text = ""
	button.position = position
	button.size = size
	parent.add_child(button)
	_add_named_image_to(button, "image/common/cm_btn_LvSe1", Vector2.ZERO, size)
	_add_label(button, text, Vector2.ZERO, size, 18, Color(0.95, 1.0, 0.92)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_head_icon(parent: Control, hero: Dictionary, position: Vector2, size: Vector2) -> void:
	_add_named_image_to(parent, "image/comHeroGrid/cm_frame_TouXiangDi5", position, size)
	_add_named_image_to(parent, "image/head/%s" % hero.id, position + Vector2(8, 8), size - Vector2(16, 16))
	_add_named_image_to(parent, "image/comHeroGrid/cm_tag_SSR1", position, Vector2(34, 22))

func _add_named_image_to(parent: Control, resource_name: String, position: Vector2, size: Vector2) -> TextureRect:
	var texture := _texture_for_named_resource(resource_name)
	if texture == null:
		return null
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _add_sprite_frame_image(parent: Control, atlas_path: String, rect: Rect2i, position: Vector2, size: Vector2, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _load_texture_region(atlas_path, rect, rotated, original_size, offset)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch
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
	var rotated := bool(entry.get("rotated", false))
	if entry.has("sprite_rotated"):
		rotated = bool(entry.get("sprite_rotated", false))
	var original_size := _arr_to_vec2i(entry.get("original_size", []))
	if original_size == Vector2i.ZERO:
		original_size = _arr_to_vec2i(entry.get("sprite_original_size", []))
	var offset := _arr_to_vec2(entry.get("offset", []))
	if offset == Vector2.ZERO:
		offset = _arr_to_vec2(entry.get("sprite_offset", []))
	if rect_arr.size() == 4:
		return _load_texture_region(native_path, Rect2i(int(rect_arr[0]), int(rect_arr[1]), int(rect_arr[2]), int(rect_arr[3])), rotated, original_size, offset)
	return _load_texture(native_path)

func _load_named_resources() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/named_resource_index.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		named_resources = parsed

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _fit_spine(hero: Dictionary) -> void:
	hero_spine.update_preview_pose(0.0)
	var bounds: Rect2 = hero_spine.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var target: Rect2 = hero.get("target", Rect2(Vector2(330, 88), Vector2(430, 600)))
	var scale_value: float = min(target.size.x / bounds.size.x, target.size.y / bounds.size.y)
	hero_spine.scale = Vector2(scale_value, scale_value)
	var bounds_center := bounds.position + bounds.size * 0.5
	var target_center := target.position + target.size * 0.5
	hero_spine.position = target_center - bounds_center * scale_value

func _current_animation_name(hero: Dictionary) -> String:
	var animations := _animation_names(hero)
	if animations.is_empty():
		return "idle"
	selected_animation = clampi(selected_animation, 0, animations.size() - 1)
	return str(animations[selected_animation])

func _animation_names(hero: Dictionary) -> Array:
	var path := str(hero.get("spine", ""))
	if path == "":
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return ["idle"]
	var skeleton: Dictionary = parsed.get("skeleton", {})
	var animation_dict: Dictionary = skeleton.get("animations", {})
	var names := animation_dict.keys()
	names.sort()
	if names.has("idle"):
		names.erase("idle")
		names.push_front("idle")
	return names

func _apply_cmdline_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var hero_arg := _cmd_arg_value(args, "--hero-index")
	if hero_arg.is_valid_int():
		selected_hero = clampi(int(hero_arg), 0, HEROES.size() - 1)
	var tab_arg := _cmd_arg_value(args, "--hero-tab")
	if tab_arg.is_valid_int():
		selected_tab = clampi(int(tab_arg), 0, 4)
	_refresh_all()

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
	if not "--capture-hero-panel" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-hero-panel")
	var output_path := "user://hero_panel.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
