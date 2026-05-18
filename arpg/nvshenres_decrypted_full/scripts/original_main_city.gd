extends Control

const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const BG_PATH := "res://assets/resources/native/4f/4fe2dfa8-dcc7-455d-b274-485c00c73e0b.png"
const MAIN_ATLAS_PATH := "res://assets/resources/native/1f/1f6b547b4.png"
const LOGIN_ATLAS_PATH := "res://assets/resources/native/1d/1d1cac610.png"
const UI_ATLAS_PATH := "res://assets/resources/native/14/1430d496a.png"
const LOGO_RECT := Rect2i(3, 612, 400, 254)
const ENTRY_RECT := Rect2i(675, 230, 336, 56)
const GIFT_RECT := Rect2i(547, 551, 34, 34)
const SUMMON_RECT := Rect2i(707, 551, 34, 34)
const RANK_RECT := Rect2i(943, 774, 80, 78)
const DAILY_RECT := Rect2i(850, 859, 70, 70)
const BACKPLATE_RECT := Rect2i(486, 555, 54, 156)
const NOTICE_RECT := Rect2i(851, 957, 58, 58)
const HEROES := [
	{
		"name": "YiLiYa",
		"body_id": "local_preview_01",
		"path": "res://assets/resources/native/d2/d25fe7e6-9571-42ef-b9f6-066ae454dab6.png",
		"size": Vector2(500, 650),
		"position": Vector2(360, 74),
	},
	{
		"name": "Knight",
		"body_id": "local_preview_02",
		"path": "res://assets/resources/native/64/645eff01-c534-4380-951e-72eeea0bbd45.png",
		"size": Vector2(390, 590),
		"position": Vector2(390, 112),
	},
	{
		"name": "Butler",
		"body_id": "local_preview_03",
		"path": "res://assets/resources/native/01/011295d0-6cf2-4807-b5c8-9c08d3eed948.png",
		"size": Vector2(250, 620),
		"position": Vector2(456, 88),
	},
	{
		"name": "Monster",
		"body_id": "local_preview_04",
		"path": "res://assets/resources/native/1c/1ca6751c-83d4-4b5e-9871-29c26e0d43c2.png",
		"size": Vector2(420, 590),
		"position": Vector2(386, 118),
	},
]

var hero_index := 0
var hero_image: TextureRect
var hero_name_label: Label
var hero_tween: Tween

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

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.05, 0.035, 0.08, 0.08)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var top := HBoxContainer.new()
	top.anchor_left = 0.0
	top.anchor_top = 0.0
	top.anchor_right = 1.0
	top.anchor_bottom = 0.0
	top.offset_left = 16
	top.offset_top = 12
	top.offset_right = -16
	top.offset_bottom = 52
	top.alignment = BoxContainer.ALIGNMENT_END
	add_child(top)

	var title := Label.new()
	title.text = "主城"
	title.add_theme_font_size_override("font_size", 26)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	Navigation.add_buttons(top)

	var resources := Button.new()
	resources.text = "资源浏览"
	resources.pressed.connect(func(): Navigation.go(RESOURCE_BROWSER))
	top.add_child(resources)

	var prefab := Button.new()
	prefab.text = "Prefab 预览"
	prefab.pressed.connect(func(): Navigation.go(PREFAB_PREVIEW))
	top.add_child(prefab)

	_add_hero_showcase()
	_add_right_entries()
	_add_bottom_nav()

func _add_hero_showcase() -> void:
	var shadow := ColorRect.new()
	shadow.position = Vector2(350, 635)
	shadow.size = Vector2(420, 34)
	shadow.color = Color(0, 0, 0, 0.28)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shadow)

	hero_image = TextureRect.new()
	hero_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hero_image)

	var controls := HBoxContainer.new()
	controls.position = Vector2(430, 610)
	controls.size = Vector2(300, 50)
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 10)
	add_child(controls)

	var prev := Button.new()
	prev.text = "<"
	prev.custom_minimum_size = Vector2(44, 38)
	prev.pressed.connect(func(): _select_hero(-1))
	controls.add_child(prev)

	hero_name_label = Label.new()
	hero_name_label.custom_minimum_size = Vector2(170, 38)
	hero_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hero_name_label.add_theme_font_size_override("font_size", 20)
	hero_name_label.add_theme_color_override("font_color", Color.WHITE)
	hero_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	hero_name_label.add_theme_constant_override("shadow_offset_x", 2)
	hero_name_label.add_theme_constant_override("shadow_offset_y", 2)
	controls.add_child(hero_name_label)

	var next := Button.new()
	next.text = ">"
	next.custom_minimum_size = Vector2(44, 38)
	next.pressed.connect(func(): _select_hero(1))
	controls.add_child(next)

	_apply_hero()

func _select_hero(delta: int) -> void:
	hero_index = wrapi(hero_index + delta, 0, HEROES.size())
	_apply_hero()

func _apply_hero() -> void:
	if hero_image == null:
		return
	var hero: Dictionary = HEROES[hero_index]
	hero_image.texture = _load_texture(str(hero.path))
	hero_image.position = hero.position
	hero_image.size = hero.size
	hero_image.pivot_offset = hero_image.size * 0.5
	hero_image.modulate = Color(1, 1, 1, 1)
	hero_image.scale = Vector2(1.0, 1.0)
	if hero_name_label:
		hero_name_label.text = "%s  %s" % [hero.name, hero.body_id]
	_start_hero_motion(hero.position)

func _start_hero_motion(base_position: Vector2) -> void:
	if hero_tween:
		hero_tween.kill()
	hero_tween = create_tween()
	hero_tween.set_loops()
	hero_tween.tween_property(hero_image, "position:y", base_position.y - 8.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	hero_tween.tween_property(hero_image, "position:y", base_position.y + 2.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _add_logo() -> void:
	var logo := TextureRect.new()
	logo.position = Vector2(28, 62)
	logo.size = Vector2(250, 160)
	logo.texture = _load_texture_region(LOGIN_ATLAS_PATH, LOGO_RECT, true)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)

func _add_player_panel() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(22, 236)
	panel.size = Vector2(330, 118)
	panel.modulate = Color(0.18, 0.13, 0.24, 0.78)
	add_child(panel)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 18
	box.offset_top = 12
	box.offset_right = -18
	box.offset_bottom = -12
	panel.add_child(box)

	var name_label := Label.new()
	name_label.text = "本地演示账号"
	name_label.add_theme_font_size_override("font_size", 24)
	box.add_child(name_label)

	var level_label := Label.new()
	level_label.text = "Lv. 120    战力 999999"
	level_label.add_theme_font_size_override("font_size", 18)
	box.add_child(level_label)

	var res_label := Label.new()
	res_label.text = "金币 888888    钻石 9999"
	res_label.add_theme_font_size_override("font_size", 16)
	box.add_child(res_label)

func _add_right_entries() -> void:
	var entries := [
		["竞技", RANK_RECT],
		["召唤", SUMMON_RECT],
		["礼包", GIFT_RECT],
		["日常", DAILY_RECT],
		["公告", NOTICE_RECT],
	]
	for i in entries.size():
		var y := 116 + i * 82
		_add_entry_button(Vector2(918, y), str(entries[i][0]), entries[i][1])

func _add_entry_button(pos: Vector2, text: String, icon_rect: Rect2i) -> void:
	var box := Control.new()
	box.position = pos
	box.size = Vector2(330, 64)
	add_child(box)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture_region(MAIN_ATLAS_PATH, ENTRY_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.modulate = Color(1, 1, 1, 0.84)
	box.add_child(bg)

	var icon := TextureRect.new()
	icon.position = Vector2(22, 15)
	icon.size = Vector2(34, 34)
	icon.texture = _load_texture_region(MAIN_ATLAS_PATH, icon_rect)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)

	var label := Label.new()
	label.position = Vector2(76, 12)
	label.size = Vector2(170, 38)
	label.text = text
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(label)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = text
	hit.pressed.connect(func(): _open_placeholder(text))
	box.add_child(hit)

func _add_bottom_nav() -> void:
	var nav := HBoxContainer.new()
	nav.anchor_left = 0.0
	nav.anchor_top = 1.0
	nav.anchor_right = 1.0
	nav.anchor_bottom = 1.0
	nav.offset_left = 260
	nav.offset_top = -86
	nav.offset_right = -260
	nav.offset_bottom = -24
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	nav.add_theme_constant_override("separation", 12)
	add_child(nav)

	for label in ["英雄", "背包", "抽卡", "活动", "公会", "冒险"]:
		var btn := Button.new()
		btn.text = label
		btn.custom_minimum_size = Vector2(88, 46)
		var module_name := str(label)
		btn.pressed.connect(func(): _open_placeholder(module_name))
		nav.add_child(btn)

func _add_activity_strip() -> void:
	var strip := PanelContainer.new()
	strip.position = Vector2(24, 586)
	strip.size = Vector2(360, 76)
	strip.modulate = Color(0.16, 0.12, 0.22, 0.72)
	add_child(strip)

	var label := Label.new()
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 18
	label.offset_top = 8
	label.offset_right = -18
	label.offset_bottom = -8
	label.text = "离线主城：功能入口进入本地预览，不连接服务器。"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	strip.add_child(label)

func _open_placeholder(name: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = name
	dialog.dialog_text = "%s 模块会继续接入对应原始 Prefab 和本地数据。" % name
	add_child(dialog)
	dialog.popup_centered()

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
	if not "--capture-main-city" in args:
		return
	for i in 12:
		await get_tree().process_frame
	var index := args.find("--capture-main-city")
	var output_path := "user://main_city.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
