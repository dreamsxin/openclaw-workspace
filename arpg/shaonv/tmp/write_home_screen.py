#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Write home_screen.gd - exact prefab coordinates at 1670x750."""

content = """# UTF-8 source: MainUIView at 1670x750, raw prefab coordinates.
# State machine: main_normal | wallpaper_focus | gal_entry
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

func show_home() -> void:
\tapp.current_view = "main"
\tapp.content.position = Vector2(0, 0)
\tapp.content.size = Vector2(1670, 750)
\tapp._set_chrome_visible(false)
\tapp._clear("\\u4e3b\\u754c\\u9762")
\t_main_panels.clear()
\tenter_normal_state()

func enter_normal_state() -> void:
\t_main_state = "normal"
\tapp._clear("\\u4e3b\\u754c\\u9762")
\tvar hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
\tdraw_wallpaper_layer(hero)
\tdraw_body_mask()
\tdraw_top_bar()
\tdraw_player_info(hero)
\tdraw_funny_content()
\tdraw_story_row()
\tdraw_charge_column()
\tdraw_menu_button()
\tdraw_assist_button()
\tdraw_commercialization_panel()
\tdraw_chapter_panel()
\tdraw_bottom_bar()
\tdraw_gal_entry_button()
\tdraw_chat_bar()

func enter_wallpaper_focus() -> void:
\t_main_state = "wallpaper_focus"
\tapp._clear("\\u58c1\\u7eb8")
\tvar hero = app._hero_by_id(int(app.save.get("selected_hero_id", 240065)))
\tdraw_wallpaper_layer(hero)
\tapp._add_action_button("\\u25c0", Vector2(698, 569), app._show_home, Vector2(70, 50))
\tapp._add_action_button("\\u25b6", Vector2(773, 569), app._show_home, Vector2(70, 50))
\tapp._add_action_button("\\u25b6\\u25b6", Vector2(848, 569), app._show_home, Vector2(70, 50))
\tapp._add_action_button("\\u773c", Vector2(923, 569), enter_normal_state, Vector2(70, 50))

func enter_gal_entry() -> void:
\t_main_state = "gal_entry"
\tapp._clear("\\u7ea6\\u4f1a")
\tapp._draw_image(UI_MAIN_GAL, Vector2(0, 0), Vector2(1670, 80), false, Color(1, 1, 1, 0.7))
\tapp.content.add_child(app._panel(Vector2(0, 0), Vector2(1670, 750), Color(0.028, 0.022, 0.018, 0.92)))
\tvar title = app._label("\\u7ea6\\u4f1a", 36, HORIZONTAL_ALIGNMENT_CENTER)
\ttitle.position = Vector2(635, 80)
\ttitle.size = Vector2(400, 52)
\tapp.content.add_child(title)
\tvar hint = app._label("Gal / \\u7ea6\\u4f1a\\u5165\\u53e3\\n\\u7ea2\\u70b9\\u952e: Gal.GalEntry.5799\\n\\u539f\\u6e38\\u620f\\u5b8c\\u6574\\u5b9e\\u73b0\\u5f85\\u53cd\\u5411", 18, HORIZONTAL_ALIGNMENT_CENTER)
\thint.position = Vector2(495, 180)
\thint.size = Vector2(680, 80)
\thint.modulate = Color(0.72, 0.68, 0.56)
\tapp.content.add_child(hint)
\tapp._add_action_button("\\u8fd4\\u56de\\u4e3b\\u754c\\u9762", Vector2(719, 380), enter_normal_state, Vector2(232, 50))

func draw_wallpaper_layer(hero: Dictionary) -> void:
\tapp._draw_image(UI_MAIN_BG, Vector2(1, 0), Vector2(1668, 750), true)
\tapp.content.add_child(app._panel(Vector2(0, 0), Vector2(1670, 750), Color(0.012, 0.010, 0.008, 0.05)))
\tapp._draw_hero_stage(hero, Vector2(356, 0), Vector2(958, 750), false)

func draw_body_mask() -> void:
\tvar mask = Button.new()
\tmask.text = ""
\tmask.flat = true
\tmask.position = Vector2(0, 0)
\tmask.size = Vector2(1670, 750)
\tmask.modulate = Color(1, 1, 1, 0.0)
\tmask.pressed.connect(enter_wallpaper_focus)
\tapp.content.add_child(mask)

func draw_top_bar() -> void:
\tvar bar = app._draw_image(UI_MAIN_TOP_ACCENT, Vector2(0, 12), Vector2(1670, 60), false, Color(1, 1, 1, 0.62))
\t_main_panels.append(bar)
\t# svRes: 1367x60, anchor (1,1) pos=(-790,-42)
\tvar x = 1080.0
\tvar ry = 26.0
\tvar resources = [
\t\t["\\u90ae\\u4ef6", app._unclaimed_mail_count()],
\t\t["\\u559a\\u7075\\u5238", app.save.get("tickets", 0)],
\t\t["\\u6e90\\u77f3", app.save.get("gems", 0)]
\t]
\tfor item in resources:
\t\tvar icon = app._panel(Vector2(x, ry), Vector2(22, 22), Color(0.58, 0.45, 0.22, 0.74))
\t\tapp.content.add_child(icon)
\t\tvar text = app._label("%s %s" % [item[0], item[1]], 16)
\t\ttext.position = Vector2(x + 28, ry - 2)
\t\ttext.size = Vector2(130, 28)
\t\ttext.modulate = Color(0.96, 0.90, 0.80)
\t\tapp.content.add_child(text)
\t\tx += 160

func draw_player_info(hero: Dictionary) -> void:
\tvar profile = app.save.get("profile", {})
\tvar frame = app._draw_image(UI_MAIN_PLAYER_FRAME, Vector2(0, 5), Vector2(354, 113), false, Color(1, 1, 1, 0.94))
\t_main_panels.append(frame)
\tapp._draw_image(UI_MAIN_AVATAR_RING, Vector2(104, 22), Vector2(80, 79), false, Color(1, 1, 1, 0.94))
\tdraw_cover_portrait(hero, Vector2(112, 33), Vector2(64, 56), Color(1, 1, 1, 0.95))
\tapp._draw_image(UI_MAIN_EXP_RING, Vector2(99, 16), Vector2(90, 90), false, Color(1, 0.84, 0.28, 0.88))
\tvar lv = app._label("Lv.%d" % int(profile.get("level", 1)), 12, HORIZONTAL_ALIGNMENT_CENTER)
\tlv.position = Vector2(108, 90)
\tlv.size = Vector2(72, 16)
\tlv.modulate = Color(0.96, 0.88, 0.52)
\tapp.content.add_child(lv)
\tvar pname = app._label(str(profile.get("name", "Player")), 18)
\tpname.position = Vector2(192, 28)
\tpname.size = Vector2(86, 28)
\tapp.content.add_child(pname)
\tvar power = app._label("\\u6218\\u529b %d" % app._player_power(), 16)
\tpower.position = Vector2(181, 52)
\tpower.size = Vector2(173, 36)
\tpower.modulate = Color(0.84, 0.74, 0.24)
\tapp.content.add_child(power)
\tvar player_btn = Button.new()
\tplayer_btn.text = ""
\tplayer_btn.flat = true
\tplayer_btn.position = Vector2(0, 5)
\tplayer_btn.size = Vector2(354, 113)
\tplayer_btn.pressed.connect(app._show_player_info)
\tapp.content.add_child(player_btn)
\tapp._add_action_button("\\u6362", Vector2(402, 58), app._show_gallery, Vector2(74, 74))
\tapp._add_action_button("\\u773c", Vector2(478, 58), enter_wallpaper_focus, Vector2(74, 74))

func draw_funny_content() -> void:
\tvar actions = [
\t\t[UI_MAIN_FUNNY_ARENA, "\\u7ade\\u6280", app._show_battle],
\t\t[UI_MAIN_FUNNY_PRAYER, "\\u7948\\u613f", app._open_prayer_pool],
\t\t[UI_MAIN_FUNNY_ADVENTURE, "\\u5192\\u9669", app._show_battle],
\t\t[UI_MAIN_FUNNY_DRAW, "\\u559a\\u7075", app._open_present_pool]
\t]
\t# pnlFunnyContent: anchor (1,0) pos=(-339,70) - 4 buttons 88x102 horizontal
\tvar px = 1670.0 - 339 - 88 * 4 - 6 * 3
\tvar py = 70.0
\tfor item in actions:
\t\tvar bg = app._draw_image(str(item[0]), Vector2(px, py), Vector2(88, 102), false, Color(1, 1, 1, 0.84))
\t\t_main_panels.append(bg)
\t\tapp._add_action_button(str(item[1]), Vector2(px + 2, py + 66), item[2], Vector2(84, 36))
\t\tapp._draw_red_dot(Vector2(px + 70, py + 4))
\t\tpx += 94

func draw_story_row() -> void:
\t# pnlStory: 278x98, anchor (1,0) pos=(-60,19)
\tvar sx = 1670.0 - 60 - 278
\tvar sy = 19.0
\tvar story_bg = app._draw_image(UI_MAIN_STORY_BG, Vector2(sx, sy), Vector2(278, 98), false, Color(1, 1, 1, 0.88))
\t_main_panels.append(story_bg)
\tvar story = app._label("\\u4e3b\\u7ebf %s\\n\\u6302\\u673a\\u6536\\u76ca %s" % [app._next_task_text(), "\\u53ef\\u6536\\u53d6" if not app._afk_claimed_today() else "\\u5df2\\u6536\\u53d6"], 16)
\tstory.position = Vector2(sx + 18, sy + 16)
\tstory.size = Vector2(160, 48)
\tapp.content.add_child(story)
\t# btnHarvest: 106x106 inside pnlStory pos=(67,1)
\tapp._add_action_button("\\u6536\\u83b7", Vector2(sx + 67, sy + 1), app._claim_afk_reward, Vector2(106, 106))
\tapp._draw_red_dot(Vector2(sx + 260, sy + 2))

func draw_charge_column() -> void:
\t# pnlCharge: 158x258, anchor (1,1) pos=(-55,-277)
\tvar cx = 1670.0 - 55 - 158
\tvar cy = 750.0 - 277 - 258
\tvar labels = [["\\u6d3b\\u52a8", app._show_daily], ["\\u798f\\u5229", app._show_daily], ["\\u6708\\u5361", app._show_shop], ["\\u5145\\u503c", app._show_shop], ["\\u5546\\u5e97", app._show_shop]]
\tfor i in range(labels.size()):
\t\tvar icon = app._draw_image(str(UI_MAIN_CHARGE_ICONS[i]), Vector2(cx, cy), Vector2(78, 78), false, Color(1, 1, 1, 0.86))
\t\t_main_panels.append(icon)
\t\tapp._add_action_button(str(labels[i][0]), Vector2(cx + 2, cy + 56), labels[i][1], Vector2(74, 30))
\t\tapp._draw_red_dot(Vector2(cx + 60, cy + 2))
\t\tcy += 52

func draw_menu_button() -> void:
\t# btnMenu: 78x78, anchor (1,1) pos=(-94,-54)
\tvar mx = 1670 - 94 - 78
\tvar my = 750 - 54 - 78
\tapp._draw_image(UI_MAIN_MENU, Vector2(mx, my), Vector2(78, 78), false, Color(1, 1, 1, 0.92))
\tapp._add_action_button("", Vector2(mx, my), app._show_home, Vector2(78, 78))
\tapp._draw_red_dot(Vector2(mx + 62, my + 4))

func draw_assist_button() -> void:
\t# btnAssist: 78x96, anchor (0,1) pos=(413,-164)
\tapp._draw_image(UI_MAIN_ASSIST, Vector2(413, 164), Vector2(78, 96), false, Color(1, 1, 1, 0.84))
\tapp._add_action_button("\\u63f4\\u52a9", Vector2(413, 240), app._show_mail, Vector2(78, 30))

func draw_commercialization_panel() -> void:
\t# pnlCommercialization: 416x420, anchor (0,1) pos=(265,-333)
\tvar px = 265
\tvar py = 333
\t# @pnlAlternate: 301x108
\tapp._draw_image(UI_MAIN_BANNER, Vector2(px, py), Vector2(301, 108), false, Color(1, 1, 1, 0.92))
\t# pnlGift: 409x300, offset (7,-120) from pnlCommercialization
\tvar gx = px + 7
\tvar gy = py + 108 + 12
\tapp.content.add_child(app._panel(Vector2(gx, gy), Vector2(409, 300), Color(0.030, 0.023, 0.018, 0.56)))
\tvar gifts = [
\t\t["\\u8865\\u7ed9", app._show_daily], ["\\u90ae\\u4ef6", app._show_mail], ["\\u7b7e\\u5230", app._show_daily],
\t\t["\\u5956\\u52b1", app._show_tasks], ["\\u95ee\\u7b54", app._show_home], ["\\u793c\\u5305", app._show_shop],
\t\t["\\u6708\\u5361", app._show_shop], ["\\u5145\\u503c", app._show_shop], ["\\u5546\\u5e97", app._show_shop]
\t]
\tvar ix = gx + 10.0
\tvar iy = gy + 14.0
\tvar gi = 0
\tfor gift in gifts:
\t\tvar slot = app._panel(Vector2(ix, iy), Vector2(88, 72), Color(0.040, 0.034, 0.030, 0.74))
\t\tapp.content.add_child(slot)
\t\tapp._add_action_button(str(gift[0]), Vector2(ix + 4, iy + 14), gift[1], Vector2(80, 44))
\t\tapp._draw_red_dot(Vector2(ix + 72, iy + 4))
\t\tgi += 1
\t\tix += 96
\t\tif gi % 4 == 0:
\t\t\tix = gx + 10
\t\t\tiy += 84

func draw_chapter_panel() -> void:
\t# btnChapterInfo: 276x100, anchor (1,0) pos=(-34,150)
\tvar px = 1670.0 - 34 - 276
\tvar py = 150.0
\tvar bg = app._draw_image(UI_MAIN_CHAPTER_BG, Vector2(px, py), Vector2(276, 100), false, Color(1, 1, 1, 0.90))
\t_main_panels.append(bg)
\tvar info = app._label("\\u7ae0\\u8282  %s\\n\\u5956\\u52b1  \\u6536\\u96c6 %d / \\u62bd\\u5361 %d" % [
\t\tapp._next_task_text(),
\t\tapp.save.get("owned", {}).size(),
\t\tint(app.save.get("draw_count", 0))
\t], 16)
\tinfo.position = Vector2(px + 18, py + 18)
\tinfo.size = Vector2(230, 62)
\tapp.content.add_child(info)
\tapp._add_action_button("", Vector2(px, py), app._show_tasks, Vector2(276, 100))
\tapp._draw_red_dot(Vector2(px + 10, py + 6))

func draw_bottom_bar() -> void:
\t# pnlBottom: height 50, anchor (0,0) pos=(64,49)
\tvar bar_y = 700.0
\tvar bar = app._panel(Vector2(64, bar_y), Vector2(1670 - 64, 50), Color(0.026, 0.022, 0.020, 0.90))
\tapp.content.add_child(bar)
\t_main_panels.append(bar)
\tapp.content.add_child(app._panel(Vector2(64, bar_y), Vector2(1670 - 64, 2), Color(0.86, 0.65, 0.32, 0.26)))
\tvar buttons = [
\t\t["\\u6b66\\u5c06", app._show_gallery, true],
\t\t["\\u80cc\\u5305", app._show_shop, false],
\t\t["\\u5ba0\\u7269", app._show_home, false],
\t\t["\\u517b\\u6210", app._show_gallery, true],
\t\t["\\u4efb\\u52a1", app._show_tasks, true],
\t\t["\\u519b\\u56e2", app._show_home, false]
\t]
\tvar btn_w = 86
\tvar bx = 210.0
\tfor item in buttons:
\t\tapp._draw_image(UI_MAIN_BOTTOM_BTN, Vector2(bx, bar_y), Vector2(btn_w, btn_w), false, Color(1, 1, 1, 0.34))
\t\tapp._add_action_button(str(item[0]), Vector2(bx, bar_y), item[1], Vector2(btn_w, 50))
\t\tapp._draw_image(UI_MAIN_SEPARATOR, Vector2(bx + btn_w + 2, bar_y + 16), Vector2(2, 18), false, Color(1, 1, 1, 0.55))
\t\tif item[2]:
\t\t\tapp._draw_red_dot(Vector2(bx + btn_w - 20, bar_y + 2))
\t\tbx += btn_w + 8

func draw_gal_entry_button() -> void:
\t# pnlGal: anchor (0,0) bottom-left. btnGal: 115x129 pos=(0,40)
\tvar gal_y = 700.0 - 79
\tapp._draw_image(UI_MAIN_GAL, Vector2(0, gal_y), Vector2(115, 129), false, Color(1, 1, 1, 0.92))
\tapp._add_action_button("\\u7ea6\\u4f1a", Vector2(12, gal_y + 92), enter_gal_entry, Vector2(91, 37))
\tapp._draw_red_dot(Vector2(90, gal_y + 8))

func draw_chat_bar() -> void:
\t# pnlChat: 410x40, anchor (1,1) pos=(-64,-94)
\tvar cx = 1670 - 64 - 410
\tvar cy = 750 - 94 - 40
\tvar bg = app._draw_image(UI_MAIN_CHAT_BG, Vector2(cx, cy), Vector2(410, 40), false, Color(1, 1, 1, 0.72))
\t_main_panels.append(bg)
\t# @txtChat: 341x40, pos=(64,0)
\tvar chat = app._label("\\u4e16\\u754c  \\u79bb\\u7ebf\\u6a21\\u5f0f\\u5df2\\u542f\\u7528", 14)
\tchat.position = Vector2(cx + 64, cy + 10)
\tchat.size = Vector2(330, 22)
\tchat.modulate = Color(0.68, 0.64, 0.58)
\tapp.content.add_child(chat)
\t# @btnChat: full anchor button
\tapp._add_action_button("", Vector2(cx, cy), app._show_mail, Vector2(410, 40))

func draw_cover_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint: Color) -> void:
\tvar texture = app._hero_portrait_texture(hero)
\tif texture == null:
\t\treturn
\tvar rect = TextureRect.new()
\trect.texture = texture
\trect.position = pos
\trect.size = draw_size
\trect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\trect.stretch_mode = TextureRect.STRETCH_SCALE
\trect.modulate = tint
\tapp.content.add_child(rect)
"""

with open('D:/work/openclaw-workspace/arpg/shaonv/standalone/godot-mvp/scripts/screens/home_screen.gd', 'w', encoding='utf-8') as f:
    f.write(content)
print("Written successfully")
