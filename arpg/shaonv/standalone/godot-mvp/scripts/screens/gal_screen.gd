# UTF-8 source. GalDormitoryMainPanel — 59 nodes restored from prefab inventory.
# GalDormitoryView shell: pnlTop / pnlMiddle / pnlBottom mount points.
extends RefCounted

# ── Sprite constants ──
const GAL_BG       = "res://assets/ui/gal/gal_img_122.png"
const GAL_ROOM_BG  = "res://assets/ui/background/gal_bg_room_4.png"
const GAL_HERO_PANEL = "res://assets/ui/gal/gal_img_03.png"
const GAL_BTN_CLOSE   = "res://assets/ui/gal/gal_btn_01.png"
const GAL_BTN_FAV     = "res://assets/ui/gal/gal_btn_31.png"
const GAL_BTN_LV      = "res://assets/ui/gal/gal_img_07.png"
const GAL_BTN_LV_BAR  = "res://assets/ui/gal/gal_img_08.png"
const GAL_BTN_DATE    = "res://assets/ui/gal/gal_btn_12.png"
const GAL_BTN_GOOUT   = "res://assets/ui/gal/gal_btn_13.png"
const GAL_BTN_GIFT    = "res://assets/ui/gal/gal_btn_14.png"
const GAL_BTN_FILE    = "res://assets/ui/gal/gal_btn_45.png"
const GAL_BTN_MEM     = "res://assets/ui/gal/gal_btn_06.png"
const GAL_BTN_ALBUM   = "res://assets/ui/gal/gal_btn_05.png"
const GAL_BTN_DRESS   = "res://assets/ui/gal/gal_btn_03.png"
const GAL_BTN_PRIV    = "res://assets/ui/gal/gal_btn_04.png"
const GAL_BTN_PERSON  = "res://assets/ui/gal/gal_img_04.png"
const GAL_BTN_PERSON_ICON = "res://assets/ui/gal/gal_btn_02.png"
const GAL_BTN_HIDE    = "res://assets/ui/gal/gal_btn_46.png"
const GAL_IMG_LABEL_BG = "res://assets/ui/gal/gal_img_05.png"
const GAL_IMG_ROLE_BG = "res://assets/ui/gal/gal_img_06.png"
const GAL_BTN_CHANGE_ICON = "res://assets/ui/gal/gal_btn_11.png"
const GAL_IMG_LOCK    = "res://assets/ui/gal/gal_img_126.png"
const GAL_IMG_LOCK_GO = "res://assets/ui/gal/gal_img_125.png"

var app
var _gal_panels: Array = []
var _hero_spine: Control = null  # spine canvas handle for cleanup

func _init(app_ref) -> void:
	app = app_ref


func show_gal() -> void:
	app.current_view = "gal"
	app._clear("Gal")
	_gal_panels.clear()
	_hero_spine = null

	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240037)))

	# Layer 0: Background fullscreen
	app._draw_image(GAL_ROOM_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)
	# Screenshot match: the real Gal room is bright, with only a light bottom vignette.
	app._view_container().add_child(app._panel(Vector2(0, 540), Vector2(1280, 180), Color(0.04, 0.025, 0.045, 0.22)))

	# Layer 1: Hero stage (center, behind UI panels)
	draw_hero_stage(hero)

	# Layer 2: Top bar
	draw_top_bar()

	# Layer 3: Left hero info panel
	draw_hero_info_panel(hero)

	# Layer 4: Right level ring
	draw_level_ring(hero)

	# Layer 5: Bottom-right action buttons
	draw_action_buttons()

	# Layer 6: Side buttons
	draw_side_buttons()

	# Layer 7: Center hide button
	draw_hide_button()

	# Layer 8: Character selector
	draw_role_selector()


# ═══════════════════════════════════════════════════════════════
# Drawing functions
# ═══════════════════════════════════════════════════════════════

func draw_hero_stage(hero: Dictionary) -> void:
	# hero_037r/hero_037r_s01 are Gal-specific but currently bake as loose atlas parts.
	# Use the verified hero_037 stage until the Gal spine baking path is fixed.
	app._draw_hero_stage(hero, Vector2(345, 34), Vector2(520, 650), false)

	var line = app._label("今天也要全力發光!", 18, HORIZONTAL_ALIGNMENT_CENTER)
	line.position = Vector2(500, 430)
	line.size = Vector2(260, 30)
	line.modulate = Color(1, 1, 1, 0.96)
	app._view_container().add_child(line)


func draw_top_bar() -> void:
	# pnlTopBar: anchor(0,1) pos(60,-18) — Unity top-left corner
	# btnClose: 120×80 → 92×77
	var cx = 50.0; var cy = 16.0
	var cw = 54.0; var ch = 54.0
	app._draw_image(GAL_BTN_CLOSE, Vector2(cx, cy), Vector2(cw, ch), false, Color(1, 1, 1, 0.94))
	app._add_action_button("", Vector2(cx, cy), app._show_home, Vector2(cw, ch))

	# btnFavorite: 60×60 → 46×58, right of close via HorizontalLayoutGroup
	app._draw_image(GAL_BTN_FAV, Vector2(178, 20), Vector2(44, 44), false, Color(1, 1, 1, 0.92))
	app._add_action_button("", Vector2(178, 20), app._show_home, Vector2(44, 44))
	var help = app._label("?", 22, HORIZONTAL_ALIGNMENT_CENTER)
	help.position = Vector2(136, 24)
	help.size = Vector2(36, 36)
	help.modulate = Color(1.0, 0.72, 0.90)
	app._view_container().add_child(help)


func draw_hero_info_panel(hero: Dictionary) -> void:
	# Image (gal_img_03): anchor(0,0.5) pos(190,-46) size(292,610) pivot(0.5,0.5)
	var pw = 224.0; var ph = 586.0
	var px = 36.0; var py = 23.0

	# gal_img_03: left-panel decorative background (prefab color.a=1.0, 97% transparent)
	app._draw_image(GAL_HERO_PANEL, Vector2(px - 4, py - 4), Vector2(pw + 8, ph + 8), false, Color(1, 1, 1, 0.25))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	app._draw_image(GAL_HERO_PANEL, Vector2(px, py), Vector2(pw, ph), false, Color(1, 1, 1, 1.0))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# Runtime text for hero_037 Gal screenshot.
	var title_text := "玄武" if str(hero.get("spine", "")) == "hero_037" else str(hero.get("title", ""))
	var name_text := "墨茗" if str(hero.get("spine", "")) == "hero_037" else str(hero.get("name", ""))
	var label_text := "天真無邪" if str(hero.get("spine", "")) == "hero_037" else "性格"
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

	# ── Buttons positioned per Prefab pivot-precise calculation ──
	# btnPersonality: anchor(0,0.5) pivot(0.5,0.5) pos(66,157) size(168,48) → Godot (20,443) 129×46
	# Screenshot state surfaces only the tag plus two side actions: dress and sweet interaction.
	var bdx = 50.0; var bdy = 220.0
	app._draw_image(GAL_BTN_DRESS, Vector2(bdx, bdy), Vector2(75, 94), false, Color(1, 1, 1, 1.0))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(bdx - 12, bdy + 82), Vector2(99, 28), false, Color(1, 1, 1, 0.74))
	_add_gal_text("裝扮", Vector2(bdx - 8, bdy + 82), Vector2(91, 28), 14)
	app._add_action_button("", Vector2(bdx, bdy), app._show_home, Vector2(75, 94))
	app._draw_red_dot(Vector2(bdx + 55, bdy + 6))

	var bix = 50.0; var biy = 335.0
	app._draw_image(GAL_BTN_PRIV, Vector2(bix, biy), Vector2(75, 94), false, Color(1, 1, 1, 1.0))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(bix - 12, biy + 82), Vector2(99, 28), false, Color(1, 1, 1, 0.74))
	_add_gal_text("甜蜜互動", Vector2(bix - 16, biy + 82), Vector2(112, 28), 14)
	app._add_action_button("", Vector2(bix, biy), app._show_home, Vector2(75, 94))


func draw_level_ring(hero: Dictionary) -> void:
	# btnLv: anchor(1,1) pos(-13,-15) size(322,322) → Godot 247×309
	var lv_w = 190.0; var lv_h = 210.0
	var lv_x = 1004.0; var lv_y = 24.0
	app._draw_image(GAL_BTN_LV, Vector2(lv_x, lv_y), Vector2(lv_w, lv_h), false, Color(1, 1, 1, 0.90))

	# txtLv: large level number centered
	var level = int(app.save.get("gal_level", 2))
	var lv_num = app._label(str(level), 48)
	lv_num.position = Vector2(lv_x + 78, lv_y + 44)
	lv_num.size = Vector2(60, 62)
	lv_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_num.modulate = Color(1.0, 0.94, 0.66)
	app._view_container().add_child(lv_num)

	# Exp bar: gal_img_08 pos(0,-112) size(222,46) → 170×44
	var bar_w = 170.0; var bar_h = 44.0
	var bar_y = lv_y + 152
	app._draw_image(GAL_BTN_LV_BAR, Vector2(lv_x + 34, bar_y), Vector2(bar_w, bar_h), false, Color(1, 1, 1, 0.82))

	var exp_val = int(app.save.get("gal_exp", 0))
	var exp_text = app._label("%d/250" % exp_val, 13)
	exp_text.position = Vector2(lv_x + 54, bar_y + 13)
	exp_text.size = Vector2(130, 16)
	exp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_text.modulate = Color(1.0, 0.72, 0.72)
	app._view_container().add_child(exp_text)

	# Level label: "好感等級" below ring
	var lbl = app._label("好感等級", 13)
	lbl.position = Vector2(lv_x + 20, lv_y + 12)
	lbl.size = Vector2(lv_w - 40, 18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate = Color(1.0, 0.96, 0.98)
	app._view_container().add_child(lbl)


func draw_action_buttons() -> void:
	# anchor(1,0) — bottom-right anchored buttons, Y from viewport bottom
	var base_y = 720.0

	# btnDate: pos(-59,19) size(296,116) → 227×111
	var dw = 227.0; var dh = 111.0
	var dx = 1007.0; var dy = 591.0  # y = 720 - 19*0.96 - 111
	app._draw_image(GAL_BTN_DATE, Vector2(dx, dy), Vector2(dw, dh), false, Color(1, 1, 1, 0.94))
	_add_gal_text("約會", Vector2(dx + 68, dy + 32), Vector2(91, 46), 24)
	add_hit_button(Vector2(dx, dy), Vector2(dw, dh), app._show_home)
	app._draw_red_dot(Vector2(dx + dw - 26, dy + 10))

	# btnGoOut: pos(-347,19) size(188,88) → 144×84
	var gw = 144.0; var gh = 84.0
	var gx = 870.0; var gy = 618.0
	app._draw_image(GAL_BTN_GOOUT, Vector2(gx, gy), Vector2(gw, gh), false, Color(1, 1, 1, 0.90))
	_add_gal_text("外出", Vector2(gx + 32, gy + 22), Vector2(80, 40), 22)
	add_hit_button(Vector2(gx, gy), Vector2(gw, gh), app._show_home)
	app._draw_red_dot(Vector2(gx + gw - 20, gy + 8))

	# btnGift: pos(-535,19) size(88,88) → 68×84
	var gi_w = 68.0; var gi_h = 84.0
	var gi_x = 803.0; var gi_y = 618.0
	app._draw_image(GAL_BTN_GIFT, Vector2(gi_x, gi_y), Vector2(gi_w, gi_h), false, Color(1, 1, 1, 0.90))
	_add_gal_text("禮物", Vector2(gi_x, gi_y + 62), Vector2(gi_w, 22), 14)
	add_hit_button(Vector2(gi_x, gi_y), Vector2(gi_w, gi_h), app._show_home)

	# btnFile: pos(-623,19) size(88,88) → 68×84
	var f_x = 735.0
	app._draw_image(GAL_BTN_FILE, Vector2(f_x, gi_y), Vector2(gi_w, gi_h), false, Color(1, 1, 1, 0.90))
	_add_gal_text("檔案", Vector2(f_x, gi_y + 62), Vector2(gi_w, 22), 14)
	add_hit_button(Vector2(f_x, gi_y), Vector2(gi_w, gi_h), app._show_home)


func draw_side_buttons() -> void:
	# btnPhotoAlbum + btnMemories: anchor(1,0), right side
	var sw = 75.0; var sh = 94.0
	var sx = 1108.0

	# btnPhotoAlbum: pos(-79,193) → above
	app._draw_image(GAL_BTN_ALBUM, Vector2(sx, 356), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, 438), Vector2(109, 28), false, Color(1, 1, 1, 0.72))
	_add_gal_text("相冊", Vector2(sx - 18, 438), Vector2(109, 28), 14)
	add_hit_button(Vector2(sx, 356), Vector2(sw, sh), app._show_home)
	app._draw_red_dot(Vector2(sx + 55, 360))

	# btnMemories: pos(-79,323) → below
	app._draw_image(GAL_BTN_MEM, Vector2(sx, 246), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, 328), Vector2(109, 28), false, Color(1, 1, 1, 0.72))
	_add_gal_text("心動回憶", Vector2(sx - 18, 328), Vector2(109, 28), 14)
	add_hit_button(Vector2(sx, 246), Vector2(sw, sh), app._show_home)
	app._draw_red_dot(Vector2(sx + 55, 250))


func draw_hide_button() -> void:
	# btnHide: pos(-196,129) size(90,90) anchor(0.5,0.5)
	app._draw_image(GAL_BTN_HIDE, Vector2(432, 142), Vector2(58, 70), false, Color(1, 1, 1, 0.72))
	add_hit_button(Vector2(432, 142), Vector2(58, 70), app._show_home)


func draw_role_selector() -> void:
	# pnlRoleList: anchor(0,0.5) pos(-9,-250) size(110,110) → 84×106
	var rx = 52.0; var ry = 594.0; var rw = 72.0; var rh = 72.0

	app._draw_image(GAL_IMG_ROLE_BG, Vector2(rx, ry), Vector2(rw, rh), false, Color(1, 1, 1, 0.88))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# Hero portrait in role selector
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240037)))
	if hero:
		var portrait_hero: Dictionary = hero.duplicate(true)
		if str(hero.get("spine", "")) == "hero_037":
			portrait_hero["portraitResource"] = str(hero.get("portraitResource", ""))
		var tex = app._hero_portrait_texture(portrait_hero)
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
			rect.position = Vector2(0, 0)
			rect.size = Vector2(56, 56)
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			rect.modulate = Color(1, 1, 1, 0.96)
			clip.add_child(rect)

	# Change icon: gal_btn_11
	app._draw_image(GAL_BTN_CHANGE_ICON, Vector2(rx + rw - 18, ry - 8), Vector2(32, 38), false, Color(1, 1, 1, 0.90))
	add_hit_button(Vector2(rx, ry), Vector2(rw, rh), app._show_home)
	app._draw_red_dot(Vector2(rx + 68, ry + 4))


# ── Helpers ──
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


func add_hit_button(pos: Vector2, hit_size: Vector2, callback: Callable) -> Button:
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
