#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Write refactored home_screen.gd based on full prefab analysis."""

content = '''# UTF-8 source. MainUIView - refactored from prefab + IL analysis.
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
\t"res://assets/ui/mainui/mainui_btn_07.png",
\t"res://assets/ui/mainui/mainui_btn_08.png",
\t"res://assets/ui/mainui/mainui_btn_09.png",
\t"res://assets/ui/mainui/mainui_btn_10.png",
\t"res://assets/ui/mainui/mainui_btn_11.png"
]

var app
var _main_state: String = "normal"
var _main_panels: Array = []

func _init(app_ref) -> void:
\tapp = app_ref


# ═══════════════════════════════════════════════════════════════
# State machine
# ═══════════════════════════════════════════════════════════════

func show_home() -> void:
\tapp.current_view = "main"
\tapp.content.position = Vector2(0, 0)
\tapp.content.size = Vector2(1280, 720)
\tapp._set_chrome_visible(false)
\tapp._clear("主界面")
\t_main_panels.clear()
\tenter_normal_state()


func enter_normal_state() -> void:
\t_main_state = "normal"
\tapp._clear("主界面")
\tvar hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
\t# Layer 0: Wallpaper (always below everything)
\tdraw_wallpaper(hero)
\t# Layer 1: Full-screen transparent button (wallpaper toggle)
\tdraw_body_mask()
\t# Layer 2: TopBar (full-width, 12px from top, h=60→58)
\tdraw_top_bar()
\t# Layer 3: pnlPlayerInfo (top-left, 354×113→271×108)
\tdraw_player_info(hero)
\t# Layer 4: pnlFunny sub-panels
\tdraw_funny_content()    # 4 buttons 88×102 at right
\tdraw_story_harvest()    # pnlStory row
\tdraw_charge_column()    # pnlCharge vertical
\tdraw_menu_button()      # btnMenu corner
\tdraw_assist_button()    # btnAssist left-bottom
\t# Layer 5: pnlCommercialization (left-mid)
\tdraw_commercialization()
\t# Layer 6: btnChapterInfo (right-mid)
\tdraw_chapter_info()
\t# Layer 7: pnlBottom (bottom bar)
\tdraw_bottom_bar()
\t# Layer 8: btnGal (independent, protruding upward)
\tdraw_gal_button()
\t# Layer 9: pnlChat (right-bottom corner)
\tdraw_chat_bar()


func enter_wallpaper_focus() -> void:
\t_main_state = "wallpaper_focus"
\tapp._clear("壁纸")
\tvar hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
\tdraw_wallpaper(hero)
\t# pnlCtl: centered control bar at bottom
\tvar ctl_y = 660.0
\tapp._add_action_button("◀", Vector2(520, ctl_y), app._show_home, Vector2(48, 48))
\tapp._add_action_button("▶", Vector2(576, ctl_y), app._show_home, Vector2(48, 48))
\tapp._add_action_button("▐▐", Vector2(632, ctl_y), app._show_home, Vector2(48, 48))
\tapp._add_action_button("眼", Vector2(700, ctl_y), enter_normal_state, Vector2(56, 48))


func enter_gal_entry() -> void:
\t_main_state = "gal_entry"
\tapp._clear("约会")
\t# Dimmed wallpaper as backdrop
\tapp._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1278, 720), true, Color(1, 1, 1, 0.22))
\tapp.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.016, 0.012, 0.020, 0.90)))
\tvar hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
\t# ── Top bar ──
\tvar top = app._panel(Vector2(0, 0), Vector2(1280, 60), Color(0.024, 0.018, 0.028, 0.72))
\tapp.content.add_child(top)
\tapp.content.add_child(app._panel(Vector2(0, 58), Vector2(1280, 2), Color(0.76, 0.54, 0.28, 0.28)))
\tapp._add_action_button("← 返回", Vector2(18, 8), enter_normal_state, Vector2(100, 44))
\tvar title = app._label("约 会", 28, HORIZONTAL_ALIGNMENT_CENTER)
\ttitle.position = Vector2(440, 12)
\ttitle.size = Vector2(400, 36)
\ttitle.modulate = Color(0.94, 0.86, 0.64)
\tapp.content.add_child(title)
\t# ── Hero card ──
\tvar cx = 315.0; var cy = 85.0; var cw = 650.0; var ch = 420.0
\tapp.content.add_child(app._panel(Vector2(cx, cy), Vector2(cw, ch), Color(0.030, 0.022, 0.036, 0.68)))
\tapp.content.add_child(app._panel(Vector2(cx + 4, cy + 4), Vector2(cw - 8, ch - 8), Color(0.045, 0.034, 0.052, 0.40)))
\tapp._draw_hero_stage(hero, Vector2(cx + 30, cy + 30), Vector2(320, 360), false)
\tapp._draw_image(UI_MAIN_AVATAR_RING, Vector2(cx + 148, cy + 26), Vector2(84, 84), false, Color(1, 1, 1, 0.78))
\tapp._draw_image(UI_MAIN_EXP_RING, Vector2(cx + 142, cy + 20), Vector2(96, 96), false, Color(1, 0.84, 0.28, 0.72))
\t# Hero info
\tvar ix = cx + 370; var iy = cy + 40
\tvar hname = app._label(str(hero.get("name", "???")) if hero else "???", 24)
\thname.position = Vector2(ix, iy); hname.size = Vector2(240, 32); hname.modulate = Color(0.98, 0.94, 0.80)
\tapp.content.add_child(hname)
\tvar htitle = app._label(str(hero.get("title", "")) if hero else "", 16)
\thtitle.position = Vector2(ix, iy + 36); htitle.size = Vector2(240, 22); htitle.modulate = Color(0.72, 0.66, 0.52)
\tapp.content.add_child(htitle)
\t# Affection bar
\tvar bl = app._label("好感度", 14, HORIZONTAL_ALIGNMENT_CENTER)
\tbl.position = Vector2(ix, iy + 72); bl.size = Vector2(56, 18); bl.modulate = Color(0.64, 0.58, 0.48)
\tapp.content.add_child(bl)
\tapp.content.add_child(app._panel(Vector2(ix + 60, iy + 74), Vector2(160, 12), Color(0.08, 0.06, 0.12, 0.70)))
\tapp.content.add_child(app._panel(Vector2(ix + 60, iy + 74), Vector2(54, 12), Color(0.92, 0.38, 0.56, 0.78)))
\tvar hlvl = app._label("Lv.%d" % int(hero.get("level", 1)) if hero else "Lv.1", 14)
\thlvl.position = Vector2(ix, iy + 100); hlvl.size = Vector2(80, 18); hlvl.modulate = Color(0.86, 0.80, 0.56)
\tapp.content.add_child(hlvl)
\t# Navigation
\tapp._add_action_button("◀", Vector2(cx - 56, cy + 180), app._show_home, Vector2(44, 56))
\tapp._add_action_button("▶", Vector2(cx + cw + 12, cy + 180), app._show_home, Vector2(44, 56))
\tapp.content.add_child(app._panel(Vector2(cx, cy + ch + 14), Vector2(cw, 1), Color(0.76, 0.54, 0.28, 0.18)))
\t# Action buttons
\tvar abtn = [["💬 对话", app._show_mail], ["🎁 赠礼", app._show_shop], ["💕 邀约", app._show_home]]
\tvar aw = 170.0; var ah = 72.0; var ag = 22.0
\tvar ax0 = (1280.0 - (3*aw+2*ag)) * 0.5; var ay = 535.0
\tfor i in range(abtn.size()):
\t\tvar ax = ax0 + i*(aw+ag)
\t\tapp.content.add_child(app._panel(Vector2(ax, ay), Vector2(aw, ah), Color(0.040, 0.030, 0.048, 0.74)))
\t\tvar albl = app._label(str(abtn[i][0]), 16, HORIZONTAL_ALIGNMENT_CENTER)
\t\talbl.position = Vector2(ax, ay + 14); albl.size = Vector2(aw, 22); albl.modulate = Color(0.86, 0.80, 0.68)
\t\tapp.content.add_child(albl)
\t\tapp._add_action_button("互动" if i==0 else ("送礼" if i==1 else "约会"), Vector2(ax + 2, ay + 38), abtn[i][1], Vector2(aw - 4, 32))
\t\tif i == 2: app._draw_red_dot(Vector2(ax + aw - 22, ay + 8))
\t# Status
\tapp.content.add_child(app._panel(Vector2(0, 688), Vector2(1280, 32), Color(0.020, 0.016, 0.028, 0.64)))
\tvar st = app._label("Gal 约会系统  |  键: Gal.GalEntry.5799  |  完整实现待反向", 12, HORIZONTAL_ALIGNMENT_CENTER)
\tst.position = Vector2(140, 694); st.size = Vector2(1000, 22); st.modulate = Color(0.52, 0.48, 0.42)
\tapp.content.add_child(st)


# ═══════════════════════════════════════════════════════════════
# Drawing functions - main_normal layers
# ═══════════════════════════════════════════════════════════════

func draw_wallpaper(hero: Dictionary) -> void:
\t# Prefab: @WallpaperPanel anchor=(0.5,0.5) 1668x750 → fullscreen scaled
\tapp._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1278, 720), true)
\tapp.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.010, 0.008, 0.05)))
\t# irole: 958x750 centered → (273,0) 734x720
\tapp._draw_hero_stage(hero, Vector2(273, 0), Vector2(734, 720), false)


func draw_body_mask() -> void:
\tvar mask = Button.new()
\tmask.text = ""; mask.flat = true
\tmask.position = Vector2(0, 0); mask.size = Vector2(1280, 720)
\tmask.modulate = Color(1, 1, 1, 0.0)
\tmask.pressed.connect(enter_wallpaper_focus)
\tapp.content.add_child(mask)


func draw_top_bar() -> void:
\t# @TopBar (0,12) full-width h=58
\tvar bar = app._draw_image(UI_MAIN_TOP_ACCENT, Vector2(0, 12), Vector2(1280, 58), false, Color(1, 1, 1, 0.62))
\t_main_panels.append(bar)
\t# svRes: resource bar at right side
\tvar x = 680.0
\tvar resources = [
\t\t["邮件", app._unclaimed_mail_count()],
\t\t["唤醒券", app.save.get("tickets", 0)],
\t\t["源石", app.save.get("gems", 0)]
\t]
\tfor item in resources:
\t\tvar icon = app._panel(Vector2(x, 26), Vector2(22, 22), Color(0.58, 0.45, 0.22, 0.74))
\t\tapp.content.add_child(icon)
\t\tvar text = app._label("%s %s" % [item[0], item[1]], 16)
\t\ttext.position = Vector2(x + 28, 24); text.size = Vector2(130, 28)
\t\ttext.modulate = Color(0.96, 0.90, 0.80)
\t\tapp.content.add_child(text)
\t\tx += 150


func draw_player_info(hero: Dictionary) -> void:
\t# pnlPlayerInfo: (0,5) 271x108
\tvar profile = app.save.get("profile", {})
\tvar panel = app._draw_image(UI_MAIN_PLAYER_FRAME, Vector2(0, 5), Vector2(271, 108), false, Color(1, 1, 1, 0.94))
\t_main_panels.append(panel)
\t# imgHeadBg (80,8) 61x76 → imgExp (74,14) 69x86
\tapp._draw_image(UI_MAIN_AVATAR_RING, Vector2(80, 13), Vector2(61, 76), false, Color(1, 1, 1, 0.94))
\tdraw_cover_portrait(hero, Vector2(86, 23), Vector2(50, 56), Color(1, 1, 1, 0.95))
\tapp._draw_image(UI_MAIN_EXP_RING, Vector2(74, 19), Vector2(69, 86), false, Color(1, 0.84, 0.28, 0.88))
\t# Level label
\tvar lv = app._label("Lv.%d" % int(profile.get("level", 1)), 12, HORIZONTAL_ALIGNMENT_CENTER)
\tlv.position = Vector2(82, 90); lv.size = Vector2(52, 14); lv.modulate = Color(0.96, 0.88, 0.52)
\tapp.content.add_child(lv)
\t# txtName (118,26) 66x28
\tvar pname = app._label(str(profile.get("name", "Player")), 18)
\tpname.position = Vector2(118, 26); pname.size = Vector2(66, 28)
\tapp.content.add_child(pname)
\t# txtPower (139,50) 133x32
\tvar power = app._label("战力 %d" % app._player_power(), 14)
\tpower.position = Vector2(139, 50); power.size = Vector2(133, 32)
\tpower.modulate = Color(0.84, 0.74, 0.24)
\tapp.content.add_child(power)
\t# btnPlayerInfo (0,13) 271x76
\tvar player_btn = Button.new()
\tplayer_btn.text = ""; player_btn.flat = true
\tplayer_btn.position = Vector2(0, 13); player_btn.size = Vector2(271, 76)
\tplayer_btn.pressed.connect(app._show_player_info)
\tapp.content.add_child(player_btn)
\t# btnChange (308,48) 57x71  /  btnEye (366,48) 57x71
\tapp._add_action_button("换", Vector2(308, 48), app._show_gallery, Vector2(57, 71))
\tapp._add_action_button("眼", Vector2(366, 48), enter_wallpaper_focus, Vector2(57, 71))


func draw_funny_content() -> void:
\t# pnlFunnyContent: 4 buttons 88x102 (→67x98), right-aligned at y=70
\tvar actions = [
\t\t[UI_MAIN_FUNNY_ARENA, "竞技", app._show_battle],
\t\t[UI_MAIN_FUNNY_PRAYER, "祈愿", app._open_prayer_pool],
\t\t[UI_MAIN_FUNNY_ADVENTURE, "冒险", app._show_battle],
\t\t[UI_MAIN_FUNNY_DRAW, "唤灵", app._open_present_pool]
\t]
\tvar bw = 67.0; var bh = 98.0; var gap = 5.0
\tvar start_x = 1280.0 - 4*bw - 3*gap - 46  # right-anchored
\tvar by = 67.0
\tfor item in actions:
\t\tvar bg = app._draw_image(str(item[0]), Vector2(start_x, by), Vector2(bw, bh), false, Color(1, 1, 1, 0.84))
\t\t_main_panels.append(bg)
\t\tapp._add_action_button(str(item[1]), Vector2(start_x + 2, by + 64), item[2], Vector2(bw - 4, 34))
\t\tapp._draw_red_dot(Vector2(start_x + bw - 16, by + 4))
\t\tstart_x += bw + gap


func draw_story_harvest() -> void:
\t# pnlStory: 278x98 (→213x94), right-anchored at y=18
\tvar sw = 213.0; var sh = 94.0
\tvar sx = 1280.0 - sw - 46; var sy = 18.0
\tvar bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(sx, sy), Vector2(sw, sh), false, Color(1, 1, 1, 0.88))
\t_main_panels.append(bg)
\tvar story = app._label("主线 %s\\n挂机收益 %s" % [app._next_task_text(), "可收取" if not app._afk_claimed_today() else "已收取"], 15)
\tstory.position = Vector2(sx + 14, sy + 14); story.size = Vector2(sw - 16, 44)
\tapp.content.add_child(story)
\t# btnHarvest: 106x106 → 81x102, inside pnlStory at (51,1)
\tapp._add_action_button("收获", Vector2(sx + 51, sy + 1), app._claim_afk_reward, Vector2(81, 102))
\tapp._draw_red_dot(Vector2(sx + sw - 20, sy + 2))


func draw_charge_column() -> void:
\t# pnlCharge: 158x258 (→121x248), right-bottom corner
\tvar labels = [["活动", app._show_daily], ["福利", app._show_daily], ["月卡", app._show_shop], ["充值", app._show_shop], ["商店", app._show_shop]]
\tvar cx = 1280.0 - 121 - 42; var cy = 720.0 - 248 - 30
\tfor i in range(labels.size()):
\t\tvar icon = app._draw_image(str(UI_MAIN_CHARGE_ICONS[i]), Vector2(cx, cy), Vector2(60, 60), false, Color(1, 1, 1, 0.86))
\t\t_main_panels.append(icon)
\t\tapp._add_action_button(str(labels[i][0]), Vector2(cx + 2, cy + 44), labels[i][1], Vector2(56, 26))
\t\tapp._draw_red_dot(Vector2(cx + 44, cy + 2))
\t\tcy += 50


func draw_menu_button() -> void:
\t# btnMenu: 78x78 (→60x72), right-bottom corner
\tvar mx = 1280.0 - 60 - 72; var my = 720.0 - 72 - 42
\tapp._draw_image(UI_MAIN_MENU, Vector2(mx, my), Vector2(60, 72), false, Color(1, 1, 1, 0.92))
\tapp._add_action_button("", Vector2(mx, my), app._show_home, Vector2(60, 72))
\tapp._draw_red_dot(Vector2(mx + 46, my + 4))


func draw_assist_button() -> void:
\t# btnAssist: 78x96 (→60x92), left-bottom area
\tapp._draw_image(UI_MAIN_ASSIST, Vector2(317, 117), Vector2(60, 92), false, Color(1, 1, 1, 0.84))
\tapp._add_action_button("援助", Vector2(317, 193), app._show_mail, Vector2(60, 26))


func draw_commercialization() -> void:
\t# pnlCommercialization: 416x420 (→319x404), left-mid area
\tvar px = 203.0; var py = 317.0
\t# @pnlAlternate: 301x108 (→231x104) banner
\tapp._draw_image(UI_MAIN_BANNER, Vector2(px, py), Vector2(231, 104), false, Color(1, 1, 1, 0.92))
\t# pnlGift: 409x300 (→313x288), below banner
\tvar gx = px + 5; var gy = py + 108 + 12
\tapp.content.add_child(app._panel(Vector2(gx, gy), Vector2(313, 288), Color(0.030, 0.023, 0.018, 0.56)))
\tvar gifts = [
\t\t["补给", app._show_daily], ["邮件", app._show_mail], ["签到", app._show_daily],
\t\t["奖励", app._show_tasks], ["问答", app._show_home], ["礼包", app._show_shop],
\t\t["月卡", app._show_shop], ["充值", app._show_shop], ["商店", app._show_shop]
\t]
\tvar gsx = gx + 8.0; var gsy = gy + 12.0; var gi = 0
\tfor gift in gifts:
\t\tvar slot = app._panel(Vector2(gsx, gsy), Vector2(68, 64), Color(0.040, 0.034, 0.030, 0.74))
\t\tapp.content.add_child(slot)
\t\tapp._add_action_button(str(gift[0]), Vector2(gsx + 4, gsy + 14), gift[1], Vector2(60, 38))
\t\tapp._draw_red_dot(Vector2(gsx + 54, gsy + 4))
\t\tgi += 1; gsx += 74
\t\tif gi % 4 == 0:
\t\t\tgsx = gx + 8; gsy += 72


func draw_chapter_info() -> void:
\t# btnChapterInfo: 276x100 (→212x96), right-mid
\tvar px = 1280.0 - 212 - 26; var py = 144.0
\tvar bg = app._draw_image(UI_MAIN_CHAPTER_BG, Vector2(px, py), Vector2(212, 96), false, Color(1, 1, 1, 0.90))
\t_main_panels.append(bg)
\tvar info = app._label("章节  %s\\n奖励  收集 %d / 抽卡 %d" % [app._next_task_text(), app.save.get("owned", {}).size(), int(app.save.get("draw_count", 0))], 15)
\tinfo.position = Vector2(px + 14, py + 16); info.size = Vector2(180, 60)
\tapp.content.add_child(info)
\tapp._add_action_button("", Vector2(px, py), app._show_tasks, Vector2(212, 96))
\tapp._draw_red_dot(Vector2(px + 8, py + 4))


func draw_bottom_bar() -> void:
\t# pnlBottom: (49,625) height=48, width=1231
\tvar bar_y = 625.0; var bar_h = 48.0
\tvar bar = app._panel(Vector2(49, bar_y), Vector2(1231, bar_h), Color(0.026, 0.022, 0.020, 0.90))
\tapp.content.add_child(bar); _main_panels.append(bar)
\tapp.content.add_child(app._panel(Vector2(49, bar_y - 2), Vector2(1231, 2), Color(0.86, 0.65, 0.32, 0.26)))
\t# 6 buttons: 86x50 each (→66x48), starting after pnlGal (115x50→88x48)
\tvar buttons = [
\t\t["武将", app._show_gallery, true],
\t\t["背包", app._show_shop, false],
\t\t["宠物", app._show_home, false],
\t\t["养成", app._show_gallery, true],
\t\t["任务", app._show_tasks, true],
\t\t["军团", app._show_home, false]
\t]
\tvar bw = 66.0; var bx = 49.0 + 88  # after gal slot
\tfor item in buttons:
\t\tapp._draw_image(UI_MAIN_BOTTOM_BTN, Vector2(bx, bar_y), Vector2(bw, bar_h), false, Color(1, 1, 1, 0.34))
\t\tapp._add_action_button(str(item[0]), Vector2(bx, bar_y), item[1], Vector2(bw, bar_h))
\t\tapp._draw_image(UI_MAIN_SEPARATOR, Vector2(bx + bw + 2, bar_y + 16), Vector2(2, 16), false, Color(1, 1, 1, 0.55))
\t\tif item[2]: app._draw_red_dot(Vector2(bx + bw - 18, bar_y))
\t\tbx += bw + 8


func draw_gal_button() -> void:
\t# pnlGal + btnGal: (49,546) 88x124, protruding 79px above pnlBottom
\tvar gx = 49.0; var gy = 625.0 - 79
\tapp._draw_image(UI_MAIN_GAL, Vector2(gx, gy), Vector2(88, 124), false, Color(1, 1, 1, 0.92))
\tapp._add_action_button("约会", Vector2(gx + 8, gy + 88), enter_gal_entry, Vector2(72, 36))
\tapp._draw_red_dot(Vector2(gx + 68, gy + 8))


func draw_chat_bar() -> void:
\t# pnlChat: right-bottom corner, 410x40 (→314x38)
\tvar cx = 1280.0 - 314 - 49; var cy = 720.0 - 38 - 90
\tvar bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), Vector2(314, 38), false, Color(1, 1, 1, 0.72))
\t_main_panels.append(bg)
\tvar chat = app._label("世界  离线模式已启用", 14)
\tchat.position = Vector2(cx + 49, cy + 8); chat.size = Vector2(255, 22)
\tchat.modulate = Color(0.68, 0.64, 0.58)
\tapp.content.add_child(chat)
\tapp._add_action_button("", Vector2(cx, cy), app._show_mail, Vector2(314, 38))


# ═══════════════════════════════════════════════════════════════
# Hero portrait utility
# ═══════════════════════════════════════════════════════════════

func draw_cover_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint: Color) -> void:
\tvar texture = app._hero_portrait_texture(hero)
\tif texture == null: return
\tvar rect = TextureRect.new()
\trect.texture = texture; rect.position = pos; rect.size = draw_size
\trect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\trect.stretch_mode = TextureRect.STRETCH_SCALE
\trect.modulate = tint
\tapp.content.add_child(rect)
'''

with open('D:/work/openclaw-workspace/arpg/shaonv/standalone/godot-mvp/scripts/screens/home_screen.gd', 'w', encoding='utf-8') as f:
    f.write(content)
print('Written successfully')
