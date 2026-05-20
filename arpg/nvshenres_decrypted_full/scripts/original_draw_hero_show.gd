extends Control

const DRAW_SCENE := "res://scenes/original_draw_card_panel.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const HERO_CATALOG_PATH := "res://data/hero_catalog.json"
const HERO_SPINE_INDEX_PATH := "res://data/hero_spine_runtime_index.json"
const HERO_VOICE_INDEX_PATH := "res://data/hero_voice_index.json"
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")
const AudioUtils := preload("res://scripts/audio_utils.gd")

var design_root: Control
var named_resources: Dictionary = {}
var hero_catalog: Array = []
var hero_spine_index: Dictionary = {}
var voice_index: Dictionary = {}
var hero_spine: Node2D
var hero_image: TextureRect
var voice_player: AudioStreamPlayer
var share_box: Control
var speak_box: Control
var hero_id := "105004"
var skin_body := ""
var hero_index := 0
var hero_data: Dictionary = {}

func _ready() -> void:
	_load_named_resources()
	_load_hero_catalog()
	_load_hero_spine_index()
	_load_voice_index()
	_apply_args()
	_build_ui()
	_capture_if_requested()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.015, 0.018, 0.03, 1.0)
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.055, 0.09, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var glow := ColorRect.new()
	glow.position = Vector2(0, 0)
	glow.size = Vector2(1280, 720)
	glow.color = Color(0.22, 0.17, 0.08, 0.18)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(glow)

	voice_player = AudioStreamPlayer.new()
	add_child(voice_player)

	_build_top_bar()
	_build_hero_stage()
	_build_info_panel()
	_build_skill_strip()
	_build_action_buttons()
	_build_share_box()
	_build_speak_box()
	_layout_design_root()
	_play_hero_voice("5")

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 1.0
	top.anchor_right = 1.0
	top.offset_left = -700
	top.offset_top = 10
	top.offset_right = -12
	top.offset_bottom = 44
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	add_child(top)

	var title := Label.new()
	title.text = "HeroShowPre | 衣装展示" if skin_body != "" else "HeroShowPre | 抽卡英雄展示"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	Navigation.add_buttons(top)
	_add_top_button(top, "召唤", func(): Navigation.go(DRAW_SCENE))
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "抽卡英雄展示"}))

	var close := Button.new()
	close.text = "<"
	close.position = Vector2(12, 11)
	close.size = Vector2(65, 48)
	close.pressed.connect(func(): Navigation.go(DRAW_SCENE))
	design_root.add_child(close)

func _build_hero_stage() -> void:
	var stage := Control.new()
	stage.position = Vector2(210, 16)
	stage.size = Vector2(760, 680)
	design_root.add_child(stage)

	hero_spine = SimpleSpinePlayerScript.new()
	stage.add_child(hero_spine)
	var runtime := _hero_runtime_path(hero_id)
	if skin_body == "" and runtime != "" and FileAccess.file_exists(runtime) and hero_spine.load_spine(runtime, "show"):
		_fit_spine_to_rect(hero_spine, Rect2(Vector2(52, 0), Vector2(640, 660)), 0.92)
	else:
		hero_spine.queue_free()
		hero_spine = null
		var body_id := skin_body if skin_body != "" else hero_id
		hero_image = _add_named_image(stage, "image/skin/showImg/%s" % body_id, Vector2(106, 24), Vector2(560, 628))
		if hero_image.texture == null:
			hero_image = _add_named_image(stage, "image/heroBook/%s" % body_id, Vector2(154, 30), Vector2(450, 600))
		if hero_image.texture == null:
			_add_named_image(stage, "image/head/%s" % hero_id, Vector2(300, 214), Vector2(160, 160))

func _build_info_panel() -> void:
	var panel := Control.new()
	panel.position = Vector2(69, 438)
	panel.size = Vector2(449, 190)
	design_root.add_child(panel)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.06, 0.08, 0.68)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(bg)

	_add_label(panel, str(hero_data.get("quality", "SSR")), Vector2(28, 10), Vector2(130, 54), 44, Color(1.0, 0.68, 0.18))
	_add_label(panel, str(hero_data.get("name", hero_id)), Vector2(160, 92), Vector2(110, 36), 24, Color(1.0, 0.92, 0.78), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(panel, str(hero_data.get("nick", hero_data.get("job", "英雄标签"))), Vector2(156, 58), Vector2(160, 28), 18, Color(0.88, 0.78, 0.62), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(panel, _stars(int(hero_data.get("stars", hero_data.get("grade", 5)))), Vector2(136, 130), Vector2(230, 42), 28, Color(1.0, 0.45, 0.78))

func _build_action_buttons() -> void:
	_add_screen_button("分享", Rect2(Vector2(1202, 118), Vector2(49, 49)), func(): _toggle_share_box())
	_add_screen_button("评论", Rect2(Vector2(1202, 192), Vector2(49, 49)), func(): _show_speak("世界频道评论预览"))
	_add_screen_button("再召1次", Rect2(Vector2(525, 597), Vector2(300, 66)), func(): Navigation.go_with_args(DRAW_SCENE, {"draw_count": 1}))
	_add_screen_button("再召10次", Rect2(Vector2(904, 597), Vector2(300, 66)), func(): Navigation.go_with_args(DRAW_SCENE, {"draw_count": 10}))

func _build_skill_strip() -> void:
	var positions := [Vector2(68, 650), Vector2(160, 650), Vector2(251, 650), Vector2(344, 650)]
	for i in positions.size():
		var slot := Control.new()
		slot.position = positions[i]
		slot.size = Vector2(64, 64)
		design_root.add_child(slot)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0.05, 0.07, 0.12, 0.78)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(bg)
		_add_label(slot, str(i + 1), Vector2(46, 36), Vector2(18, 24), 17, Color(0.95, 0.9, 0.7), HORIZONTAL_ALIGNMENT_CENTER)

func _build_share_box() -> void:
	share_box = Control.new()
	share_box.visible = false
	share_box.position = Vector2(1002, 114)
	share_box.size = Vector2(180, 146)
	design_root.add_child(share_box)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.07, 0.13, 0.88)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	share_box.add_child(bg)
	_add_screen_button("世界频道", Rect2(Vector2(12, 34), Vector2(154, 42)), func(): _show_speak("已模拟分享到世界频道"), share_box)
	_add_screen_button("公会频道", Rect2(Vector2(12, 92), Vector2(154, 42)), func(): _show_speak("已模拟分享到公会频道"), share_box)

func _build_speak_box() -> void:
	speak_box = Control.new()
	speak_box.visible = false
	speak_box.position = Vector2(525, 417)
	speak_box.size = Vector2(264, 121)
	design_root.add_child(speak_box)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.06, 0.78)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speak_box.add_child(bg)
	_add_label(speak_box, "", Vector2(18, 38), Vector2(230, 42), 19, Color(0.95, 0.92, 0.82), HORIZONTAL_ALIGNMENT_CENTER).name = "lblSpeak"

func _toggle_share_box() -> void:
	share_box.visible = not share_box.visible
	_play_hero_voice("2")

func _show_speak(text: String) -> void:
	share_box.visible = false
	speak_box.visible = true
	var label := speak_box.get_node_or_null("lblSpeak") as Label
	if label:
		label.text = text
	_play_hero_voice("3")

func _add_screen_button(text: String, rect: Rect2, callback: Callable, parent: Control = null) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.pressed.connect(callback)
	if parent:
		parent.add_child(button)
	else:
		design_root.add_child(button)
	return button

func _add_top_button(parent: Container, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _fit_spine_to_rect(player: Node2D, target: Rect2, max_scale: float) -> void:
	if not player.has_method("update_preview_pose") or not player.has_method("get_draw_bounds"):
		return
	player.update_preview_pose(0.4)
	var bounds: Rect2 = player.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var scale_value := minf(minf(target.size.x / bounds.size.x, target.size.y / bounds.size.y), max_scale)
	player.scale = Vector2(scale_value, scale_value)
	var bounds_center := bounds.position + bounds.size * 0.5
	player.position = target.position + target.size * 0.5 - bounds_center * scale_value

func _hero_runtime_path(id: String) -> String:
	var entry: Dictionary = hero_spine_index.get(id, {})
	return str(entry.get("runtime", ""))

func _play_hero_voice(sound_id: String) -> void:
	var hero_voice: Dictionary = voice_index.get(hero_id, {})
	var entry: Dictionary = hero_voice.get(sound_id, {})
	var path := str(entry.get("path", ""))
	AudioUtils.play_mp3(voice_player, path)

func _stars(count: int) -> String:
	var result := ""
	for i in maxi(count, 1):
		result += "★"
	return result

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
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label

func _load_named_resources() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/named_resource_index.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		named_resources = parsed

func _load_hero_catalog() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_CATALOG_PATH))
	if typeof(parsed) == TYPE_ARRAY:
		hero_catalog = parsed

func _load_hero_spine_index() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_SPINE_INDEX_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		hero_spine_index = parsed.get("heroes", {})

func _load_voice_index() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(HERO_VOICE_INDEX_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		voice_index = parsed

func _apply_args() -> void:
	var args := Navigation.consume_scene_args()
	hero_id = str(args.get("hero_id", hero_id))
	skin_body = str(args.get("skin_body", skin_body))
	hero_index = int(args.get("hero_show_index", 0))
	var cmd_args := OS.get_cmdline_args()
	cmd_args.append_array(OS.get_cmdline_user_args())
	var cmd_hero := _cmd_arg_value(cmd_args, "--hero-id")
	if cmd_hero != "":
		hero_id = cmd_hero
	var cmd_skin := _cmd_arg_value(cmd_args, "--skin-body")
	if cmd_skin != "":
		skin_body = cmd_skin
	var cmd_index := _cmd_arg_value(cmd_args, "--hero-show-index")
	if cmd_index.is_valid_int():
		hero_index = int(cmd_index)
	if hero_id == "":
		hero_id = _hero_id_for_index(hero_index)
	hero_data = _find_hero(hero_id)

func _hero_id_for_index(index: int) -> String:
	if hero_catalog.is_empty():
		return hero_id
	return str(hero_catalog[index % hero_catalog.size()].get("id", hero_id))

func _find_hero(id: String) -> Dictionary:
	for hero in hero_catalog:
		if str(hero.get("id", "")) == id:
			return hero
	return {"id": id, "name": "英雄%s" % id, "quality": "SSR", "grade": 5, "stars": 5, "power": "3000000", "level": "120"}

func _cmd_arg_value(args: Array, key: String) -> String:
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

func _layout_design_root() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
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
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, image.get_size()).encloses(crop):
		return ImageTexture.create_from_image(image)
	var frame := image.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x > 0 and original_size.y > 0 and original_size != frame.get_size():
		frame.convert(Image.FORMAT_RGBA8)
		var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
		canvas.fill(Color(0, 0, 0, 0))
		var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
		var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
		canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
		frame = canvas
	return ImageTexture.create_from_image(frame)

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
	if not "--capture-draw-hero-show" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-draw-hero-show")
	var output_path := "user://draw_hero_show.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
