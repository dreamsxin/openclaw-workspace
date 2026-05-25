# UTF-8 source. MainUIView - refactored from prefab + IL analysis.
# States: main_normal | wallpaper_focus | gal_entry
# listPanel = [pnlChat, pnlFunny, pnlPlayerInfo, pnlCommercialization, btnChapterInfo, pnlBottom]
# ShowOrHide() toggles listPanel + TopBar + btnBodyMask + btnEye/btnChange
extends RefCounted

# ── Sprite constants ──
const UI_MAIN_BG = "res://assets/ui/background/mainui_bg_01.png"   # 1670x750 fullscreen wallpaper
const UI_MAIN_PLAYER_FRAME = "res://assets/ui/mainui/mainui_img_02.png"
const UI_MAIN_AVATAR_RING = "res://assets/ui/mainui/mainui_img_03.png"
const UI_MAIN_EXP_RING = "res://assets/ui/mainui/mainui_img_04.png"
const UI_MAIN_BANNER = "res://assets/ui/mainui/mainui_img_05.png"
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
const UI_MAIN_BTN_EYE = "res://assets/ui/mainui/mainui_btn_12.png"       # btnEye
const UI_MAIN_BTN_CHANGE = "res://assets/ui/mainui/mainui_btn_13.png"    # btnChange
const UI_MAIN_BTN_HARVEST = "res://assets/ui/mainui/mainui_img_18.png"   # btnHarvest
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

var app
var _main_state: String = "normal"
var _main_panels: Array = []

func _init(app_ref) -> void:
	app = app_ref


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
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240055)))
	# Layer 0: Wallpaper (always below everything)
	draw_wallpaper(hero)
	# Layer 1: Full-screen transparent button (wallpaper toggle)
	draw_body_mask()
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
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240055)))
	draw_wallpaper(hero)
	# pnlCtl: centered control bar at bottom
	var ctl_y = 660.0
	app._add_action_button("◀", Vector2(520, ctl_y), app._show_home, Vector2(48, 48))
	app._add_action_button("▶", Vector2(576, ctl_y), app._show_home, Vector2(48, 48))
	app._add_action_button("▐▐", Vector2(632, ctl_y), app._show_home, Vector2(48, 48))
	app._add_action_button("眼", Vector2(700, ctl_y), enter_normal_state, Vector2(56, 48))


func enter_gal_entry() -> void:
	app._show_gal()


# ═══════════════════════════════════════════════════════════════
# Drawing functions - main_normal layers
# ═══════════════════════════════════════════════════════════════

func draw_wallpaper(hero: Dictionary) -> void:
	# Prefab: @WallpaperPanel anchor=(0.5,0.5) 1668x750 → fullscreen scaled
	app._draw_image(UI_MAIN_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.010, 0.008, 0.05)))
	# Keep the interactive role in the center-right lane so left activity entries remain readable.
	app._draw_hero_stage(hero, Vector2(390, 82), Vector2(560, 620), false)


func draw_body_mask() -> void:
	var mask = Button.new()
	mask.text = ""; mask.flat = true
	mask.position = Vector2(0, 0); mask.size = Vector2(1280, 720)
	mask.modulate = Color(1, 1, 1, 0.0)
	mask.pressed.connect(enter_wallpaper_focus)
	app._view_container().add_child(mask)


func draw_top_bar() -> void:
	# @TopBar/svRes sits in the top-right resource strip.
	var strip = app._panel(Vector2(842, 20), Vector2(344, 42), Color(0.016, 0.014, 0.014, 0.62))
	app._view_container().add_child(strip)
	_main_panels.append(strip)
	var x = 866.0
	var resources = [
		[UI_ITEM_TICKET, "%d/50" % clamp(int(app.save.get("tickets", 0)), 0, 50)],
		[UI_ITEM_GEM, app.save.get("gems", 0)]
	]
	for item in resources:
		add_scaled_image(str(item[0]), Vector2(x - 8, 23), Vector2(34, 34), Color(1, 1, 1, 0.92))
		add_ui_text(str(item[1]), Vector2(x + 30, 23), Vector2(72, 30), 17, HORIZONTAL_ALIGNMENT_LEFT, Color(0.96, 0.92, 0.78))
		add_ui_text("+", Vector2(x + 106, 18), Vector2(24, 34), 28, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.86, 0.34))
		x += 156


func draw_player_info(hero: Dictionary) -> void:
	# pnlPlayerInfo: (0,5) 271x108
	var profile = app.save.get("profile", {})
	var panel = app._draw_image(UI_MAIN_PLAYER_FRAME, Vector2(0, 5), Vector2(271, 108), false, Color(1, 1, 1, 0.94))
	_main_panels.append(panel)
	# imgHeadBg and imgExp are left-middle inside the player panel.
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(49, 12), Vector2(61, 76), false, Color(1, 1, 1, 0.94))
	app._draw_image(UI_MAIN_EXP_RING, Vector2(43, 6), Vector2(69, 86), false, Color(1, 0.84, 0.28, 0.88))
	# Level label
	var lv = app._label("Lv.%d" % int(profile.get("level", 1)), 12, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = Vector2(54, 82); lv.size = Vector2(52, 14); lv.modulate = Color(0.96, 0.88, 0.52)
	app._view_container().add_child(lv)
	# txtName (118,26) 66x28
	var pname = app._label(str(profile.get("name", "Player")), 18)
	pname.position = Vector2(118, 26); pname.size = Vector2(66, 28)
	app._view_container().add_child(pname)
	# txtPower (139,50) 133x32
	app._draw_image(UI_MAIN_POWER_ICON, Vector2(127, 50), Vector2(17, 20), false, Color(1, 1, 1, 0.9))
	var power = app._label("战力 %d" % app._player_power(), 14)
	power.position = Vector2(139, 50); power.size = Vector2(133, 32)
	power.modulate = Color(0.84, 0.74, 0.24)
	app._view_container().add_child(power)
	# btnPlayerInfo (0,13) 271x76
	add_hit_button(Vector2(0, 13), Vector2(271, 76), app._show_player_info)
	# btnChange/btnEye: center near x=402/478, top y about 15 on a 1280x720 target.
	app._draw_image(UI_MAIN_BTN_CHANGE, Vector2(280, 15), Vector2(57, 57), false, Color(1, 1, 1, 0.92))
	add_ui_text("壁紙", Vector2(281, 69), Vector2(56, 20), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(280, 15), Vector2(57, 74), app._show_gallery)
	app._draw_image(UI_MAIN_BTN_EYE, Vector2(338, 15), Vector2(57, 57), false, Color(1, 1, 1, 0.92))
	add_ui_text("互動", Vector2(339, 69), Vector2(56, 20), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(338, 15), Vector2(57, 74), enter_wallpaper_focus)


func draw_funny_content() -> void:
	# pnlFunnyContent: bottom-right row, prefab screenshot box x≈972..1331 y≈629..731.
	var actions = [
		[UI_MAIN_FUNNY_ARENA, "競技", app._show_battle],
		[UI_MAIN_FUNNY_PRAYER, "祈願", app._open_prayer_pool],
		[UI_MAIN_FUNNY_ADVENTURE, "冒險", app._show_battle],
		[UI_MAIN_FUNNY_DRAW, "喚靈", app._open_present_pool]
	]
	var bw = 67.0; var bh = 98.0; var gap = 5.0
	var start_x = 745.0
	var by = 604.0
	for item in actions:
		var bg = app._draw_image(str(item[0]), Vector2(start_x, by), Vector2(bw, bh), false, Color(1, 1, 1, 0.84))
		_main_panels.append(bg)
		add_ui_text(str(item[1]), Vector2(start_x, by + 68), Vector2(bw, 24), 14, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		add_hit_button(Vector2(start_x, by), Vector2(bw, bh), item[2])
		app._draw_red_dot(Vector2(start_x + bw - 16, by + 4))
		start_x += bw + gap


func draw_story_harvest() -> void:
	# pnlStory: bottom-right big story/hook button.
	var sw = 213.0; var sh = 94.0
	var sx = 1021.0; var sy = 608.0
	var bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(sx, sy), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	_main_panels.append(bg)
	app._draw_image(UI_MAIN_STORY_PROGRESS, Vector2(sx + 61, sy - 2), Vector2(119, 26), false, Color(1, 1, 1, 0.9))
	add_ui_text("进度：%s" % app._next_task_text(), Vector2(sx + 64, sy + 1), Vector2(112, 20), 12, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.88, 0.52))
	add_ui_text("塵世探秘", Vector2(sx + 86, sy + 37), Vector2(116, 34), 24, HORIZONTAL_ALIGNMENT_CENTER, Color(0.55, 0.48, 0.40))
	# btnHarvest: chest/hook reward button inside pnlStory.
	app._draw_image(UI_MAIN_BTN_HARVEST, Vector2(sx + 10, sy + 13), Vector2(74, 74), false, Color(1, 1, 1, 0.90))
	add_hit_button(Vector2(sx + 10, sy + 13), Vector2(74, 74), app._claim_afk_reward)
	# btnHarvest sub-elements: imgHookTime + txtHookTime
	app._draw_image(UI_MAIN_AUTO_FIGHT, Vector2(sx + 5, sy + 67), Vector2(84, 24), false, Color(1, 1, 1, 0.70))
	add_ui_text(app._afk_time_display(), Vector2(sx + 13, sy + 69), Vector2(68, 18), 11, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.84, 0.52))
	# btnStory: prefab has transparent overlay button (132×99) covering story area
	add_hit_button(Vector2(sx + 86, sy), Vector2(sw - 86, sh), app._show_tasks)
	app._draw_red_dot(Vector2(sx + sw - 20, sy + 2))


func draw_charge_column() -> void:
	# pnlCharge: right-side commerce grid, screenshot x≈1117..1238 y≈142..390.
	var entries = [
		[UI_MAIN_CHARGE_ICONS[3], "儲值", app._show_shop, Vector2(1118, 142)],
		[UI_MAIN_CHARGE_ICONS[0], "活動", app._show_daily, Vector2(1178, 142)],
		[UI_MAIN_CHARGE_ICONS[4], "商店", app._show_shop, Vector2(1118, 230)],
		[UI_MAIN_CHARGE_ICONS[1], "福利", app._show_daily, Vector2(1178, 230)],
		[UI_MAIN_CHARGE_ICONS[2], "月卡", app._show_shop, Vector2(1178, 318)]
	]
	for entry in entries:
		var icon = app._draw_image(str(entry[0]), entry[3], Vector2(52, 52), false, Color(1, 1, 1, 0.88))
		_main_panels.append(icon)
		add_ui_text(str(entry[1]), entry[3] + Vector2(-4, 48), Vector2(60, 20), 14, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		add_hit_button(entry[3], Vector2(56, 72), entry[2])
		app._draw_red_dot(entry[3] + Vector2(40, 0))


func draw_menu_button() -> void:
	# btnMenu: 78x78 (→60x75), right-top pos(-94,-54)
	var mx = 1178.0; var my = 14.0
	app._draw_image(UI_MAIN_MENU, Vector2(mx, my), Vector2(60, 60), false, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(mx, my), Vector2(60, 60), app._show_settings)
	app._draw_red_dot(Vector2(mx + 46, my + 4))


func draw_assist_button() -> void:
	# btnAssist: 78x96 (→60x92), left pos(413,-164)
	# Godot: x = 413*0.7665 = 317, y = 164*0.96 = 157
	app._draw_image(UI_MAIN_ASSIST, Vector2(317, 157), Vector2(60, 74), false, Color(1, 1, 1, 0.84))
	add_ui_text("小助手", Vector2(298, 220), Vector2(98, 20), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
	add_hit_button(Vector2(317, 157), Vector2(60, 92), app._show_mail)


func draw_commercialization() -> void:
	# pnlCommercialization: banner + 4-column LimitIconView grid from MainUIView.
	var px = 50.0; var py = 120.0
	# @pnlAlternate: 301x108 (→231x104) banner
	app._draw_image(UI_MAIN_BANNER, Vector2(px, py), Vector2(231, 104), false, Color(1, 1, 1, 0.92))
	# pnlGift: 409x300 (→313x288), below banner
	var gx = px + 5; var gy = py + 113
	var gifts = [
		["喚靈福利", "4d01h", app._show_daily],
		["幻海邀约", "6d01h", enter_gal_entry],
		["簽到福利", "", app._show_daily],
		["新服庆典", "11d01h", app._show_tasks],
		["交流大厅", "", app._show_mail],
		["开服冲榜", "7d01h", app._show_daily],
		["限时皮肤", "11d01h", app._show_shop],
		["露箔闪光", "11d01h", app._show_shop],
		["首储", "", app._show_shop],
		["萬象喚靈", "4d01h", app._open_present_pool],
		["周末企划", "1d01h", app._show_tasks],
		["神域馈赠", "11d01h", app._show_daily]
	]
	var gsx = gx + 2.0; var gsy = gy + 5.0; var gi = 0
	for gift in gifts:
		add_scaled_image(str(UI_MAIN_LIMIT_ICONS[gi % UI_MAIN_LIMIT_ICONS.size()]), Vector2(gsx, gsy), Vector2(66, 66), Color(1, 1, 1, 0.9))
		add_ui_text(str(gift[0]), Vector2(gsx - 7, gsy + 48), Vector2(80, 20), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.94))
		if not str(gift[1]).is_empty():
			add_ui_text(str(gift[1]), Vector2(gsx - 4, gsy + 64), Vector2(74, 18), 12, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.80, 0.28))
		add_hit_button(Vector2(gsx, gsy), Vector2(68, 82), gift[2])
		if gi in [2, 4, 8, 10]:
			app._draw_red_dot(Vector2(gsx + 52, gsy + 2))
		gi += 1; gsx += 74
		if gi % 4 == 0:
			gsx = gx + 2; gsy += 96


func draw_chapter_info() -> void:
	# btnChapterInfo: anchor(1,0) pivot(1,0) pos(-34,150) size(276,100)
	# Godot: right=1280-34*0.7665=1254, bottom=720+150*0.96=864→pivot=cornner→bottom=576→top=480
	var px = 1042.0; var py = 480.0
	var bg = app._draw_image(UI_MAIN_CHAPTER_BG, Vector2(px, py), Vector2(212, 96), false, Color(1, 1, 1, 0.90))
	_main_panels.append(bg)
	add_ui_text("第1章塵世裂痕 0/1", Vector2(px + 26, py + 9), Vector2(168, 20), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.90, 0.62))
	var rewards = [
		[UI_ITEM_TICKET, "5", Color(0.96, 0.48, 0.38, 0.72)],
		["res://assets/ui/item/draw_06.png", "10", Color(0.28, 0.40, 0.72, 0.72)],
		[UI_ITEM_GEM, "100", Color(0.92, 0.72, 0.34, 0.72)]
	]
	var rx = px + 25.0
	for reward in rewards:
		app._view_container().add_child(app._panel(Vector2(rx, py + 38), Vector2(42, 42), reward[2]))
		add_scaled_image(str(reward[0]), Vector2(rx + 4, py + 40), Vector2(34, 34), Color(1, 1, 1, 0.96))
		add_ui_text(str(reward[1]), Vector2(rx + 23, py + 64), Vector2(18, 14), 9, HORIZONTAL_ALIGNMENT_RIGHT, Color(1, 1, 1, 0.95))
		rx += 50
	add_hit_button(Vector2(px, py), Vector2(212, 96), app._show_tasks)
	app._draw_red_dot(Vector2(px + 8, py + 4))


func draw_bottom_bar() -> void:
	# MainUIView screenshot calibration at 1280x720: keep this row slightly above the bottom edge.
	var bar_y = 657.0; var bar_h = 48.0
	var bar = app._draw_image(UI_MAIN_BOTTOM_BG, Vector2(49, bar_y), Vector2(430, bar_h), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bar)
	# 6 buttons: compact row starts immediately after the enlarged Gal portal.
	# 繁體中文: via lang_extra.bytes UI1000001-UI1000013
	var buttons = [
		["幻靈", app._show_gallery, true],
		["背包", app._show_shop, false],
		["遺器", app._show_home, false],
		["養成", app._show_gallery, true],
		["任務", app._show_tasks, true],
		["公會", app._show_home, false]
	]
	var bw = 62.0; var bx = 135.0
	for item in buttons:
		add_ui_text(str(item[0]), Vector2(bx, bar_y + 8), Vector2(bw, 30), 19, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.92))
		add_hit_button(Vector2(bx, bar_y), Vector2(bw, bar_h), item[1])
		app._draw_image(UI_MAIN_SEPARATOR, Vector2(bx + bw + 2, bar_y + 16), Vector2(2, 16), false, Color(1, 1, 1, 0.55))
		if item[2]: app._draw_red_dot(Vector2(bx + bw - 18, bar_y))
		bx += 67


func draw_gal_button() -> void:
	# mainui_btn_25 source is 150x170; force-scale it so it cannot cover btnHero.
	var gx = 38.0; var gy = 562.0
	add_scaled_image(UI_MAIN_GAL, Vector2(gx, gy), Vector2(108, 132), Color(1, 1, 1, 0.94))
	add_ui_text("現世", Vector2(gx + 19, gy + 88), Vector2(70, 30), 20, HORIZONTAL_ALIGNMENT_CENTER, Color(1, 1, 1, 0.96))
	add_hit_button(Vector2(gx, gy), Vector2(108, 132), enter_gal_entry)
	app._draw_red_dot(Vector2(gx + 82, gy + 8))


func draw_chat_bar() -> void:
	# pnlChat: right-anchored pos(-64,-94), 410x40 (→314x38)
	# Godot: left = 1280 - 64*0.7665 - 410*0.7665 ≈ 917, y = 94*0.96.
	var cx = 916.0; var cy = 90.0
	var bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), Vector2(314, 38), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bg)
	var chat = app._label("[世界] 塵世：?", 14)
	chat.position = Vector2(cx + 49, cy + 8); chat.size = Vector2(255, 22)
	chat.modulate = Color(0.54, 0.92, 0.54)
	app._view_container().add_child(chat)
	add_hit_button(Vector2(cx, cy), Vector2(314, 38), app._show_mail)


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
