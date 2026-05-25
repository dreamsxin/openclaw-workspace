# UTF-8 source. GalDormitoryView shell + restored Gal child views.
extends RefCounted

const VIEW_MAIN := "main"
const VIEW_DATE_SELECT := "date_select"
const VIEW_CHARACTER := "character"

# Main panel resources
const GAL_BG := "res://assets/ui/gal/gal_img_122.png"
const GAL_ROOM_BG := "res://assets/ui/background/gal_bg_room_4.png"
const GAL_HERO_PANEL := "res://assets/ui/gal/gal_img_03.png"
const GAL_BTN_CLOSE := "res://assets/ui/gal/gal_btn_01.png"
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

var app
var _current_view := VIEW_MAIN

func _init(app_ref) -> void:
	app = app_ref


func show_gal() -> void:
	show_view(VIEW_MAIN)


func show_view(view_name: String) -> void:
	_current_view = view_name
	app.current_view = "gal"
	app._clear("Gal")
	match view_name:
		VIEW_DATE_SELECT:
			_draw_date_select_view()
		VIEW_CHARACTER:
			_draw_character_view()
		_:
			_draw_main_view()


func _selected_hero() -> Dictionary:
	return app._hero_by_id(int(app.save.get("selected_hero_id", 240037)))


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
	app._draw_hero_stage(hero, Vector2(345, 34), Vector2(520, 650), false)

	var line = app._label("今天也要全力發光!", 18, HORIZONTAL_ALIGNMENT_CENTER)
	line.position = Vector2(500, 430)
	line.size = Vector2(260, 30)
	line.modulate = Color(1, 1, 1, 0.96)
	app._view_container().add_child(line)


func _draw_top_bar() -> void:
	var cx := 50.0
	var cy := 16.0
	var cw := 54.0
	var ch := 54.0
	app._draw_image(GAL_BTN_CLOSE, Vector2(cx, cy), Vector2(cw, ch), false, Color(1, 1, 1, 0.94))
	_add_hit_button(Vector2(cx, cy), Vector2(cw, ch), app._show_home)

	app._draw_image(GAL_BTN_FAV, Vector2(178, 20), Vector2(44, 44), false, Color(1, 1, 1, 0.92))
	_add_hit_button(Vector2(178, 20), Vector2(44, 44), func() -> void:
		app._show_gallery()
	)

	var help = app._label("?", 22, HORIZONTAL_ALIGNMENT_CENTER)
	help.position = Vector2(136, 24)
	help.size = Vector2(36, 36)
	help.modulate = Color(1.0, 0.72, 0.90)
	app._view_container().add_child(help)


func _draw_hero_info_panel(hero: Dictionary) -> void:
	var pw := 224.0
	var ph := 586.0
	var px := 36.0
	var py := 23.0

	app._draw_image(GAL_HERO_PANEL, Vector2(px - 4, py - 4), Vector2(pw + 8, ph + 8), false, Color(1, 1, 1, 0.25))
	app._draw_image(GAL_HERO_PANEL, Vector2(px, py), Vector2(pw, ph), false, Color(1, 1, 1, 1.0))

	var title_text := "玄武" if str(hero.get("spine", "")) == "hero_037" else str(hero.get("title", hero.get("name", "")))
	var name_text := "墨菏" if str(hero.get("spine", "")) == "hero_037" else str(hero.get("name", "角色"))
	var label_text := "天真天然邪" if str(hero.get("spine", "")) == "hero_037" else "性格標籤"

	var title_label = app._label(title_text, 18)
	title_label.position = Vector2(56, 92)
	title_label.size = Vector2(120, 28)
	title_label.modulate = Color(1.0, 0.92, 0.66)
	app._view_container().add_child(title_label)

	var name_label = app._label(name_text, 30)
	name_label.position = Vector2(56, 118)
	name_label.size = Vector2(140, 42)
	name_label.modulate = Color(1.0, 1.0, 1.0)
	app._view_container().add_child(name_label)

	app._draw_image(GAL_IMG_LABEL_BG, Vector2(52, 178), Vector2(118, 25), false, Color(1, 0.62, 0.86, 0.92))
	var tag_label = app._label(label_text, 14)
	tag_label.position = Vector2(58, 181)
	tag_label.size = Vector2(86, 18)
	tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_label.modulate = Color(1.0, 0.92, 1.0)
	app._view_container().add_child(tag_label)

	var dress_x := 50.0
	var dress_y := 220.0
	app._draw_image(GAL_BTN_DRESS, Vector2(dress_x, dress_y), Vector2(75, 94), false)
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(dress_x - 12, dress_y + 82), Vector2(99, 28), false, Color(1, 1, 1, 0.74))
	_add_gal_text("裝扮", Vector2(dress_x - 8, dress_y + 82), Vector2(91, 28), 14)
	_add_hit_button(Vector2(dress_x, dress_y), Vector2(75, 94), func() -> void:
		show_view(VIEW_CHARACTER)
	)
	app._draw_red_dot(Vector2(dress_x + 55, dress_y + 6))

	var priv_x := 50.0
	var priv_y := 335.0
	app._draw_image(GAL_BTN_PRIV, Vector2(priv_x, priv_y), Vector2(75, 94), false)
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(priv_x - 12, priv_y + 82), Vector2(99, 28), false, Color(1, 1, 1, 0.74))
	_add_gal_text("甜蜜互動", Vector2(priv_x - 16, priv_y + 82), Vector2(112, 28), 14)
	_add_hit_button(Vector2(priv_x, priv_y), Vector2(75, 94), func() -> void:
		show_view(VIEW_CHARACTER)
	)

	var person_x := 74.0
	var person_y := 480.0
	app._draw_image("res://assets/ui/gal/gal_img_04.png", Vector2(person_x, person_y), Vector2(129, 46), false, Color(1, 1, 1, 0.95))
	app._draw_image("res://assets/ui/gal/gal_btn_02.png", Vector2(person_x + 88, person_y - 2), Vector2(38, 50), false)
	_add_gal_text("性格", Vector2(person_x + 4, person_y + 8), Vector2(88, 28), 15)
	_add_hit_button(Vector2(person_x, person_y), Vector2(129, 46), func() -> void:
		show_view(VIEW_CHARACTER)
	)


func _draw_level_ring() -> void:
	var lv_w := 190.0
	var lv_h := 210.0
	var lv_x := 1004.0
	var lv_y := 24.0
	app._draw_image(GAL_BTN_LV, Vector2(lv_x, lv_y), Vector2(lv_w, lv_h), false, Color(1, 1, 1, 0.90))

	var level := int(app.save.get("gal_level", 2))
	var lv_num = app._label(str(level), 48)
	lv_num.position = Vector2(lv_x + 78, lv_y + 44)
	lv_num.size = Vector2(60, 62)
	lv_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_num.modulate = Color(1.0, 0.94, 0.66)
	app._view_container().add_child(lv_num)

	var bar_w := 170.0
	var bar_h := 44.0
	var bar_y := lv_y + 152
	app._draw_image(GAL_BTN_LV_BAR, Vector2(lv_x + 34, bar_y), Vector2(bar_w, bar_h), false, Color(1, 1, 1, 0.82))

	var exp_val := int(app.save.get("gal_exp", 0))
	var exp_text = app._label("%d/250" % exp_val, 13)
	exp_text.position = Vector2(lv_x + 54, bar_y + 13)
	exp_text.size = Vector2(130, 16)
	exp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_text.modulate = Color(1.0, 0.72, 0.72)
	app._view_container().add_child(exp_text)

	var lbl = app._label("好感等級", 13)
	lbl.position = Vector2(lv_x + 20, lv_y + 12)
	lbl.size = Vector2(lv_w - 40, 18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate = Color(1.0, 0.96, 0.98)
	app._view_container().add_child(lbl)


func _draw_action_buttons() -> void:
	var dw := 227.0
	var dh := 111.0
	var dx := 1007.0
	var dy := 591.0
	app._draw_image(GAL_BTN_DATE, Vector2(dx, dy), Vector2(dw, dh), false, Color(1, 1, 1, 0.94))
	_add_gal_text("約會", Vector2(dx + 68, dy + 32), Vector2(91, 46), 24)
	_add_hit_button(Vector2(dx, dy), Vector2(dw, dh), func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(Vector2(dx + dw - 26, dy + 10))

	var gw := 144.0
	var gh := 84.0
	var gx := 870.0
	var gy := 618.0
	app._draw_image(GAL_BTN_GOOUT, Vector2(gx, gy), Vector2(gw, gh), false, Color(1, 1, 1, 0.90))
	_add_gal_text("外出", Vector2(gx + 32, gy + 22), Vector2(80, 40), 22)
	_add_hit_button(Vector2(gx, gy), Vector2(gw, gh), func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(Vector2(gx + gw - 20, gy + 8))

	var gi_w := 68.0
	var gi_h := 84.0
	var gi_x := 803.0
	var gi_y := 618.0
	app._draw_image(GAL_BTN_GIFT, Vector2(gi_x, gi_y), Vector2(gi_w, gi_h), false, Color(1, 1, 1, 0.90))
	_add_gal_text("禮物", Vector2(gi_x, gi_y + 62), Vector2(gi_w, 22), 14)
	_add_hit_button(Vector2(gi_x, gi_y), Vector2(gi_w, gi_h), func() -> void:
		show_view(VIEW_DATE_SELECT)
	)

	var f_x := 735.0
	app._draw_image(GAL_BTN_FILE, Vector2(f_x, gi_y), Vector2(gi_w, gi_h), false, Color(1, 1, 1, 0.90))
	_add_gal_text("檔案", Vector2(f_x, gi_y + 62), Vector2(gi_w, 22), 14)
	_add_hit_button(Vector2(f_x, gi_y), Vector2(gi_w, gi_h), func() -> void:
		show_view(VIEW_CHARACTER)
	)


func _draw_side_buttons() -> void:
	var sw := 75.0
	var sh := 94.0
	var sx := 1108.0

	app._draw_image(GAL_BTN_ALBUM, Vector2(sx, 356), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, 438), Vector2(109, 28), false, Color(1, 1, 1, 0.72))
	_add_gal_text("相冊", Vector2(sx - 18, 438), Vector2(109, 28), 14)
	_add_hit_button(Vector2(sx, 356), Vector2(sw, sh), func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(Vector2(sx + 55, 360))

	app._draw_image(GAL_BTN_MEM, Vector2(sx, 246), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, 328), Vector2(109, 28), false, Color(1, 1, 1, 0.72))
	_add_gal_text("心動回憶", Vector2(sx - 18, 328), Vector2(109, 28), 14)
	_add_hit_button(Vector2(sx, 246), Vector2(sw, sh), func() -> void:
		show_view(VIEW_DATE_SELECT)
	)
	app._draw_red_dot(Vector2(sx + 55, 250))


func _draw_hide_button() -> void:
	app._draw_image("res://assets/ui/gal/gal_btn_46.png", Vector2(432, 142), Vector2(58, 70), false, Color(1, 1, 1, 0.72))
	_add_hit_button(Vector2(432, 142), Vector2(58, 70), func() -> void:
		show_view(VIEW_DATE_SELECT)
	)


func _draw_role_selector(hero: Dictionary) -> void:
	var rx := 52.0
	var ry := 594.0
	var rw := 72.0
	var rh := 72.0

	app._draw_image(GAL_IMG_ROLE_BG, Vector2(rx, ry), Vector2(rw, rh), false, Color(1, 1, 1, 0.88))
	var tex = app._hero_portrait_texture(hero)
	if tex != null:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(0, 88, tex.get_width(), min(260, tex.get_height() - 88))

		var clip := Control.new()
		clip.position = Vector2(rx + 8, ry + 8)
		clip.size = Vector2(56, 56)
		clip.clip_contents = true
		app._view_container().add_child(clip)

		var rect := TextureRect.new()
		rect.texture = atlas
		rect.position = Vector2.ZERO
		rect.size = Vector2(56, 56)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.modulate = Color(1, 1, 1, 0.96)
		clip.add_child(rect)

	app._draw_image(GAL_BTN_CHANGE_ICON, Vector2(rx + rw - 18, ry - 8), Vector2(32, 38), false, Color(1, 1, 1, 0.90))
	_add_hit_button(Vector2(rx, ry), Vector2(rw, rh), func() -> void:
		show_view(VIEW_CHARACTER)
	)
	app._draw_red_dot(Vector2(rx + 68, ry + 4))


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
		)

	app._draw_image(GAL_BTN_DATE_CONFIRM, Vector2(card_pos.x + 366, card_pos.y + 528), Vector2(270, 58), false)
	_add_gal_text("確認出行", Vector2(card_pos.x + 424, card_pos.y + 541), Vector2(160, 28), 20)
	_add_hit_button(Vector2(card_pos.x + 366, card_pos.y + 528), Vector2(270, 58), func() -> void:
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
	button.pressed.connect(callback)
	app._view_container().add_child(button)
	return button
