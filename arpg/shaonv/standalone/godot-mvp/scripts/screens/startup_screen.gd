# UTF-8 source. Startup chain reconstructed from LaunchView/LoginView/LoadingView prefabs.
extends RefCounted

const UI_LOGIN_BG = "res://assets/ui/background/login_bg_01.png"
const UI_LOGIN_BTN = "res://assets/ui/login/login_btn_03.png"
const UI_LOGIN_LOGO = "res://assets/ui/login/logo.png"
const UI_LOGIN_SERVER_BG = "res://assets/ui/login/server_bg_03.png"

var app

func _init(app_ref) -> void:
	app = app_ref

func show_launch() -> void:
	app.current_view = "launch"
	print("Shaonv MVP show launch: heroes=%d pools=%d" % [app.heroes.size(), app.pools.size()])
	app._set_chrome_visible(false)
	app._clear("启动")

	# LaunchView is mostly a full-screen VideoPlayer/RawImage.
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.0, 0.0, 0.0, 1.0)))
	app._view_container().add_child(app._panel(Vector2(-200, -120), Vector2(1680, 1680), Color(0.05, 0.032, 0.026, 0.38)))

	var hint = app._label("点击跳过", 18, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(520, 650)
	hint.size = Vector2(240, 34)
	hint.modulate = Color(0.86, 0.80, 0.70, 1.0)
	app._view_container().add_child(hint)
	app._add_action_button("跳过", Vector2(1128, 32), app._show_preloading, Vector2(104, 40))

func show_preloading() -> void:
	app.current_view = "preloading"
	app._set_chrome_visible(false)
	app._clear("预载入")
	app._draw_image(UI_LOGIN_BG, Vector2(-195, -4), Vector2(1670, 728), true, Color(1, 1, 1, 0.64))
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

	app._draw_image(UI_LOGIN_BG, Vector2(-195, -4), Vector2(1670, 728), true, Color(1, 1, 1, 0.92))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.014, 0.018, 0.16)))

	var info = app._label("正在进入主城", 22, HORIZONTAL_ALIGNMENT_CENTER)
	info.position = Vector2(340, 550)
	info.size = Vector2(600, 36)
	app._view_container().add_child(info)

	var tip = app._label("提示：喚灵可获得新武将，重复武将将转换为碎片。", 16, HORIZONTAL_ALIGNMENT_CENTER)
	tip.position = Vector2(290, 596)
	tip.size = Vector2(700, 30)
	tip.modulate = Color(0.7, 0.66, 0.6)
	app._view_container().add_child(tip)

	var slider_y = 624
	var slider_margin = 90
	app._draw_progress_bar(Vector2(slider_margin, slider_y), Vector2(1280 - slider_margin * 2, 22), 0.88)

	var pct = app._label("88%", 20, HORIZONTAL_ALIGNMENT_RIGHT)
	pct.position = Vector2(1280 - slider_margin + 12, slider_y - 20)
	pct.size = Vector2(60, 28)
	app._view_container().add_child(pct)

	app._add_action_button("进入", Vector2(574, 664), app._enter_main_scene, Vector2(132, 38))
