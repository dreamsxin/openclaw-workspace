# UTF-8 source. Startup chain reconstructed from LaunchView/LoginView/LoadingView prefabs.
extends RefCounted

const UI_LOGIN_BG = "res://assets/ui/background/login_bg_01.png"
const UI_LOGIN_BTN = "res://assets/ui/login/login_btn_03.png"
const UI_LOGIN_LOGO = "res://assets/ui/login/login_txt_02.png"  # prefab: imgLogo → login_txt_02
const UI_LOGIN_SERVER_BG = "res://assets/ui/login/server_bg_03.png"
const UI_LOGIN_SERVER_SELECT_BG = "res://assets/ui/login/login_img_01.png"
const UI_LOGIN_SERVER_STATUS = "res://assets/ui/login/login_img_02.png"
# Function buttons (pnlFunction)
const UI_LOGIN_BTN_NOTICE = "res://assets/ui/login/login_btn_01.png"    # btnNotice
const UI_LOGIN_BTN_REPAIR = "res://assets/ui/login/login_btn_02.png"    # btnRepair
const UI_LOGIN_BTN_SWITCH = "res://assets/ui/login/login_btn_05.png"    # btnSwitchAccount
const UI_LOGIN_BTN_SELECT = "res://assets/ui/login/login_btn_06.png"    # btnSelect
const UI_LOGIN_INPUT_BG = "res://assets/ui/login/login_img_03.png"      # inputAccount bg
const UI_LOGIN_INPUT_ICON = "res://assets/ui/login/login_img_04.png"    # input icon
const UI_LOGIN_AGE = "res://assets/ui/login/login_txt_03.png"           # btnAge 12+
const UI_LOGIN_TIP = "res://assets/ui/login/login_txt_01.png"           # imgTipLogin
const UI_COMMON_TOGGLE_BG = "res://assets/ui/common/common_btn_09.png"
const UI_COMMON_TOGGLE_CHECK = "res://assets/ui/common/common_btn_10.png"
const UI_LOADING_BG = "res://assets/ui/background/loading_bg_01.png"
const UI_LOADING_TRACK = "res://assets/ui/loading/update_img_01.png"
const UI_LOADING_FILL = "res://assets/ui/loading/update_img_02.png"
const UI_LOADING_HANDLE = "res://assets/ui/loading/update_img_03.png"
const UI_LAUNCH_VIDEO = "res://assets/video/game_start.ogv"
const LAUNCH_VIDEO_SECONDS := 15.8
const LOGIN_PREFAB_SIZE := Vector2(1670, 750)
const LOGIN_SCALE := Vector2(1280.0 / 1670.0, 720.0 / 750.0)
const LAUNCH_RAW_IMAGE_POS := Vector2(-3, -446)
const LAUNCH_RAW_IMAGE_SIZE := Vector2(1287, 1613)

var app

func _init(app_ref) -> void:
	app = app_ref

func _login_size(prefab_size: Vector2) -> Vector2:
	return Vector2(prefab_size.x * LOGIN_SCALE.x, prefab_size.y * LOGIN_SCALE.y)

func _login_center_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((835.0 + center.x - size.x * 0.5) * LOGIN_SCALE.x, (375.0 - center.y - size.y * 0.5) * LOGIN_SCALE.y)

func _login_left_top_pos(anchor_pos: Vector2, size: Vector2) -> Vector2:
	return Vector2(anchor_pos.x * LOGIN_SCALE.x, (-anchor_pos.y) * LOGIN_SCALE.y)

func _login_left_bottom_center_pos(center: Vector2, size: Vector2) -> Vector2:
	return Vector2((center.x - size.x * 0.5) * LOGIN_SCALE.x, (750.0 - center.y - size.y * 0.5) * LOGIN_SCALE.y)

func _login_right_bottom_pos(offset: Vector2, size: Vector2) -> Vector2:
	return Vector2((1670.0 + offset.x - size.x) * LOGIN_SCALE.x, (750.0 - offset.y - size.y) * LOGIN_SCALE.y)

func _login_center_top_pos(offset: Vector2, size: Vector2) -> Vector2:
	return Vector2((835.0 + offset.x - size.x * 0.5) * LOGIN_SCALE.x, (-offset.y) * LOGIN_SCALE.y)

func _login_child_center_pos(parent_pos: Vector2, parent_prefab_size: Vector2, child_center: Vector2, child_prefab_size: Vector2) -> Vector2:
	return parent_pos + _login_size(Vector2(
		parent_prefab_size.x * 0.5 + child_center.x - child_prefab_size.x * 0.5,
		parent_prefab_size.y * 0.5 - child_center.y - child_prefab_size.y * 0.5
	))

func _login_function_pos(index: int, size: Vector2) -> Vector2:
	var panel_center_x := 1670.0 - 65.672607421875
	var x := panel_center_x - size.x * 0.5
	var y := 185.0 + float(index) * 76.0
	return Vector2(x * LOGIN_SCALE.x, y * LOGIN_SCALE.y)

func _pulse_alpha(node: CanvasItem, low := 0.45, high := 1.0, duration := 0.75) -> void:
	node.modulate.a = high
	var tween: Tween = app.create_tween()
	tween.set_loops()
	tween.tween_property(node, "modulate:a", low, duration)
	tween.tween_property(node, "modulate:a", high, duration)

func show_launch() -> void:
	app.current_view = "launch"
	print("Shaonv MVP show launch: heroes=%d pools=%d" % [app.heroes.size(), app.pools.size()])
	app._set_chrome_visible(false)
	app._clear("启动")

	# LaunchView: Image (fullscreen black) + RawImage (1680×1680, anchor 0.5-0.5 居中)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.0, 0.0, 0.0, 1.0)))
	var played_video := _draw_launch_video()
	if not played_video:
		# RawImage: 1680×1680 center-anchored → Godot: 1287×1613 centered at (640,360) → top-left (-3,-446)
		app._view_container().add_child(app._panel(LAUNCH_RAW_IMAGE_POS, LAUNCH_RAW_IMAGE_SIZE, Color(0.0, 0.0, 0.0, 1.0)))

	var hint = app._label("少女回战 · 离线单机版", 18, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(440, 640)
	hint.size = Vector2(400, 36)
	hint.modulate = Color(0.78, 0.72, 0.62, 1.0)
	app._view_container().add_child(hint)
	hint.visible = false
	_draw_launch_skip_controls()

func _draw_launch_video() -> bool:
	if not ResourceLoader.exists(UI_LAUNCH_VIDEO):
		return false
	var stream := load(UI_LAUNCH_VIDEO)
	if stream == null:
		return false
	var video := VideoStreamPlayer.new()
	video.stream = stream
	video.position = LAUNCH_RAW_IMAGE_POS
	video.size = LAUNCH_RAW_IMAGE_SIZE
	video.expand = true
	video.autoplay = true
	video.modulate.a = 0.0
	video.finished.connect(func() -> void:
		if app.current_view == "launch":
			app._show_login()
	)
	app._view_container().add_child(video)
	var tween: Tween = app.create_tween()
	tween.tween_property(video, "modulate:a", 1.0, 0.1).set_delay(0.1)
	video.play()
	return true

func _draw_launch_skip_controls() -> void:
	var skip_label: Label = app._label("点击跳过", 18, HORIZONTAL_ALIGNMENT_CENTER)
	skip_label.position = Vector2(1084, 638)
	skip_label.size = Vector2(126, 34)
	skip_label.modulate = Color(0.94, 0.88, 0.74, 0.86)
	app._view_container().add_child(skip_label)
	skip_label.visible = false
	app._add_hit_button(Vector2(0, 0), Vector2(1280, 720), app._skip_launch_video)

func show_preloading() -> void:
	app.current_view = "preloading"
	app._set_chrome_visible(false)
	app._clear("预载入")
	app._draw_image(UI_LOGIN_BG, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.64))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.014, 0.018, 0.48)))

	var mark = app._label("少女回战", 44, HORIZONTAL_ALIGNMENT_CENTER)
	mark.position = Vector2(390, 204)
	mark.size = Vector2(500, 66)
	app._view_container().add_child(mark)
	var info = app._label("正在校验本地资源", 24, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = Vector2(360, 292)
	info.size = Vector2(560, 40)
	app._view_container().add_child(info)
	app._draw_progress_bar(Vector2(376, 374), Vector2(528, 20), 0.65)
	var percent = app._label("65%", 18, HORIZONTAL_ALIGNMENT_CENTER)
	percent.position = Vector2(586, 404)
	percent.size = Vector2(108, 28)
	app._view_container().add_child(percent)
	var tip = app._label("预载入角色、喚灵与静态表数据", 18, HORIZONTAL_ALIGNMENT_CENTER)
	tip.position = Vector2(330, 456)
	tip.size = Vector2(620, 34)
	tip.modulate = Color(0.78, 0.72, 0.62)
	app._view_container().add_child(tip)
	app._add_action_button("继续", Vector2(574, 522), app._show_login, Vector2(132, 46))

func show_login() -> void:
	app.current_view = "login"
	app._set_chrome_visible(false)
	app._clear("Login")

	app._draw_image(UI_LOGIN_BG, Vector2.ZERO, Vector2(1280, 720), true)
	app._add_hit_button(Vector2.ZERO, Vector2(1280, 720), app._show_loading)

	var logo_size := _login_size(Vector2(260, 104) * 0.8)
	var logo_pos := _login_left_top_pos(Vector2(61, -129), Vector2(260, 104) * 0.8)
	if app._draw_image(UI_LOGIN_LOGO, logo_pos, logo_size, false) == null:
		var logo = app._label("Shaonv", 42, HORIZONTAL_ALIGNMENT_CENTER)
		logo.position = logo_pos
		logo.size = logo_size
		app._view_container().add_child(logo)

	var age_size := _login_size(Vector2(83, 104) * 0.8)
	var age_pos := _login_left_bottom_center_pos(Vector2(90, 154), Vector2(83, 104) * 0.8)
	app._draw_image(UI_LOGIN_AGE, age_pos, age_size, false)
	app._add_hit_button(age_pos, age_size, app._show_login)

	var version_pos := _login_right_bottom_pos(Vector2(-13, 114), Vector2(332, 96))
	var version_line_size := _login_size(Vector2(332, 30))
	var version_lines := ["Ver 1.0.0", "App v1.18", "Res v1.18"]
	for i in range(version_lines.size()):
		var ver = app._label(str(version_lines[i]), 14, HORIZONTAL_ALIGNMENT_RIGHT)
		ver.position = version_pos + Vector2(0, version_line_size.y * i)
		ver.size = version_line_size
		ver.modulate = Color(0.68, 0.64, 0.58)
		app._view_container().add_child(ver)

	var input_size := _login_size(Vector2(543, 64))
	var input_pos := _login_center_pos(Vector2(0, -114.5), Vector2(543, 64))
	app._draw_image(UI_LOGIN_INPUT_BG, input_pos, input_size, false, Color(1, 1, 1, 0.95))
	var input_prefab_size := Vector2(543, 64)
	app._draw_image(UI_LOGIN_INPUT_ICON, _login_child_center_pos(input_pos, input_prefab_size, Vector2(-239.1, 0), Vector2(40, 40)), _login_size(Vector2(40, 40)), false)
	var account_label = app._label("账号", 18, HORIZONTAL_ALIGNMENT_CENTER)
	account_label.position = input_pos + _login_size(Vector2(18, 0))
	account_label.size = _login_size(Vector2(96, 64))
	account_label.modulate = Color(0.56, 0.48, 0.40, 0.92)
	app._view_container().add_child(account_label)
	var account = LineEdit.new()
	account.text = "LocalPlayer"
	account.placeholder_text = "输入账号..."
	account.position = _login_child_center_pos(input_pos, input_prefab_size, Vector2(160.8, 0), Vector2(362.7, 63.9))
	account.size = _login_size(Vector2(362.7, 63.9))
	account.flat = true
	app._view_container().add_child(account)

	var buttons := [
		{"icon": UI_LOGIN_BTN_NOTICE, "callback": app._show_login_notice_popup},
		{"icon": UI_LOGIN_BTN_REPAIR, "callback": app._show_repair_popup},
		{"icon": UI_LOGIN_BTN_SWITCH, "callback": app._show_login_account_popup},
		{"icon": UI_LOGIN_BTN_SELECT, "callback": app._show_login},
	]
	for index in range(buttons.size()):
		var button_size := _login_size(Vector2(60, 60))
		var button_pos := _login_function_pos(index, Vector2(60, 60))
		app._draw_image(str(buttons[index].get("icon", "")), button_pos, button_size, false)
		app._add_hit_button(button_pos, button_size, buttons[index].get("callback"))

	var server_size := _login_size(Vector2(500, 34))
	var server_pos := _login_center_pos(Vector2(0, -99), Vector2(500, 34))
	var server_group := Control.new()
	server_group.name = "btnServerSel"
	server_group.position = server_pos
	server_group.size = server_size
	server_group.visible = false
	app._view_container().add_child(server_group)
	var server_bg: TextureRect = app._draw_image(UI_LOGIN_SERVER_SELECT_BG, server_pos, server_size, false)
	if server_bg != null:
		server_bg.reparent(server_group)
		server_bg.position = Vector2.ZERO
	var server_status: TextureRect = app._draw_image(UI_LOGIN_SERVER_STATUS, _login_child_center_pos(server_pos, Vector2(500, 34), Vector2(-20, 0), Vector2(26, 26)), _login_size(Vector2(26, 26)), false)
	if server_status != null:
		server_status.reparent(server_group)
		server_status.position -= server_pos

	var tip_size := _login_size(Vector2(536, 30))
	var tip_pos := _login_center_top_pos(Vector2(0, -553), Vector2(536, 30))
	var tip_node: TextureRect = app._draw_image(UI_LOGIN_TIP, tip_pos, tip_size, false)
	if tip_node == null:
		var tip = app._label("Tap anywhere to login", 15, HORIZONTAL_ALIGNMENT_CENTER)
		tip.position = tip_pos
		tip.size = tip_size
		app._view_container().add_child(tip)
		_pulse_alpha(tip)
	else:
		_pulse_alpha(tip_node)

	var rich_pos := _login_center_top_pos(Vector2(19.9, -620), Vector2(420, 32))
	var toggle_size := _login_size(Vector2(32, 32))
	var toggle_pos := rich_pos + _login_size(Vector2(0, 0))
	app._draw_image(UI_COMMON_TOGGLE_BG, toggle_pos, toggle_size, false)
	app._draw_image(UI_COMMON_TOGGLE_CHECK, toggle_pos, toggle_size, false)
	app._add_hit_button(toggle_pos, toggle_size, app._show_login)
	var agree_text = app._label("我已阅读并同意服务协议和隐私政策", 15, HORIZONTAL_ALIGNMENT_LEFT)
	agree_text.position = toggle_pos + _login_size(Vector2(42, 0))
	agree_text.size = _login_size(Vector2(386, 32))
	agree_text.modulate = Color(0.82, 0.76, 0.68, 0.96)
	app._view_container().add_child(agree_text)

func show_login_legacy() -> void:
	app.current_view = "login"
	app._set_chrome_visible(false)
	app._clear("登入")

	# imgBg: anchor(0.5,0.5) pivot(0.5,0.5) size(1670,750) pos(0,0) — centered fullscreen
	app._draw_image(UI_LOGIN_BG, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.94))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.014, 0.012, 0.08)))

	# imgLogo: anchor(0,1) pivot(0,0) size(260,104) pos(61,-129) scale(0.8)
	# Godot: (47, 124) × (199, 100)
	if app._draw_image(UI_LOGIN_LOGO, Vector2(47, 124), Vector2(199, 100), false) == null:
		var logo = app._label("少女回战", 54, HORIZONTAL_ALIGNMENT_CENTER)
		logo.position = Vector2(47, 124)
		logo.size = Vector2(199, 100)
		app._view_container().add_child(logo)

	# btnAge: anchor(0,0) pivot(0.5,0.5) size(83,104) pos(90,154) scale(0.8)
	# Godot: (69, 572) × (64, 100)
	var age_btn = Button.new()
	age_btn.text = "12+"
	age_btn.position = Vector2(69, 572)
	age_btn.size = Vector2(64, 100)
	age_btn.pressed.connect(app._show_login)
	app._view_container().add_child(age_btn)

	# pnlVersion: anchor(1,0) pivot(1,0) size(100,126.8) pos(-13,114)
	# Godot: x=1280-13*0.7665=1270, y=720-114*0.96=611, size=(77,122)
	var ver = app._label("版本 1.0.0\n程序 v1.18\n资源 v1.18", 14, HORIZONTAL_ALIGNMENT_RIGHT)
	ver.position = Vector2(1270, 611)
	ver.size = Vector2(77, 122)
	ver.modulate = Color(0.68, 0.64, 0.58)
	app._view_container().add_child(ver)

	# inputAccount: anchor(0.5,0.5) pivot(0.5,0.5) size(543,64) pos(0,-114.5)
	# Godot: center=(640,360-114.5*0.96=250), pos=(640-416/2=432, 250-61/2=219), size=(416,61)
	var icon_x := 432.0
	var input_y := 219.0
	var input_w := 416.0
	var input_h := 61.0
	app._view_container().add_child(app._panel(Vector2(icon_x, input_y), Vector2(38, 38), Color(0.14, 0.11, 0.09, 0.9)))
	var icon_label = app._label("人", 22, HORIZONTAL_ALIGNMENT_CENTER)
	icon_label.position = Vector2(icon_x + 4, input_y + 4)
	icon_label.size = Vector2(30, 30)
	app._view_container().add_child(icon_label)

	var account = LineEdit.new()
	account.text = "LocalPlayer"
	account.placeholder_text = "输入玩家名称"
	account.position = Vector2(icon_x + 42, input_y)
	account.size = Vector2(input_w - 42, input_h)
	app._view_container().add_child(account)

	# Login button: centered below input, no exact prefab position (btnLogin fills screen)
	app._draw_image(UI_LOGIN_BTN, Vector2(498, 300), Vector2(284, 82), false)
	app._add_action_button("开始游戏", Vector2(526, 318), app._show_loading, Vector2(228, 54))

	# pnlFunction: anchor(1,0)→(1,1) size(131,0) pos(-65.7,0) — right column
	# Godot: x=1280-101=1179, buttons at x=1180, each 46x58, y spaced
	var func_x := 1180.0
	var func_start_y := 160.0
	var func_step := 72.0
	app._add_action_button("公告", Vector2(func_x, func_start_y), app._show_login_notice_popup, Vector2(60, 60))
	app._add_action_button("修复", Vector2(func_x, func_start_y + func_step), app._show_repair_popup, Vector2(60, 60))
	app._add_action_button("账号", Vector2(func_x, func_start_y + func_step*2), app._show_login_account_popup, Vector2(60, 60))
	app._add_action_button("切换", Vector2(func_x, func_start_y + func_step*3), app._show_login, Vector2(60, 60))

	# Server select bar: anchor(0.5,0.5) pos(0,-99) size(500,34)
	# Godot: y=360+99*0.96=455, x=640-500*0.7665/2=640-192=448, size=(383,33)
	var svr_y := 455.0
	# btnServerSel: prefab 中 active=false（隐藏），MVP 不应显示
	# 改为离线提示标签覆盖该区域
	var offline_note = app._label("（离线模式 · 本地验证用）", 14, HORIZONTAL_ALIGNMENT_CENTER)
	offline_note.position = Vector2(468, svr_y + 6)
	offline_note.size = Vector2(343, 24)
	offline_note.modulate = Color(0.46, 0.43, 0.40)
	app._view_container().add_child(offline_note)

	# imgTipLogin: anchor(0.5,1) pivot(0.5,1) size(536,30) pos(0,-553)
	# Godot: y=553*0.96=531, x=center=640, size=(411,29), pos=(435,531)
	var tip = app._label("离线单机模式，数据仅供本地验证使用", 15, HORIZONTAL_ALIGNMENT_CENTER)
	tip.position = Vector2(435, 531)
	tip.size = Vector2(411, 29)
	tip.modulate = Color(0.62, 0.58, 0.52, 0.85)
	app._view_container().add_child(tip)

	# @richUrl: anchor(0.5,1) pivot(0.5,1) pos(19.9,-620) — agree checkbox + hyperlink
	# Godot: y=620*0.96=595, centered x≈640
	var agree = CheckBox.new()
	agree.text = "我已阅读并同意隐私政策与使用者协议"
	agree.button_pressed = true
	agree.position = Vector2(426, 595)
	agree.size = Vector2(428, 31)
	app._view_container().add_child(agree)

	# @richBottom: anchor(0.5,1) pivot(0.5,1) size(1670,78) pos(0,-667)
	# Godot: y=667*0.96=640, x=0, size=(1280,75)
	var copyright = app._label("Copyright © Offline MVP. 本地喚灵资料仅用于还原验证。", 14, HORIZONTAL_ALIGNMENT_CENTER)
	copyright.position = Vector2(0, 640)
	copyright.size = Vector2(1280, 75)
	copyright.modulate = Color(0.46, 0.43, 0.4)
	app._view_container().add_child(copyright)

func show_loading() -> void:
	app.current_view = "loading"
	app._set_chrome_visible(false)
	app._clear("载入")

	# imgBg: centering (0.5,0.5), 1670x750 → Godot: (0,0) fullscreen
	# Prefab uses loading_bg_01.png (not login_bg_01), loaded via FixHarmoniousPic("6")
	app._draw_image(UI_LOADING_BG, Vector2(0, 0), Vector2(1280, 720), true)

	# sldSpeed: anchor(0,0.5)→(1,0.5), pos(3.96,-356.8), size(-181,34)
	# Godot: full-width with margin, y from center = -356.8*0.96 = -342 → y = 360-342 = 18... no
	# anchoredPosition.y=-356.8 with anchor(0,0.5): from center = -356.8*0.96 = -342.5
	# center_y = 360, so pos.y = 360 + (-342.5) = 17.5... that's near top.
	# Hmm, that's wrong. Let me recalculate.
	# anchor(0,0.5): x anchored left, y anchored at center
	# pos(3.96, -356.8): x near left edge, y below center by 356.8*0.96=342.5
	# So slider center at (3.96*0.7665=3, 360+342.5=702.5) — near bottom!
	# Wait, 702.5 is below 720. That's off-screen. 
	# Ah — the y is NEGATIVE: -356.8. With anchor y=0.5, y_center = 360 + (-356.8)*0.96 = 360 - 342.5 = 17.5. Near top.
	
	# Actually, let me reconsider. For Unity, pos.y=-356.8 with anchor(0,0.5):
	# The anchor is at center of parent (y=375 in 750 canvas)
	# The anchored position is relative to the anchor: -356.8 means BELOW center
	# In Godot: y = 360 + 356.8*0.96 = 360 + 343 = 703. Bottom area.
	# But that's below 720. Hmm. Let me recheck.
	
	# Actually no. Looking at the LoadingView prefab imgBg is 1670x750 (same as Login).
	# sldSpeed is near the bottom. pos=(3.96, -356.8) with anchor(0,0.5):
	# Godot y: 360 + 356.8*0.96 = 360 + 343 = 703. Size height is 34*0.96=33.
	# So slider spans y=703-16 to 703+16 = 687 to 719. Bottom of screen. OK that makes sense.
	
	# txtPercent: anchor(1,0.5), pos(-11.39,-355.03), size(123,37)
	# Godot: right edge, center-y=360+355*0.96=701, x=1280-11.39*0.7665=1271, width=123*0.7665=94
	# Position: (1271-94/2=1224, 701-37*0.96/2=701-18=683), size=(94,36)
	
	# Simpler: use a bottom area for the progress bar
	var slider_prefab_size := Vector2(LOGIN_PREFAB_SIZE.x - 181.07, 34)
	var slider_size := _login_size(slider_prefab_size)
	var slider_pos := _login_center_pos(Vector2(3.9648, -356.8), slider_prefab_size)
	
	# Background track
	if app._draw_image(UI_LOADING_TRACK, slider_pos, slider_size, false) == null:
		app._view_container().add_child(app._panel(slider_pos, slider_size, Color(0.06, 0.05, 0.04, 0.70)))
	# Fill (animated)
	var fill: Control = app._draw_clipped_image(UI_LOADING_FILL, slider_pos, Vector2(0, slider_size.y), false)
	if fill == null:
		fill = app._panel(slider_pos, Vector2(0, slider_size.y), Color(0.86, 0.65, 0.28, 0.88))
		app._view_container().add_child(fill)
	# Handle: prefab 82×82 → Godot 63×79
	var handle_size := _login_size(Vector2(82, 82))
	var handle_y := slider_pos.y + slider_size.y * 0.5 - handle_size.y * 0.55
	var handle: Control = app._draw_image(UI_LOADING_HANDLE, Vector2(slider_pos.x - handle_size.x * 0.5, handle_y), handle_size, false)
	if handle == null:
		handle = app._panel(Vector2(slider_pos.x - handle_size.x * 0.5, handle_y), handle_size, Color(0.94, 0.78, 0.42, 0.92))
		app._view_container().add_child(handle)
	handle.name = "loading_handle"
	
	# txtPercent: right-anchored near slider
	var pct = app._label("0%", 20, HORIZONTAL_ALIGNMENT_RIGHT)
	pct.name = "loading_percent"
	var pct_prefab_size := Vector2(123, 37)
	pct.position = Vector2((1670.0 - 11.39 - pct_prefab_size.x * 0.5) * LOGIN_SCALE.x, (375.0 + 355.03 - pct_prefab_size.y * 0.5) * LOGIN_SCALE.y)
	pct.size = _login_size(pct_prefab_size)
	app._view_container().add_child(pct)
	
	# Auto-transition: animate 0→100, then auto-load main scene
	_animate_loading_progress(fill, handle, pct, slider_pos, slider_size, handle_y, handle_size.x)

func _animate_loading_progress(fill: Control, handle: Control, pct: Label, pos: Vector2, size: Vector2, handle_y: float, handle_width: float) -> void:
	var steps := 100
	var step_time := 0.005
	for i in range(steps + 1):
		var t = float(i) / steps
		var val = int(t * 100)
		fill.size = Vector2(size.x * t, size.y)
		handle.position = Vector2(pos.x + size.x * t - handle_width * 0.5, handle_y)
		pct.text = "%d%%" % val
		if i < steps:
			await app._startup_step_timer(step_time)
	if app.current_view == "loading":
		app._enter_main_scene()
