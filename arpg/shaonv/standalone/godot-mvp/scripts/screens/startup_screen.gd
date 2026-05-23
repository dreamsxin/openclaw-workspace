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

	# LoginView/imgBg: 1670x750 center background.
	app._draw_image(UI_LOGIN_BG, Vector2(-195, -4), Vector2(1670, 728), true, Color(1, 1, 1, 0.94))
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.014, 0.012, 0.08)))

	if app._draw_image(UI_LOGIN_LOGO, Vector2(48, 90), Vector2(258, 86), false) == null:
		var logo = app._label("少女回战", 54, HORIZONTAL_ALIGNMENT_CENTER)
		logo.position = Vector2(46, 102)
		logo.size = Vector2(300, 82)
		app._view_container().add_child(logo)

	var age_btn = Button.new()
	age_btn.text = "12+"
	age_btn.position = Vector2(106, 214)
	age_btn.size = Vector2(64, 70)
	age_btn.pressed.connect(app._show_login)
	app._view_container().add_child(age_btn)

	var ver = app._label("版本 1.0.0\n程序 v1.18\n资源 v1.18", 14, HORIZONTAL_ALIGNMENT_RIGHT)
	ver.position = Vector2(934, 80)
	ver.size = Vector2(230, 78)
	ver.modulate = Color(0.68, 0.64, 0.58)
	app._view_container().add_child(ver)

	app._view_container().add_child(app._panel(Vector2(376, 418), Vector2(38, 38), Color(0.14, 0.11, 0.09, 0.9)))
	var icon_label = app._label("人", 22, HORIZONTAL_ALIGNMENT_CENTER)
	icon_label.position = Vector2(378, 423)
	icon_label.size = Vector2(34, 30)
	app._view_container().add_child(icon_label)

	var account = LineEdit.new()
	account.text = "LocalPlayer"
	account.placeholder_text = "输入玩家名称"
	account.position = Vector2(426, 418)
	account.size = Vector2(376, 62)
	app._view_container().add_child(account)

	app._draw_image(UI_LOGIN_BTN, Vector2(498, 340), Vector2(284, 82), false)
	app._add_action_button("开始游戏", Vector2(526, 358), app._show_loading, Vector2(228, 54))

	app._add_action_button("公告", Vector2(1138, 178), app._show_login_notice_popup, Vector2(60, 60))
	app._add_action_button("修复", Vector2(1138, 250), app._show_repair_popup, Vector2(60, 60))
	app._add_action_button("账号", Vector2(1138, 322), app._show_login_account_popup, Vector2(60, 60))
	app._add_action_button("切换", Vector2(1138, 394), app._show_login, Vector2(60, 60))

	if app._draw_image(UI_LOGIN_SERVER_BG, Vector2(390, 486), Vector2(500, 42), false) == null:
		app._view_container().add_child(app._panel(Vector2(390, 486), Vector2(500, 42), Color(0.09, 0.065, 0.052, 0.88)))
	var server_label = app._label("推荐服务器    Local MainScene", 18, HORIZONTAL_ALIGNMENT_CENTER)
	server_label.position = Vector2(410, 490)
	server_label.size = Vector2(460, 34)
	app._view_container().add_child(server_label)
	app._view_container().add_child(app._panel(Vector2(888, 494), Vector2(18, 18), Color(0.18, 0.88, 0.28, 0.95)))
	var state_label = app._label("流畅", 14, HORIZONTAL_ALIGNMENT_CENTER)
	state_label.position = Vector2(912, 492)
	state_label.size = Vector2(46, 26)
	state_label.modulate = Color(0.22, 0.88, 0.32)
	app._view_container().add_child(state_label)

	var tip = app._label("离线单机模式，数据仅供本地验证使用", 15, HORIZONTAL_ALIGNMENT_CENTER)
	tip.position = Vector2(390, 548)
	tip.size = Vector2(500, 30)
	tip.modulate = Color(0.62, 0.58, 0.52, 0.85)
	app._view_container().add_child(tip)

	var agree = CheckBox.new()
	agree.text = "我已阅读并同意隐私政策与使用者协议"
	agree.button_pressed = true
	agree.position = Vector2(426, 594)
	agree.size = Vector2(428, 34)
	app._view_container().add_child(agree)

	var copyright = app._label("Copyright © Offline MVP. 本地喚灵资料仅用于还原验证。", 14, HORIZONTAL_ALIGNMENT_CENTER)
	copyright.position = Vector2(340, 654)
	copyright.size = Vector2(600, 28)
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
