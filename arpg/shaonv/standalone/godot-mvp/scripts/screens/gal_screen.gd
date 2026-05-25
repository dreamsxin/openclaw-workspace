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

func _init(app_ref) -> void:
	app = app_ref


func show_gal() -> void:
	app.current_view = "gal"
	app._set_chrome_visible(false)
	app._clear("Gal")
	_gal_panels.clear()

	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240037)))

	# Layer 0: Background
	app._draw_image(GAL_BG, Vector2(0, 0), Vector2(1280, 720), true)

	# Layer 1: Top bar (close + fav)
	draw_top_bar()

	# Layer 2: Left hero info panel
	draw_hero_info_panel(hero)

	# Layer 3: Right level ring
	draw_level_ring(hero)

	# Layer 4: Bottom-right action buttons
	draw_action_buttons()

	# Layer 5: Side buttons (memories, album)
	draw_side_buttons()

	# Layer 6: Center hide button
	draw_hide_button()

	# Layer 7: Character selector
	draw_role_selector()


# ═══════════════════════════════════════════════════════════════
# Drawing functions
# ═══════════════════════════════════════════════════════════════

func draw_top_bar() -> void:
	# pnlTopBar: anchor(0,1) pos(60,-18) size(120,80) → Godot top-left
	# btnClose pos(0,0) size(120,80)
	var cx = 46.0; var cy = 17.0
	var cw = 92.0; var ch = 77.0
	app._draw_image(GAL_BTN_CLOSE, Vector2(cx, cy), Vector2(cw, ch), false, Color(1, 1, 1, 0.92))
	app._add_action_button("", Vector2(cx, cy), app._show_home, Vector2(cw, ch))

	# pnlSection: HorizontalLayoutGroup right of close
	# btnFavorite: gal_btn_31, 60x60 (→46×58)
	var fx = cx + cw + 8; var fy = cy + 8
	var fw = 46.0; var fh = 58.0
	app._draw_image(GAL_BTN_FAV, Vector2(fx, fy), Vector2(fw, fh), false, Color(1, 1, 1, 0.90))
	app._add_action_button("", Vector2(fx, fy), app._show_home, Vector2(fw, fh))


func draw_hero_info_panel(hero: Dictionary) -> void:
	# Image (gal_img_03): anchor(0,0.5) pos(190,-46) size(292,610) pivot(0.5,0.5)
	var pw = 224.0; var ph = 586.0
	var px = 36.0; var py = 23.0
	app._draw_image(GAL_HERO_PANEL, Vector2(px, py), Vector2(pw, ph), false, Color(1, 1, 1, 0.92))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# Mirrored copy: second gal_img_03 at offset (146,0) from first
	app._draw_image(GAL_HERO_PANEL, Vector2(px + 112, py), Vector2(pw, ph), false, Color(1, 1, 1, 0.50))
	_gal_panels.append(app._view_container().get_child(app._view_container().get_child_count() - 1))

	# txtTName: pos(298.3,231.5) from parent, fs=50
	var tx = px + 49.0; var ty = py + 44.0
	var name_label = app._label(str(hero.get("name", "阿修羅") if hero else "阿修羅"), 28)
	name_label.position = Vector2(tx, ty)
	name_label.size = Vector2(160, 36)
	name_label.modulate = Color(0.98, 0.94, 0.78)
	app._view_container().add_child(name_label)

	# txtName: pos(298.3,275.0), fs=26
	var subtitle = app._label(str(hero.get("title", "修羅之刃") if hero else "修羅之刃"), 16)
	subtitle.position = Vector2(tx, ty + 42)
	subtitle.size = Vector2(160, 22)
	subtitle.modulate = Color(0.80, 0.74, 0.60)
	app._view_container().add_child(subtitle)

	# btnPersonality: gal_img_04 pos(66,157) size(168,48)
	var pers_x = px + 16; var pers_y = py + 168
	var pers_w = 129.0; var pers_h = 46.0
	app._draw_image(GAL_BTN_PERSON, Vector2(pers_x, pers_y), Vector2(pers_w, pers_h), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_BTN_PERSON_ICON, Vector2(pers_x + pers_w - 50, pers_y - 2), Vector2(38, 50), false, Color(1, 1, 1, 0.90))
	app._add_action_button("性格", Vector2(pers_x, pers_y), app._show_home, Vector2(pers_w, pers_h))

	# btnDressUp: gal_btn_03 pos(-4,72) size(98,98)
	var drs_x = px; var drs_y = py + 148
	var drs_w = 75.0; var drs_h = 94.0
	app._draw_image(GAL_BTN_DRESS, Vector2(drs_x, drs_y), Vector2(drs_w, drs_h), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(drs_x - 12, drs_y + 85), Vector2(97, 28), false, Color(1, 1, 1, 0.72))
	add_gal_label("裝扮", Vector2(drs_x - 8, drs_y + 82), Vector2(90, 28), 14)
	app._add_action_button("", Vector2(drs_x, drs_y), app._show_home, Vector2(drs_w, drs_h))

	# btnPrivateInteraction: gal_btn_04 pos(-4,-58) size(98,98)
	var pri_y = py + 344
	app._draw_image(GAL_BTN_PRIV, Vector2(drs_x, pri_y), Vector2(drs_w, drs_h), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(drs_x - 12, pri_y + 85), Vector2(97, 28), false, Color(1, 1, 1, 0.72))
	add_gal_label("私密", Vector2(drs_x - 8, pri_y + 82), Vector2(90, 28), 14)
	app._add_action_button("", Vector2(drs_x, pri_y), app._show_home, Vector2(drs_w, drs_h))


func draw_level_ring(hero: Dictionary) -> void:
	# btnLv: anchor(1,1) pos(-13,-15) size(322,322) → Godot right-bottom
	var lv_w = 247.0; var lv_h = 309.0
	var lv_x = 1023.0; var lv_y = 397.0
	app._draw_image(GAL_BTN_LV, Vector2(lv_x, lv_y), Vector2(lv_w, lv_h), false, Color(1, 1, 1, 0.88))

	# txtLv: pos(0,13.8) size(322,99.7) fs=110 "50"
	var level = app.save.get("gal_level", 1)
	var lv_text = app._label(str(level), 52)
	lv_text.position = Vector2(lv_x + lv_w * 0.5 - 30, lv_y + 30)
	lv_text.size = Vector2(60, 60)
	lv_text.modulate = Color(1.0, 0.94, 0.70)
	lv_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	app._view_container().add_child(lv_text)

	# Image (gal_img_08): exp bar pos(0,-112) size(222,46)
	var bar_w = 170.0; var bar_h = 44.0
	var bar_x = lv_x + (lv_w - bar_w) * 0.5; var bar_y = lv_y + lv_h - 50
	app._draw_image(GAL_BTN_LV_BAR, Vector2(bar_x, bar_y), Vector2(bar_w, bar_h), false, Color(1, 1, 1, 0.80))

	# txtExp
	var exp_text = app._label("0 / 100", 11)
	exp_text.position = Vector2(bar_x + 10, bar_y + 14)
	exp_text.size = Vector2(bar_w - 20, 16)
	exp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exp_text.modulate = Color(1.0, 0.70, 0.70)
	app._view_container().add_child(exp_text)

	# Level name label: Text "Default" at pos(0,114) size(320,30) fs=22
	var lvl_name = app._label("好感等級", 13)
	lvl_name.position = Vector2(lv_x + 10, lv_y + lv_h * 0.5 + 70)
	lvl_name.size = Vector2(lv_w - 20, 20)
	lvl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lvl_name.modulate = Color(1.0, 0.82, 0.58)
	app._view_container().add_child(lvl_name)


func draw_action_buttons() -> void:
	# All anchored at anchor(1,0), Y from bottom of viewport

	# btnDate: pos(-59,19) size(296,116) → right-mid large button
	var dw = 227.0; var dh = 111.0
	var dx = 1008.0; var dy = 591.0
	app._draw_image(GAL_BTN_DATE, Vector2(dx, dy), Vector2(dw, dh), false, Color(1, 1, 1, 0.92))
	add_gal_label("約會", Vector2(dx + 60, dy + 30), Vector2(107, 50), 24)
	app._add_action_button("", Vector2(dx, dy), app._show_home, Vector2(dw, dh))
	app._draw_red_dot(Vector2(dx + dw - 28, dy + 12))
	# Lock overlay
	app._draw_image(GAL_IMG_LOCK, Vector2(dx, dy), Vector2(dw, dh), false, Color(1, 1, 1, 0.0))

	# btnGoOut: pos(-347,19) size(188,88)
	var gw = 144.0; var gh = 84.0
	var gx = 870.0; var gy = 618.0
	app._draw_image(GAL_BTN_GOOUT, Vector2(gx, gy), Vector2(gw, gh), false, Color(1, 1, 1, 0.90))
	add_gal_label("外出", Vector2(gx + 30, gy + 20), Vector2(85, 45), 22)
	app._add_action_button("", Vector2(gx, gy), app._show_home, Vector2(gw, gh))
	app._draw_red_dot(Vector2(gx + gw - 22, gy + 6))
	app._draw_image(GAL_IMG_LOCK_GO, Vector2(gx, gy), Vector2(gw, gh), false, Color(1, 1, 1, 0.0))

	# btnGift: pos(-535,19) size(88,88)
	var giw = 67.0; var gih = 84.0
	var gix = 803.0; var giy = 618.0
	app._draw_image(GAL_BTN_GIFT, Vector2(gix, giy), Vector2(giw, gih), false, Color(1, 1, 1, 0.90))
	add_gal_label("禮物", Vector2(gix, giy + 62), Vector2(giw, 22), 14)
	app._add_action_button("", Vector2(gix, giy), app._show_home, Vector2(giw, gih))

	# btnFile: pos(-623,19) size(88,88)
	var fw = 67.0; var fh = 84.0
	var fx = 735.0; var fy = 618.0
	app._draw_image(GAL_BTN_FILE, Vector2(fx, fy), Vector2(fw, fh), false, Color(1, 1, 1, 0.90))
	add_gal_label("檔案", Vector2(fx, fy + 62), Vector2(fw, 22), 14)
	app._add_action_button("", Vector2(fx, fy), app._show_home, Vector2(fw, fh))


func draw_side_buttons() -> void:
	var sw = 75.0; var sh = 94.0
	var sx = 1144.0

	# btnPhotoAlbum: pos(-79,193) → above
	var ay = 441.0
	app._draw_image(GAL_BTN_ALBUM, Vector2(sx, ay), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, ay + 82), Vector2(107, 28), false, Color(1, 1, 1, 0.72))
	add_gal_label("相冊", Vector2(sx - 18, ay + 82), Vector2(107, 28), 14)
	app._add_action_button("", Vector2(sx, ay), app._show_home, Vector2(sw, sh))
	app._draw_red_dot(Vector2(sx + sw - 20, ay + 8))

	# btnMemories: pos(-79,323) → below
	var my = 316.0
	app._draw_image(GAL_BTN_MEM, Vector2(sx, my), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	app._draw_image(GAL_IMG_LABEL_BG, Vector2(sx - 18, my + 82), Vector2(107, 28), false, Color(1, 1, 1, 0.72))
	add_gal_label("回憶", Vector2(sx - 18, my + 82), Vector2(107, 28), 14)
	app._add_action_button("", Vector2(sx, my), app._show_home, Vector2(sw, sh))
	app._draw_red_dot(Vector2(sx + sw - 20, my + 8))


func draw_hide_button() -> void:
	# btnHide: pos(-196,129) size(90,90) anchor(0.5,0.5)
	var hw = 69.0; var hh = 86.0
	var hx = 455.0; var hy = 442.0
	app._draw_image(GAL_BTN_HIDE, Vector2(hx, hy), Vector2(hw, hh), false, Color(1, 1, 1, 0.70))
	app._add_action_button("", Vector2(hx, hy), app._show_home, Vector2(hw, hh))


func draw_role_selector() -> void:
	# pnlRoleList: anchor(0,0.5) pos(-9,-250) size(110,110)
	var rw = 84.0; var rh = 106.0
	var rx = 4.0; var ry = 82.0

	# btnChange: gal_img_06 background
	app._draw_image(GAL_IMG_ROLE_BG, Vector2(rx, ry), Vector2(rw, rh), false, Color(1, 1, 1, 0.88))

	# imgHead: transparent placeholder (100x100 → 77×96)
	var head_w = 77.0; var head_h = 96.0
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240037)))
	if hero:
		var tex = app._hero_portrait_texture(hero)
		if tex != null:
			var rect = TextureRect.new()
			rect.texture = tex
			rect.position = Vector2(rx + 4, ry + 5)
			rect.size = Vector2(head_w, head_h)
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			rect.clip_contents = true
			app._view_container().add_child(rect)

	# Change icon (gal_btn_11, 50×50 → 38×48)
	app._draw_image(GAL_BTN_CHANGE_ICON, Vector2(rx + rw - 28, ry + rh - 30), Vector2(38, 48), false, Color(1, 1, 1, 0.90))

	app._add_action_button("", Vector2(rx, ry), app._show_home, Vector2(rw, rh))
	app._draw_red_dot(Vector2(rx + rw - 14, ry + 4))


# ── Helper ──
func add_gal_label(text: String, pos: Vector2, text_size: Vector2, font_size: int) -> Label:
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
