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
	app._draw_image(UI_MAIN_GAL, Vector2(0, 0), Vector2(1280, 80), false, Color(1, 1, 1, 0.7))
	app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.028, 0.022, 0.018, 0.92)))
	var title = app._label("约会", 36, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(440, 80)
	title.size = Vector2(400, 52)
	app.content.add_child(title)
	var hint = app._label("Gal / 约会入口 — 原游戏完整实现待反向\n红点键: Gal.GalEntry.5799", 18, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(300, 180)
	hint.size = Vector2(680, 60)
	hint.modulate = Color(0.72, 0.68, 0.56)
	app.content.add_child(hint)
	app._add_action_button("返回主界面", Vector2(524, 380), enter_normal_state, Vector2(232, 50))

# ── Shared Layers ──

func draw_wallpaper_layer(hero: Dictionary) -> void:
	var bg = app._draw_image(UI_MAIN_BG, Vector2(110, -4), Vector2(1060, 728), true)
	app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.010, 0.008, 0.05)))
	app._draw_hero_stage(hero, Vector2(470, -2), Vector2(500, 682), false)

func draw_top_bar() -> void:
	var bar = app._draw_image(UI_MAIN_TOP_ACCENT, Vector2(376, 0), Vector2(560, 50), false, Color(1, 1, 1, 0.62))
	_main_panels.append(bar)
	var resources = [
		["邮件", app._unclaimed_mail_count()],
		["喚灵券", app.save.get("tickets", 0)],
		["源石", app.save.get("gems", 0)]
	]
	var x = 828.0
	for item in resources:
		var icon = app._panel(Vector2(x, 13), Vector2(26, 26), Color(0.58, 0.45, 0.22, 0.74))
		app.content.add_child(icon)
		var text = app._label("%s %s" % [item[0], item[1]], 16)
		text.position = Vector2(x + 32, 10)
		text.size = Vector2(130, 32)
		text.modulate = Color(0.96, 0.90, 0.80)
		app.content.add_child(text)
		x += 148

func draw_player_info(hero: Dictionary) -> void:
	var profile = app.save.get("profile", {})
	var panel = app._draw_image(UI_MAIN_PLAYER_FRAME, Vector2(0, 5), Vector2(354, 113), false, Color(1, 1, 1, 0.94))
	_main_panels.append(panel)
	app._draw_image(UI_MAIN_AVATAR_RING, Vector2(64, 31), Vector2(80, 80), false, Color(1, 1, 1, 0.94))
	draw_cover_portrait(hero, Vector2(74, 40), Vector2(60, 60), Color(1, 1, 1, 0.95))
	app._draw_image(UI_MAIN_EXP_RING, Vector2(59, 26), Vector2(90, 90), false, Color(1, 0.84, 0.28, 0.88))
	var lv = app._label("Lv.%d" % int(profile.get("level", 1)), 13, HORIZONTAL_ALIGNMENT_CENTER)
	lv.position = Vector2(70, 96)
	lv.size = Vector2(68, 16)
	lv.modulate = Color(0.96, 0.88, 0.52)
	app.content.add_child(lv)
	var pname = app._label(str(profile.get("name", "Player")), 20)
	pname.position = Vector2(150, 28)
	pname.size = Vector2(110, 28)
	app.content.add_child(pname)
	var power = app._label("战力 %d" % app._player_power(), 16)
	power.position = Vector2(150, 58)
	power.size = Vector2(176, 28)
	power.modulate = Color(0.84, 0.74, 0.24)
	app.content.add_child(power)
	var player_btn = Button.new()
	player_btn.text = ""
	player_btn.flat = true
	player_btn.position = Vector2(0, 5)
	player_btn.size = Vector2(354, 92)
	player_btn.pressed.connect(app._show_player_info)
	app.content.add_child(player_btn)
	# btnChange (swap wallpaper hero) — prefab: 74×74, pos=(402,-47) relative to pnlPlayerInfo
	app._add_action_button("换", Vector2(365, 15), app._show_gallery, Vector2(74, 74))
	# btnEye (toggle to wallpaper_focus) — prefab: 74×74, pos=(478,-47)
	app._add_action_button("眼", Vector2(441, 15), enter_wallpaper_focus, Vector2(74, 74))

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
	var bar = app._panel(Vector2(0, 646), Vector2(1280, 50), Color(0.026, 0.022, 0.020, 0.90))
	app.content.add_child(bar)
	_main_panels.append(bar)
	app.content.add_child(app._panel(Vector2(0, 644), Vector2(1280, 2), Color(0.86, 0.65, 0.32, 0.26)))
	var buttons = [
		["武将", app._show_gallery, true],
		["背包", app._show_shop, false],
		["宠物", app._show_home, false],
		["养成", app._show_gallery, true],
		["任务", app._show_tasks, true],
		["军团", app._show_home, false]
	]
	# Bottom buttons start after gal slot (shifted right)
	var bx = 200.0
	for item in buttons:
		var img = app._draw_image(UI_MAIN_BOTTOM_BTN, Vector2(bx, 598), Vector2(86, 86), false, Color(1, 1, 1, 0.34))
		_main_panels.append(img)
		app._add_action_button(str(item[0]), Vector2(bx, 646), item[1], Vector2(86, 50))
		app._draw_image(UI_MAIN_SEPARATOR, Vector2(bx + 92, 662), Vector2(2, 18), false, Color(1, 1, 1, 0.55))
		if item[2]:
			app._draw_red_dot(Vector2(bx + 68, 642))
		bx += 96

# ── btnGal: independent entry (NOT part of bottom bar) ──

func draw_gal_entry_button() -> void:
	# prefab: 115×129, pos=(0,40), pnlGal anchor=(0,0) bottom-left
	# Independent red dot key: Gal.GalEntry.5799
	var icon = app._draw_image(UI_MAIN_GAL, Vector2(64, 567), Vector2(115, 129), false, Color(1, 1, 1, 0.92))
	_main_panels.append(icon)
	app._add_action_button("约会", Vector2(76, 654), enter_gal_entry, Vector2(92, 42))
	app._draw_red_dot(Vector2(152, 577))

func draw_chat_bar() -> void:
	var bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(806, 94), Vector2(410, 40), false, Color(1, 1, 1, 0.72))
	_main_panels.append(bg)
	var chat = app._label("世界  离线模式已启用", 14)
	chat.position = Vector2(870, 102)
	chat.size = Vector2(330, 24)
	chat.modulate = Color(0.68, 0.64, 0.58)
	app.content.add_child(chat)
	app._add_action_button("", Vector2(806, 94), app._show_mail, Vector2(410, 40))

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
