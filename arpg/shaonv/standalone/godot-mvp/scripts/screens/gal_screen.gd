# UTF-8 source. GalDormitoryMainPanel — 59 nodes restored from prefab inventory.
# GalDormitoryView shell: pnlTop / pnlMiddle / pnlBottom mount points.
extends RefCounted

# ── Sprite constants ──
const GAL_BG       = "res://assets/ui/gal/gal_img_122.png"
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
	app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)
	# Dimming overlay
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.02, 0.02, 0.04, 0.25)))

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
	# Center the hero spine in the viewport area between info panel and level ring
	# irole was centered at parent center × 0.767/0.96
	app._draw_hero_stage(hero, Vector2(260, 40), Vector2(760, 660), false)


func draw_top_bar() -> void:
	# pnlTopBar: anchor(0,1) pos(60,-18) — Unity top-left corner
	# btnClose: 120×80 → 92×77
	var cx = 50.0; var cy = 16.0
	var cw = 92.0; var ch = 77.0
	app._draw_image(GAL_BTN_CLOSE, Vector2(cx, cy), Vector2(cw, ch), false, Color(1, 1, 1, 0.94))
	app._add_action_button("", Vector2(cx, cy), app._show_home, Vector2(cw, ch))

	# btnFavorite: 60×60 → 46×58, right of close via HorizontalLayoutGroup
	app._draw_image(GAL_BTN_FAV, Vector2(cx + cw + 6, cy + 8), Vector2(46, 58), false, Color(1, 1, 1, 0.92))
	app._add_action_button("", Vector2(cx + cw + 6, cy + 8), app._show_home, Vector2(46, 58))


func draw_hero_info_panel(hero: Dictionary) -> void:
	# Image (gal_img_03): anchor(0,0.5) pos(190,-46) size(292,610) pivot(0.5,0.5)
	var pw = 224.0; var ph = 586.0
	var px = 36.0; var py = 23.0

	# Main panel
	app._draw_image(GAL_HERO_PANEL, Vector2(px, py), Vector2(pw, ph), false, Color(1, 1, 1, 0.94))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# Mirrored reflection (second gal_img_03 at +146px)
	app._draw_image(GAL_HERO_PANEL, Vector2(px + 112, py), Vector2(pw, ph), false, Color(1, 1, 1, 0.48))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# txtTName: primary name (fs=50 in prefab, scaled down)
	var tx = px + 50
	var name_label = app._label(str(hero.get("name", "阿修羅") if hero else "阿修羅"), 26)
	name_label.position = Vector2(tx, py + 44)
	name_label.size = Vector2(150, 32)
	name_label.modulate = Color(0.98, 0.94, 0.78)
	app._view_container().add_child(name_label)

	# txtName: subtitle
	var subtitle = app._label(str(hero.get("title", "修羅之刃") if hero else "修羅之刃"), 15)
	subtitle.position = Vector2(tx, py + 82)
	subtitle.size = Vector2(150, 20)
	subtitle.modulate = Color(0.82, 0.76, 0.64)
	app._view_container().add_child(subtitle)

	# btnPersonality: gal_img_04 pos(66,157) size(168,48) → 129×46
	app._draw_image(GAL_BTN_PERSON, Vector2(px + 16, py + 168), Vector2(129, 46), false, Color(1, 1, 1, 0.90))
	app._draw_image(GAL_BTN_PERSON_ICON, Vector2(px + 96, py + 164), Vector2(38, 50), false, Color(1, 1, 1, 0.92))
	_add_gal_text("性格", Vector2(px + 24, py + 176), Vector2(70, 30), 16)
	app._add_action_button("", Vector2(px + 16, py + 168), app._show_home, Vector2(129, 46))

	# btnDressUp: gal_btn_03 pos(-4,72) size(98,98) → 75×94
	var d_btn_y = py + 148
	app._draw_image(GAL_BTN_DRESS, Vector2(px, d_btn_y), Vector2(75, 94), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(px - 12, d_btn_y + 82), Vector2(99, 28), false, Color(1, 1, 1, 0.74))
	_add_gal_text("裝扮", Vector2(px - 8, d_btn_y + 82), Vector2(91, 28), 14)
	app._add_action_button("", Vector2(px, d_btn_y), app._show_home, Vector2(75, 94))
	app._draw_red_dot(Vector2(px + 55, d_btn_y + 6))

	# btnPrivateInteraction: gal_btn_04 pos(-4,-58) → below dressUp
	app._draw_image(GAL_BTN_PRIV, Vector2(px, py + 344), Vector2(75, 94), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(px - 12, py + 426), Vector2(99, 28), false, Color(1, 1, 1, 0.74))
	_add_gal_text("私密", Vector2(px - 8, py + 426), Vector2(91, 28), 14)
	app._add_action_button("", Vector2(px, py + 344), app._show_home, Vector2(75, 94))


func draw_level_ring(hero: Dictionary) -> void:
	# btnLv: anchor(1,1) pos(-13,-15) size(322,322) → Godot 247×309
	var lv_w = 247.0; var lv_h = 309.0
	var lv_x = 1023.0; var lv_y = 397.0
	app._draw_image(GAL_BTN_LV, Vector2(lv_x, lv_y), Vector2(lv_w, lv_h), false, Color(1, 1, 1, 0.90))

	# txtLv: large level number centered
	var level = int(app.save.get("gal_level", 1))
	var lv_num = app._label(str(level), 48)
	lv_num.position = Vector2(lv_x + 94, lv_y + 34)
	lv_num.size = Vector2(60, 56)
	lv_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_num.modulate = Color(1.0, 0.94, 0.66)
	app._view_container().add_child(lv_num)

	# Exp bar: gal_img_08 pos(0,-112) size(222,46) → 170×44
	var bar_w = 170.0; var bar_h = 44.0
	var bar_y = lv_y + lv_h - 54
	app._draw_image(GAL_BTN_LV_BAR, Vector2(lv_x + 38, bar_y), Vector2(bar_w, bar_h), false, Color(1, 1, 1, 0.82))

	var exp_val = int(app.save.get("gal_exp", 0))
	var exp_text = app._label("%d / 100" % exp_val, 11)
	exp_text.position = Vector2(lv_x + 58, bar_y + 14)
	exp_text.size = Vector2(130, 16)
	exp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_text.modulate = Color(1.0, 0.72, 0.72)
	app._view_container().add_child(exp_text)

	# Level label: "好感等級" below ring
	var lbl = app._label("好感等級", 13)
	lbl.position = Vector2(lv_x + 20, bar_y + bar_h + 6)
	lbl.size = Vector2(lv_w - 40, 18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate = Color(1.0, 0.84, 0.60)
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
	var sx = 1144.0

	# btnPhotoAlbum: pos(-79,193) → above
	app._draw_image(GAL_BTN_ALBUM, Vector2(sx, 441), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, 523), Vector2(109, 28), false, Color(1, 1, 1, 0.72))
	_add_gal_text("相冊", Vector2(sx - 18, 523), Vector2(109, 28), 14)
	add_hit_button(Vector2(sx, 441), Vector2(sw, sh), app._show_home)
	app._draw_red_dot(Vector2(sx + 55, 445))

	# btnMemories: pos(-79,323) → below
	app._draw_image(GAL_BTN_MEM, Vector2(sx, 316), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, 398), Vector2(109, 28), false, Color(1, 1, 1, 0.72))
	_add_gal_text("回憶", Vector2(sx - 18, 398), Vector2(109, 28), 14)
	add_hit_button(Vector2(sx, 316), Vector2(sw, sh), app._show_home)
	app._draw_red_dot(Vector2(sx + 55, 320))


func draw_hide_button() -> void:
	# btnHide: pos(-196,129) size(90,90) anchor(0.5,0.5)
	app._draw_image(GAL_BTN_HIDE, Vector2(456, 442), Vector2(69, 86), false, Color(1, 1, 1, 0.72))
	add_hit_button(Vector2(456, 442), Vector2(69, 86), app._show_home)


func draw_role_selector() -> void:
	# pnlRoleList: anchor(0,0.5) pos(-9,-250) size(110,110) → 84×106
	var rx = 6.0; var ry = 82.0; var rw = 84.0; var rh = 106.0

	app._draw_image(GAL_IMG_ROLE_BG, Vector2(rx, ry), Vector2(rw, rh), false, Color(1, 1, 1, 0.88))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# Hero portrait in role selector
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240037)))
	if hero:
		var tex = app._hero_portrait_texture(hero)
		if tex != null:
			var rect = TextureRect.new()
			rect.texture = tex
			rect.position = Vector2(rx + 6, ry + 7)
			rect.size = Vector2(72, 92)
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			rect.clip_contents = true
			app._view_container().add_child(rect)

	# Change icon: gal_btn_11
	app._draw_image(GAL_BTN_CHANGE_ICON, Vector2(rx + rw - 26, ry + rh - 28), Vector2(36, 44), false, Color(1, 1, 1, 0.90))
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
