# UTF-8 source. MainUIView - refactored from prefab + IL analysis.
# States: main_normal | wallpaper_focus | gal_entry
# listPanel = [pnlChat, pnlFunny, pnlPlayerInfo, pnlCommercialization, btnChapterInfo, pnlBottom]
# ShowOrHide() toggles listPanel + TopBar + btnBodyMask + btnEye/btnChange
extends RefCounted

const BAKED_SPINE_CANVAS := preload("res://scripts/spine_baked_preview_canvas.gd")
const MAINUI_FX_CANVAS := preload("res://scripts/mainui_fx_canvas.gd")

# ── Sprite constants ──
const UI_MAIN_BG = "res://assets/ui/background/mainui_bg_01.png"   # 1670x750 fullscreen wallpaper
const UI_MAIN_PLAYER_FRAME = "res://assets/ui/mainui/mainui_img_02.png"
const UI_MAIN_AVATAR_RING = "res://assets/ui/mainui/mainui_img_03.png"
const UI_MAIN_EXP_RING = "res://assets/ui/mainui/mainui_img_04.png"
const UI_MAIN_BANNER = "res://assets/ui/mainui/mainui_img_05.png"
const UI_MAIN_DOT_ON = "res://assets/ui/mainui/mainui_img_06.png"
const UI_MAIN_DOT_OFF = "res://assets/ui/mainui/mainui_img_07.png"
const UI_MAIN_TOP_RES_BG = "res://assets/ui/mainui/mainui_img_09.png"
const UI_MAIN_BOTTOM_BG = "res://assets/ui/mainui/mainui_img_10.png"
const UI_MAIN_SEPARATOR = "res://assets/ui/mainui/mainui_img_11.png"
const UI_MAIN_ASSIST = "res://assets/ui/mainui/mainui_img_19.png"
const UI_MAIN_POWER_ICON = "res://assets/ui/mainui/mainui_img_32.png"
const UI_MAIN_STORY_PROGRESS = "res://assets/ui/mainui/mainui_img_34.png"
const UI_MAIN_STORY_BG = "res://assets/ui/mainui/mainui_txt_01.png"
const UI_MAIN_FUNNY_ARENA = "res://assets/ui/mainui/mainui_txt_03.png"
const UI_MAIN_FUNNY_PRAYER = "res://assets/ui/mainui/mainui_txt_06.png"
const UI_MAIN_FUNNY_ADVENTURE = "res://assets/ui/mainui/mainui_txt_02.png"
const UI_MAIN_FUNNY_DRAW = "res://assets/ui/mainui/mainui_txt_05.png"
const UI_MAIN_CHAPTER_BG = "res://assets/ui/mainui/mainui_img_35.png"
const UI_MAIN_CHAT_BG = "res://assets/ui/mainui/mainui_btn_04.png"
const UI_MAIN_GAL = "res://assets/ui/mainui/mainui_btn_25.png"
const UI_MAIN_MENU = "res://assets/ui/mainui/mainui_btn_11.png"
const UI_MAIN_AUTO_FIGHT = "res://assets/ui/mainui/mainui_img_36.png"
const UI_MAIN_HOOK_TIME_BG = "res://assets/ui/mainui/mainui_img_08.png"    # imgHookTime plate
const UI_MAIN_FULLSCREEN_OVERLAY = "res://assets/ui/mainui/mainui_img_44.png"
const UI_MAIN_REWARD_FRAME = "res://assets/ui/mainui/mainui_img_45.png"
const UI_MAIN_BTN_EYE = "res://assets/ui/mainui/mainui_btn_12.png"       # btnEye
const UI_MAIN_BTN_CHANGE = "res://assets/ui/mainui/mainui_btn_13.png"    # btnChange
const UI_MAIN_BTN_HARVEST = "res://assets/ui/mainui/mainui_img_18.png"   # btnHarvest
const UI_HERO_MASK = "res://assets/ui/hero/hero_img_253.png"
const UI_WALLPAPER_ARROW = "res://assets/ui/wallpaper/wallpaper_btn_01.png"
const UI_WALLPAPER_PLAY = "res://assets/ui/wallpaper/wallpaper_btn_02.png"
const UI_WALLPAPER_PAUSE = "res://assets/ui/wallpaper/wallpaper_btn_16_1.png"
const UI_WALLPAPER_PAUSE_FX = "res://assets/ui/wallpaper/wallpaper_btn_16_2.png"
const UI_ITEM_TICKET = "res://assets/ui/item/draw_07.png"
const UI_ITEM_GEM = "res://assets/ui/item/draw_05.png"
const UI_MAIN_CHARGE_ICONS = [
	"res://assets/ui/mainui/mainui_btn_06.png",   # btnActivity 活动
	"res://assets/ui/mainui/mainui_btn_07.png",   # btnWelfare 福利
	"res://assets/ui/mainui/mainui_btn_10.png",   # btnCard 月卡
	"res://assets/ui/mainui/mainui_btn_08.png",   # btnCharge 充值
	"res://assets/ui/mainui/mainui_btn_09.png"    # btnShop 商店
]
const UI_MAIN_LIMIT_ICONS = [
	"res://assets/ui/mainui/mainui_btn_15.png",
	"res://assets/ui/mainui/mainui_btn_16.png",
	"res://assets/ui/mainui/mainui_btn_17.png",
	"res://assets/ui/mainui/mainui_btn_20.png",
	"res://assets/ui/mainui/mainui_btn_18.png",
	"res://assets/ui/mainui/mainui_btn_19.png"
]
const UI_MAIN_LIMIT_QUESTION = "res://assets/ui/mainui/mainui_btn_21.png"
const UI_MAIN_LIMIT_PRESENT = "res://assets/ui/mainui/mainui_btn_22.png"
const UI_MAIN_LIMIT_BURY_GIFT = "res://assets/ui/mainui/mainui_btn_23.png"
const UI_MAIN_LIMIT_DISCOUNT = "res://assets/ui/mainui/mainui_btn_24.png"

const MAINUI_PLAYER_INFO_POS := Vector2(0, 5)
const MAINUI_FUNNY_CONTENT_POS := Vector2(972, 629)
const MAINUI_STORY_POS := Vector2(1332, 633)
const MAINUI_CHARGE_POS := Vector2(1457, 148)
const MAINUI_COMMERCIAL_POS := Vector2(57, 123)
const MAINUI_CHAPTER_POS := Vector2(1360, 500)
const MAINUI_BOTTOM_POS := Vector2(64, 676)
const MAINUI_CHAT_POS := Vector2(1196, 94)

var app
var _main_state: String = "normal"
var _main_panels: Array = []

func _init(app_ref) -> void:
	app = app_ref


func _main_prefab_size(prefab_size: Vector2) -> Vector2:
	return prefab_size


func _main_centered_rect(prefab_center: Vector2, prefab_size: Vector2) -> Rect2:
	var size := _main_prefab_size(prefab_size)
	var center := Vector2(835.0 + prefab_center.x, 375.0 - prefab_center.y)
	return Rect2(center - size * 0.5, size)


func _main_left_top_rect(prefab_pos: Vector2, prefab_size: Vector2) -> Rect2:
	var size := _main_prefab_size(prefab_size)
	return Rect2(Vector2(prefab_pos.x, -prefab_pos.y), size)


func _main_right_top_center_rect(prefab_center: Vector2, prefab_size: Vector2) -> Rect2:
	var size := _main_prefab_size(prefab_size)
	var center := Vector2(1670.0 + prefab_center.x, -prefab_center.y)
	return Rect2(center - size * 0.5, size)


func _main_right_top_rect(prefab_pos: Vector2, prefab_size: Vector2) -> Rect2:
	var size := _main_prefab_size(prefab_size)
	var top_right := Vector2(1670.0 + prefab_pos.x, -prefab_pos.y)
	return Rect2(Vector2(top_right.x - size.x, top_right.y), size)


func _main_right_bottom_rect(prefab_pos: Vector2, prefab_size: Vector2) -> Rect2:
	var size := _main_prefab_size(prefab_size)
	var bottom_right := Vector2(1670.0 + prefab_pos.x, 750.0 - prefab_pos.y)
	return Rect2(bottom_right - size, size)


func add_hit_button(pos: Vector2, hit_size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.position = pos
	button.size = hit_size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		app._play_sfx(app.AUDIO_SFX_UI_MAIN, 0.72)
		callback.call()
	)
	app._view_container().add_child(button)
	return button


func add_ui_text(text: String, pos: Vector2, text_size: Vector2, font_size: int, align := HORIZONTAL_ALIGNMENT_CENTER, color := Color(0.96, 0.91, 0.84, 1.0)) -> Label:
	var label: Label = app._label(text, font_size, align)
	label.position = pos
	label.size = text_size
	label.modulate = color
	app._view_container().add_child(label)
	return label


func add_scaled_image(path: String, pos: Vector2, draw_size: Vector2, tint := Color(1, 1, 1, 1)) -> TextureRect:
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		return null
	image.resize(int(draw_size.x), int(draw_size.y), Image.INTERPOLATE_LANCZOS)
	var texture := ImageTexture.create_from_image(image)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate = tint
	app._view_container().add_child(rect)
	return rect


func draw_baked_spine_layer(path: String, clip: String, rect: Rect2, tint := Color(1, 1, 1, 1)) -> Control:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var canvas: Control = BAKED_SPINE_CANVAS.new()
	canvas.position = rect.position
	canvas.size = rect.size
	canvas.modulate = tint
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app._view_container().add_child(canvas)
	canvas.set_baked_path(path, clip)
	return canvas


func draw_mainui_fx(kind: String, pos: Vector2, draw_size: Vector2, alpha := 1.0) -> Control:
	var fx: Control = MAINUI_FX_CANVAS.new()
	fx.position = pos
	fx.size = draw_size
	fx.modulate.a = alpha
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app._view_container().add_child(fx)
	fx.set_kind(kind)
	return fx


# ═══════════════════════════════════════════════════════════════
# State machine
# ═══════════════════════════════════════════════════════════════

func show_home() -> void:
	app.current_view = "main"
	app._set_chrome_visible(false)
	app._clear("主界面")
	_main_panels.clear()
	enter_normal_state()

func enter_normal_state() -> void:
	_main_state = "normal"
	# 不再调 _clear — show_home 已经做了
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))
	# Layer 0: Wallpaper (always below everything)
	draw_wallpaper(hero)
	# Layer 1: Full-screen transparent button (wallpaper toggle)
	draw_body_mask()
	# Layer 1b: Fullscreen overlay (mainui_img_44)
	draw_fullscreen_overlay()
	# Layer 2: TopBar (full-width, 12px from top, h=60→58)
	draw_top_bar()
	# Layer 3: pnlPlayerInfo (top-left, 354×113→271×108)
	draw_player_info(hero)
	# Layer 4: pnlFunny sub-panels
	draw_funny_content()    # 4 buttons 88×102 at right
	draw_story_harvest()    # pnlStory row
	draw_charge_column()    # pnlCharge vertical
	draw_menu_button()      # btnMenu corner
	draw_assist_button()    # btnAssist helper entry
	# Layer 5: pnlCommercialization (left-mid)
	draw_commercialization()
	# Layer 6: btnChapterInfo (right-mid)
	draw_chapter_info()
	# Layer 7: pnlBottom (bottom bar)
	draw_bottom_bar()
	# Layer 8: btnGal (independent, protruding upward)
	draw_gal_button()
	# Layer 9: pnlChat (right-bottom corner)
	draw_chat_bar()


func enter_wallpaper_focus() -> void:
	_main_state = "wallpaper_focus"
	app._clear("壁纸")
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))
	draw_wallpaper(hero)
	draw_wallpaper_control_bar()


func draw_wallpaper_control_bar() -> void:
	# @WallpaperPanel/pnlCtl: prefab center pos(0,-181), left/right/pause original sprites.
	var ctl := _main_centered_rect(Vector2(0, -181), Vector2(68, 68))
	var center := ctl.position + ctl.size * 0.5
	var settings: Dictionary = app.save.get("settings", {})
	add_hit_button(Vector2(0, 0), app.CANVAS_SIZE, enter_normal_state)
	var left_rect := _main_centered_rect(Vector2(-73, -181), Vector2(92, 50))
	var right_rect := _main_centered_rect(Vector2(73, -181), Vector2(92, 50))
	app._draw_image(UI_WALLPAPER_ARROW, left_rect.position, left_rect.size, false, Color(1, 1, 1, 0.94))
	var right_icon: TextureRect = app._draw_image(UI_WALLPAPER_ARROW, right_rect.position, right_rect.size, false, Color(1, 1, 1, 0.94))
	if right_icon != null:
		right_icon.flip_h = true
	var pause_rect := Rect2(center - Vector2(34, 34), Vector2(68, 68))
	var is_playing := bool(settings.get("wallpaper_auto_play", true))
	app._draw_image(UI_WALLPAPER_PAUSE if is_playing else UI_WALLPAPER_PLAY, pause_rect.position, pause_rect.size, false, Color(1, 1, 1, 0.95))
	if is_playing:
		app._draw_image(UI_WALLPAPER_PAUSE_FX, pause_rect.position, pause_rect.size, false, Color(1, 1, 1, 0.50))
	add_hit_button(left_rect.position, left_rect.size, func() -> void: _cycle_wallpaper(-1))
	add_hit_button(right_rect.position, right_rect.size, func() -> void: _cycle_wallpaper(1))
	add_hit_button(pause_rect.position, pause_rect.size, func() -> void: _toggle_wallpaper_auto_play())


func _wallpaper_candidates() -> Array:
	var candidates: Array = app._gallery_filtered_heroes()
	return candidates if not candidates.is_empty() else app.heroes


func _selected_wallpaper_index(candidates: Array) -> int:
	var selected_id := int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID))
	for index in range(candidates.size()):
		var hero: Dictionary = candidates[index]
		if int(hero.get("id", 0)) == selected_id:
			return index
	return 0


func _cycle_wallpaper(offset: int) -> void:
	var candidates := _wallpaper_candidates()
	if candidates.is_empty():
		return
	var next_index := posmod(_selected_wallpaper_index(candidates) + offset, candidates.size())
	var hero: Dictionary = candidates[next_index]
	app.save["selected_hero_id"] = int(hero.get("id", app.DEFAULT_HERO_ID))
	app._persist()
	enter_wallpaper_focus()


func _toggle_wallpaper_auto_play() -> void:
	var settings: Dictionary = app.save.get("settings", {})
	settings["wallpaper_auto_play"] = not bool(settings.get("wallpaper_auto_play", true))
	app.save["settings"] = settings
	app._persist()
	enter_wallpaper_focus()


func enter_gal_entry() -> void:
	app._show_gal()


# ═══════════════════════════════════════════════════════════════
# Drawing functions - main_normal layers
# ═══════════════════════════════════════════════════════════════

func draw_wallpaper(hero: Dictionary) -> void:
	# Prefab: @WallpaperPanel anchor=(0.5,0.5) 1668x750 → fullscreen scaled
	app._draw_image(UI_MAIN_BG, Vector2(0, 0), app.CANVAS_SIZE, true)
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.012, 0.010, 0.008, 0.05)))
	draw_interactive_role(hero, Vector2(390, 82), Vector2(560, 620))


func draw_interactive_role(hero: Dictionary, pos: Vector2, draw_size: Vector2) -> void:
	# MainUIView prefab: irole/spBg -> spHero -> spFg -> imgMask.
	var role_rect := Rect2(pos, draw_size)
	var spine_key := _hero_spine_key(hero)
	var drew_any := false
	if not spine_key.is_empty():
		drew_any = _draw_spine_role_layer(spine_key, "bg", role_rect, Color(1, 1, 1, 0.84)) or drew_any
		drew_any = _draw_spine_role_layer(spine_key, "base", role_rect, Color(1, 1, 1, 0.98)) or drew_any
		drew_any = _draw_spine_role_layer(spine_key, "fg", role_rect, Color(1, 1, 1, 0.92)) or drew_any
	if not drew_any:
		app._draw_hero_stage(hero, pos, draw_size, false)
	var mask_size := Vector2(324, 274)
	var mask_pos := pos + draw_size * 0.5 - mask_size * 0.5
	app._draw_image(UI_HERO_MASK, mask_pos, mask_size, false, Color(1, 1, 1, 0.22))


func _hero_spine_key(hero: Dictionary) -> String:
	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		var parts := resource_path.split("/")
		if parts.size() > 0:
			return str(parts[parts.size() - 1])
	var spine := str(hero.get("spine", ""))
	if spine.find("|") >= 0:
		spine = spine.split("|")[0]
	return spine


func _draw_spine_role_layer(spine_key: String, layer: String, rect: Rect2, tint: Color) -> bool:
	var baked_path := _first_existing_path(_spine_layer_baked_candidates(spine_key, layer))
	if not baked_path.is_empty():
		draw_baked_spine_layer(baked_path, "wait", rect, tint)
		return true
	var png_path := _first_existing_path(_spine_layer_png_candidates(spine_key, layer))
	if not png_path.is_empty():
		return _draw_spine_png_layer(png_path, rect, tint) != null
	if layer == "base":
		print("[mainui] irole base missing for spine: %s" % spine_key)
	return false


func _spine_layer_baked_candidates(spine_key: String, layer: String) -> Array:
	var layer_key := spine_key
	if layer != "base":
		layer_key = "%s_%s" % [spine_key, layer]
	var candidates := []
	if layer == "base":
		candidates.append("res://assets/spine/%s/%s.baked.json" % [spine_key, spine_key])
		candidates.append("res://assets/spine/Hero__%s/Hero__%s.baked.json" % [spine_key, spine_key])
	else:
		candidates.append("res://assets/spine/%s/%s.baked.json" % [spine_key, layer_key])
		candidates.append("res://assets/spine/Hero__%s__%s/Hero__%s__%s.baked.json" % [spine_key, layer_key, spine_key, layer_key])
	return candidates


func _spine_layer_png_candidates(spine_key: String, layer: String) -> Array:
	var layer_key := spine_key
	if layer != "base":
		layer_key = "%s_%s" % [spine_key, layer]
	var candidates := []
	if layer == "base":
		candidates.append("res://assets/spine/%s/%s.png" % [spine_key, spine_key])
		candidates.append("res://assets/spine/Hero__%s/%s.png" % [spine_key, spine_key])
	else:
		candidates.append("res://assets/spine/%s/%s.png" % [spine_key, layer_key])
		candidates.append("res://assets/spine/Hero__%s__%s/%s.png" % [spine_key, layer_key, layer_key])
	return candidates


func _first_existing_path(candidates: Array) -> String:
	for raw_path in candidates:
		var path := str(raw_path)
		if FileAccess.file_exists(path):
			return path
	return ""


func _draw_spine_png_layer(path: String, rect: Rect2, tint: Color) -> TextureRect:
	var texture: Texture2D = app._load_png_source_texture(path)
	if texture == null:
		return null
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.position = rect.position
	texture_rect.size = rect.size
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.modulate = tint
	app._view_container().add_child(texture_rect)
	return texture_rect


func draw_body_mask() -> void:
	var mask = Button.new()
	mask.text = ""; mask.flat = true
	mask.position = Vector2(0, 0); mask.size = app.CANVAS_SIZE
	mask.modulate = Color(1, 1, 1, 0.0)
	mask.pressed.connect(enter_wallpaper_focus)
	app._view_container().add_child(mask)


func draw_fullscreen_overlay() -> void:
	# pnlAdapter/Image: mainui_img_44 fullscreen overlay layer
	app._draw_image(UI_MAIN_FULLSCREEN_OVERLAY, Vector2(0, 0), app.CANVAS_SIZE, true, Color(1, 1, 1, 0.12))


func draw_top_bar() -> void:
	# @TopBar/svRes creates TopResGrid-like cells: 200x40 with icon + number.
	var x = 1030.0
	var cell_size := Vector2(200, 40)
	var resources = [
		[UI_MAIN_CHAT_BG, app._unclaimed_mail_count(), app._show_mail],
		[UI_ITEM_TICKET, "%d/50" % clamp(int(app.save.get("tickets", 0)), 0, 50), app._show_shop],
		[UI_ITEM_GEM, app.save.get("gems", 0), app._show_shop]
	]
	for item in resources:
		var bg = app._draw_image(UI_MAIN_TOP_RES_BG, Vector2(x, 14), cell_size, false, Color(1, 1, 1, 0.76))
		_main_panels.append(bg)
		add_scaled_image(str(item[0]), Vector2(x - 5, 9), Vector2(50, 50), Color(1, 1, 1, 0.94))
		add_ui_text(str(item[1]), Vector2(x + 27, 14), Vector2(130, 40), 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.96, 0.92, 0.78))
		add_hit_button(Vector2(x, 14), cell_size, item[2])
		x += 205


func draw_player_info(hero: Dictionary) -> void:
	# pnlPlayerInfo: top-left, pos(0,-5), size 354x113.
	var profile = app.save.get("profile", {})
	var player_rect := Rect2(MAINUI_PLAYER_INFO_POS, Vector2(354, 113))
	var panel = app._draw_image(UI_MAIN_PLAYER_FRAME, player_rect.position, player_rect.size, false, Color(1, 1, 1, 0.94))
	_main_panels.append(panel)
	# imgHeadBg and imgExp are left-middle inside the player panel.
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(64, 14), Vector2(80, 79), false, Color(1, 1, 1, 0.94))
	app._draw_image(UI_MAIN_EXP_RING, Vector2(59, 8), Vector2(90, 90), false, Color(1, 0.84, 0.28, 0.88))
	# Level label
	var lv = app._label("%d" % int(profile.get("level", 1)), 24, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = Vector2(67, 42); lv.size = Vector2(74, 28); lv.modulate = Color(0.96, 0.88, 0.52)
	app._view_container().add_child(lv)
	var level_caption = app._label("LEVEL", 8, HORIZONTAL_ALIGNMENT_CENTER)
	level_caption.position = Vector2(80, 69)
	level_caption.size = Vector2(48, 12)
	level_caption.modulate = Color(0.96, 0.88, 0.52)
	app._view_container().add_child(level_caption)
	# txtName (118,26) 66x28
	var pname = app._label(str(profile.get("name", "Player")), 18)
	pname.position = Vector2(134, 43); pname.size = Vector2(100, 29)
	app._view_container().add_child(pname)
	# txtPower (139,50) 133x32
	app._draw_image(UI_MAIN_POWER_ICON, Vector2(126, 78), Vector2(22, 21), false, Color(1, 1, 1, 0.9))
	var power = app._label("战力 %d" % app._player_power(), 14)
	power.position = Vector2(152, 72); power.size = Vector2(173, 37)
	power.modulate = Color(0.84, 0.74, 0.24)
	app._view_container().add_child(power)
	# btnPlayerInfo (0,13) 271x76
	add_hit_button(Vector2(0, 22), Vector2(354, 79), app._show_player_info)
	# btnChange/btnEye: compact actions beside the player card.
	app._draw_image(UI_MAIN_BTN_CHANGE, Vector2(365, 10), Vector2(74, 74), false, Color(1, 1, 1, 0.92))
	add_ui_text("壁紙", Vector2(367, 72), Vector2(70, 22), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(365, 10), Vector2(74, 86), app._show_wallpaper_select)
	app._draw_image(UI_MAIN_BTN_EYE, Vector2(441, 10), Vector2(74, 74), false, Color(1, 1, 1, 0.92))
	add_ui_text("互動", Vector2(443, 72), Vector2(70, 22), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(441, 10), Vector2(74, 86), enter_wallpaper_focus)


func draw_funny_content() -> void:
	# pnlFunnyContent: bottom-right row, prefab screenshot box x≈972..1331 y≈629..731.
	var actions = [
		[UI_MAIN_FUNNY_ARENA, "競技", app._show_competition],
		[UI_MAIN_FUNNY_PRAYER, "祈願", app._open_prayer_pool],
		[UI_MAIN_FUNNY_ADVENTURE, "冒險", app._show_battle],
		[UI_MAIN_FUNNY_DRAW, "喚靈", app._open_present_pool]
	]
	var bw = 88.0; var bh = 102.0; var gap = 5.0
	var start_x = MAINUI_FUNNY_CONTENT_POS.x
	var by = MAINUI_FUNNY_CONTENT_POS.y
	for item in actions:
		var bg = app._draw_image(str(item[0]), Vector2(start_x, by), Vector2(bw, bh), false, Color(1, 1, 1, 0.84))
		_main_panels.append(bg)
		add_ui_text(str(item[1]), Vector2(start_x, by + 66), Vector2(bw, 28), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		add_hit_button(Vector2(start_x, by), Vector2(bw, bh), item[2])
		app._draw_red_dot(Vector2(start_x + bw - 16, by + 4))
		start_x += bw + gap
	# btnJumpAutoFight above btnAdventure (prefab pos(0,33) size(180,90))
	# 3rd button (冒險): banner is wider than its parent and protrudes upward.
	var adv_x = MAINUI_FUNNY_CONTENT_POS.x + 2 * (bw + gap)
	var auto_x = adv_x - 46
	var auto_y = by - 88
	app._draw_image(UI_MAIN_AUTO_FIGHT, Vector2(auto_x, auto_y), Vector2(180, 90), false, Color(1, 1, 1, 0.88))
	add_ui_text("自動挑戰中...", Vector2(auto_x + 9, auto_y + 18), Vector2(162, 26), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.96, 0.88, 0.52))
	add_ui_text("歷戰尖塔-單隊", Vector2(auto_x + 5, auto_y + 46), Vector2(170, 24), 16, HORIZONTAL_ALIGNMENT_CENTER, Color(0.96, 0.88, 0.52))
	add_hit_button(Vector2(auto_x, auto_y), Vector2(180, 90), app._show_auto_fight)


func draw_story_harvest() -> void:
	# pnlStory: bottom-right big story/hook button.
	var sw = 278.0; var sh = 98.0
	var sx = MAINUI_STORY_POS.x; var sy = MAINUI_STORY_POS.y
	var bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(sx, sy), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	_main_panels.append(bg)
	app._draw_image(UI_MAIN_STORY_PROGRESS, Vector2(sx + 42, sy - 32), Vector2(156, 34), false, Color(1, 1, 1, 0.9))
	add_ui_text("進度：%s" % app._next_task_text(), Vector2(sx + 45, sy - 29), Vector2(150, 24), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.88, 0.52))
	add_ui_text("塵世探秘", Vector2(sx + 114, sy + 26), Vector2(128, 46), 28, HORIZONTAL_ALIGNMENT_CENTER, Color(0.55, 0.48, 0.40))
	# btnHarvest: chest/hook reward button inside pnlStory.
	app._draw_image(UI_MAIN_BTN_HARVEST, Vector2(sx + 14, sy - 5), Vector2(106, 106), false, Color(1, 1, 1, 0.90))
	add_hit_button(Vector2(sx + 14, sy - 5), Vector2(106, 106), app._claim_afk_reward)
	# btnHarvest sub-elements: imgHookTime + txtHookTime
	app._draw_image(UI_MAIN_HOOK_TIME_BG, Vector2(sx + 21, sy + 69), Vector2(92, 20), false, Color(1, 1, 1, 0.82))
	add_ui_text(app._afk_time_display(), Vector2(sx + 21, sy + 69), Vector2(92, 20), 12, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.84, 0.52))
	# btnStory: prefab has transparent overlay button (132×99) covering story area
	add_hit_button(Vector2(sx + 146, sy), Vector2(132, sh), app._show_dust_transition)
	app._draw_red_dot(Vector2(sx + 13, sy - 2))


func draw_charge_column() -> void:
	# pnlCharge: right-side commerce cluster, prefab rect x=1457 y=148 size=158x258.
	var entries = [
		[UI_MAIN_CHARGE_ICONS[3], "儲值", app._show_charge, MAINUI_CHARGE_POS + Vector2(0, 0)],
		[UI_MAIN_CHARGE_ICONS[0], "活動", app._show_activity_center, MAINUI_CHARGE_POS + Vector2(80, 0)],
		[UI_MAIN_CHARGE_ICONS[4], "商店", app._show_shop, MAINUI_CHARGE_POS + Vector2(0, 88)],
		[UI_MAIN_CHARGE_ICONS[1], "福利", app._show_welfare, MAINUI_CHARGE_POS + Vector2(80, 88)],
		[UI_MAIN_CHARGE_ICONS[2], "月卡", app._show_month_card, MAINUI_CHARGE_POS + Vector2(80, 176)]
	]
	for entry in entries:
		var icon = app._draw_image(str(entry[0]), entry[3], Vector2(78, 78), false, Color(1, 1, 1, 0.90))
		_main_panels.append(icon)
		add_ui_text(str(entry[1]), entry[3] + Vector2(0, 58), Vector2(78, 29), 20, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		add_hit_button(entry[3], Vector2(78, 88), entry[2])
		app._draw_red_dot(entry[3] + Vector2(58, 2))


func draw_menu_button() -> void:
	# btnMenu: 78x78 (→60x75), right-top pos(-94,-54)
	var menu_rect := _main_right_top_center_rect(Vector2(-94, -54), Vector2(78, 78))
	var mx = menu_rect.position.x; var my = menu_rect.position.y
	draw_mainui_fx("menu", Vector2(mx - 19, my - 19), menu_rect.size + Vector2(38, 38), 0.78)
	app._draw_image(UI_MAIN_MENU, Vector2(mx - 8, my - 8), Vector2(76, 76), false, Color(1, 0.78, 0.34, 0.24))
	app._draw_image(UI_MAIN_MENU, Vector2(mx - 6, my - 6), Vector2(72, 72), false, Color(1, 1, 1, 0.30))
	app._draw_image(UI_MAIN_MENU, Vector2(mx, my), menu_rect.size, false, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(mx, my), menu_rect.size, app._show_home_menu)
	app._draw_red_dot(Vector2(mx + 46, my + 4))


func draw_assist_button() -> void:
	# btnAssist: 78x96 (→60x92), left pos(413,-164)
	# Godot: x = 413*0.7665 = 317, y = 164*0.96 = 157
	app._draw_image(UI_MAIN_ASSIST, Vector2(317, 157), Vector2(60, 74), false, Color(1, 1, 1, 0.84))
	add_ui_text("小助手", Vector2(298, 220), Vector2(98, 20), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(317, 157), Vector2(60, 92), app._show_assist)


func draw_commercialization() -> void:
	# pnlCommercialization: banner + 4-column LimitIconView grid from MainUIView.
	var px = MAINUI_COMMERCIAL_POS.x; var py = MAINUI_COMMERCIAL_POS.y
	# @pnlAlternate: 301x108 banner.
	app._draw_image(UI_MAIN_BANNER, Vector2(px, py), Vector2(301, 108), false, Color(1, 1, 1, 0.92))
	for dot_index in range(3):
		var dot_path = UI_MAIN_DOT_ON if dot_index == 0 else UI_MAIN_DOT_OFF
		app._draw_image(dot_path, Vector2(px + 212 + dot_index * 16, py + 88), Vector2(12, 12), false, Color(1, 1, 1, 0.90))
	# pnlGift: 409x300 grid below banner.
	var gx = px + 7; var gy = py + 120
	var gifts = [
		[UI_MAIN_LIMIT_ICONS[0], "喚靈福利", "4d01h", app._show_welfare],
		[UI_MAIN_LIMIT_ICONS[2], "幻海邀約", "6d01h", enter_gal_entry],
		[UI_MAIN_LIMIT_ICONS[1], "簽到福利", "", app._show_welfare],
		[UI_MAIN_LIMIT_ICONS[4], "新服慶典", "11d01h", app._show_activity_center],
		[UI_MAIN_LIMIT_ICONS[5], "交流大廳", "", app._show_chat],
		[UI_MAIN_LIMIT_ICONS[3], "開服沖榜", "7d01h", app._show_activity_center],
		[UI_MAIN_LIMIT_ICONS[4], "限時皮膚", "11d01h", app._show_shop],
		[UI_MAIN_LIMIT_ICONS[5], "露箔閃光", "11d01h", app._show_shop],
		[UI_MAIN_LIMIT_ICONS[5], "首儲", "", app._show_charge],
		[UI_MAIN_LIMIT_PRESENT, "萬象喚靈", "4d01h", app._open_present_pool],
		[UI_MAIN_LIMIT_BURY_GIFT, "周末企劃", "1d01h", app._show_tasks],
		[UI_MAIN_LIMIT_ICONS[1], "神域饋贈", "11d01h", app._show_welfare],
		[UI_MAIN_LIMIT_QUESTION, "問卷", "可領取", app._show_welfare],
		[UI_MAIN_LIMIT_BURY_GIFT, "埋點禮包", "", app._show_welfare],
		[UI_MAIN_LIMIT_DISCOUNT, "折扣禮包", "", app._show_shop]
	]
	var gsx = gx; var gsy = gy; var gi = 0
	for gift in gifts:
		add_scaled_image(str(gift[0]), Vector2(gsx, gsy), Vector2(86, 86), Color(1, 1, 1, 0.94))
		add_ui_text(str(gift[1]), Vector2(gsx, gsy + 55), Vector2(86, 24), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.96))
		if not str(gift[2]).is_empty():
			add_ui_text(str(gift[2]), Vector2(gsx, gsy + 73), Vector2(86, 22), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.80, 0.28))
		add_hit_button(Vector2(gsx, gsy), Vector2(86, 86), gift[3])
		if gi in [2, 4, 8, 10]:
			app._draw_red_dot(Vector2(gsx + 66, gsy + 2))
		gi += 1; gsx += 102
		if gi % 4 == 0:
			gsx = gx; gsy += 96
		if gi >= 12:
			gsx = gx + float(gi - 12) * 102.0
			gsy = gy + 3.0 * 96.0


func draw_chapter_info() -> void:
	# btnChapterInfo: screenshot/prefab box x=1360 y=500 size=276x100.
	var chapter_rect := Rect2(MAINUI_CHAPTER_POS, Vector2(276, 100))
	var px = chapter_rect.position.x; var py = chapter_rect.position.y
	var state: Dictionary = app._current_chapter_state()
	var chapter: Dictionary = state.get("chapter", {})
	var chapter_title := "第%d章 %s %d/%d" % [
		int(state.get("chapter_index", 1)),
		app._chapter_display_name(chapter, int(state.get("chapter_index", 1))),
		int(state.get("completed", 0)),
		int(state.get("stage_count", 1))
	]
	var rewards: Array = app._chapter_reward_items(chapter)
	var bg = app._draw_image(UI_MAIN_CHAPTER_BG, Vector2(px, py), chapter_rect.size, false, Color(1, 1, 1, 0.90))
	_main_panels.append(bg)
	add_ui_text(chapter_title, Vector2(px + 22, py + 9), Vector2(220, 20), 14, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.90, 0.62))
	var rx = px + 25.0
	for reward in rewards.slice(0, min(rewards.size(), 3)):
		var reward_item: Dictionary = reward
		app._draw_image(UI_MAIN_REWARD_FRAME, Vector2(rx - 2, py + 34), Vector2(46, 56), false, Color(1, 1, 1, 0.78))
		add_scaled_image(str(reward_item.get("icon", UI_ITEM_TICKET)), Vector2(rx + 4, py + 43), Vector2(34, 34), Color(1, 1, 1, 0.96))
		add_ui_text(str(reward_item.get("count", "")), Vector2(rx + 12, py + 66), Vector2(30, 14), 9, HORIZONTAL_ALIGNMENT_RIGHT, Color(1, 1, 1, 0.95))
		rx += 50
	add_hit_button(Vector2(px, py), chapter_rect.size, app._show_dust_transition)
	if not app._afk_claimed_today() or int(state.get("completed", 0)) < int(state.get("stage_count", 1)):
		app._draw_red_dot(Vector2(px + 8, py + 4))


func draw_bottom_bar() -> void:
	# pnlBottom: bottom-left, pos(64,49), height 50.
	var bar_y = MAINUI_BOTTOM_POS.y; var bar_h = 50.0
	var bar_width = 115.0 + 6.0 * 86.0
	var bar = app._draw_image(UI_MAIN_BOTTOM_BG, MAINUI_BOTTOM_POS, Vector2(bar_width, bar_h), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bar)
	# 6 buttons: after the enlarged Gal portal.
	# 繁體中文: via lang_extra.bytes UI1000001-UI1000013
	var buttons = [
		["幻靈", app._show_remnants_list, true],
		["背包", app._show_bag, false],
		["遺器", app._show_relics, false],
		["養成", app._show_develop, true],
		["任務", app._show_tasks, true],
		["公會", app._show_guild, false]
	]
	var bw = 86.0; var bx = MAINUI_BOTTOM_POS.x + 115.0
	for item in buttons:
		add_ui_text(str(item[0]), Vector2(bx + 8, bar_y + 10), Vector2(70, 30), 22, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.92))
		add_hit_button(Vector2(bx, bar_y), Vector2(bw, bar_h), item[1])
		app._draw_image(UI_MAIN_SEPARATOR, Vector2(bx, bar_y + 16), Vector2(2, 18), false, Color(1, 1, 1, 0.55))
		if item[2]:
			app._draw_red_dot(Vector2(bx + 64, bar_y + 2))
		bx += bw


func draw_gal_button() -> void:
	# btnGal: 115x129 protrudes 79px upward from pnlBottom.
	var gx = MAINUI_BOTTOM_POS.x
	var gy = MAINUI_BOTTOM_POS.y + 50.0 - 129.0
	draw_mainui_fx("gal", Vector2(gx + 7, gy + 62), Vector2(100, 76), 0.90)
	add_scaled_image(UI_MAIN_GAL, Vector2(gx - 17, gy - 41), Vector2(150, 170), Color(1, 1, 1, 0.94))
	add_ui_text("現世", Vector2(gx + 22, gy + 82), Vector2(70, 30), 24, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.96))
	add_hit_button(Vector2(gx, gy), Vector2(115, 129), enter_gal_entry)
	add_hit_button(Vector2(gx + 8, gy + 74), Vector2(100, 100), enter_gal_entry)
	app._draw_red_dot(Vector2(gx + 90, gy + 4))


func draw_chat_bar() -> void:
	# pnlChat: right-anchored prefab box x=1196 y=94 size=410x40.
	var chat_rect := Rect2(MAINUI_CHAT_POS, Vector2(410, 40))
	var cx = chat_rect.position.x; var cy = chat_rect.position.y
	var bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), chat_rect.size, false, Color(1, 1, 1, 0.72))
	_main_panels.append(bg)
	var chat = app._label("[世界] 塵世：?", 14)
	chat.position = Vector2(cx + 64, cy); chat.size = Vector2(341, 40)
	chat.modulate = Color(0.54, 0.92, 0.54)
	app._view_container().add_child(chat)
	add_hit_button(Vector2(cx, cy), chat_rect.size, app._show_chat)


# ═══════════════════════════════════════════════════════════════
# Hero portrait utility
# ═══════════════════════════════════════════════════════════════

func draw_cover_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint: Color) -> void:
	var texture = app._hero_portrait_texture(hero)
	if texture == null: return
	var rect = TextureRect.new()
	rect.texture = texture; rect.position = pos; rect.size = draw_size
	rect.clip_contents = true
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.modulate = tint
	app._view_container().add_child(rect)
