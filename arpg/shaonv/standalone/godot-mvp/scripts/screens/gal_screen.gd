# UTF-8 source. GalDormitoryView shell + restored Gal child views.
extends RefCounted

const VIEW_MAIN := "main"
const VIEW_DATE_SELECT := "date_select"
const VIEW_CHARACTER := "character"
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
const GAL_BTN_CHANGE_ICON := "res://assets/ui/gal/gal_btn_11.png"

# Shared / child view resources
const GAL_BTN_CLOSE_SMALL := "res://assets/ui/gal/gal_btn_33.png"
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

const GAL_PREFAB_SCALE := Vector2(1280.0 / 1670.0, 720.0 / 750.0)
const GAL_INFO_PANEL_CENTER := Vector2(190, -46)
const GAL_INFO_PANEL_SIZE := Vector2(292, 610)

func _init(app_ref) -> void:
	app = app_ref


func show_gal() -> void:
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
		_:
			_draw_main_view()
	_restart_idle_voice_timer()


func _selected_hero() -> Dictionary:
	var hero: Dictionary = app._hero_by_id(int(app.save.get("selected_gal_hero_id", DEFAULT_GAL_HERO_ID)))
	if hero.is_empty():
		hero = app._hero_by_id(DEFAULT_GAL_HERO_ID)
	if not hero.is_empty():
		hero = hero.duplicate(true)
		var spine := str(hero.get("spine", ""))
		if spine == "hero_037":
			hero["name"] = "墨菏"
			hero["title"] = "玄武"
			hero["spine"] = "hero_037r_s01"
			hero["artResource"] = "Art/Spine/hero_037r_s01/hero_037r_s01"
			hero["galSpine"] = "hero_037r_s01|hero_037r"
			hero["portraitResource"] = "assets/ui/hero/recruit/zhero_037.png"
	return hero


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

	app._draw_image(GAL_ROOM_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 540), Vector2(1280, 180), Color(0.04, 0.025, 0.045, 0.22)))

	_draw_hero_stage(hero)
	_draw_top_bar()
	_draw_hero_info_panel(hero)
	_draw_level_ring()
	_draw_action_buttons()
	_draw_side_buttons()
	_draw_hide_button()
	_draw_role_selector(hero)


func _draw_hero_stage(hero: Dictionary) -> void:
	app._draw_hero_stage(hero, Vector2(330, 28), Vector2(540, 662), false)
	_add_hit_button(Vector2(360, 40), Vector2(470, 610), func() -> void:
		_play_touch_voice("touch")
		_show_touch_hint("摸到了。%s 的心情似乎變好了。" % str(hero.get("name", "她")))
	)

	var line = app._label("今天也要全力發光!", 18, HORIZONTAL_ALIGNMENT_CENTER)
	line.position = Vector2(500, 430)
	line.size = Vector2(260, 30)
	line.modulate = Color(1, 1, 1, 0.96)
	app._view_container().add_child(line)


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
		app._show_gallery()
	)


func _draw_hero_info_panel(hero: Dictionary) -> void:
	var panel_pos := _gal_left_middle_pos(GAL_INFO_PANEL_CENTER, GAL_INFO_PANEL_SIZE)
	var panel_size := _gal_size(GAL_INFO_PANEL_SIZE)
	var px := panel_pos.x
	var py := panel_pos.y
	var pw := panel_size.x
	var ph := panel_size.y

	app._draw_image(GAL_HERO_PANEL, panel_pos, panel_size, false, Color(1, 1, 1, 1.0))
	app._draw_image(GAL_HERO_PANEL, _gal_left_middle_pos(GAL_INFO_PANEL_CENTER + Vector2(146, 0), GAL_INFO_PANEL_SIZE), panel_size, false, Color(1, 1, 1, 0.35))

	var title_text := str(hero.get("title", hero.get("name", "")))
	var name_text := str(hero.get("name", "角色"))
	var label_text := str(hero.get("personality", "天真天然邪"))

	var title_label = app._label(title_text, 18)
	title_label.position = _gal_info_child_pos(Vector2(298.3, 275.0), Vector2(180, 30), true)
	title_label.size = _gal_size(Vector2(180, 30))
	title_label.modulate = Color(1.0, 0.92, 0.66)
	app._view_container().add_child(title_label)

	var name_label = app._label(name_text, 30)
	name_label.position = _gal_info_child_pos(Vector2(298.3, 231.5), Vector2(210, 57), true)
	name_label.size = _gal_size(Vector2(210, 57))
	name_label.modulate = Color(1.0, 1.0, 1.0)
	app._view_container().add_child(name_label)

	app._draw_image(GAL_IMG_LABEL_BG, _gal_info_child_pos(Vector2(66, 157), Vector2(126, 36), true), _gal_size(Vector2(126, 36)), false, Color(1, 0.62, 0.86, 0.92))
	var tag_label = app._label(label_text, 14)
	tag_label.position = _gal_info_child_pos(Vector2(66, 157), Vector2(126, 30), true)
	tag_label.size = _gal_size(Vector2(126, 30))
	tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_label.modulate = Color(1.0, 0.92, 1.0)
	app._view_container().add_child(tag_label)

	var dress_pos := _gal_info_child_pos(Vector2(-4, 72), Vector2(98, 98), true)
	app._draw_image(GAL_BTN_DRESS, dress_pos, _gal_size(Vector2(98, 98)), false)
	app._draw_image(GAL_IMG_LABEL_BG, _gal_info_child_pos(Vector2(-4, 18), Vector2(126, 36), true), _gal_size(Vector2(126, 36)), false, Color(1, 1, 1, 0.74))
	_add_gal_text("裝扮", _gal_info_child_pos(Vector2(-4, 18), Vector2(126, 30), true), _gal_size(Vector2(126, 30)), 14)
	_add_hit_button(dress_pos, _gal_size(Vector2(98, 98)), func() -> void:
		show_view(VIEW_CHARACTER)
	)
	app._draw_red_dot(_gal_info_child_pos(Vector2(27.3, 100.5), Vector2(0, 0), true))

	var priv_pos := _gal_info_child_pos(Vector2(-4, -58), Vector2(98, 98), true)
	app._draw_image(GAL_BTN_PRIV, priv_pos, _gal_size(Vector2(98, 98)), false)
	app._draw_image(GAL_IMG_LABEL_BG, _gal_info_child_pos(Vector2(-4, -112), Vector2(126, 36), true), _gal_size(Vector2(126, 36)), false, Color(1, 1, 1, 0.74))
	_add_gal_text("甜蜜互動", _gal_info_child_pos(Vector2(-4, -112), Vector2(126, 30), true), _gal_size(Vector2(126, 30)), 14)
	_add_hit_button(priv_pos, _gal_size(Vector2(98, 98)), func() -> void:
		show_view(VIEW_CHARACTER)
	)

	var personality_pos := _gal_info_child_pos(Vector2(66, 157), Vector2(168, 48), true)
	app._draw_image("res://assets/ui/gal/gal_img_04.png", personality_pos, _gal_size(Vector2(168, 48)), false, Color(1, 1, 1, 0.95))
	app._draw_image("res://assets/ui/gal/gal_btn_02.png", _gal_info_child_pos(Vector2(150, 157), Vector2(50, 50), true), _gal_size(Vector2(50, 50)), false)
	_add_gal_text("性格", _gal_info_child_pos(Vector2(55, 157), Vector2(120, 30), true), _gal_size(Vector2(120, 30)), 15)
	_add_hit_button(personality_pos, _gal_size(Vector2(168, 48)), func() -> void:
		show_view(VIEW_CHARACTER)
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

	var lbl = app._label("好感等級", 13)
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
		_show_touch_hint("禮物已送出，好感 +5")
		show_view(VIEW_DATE_SELECT)
	)

	var file_pos := _gal_right_bottom_pos(Vector2(-623, 19), Vector2(88, 88))
	app._draw_image(GAL_BTN_FILE, file_pos, small_size, false, Color(1, 1, 1, 0.90))
	_add_gal_text("檔案", file_pos + _gal_size(Vector2(0, 60)), _gal_size(Vector2(88, 22)), 14)
	_add_hit_button(file_pos, small_size, func() -> void:
		show_view(VIEW_CHARACTER)
	)


func _draw_side_buttons() -> void:
	var button_size := _gal_size(Vector2(98, 98))
	var label_size := _gal_size(Vector2(126, 36))

	var album_pos := _gal_right_bottom_pos(Vector2(-79, 193), Vector2(98, 98))
	app._draw_image(GAL_BTN_ALBUM, album_pos, button_size, false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, album_pos + _gal_size(Vector2(-14, 89)), label_size, false, Color(1, 1, 1, 0.72))
	_add_gal_text("相冊", album_pos + _gal_size(Vector2(-14, 89)), label_size, 14)
	_add_hit_button(album_pos, button_size, func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(_gal_right_bottom_pos(Vector2(-51.7, 221.5), Vector2(0, 0)))

	var mem_pos := _gal_right_bottom_pos(Vector2(-79, 323), Vector2(98, 98))
	app._draw_image(GAL_BTN_MEM, mem_pos, button_size, false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, mem_pos + _gal_size(Vector2(-14, 89)), label_size, false, Color(1, 1, 1, 0.72))
	_add_gal_text("心動回憶", mem_pos + _gal_size(Vector2(-14, 89)), label_size, 14)
	_add_hit_button(mem_pos, button_size, func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(_gal_right_bottom_pos(Vector2(-51.7, 351.5), Vector2(0, 0)))


func _draw_hide_button() -> void:
	var hide_pos := _gal_center_pos(Vector2(-196, 129), Vector2(90, 90))
	var hide_size := _gal_size(Vector2(90, 90))
	app._draw_image("res://assets/ui/gal/gal_btn_46.png", hide_pos, hide_size, false, Color(1, 1, 1, 0.72))
	_add_hit_button(hide_pos, hide_size, func() -> void:
		show_view(VIEW_DATE_SELECT)
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
		show_view(VIEW_CHARACTER)
	)
	app._draw_red_dot(_gal_left_middle_pos(Vector2(230.9, -246.4), Vector2(0, 0)))


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
