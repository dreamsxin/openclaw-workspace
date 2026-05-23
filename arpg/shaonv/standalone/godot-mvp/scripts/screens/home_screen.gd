# UTF-8 source. MainUIView - refactored from prefab + IL analysis.
# States: main_normal | wallpaper_focus | gal_entry
# listPanel = [pnlChat, pnlFunny, pnlPlayerInfo, pnlCommercialization, btnChapterInfo, pnlBottom]
# ShowOrHide() toggles listPanel + TopBar + btnBodyMask + btnEye/btnChange
extends RefCounted

# ── Sprite constants ──
const UI_MAIN_BG = "res://assets/ui/mainui/mainui_img_01.png"
const UI_MAIN_PLAYER_FRAME = "res://assets/ui/mainui/mainui_img_02.png"
const UI_MAIN_AVATAR_RING = "res://assets/ui/mainui/mainui_img_03.png"
const UI_MAIN_EXP_RING = "res://assets/ui/mainui/mainui_img_04.png"
const UI_MAIN_BANNER = "res://assets/ui/mainui/mainui_img_05.png"
const UI_MAIN_TOP_ACCENT = "res://assets/ui/mainui/mainui_img_10.png"
const UI_MAIN_SEPARATOR = "res://assets/ui/mainui/mainui_img_11.png"
const UI_MAIN_ASSIST = "res://assets/ui/mainui/mainui_img_19.png"
const UI_MAIN_STORY_BG = "res://assets/ui/mainui/mainui_txt_01.png"
const UI_MAIN_FUNNY_ARENA = "res://assets/ui/mainui/mainui_txt_02.png"
const UI_MAIN_FUNNY_PRAYER = "res://assets/ui/mainui/mainui_txt_03.png"
const UI_MAIN_FUNNY_ADVENTURE = "res://assets/ui/mainui/mainui_txt_05.png"
const UI_MAIN_FUNNY_DRAW = "res://assets/ui/mainui/mainui_txt_06.png"
const UI_MAIN_CHAPTER_BG = "res://assets/ui/mainui/mainui_img_35.png"
const UI_MAIN_CHAT_BG = "res://assets/ui/mainui/mainui_btn_04.png"
const UI_MAIN_GAL = "res://assets/ui/mainui/mainui_txt_09.png"
const UI_MAIN_BOTTOM_BTN = "res://assets/ui/mainui/mainui_btn_01.png"
const UI_MAIN_MENU = "res://assets/ui/mainui/mainui_btn_06.png"
const UI_MAIN_CHARGE_ICONS = [
	"res://assets/ui/mainui/mainui_btn_07.png",
	"res://assets/ui/mainui/mainui_btn_08.png",
	"res://assets/ui/mainui/mainui_btn_09.png",
	"res://assets/ui/mainui/mainui_btn_10.png",
	"res://assets/ui/mainui/mainui_btn_11.png"
]

var app
var _main_state: String = "normal"
var _main_panels: Array = []

func _init(app_ref) -> void:
	app = app_ref


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
	app._clear("主界面")
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
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
	draw_assist_button()    # btnAssist left-bottom
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
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
	draw_wallpaper(hero)
	# pnlCtl: centered control bar at bottom
	var ctl_y = 660.0
	app._add_action_button("◀", Vector2(520, ctl_y), app._show_home, Vector2(48, 48))
	app._add_action_button("▶", Vector2(576, ctl_y), app._show_home, Vector2(48, 48))
	app._add_action_button("▐▐", Vector2(632, ctl_y), app._show_home, Vector2(48, 48))
	app._add_action_button("眼", Vector2(700, ctl_y), enter_normal_state, Vector2(56, 48))


func enter_gal_entry() -> void:
	_main_state = "gal_entry"
	app._clear("约会")
	# Dimmed wallpaper as backdrop
	app._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1278, 720), true, Color(1, 1, 1, 0.22))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.016, 0.012, 0.020, 0.90)))
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
	# ── Top bar ──
	var top = app._panel(Vector2(0, 0), Vector2(1280, 60), Color(0.024, 0.018, 0.028, 0.72))
	app._view_container().add_child(top)
	app._view_container().add_child(app._panel(Vector2(0, 58), Vector2(1280, 2), Color(0.76, 0.54, 0.28, 0.28)))
	app._add_action_button("← 返回", Vector2(18, 8), enter_normal_state, Vector2(100, 44))
	var title = app._label("约 会", 28, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(440, 12)
	title.size = Vector2(400, 36)
	title.modulate = Color(0.94, 0.86, 0.64)
	app._view_container().add_child(title)
	# ── Hero card ──
	var cx = 315.0; var cy = 85.0; var cw = 650.0; var ch = 420.0
	app._view_container().add_child(app._panel(Vector2(cx, cy), Vector2(cw, ch), Color(0.030, 0.022, 0.036, 0.68)))
	app._view_container().add_child(app._panel(Vector2(cx + 4, cy + 4), Vector2(cw - 8, ch - 8), Color(0.045, 0.034, 0.052, 0.40)))
	app._draw_hero_stage(hero, Vector2(cx + 30, cy + 30), Vector2(320, 360), false)
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(cx + 148, cy + 26), Vector2(84, 84), false, Color(1, 1, 1, 0.78))
	app._draw_image(UI_MAIN_EXP_RING, Vector2(cx + 142, cy + 20), Vector2(96, 96), false, Color(1, 0.84, 0.28, 0.72))
	# Hero info
	var ix = cx + 370; var iy = cy + 40
	var hname = app._label(str(hero.get("name", "???")) if hero else "???", 24)
	hname.position = Vector2(ix, iy); hname.size = Vector2(240, 32); hname.modulate = Color(0.98, 0.94, 0.80)
	app._view_container().add_child(hname)
	var htitle = app._label(str(hero.get("title", "")) if hero else "", 16)
	htitle.position = Vector2(ix, iy + 36); htitle.size = Vector2(240, 22); htitle.modulate = Color(0.72, 0.66, 0.52)
	app._view_container().add_child(htitle)
	# Affection bar
	var bl = app._label("好感度", 14, HORIZONTAL_ALIGNMENT_CENTER)
	bl.position = Vector2(ix, iy + 72); bl.size = Vector2(56, 18); bl.modulate = Color(0.64, 0.58, 0.48)
	app._view_container().add_child(bl)
	app._view_container().add_child(app._panel(Vector2(ix + 60, iy + 74), Vector2(160, 12), Color(0.08, 0.06, 0.12, 0.70)))
	app._view_container().add_child(app._panel(Vector2(ix + 60, iy + 74), Vector2(54, 12), Color(0.92, 0.38, 0.56, 0.78)))
	var hlvl = app._label("Lv.%d" % int(hero.get("level", 1)) if hero else "Lv.1", 14)
	hlvl.position = Vector2(ix, iy + 100); hlvl.size = Vector2(80, 18); hlvl.modulate = Color(0.86, 0.80, 0.56)
	app._view_container().add_child(hlvl)
	# Navigation
	app._add_action_button("◀", Vector2(cx - 56, cy + 180), app._show_home, Vector2(44, 56))
	app._add_action_button("▶", Vector2(cx + cw + 12, cy + 180), app._show_home, Vector2(44, 56))
	app._view_container().add_child(app._panel(Vector2(cx, cy + ch + 14), Vector2(cw, 1), Color(0.76, 0.54, 0.28, 0.18)))
	# Action buttons
	var abtn = [["💬 对话", app._show_mail], ["🎁 赠礼", app._show_shop], ["💕 邀约", app._show_home]]
	var aw = 170.0; var ah = 72.0; var ag = 22.0
	var ax0 = (1280.0 - (3*aw+2*ag)) * 0.5; var ay = 535.0
	for i in range(abtn.size()):
		var ax = ax0 + i*(aw+ag)
		app._view_container().add_child(app._panel(Vector2(ax, ay), Vector2(aw, ah), Color(0.040, 0.030, 0.048, 0.74)))
		var albl = app._label(str(abtn[i][0]), 16, HORIZONTAL_ALIGNMENT_CENTER)
		albl.position = Vector2(ax, ay + 14); albl.size = Vector2(aw, 22); albl.modulate = Color(0.86, 0.80, 0.68)
		app._view_container().add_child(albl)
		app._add_action_button("互动" if i==0 else ("送礼" if i==1 else "约会"), Vector2(ax + 2, ay + 38), abtn[i][1], Vector2(aw - 4, 32))
		if i == 2: app._draw_red_dot(Vector2(ax + aw - 22, ay + 8))
	# Status
	app._view_container().add_child(app._panel(Vector2(0, 688), Vector2(1280, 32), Color(0.020, 0.016, 0.028, 0.64)))
	var st = app._label("Gal 约会系统  |  键: Gal.GalEntry.5799  |  完整实现待反向", 12, HORIZONTAL_ALIGNMENT_CENTER)
	st.position = Vector2(140, 694); st.size = Vector2(1000, 22); st.modulate = Color(0.52, 0.48, 0.42)
	app._view_container().add_child(st)


# ═══════════════════════════════════════════════════════════════
# Drawing functions - main_normal layers
# ═══════════════════════════════════════════════════════════════

func draw_wallpaper(hero: Dictionary) -> void:
	# Prefab: @WallpaperPanel anchor=(0.5,0.5) 1668x750 → fullscreen scaled
	app._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1278, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.010, 0.008, 0.05)))
	# irole: 958x750 centered → (273,0) 734x720
	app._draw_hero_stage(hero, Vector2(273, 0), Vector2(734, 720), false)


func draw_body_mask() -> void:
	var mask = Button.new()
	mask.text = ""; mask.flat = true
	mask.position = Vector2(0, 0); mask.size = Vector2(1280, 720)
	mask.modulate = Color(1, 1, 1, 0.0)
	mask.pressed.connect(enter_wallpaper_focus)
	app._view_container().add_child(mask)


func draw_top_bar() -> void:
	# @TopBar (0,12) full-width h=58
	var bar = app._draw_image(UI_MAIN_TOP_ACCENT, Vector2(0, 12), Vector2(1280, 58), false, Color(1, 1, 1, 0.62))
	_main_panels.append(bar)
	# svRes: resource bar at right side
	var x = 680.0
	var resources = [
		["邮件", app._unclaimed_mail_count()],
		["唤醒券", app.save.get("tickets", 0)],
		["源石", app.save.get("gems", 0)]
	]
	for item in resources:
		var icon = app._panel(Vector2(x, 26), Vector2(22, 22), Color(0.58, 0.45, 0.22, 0.74))
		app._view_container().add_child(icon)
		var text = app._label("%s %s" % [item[0], item[1]], 16)
		text.position = Vector2(x + 28, 24); text.size = Vector2(130, 28)
		text.modulate = Color(0.96, 0.90, 0.80)
		app._view_container().add_child(text)
		x += 150


func draw_player_info(hero: Dictionary) -> void:
	# pnlPlayerInfo: (0,5) 271x108
	var profile = app.save.get("profile", {})
	var panel = app._draw_image(UI_MAIN_PLAYER_FRAME, Vector2(0, 5), Vector2(271, 108), false, Color(1, 1, 1, 0.94))
	_main_panels.append(panel)
	# imgHeadBg (80,8) 61x76 → imgExp (74,14) 69x86
	# imgHeadBg: pos(104,8) size(80,79) → Godot: (80,8) (61,76)
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(80, 8), Vector2(61, 76), false, Color(1, 1, 1, 0.94))
	draw_cover_portrait(hero, Vector2(86, 18), Vector2(50, 56), Color(1, 1, 1, 0.95))
	app._draw_image(UI_MAIN_EXP_RING, Vector2(74, 14), Vector2(69, 86), false, Color(1, 0.84, 0.28, 0.88))
	# Level label
	var lv = app._label("Lv.%d" % int(profile.get("level", 1)), 12, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = Vector2(82, 90); lv.size = Vector2(52, 14); lv.modulate = Color(0.96, 0.88, 0.52)
	app._view_container().add_child(lv)
	# txtName (118,26) 66x28
	var pname = app._label(str(profile.get("name", "Player")), 18)
	pname.position = Vector2(118, 26); pname.size = Vector2(66, 28)
	app._view_container().add_child(pname)
	# txtPower (139,50) 133x32
	var power = app._label("战力 %d" % app._player_power(), 14)
	power.position = Vector2(139, 50); power.size = Vector2(133, 32)
	power.modulate = Color(0.84, 0.74, 0.24)
	app._view_container().add_child(power)
	# btnPlayerInfo (0,13) 271x76
	var player_btn = Button.new()
	player_btn.text = ""; player_btn.flat = true
	player_btn.position = Vector2(0, 13); player_btn.size = Vector2(271, 76)
	player_btn.pressed.connect(app._show_player_info)
	app._view_container().add_child(player_btn)
	# btnChange (308,48) 57x71  /  btnEye (366,48) 57x71
	app._add_action_button("换", Vector2(308, 48), app._show_gallery, Vector2(57, 71))
	app._add_action_button("眼", Vector2(366, 48), enter_wallpaper_focus, Vector2(57, 71))


func draw_funny_content() -> void:
	# pnlFunnyContent: 4 buttons 88x102 (→67x98), right-anchored pos(-339,70)
	# Godot: start_x = 1280 - 339*0.7665 = 1020, by = 70*0.96 = 67
	var actions = [
		[UI_MAIN_FUNNY_ARENA, "竞技", app._show_battle],
		[UI_MAIN_FUNNY_PRAYER, "祈愿", app._open_prayer_pool],
		[UI_MAIN_FUNNY_ADVENTURE, "冒险", app._show_battle],
		[UI_MAIN_FUNNY_DRAW, "唤灵", app._open_present_pool]
	]
	var bw = 67.0; var bh = 98.0; var gap = 5.0
	var start_x = 1020.0
	var by = 67.0
	var aidx = 0
	for item in actions:
		var bg = app._draw_image(str(item[0]), Vector2(start_x, by), Vector2(bw, bh), false, Color(1, 1, 1, 0.84))
		_main_panels.append(bg)
		app._add_action_button(str(item[1]), Vector2(start_x + 2, by + 64), item[2], Vector2(bw - 4, 34))
		app._draw_red_dot(Vector2(start_x + bw - 16, by + 4))
		# btnJumpAutoFight: prefab 仅在 btnAdventure 下有子面板 (pos 0,-32 size 138,86)
		if aidx == 2:
			var afx = start_x - 36; var afy = by + bh + 4
			app._view_container().add_child(app._panel(Vector2(afx, afy), Vector2(138, 32), Color(0.025, 0.018, 0.014, 0.72)))
			var assist = app._label("<i>自动挑战中...</i>", 12, HORIZONTAL_ALIGNMENT_CENTER)
			assist.position = Vector2(afx, afy + 2); assist.size = Vector2(138, 14)
			assist.modulate = Color(0.72, 0.66, 0.48)
			app._view_container().add_child(assist)
			var assist_proj = app._label("历战尖塔-单队", 11, HORIZONTAL_ALIGNMENT_CENTER)
			assist_proj.position = Vector2(afx, afy + 16); assist_proj.size = Vector2(138, 14)
			assist_proj.modulate = Color(0.58, 0.52, 0.40)
			app._view_container().add_child(assist_proj)
		start_x += bw + gap
		aidx += 1


func draw_story_harvest() -> void:
	# pnlStory: 278x98 (→213x94), right-anchored pos(-60,19)
	# Godot: x = 1280 - 60*0.7665 = 1234, y = 19*0.96 = 18
	var sw = 213.0; var sh = 94.0
	var sx = 1234.0; var sy = 18.0
	var bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(sx, sy), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
	_main_panels.append(bg)
	var story = app._label("主线 %s\n挂机收益 %s" % [app._next_task_text(), "可收取" if not app._afk_claimed_today() else "已收取"], 15)
	story.position = Vector2(sx + 14, sy + 14); story.size = Vector2(sw - 16, 44)
	app._view_container().add_child(story)
	# btnHarvest: 106x106 → 81x102, inside pnlStory at (51,1)
	app._add_action_button("收获", Vector2(sx + 51, sy + 1), app._claim_afk_reward, Vector2(81, 102))
	# btnHarvest sub-elements: imgHookTime + txtHookTime
	var hook_time = app._label(app._afk_time_display(), 12, HORIZONTAL_ALIGNMENT_CENTER)
	hook_time.position = Vector2(sx + 55, sy + 104); hook_time.size = Vector2(71, 18)
	hook_time.modulate = Color(0.92, 0.84, 0.52)
	app._view_container().add_child(hook_time)
	# btnStory: prefab has transparent overlay button (132×99) covering story area
	app._add_action_button("", Vector2(sx, sy), app._show_tasks, Vector2(sw, sh))
	app._draw_red_dot(Vector2(sx + sw - 20, sy + 2))


func draw_charge_column() -> void:
	# pnlCharge: 158x258 (→121x248), right-top pos(-55,-277)
	# Godot: x = 1280 - 55*0.7665 = 1238, y = 277*0.96 = 266
	var labels = [["活动", app._show_daily], ["福利", app._show_daily], ["月卡", app._show_shop], ["充值", app._show_shop], ["商店", app._show_shop]]
	var cx = 1238.0; var cy = 266.0
	for i in range(labels.size()):
		var icon = app._draw_image(str(UI_MAIN_CHARGE_ICONS[i]), Vector2(cx, cy), Vector2(60, 60), false, Color(1, 1, 1, 0.86))
		_main_panels.append(icon)
		app._add_action_button(str(labels[i][0]), Vector2(cx + 2, cy + 44), labels[i][1], Vector2(56, 26))
		app._draw_red_dot(Vector2(cx + 44, cy + 2))
		cy += 50


func draw_menu_button() -> void:
	# btnMenu: 78x78 (→60x75), right-top pos(-94,-54)
	# Godot: x = 1280 - 94*0.7665 = 1208, y = 54*0.96 = 52
	var mx = 1208.0; var my = 52.0
	app._draw_image(UI_MAIN_MENU, Vector2(mx, my), Vector2(60, 75), false, Color(1, 1, 1, 0.92))
	app._add_action_button("", Vector2(mx, my), app._show_settings, Vector2(60, 75))
	app._draw_red_dot(Vector2(mx + 46, my + 4))


func draw_assist_button() -> void:
	# btnAssist: 78x96 (→60x92), left pos(413,-164)
	# Godot: x = 413*0.7665 = 317, y = 164*0.96 = 157
	app._draw_image(UI_MAIN_ASSIST, Vector2(317, 157), Vector2(60, 92), false, Color(1, 1, 1, 0.84))
	app._add_action_button("援助", Vector2(317, 233), app._show_mail, Vector2(60, 26))


func draw_commercialization() -> void:
	# pnlCommercialization: 416x420 (→319x404), left-mid area
	var px = 203.0; var py = 317.0
	# @pnlAlternate: 301x108 (→231x104) banner
	app._draw_image(UI_MAIN_BANNER, Vector2(px, py), Vector2(231, 104), false, Color(1, 1, 1, 0.92))
	# pnlGift: 409x300 (→313x288), below banner
	var gx = px + 5; var gy = py + 108 + 12
	app._view_container().add_child(app._panel(Vector2(gx, gy), Vector2(313, 288), Color(0.030, 0.023, 0.018, 0.56)))
	var gifts = [
		["补给", app._show_daily], ["邮件", app._show_mail], ["签到", app._show_daily],
		["奖励", app._show_tasks], ["问答", app._show_home], ["礼包", app._show_shop],
		["月卡", app._show_shop], ["充值", app._show_shop], ["商店", app._show_shop]
	]
	var gsx = gx + 8.0; var gsy = gy + 12.0; var gi = 0
	for gift in gifts:
		var slot = app._panel(Vector2(gsx, gsy), Vector2(68, 64), Color(0.040, 0.034, 0.030, 0.74))
		app._view_container().add_child(slot)
		app._add_action_button(str(gift[0]), Vector2(gsx + 4, gsy + 14), gift[1], Vector2(60, 38))
		app._draw_red_dot(Vector2(gsx + 54, gsy + 4))
		gi += 1; gsx += 74
		if gi % 4 == 0:
			gsx = gx + 8; gsy += 72


func draw_chapter_info() -> void:
	# btnChapterInfo: right-anchored pos(-34,150), 276x100 (→212x96)
	# Godot: right edge = 1280 - 34*0.7665 = 1254, left = 1254 - 212 = 1042
	# y: 150*0.96 = 144 (from top, this is the center-y for center anchor)
	var px = 1042.0; var py = 144.0
	var bg = app._draw_image(UI_MAIN_CHAPTER_BG, Vector2(px, py), Vector2(212, 96), false, Color(1, 1, 1, 0.90))
	_main_panels.append(bg)
	var info = app._label("章节  %s\n奖励  收集 %d / 抽卡 %d" % [app._next_task_text(), app.save.get("owned", {}).size(), int(app.save.get("draw_count", 0))], 15)
	info.position = Vector2(px + 14, py + 16); info.size = Vector2(180, 60)
	app._view_container().add_child(info)
	app._add_action_button("", Vector2(px, py), app._show_tasks, Vector2(212, 96))
	app._draw_red_dot(Vector2(px + 8, py + 4))


func draw_bottom_bar() -> void:
	# pnlBottom: anchor(0,1) pos(64,-673) height=50 → Godot: x=49, y=720-646=74→673 from top
	var bar_y = 673.0; var bar_h = 48.0
	var bar = app._panel(Vector2(49, bar_y), Vector2(1231, bar_h), Color(0.026, 0.022, 0.020, 0.90))
	app._view_container().add_child(bar); _main_panels.append(bar)
	app._view_container().add_child(app._panel(Vector2(49, bar_y - 2), Vector2(1231, 2), Color(0.86, 0.65, 0.32, 0.26)))
	# 6 buttons: 86x50 each (→66x48), starting after pnlGal (115x50→88x48)
	var buttons = [
		["武将", app._show_gallery, true],
		["背包", app._show_shop, false],
		["宠物", app._show_home, false],
		["养成", app._show_gallery, true],
		["任务", app._show_tasks, true],
		["军团", app._show_home, false]
	]
	var bw = 66.0; var bx = 49.0 + 88  # after gal slot
	for item in buttons:
		app._draw_image(UI_MAIN_BOTTOM_BTN, Vector2(bx, bar_y), Vector2(bw, bar_h), false, Color(1, 1, 1, 0.34))
		app._add_action_button(str(item[0]), Vector2(bx, bar_y), item[1], Vector2(bw, bar_h))
		app._draw_image(UI_MAIN_SEPARATOR, Vector2(bx + bw + 2, bar_y + 16), Vector2(2, 16), false, Color(1, 1, 1, 0.55))
		if item[2]: app._draw_red_dot(Vector2(bx + bw - 18, bar_y))
		bx += bw + 8


func draw_gal_button() -> void:
	# pnlGal + btnGal: 115x129 (→88x124), pos(0,40) protruding above pnlBottom(673)
	# Godot: gal top = 673 - 40*0.96 - 124 + bar_h... prefab: gal protrudes 79px (40+129-50=119 → 91px in Godot)
	var gx = 49.0; var gy = 673.0 - 79
	app._draw_image(UI_MAIN_GAL, Vector2(gx, gy), Vector2(88, 124), false, Color(1, 1, 1, 0.92))
	app._add_action_button("约会", Vector2(gx + 8, gy + 88), enter_gal_entry, Vector2(72, 36))
	app._draw_red_dot(Vector2(gx + 68, gy + 8))


func draw_chat_bar() -> void:
	# pnlChat: right-anchored pos(-64,-94), 410x40 (→314x38)
	# Godot: x = 1280 - 64*0.7665 = 1231, y = 94*0.96 = 90 (from top)
	var cx = 1231.0 - 157; var cy = 90.0  # center-anchored: left = center - width/2
	var bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), Vector2(314, 38), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bg)
	var chat = app._label("世界  离线模式已启用", 14)
	chat.position = Vector2(cx + 49, cy + 8); chat.size = Vector2(255, 22)
	chat.modulate = Color(0.68, 0.64, 0.58)
	app._view_container().add_child(chat)
	app._add_action_button("", Vector2(cx, cy), app._show_mail, Vector2(314, 38))


# ═══════════════════════════════════════════════════════════════
# Hero portrait utility
# ═══════════════════════════════════════════════════════════════

func draw_cover_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint: Color) -> void:
	var texture = app._hero_portrait_texture(hero)
	if texture == null: return
	var rect = TextureRect.new()
	rect.texture = texture; rect.position = pos; rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.modulate = tint
	app._view_container().add_child(rect)
