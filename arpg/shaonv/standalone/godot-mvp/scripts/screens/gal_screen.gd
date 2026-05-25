# UTF-8 source. GalDormitoryView shell + restored Gal child views.
extends RefCounted

const VIEW_MAIN := "main"
const VIEW_DATE_SELECT := "date_select"
const VIEW_CHARACTER := "character"
const VIEW_DRESS_UP := "dress_up"
const VIEW_FILES := "files"
const VIEW_ALBUM := "album"
const VIEW_MEMORY := "memory"
const VIEW_SPECIAL_TOUCH := "special_touch"
const DEFAULT_GAL_HERO_ID := 240030

# Main panel resources
const GAL_BG := "res://assets/ui/gal/gal_img_122.png"
const GAL_ROOM_BG := "res://assets/ui/background/gal_bg_room_4.png"
const GAL_HERO_PANEL := "res://assets/ui/gal/gal_img_03.png"
const GAL_BTN_CLOSE := "res://assets/ui/gal/gal_btn_01.png"
const GAL_BTN_DETAIL := "res://assets/ui/gal/gal_btn_30.png"
const GAL_BTN_FAV := "res://assets/ui/gal/gal_btn_31.png"
const GAL_BTN_LV := "res://assets/ui/gal/gal_img_07.png"
const GAL_BTN_LV_BAR := "res://assets/ui/gal/gal_img_08.png"
const GAL_BTN_DATE := "res://assets/ui/gal/gal_btn_12.png"
const GAL_BTN_GOOUT := "res://assets/ui/gal/gal_btn_13.png"
const GAL_BTN_GIFT := "res://assets/ui/gal/gal_btn_14.png"
const GAL_BTN_FILE := "res://assets/ui/gal/gal_btn_45.png"
const GAL_BTN_MEM := "res://assets/ui/gal/gal_btn_06.png"
const GAL_BTN_ALBUM := "res://assets/ui/gal/gal_btn_05.png"
const GAL_BTN_DRESS := "res://assets/ui/gal/gal_btn_03.png"
const GAL_BTN_PRIV := "res://assets/ui/gal/gal_btn_04.png"
const GAL_IMG_LABEL_BG := "res://assets/ui/gal/gal_img_05.png"
const GAL_IMG_ROLE_BG := "res://assets/ui/gal/gal_img_06.png"
const GAL_IMG_ROLE_SELECT_BG := "res://assets/ui/gal/gal_img_09.png"
const GAL_IMG_ROLE_GRID_LEVEL := "res://assets/ui/gal/gal_img_10.png"
const GAL_BTN_ROLE_GRID_SELECT := "res://assets/ui/gal/gal_btn_17.png"
const GAL_BTN_ROLE_GRID_SELECT_MARK := "res://assets/ui/gal/gal_btn_18.png"
const GAL_IMG_ROLE_GRID_LOCK := "res://assets/ui/gal/gal_img_51.png"
const GAL_IMG_ROLE_GRID_FAVORITE := "res://assets/ui/gal/gal_img_52.png"
const GAL_BTN_CHANGE_ICON := "res://assets/ui/gal/gal_btn_11.png"

# Shared / child view resources
const GAL_BTN_CLOSE_SMALL := "res://assets/ui/gal/gal_btn_33.png"
const GAL_BTN_DRESS_ACTIVE := "res://assets/ui/gal/gal_btn_24.png"
const GAL_BTN_DRESS_GETWAY := "res://assets/ui/gal/gal_btn_25.png"
const GAL_BG_DATE_SELECT := "res://assets/ui/background/gal_bg_06.png"
const GAL_BTN_DATE_CONFIRM := "res://assets/ui/gal/gal_btn_25.png"
const GAL_BTN_DATE_RECORD := "res://assets/ui/gal/gal_btn_36.png"
const GAL_BG_CHARACTER := "res://assets/ui/background/gal_bg_11.png"
const GAL_IMG_CHAR_FRAME := "res://assets/ui/gal/gal_img_103.png"
const GAL_IMG_CHAR_HEADER := "res://assets/ui/gal/gal_img_105.png"
const GAL_IMG_CHAR_TAG := "res://assets/ui/gal/gal_img_106.png"
const GAL_IMG_AXIS := "res://assets/ui/gal/gal_img_119.png"
const GAL_IMG_BAR_1 := "res://assets/ui/gal/gal_img_111.png"
const GAL_IMG_BAR_2 := "res://assets/ui/gal/gal_img_112.png"
const GAL_IMG_BAR_3 := "res://assets/ui/gal/gal_img_113.png"
const GAL_IMG_BAR_4 := "res://assets/ui/gal/gal_img_114.png"
const GAL_IMG_TRAIT_1 := "res://assets/ui/gal/gal_img_115.png"
const GAL_IMG_TRAIT_2 := "res://assets/ui/gal/gal_img_116.png"
const GAL_IMG_TRAIT_3 := "res://assets/ui/gal/gal_img_117.png"
const GAL_IMG_TRAIT_4 := "res://assets/ui/gal/gal_img_118.png"
const GAL_DRESS_UNLOCK_BG := "res://assets/ui/gal/gal_img_28.png"
const GAL_DRESS_PANEL := "res://assets/ui/gal/gal_img_30.png"
const GAL_DRESS_DIVIDER := "res://assets/ui/gal/gal_img_31.png"
const GAL_DRESS_GRID_SELECT := "res://assets/ui/gal/gal_img_32.png"
const GAL_DRESS_GRID_NAME := "res://assets/ui/gal/gal_img_33.png"
const GAL_DRESS_GRID_BG := "res://assets/ui/gal/gal_img_34.png"
const GAL_DRESS_GRID_LOCK := "res://assets/ui/gal/gal_img_36.png"
const GAL_DRESS_ACTIVE_DECOR := "res://assets/ui/gal/gal_img_41.png"
const GAL_AUDIO_CLICK := "res://assets/audio/gal/hero_037_er.wav"
const GAL_AUDIO_GREET := "res://assets/audio/gal/hero_037_greet.wav"
const GAL_AUDIO_WAIT := [
	"res://assets/audio/gal/hero_037_wait1.wav",
	"res://assets/audio/gal/hero_037_wait2.wav",
	"res://assets/audio/gal/hero_037_wait3.wav",
]
const GAL_AUDIO_TOUCH := [
	"res://assets/audio/gal/hero_037_greet.wav",
	"res://assets/audio/gal/hero_037_arm1.wav",
	"res://assets/audio/gal/hero_037_wait2.wav",
]
const GAL_AUDIO_GIFT := [
	"res://assets/audio/gal/hero_037_gift.wav",
	"res://assets/audio/gal/hero_037_gift_fav.wav",
]

var app
var _current_view := VIEW_MAIN
var _audio_player: AudioStreamPlayer
var _voice_index := 0
var _gift_voice_index := 0
var _idle_voice_timer: Timer
var _audio_cache: Dictionary = {}
var _role_selector_expanded := false
var _ui_hidden := false
var _files_tab := "voice"
var _dress_tab := "skin"

const GAL_PREFAB_SCALE := Vector2(1280.0 / 1670.0, 720.0 / 750.0)
const GAL_INFO_PANEL_CENTER := Vector2(190, -46)
const GAL_INFO_PANEL_SIZE := Vector2(292, 610)

func _init(app_ref) -> void:
	app = app_ref


func show_gal() -> void:
	var gal_hero_id := OS.get_environment("SHAONV_MVP_GAL_HERO_ID")
	if not gal_hero_id.is_empty():
		app.save["selected_gal_hero_id"] = int(gal_hero_id)
	_role_selector_expanded = OS.get_environment("SHAONV_MVP_GAL_ROLE_LIST") == "1"
	show_view(VIEW_MAIN)


func show_view(view_name: String) -> void:
	_current_view = view_name
	app.current_view = "gal"
	app._clear("Gal")
	_ensure_audio_player()
	match view_name:
		VIEW_DATE_SELECT:
			_draw_date_select_view()
		VIEW_CHARACTER:
			_draw_character_view()
		VIEW_DRESS_UP:
			_draw_dress_up_view()
		VIEW_FILES:
			_draw_files_view()
		VIEW_ALBUM:
			_draw_album_view()
		VIEW_MEMORY:
			_draw_memory_view()
		VIEW_SPECIAL_TOUCH:
			_draw_special_touch_view()
		_:
			_draw_main_view()
	_restart_idle_voice_timer()


func _selected_hero() -> Dictionary:
	var hero: Dictionary = app._hero_by_id(int(app.save.get("selected_gal_hero_id", DEFAULT_GAL_HERO_ID)))
	if hero.is_empty():
		hero = app._hero_by_id(DEFAULT_GAL_HERO_ID)
	if not hero.is_empty():
		hero = hero.duplicate(true)
		var gal_entry := _gal_resource_entry(int(hero.get("id", 0)))
		if not gal_entry.is_empty():
			_apply_gal_entry(hero, gal_entry)
		elif int(hero.get("id", 0)) == DEFAULT_GAL_HERO_ID:
			var fallback_spines := "hero_037r_s01|hero_037r|hero_037"
			var fallback_spine := _selected_dress_spine(int(hero.get("id", 0)), fallback_spines)
			if fallback_spine.is_empty():
				fallback_spine = "hero_037r_s01"
			hero["name"] = "墨菏"
			hero["title"] = "玄武"
			hero["spine"] = fallback_spine
			hero["artResource"] = "Art/Spine/%s/%s" % [fallback_spine, fallback_spine]
			hero["galSpine"] = fallback_spines
			hero["roundHeadResource"] = "assets/ui/hero/round/yhero_037r_s01.png"
	return hero


func _gal_resource_entry(hero_id: int) -> Dictionary:
	for raw_entry in app.hero_resource_map:
		var entry: Dictionary = raw_entry
		if int(entry.get("heroId", 0)) == hero_id:
			return entry
	return {}


func _apply_gal_entry(hero: Dictionary, entry: Dictionary) -> void:
	var spine_list := str(entry.get("galSpine", ""))
	var gal_spine := _selected_dress_spine(int(entry.get("heroId", hero.get("id", 0))), spine_list)
	if gal_spine.is_empty():
		gal_spine = _first_existing_spine(spine_list)
	if gal_spine.is_empty():
		gal_spine = _first_spine_token(spine_list)
	if gal_spine.is_empty():
		return
	hero["name"] = str(entry.get("nameText", hero.get("name", "")))
	hero["spine"] = gal_spine
	hero["artResource"] = "Art/Spine/%s/%s" % [gal_spine, gal_spine]
	hero["galSpine"] = str(entry.get("galSpine", gal_spine))
	var round_head := _first_existing_round_head(gal_spine, str(entry.get("galSpine", "")))
	if not round_head.is_empty():
		hero["roundHeadResource"] = round_head


func _first_spine_token(spine_list: String) -> String:
	for raw_name in spine_list.split("|", false):
		var spine_name := raw_name.strip_edges()
		if not spine_name.is_empty():
			return spine_name
	return ""


func _first_existing_spine(spine_list: String) -> String:
	for raw_name in spine_list.split("|", false):
		var spine_name := raw_name.strip_edges()
		if spine_name.is_empty():
			continue
		if _spine_exists(spine_name):
			return spine_name
	return ""


func _spine_exists(spine_name: String) -> bool:
	var baked_path := "res://assets/spine/%s/%s.baked.json" % [spine_name, spine_name]
	var png_path := "res://assets/spine/%s/%s.png" % [spine_name, spine_name]
	return FileAccess.file_exists(baked_path) or FileAccess.file_exists(png_path)


func _selected_dress_spine(hero_id: int, spine_list: String) -> String:
	var saved_spine := str(app.save.get(_dress_skin_save_key(hero_id), ""))
	if saved_spine.is_empty() or not _spine_exists(saved_spine):
		return ""
	for raw_name in spine_list.split("|", false):
		if raw_name.strip_edges() == saved_spine:
			return saved_spine
	return ""


func _dress_skin_save_key(hero_id: int) -> String:
	return "gal_dress_spine_%d" % hero_id


func _first_existing_round_head(primary_spine: String, spine_list: String) -> String:
	var candidates: Array[String] = []
	if not primary_spine.is_empty():
		candidates.append(primary_spine)
	for raw_name in spine_list.split("|", false):
		var spine_name := raw_name.strip_edges()
		if not spine_name.is_empty() and not candidates.has(spine_name):
			candidates.append(spine_name)
	for spine_name in candidates:
		if not spine_name.begins_with("hero_"):
			continue
		var suffix := spine_name.trim_prefix("hero_")
		var path := "res://assets/ui/hero/round/yhero_%s.png" % suffix
		if FileAccess.file_exists(path):
			return path
	return ""


func _gal_roster() -> Array[Dictionary]:
	var roster: Array[Dictionary] = []
	for raw_entry in app.hero_resource_map:
		var entry: Dictionary = raw_entry
		if str(entry.get("galSpine", "")).is_empty():
			continue
		var hero: Dictionary = app._hero_by_id(int(entry.get("heroId", 0))).duplicate(true)
		if hero.is_empty():
			hero = {"id": int(entry.get("heroId", 0)), "rarity": int(entry.get("rare", 1))}
		_apply_gal_entry(hero, entry)
		roster.append(hero)
	return roster


func _gal_size(prefab_size: Vector2) -> Vector2:
	return Vector2(prefab_size.x * GAL_PREFAB_SCALE.x, prefab_size.y * GAL_PREFAB_SCALE.y)


func _gal_top_left_pos(pos: Vector2) -> Vector2:
	return Vector2(pos.x * GAL_PREFAB_SCALE.x, -pos.y * GAL_PREFAB_SCALE.y)


func _gal_left_middle_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((center.x - size.x * 0.5) * GAL_PREFAB_SCALE.x, (375.0 - center.y - size.y * 0.5) * GAL_PREFAB_SCALE.y)


func _gal_right_bottom_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((1670.0 + center.x - size.x) * GAL_PREFAB_SCALE.x, (750.0 - center.y - size.y) * GAL_PREFAB_SCALE.y)


func _gal_right_top_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((1670.0 + center.x - size.x) * GAL_PREFAB_SCALE.x, -center.y * GAL_PREFAB_SCALE.y)


func _gal_right_middle_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((1670.0 + center.x - size.x * 0.5) * GAL_PREFAB_SCALE.x, (375.0 - center.y - size.y * 0.5) * GAL_PREFAB_SCALE.y)


func _gal_center_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((835.0 + center.x - size.x * 0.5) * GAL_PREFAB_SCALE.x, (375.0 - center.y - size.y * 0.5) * GAL_PREFAB_SCALE.y)


func _gal_info_child_center(child_pos: Vector2, child_size := Vector2.ZERO, pivot_left := false) -> Vector2:
	var x := GAL_INFO_PANEL_CENTER.x - GAL_INFO_PANEL_SIZE.x * 0.5 + child_pos.x
	if pivot_left:
		x += child_size.x * 0.5
	return Vector2(x, GAL_INFO_PANEL_CENTER.y + child_pos.y)


func _gal_info_child_pos(child_pos: Vector2, child_size: Vector2, pivot_left := false) -> Vector2:
	return _gal_left_middle_pos(_gal_info_child_center(child_pos, child_size, pivot_left), child_size)


func _draw_main_view() -> void:
	var hero := _selected_hero()

	_draw_gal_background()
	app._view_container().add_child(app._panel(Vector2(0, 540), Vector2(1280, 180), Color(0.04, 0.025, 0.045, 0.10)))

	_draw_hero_stage(hero)
	if _ui_hidden:
		_draw_hidden_restore_button()
		return
	_draw_top_bar()
	_draw_hero_info_panel(hero)
	_draw_level_ring()
	_draw_action_buttons()
	_draw_side_buttons()
	_draw_hide_button()
	_draw_role_selector(hero)


func _draw_gal_background() -> void:
	var bg_key := str(app.save.get("gal_dress_background", "room"))
	if bg_key == "star":
		app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)
		app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.02, 0.03, 0.07, 0.12)))
		return
	app._draw_image(GAL_ROOM_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)


func _draw_hero_stage(hero: Dictionary) -> void:
	_draw_clipped_gal_stage(hero, Vector2(250, -32), Vector2(720, 910), Vector2(268, 0), Vector2(620, 570))
	_add_hit_button(Vector2(335, 36), Vector2(500, 620), func() -> void:
		_play_touch_voice("touch")
		_show_touch_hint("摸到了。%s 的心情似乎變好了。" % str(hero.get("name", "她")))
	)

	var line = app._label("今天也要全力發光!", 18, HORIZONTAL_ALIGNMENT_CENTER)
	line.position = Vector2(510, 458)
	line.size = Vector2(260, 30)
	line.modulate = Color(1, 1, 1, 0.96)
	app._view_container().add_child(line)


func _draw_clipped_gal_stage(hero: Dictionary, stage_pos: Vector2, stage_size: Vector2, clip_pos: Vector2, clip_size: Vector2) -> void:
	var clip := Control.new()
	clip.position = clip_pos
	clip.size = clip_size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app._view_container().add_child(clip)

	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		var spine_base_path := "res://%s" % resource_path.replace("Art/Spine", "assets/spine")
		var baked_path := "%s.baked.json" % spine_base_path
		if FileAccess.file_exists(baked_path):
			var canvas_script = load("res://scripts/spine_baked_preview_canvas.gd")
			var canvas: Control = canvas_script.new()
			canvas.position = stage_pos - clip_pos
			canvas.size = stage_size
			clip.add_child(canvas)
			canvas.set_baked_path(baked_path, "wait")
			return
		var png_path := "%s.png" % spine_base_path
		var source_texture: Texture2D = app._load_png_source_texture(png_path)
		if source_texture != null:
			var rect := TextureRect.new()
			rect.texture = source_texture
			rect.position = stage_pos - clip_pos
			rect.size = stage_size
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			clip.add_child(rect)
			return
	app._draw_hero_stage(hero, stage_pos, stage_size, false)


func _draw_top_bar() -> void:
	var close_pos := _gal_top_left_pos(Vector2(60, -18))
	var close_size := _gal_size(Vector2(120, 80))
	app._draw_image(GAL_BTN_CLOSE, close_pos, close_size, false, Color(1, 1, 1, 0.94))
	_add_hit_button(close_pos, close_size, func() -> void:
		_stop_idle_voice_timer()
		app._show_home()
	)

	var detail_pos := _gal_top_left_pos(Vector2(126, -18))
	var section_size := _gal_size(Vector2(60, 60))
	app._draw_image(GAL_BTN_DETAIL, detail_pos, section_size, false, Color(1, 1, 1, 0.92))
	_add_hit_button(detail_pos, section_size, func() -> void:
		show_view(VIEW_CHARACTER)
	)

	var fav_pos := _gal_top_left_pos(Vector2(186, -18))
	app._draw_image(GAL_BTN_FAV, fav_pos, section_size, false, Color(1, 1, 1, 0.92))
	_add_hit_button(fav_pos, section_size, func() -> void:
		_show_touch_hint("已設為最愛看板")
	)


func _draw_hero_info_panel(hero: Dictionary) -> void:
	var panel_pos := _gal_left_middle_pos(GAL_INFO_PANEL_CENTER, GAL_INFO_PANEL_SIZE)
	var panel_size := _gal_size(GAL_INFO_PANEL_SIZE)

	app._draw_image(GAL_HERO_PANEL, panel_pos, panel_size, false, Color(1, 1, 1, 1.0))
	app._draw_image(GAL_HERO_PANEL, _gal_left_middle_pos(GAL_INFO_PANEL_CENTER + Vector2(146, 0), GAL_INFO_PANEL_SIZE), panel_size, false, Color(1, 1, 1, 0.35))

	var title_text := str(hero.get("title", hero.get("name", "")))
	var name_text := str(hero.get("name", "角色"))
	var label_text := str(hero.get("personality", "天真天然邪"))

	var title_label = app._label(title_text, 18)
	title_label.position = Vector2(54, 92)
	title_label.size = Vector2(180, 30)
	title_label.modulate = Color(1.0, 0.92, 0.66)
	app._view_container().add_child(title_label)

	var name_label = app._label(name_text, 30)
	name_label.position = Vector2(54, 124)
	name_label.size = Vector2(210, 48)
	name_label.modulate = Color(1.0, 1.0, 1.0)
	app._view_container().add_child(name_label)

	var personality_pos := Vector2(54, 176)
	var personality_size := _gal_size(Vector2(168, 48))
	app._draw_image("res://assets/ui/gal/gal_img_04.png", personality_pos, personality_size, false, Color(1, 1, 1, 0.95))
	app._draw_image("res://assets/ui/gal/gal_btn_02.png", personality_pos + Vector2(104, -2), _gal_size(Vector2(50, 50)), false)
	var tag_label = app._label(label_text, 14)
	tag_label.position = personality_pos + Vector2(4, 9)
	tag_label.size = Vector2(112, 26)
	tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_label.modulate = Color(1.0, 0.92, 1.0)
	app._view_container().add_child(tag_label)
	_add_hit_button(personality_pos, personality_size, func() -> void:
		show_view(VIEW_CHARACTER)
	)

	var small_button_size := _gal_size(Vector2(98, 98))
	var small_label_size := _gal_size(Vector2(126, 36))
	var dress_pos := Vector2(48, 252)
	app._draw_image(GAL_BTN_DRESS, dress_pos, small_button_size, false)
	app._draw_image(GAL_IMG_LABEL_BG, dress_pos + Vector2(-11, 82), small_label_size, false, Color(1, 1, 1, 0.74))
	_add_gal_text("裝扮", dress_pos + Vector2(-11, 84), small_label_size, 14)
	_add_hit_button(dress_pos, small_button_size, func() -> void:
		show_view(VIEW_DRESS_UP)
	)
	app._draw_red_dot(dress_pos + Vector2(58, 8))

	var priv_pos := Vector2(48, 382)
	app._draw_image(GAL_BTN_PRIV, priv_pos, small_button_size, false)
	app._draw_image(GAL_IMG_LABEL_BG, priv_pos + Vector2(-11, 82), small_label_size, false, Color(1, 1, 1, 0.74))
	_add_gal_text("甜蜜互動", priv_pos + Vector2(-11, 84), small_label_size, 14)
	_add_hit_button(priv_pos, small_button_size, func() -> void:
		show_view(VIEW_SPECIAL_TOUCH)
	)


func _draw_level_ring() -> void:
	var lv_pos := _gal_right_top_pos(Vector2(-13, -15), Vector2(322, 322))
	var lv_size := _gal_size(Vector2(322, 322))
	app._draw_image(GAL_BTN_LV, lv_pos, lv_size, false, Color(1, 1, 1, 0.90))

	var level := int(app.save.get("gal_level", 2))
	var lv_num = app._label(str(level), 48)
	lv_num.position = lv_pos + _gal_size(Vector2(131, 92))
	lv_num.size = _gal_size(Vector2(60, 70))
	lv_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_num.modulate = Color(1.0, 0.94, 0.66)
	app._view_container().add_child(lv_num)

	var bar_pos := lv_pos + _gal_size(Vector2(50, 240))
	var bar_size := _gal_size(Vector2(222, 46))
	app._draw_image(GAL_BTN_LV_BAR, bar_pos, bar_size, false, Color(1, 1, 1, 0.82))

	var exp_val := int(app.save.get("gal_exp", 0))
	var exp_text = app._label("%d/250" % exp_val, 13)
	exp_text.position = bar_pos + _gal_size(Vector2(28, 12))
	exp_text.size = _gal_size(Vector2(166, 20))
	exp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_text.modulate = Color(1.0, 0.72, 0.72)
	app._view_container().add_child(exp_text)

	var lbl = app._label("親密等級", 13)
	lbl.position = lv_pos + _gal_size(Vector2(0, 38))
	lbl.size = _gal_size(Vector2(322, 30))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate = Color(1.0, 0.96, 0.98)
	app._view_container().add_child(lbl)


func _draw_action_buttons() -> void:
	var date_pos := _gal_right_bottom_pos(Vector2(-59, 19), Vector2(296, 116))
	var date_size := _gal_size(Vector2(296, 116))
	app._draw_image(GAL_BTN_DATE, date_pos, date_size, false, Color(1, 1, 1, 0.94))
	_add_gal_text("約會", date_pos + _gal_size(Vector2(88, 34)), _gal_size(Vector2(120, 46)), 24)
	_add_hit_button(date_pos, date_size, func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(_gal_right_bottom_pos(Vector2(49.1, 40.4), Vector2(0, 0)))

	var go_pos := _gal_right_bottom_pos(Vector2(-347, 19), Vector2(188, 88))
	var go_size := _gal_size(Vector2(188, 88))
	app._draw_image(GAL_BTN_GOOUT, go_pos, go_size, false, Color(1, 1, 1, 0.90))
	_add_gal_text("外出", go_pos + _gal_size(Vector2(42, 23)), _gal_size(Vector2(84, 40)), 22)
	_add_hit_button(go_pos, go_size, func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(_gal_right_bottom_pos(Vector2(-292.3, 53), Vector2(0, 0)))

	var gift_pos := _gal_right_bottom_pos(Vector2(-535, 19), Vector2(88, 88))
	var small_size := _gal_size(Vector2(88, 88))
	app._draw_image(GAL_BTN_GIFT, gift_pos, small_size, false, Color(1, 1, 1, 0.90))
	_add_gal_text("禮物", gift_pos + _gal_size(Vector2(0, 60)), _gal_size(Vector2(88, 22)), 14)
	_add_hit_button(gift_pos, small_size, func() -> void:
		_play_gift_voice()
		app.save["gal_exp"] = mini(int(app.save.get("gal_exp", 0)) + 5, 250)
		show_view(VIEW_MAIN)
		_show_touch_hint("禮物已送出，親密 +5")
	)

	var file_pos := _gal_right_bottom_pos(Vector2(-623, 19), Vector2(88, 88))
	app._draw_image(GAL_BTN_FILE, file_pos, small_size, false, Color(1, 1, 1, 0.90))
	_add_gal_text("檔案", file_pos + _gal_size(Vector2(0, 60)), _gal_size(Vector2(88, 22)), 14)
	_add_hit_button(file_pos, small_size, func() -> void:
		_files_tab = "profile"
		show_view(VIEW_FILES)
	)


func _draw_side_buttons() -> void:
	var button_size := _gal_size(Vector2(98, 98))
	var label_size := _gal_size(Vector2(126, 36))

	var album_pos := _gal_right_bottom_pos(Vector2(-79, 193), Vector2(98, 98))
	app._draw_image(GAL_BTN_ALBUM, album_pos, button_size, false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, album_pos + _gal_size(Vector2(-14, 89)), label_size, false, Color(1, 1, 1, 0.72))
	_add_gal_text("相冊", album_pos + _gal_size(Vector2(-14, 89)), label_size, 14)
	_add_hit_button(album_pos, button_size, func() -> void:
		show_view(VIEW_ALBUM)
	)
	app._draw_red_dot(_gal_right_bottom_pos(Vector2(-51.7, 221.5), Vector2(0, 0)))

	var mem_pos := _gal_right_bottom_pos(Vector2(-79, 323), Vector2(98, 98))
	app._draw_image(GAL_BTN_MEM, mem_pos, button_size, false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, mem_pos + _gal_size(Vector2(-14, 89)), label_size, false, Color(1, 1, 1, 0.72))
	_add_gal_text("心動回憶", mem_pos + _gal_size(Vector2(-14, 89)), label_size, 14)
	_add_hit_button(mem_pos, button_size, func() -> void:
		show_view(VIEW_MEMORY)
	)
	app._draw_red_dot(_gal_right_bottom_pos(Vector2(-51.7, 351.5), Vector2(0, 0)))


func _draw_hide_button() -> void:
	var hide_pos := _gal_center_pos(Vector2(-196, 129), Vector2(90, 90))
	var hide_size := _gal_size(Vector2(90, 90))
	app._draw_image("res://assets/ui/gal/gal_btn_46.png", hide_pos, hide_size, false, Color(1, 1, 1, 0.72))
	_add_hit_button(hide_pos, hide_size, func() -> void:
		_ui_hidden = true
		show_view(VIEW_MAIN)
	)


func _draw_role_selector(hero: Dictionary) -> void:
	var selector_pos := _gal_left_middle_pos(Vector2(181, -296), Vector2(110, 110))
	var selector_size := _gal_size(Vector2(110, 110))
	var head_pos := _gal_left_middle_pos(Vector2(181, -296), Vector2(100, 100))
	var head_size := _gal_size(Vector2(100, 100))

	app._draw_image(GAL_IMG_ROLE_BG, selector_pos, selector_size, false, Color(1, 1, 1, 0.88))
	var tex = app._hero_round_head_texture(hero)
	if tex != null:
		var rect := TextureRect.new()
		rect.texture = tex
		rect.position = head_pos
		rect.size = head_size
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_SCALE
		rect.modulate = Color(1, 1, 1, 0.96)
		app._view_container().add_child(rect)
	else:
		app._draw_hero_thumb(hero, head_pos + _gal_size(Vector2(10, 10)), head_size - _gal_size(Vector2(20, 20)), Color(1, 1, 1, 0.78))

	app._draw_image(GAL_BTN_CHANGE_ICON, _gal_left_middle_pos(Vector2(219, -279), Vector2(50, 50)), _gal_size(Vector2(50, 50)), false, Color(1, 1, 1, 0.90))
	_add_hit_button(selector_pos, selector_size, func() -> void:
		_role_selector_expanded = not _role_selector_expanded
		show_view(VIEW_MAIN)
	)
	if _role_selector_expanded:
		_draw_gal_role_list(hero)
	app._draw_red_dot(_gal_left_middle_pos(Vector2(230.9, -246.4), Vector2(0, 0)))


func _draw_gal_role_list(current_hero: Dictionary) -> void:
	var roster := _gal_roster()
	if roster.is_empty():
		return
	var selector_pos := _gal_left_middle_pos(Vector2(181, -296), Vector2(110, 110))
	var name_pos := selector_pos + _gal_size(Vector2(75, 84))
	var name_size := _gal_size(Vector2(200, 44))
	app._draw_image(GAL_IMG_ROLE_SELECT_BG, name_pos, name_size, false, Color(1, 1, 1, 0.92))
	var current_name = app._label(str(current_hero.get("name", "角色")), 15, HORIZONTAL_ALIGNMENT_CENTER)
	current_name.position = name_pos + Vector2(4, 3)
	current_name.size = name_size - Vector2(32, 8)
	current_name.modulate = Color(1.0, 0.92, 0.98)
	app._view_container().add_child(current_name)

	var list_pos := selector_pos + _gal_size(Vector2(314, 0)) - Vector2(0, 28)
	var list_size := _gal_size(Vector2(656, 128))
	app._view_container().add_child(app._panel(list_pos + Vector2(8, 8), list_size, Color(0, 0, 0, 0.20)))
	app._view_container().add_child(app._panel(list_pos, list_size, Color(0.03, 0.025, 0.055, 0.54)))
	for index in range(roster.size()):
		var item: Dictionary = roster[index]
		var item_size := _gal_size(Vector2(110, 110))
		var item_pos := list_pos + Vector2(index * 70, 10)
		if item_pos.x + item_size.x > list_pos.x + list_size.x:
			break
		var selected := int(item.get("id", 0)) == int(current_hero.get("id", 0))
		_draw_role_grid_item(item, item_pos, item_size, selected)
		var hero_id := int(item.get("id", 0))
		var hero_name := str(item.get("name", "角色"))
		_add_hit_button(item_pos, item_size, func() -> void:
			app.save["selected_gal_hero_id"] = hero_id
			_role_selector_expanded = false
			show_view(VIEW_MAIN)
			_show_touch_hint("已切換看板：%s" % hero_name)
		)


func _draw_role_grid_item(item: Dictionary, item_pos: Vector2, item_size: Vector2, selected: bool) -> void:
	app._draw_image(GAL_IMG_ROLE_BG, item_pos, item_size, false, Color(1, 1, 1, 0.88))
	if selected:
		if FileAccess.file_exists(GAL_BTN_ROLE_GRID_SELECT):
			app._draw_image(GAL_BTN_ROLE_GRID_SELECT, item_pos, item_size, false, Color(1, 1, 1, 0.95))
		else:
			app._view_container().add_child(app._panel(item_pos + Vector2(5, 5), item_size - Vector2(10, 10), Color(1.0, 0.72, 0.92, 0.20)))
	var tex = app._hero_round_head_texture(item)
	if tex != null:
		var head := TextureRect.new()
		head.texture = tex
		head.position = item_pos + _gal_size(Vector2(5, 5))
		head.size = _gal_size(Vector2(100, 100))
		head.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		head.stretch_mode = TextureRect.STRETCH_SCALE
		head.modulate = Color(1, 1, 1, 0.96)
		app._view_container().add_child(head)
	var level_pos := item_pos + _gal_size(Vector2(-36, -38)) + item_size * 0.5
	var level_size := _gal_size(Vector2(56, 56))
	if FileAccess.file_exists(GAL_IMG_ROLE_GRID_LEVEL):
		app._draw_image(GAL_IMG_ROLE_GRID_LEVEL, level_pos, level_size, false, Color(1, 1, 1, 0.92))
	else:
		app._view_container().add_child(app._panel(level_pos + Vector2(3, 3), Vector2(34, 22), Color(0.05, 0.04, 0.07, 0.64)))
	var lv = app._label(str(int(item.get("gal_level", app.save.get("gal_level", 2)))), 11, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = level_pos + Vector2(4, 4)
	lv.size = Vector2(30, 18)
	lv.modulate = Color(1, 0.95, 0.82)
	app._view_container().add_child(lv)
	if selected:
		var mark_pos := item_pos + item_size - _gal_size(Vector2(50, 50)) - Vector2(5, 5)
		if FileAccess.file_exists(GAL_BTN_ROLE_GRID_SELECT_MARK):
			app._draw_image(GAL_BTN_ROLE_GRID_SELECT_MARK, mark_pos, _gal_size(Vector2(50, 50)), false, Color(1, 1, 1, 0.95))
		else:
			app._draw_image(GAL_BTN_CHANGE_ICON, mark_pos, _gal_size(Vector2(42, 42)), false, Color(1, 1, 1, 0.88))
	var favorite_pos := item_pos + Vector2(9, item_size.y - 28)
	if FileAccess.file_exists(GAL_IMG_ROLE_GRID_FAVORITE) and int(item.get("id", 0)) == int(app.save.get("selected_gal_hero_id", DEFAULT_GAL_HERO_ID)):
		app._draw_image(GAL_IMG_ROLE_GRID_FAVORITE, favorite_pos, _gal_size(Vector2(34, 34)), false, Color(1, 1, 1, 0.90))
	var name_label = app._label(str(item.get("name", "角色")), 11, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.position = item_pos + Vector2(1, item_size.y - 23)
	name_label.size = Vector2(item_size.x - 2, 20)
	name_label.modulate = Color(1.0, 0.92, 0.98)
	app._view_container().add_child(name_label)


func _draw_hidden_restore_button() -> void:
	var restore_pos := Vector2(20, 318)
	var restore_size := Vector2(74, 86)
	app._draw_image("res://assets/ui/gal/gal_btn_46.png", restore_pos, restore_size, false, Color(1, 1, 1, 0.78))
	_add_gal_text("顯示", restore_pos + Vector2(0, 54), Vector2(74, 24), 14)
	_add_hit_button(restore_pos, restore_size, func() -> void:
		_ui_hidden = false
		show_view(VIEW_MAIN)
	)


func _draw_child_panel_shell(title_text: String, subtitle_text: String) -> Dictionary:
	var hero := _selected_hero()
	app._draw_image(GAL_ROOM_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.02, 0.015, 0.035, 0.42)))

	var close_pos := _gal_top_left_pos(Vector2(60, -18))
	var close_size := _gal_size(Vector2(120, 80))
	app._draw_image(GAL_BTN_CLOSE, close_pos, close_size, false, Color(1, 1, 1, 0.94))
	_add_hit_button(close_pos, close_size, func() -> void:
		show_view(VIEW_MAIN)
	)

	var card_pos := Vector2(250, 58)
	var card_size := Vector2(900, 604)
	app._view_container().add_child(app._panel(card_pos + Vector2(12, 12), card_size, Color(0.0, 0.0, 0.0, 0.20)))
	app._view_container().add_child(app._panel(card_pos, card_size, Color(0.08, 0.06, 0.12, 0.82)))

	var title = app._label(title_text, 30)
	title.position = card_pos + Vector2(36, 28)
	title.size = Vector2(260, 42)
	title.modulate = Color(1.0, 0.80, 0.96)
	app._view_container().add_child(title)

	var subtitle = app._label(subtitle_text, 16)
	subtitle.position = card_pos + Vector2(38, 70)
	subtitle.size = Vector2(card_size.x - 76, 28)
	subtitle.modulate = Color(0.95, 0.88, 0.94, 0.78)
	app._view_container().add_child(subtitle)

	return {"hero": hero, "card_pos": card_pos, "card_size": card_size}


func _draw_dress_up_view() -> void:
	var hero := _selected_hero()
	_draw_gal_background()
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.02, 0.02, 0.05, 0.12)))

	_draw_gal_child_close_button()
	_draw_clipped_gal_stage(hero, Vector2(186, -38), Vector2(760, 930), Vector2(108, 0), Vector2(720, 720))

	var panel_size := _gal_size(Vector2(564, 750))
	var panel_pos := _gal_right_middle_pos(Vector2(-282, 0), Vector2(564, 750))
	if app._draw_image(GAL_DRESS_PANEL, panel_pos, panel_size, false, Color(1, 1, 1, 0.96)) == null:
		app._view_container().add_child(app._panel(panel_pos, panel_size, Color(0.04, 0.045, 0.09, 0.82)))
		app._view_container().add_child(app._panel(panel_pos + Vector2(10, 10), panel_size - Vector2(20, 20), Color(0.06, 0.065, 0.12, 0.74)))

	_draw_dress_tab_button(panel_pos + Vector2(-54, 152), "服裝", "skin")
	_draw_dress_tab_button(panel_pos + Vector2(-54, 232), "背景", "bg")

	var title := "服裝更換" if _dress_tab == "skin" else "背景更換"
	var title_label = app._label(title, 24)
	title_label.position = panel_pos + Vector2(42, 58)
	title_label.size = Vector2(280, 36)
	title_label.modulate = Color(1.0, 0.96, 0.82)
	app._view_container().add_child(title_label)
	_draw_dress_divider(panel_pos + Vector2(62, 104), Vector2(318, 2))
	_draw_dress_divider(panel_pos + Vector2(62, 514), Vector2(318, 2))

	if _dress_tab == "bg":
		_draw_dress_background_grid(panel_pos)
	else:
		_draw_dress_skin_grid(hero, panel_pos)


func _draw_gal_child_close_button() -> void:
	var close_pos := _gal_top_left_pos(Vector2(60, -18))
	var close_size := _gal_size(Vector2(120, 80))
	app._draw_image(GAL_BTN_CLOSE, close_pos, close_size, false, Color(1, 1, 1, 0.94))
	_add_hit_button(close_pos, close_size, func() -> void:
		show_view(VIEW_MAIN)
	)


func _draw_dress_tab_button(pos: Vector2, label_text: String, tab_key: String) -> void:
	var active := _dress_tab == tab_key
	app._view_container().add_child(app._panel(pos, Vector2(78, 52), Color(0.78, 1.0, 0.22, 0.20 if active else 0.07)))
	app._draw_image(GAL_IMG_CHAR_TAG, pos + Vector2(4, 7), Vector2(70, 38), false, Color(1, 1, 1, 0.9 if active else 0.56))
	_add_gal_text(label_text, pos + Vector2(4, 6), Vector2(70, 38), 17)
	_add_hit_button(pos, Vector2(78, 52), func() -> void:
		_dress_tab = tab_key
		show_view(VIEW_DRESS_UP)
	)


func _draw_dress_divider(pos: Vector2, size: Vector2) -> void:
	if app._draw_image(GAL_DRESS_DIVIDER, pos, size, false, Color(1, 1, 1, 0.82)) == null:
		app._view_container().add_child(app._panel(pos, size, Color(1.0, 1.0, 1.0, 0.18)))


func _draw_dress_skin_grid(hero: Dictionary, panel_pos: Vector2) -> void:
	var options := _dress_skin_options(hero)
	var selected_spine := str(hero.get("spine", ""))
	for index in range(options.size()):
		var item: Dictionary = options[index]
		var col := index % 2
		var row := index / 2
		var card_pos := panel_pos + Vector2(36 + col * 184, 124 + row * 236)
		_draw_dress_skin_card(hero, item, card_pos, str(item.get("spine", "")) == selected_spine)

	_draw_skin_effect_panel(panel_pos)
	_draw_dress_action_area(hero, panel_pos)


func _dress_skin_options(hero: Dictionary) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var spine_list := str(hero.get("galSpine", hero.get("spine", "")))
	var names := ["默認看板", "日常裝扮", "原始立繪", "備用看板"]
	for raw_name in spine_list.split("|", false):
		var spine_name := raw_name.strip_edges()
		if spine_name.is_empty():
			continue
		var label: String = names[min(options.size(), names.size() - 1)]
		options.append({
			"name": label,
			"spine": spine_name,
			"unlocked": _spine_exists(spine_name)
		})
	if options.is_empty():
		options.append({"name": "默認看板", "spine": str(hero.get("spine", "")), "unlocked": true})
	return options


func _draw_dress_skin_card(hero: Dictionary, item: Dictionary, pos: Vector2, selected: bool) -> void:
	var card_size := Vector2(152, 220)
	if app._draw_image(GAL_DRESS_GRID_BG, pos, card_size, false, Color(1, 1, 1, 0.96)) == null:
		app._view_container().add_child(app._panel(pos, card_size, Color(0.09, 0.10, 0.16, 0.86)))
		app._view_container().add_child(app._panel(pos + Vector2(5, 5), card_size - Vector2(10, 10), Color(0.16, 0.18, 0.25, 0.48)))

	var spine_name := str(item.get("spine", ""))
	var preview_hero := hero.duplicate(true)
	preview_hero["spine"] = spine_name
	preview_hero["artResource"] = "Art/Spine/%s/%s" % [spine_name, spine_name]
	_draw_clipped_dress_preview(preview_hero, pos + Vector2(7, 10), Vector2(138, 150))

	if app._draw_image(GAL_DRESS_GRID_NAME, pos + Vector2(11, 166), Vector2(130, 28), false, Color(1, 1, 1, 0.9)) == null:
		app._view_container().add_child(app._panel(pos + Vector2(11, 166), Vector2(130, 28), Color(0.02, 0.02, 0.04, 0.72)))
	_add_gal_text(str(item.get("name", "")), pos + Vector2(12, 165), Vector2(128, 30), 15)

	if selected:
		if app._draw_image(GAL_DRESS_GRID_SELECT, pos - Vector2(6, 8), card_size + Vector2(12, 16), false, Color(1, 1, 1, 0.96)) == null:
			app._view_container().add_child(app._panel(pos - Vector2(4, 6), card_size + Vector2(8, 12), Color(0.72, 1.0, 0.24, 0.24)))
		_add_gal_text("使用中", pos + Vector2(38, 194), Vector2(76, 22), 13)

	if not bool(item.get("unlocked", true)):
		if app._draw_image(GAL_DRESS_GRID_LOCK, pos + Vector2(7, 8), Vector2(138, 204), false, Color(1, 1, 1, 0.86)) == null:
			app._view_container().add_child(app._panel(pos + Vector2(7, 8), Vector2(138, 204), Color(0, 0, 0, 0.55)))
		_add_gal_text("未解鎖", pos + Vector2(38, 88), Vector2(76, 30), 16)

	var hero_id := int(hero.get("id", 0))
	var target_spine := spine_name
	var target_name := str(item.get("name", "裝扮"))
	_add_hit_button(pos, card_size, func() -> void:
		if not bool(item.get("unlocked", true)):
			_show_touch_hint("尚未解鎖：%s" % target_name)
			return
		app.save[_dress_skin_save_key(hero_id)] = target_spine
		show_view(VIEW_DRESS_UP)
		_show_touch_hint("已切換裝扮：%s" % target_name)
	)


func _dress_half_icon_path(spine_name: String) -> String:
	if not spine_name.begins_with("hero_"):
		return ""
	var suffix := spine_name.trim_prefix("hero_")
	var candidates: Array[String] = [suffix]
	var parts := suffix.split("_")
	if parts.size() > 0 and not candidates.has(parts[0]):
		candidates.append(parts[0])
	for candidate in candidates:
		var half_path := "res://assets/ui/hero/half/phero_%s.png" % candidate
		if FileAccess.file_exists(half_path):
			return half_path
		var round_path := "res://assets/ui/hero/round/yhero_%s.png" % candidate
		if FileAccess.file_exists(round_path):
			return round_path
	return ""


func _draw_clipped_dress_preview(hero: Dictionary, pos: Vector2, preview_size: Vector2) -> void:
	var clip := Control.new()
	clip.position = pos
	clip.size = preview_size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app._view_container().add_child(clip)

	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		var spine_base_path := "res://%s" % resource_path.replace("Art/Spine", "assets/spine")
		var baked_path := "%s.baked.json" % spine_base_path
		if FileAccess.file_exists(baked_path):
			var canvas_script = load("res://scripts/spine_baked_preview_canvas.gd")
			var canvas: Control = canvas_script.new()
			canvas.position = Vector2(-42, -52)
			canvas.size = Vector2(226, 252)
			clip.add_child(canvas)
			canvas.set_baked_path(baked_path, "wait")
			return

	var half_path := _dress_half_icon_path(str(hero.get("spine", "")))
	if half_path.is_empty():
		half_path = str(hero.get("roundHeadResource", ""))
	if not half_path.is_empty():
		var tex: Texture2D = app._load_png_source_texture(half_path)
		if tex != null:
			var rect := TextureRect.new()
			rect.texture = tex
			rect.position = Vector2.ZERO
			rect.size = preview_size
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			clip.add_child(rect)


func _draw_skin_effect_panel(panel_pos: Vector2) -> void:
	var effect_pos := panel_pos + Vector2(44, 532)
	app._view_container().add_child(app._panel(effect_pos, Vector2(338, 74), Color(0.02, 0.025, 0.055, 0.58)))
	var effects := ["看板互動", "甜蜜觸摸", "專屬語音"]
	for index in range(effects.size()):
		var chip_pos := effect_pos + Vector2(14 + index * 104, 18)
		app._draw_image(GAL_IMG_CHAR_TAG, chip_pos, Vector2(92, 34), false, Color(1, 1, 1, 0.66))
		_add_gal_text(effects[index], chip_pos, Vector2(92, 32), 13)


func _draw_dress_action_area(hero: Dictionary, panel_pos: Vector2) -> void:
	var selected_spine := str(hero.get("spine", ""))
	var cost_pos := panel_pos + Vector2(168, 624)
	_add_gal_text("0/1", cost_pos, Vector2(72, 28), 18)
	app._view_container().add_child(app._panel(cost_pos - Vector2(48, 5), Vector2(36, 36), Color(0.86, 0.74, 0.38, 0.84)))

	var button_pos := panel_pos + Vector2(86, 666)
	var button_size := Vector2(260, 46)
	var button_path := GAL_BTN_DRESS_ACTIVE if FileAccess.file_exists(GAL_BTN_DRESS_ACTIVE) else GAL_BTN_DRESS_GETWAY
	if app._draw_image(button_path, button_pos, button_size, false, Color(1, 1, 1, 0.96)) == null:
		app._view_container().add_child(app._panel(button_pos, button_size, Color(0.72, 0.82, 0.28, 0.72)))
	_add_gal_text("已啟用：%s" % selected_spine, button_pos, button_size, 16)
	_add_hit_button(button_pos, button_size, func() -> void:
		_show_touch_hint("當前裝扮已設為 Gal 看板")
	)


func _draw_dress_background_grid(panel_pos: Vector2) -> void:
	var backgrounds := [
		{"name": "現世界房間", "path": GAL_ROOM_BG, "key": "room"},
		{"name": "星屑夜空", "path": GAL_BG, "key": "star"},
	]
	var current := str(app.save.get("gal_dress_background", "room"))
	for index in range(backgrounds.size()):
		var item: Dictionary = backgrounds[index]
		var pos := panel_pos + Vector2(44, 130 + index * 154)
		app._view_container().add_child(app._panel(pos, Vector2(338, 124), Color(0.02, 0.025, 0.055, 0.62)))
		app._draw_image(str(item.get("path", "")), pos + Vector2(10, 10), Vector2(150, 104), true)
		_add_gal_text(str(item.get("name", "")), pos + Vector2(176, 18), Vector2(130, 30), 17)
		if current == str(item.get("key", "")):
			_add_gal_text("使用中", pos + Vector2(176, 66), Vector2(86, 28), 14)
		var bg_key := str(item.get("key", ""))
		var bg_name := str(item.get("name", "背景"))
		_add_hit_button(pos, Vector2(338, 124), func() -> void:
			app.save["gal_dress_background"] = bg_key
			show_view(VIEW_DRESS_UP)
			_show_touch_hint("已切換背景：%s" % bg_name)
		)

	var unlock_pos := panel_pos + Vector2(44, 492)
	if app._draw_image(GAL_DRESS_UNLOCK_BG, unlock_pos, Vector2(338, 106), false, Color(1, 1, 1, 0.82)) == null:
		app._view_container().add_child(app._panel(unlock_pos, Vector2(338, 106), Color(0.04, 0.05, 0.10, 0.66)))
	_add_gal_text("更多背景可通過親密任務與活動解鎖", unlock_pos + Vector2(18, 16), Vector2(302, 66), 16)


func _draw_files_view() -> void:
	var ctx := _draw_child_panel_shell("檔案", "角色語音、資料與親密記錄入口。")
	var card_pos: Vector2 = ctx["card_pos"]
	var hero: Dictionary = ctx["hero"]
	var tabs := [{"key": "voice", "text": "語音"}, {"key": "profile", "text": "檔案"}]
	for index in range(tabs.size()):
		var tab: Dictionary = tabs[index]
		var tab_pos := card_pos + Vector2(42, 126 + index * 82)
		var active := _files_tab == str(tab.get("key", ""))
		app._draw_image(GAL_IMG_CHAR_TAG, tab_pos, Vector2(168, 46), false, Color(1, 1, 1, 0.95 if active else 0.55))
		_add_gal_text(str(tab.get("text", "")), tab_pos, Vector2(168, 42), 18)
		var tab_key := str(tab.get("key", ""))
		_add_hit_button(tab_pos, Vector2(168, 46), func() -> void:
			_files_tab = tab_key
			show_view(VIEW_FILES)
		)

	var content_pos := card_pos + Vector2(250, 126)
	app._view_container().add_child(app._panel(content_pos, Vector2(560, 408), Color(0.03, 0.025, 0.055, 0.62)))
	if _files_tab == "profile":
		_draw_profile_content(hero, content_pos)
	else:
		_draw_voice_content(content_pos)


func _draw_voice_content(content_pos: Vector2) -> void:
	var voices := [
		{"name": "問候", "path": GAL_AUDIO_GREET},
		{"name": "待機 1", "path": GAL_AUDIO_WAIT[0]},
		{"name": "待機 2", "path": GAL_AUDIO_WAIT[1]},
		{"name": "待機 3", "path": GAL_AUDIO_WAIT[2]},
		{"name": "觸摸", "path": GAL_AUDIO_TOUCH[1]},
		{"name": "禮物", "path": GAL_AUDIO_GIFT[0]}
	]
	for index in range(voices.size()):
		var item: Dictionary = voices[index]
		var row := index / 2
		var col := index % 2
		var pos := content_pos + Vector2(28 + col * 258, 28 + row * 82)
		app._view_container().add_child(app._panel(pos, Vector2(226, 58), Color(1.0, 0.68, 0.90, 0.12)))
		_add_gal_text(str(item.get("name", "")), pos + Vector2(12, 6), Vector2(116, 30), 16)
		_add_gal_text("播放", pos + Vector2(132, 8), Vector2(70, 28), 14)
		var voice_path := str(item.get("path", ""))
		var voice_name := str(item.get("name", ""))
		_add_hit_button(pos, Vector2(226, 58), func() -> void:
			_play_gal_sound(voice_path, 0.92)
			_show_touch_hint("播放語音：%s" % voice_name)
		)


func _draw_profile_content(hero: Dictionary, content_pos: Vector2) -> void:
	var portrait = app._hero_portrait_texture(hero)
	if portrait != null:
		var head := TextureRect.new()
		head.texture = portrait
		head.position = content_pos + Vector2(34, 34)
		head.size = Vector2(132, 132)
		head.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		head.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		app._view_container().add_child(head)
	var profile := [
		["稱號", str(hero.get("title", "玄武"))],
		["姓名", str(hero.get("name", "角色"))],
		["性格", str(hero.get("personality", "天真天然邪"))],
		["親密", "%d / 250" % int(app.save.get("gal_exp", 0))],
		["狀態", "看板互動已開啟"]
	]
	for index in range(profile.size()):
		var row: Array = profile[index]
		var pos := content_pos + Vector2(196, 34 + index * 58)
		app._draw_image(GAL_IMG_TRAIT_1, pos, Vector2(310, 34), false, Color(1, 1, 1, 0.72))
		var label = app._label("%s   %s" % [str(row[0]), str(row[1])], 17)
		label.position = pos + Vector2(18, 2)
		label.size = Vector2(276, 30)
		label.modulate = Color(1, 0.92, 0.96)
		app._view_container().add_child(label)


func _draw_album_view() -> void:
	var ctx := _draw_child_panel_shell("相冊", "展示已解鎖的 Gal 圖像回憶。")
	var card_pos: Vector2 = ctx["card_pos"]
	for index in range(6):
		var col := index % 3
		var row := index / 3
		var pos := card_pos + Vector2(70 + col * 250, 132 + row * 190)
		app._view_container().add_child(app._panel(pos, Vector2(208, 132), Color(1.0, 0.82, 0.94, 0.10)))
		app._view_container().add_child(app._panel(pos + Vector2(8, 8), Vector2(192, 88), Color(0.02, 0.018, 0.04, 0.56)))
		app._draw_image(GAL_IMG_CHAR_TAG, pos + Vector2(36, 36), Vector2(136, 30), false, Color(1, 1, 1, 0.44))
		_add_gal_text("未解鎖", pos + Vector2(44, 34), Vector2(120, 28), 14)
		_add_gal_text("回憶相片 %02d" % (index + 1), pos + Vector2(8, 100), Vector2(192, 26), 14)
		var album_index := index + 1
		_add_hit_button(pos, Vector2(208, 132), func() -> void:
			_show_touch_hint("查看相片 %02d" % album_index)
		)


func _draw_memory_view() -> void:
	var ctx := _draw_child_panel_shell("心動回憶", "回看親密事件與約會記錄。")
	var card_pos: Vector2 = ctx["card_pos"]
	var memories := [
		{"title": "初次問候", "desc": "她在房間裡向你打招呼。", "unlocked": true},
		{"title": "送禮反應", "desc": "收到禮物時的特別語音。", "unlocked": true},
		{"title": "外出邀約", "desc": "約會功能接通後可繼續補全。", "unlocked": false},
		{"title": "甜蜜互動", "desc": "特殊觸摸事件入口。", "unlocked": true}
	]
	for index in range(memories.size()):
		var item: Dictionary = memories[index]
		var pos := card_pos + Vector2(74, 124 + index * 106)
		var unlocked := bool(item.get("unlocked", false))
		app._view_container().add_child(app._panel(pos, Vector2(740, 78), Color(1.0, 0.72, 0.92, 0.14 if unlocked else 0.06)))
		var title = app._label(str(item.get("title", "")), 20)
		title.position = pos + Vector2(28, 10)
		title.size = Vector2(220, 30)
		title.modulate = Color(1, 0.92, 0.98) if unlocked else Color(0.72, 0.68, 0.72)
		app._view_container().add_child(title)
		var desc = app._label(str(item.get("desc", "")), 15)
		desc.position = pos + Vector2(28, 42)
		desc.size = Vector2(560, 24)
		desc.modulate = Color(0.94, 0.86, 0.92, 0.82)
		app._view_container().add_child(desc)
		if unlocked:
			var memory_title := str(item.get("title", ""))
			_add_hit_button(pos, Vector2(740, 78), func() -> void:
				_show_touch_hint("回看：%s" % memory_title)
			)


func _draw_special_touch_view() -> void:
	var hero := _selected_hero()
	_draw_gal_background()
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.02, 0.02, 0.05, 0.08)))
	_draw_gal_child_close_button()

	_draw_clipped_gal_stage(hero, Vector2(272, -74), Vector2(790, 990), Vector2(184, 0), Vector2(760, 720))
	_draw_special_touch_front_layer(hero)


func _draw_special_touch_front_layer(hero: Dictionary) -> void:
	var count := int(app.save.get("gal_touch_count", 0))
	var level := int(app.save.get("gal_level", 2))
	app._view_container().add_child(app._panel(Vector2(982, 96), Vector2(224, 188), Color(0.02, 0.025, 0.055, 0.48)))
	_add_gal_text("甜蜜互動", Vector2(1002, 112), Vector2(184, 34), 22)
	_add_gal_text("今日觸摸 %d 次" % count, Vector2(1010, 154), Vector2(168, 26), 15)
	_add_gal_text("親密等級 Lv.%d" % level, Vector2(1010, 184), Vector2(168, 26), 15)
	_add_gal_text("點擊角色不同區域，觸發語音和好感反饋。", Vector2(1004, 218), Vector2(180, 48), 13)

	var zones := [
		{"name": "問候", "rect": Rect2(500, 72, 180, 130), "kind": "greet", "gain": 1},
		{"name": "輕觸", "rect": Rect2(490, 204, 220, 166), "kind": "touch", "gain": 2},
		{"name": "牽手", "rect": Rect2(362, 288, 154, 174), "kind": "touch", "gain": 2},
		{"name": "靠近", "rect": Rect2(522, 382, 190, 160), "kind": "wait", "gain": 1},
	]
	for zone in zones:
		var item: Dictionary = zone
		_draw_touch_zone(item)

	_draw_gift_button(hero)


func _draw_touch_zone(item: Dictionary) -> void:
	var rect: Rect2 = item.get("rect", Rect2())
	var label := str(item.get("name", "互動"))
	var kind := str(item.get("kind", "touch"))
	var gain := int(item.get("gain", 1))
	_add_hit_button(rect.position, rect.size, func() -> void:
		_register_touch_action(kind, label, gain)
	)


func _draw_gift_button(hero: Dictionary) -> void:
	var gift_pos := Vector2(986, 588)
	var gift_size := Vector2(210, 58)
	app._view_container().add_child(app._panel(gift_pos, gift_size, Color(0.95, 0.78, 0.35, 0.18)))
	app._draw_image(GAL_IMG_CHAR_TAG, gift_pos + Vector2(14, 11), Vector2(104, 36), false, Color(1, 1, 1, 0.78))
	_add_gal_text("送禮", gift_pos + Vector2(18, 11), Vector2(96, 34), 17)
	_add_gal_text("好感 +4", gift_pos + Vector2(120, 15), Vector2(76, 28), 14)
	_add_hit_button(gift_pos, gift_size, func() -> void:
		_register_touch_action("gift", "送禮", 4)
		_show_touch_hint("%s 收下了禮物" % str(hero.get("name", "她")))
	)


func _register_touch_action(kind: String, label_text: String, gain: int) -> void:
	if kind == "gift":
		_play_gift_voice()
	else:
		_play_touch_voice(kind)
	app.save["gal_touch_count"] = int(app.save.get("gal_touch_count", 0)) + 1
	app.save["gal_exp"] = int(app.save.get("gal_exp", 0)) + gain
	_show_touch_hint("%s成功，好感 +%d" % [label_text, gain])


func _draw_date_select_view() -> void:
	var hero := _selected_hero()
	app._draw_image(GAL_BG_DATE_SELECT, Vector2(0, 0), Vector2(1280, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.03, 0.02, 0.04, 0.18)))

	var card_pos := Vector2(105, 34)
	var card_size := Vector2(1070, 622)
	app._view_container().add_child(app._panel(card_pos + Vector2(12, 12), card_size, Color(0.18, 0.08, 0.11, 0.18)))
	app._view_container().add_child(app._panel(card_pos, card_size, Color(0.11, 0.05, 0.07, 0.72)))

	var title = app._label("約會安排", 30)
	title.position = Vector2(card_pos.x + 48, card_pos.y + 28)
	title.size = Vector2(280, 42)
	app._view_container().add_child(title)

	var dates_left := 2 + int(app.save.get("gal_level", 2))
	var remain = app._label("今日可安排 %d 次" % dates_left, 18)
	remain.position = Vector2(card_pos.x + 50, card_pos.y + 74)
	remain.size = Vector2(240, 28)
	remain.modulate = Color(1.0, 0.84, 0.86)
	app._view_container().add_child(remain)

	app._draw_image(GAL_BTN_CLOSE_SMALL, Vector2(card_pos.x + card_size.x - 72, card_pos.y + 24), Vector2(42, 42), false)
	_add_hit_button(Vector2(card_pos.x + card_size.x - 72, card_pos.y + 24), Vector2(42, 42), func() -> void:
		show_view(VIEW_MAIN)
	)

	app._draw_image(GAL_BTN_DATE_RECORD, Vector2(card_pos.x + 34, card_pos.y + 120), Vector2(78, 78), false)
	var record = app._label("回憶", 15, HORIZONTAL_ALIGNMENT_CENTER)
	record.position = Vector2(card_pos.x + 26, card_pos.y + 194)
	record.size = Vector2(92, 26)
	app._view_container().add_child(record)
	_add_hit_button(Vector2(card_pos.x + 34, card_pos.y + 120), Vector2(78, 78), func() -> void:
		show_view(VIEW_CHARACTER)
	)

	var info_panel = app._panel(Vector2(card_pos.x + 150, card_pos.y + 112), Vector2(850, 176), Color(0.16, 0.08, 0.11, 0.74))
	app._view_container().add_child(info_panel)
	var info_title = app._label("今日行程", 22)
	info_title.position = Vector2(card_pos.x + 182, card_pos.y + 132)
	info_title.size = Vector2(180, 32)
	app._view_container().add_child(info_title)
	var info_body = app._label("和 %s 一起出門。可選的活動會隨好感與角色狀態變化。" % str(hero.get("name", "角色")), 18)
	info_body.position = Vector2(card_pos.x + 182, card_pos.y + 172)
	info_body.size = Vector2(760, 72)
	info_body.modulate = Color(0.96, 0.88, 0.84)
	app._view_container().add_child(info_body)

	var sections := [
		{"title": "甜點店", "desc": "增加親密感，觸發輕鬆對話", "tag": "推薦"},
		{"title": "商業街", "desc": "送禮與外出事件更容易銜接", "tag": "普通"},
		{"title": "河岸夜景", "desc": "回憶值成長較高，節奏偏慢", "tag": "夜間"}
	]

	var x := card_pos.x + 64
	for index in range(sections.size()):
		var item: Dictionary = sections[index]
		var px := x + index * 318.0
		var py := card_pos.y + 320
		app._view_container().add_child(app._panel(Vector2(px, py), Vector2(262, 182), Color(0.24, 0.12, 0.16, 0.78)))
		app._view_container().add_child(app._panel(Vector2(px + 12, py + 12), Vector2(238, 72), Color(0.37, 0.17, 0.22, 0.82)))

		var item_title = app._label(str(item.get("title", "")), 24, HORIZONTAL_ALIGNMENT_CENTER)
		item_title.position = Vector2(px + 24, py + 28)
		item_title.size = Vector2(214, 34)
		app._view_container().add_child(item_title)

		var item_desc = app._label(str(item.get("desc", "")), 16)
		item_desc.position = Vector2(px + 22, py + 100)
		item_desc.size = Vector2(220, 48)
		item_desc.modulate = Color(0.98, 0.90, 0.88)
		app._view_container().add_child(item_desc)

		var item_tag = app._label("[%s]" % str(item.get("tag", "")), 14, HORIZONTAL_ALIGNMENT_RIGHT)
		item_tag.position = Vector2(px + 138, py + 148)
		item_tag.size = Vector2(96, 22)
		item_tag.modulate = Color(1.0, 0.76, 0.82)
		app._view_container().add_child(item_tag)

		var selected_index := index
		_add_hit_button(Vector2(px, py), Vector2(262, 182), func() -> void:
			app.save["gal_selected_date_option"] = selected_index
			_show_touch_hint("已選擇：%s" % str(item.get("title", "")))
		)

	app._draw_image(GAL_BTN_DATE_CONFIRM, Vector2(card_pos.x + 366, card_pos.y + 528), Vector2(270, 58), false)
	_add_gal_text("確認出行", Vector2(card_pos.x + 424, card_pos.y + 541), Vector2(160, 28), 20)
	_add_hit_button(Vector2(card_pos.x + 366, card_pos.y + 528), Vector2(270, 58), func() -> void:
		_play_touch_voice("greet")
		show_view(VIEW_MAIN)
	)


func _draw_character_view() -> void:
	var hero := _selected_hero()
	app._draw_image(GAL_BG_CHARACTER, Vector2(0, 0), Vector2(1280, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.02, 0.02, 0.03, 0.32)))

	var card_pos := Vector2(95, 20)
	var card_size := Vector2(1090, 680)
	app._view_container().add_child(app._panel(card_pos, card_size, Color(0.09, 0.06, 0.10, 0.70)))

	var title = app._label("性格分析", 28)
	title.position = Vector2(card_pos.x + 34, card_pos.y + 26)
	title.size = Vector2(180, 40)
	title.modulate = Color(1.0, 0.72, 0.88)
	app._view_container().add_child(title)

	app._draw_image(GAL_BTN_CLOSE_SMALL, Vector2(card_pos.x + card_size.x - 74, card_pos.y + 24), Vector2(42, 42), false)
	_add_hit_button(Vector2(card_pos.x + card_size.x - 74, card_pos.y + 24), Vector2(42, 42), func() -> void:
		show_view(VIEW_MAIN)
	)

	app._draw_image(GAL_IMG_CHAR_FRAME, Vector2(card_pos.x + 86, card_pos.y + 112), Vector2(128, 128), false)
	var portrait = app._hero_portrait_texture(hero)
	if portrait != null:
		var head := TextureRect.new()
		head.texture = portrait
		head.position = Vector2(card_pos.x + 100, card_pos.y + 126)
		head.size = Vector2(100, 100)
		head.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		head.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		app._view_container().add_child(head)

	var hero_name = app._label(str(hero.get("name", "角色")), 24, HORIZONTAL_ALIGNMENT_CENTER)
	hero_name.position = Vector2(card_pos.x + 70, card_pos.y + 244)
	hero_name.size = Vector2(160, 28)
	app._view_container().add_child(hero_name)

	app._draw_image(GAL_IMG_CHAR_HEADER, Vector2(card_pos.x + 54, card_pos.y + 300), Vector2(190, 24), false)
	var header_text = app._label("性格標籤", 18, HORIZONTAL_ALIGNMENT_CENTER)
	header_text.position = Vector2(card_pos.x + 86, card_pos.y + 296)
	header_text.size = Vector2(120, 30)
	app._view_container().add_child(header_text)

	var tags := ["傲嬌", "執著", "戰意", "率真", "護短", "直覺"]
	var start_x := card_pos.x + 56
	var start_y := card_pos.y + 356
	for index in range(tags.size()):
		var col := index % 3
		var row := index / 3
		var tx := start_x + col * 118.0
		var ty := start_y + row * 42.0
		app._draw_image(GAL_IMG_CHAR_TAG, Vector2(tx, ty), Vector2(110, 30), false)
		var tag = app._label(tags[index], 15, HORIZONTAL_ALIGNMENT_CENTER)
		tag.position = Vector2(tx, ty + 1)
		tag.size = Vector2(110, 28)
		tag.modulate = Color(1.0, 0.92, 0.98)
		app._view_container().add_child(tag)

	app._draw_image(GAL_IMG_AXIS, Vector2(card_pos.x + 430, card_pos.y + 128), Vector2(500, 340), false)
	_draw_character_bars(card_pos + Vector2(448, 138))

	var metrics := [
		{"name": "熱情", "value": "82", "bg": GAL_IMG_TRAIT_1},
		{"name": "克制", "value": "41", "bg": GAL_IMG_TRAIT_2},
		{"name": "信任", "value": "77", "bg": GAL_IMG_TRAIT_3},
		{"name": "支配", "value": "35", "bg": GAL_IMG_TRAIT_4},
	]
	for i in range(metrics.size()):
		var metric: Dictionary = metrics[i]
		var col := i % 2
		var row := i / 2
		var bx := card_pos.x + 454 + col * 260.0
		var by := card_pos.y + 500 + row * 40.0
		app._draw_image(str(metric.get("bg", "")), Vector2(bx, by), Vector2(240, 30), false)
		var name_label = app._label(str(metric.get("name", "")), 16)
		name_label.position = Vector2(bx + 26, by)
		name_label.size = Vector2(90, 30)
		app._view_container().add_child(name_label)
		var value_label = app._label(str(metric.get("value", "")), 16, HORIZONTAL_ALIGNMENT_CENTER)
		value_label.position = Vector2(bx + 150, by)
		value_label.size = Vector2(54, 30)
		app._view_container().add_child(value_label)


func _draw_character_bars(origin: Vector2) -> void:
	var up_bars := [
		{"name": "熱情", "height": 118.0, "sprite": GAL_IMG_BAR_1, "x": 0.0},
		{"name": "感性", "height": 86.0, "sprite": GAL_IMG_BAR_2, "x": 118.0},
		{"name": "依賴", "height": 102.0, "sprite": GAL_IMG_BAR_3, "x": 236.0},
		{"name": "勇氣", "height": 72.0, "sprite": GAL_IMG_BAR_4, "x": 354.0},
	]
	var down_bars := [
		{"name": "戒心", "height": 54.0, "sprite": GAL_IMG_BAR_1, "x": 0.0},
		{"name": "冷靜", "height": 92.0, "sprite": GAL_IMG_BAR_2, "x": 118.0},
		{"name": "壓抑", "height": 40.0, "sprite": GAL_IMG_BAR_3, "x": 236.0},
		{"name": "孤獨", "height": 80.0, "sprite": GAL_IMG_BAR_4, "x": 354.0},
	]

	for i in range(11):
		var axis = app._label(str(100 - i * 20), 13, HORIZONTAL_ALIGNMENT_RIGHT)
		axis.position = Vector2(origin.x - 42, origin.y + i * 27)
		axis.size = Vector2(32, 18)
		axis.modulate = Color(0.92, 0.86, 0.90, 0.78)
		app._view_container().add_child(axis)
	for i in range(5):
		var neg = app._label(str(-20 * (i + 1)), 13, HORIZONTAL_ALIGNMENT_RIGHT)
		neg.position = Vector2(origin.x - 42, origin.y + 302 + i * 14)
		neg.size = Vector2(32, 18)
		neg.modulate = Color(0.92, 0.86, 0.90, 0.78)
		app._view_container().add_child(neg)

	for item in up_bars:
		var x := origin.x + float(item.get("x", 0.0))
		var h := float(item.get("height", 0.0))
		app._draw_image(str(item.get("sprite", "")), Vector2(x, origin.y + 120 - h), Vector2(70, h), false)
		var lbl = app._label(str(item.get("name", "")), 14, HORIZONTAL_ALIGNMENT_CENTER)
		lbl.position = Vector2(x - 2, origin.y + 132)
		lbl.size = Vector2(74, 20)
		app._view_container().add_child(lbl)

	for item in down_bars:
		var x := origin.x + float(item.get("x", 0.0))
		var h := float(item.get("height", 0.0))
		app._draw_image(str(item.get("sprite", "")), Vector2(x, origin.y + 180), Vector2(70, h), false)
		var lbl = app._label(str(item.get("name", "")), 14, HORIZONTAL_ALIGNMENT_CENTER)
		lbl.position = Vector2(x - 2, origin.y + 266)
		lbl.size = Vector2(74, 20)
		app._view_container().add_child(lbl)


func _add_gal_text(text: String, pos: Vector2, text_size: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = text_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = Color(1, 1, 1, 0.94)
	app._view_container().add_child(label)
	return label


func _add_hit_button(pos: Vector2, hit_size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.position = pos
	button.size = hit_size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.button_down.connect(_on_gal_button_down.bind(button))
	button.button_up.connect(_on_gal_button_up.bind(button))
	button.mouse_entered.connect(_on_gal_button_hover.bind(button, true))
	button.mouse_exited.connect(_on_gal_button_hover.bind(button, false))
	button.pressed.connect(func() -> void:
		_play_gal_sound(GAL_AUDIO_CLICK, 0.45)
		_spawn_press_pulse(button)
		callback.call()
	)
	app._view_container().add_child(button)
	return button


func _ensure_audio_player() -> void:
	if _audio_player != null and is_instance_valid(_audio_player):
		return
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "GalAudioPlayer"
	app.add_child(_audio_player)


func _play_gal_sound(path: String, volume := 1.0) -> void:
	if not bool(app.save.get("settings", {}).get("effects", true)):
		return
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	_ensure_audio_player()
	var stream := _load_wav_stream(path)
	if stream == null:
		return
	_audio_player.stream = stream
	_audio_player.volume_db = linear_to_db(clampf(volume, 0.01, 1.0))
	_audio_player.play()


func _load_wav_stream(path: String) -> AudioStreamWAV:
	if _audio_cache.has(path):
		return _audio_cache[path]
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 44 or _ascii4(bytes, 0) != "RIFF" or _ascii4(bytes, 8) != "WAVE":
		return null
	var offset := 12
	var channels := 1
	var sample_rate := 22050
	var bits_per_sample := 16
	var data_start := -1
	var data_size := 0
	while offset + 8 <= bytes.size():
		var chunk := _ascii4(bytes, offset)
		var chunk_size := _u32le(bytes, offset + 4)
		var chunk_data := offset + 8
		if chunk == "fmt " and chunk_data + 16 <= bytes.size():
			var audio_format := _u16le(bytes, chunk_data)
			channels = _u16le(bytes, chunk_data + 2)
			sample_rate = _u32le(bytes, chunk_data + 4)
			bits_per_sample = _u16le(bytes, chunk_data + 14)
			if audio_format != 1:
				return null
		elif chunk == "data":
			data_start = chunk_data
			data_size = mini(chunk_size, bytes.size() - data_start)
			break
		offset = chunk_data + chunk_size + (chunk_size % 2)
	if data_start < 0 or data_size <= 0:
		return null
	var stream := AudioStreamWAV.new()
	if bits_per_sample == 8:
		stream.format = AudioStreamWAV.FORMAT_8_BITS
	elif bits_per_sample == 16:
		stream.format = AudioStreamWAV.FORMAT_16_BITS
	else:
		return null
	stream.mix_rate = sample_rate
	stream.stereo = channels == 2
	stream.data = bytes.slice(data_start, data_start + data_size)
	_audio_cache[path] = stream
	return stream


func _u16le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8)


func _u32le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8) | (int(bytes[offset + 2]) << 16) | (int(bytes[offset + 3]) << 24)


func _ascii4(bytes: PackedByteArray, offset: int) -> String:
	if offset + 4 > bytes.size():
		return ""
	var out := ""
	for index in range(4):
		out += char(bytes[offset + index])
	return out


func _play_touch_voice(kind := "touch") -> void:
	var pool: Array = GAL_AUDIO_TOUCH
	if kind == "greet":
		_play_gal_sound(GAL_AUDIO_GREET, 0.9)
		return
	if pool.is_empty():
		return
	var path := str(pool[_voice_index % pool.size()])
	_voice_index += 1
	_play_gal_sound(path, 0.9)


func _play_gift_voice() -> void:
	if GAL_AUDIO_GIFT.is_empty():
		return
	var path := str(GAL_AUDIO_GIFT[_gift_voice_index % GAL_AUDIO_GIFT.size()])
	_gift_voice_index += 1
	_play_gal_sound(path, 0.92)


func _restart_idle_voice_timer() -> void:
	_stop_idle_voice_timer()
	if _current_view != VIEW_MAIN or GAL_AUDIO_WAIT.is_empty():
		return
	_idle_voice_timer = Timer.new()
	_idle_voice_timer.one_shot = false
	_idle_voice_timer.wait_time = 12.0
	_idle_voice_timer.timeout.connect(_play_idle_voice)
	app._view_container().add_child(_idle_voice_timer)
	_idle_voice_timer.start()
	_play_gal_sound(GAL_AUDIO_GREET, 0.85)


func _stop_idle_voice_timer() -> void:
	if _idle_voice_timer != null and is_instance_valid(_idle_voice_timer):
		_idle_voice_timer.stop()
		_idle_voice_timer.queue_free()
	_idle_voice_timer = null


func _play_idle_voice() -> void:
	if _current_view != VIEW_MAIN or GAL_AUDIO_WAIT.is_empty():
		return
	var path := str(GAL_AUDIO_WAIT[randi() % GAL_AUDIO_WAIT.size()])
	_play_gal_sound(path, 0.72)


func _show_touch_hint(text: String) -> void:
	var bubble: Label = app._label(text, 17, HORIZONTAL_ALIGNMENT_CENTER)
	bubble.position = Vector2(446, 472)
	bubble.size = Vector2(390, 38)
	bubble.modulate = Color(1.0, 0.92, 0.98, 0.0)
	app._view_container().add_child(bubble)
	var tween: Tween = bubble.create_tween()
	tween.tween_property(bubble, "modulate:a", 0.96, 0.12)
	tween.tween_property(bubble, "position:y", bubble.position.y - 18.0, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(bubble, "modulate:a", 0.0, 0.45).set_delay(0.35)
	tween.tween_callback(bubble.queue_free)


func _spawn_press_pulse(button: Button) -> void:
	var pulse := ColorRect.new()
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pulse.color = Color(1.0, 0.72, 0.92, 0.28)
	var pulse_size := Vector2(minf(button.size.x, 96.0), minf(button.size.y, 96.0))
	pulse.position = button.position + button.size * 0.5 - pulse_size * 0.5
	pulse.size = pulse_size
	pulse.scale = Vector2(0.82, 0.82)
	pulse.pivot_offset = pulse_size * 0.5
	app._view_container().add_child(pulse)
	var tween := pulse.create_tween()
	tween.tween_property(pulse, "scale", Vector2(1.25, 1.25), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(pulse, "color:a", 0.0, 0.22)
	tween.tween_callback(pulse.queue_free)


func _on_gal_button_down(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.96, 0.96), 0.06)


func _on_gal_button_up(button: Button) -> void:
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_gal_button_hover(button: Button, hovering: bool) -> void:
	button.modulate = Color(1.0, 1.0, 1.0, 0.36) if hovering else Color(1, 1, 1, 1)
