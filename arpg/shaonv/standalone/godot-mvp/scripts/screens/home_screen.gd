# UTF-8 source. MainUIView with state machine (listPanel + ShowOrHide).
# Based on C# IL evidence from MainUIView.il.txt:
#   listPanel = [pnlChat, pnlFunny, pnlPlayerInfo, pnlCommercialization, btnChapterInfo, pnlBottom]
#   ShowOrHide() toggles listPanel + TopBar + btnBodyMask + btnEye/btnChange
# States: main_normal, wallpaper_focus, gal_entry
extends RefCounted

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
var _main_state: String = "normal"   # normal | wallpaper_focus | gal_entry
var _main_panels: Array = []         # listPanel nodes for bulk show/hide

func _init(app_ref) -> void:
	app = app_ref

# ── State: main_normal ──

func show_home() -> void:
	app.current_view = "main"
	app.content.position = Vector2(0, 0)
	app.content.size = Vector2(1280, 720)
	app._set_chrome_visible(false)
	app._clear("主界面")
	_main_panels.clear()
	enter_normal_state()

func enter_normal_state() -> void:
	_main_state = "normal"
	app._clear("主界面")
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
	draw_wallpaper_layer(hero)
	draw_top_bar()
	draw_player_info(hero)
	draw_funny_panel()
	draw_commercialization_panel()
	draw_chapter_panel()
	draw_bottom_bar()
	draw_chat_bar()
	draw_gal_entry_button()
	# Wallpaper toggle (btnEye → focus, btnBodyMask → back to normal)
	draw_wallpaper_toggles()

# ── State: wallpaper_focus ──

func enter_wallpaper_focus() -> void:
	_main_state = "wallpaper_focus"
	app._clear("壁纸")
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
	draw_wallpaper_layer(hero)
	var ctl_y = 680.0
	app._add_action_button("◀", Vector2(528, ctl_y), app._show_home, Vector2(44, 44))
	app._add_action_button("▶", Vector2(580, ctl_y), app._show_home, Vector2(44, 44))
	app._add_action_button("▶▶", Vector2(632, ctl_y), app._show_home, Vector2(48, 44))
	app._add_action_button("壁纸", Vector2(695, ctl_y), app._show_gallery, Vector2(64, 44))
	app._add_action_button("眼", Vector2(768, ctl_y), enter_normal_state, Vector2(56, 44))

func draw_wallpaper_toggles() -> void:
	# Body mask: full-screen transparent button to toggle focus
	var mask = Button.new()
	mask.text = ""
	mask.flat = true
	mask.position = Vector2(0, 0)
	mask.size = Vector2(1280, 720)
	mask.modulate = Color(1, 1, 1, 0.0)
	mask.pressed.connect(enter_wallpaper_focus)
	app.content.add_child(mask)
	_main_panels.append(mask)

# ── State: gal_entry ──

func enter_gal_entry() -> void:
	_main_state = "gal_entry"
	app._clear("约会")
	# Dimmed wallpaper backdrop
	app._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1278, 720), true, Color(1, 1, 1, 0.22))
	# Full-screen dark overlay
	app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.016, 0.012, 0.020, 0.90)))
	var hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
	# ── Top bar ──
	var top_bar = app._panel(Vector2(0, 0), Vector2(1280, 60), Color(0.024, 0.018, 0.028, 0.72))
	app.content.add_child(top_bar)
	app.content.add_child(app._panel(Vector2(0, 58), Vector2(1280, 2), Color(0.76, 0.54, 0.28, 0.28)))
	app._add_action_button("← 返回", Vector2(18, 8), enter_normal_state, Vector2(100, 44))
	var title = app._label("约 会", 28, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(440, 12)
	title.size = Vector2(400, 36)
	title.modulate = Color(0.94, 0.86, 0.64)
	app.content.add_child(title)
	# ── Hero portrait card (center) ──
	var card_x = 315.0
	var card_y = 85.0
	var card_w = 650.0
	var card_h = 420.0
	app.content.add_child(app._panel(Vector2(card_x, card_y), Vector2(card_w, card_h), Color(0.030, 0.022, 0.036, 0.68)))
	app.content.add_child(app._panel(Vector2(card_x + 4, card_y + 4), Vector2(card_w - 8, card_h - 8), Color(0.045, 0.034, 0.052, 0.40)))
	# Hero stage (large portrait)
	app._draw_hero_stage(hero, Vector2(card_x + 30, card_y + 30), Vector2(320, 360), false)
	# Portrait frame rings
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(card_x + 148, card_y + 26), Vector2(84, 84), false, Color(1, 1, 1, 0.78))
	app._draw_image(UI_MAIN_EXP_RING, Vector2(card_x + 142, card_y + 20), Vector2(96, 96), false, Color(1, 0.84, 0.28, 0.72))
	# Hero info (right side of card)
	var info_x = card_x + 370
	var info_y = card_y + 40
	var hname = app._label(str(hero.get("name", "???")) if hero else "???", 24)
	hname.position = Vector2(info_x, info_y)
	hname.size = Vector2(240, 32)
	hname.modulate = Color(0.98, 0.94, 0.80)
	app.content.add_child(hname)
	var htitle = app._label(str(hero.get("title", "")) if hero else "", 16)
	htitle.position = Vector2(info_x, info_y + 36)
	htitle.size = Vector2(240, 22)
	htitle.modulate = Color(0.72, 0.66, 0.52)
	app.content.add_child(htitle)
	# Bond/affection indicator (好感度)
	var bond_label = app._label("好感度", 14, HORIZONTAL_ALIGNMENT_CENTER)
	bond_label.position = Vector2(info_x, info_y + 72)
	bond_label.size = Vector2(56, 18)
	bond_label.modulate = Color(0.64, 0.58, 0.48)
	app.content.add_child(bond_label)
	var bond_bar_bg = app._panel(Vector2(info_x + 60, info_y + 74), Vector2(160, 12), Color(0.08, 0.06, 0.12, 0.70))
	app.content.add_child(bond_bar_bg)
	var bond_val = 34.0  # placeholder bond level %
	var bond_bar = app._panel(Vector2(info_x + 60, info_y + 74), Vector2(bond_val * 1.6, 12), Color(0.92, 0.38, 0.56, 0.78))
	app.content.add_child(bond_bar)
	# Hero level
	var hlvl = app._label("Lv.%d" % int(hero.get("level", 1)) if hero else "Lv.1", 14)
	hlvl.position = Vector2(info_x, info_y + 100)
	hlvl.size = Vector2(80, 18)
	hlvl.modulate = Color(0.86, 0.80, 0.56)
	app.content.add_child(hlvl)
	# ── Navigation arrows ──
	app._add_action_button("◀", Vector2(card_x - 56, card_y + 180), app._show_home, Vector2(44, 56))
	app._add_action_button("▶", Vector2(card_x + card_w + 12, card_y + 180), app._show_home, Vector2(44, 56))
	# ── Separator line below card ──
	app.content.add_child(app._panel(Vector2(card_x, card_y + card_h + 14), Vector2(card_w, 1), Color(0.76, 0.54, 0.28, 0.18)))
	# ── Action buttons row (bottom) ──
	var abtn_y = 535.0
	var abtn_w = 170.0
	var abtn_h = 72.0
	var abtn_gap = 22.0
	var abtn_total = 3 * abtn_w + 2 * abtn_gap
	var abtn_start = (1280.0 - abtn_total) * 0.5
	var actions = [
		["互动", "💬 对话", app._show_mail],
		["送礼", "🎁 赠礼", app._show_shop],
		["约会", "💕 邀约", app._show_home]
	]
	for i in range(actions.size()):
		var ax = abtn_start + i * (abtn_w + abtn_gap)
		app.content.add_child(app._panel(Vector2(ax, abtn_y), Vector2(abtn_w, abtn_h), Color(0.040, 0.030, 0.048, 0.74)))
		app.content.add_child(app._panel(Vector2(ax + 1, abtn_y + 1), Vector2(abtn_w - 2, abtn_h - 2), Color(0.055, 0.042, 0.064, 0.50)))
		var albl = app._label(str(actions[i][1]), 16, HORIZONTAL_ALIGNMENT_CENTER)
		albl.position = Vector2(ax, abtn_y + 14)
		albl.size = Vector2(abtn_w, 22)
		albl.modulate = Color(0.86, 0.80, 0.68)
		app.content.add_child(albl)
		app._add_action_button(str(actions[i][0]), Vector2(ax + 2, abtn_y + 38), actions[i][2], Vector2(abtn_w - 4, 32))
		if i == 2:
			app._draw_red_dot(Vector2(ax + abtn_w - 22, abtn_y + 8))
	# ── Status bar at very bottom ──
	var status_bar = app._panel(Vector2(0, 688), Vector2(1280, 32), Color(0.020, 0.016, 0.028, 0.64))
	app.content.add_child(status_bar)
	var status_text = app._label("Gal 约会系统  |  键: Gal.GalEntry.5799  |  完整实现待反向", 12, HORIZONTAL_ALIGNMENT_CENTER)
	status_text.position = Vector2(140, 694)
	status_text.size = Vector2(1000, 22)
	status_text.modulate = Color(0.52, 0.48, 0.42)
	app.content.add_child(status_text)

# ── Shared Layers ──

func draw_wallpaper_layer(hero: Dictionary) -> void:
	# Prefab: @WallpaperPanel anchor=(0.5,0.5) pos=(0,0) size=(1668,750)
	# Scaled to 1280x720: pos=(1,0) size=(1278,720)
	app._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1278, 720), true)
	app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.010, 0.008, 0.05)))
	# irole: anchor=(0.5,0.5) size=(958,750) → pos=(273,0) size=(734,720)
	app._draw_hero_stage(hero, Vector2(273, 0), Vector2(734, 720), false)

func draw_top_bar() -> void:
	# Prefab: @TopBar anchor=(0,1) pos=(0,-12) size=(0,60) → full-width y=12 h=58
	var bar = app._draw_image(UI_MAIN_TOP_ACCENT, Vector2(0, 12), Vector2(1280, 58), false, Color(1, 1, 1, 0.62))
	_main_panels.append(bar)
	var resources = [
		["邮件", app._unclaimed_mail_count()],
		["喚灵券", app.save.get("tickets", 0)],
		["源石", app.save.get("gems", 0)]
	]
	# svRes: anchor=(1,1) pos=(-790,-42) size=(1367,60) → x≈675 (right-anchored)
	var x = 675.0
	for item in resources:
		var icon = app._panel(Vector2(x, 24), Vector2(22, 22), Color(0.58, 0.45, 0.22, 0.74))
		app.content.add_child(icon)
		var text = app._label("%s %s" % [item[0], item[1]], 16)
		text.position = Vector2(x + 28, 22)
		text.size = Vector2(130, 28)
		text.modulate = Color(0.96, 0.90, 0.80)
		app.content.add_child(text)
		x += 148

func draw_player_info(hero: Dictionary) -> void:
	var profile = app.save.get("profile", {})
	# pnlPlayerInfo: anchor=(0,1) pos=(0,-5) size=(354,113) → (0,5) (271,108)
	var panel = app._draw_image(UI_MAIN_PLAYER_FRAME, Vector2(0, 5), Vector2(271, 108), false, Color(1, 1, 1, 0.94))
	_main_panels.append(panel)
	# imgHeadBg: pos=(104,8) size=(80,79) → (80,8) (61,76)
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(80, 8), Vector2(61, 76), false, Color(1, 1, 1, 0.94))
	draw_cover_portrait(hero, Vector2(86, 18), Vector2(50, 56), Color(1, 1, 1, 0.95))
	# imgExp: pos=(0,0) size=(90,90) → (74,14) (69,86)
	app._draw_image(UI_MAIN_EXP_RING, Vector2(74, 14), Vector2(69, 86), false, Color(1, 0.84, 0.28, 0.88))
	var lv = app._label("Lv.%d" % int(profile.get("level", 1)), 12, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = Vector2(82, 84)
	lv.size = Vector2(52, 14)
	lv.modulate = Color(0.96, 0.88, 0.52)
	app.content.add_child(lv)
	# txtName: pos=(154,22) size=(200,28) → (118,21) (153,27)
	var pname = app._label(str(profile.get("name", "Player")), 18)
	pname.position = Vector2(118, 21)
	pname.size = Vector2(66, 28)
	app.content.add_child(pname)
	# txtPower: pos=(181,-4) size=(173,37) → (139,-4) (133,36)
	var power = app._label("战力 %d" % app._player_power(), 14)
	power.position = Vector2(139, 45)
	power.size = Vector2(133, 32)
	power.modulate = Color(0.84, 0.74, 0.24)
	app.content.add_child(power)
	var player_btn = Button.new()
	player_btn.text = ""
	player_btn.flat = true
	player_btn.position = Vector2(0, 5)
	player_btn.size = Vector2(271, 108)
	player_btn.pressed.connect(app._show_player_info)
	app.content.add_child(player_btn)
	# btnChange: pos=(402,-47) size=(74,74) → (308,-45) (57,71)
	app._add_action_button("换", Vector2(308, 43), app._show_gallery, Vector2(57, 71))
	# btnEye: pos=(478,-47) size=(74,74) → (366,-45) (57,71)
	app._add_action_button("眼", Vector2(366, 43), enter_wallpaper_focus, Vector2(57, 71))

func draw_funny_panel() -> void:
	var actions = [
		[UI_MAIN_FUNNY_ARENA, "竞技", app._show_battle],
		[UI_MAIN_FUNNY_PRAYER, "祈愿", app._open_prayer_pool],
		[UI_MAIN_FUNNY_ADVENTURE, "冒险", app._show_battle],
		[UI_MAIN_FUNNY_DRAW, "喚灵", app._open_present_pool]
	]
	var x = 600.0
	var y = 599.0
	for item in actions:
		var img = app._draw_image(str(item[0]), Vector2(x, y), Vector2(88, 102), false, Color(1, 1, 1, 0.84))
		_main_panels.append(img)
		var button = Button.new()
		button.text = str(item[1])
		button.position = Vector2(x, y + 68)
		button.size = Vector2(88, 34)
		button.pressed.connect(item[2])
		app.content.add_child(button)
		app._draw_red_dot(Vector2(x + 70, y + 4))
		x += 94
	var menu = app._draw_image(UI_MAIN_MENU, Vector2(1147, 15), Vector2(78, 78), false, Color(1, 1, 1, 0.92))
	_main_panels.append(menu)
	app._add_action_button("", Vector2(1147, 15), app._show_home, Vector2(78, 78))
	app._draw_red_dot(Vector2(1205, 21))
	# Story + Harvest row
	var story_bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(942, 603), Vector2(278, 98), false, Color(1, 1, 1, 0.88))
	_main_panels.append(story_bg)
	var story = app._label("主线 %s\n挂机收益 %s" % [app._next_task_text(), "可收取" if not app._afk_claimed_today() else "已收取"], 17)
	story.position = Vector2(966, 621)
	story.size = Vector2(148, 54)
	app.content.add_child(story)
	app._add_action_button("收获", Vector2(1106, 611), app._claim_afk_reward, Vector2(96, 76))
	app._draw_red_dot(Vector2(1108, 607))
	# Assist button — prefab: 78×96, pos=(413,-164) relative to pnlPlayerInfo
	var assist = app._draw_image(UI_MAIN_ASSIST, Vector2(374, 116), Vector2(78, 96), false, Color(1, 1, 1, 0.84))
	_main_panels.append(assist)
	app._add_action_button("援助", Vector2(378, 192), app._show_mail, Vector2(70, 34))

func draw_commercialization_panel() -> void:
	var banner = app._draw_image(UI_MAIN_BANNER, Vector2(57, 123), Vector2(304, 116), false, Color(1, 1, 1, 0.92))
	_main_panels.append(banner)
	app.content.add_child(app._panel(Vector2(64, 243), Vector2(409, 300), Color(0.030, 0.023, 0.018, 0.56)))
	var gifts = [
		["补给", app._show_daily], ["邮件", app._show_mail], ["签到", app._show_daily],
		["奖励", app._show_tasks], ["问答", app._show_home], ["礼包", app._show_shop],
		["月卡", app._show_shop], ["充值", app._show_shop], ["商店", app._show_shop]
	]
	var gx = 78.0
	var gy = 260.0
	var gi = 0
	for gift in gifts:
		var slot = app._panel(Vector2(gx, gy), Vector2(82, 68), Color(0.040, 0.034, 0.030, 0.74))
		app.content.add_child(slot)
		app._add_action_button(str(gift[0]), Vector2(gx + 4, gy + 14), gift[1], Vector2(74, 42))
		app._draw_red_dot(Vector2(gx + 66, gy + 4))
		gi += 1
		gx += 96
		if gi % 4 == 0:
			gx = 78
			gy += 82
	# pnlCharge vertical buttons — prefab: 158×258, right-top anchor
	var labels = [["活动", app._show_daily], ["福利", app._show_daily], ["月卡", app._show_shop], ["充值", app._show_shop], ["商店", app._show_shop]]
	var cx = 1067.0
	var cy = 148.0
	for i in range(labels.size()):
		var icon = app._draw_image(str(UI_MAIN_CHARGE_ICONS[i]), Vector2(cx, cy), Vector2(78, 78), false, Color(1, 1, 1, 0.86))
		_main_panels.append(icon)
		app._add_action_button(str(labels[i][0]), Vector2(cx + 4, cy + 52), labels[i][1], Vector2(70, 34))
		app._draw_red_dot(Vector2(cx + 60, cy + 2))
		cy += 82

func draw_chapter_panel() -> void:
	var bg = app._draw_image(UI_MAIN_CHAPTER_BG, Vector2(970, 470), Vector2(276, 100), false, Color(1, 1, 1, 0.90))
	_main_panels.append(bg)
	var info = app._label("章节  %s\n奖励  收集 %d / 抽卡 %d" % [
		app._next_task_text(),
		app.save.get("owned", {}).size(),
		int(app.save.get("draw_count", 0))
	], 16)
	info.position = Vector2(994, 486)
	info.size = Vector2(220, 62)
	app.content.add_child(info)
	app._add_action_button("", Vector2(970, 470), app._show_tasks, Vector2(276, 100))
	app._draw_red_dot(Vector2(982, 478))

func draw_bottom_bar() -> void:
	# Prefab: pnlBottom anchor=(0,0) pos=(64,49) size=(0,50)
	# Scale: y=49*0.96≈47, h=50*0.96=48, x=64*0.766≈49
	var bar_y = 720.0 - 48 - 47  # bottom-anchored
	var bar_h = 48
	var bar = app._panel(Vector2(49, bar_y), Vector2(1280 - 49, bar_h), Color(0.026, 0.022, 0.020, 0.90))
	app.content.add_child(bar)
	_main_panels.append(bar)
	app.content.add_child(app._panel(Vector2(49, bar_y - 2), Vector2(1280 - 49, 2), Color(0.86, 0.65, 0.32, 0.26)))
	var buttons = [
		["武将", app._show_gallery, true],
		["背包", app._show_shop, false],
		["宠物", app._show_home, false],
		["养成", app._show_gallery, true],
		["任务", app._show_tasks, true],
		["军团", app._show_home, false]
	]
	# Prefab: buttons are 86×50 each (not 86×86!)
	var btn_w = 66  # 86*0.766≈66
	var btn_h = 48  # 50*0.96=48
	var bx = 49.0 + 88  # pnlGal(115*0.766≈88) starts at x=49, buttons after gal
	for item in buttons:
		app._draw_image(UI_MAIN_BOTTOM_BTN, Vector2(bx, bar_y), Vector2(btn_w, btn_h), false, Color(1, 1, 1, 0.34))
		app._add_action_button(str(item[0]), Vector2(bx, bar_y), item[1], Vector2(btn_w, btn_h))
		app._draw_image(UI_MAIN_SEPARATOR, Vector2(bx + btn_w + 2, bar_y + 16), Vector2(2, 18), false, Color(1, 1, 1, 0.55))
		if item[2]:
			app._draw_red_dot(Vector2(bx + btn_w - 18, bar_y))
		bx += btn_w + 8

# ── btnGal: independent entry (NOT part of bottom bar) ──

func draw_gal_entry_button() -> void:
	# Prefab: pnlGal pos=(0,0) size=(115,50), btnGal pos=(0,40) size=(115,129)
	# pnlBottom starts at y=625 (720-48-47), pnlGal at y=625, btnGal protrudes up to y=625-79=546
	# btnGal: (49,546) size=(88,124)
	var gal_x = 49.0
	var gal_y = 625.0 - 79
	app._draw_image(UI_MAIN_GAL, Vector2(gal_x, gal_y), Vector2(88, 124), false, Color(1, 1, 1, 0.92))
	app._add_action_button("约会", Vector2(gal_x + 8, gal_y + 88), enter_gal_entry, Vector2(72, 36))
	app._draw_red_dot(Vector2(gal_x + 68, gal_y + 8))

func draw_chat_bar() -> void:
	# Prefab: pnlChat anchor=(1,1) pos=(-64,-94) size=(410,40)
	# Scale: x=1280-(64+410)*0.766≈917, y=720-(94+40)*0.96≈591, size=(314,38)
	var cx = 917.0
	var cy = 591.0
	var cw = 314.0
	var ch = 38.0
	var bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), Vector2(cw, ch), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bg)
	# @txtChat: pos=(64,0) size=(341,40) → (cx+49, cy) (261,38)
	var chat = app._label("世界  离线模式已启用", 14)
	chat.position = Vector2(cx + 49, cy + 8)
	chat.size = Vector2(261, 22)
	chat.modulate = Color(0.68, 0.64, 0.58)
	app.content.add_child(chat)
	app._add_action_button("", Vector2(cx, cy), app._show_mail, Vector2(cw, ch))

# ── Hero Portrait Utility ──

func draw_cover_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint: Color) -> void:
	var texture = app._hero_portrait_texture(hero)
	if texture == null:
		return
	var rect = TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.modulate = tint
	app.content.add_child(rect)
