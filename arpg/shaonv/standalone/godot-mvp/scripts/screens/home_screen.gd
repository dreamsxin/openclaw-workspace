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
const UI_WALLPAPER_SPEAK = "res://assets/ui/hero/hero_img_219.png"
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
const WALLPAPER_ROLE_SIZE := Vector2(957.5, 750.0)
const WALLPAPER_TOUCH_SIZE := Vector2(418.2, 804.2)
const WALLPAPER_SPEAK_SIZE := Vector2(668.0, 154.0)
const WALLPAPER_SPEAK_TEXT_SIZE := Vector2(585.0, 72.0)
const WALLPAPER_SPEAK_DURATION := 3.0
const WALLPAPER_CTL_AUTO_HIDE := 5.0
const WALLPAPER_RETURN_HOTZONE := Rect2(0, 0, 96, 96)
const WALLPAPER_TOUCH_LINES := [
	"交流嘛，遇到好说话的，那自然好;遇到不好说话的，就用枪械捅他几个透明窟窿，消消火气。",
	"今天的看板值守已经开始了。",
	"要出发吗？我会跟上。",
	"这里交给我，你可以放心。"
]

var app
var _main_state: String = "normal"
var _main_panels: Array = []
var _wallpaper_focus_state := "focus_idle"
var _wallpaper_speak_text := ""
var _wallpaper_touch_token := 0
var _wallpaper_ctl_token := 0

func _init(app_ref) -> void:
	app = app_ref


func _configured_group(group_name: String) -> Array:
	return app._mainui_group(group_name)


func _configured_entry(entry_id: String) -> Dictionary:
	return app._mainui_entry_by_id(entry_id)


func _entry_callback(entry_id: String, fallback: Callable) -> Callable:
	var entry := _configured_entry(entry_id)
	if entry.is_empty():
		return fallback
	return app._mainui_entry_callable(entry)


func _draw_entry_red_dot(entry: Dictionary, pos: Vector2) -> void:
	if entry.is_empty():
		return
	if app._mainui_red_dot_active(str(entry.get("red_dot_key", "")), str(entry.get("id", ""))):
		app._draw_red_dot(pos)


func _entry_timer(entry: Dictionary, fallback := "") -> String:
	if entry.is_empty():
		return fallback
	var timer: String = app._mainui_entry_timer(entry)
	return timer if not timer.is_empty() else fallback


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


func add_hit_button(pos: Vector2, hit_size: Vector2, callback: Callable, play_click := true) -> Button:
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.position = pos
	button.size = hit_size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		if play_click:
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
	_wallpaper_focus_state = "focus_idle"
	_wallpaper_speak_text = ""
	_wallpaper_touch_token += 1
	_wallpaper_ctl_token += 1
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
	_wallpaper_focus_state = "focus_idle"
	_wallpaper_speak_text = ""
	_wallpaper_touch_token += 1
	_wallpaper_ctl_token += 1
	_draw_wallpaper_focus()


func _draw_wallpaper_focus() -> void:
	app._clear("壁纸")
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))
	var role_rect := _wallpaper_role_rect(true)
	draw_wallpaper(hero, true)
	add_hit_button(Vector2(0, 0), app.CANVAS_SIZE, _on_wallpaper_body_click)
	draw_wallpaper_role_hit(hero, role_rect)
	draw_wallpaper_return_hotzone()
	if _wallpaper_focus_state == "focus_ctl":
		draw_wallpaper_control_bar()


func _exit_wallpaper_focus() -> void:
	_wallpaper_speak_text = ""
	_wallpaper_touch_token += 1
	_wallpaper_ctl_token += 1
	_wallpaper_focus_state = "focus_idle"
	app._clear("主界面")
	_main_panels.clear()
	enter_normal_state()


func is_wallpaper_focus() -> bool:
	return _main_state == "wallpaper_focus"


func handle_wallpaper_back() -> bool:
	if _main_state != "wallpaper_focus":
		return false
	_exit_wallpaper_focus()
	return true


func _on_wallpaper_body_click() -> void:
	if _main_state != "wallpaper_focus":
		return
	_show_wallpaper_control_bar()


func _show_wallpaper_control_bar() -> void:
	if _main_state != "wallpaper_focus":
		return
	_wallpaper_focus_state = "focus_ctl"
	_wallpaper_ctl_token += 1
	var token := _wallpaper_ctl_token
	_draw_wallpaper_focus()
	_hide_wallpaper_control_bar_later(token)


func _hide_wallpaper_control_bar_later(token: int) -> void:
	await app.get_tree().create_timer(WALLPAPER_CTL_AUTO_HIDE).timeout
	if _main_state != "wallpaper_focus" or _wallpaper_focus_state != "focus_ctl" or token != _wallpaper_ctl_token:
		return
	_wallpaper_focus_state = "focus_idle"
	_draw_wallpaper_focus()


func draw_wallpaper_return_hotzone() -> void:
	add_hit_button(WALLPAPER_RETURN_HOTZONE.position, WALLPAPER_RETURN_HOTZONE.size, _exit_wallpaper_focus, false)


func draw_wallpaper_control_bar() -> void:
	# @WallpaperPanel/pnlCtl: prefab center pos(0,-181), left/right/pause original sprites.
	var ctl := _main_centered_rect(Vector2(0, -181), Vector2(68, 68))
	var center := ctl.position + ctl.size * 0.5
	var settings: Dictionary = app.save.get("settings", {})
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
	var candidates := []
	for hero in app.heroes:
		var item: Dictionary = hero
		if _has_local_wallpaper_asset(item):
			candidates.append(item)
	return candidates if not candidates.is_empty() else app.heroes


func _has_local_wallpaper_asset(hero: Dictionary) -> bool:
	var spine_key := _hero_spine_key(hero)
	if not spine_key.is_empty():
		for layer in ["base", "bg", "fg"]:
			if not _first_existing_path(_spine_layer_baked_candidates(spine_key, layer)).is_empty():
				return true
			if not _first_existing_path(_spine_layer_png_candidates(spine_key, layer)).is_empty():
				return true
	var portrait_path := str(hero.get("portraitResource", ""))
	if not portrait_path.is_empty() and FileAccess.file_exists(app._godot_resource_path(portrait_path)):
		return true
	return false


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
	_wallpaper_speak_text = ""
	_wallpaper_touch_token += 1
	_wallpaper_focus_state = "focus_ctl"
	app._persist()
	_show_wallpaper_control_bar()


func _toggle_wallpaper_auto_play() -> void:
	var settings: Dictionary = app.save.get("settings", {})
	settings["wallpaper_auto_play"] = not bool(settings.get("wallpaper_auto_play", true))
	app.save["settings"] = settings
	app._persist()
	_show_wallpaper_control_bar()


func enter_gal_entry() -> void:
	app._show_gal()


# ═══════════════════════════════════════════════════════════════
# Drawing functions - main_normal layers
# ═══════════════════════════════════════════════════════════════

func draw_wallpaper(hero: Dictionary, focus_mode := false) -> void:
	# Prefab: @WallpaperPanel anchor=(0.5,0.5) 1668x750 → fullscreen scaled
	app._draw_image(UI_MAIN_BG, Vector2(0, 0), app.CANVAS_SIZE, true)
	app._view_container().add_child(app._panel(Vector2(0, 0), app.CANVAS_SIZE, Color(0.012, 0.010, 0.008, 0.05)))
	var role_rect := _wallpaper_role_rect(focus_mode)
	draw_interactive_role(hero, role_rect.position, role_rect.size)
	if focus_mode:
		draw_wallpaper_speech(role_rect)


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


func _wallpaper_role_rect(focus_mode: bool) -> Rect2:
	if focus_mode:
		return _main_centered_rect(Vector2(0, 0), WALLPAPER_ROLE_SIZE)
	return Rect2(Vector2(390, 82), Vector2(560, 620))


func _wallpaper_child_centered_rect(parent_rect: Rect2, prefab_center: Vector2, prefab_size: Vector2) -> Rect2:
	var center := parent_rect.position + parent_rect.size * 0.5 + Vector2(prefab_center.x, -prefab_center.y)
	return Rect2(center - prefab_size * 0.5, prefab_size)


func _wallpaper_role_touch_rect(role_rect: Rect2) -> Rect2:
	return _wallpaper_child_centered_rect(role_rect, Vector2(0, 272), WALLPAPER_TOUCH_SIZE)


func _wallpaper_role_core_rect(role_rect: Rect2) -> Rect2:
	var outer := _wallpaper_role_touch_rect(role_rect)
	var core_size := Vector2(outer.size.x * 0.68, outer.size.y * 0.46)
	var core_center := Vector2(outer.position.x + outer.size.x * 0.5, role_rect.position.y + role_rect.size.y * 0.46)
	return Rect2(core_center - core_size * 0.5, core_size)


func draw_wallpaper_role_hit(hero: Dictionary, role_rect: Rect2) -> void:
	var touch_rect := _wallpaper_role_touch_rect(role_rect)
	add_hit_button(touch_rect.position, touch_rect.size, func() -> void:
		var click_pos: Vector2 = app._view_container().get_local_mouse_position()
		if _wallpaper_role_core_rect(role_rect).has_point(click_pos):
			_on_wallpaper_role_touch(hero)
		else:
			app._play_sfx(app.AUDIO_SFX_UI_MAIN, 0.72)
			_show_wallpaper_control_bar()
	, false)


func _on_wallpaper_role_touch(hero: Dictionary) -> void:
	var count := int(app.save.get("mainui_wallpaper_touch_count", 0))
	_wallpaper_speak_text = _wallpaper_touch_line(hero, count)
	_wallpaper_touch_token += 1
	_wallpaper_focus_state = "focus_speak"
	_wallpaper_ctl_token += 1
	app.save["mainui_wallpaper_touch_count"] = count + 1
	app.save["mainui_last_wallpaper_touch"] = int(Time.get_unix_time_from_system())
	app._persist()
	_play_wallpaper_touch_voice(hero, count)
	var token := _wallpaper_touch_token
	_draw_wallpaper_focus()
	_hide_wallpaper_speech_later(token)


func _wallpaper_touch_line(hero: Dictionary, count: int) -> String:
	var line := str(WALLPAPER_TOUCH_LINES[count % WALLPAPER_TOUCH_LINES.size()])
	return line.replace("{hero}", str(hero.get("name", "看板娘")))


func draw_wallpaper_speech(role_rect: Rect2) -> void:
	if _wallpaper_speak_text.is_empty():
		return
	var bubble_rect := Rect2(role_rect.position + Vector2((role_rect.size.x - WALLPAPER_SPEAK_SIZE.x) * 0.5, 85), WALLPAPER_SPEAK_SIZE)
	app._draw_image(UI_WALLPAPER_SPEAK, bubble_rect.position, bubble_rect.size, false, Color(1, 1, 1, 0.96))
	var text_rect := Rect2(bubble_rect.position + (bubble_rect.size - WALLPAPER_SPEAK_TEXT_SIZE) * 0.5 + Vector2(0, 8), WALLPAPER_SPEAK_TEXT_SIZE)
	var speech: Label = app._label(_wallpaper_speak_text, 18, HORIZONTAL_ALIGNMENT_CENTER)
	speech.position = text_rect.position
	speech.size = text_rect.size
	speech.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	speech.modulate = Color(0.34, 0.23, 0.16, 1.0)
	app._view_container().add_child(speech)


func _hide_wallpaper_speech_later(token: int) -> void:
	await app.get_tree().create_timer(WALLPAPER_SPEAK_DURATION).timeout
	if _main_state != "wallpaper_focus" or token != _wallpaper_touch_token or _wallpaper_speak_text.is_empty():
		return
	_wallpaper_speak_text = ""
	if _wallpaper_focus_state == "focus_speak":
		_wallpaper_focus_state = "focus_idle"
	_draw_wallpaper_focus()


func _play_wallpaper_touch_voice(hero: Dictionary, count: int) -> void:
	var suffixes := ["greet", "wait1", "wait2", "wait3", "arm1", "er"]
	var prefixes := _wallpaper_voice_prefixes(hero)
	var start_index := count % suffixes.size()
	for offset in range(suffixes.size()):
		var suffix := str(suffixes[(start_index + offset) % suffixes.size()])
		for prefix in prefixes:
			var path := "res://assets/audio/gal/%s_%s.wav" % [prefix, suffix]
			if FileAccess.file_exists(path):
				app._play_sfx(path, 0.82)
				return


func _wallpaper_voice_prefixes(hero: Dictionary) -> Array:
	var prefixes := []
	_append_wallpaper_voice_prefix(prefixes, _hero_spine_key(hero))
	var spine_list := str(hero.get("spine", "")).split("|")
	for raw_spine in spine_list:
		_append_wallpaper_voice_prefix(prefixes, str(raw_spine))
	_append_wallpaper_voice_prefix(prefixes, "hero_037")
	return prefixes


func _append_wallpaper_voice_prefix(prefixes: Array, raw_key: String) -> void:
	var key := raw_key.strip_edges()
	if key.is_empty():
		return
	if not prefixes.has(key):
		prefixes.append(key)
	var skin_index := key.find("_s")
	if skin_index > 0:
		var base_key := key.substr(0, skin_index)
		if not prefixes.has(base_key):
			prefixes.append(base_key)


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
	var resources := _configured_group("top_resources")
	if resources.is_empty():
		resources = [
			{"id": "top_mail", "icon": UI_MAIN_CHAT_BG, "target": "mail", "value": app._unclaimed_mail_count()},
			{"id": "top_ticket", "icon": UI_ITEM_TICKET, "target": "shop", "value": "%d/50" % clamp(int(app.save.get("tickets", 0)), 0, 50)},
			{"id": "top_gem", "icon": UI_ITEM_GEM, "target": "shop", "value": app.save.get("gems", 0)}
		]
	for item in resources:
		var entry: Dictionary = item
		if not app._mainui_entry_visible(entry):
			continue
		var value = entry.get("value", "")
		match str(entry.get("id", "")):
			"top_mail":
				value = app._unclaimed_mail_count()
			"top_ticket":
				value = "%d/50" % clamp(int(app.save.get("tickets", 0)), 0, 50)
			"top_gem":
				value = app.save.get("gems", 0)
		var bg = app._draw_image(UI_MAIN_TOP_RES_BG, Vector2(x, 14), cell_size, false, Color(1, 1, 1, 0.76))
		_main_panels.append(bg)
		add_scaled_image(str(entry.get("icon", UI_ITEM_GEM)), Vector2(x - 5, 9), Vector2(50, 50), Color(1, 1, 1, 0.94))
		add_ui_text(str(value), Vector2(x + 27, 14), Vector2(130, 40), 18, HORIZONTAL_ALIGNMENT_LEFT, Color(0.96, 0.92, 0.78))
		add_hit_button(Vector2(x, 14), cell_size, app._mainui_entry_callable(entry))
		_draw_entry_red_dot(entry, Vector2(x + cell_size.x - 16, 12))
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
	add_hit_button(Vector2(0, 22), Vector2(354, 79), _entry_callback("btnPlayerInfo", app._show_player_info))
	# btnChange/btnEye: compact actions beside the player card.
	var change_entry := _configured_entry("btnChange")
	app._draw_image(UI_MAIN_BTN_CHANGE, Vector2(365, 10), Vector2(74, 74), false, Color(1, 1, 1, 0.92))
	add_ui_text(str(change_entry.get("label", "壁紙")), Vector2(367, 72), Vector2(70, 22), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(365, 10), Vector2(74, 86), _entry_callback("btnChange", app._show_wallpaper_select))
	var eye_entry := _configured_entry("btnEye")
	app._draw_image(UI_MAIN_BTN_EYE, Vector2(441, 10), Vector2(74, 74), false, Color(1, 1, 1, 0.92))
	add_ui_text(str(eye_entry.get("label", "互動")), Vector2(443, 72), Vector2(70, 22), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(441, 10), Vector2(74, 86), _entry_callback("btnEye", enter_wallpaper_focus))


func draw_funny_content() -> void:
	# pnlFunnyContent: bottom-right row, prefab screenshot box x≈972..1331 y≈629..731.
	var actions := _configured_group("funny")
	if actions.is_empty():
		actions = [
			{"id": "btnArena", "label": "競技", "icon": UI_MAIN_FUNNY_ARENA, "target": "competition", "red_dot_key": "Arena.ArenaRedDot.89949"},
			{"id": "btnPrayer", "label": "祈願", "icon": UI_MAIN_FUNNY_PRAYER, "target": "prayer_pool", "red_dot_key": "LotteryDraw.Prayer.4036"},
			{"id": "btnAdventure", "label": "冒險", "icon": UI_MAIN_FUNNY_ADVENTURE, "target": "battle", "red_dot_key": "Adventure.AdventureMainView.43704"},
			{"id": "btnDraw", "label": "喚靈", "icon": UI_MAIN_FUNNY_DRAW, "target": "present_pool", "red_dot_key": "LotteryDraw.LotteryDrawHero.7805"}
		]
	var bw = 88.0; var bh = 102.0; var gap = 5.0
	var start_x = MAINUI_FUNNY_CONTENT_POS.x
	var by = MAINUI_FUNNY_CONTENT_POS.y
	for item in actions:
		var entry: Dictionary = item
		if not app._mainui_entry_visible(entry):
			continue
		var bg = app._draw_image(str(entry.get("icon", UI_MAIN_FUNNY_DRAW)), Vector2(start_x, by), Vector2(bw, bh), false, Color(1, 1, 1, 0.84))
		_main_panels.append(bg)
		add_ui_text(str(entry.get("label", "")), Vector2(start_x, by + 66), Vector2(bw, 28), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		add_hit_button(Vector2(start_x, by), Vector2(bw, bh), app._mainui_entry_callable(entry))
		_draw_entry_red_dot(entry, Vector2(start_x + bw - 16, by + 4))
		start_x += bw + gap
	# btnJumpAutoFight above btnAdventure (prefab pos(0,33) size(180,90))
	# 3rd button (冒險): banner is wider than its parent and protrudes upward.
	var auto_entry := _configured_entry("btnJumpAutoFight")
	var adv_x = MAINUI_FUNNY_CONTENT_POS.x + 2 * (bw + gap)
	var auto_x = adv_x - 46
	var auto_y = by - 88
	app._draw_image(UI_MAIN_AUTO_FIGHT, Vector2(auto_x, auto_y), Vector2(180, 90), false, Color(1, 1, 1, 0.88))
	add_ui_text("%s中..." % str(auto_entry.get("label", "自動挑戰")), Vector2(auto_x + 9, auto_y + 18), Vector2(162, 26), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.96, 0.88, 0.52))
	add_ui_text("歷戰尖塔-單隊", Vector2(auto_x + 5, auto_y + 46), Vector2(170, 24), 16, HORIZONTAL_ALIGNMENT_CENTER, Color(0.96, 0.88, 0.52))
	add_hit_button(Vector2(auto_x, auto_y), Vector2(180, 90), _entry_callback("btnJumpAutoFight", app._show_auto_fight))
	_draw_entry_red_dot(auto_entry, Vector2(auto_x + 152, auto_y + 8))


func draw_story_harvest() -> void:
	# pnlStory: bottom-right big story/hook button.
	var harvest_entry := _configured_entry("btnHarvest")
	var story_entry := _configured_entry("btnStory")
	var sw = 278.0; var sh = 98.0
	var sx = MAINUI_STORY_POS.x; var sy = MAINUI_STORY_POS.y
	var bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(sx, sy), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	_main_panels.append(bg)
	app._draw_image(UI_MAIN_STORY_PROGRESS, Vector2(sx + 42, sy - 32), Vector2(156, 34), false, Color(1, 1, 1, 0.9))
	add_ui_text("進度：%s" % app._next_task_text(), Vector2(sx + 45, sy - 29), Vector2(150, 24), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.88, 0.52))
	add_ui_text("塵世探秘", Vector2(sx + 114, sy + 26), Vector2(128, 46), 28, HORIZONTAL_ALIGNMENT_CENTER, Color(0.55, 0.48, 0.40))
	# btnHarvest: chest/hook reward button inside pnlStory.
	app._draw_image(UI_MAIN_BTN_HARVEST, Vector2(sx + 14, sy - 5), Vector2(106, 106), false, Color(1, 1, 1, 0.90))
	add_hit_button(Vector2(sx + 14, sy - 5), Vector2(106, 106), _entry_callback("btnHarvest", app._claim_afk_reward))
	# btnHarvest sub-elements: imgHookTime + txtHookTime
	app._draw_image(UI_MAIN_HOOK_TIME_BG, Vector2(sx + 21, sy + 69), Vector2(92, 20), false, Color(1, 1, 1, 0.82))
	add_ui_text(_entry_timer(harvest_entry, app._afk_time_display()), Vector2(sx + 21, sy + 69), Vector2(92, 20), 12, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.84, 0.52))
	# btnStory: prefab has transparent overlay button (132×99) covering story area
	add_hit_button(Vector2(sx + 146, sy), Vector2(132, sh), _entry_callback("btnStory", app._show_expedition_main))
	_draw_entry_red_dot(harvest_entry, Vector2(sx + 13, sy - 2))
	_draw_entry_red_dot(story_entry, Vector2(sx + 252, sy + 5))


func draw_charge_column() -> void:
	# pnlCharge: right-side commerce cluster, 5 buttons generated by the original layout group order.
	var entries := _configured_group("charge")
	if entries.is_empty():
		entries = [
			{"id": "btnCharge", "label": "充值", "icon": UI_MAIN_CHARGE_ICONS[3], "target": "charge", "red_dot_key": "Activities.ReCharge.99752"},
			{"id": "btnActivity", "label": "活動", "icon": UI_MAIN_CHARGE_ICONS[0], "target": "activity", "red_dot_key": "Activities.Activity.34064"},
			{"id": "btnShop", "label": "商店", "icon": UI_MAIN_CHARGE_ICONS[4], "target": "shop", "red_dot_key": "GameShopCollection.Page.1748"},
			{"id": "btnWelfare", "label": "福利", "icon": UI_MAIN_CHARGE_ICONS[1], "target": "welfare", "red_dot_key": "Activities.Welfare.83923"},
			{"id": "btnCard", "label": "月卡", "icon": UI_MAIN_CHARGE_ICONS[2], "target": "month_card", "red_dot_key": "Activities.Card.5353"}
		]
	var positions := [
		MAINUI_CHARGE_POS + Vector2(0, 0),
		MAINUI_CHARGE_POS + Vector2(80, 0),
		MAINUI_CHARGE_POS + Vector2(0, 88),
		MAINUI_CHARGE_POS + Vector2(80, 88),
		MAINUI_CHARGE_POS + Vector2(80, 176)
	]
	for index in range(min(entries.size(), positions.size())):
		var entry: Dictionary = entries[index]
		if not app._mainui_entry_visible(entry):
			continue
		var pos: Vector2 = positions[index]
		var icon = app._draw_image(str(entry.get("icon", UI_MAIN_CHARGE_ICONS[0])), pos, Vector2(78, 78), false, Color(1, 1, 1, 0.90))
		_main_panels.append(icon)
		add_ui_text(str(entry.get("label", "")), pos + Vector2(0, 58), Vector2(78, 29), 20, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		add_hit_button(pos, Vector2(78, 88), app._mainui_entry_callable(entry))
		_draw_entry_red_dot(entry, pos + Vector2(58, 2))


func draw_menu_button() -> void:
	# btnMenu: 78x78 (→60x75), right-top pos(-94,-54)
	var entry := {"id": "btnMenu", "red_dot_key": "Activities.Activity.34064"}
	var menu_rect := _main_right_top_center_rect(Vector2(-94, -54), Vector2(78, 78))
	var mx = menu_rect.position.x; var my = menu_rect.position.y
	draw_mainui_fx("menu", Vector2(mx - 19, my - 19), menu_rect.size + Vector2(38, 38), 0.78)
	app._draw_image(UI_MAIN_MENU, Vector2(mx - 8, my - 8), Vector2(76, 76), false, Color(1, 0.78, 0.34, 0.24))
	app._draw_image(UI_MAIN_MENU, Vector2(mx - 6, my - 6), Vector2(72, 72), false, Color(1, 1, 1, 0.30))
	app._draw_image(UI_MAIN_MENU, Vector2(mx, my), menu_rect.size, false, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(mx, my), menu_rect.size, app._show_home_menu)
	_draw_entry_red_dot(entry, Vector2(mx + 46, my + 4))


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
	var gifts := _configured_group("commercialization")
	var gsx = gx; var gsy = gy; var gi = 0
	for gift in gifts:
		var entry: Dictionary = gift
		if not app._mainui_entry_visible(entry):
			continue
		add_scaled_image(str(entry.get("icon", UI_MAIN_LIMIT_ICONS[0])), Vector2(gsx, gsy), Vector2(86, 86), Color(1, 1, 1, 0.94))
		add_ui_text(str(entry.get("label", "")), Vector2(gsx, gsy + 55), Vector2(86, 24), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.96))
		var timer := _entry_timer(entry)
		if not timer.is_empty():
			add_ui_text(timer, Vector2(gsx, gsy + 73), Vector2(86, 22), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.80, 0.28))
		add_hit_button(Vector2(gsx, gsy), Vector2(86, 86), app._mainui_entry_callable(entry))
		_draw_entry_red_dot(entry, Vector2(gsx + 66, gsy + 2))
		gi += 1; gsx += 102
		if gi % 4 == 0:
			gsx = gx; gsy += 96
		if gi >= 12:
			gsx = gx + float(gi - 12) * 102.0
			gsy = gy + 3.0 * 96.0


func draw_chapter_info() -> void:
	# btnChapterInfo: screenshot/prefab box x=1360 y=500 size=276x100.
	var entry := _configured_entry("btnChapterInfo")
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
	add_hit_button(Vector2(px, py), chapter_rect.size, _entry_callback("btnChapterInfo", app._show_chapter_panel))
	_draw_entry_red_dot(entry, Vector2(px + 8, py + 4))


func draw_bottom_bar() -> void:
	# pnlBottom: bottom-left, pos(64,49), height 50.
	var bar_y = MAINUI_BOTTOM_POS.y; var bar_h = 50.0
	var bar_width = 115.0 + 6.0 * 86.0
	var bar = app._draw_image(UI_MAIN_BOTTOM_BG, MAINUI_BOTTOM_POS, Vector2(bar_width, bar_h), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bar)
	# 6 buttons: after the enlarged Gal portal.
	# 繁體中文: via lang_extra.bytes UI1000001-UI1000013
	var buttons := _configured_group("bottom_nav")
	var bw = 86.0; var bx = MAINUI_BOTTOM_POS.x + 115.0
	for item in buttons:
		var entry: Dictionary = item
		if not app._mainui_entry_visible(entry):
			continue
		add_ui_text(str(entry.get("label", "")), Vector2(bx + 8, bar_y + 10), Vector2(70, 30), 22, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.92))
		add_hit_button(Vector2(bx, bar_y), Vector2(bw, bar_h), app._mainui_entry_callable(entry))
		app._draw_image(UI_MAIN_SEPARATOR, Vector2(bx, bar_y + 16), Vector2(2, 18), false, Color(1, 1, 1, 0.55))
		_draw_entry_red_dot(entry, Vector2(bx + 64, bar_y + 2))
		bx += bw


func draw_gal_button() -> void:
	# btnGal: 115x129 protrudes 79px upward from pnlBottom.
	var entry := _configured_entry("btnGal")
	var gx = MAINUI_BOTTOM_POS.x
	var gy = MAINUI_BOTTOM_POS.y + 50.0 - 129.0
	draw_mainui_fx("gal", Vector2(gx + 7, gy + 62), Vector2(100, 76), 0.90)
	add_scaled_image(str(entry.get("icon", UI_MAIN_GAL)), Vector2(gx - 17, gy - 41), Vector2(150, 170), Color(1, 1, 1, 0.94))
	add_ui_text(str(entry.get("label", "現世")), Vector2(gx + 22, gy + 82), Vector2(70, 30), 24, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.96))
	add_hit_button(Vector2(gx, gy), Vector2(115, 129), _entry_callback("btnGal", enter_gal_entry))
	add_hit_button(Vector2(gx + 8, gy + 74), Vector2(100, 100), _entry_callback("btnGal", enter_gal_entry))
	_draw_entry_red_dot(entry, Vector2(gx + 90, gy + 4))


func draw_chat_bar() -> void:
	# pnlChat: right-anchored prefab box x=1196 y=94 size=410x40.
	var entry := _configured_entry("pnlChat")
	var chat_rect := Rect2(MAINUI_CHAT_POS, Vector2(410, 40))
	var cx = chat_rect.position.x; var cy = chat_rect.position.y
	var bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), chat_rect.size, false, Color(1, 1, 1, 0.72))
	_main_panels.append(bg)
	var chat = app._label("[世界] 塵世：?", 14)
	chat.position = Vector2(cx + 64, cy); chat.size = Vector2(341, 40)
	chat.modulate = Color(0.54, 0.92, 0.54)
	app._view_container().add_child(chat)
	add_hit_button(Vector2(cx, cy), chat_rect.size, _entry_callback("pnlChat", app._show_chat))
	_draw_entry_red_dot(entry, Vector2(cx + 382, cy - 3))


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
