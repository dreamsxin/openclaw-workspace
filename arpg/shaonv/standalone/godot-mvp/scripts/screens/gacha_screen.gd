# UTF-8 source. LotteryDrawMainView first-screen reconstruction split from main.gd.
extends RefCounted

const UI_LOTTERY_ALPHA_L := "res://assets/ui/lottery/lottery_img_alpha_l.png"
const UI_LOTTERY_ALPHA_R := "res://assets/ui/lottery/lottery_img_alpha_r.png"
const UI_LOTTERY_BG_ADVANCED := "res://assets/ui/lottery/bg/lottery_bg_01.png"
const UI_LOTTERY_BG_EPIC := "res://assets/ui/lottery/bg/lottery_bg_03.png"
const UI_LOTTERY_BG_NORMAL := "res://assets/ui/lottery/bg/lottery_bg_02.png"
const UI_LOTTERY_BG_PRAYER := "res://assets/ui/lottery/bg/lottery_bg_08.png"
const UI_LOTTERY_BTN_SINGLE := "res://assets/ui/common/lottery_btn_05.png"
const UI_LOTTERY_BTN_TEN := "res://assets/ui/common/lottery_btn_06.png"
const UI_LOTTERY_POOL_FRAME := "res://assets/ui/lottery/lottery_img_55.png"
const UI_LOTTERY_PRAYER_FRAME := "res://assets/ui/lottery/lottery_img_57.png"
const UI_LOTTERY_TICKET_ICON := "res://assets/ui/item/draw_03.png"

var app

func _init(app_ref) -> void:
	app = app_ref

func show_gacha() -> void:
	var pool = app._pool_by_id(str(app.save.get("active_pool_id", "advanced")))
	var realm = app._active_gacha_realm()
	app._set_chrome_visible(false)
	app.content.position = Vector2(0, 0)
	app.content.size = Vector2(1280, 720)
	app._clear("現世" if realm == "present" else "幻靈")
	app._draw_image(lottery_bg_for_pool(str(pool.get("id", "advanced"))), Vector2(-160, 0), Vector2(1600, 720), true)
	app.content.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.014, 0.016, 0.14)))
	app._draw_image(UI_LOTTERY_ALPHA_L, Vector2(254, 62), Vector2(410, 142), false, Color(1, 1, 1, 0.52))
	app._draw_image(UI_LOTTERY_ALPHA_R, Vector2(792, 62), Vector2(410, 128), false, Color(1, 1, 1, 0.52))

	draw_top_buttons()
	draw_pool_tabs(realm)
	draw_pool_panel(pool, realm)
	draw_wish_panel(pool, realm)
	var hero = app._hero_by_id(int(pool.get("featuredHeroIds", [240055])[0]))
	app._draw_hero_stage(hero, Vector2(612, 66), Vector2(500, 566), false)
	app._add_action_button("返回", Vector2(34, 28), app._show_home, Vector2(92, 42))

func draw_top_buttons() -> void:
	app.content.add_child(app._panel(Vector2(42, 40), Vector2(404, 80), Color(0.026, 0.020, 0.018, 0.50)))
	app._add_action_button("概率", Vector2(64, 54), app._show_gacha_rate, Vector2(66, 52))
	app._add_action_button("商店", Vector2(142, 54), app._show_shop, Vector2(66, 52))
	app._add_action_button("兌換", Vector2(220, 54), app._show_shop, Vector2(66, 52))
	app._add_action_button("積分", Vector2(298, 54), app._show_tasks, Vector2(66, 52))
	var skip = CheckBox.new()
	skip.text = "跳過動畫"
	skip.button_pressed = false
	skip.position = Vector2(42, 134)
	skip.size = Vector2(154, 34)
	app.content.add_child(skip)

func draw_pool_tabs(realm: String) -> void:
	app.content.add_child(app._panel(Vector2(972, 126), Vector2(246, 470), Color(0.026, 0.020, 0.019, 0.62)))
	app._add_realm_button("現世", "present", Vector2(994, 144))
	app._add_realm_button("幻靈", "prayer", Vector2(1100, 144))
	var y = 208.0
	for pool_item in app.pools:
		var pool_id = str(pool_item.get("id", "advanced"))
		if not app._pool_in_realm(pool_id, realm):
			continue
		app._draw_image(UI_LOTTERY_POOL_FRAME if realm == "present" else UI_LOTTERY_PRAYER_FRAME, Vector2(1000, y - 8), Vector2(190, 56), false, Color(1, 1, 1, 0.70))
		var button = Button.new()
		button.text = "%s%s" % ["✓ " if pool_id == str(app.save.get("active_pool_id", "advanced")) else "", str(pool_item.get("name", "Pool"))]
		button.position = Vector2(1008, y)
		button.size = Vector2(174, 42)
		button.pressed.connect(func() -> void:
			app.save["active_pool_id"] = pool_id
			app._persist()
			show_gacha()
		)
		app.content.add_child(button)
		y += 72

func draw_pool_panel(pool: Dictionary, realm: String) -> void:
	var title = app._label("%s  %s" % ["現世" if realm == "present" else "幻靈", pool.get("name", "高級喚靈")], 40)
	title.position = Vector2(216, 126)
	title.size = Vector2(520, 56)
	app.content.add_child(title)
	var featured_names = []
	for id in pool.get("featuredHeroIds", []):
		featured_names.append(app._hero_by_id(int(id)).get("name", str(id)))
	var rates: Dictionary = pool.get("rates", {})
	app.content.add_child(app._panel(Vector2(216, 198), Vector2(420, 196), Color(0.018, 0.014, 0.012, 0.50)))
	app._draw_image(UI_LOTTERY_TICKET_ICON, Vector2(486, 312), Vector2(32, 36), false)
	var detail = app._label("UP 角色\n%s\n\n保底 %d/%d\n消耗喚靈券       x%d\n%s %.1f%%  %s %.1f%%" % [
		" / ".join(featured_names),
		app._pity(pool.get("id", "advanced")),
		int(pool.get("pityLimit", 60)),
		int(pool.get("ticketCost", 1)),
		app._stars(4),
		float(rates.get("4", 0.02)) * 100.0,
		app._stars(3),
		float(rates.get("3", 0.14)) * 100.0
	], 21)
	detail.position = Vector2(238, 212)
	detail.size = Vector2(376, 170)
	app.content.add_child(detail)

func draw_wish_panel(pool: Dictionary, realm: String) -> void:
	app.content.add_child(app._panel(Vector2(214, 420), Vector2(330, 70), Color(0.035, 0.027, 0.023, 0.52)))
	var wish = app._label("祈願角色位", 18)
	wish.position = Vector2(236, 438)
	wish.size = Vector2(116, 30)
	app.content.add_child(wish)
	for i in range(2 if realm == "present" else 1):
		var slot_pos = Vector2(358 + i * 88, 424)
		app.content.add_child(app._panel(slot_pos, Vector2(70, 70), Color(0.09, 0.072, 0.058, 0.82)))
		var add = app._label("+", 30, HORIZONTAL_ALIGNMENT_CENTER)
		add.position = slot_pos + Vector2(0, 14)
		add.size = Vector2(70, 34)
		app.content.add_child(add)
	app._draw_image(UI_LOTTERY_BTN_SINGLE, Vector2(214, 566), Vector2(194, 70), false, Color(1, 1, 1, 0.86))
	app._draw_image(UI_LOTTERY_BTN_TEN, Vector2(424, 566), Vector2(214, 70), false, Color(1, 1, 1, 0.86))
	app._add_action_button("召喚 1 次", Vector2(236, 576), func() -> void: app._show_draw_animation(1), Vector2(150, 50))
	app._add_action_button("召喚 10 次", Vector2(454, 576), func() -> void: app._show_draw_animation(10), Vector2(156, 50))

func lottery_bg_for_pool(pool_id: String) -> String:
	match pool_id:
		"normal":
			return UI_LOTTERY_BG_NORMAL
		"epic":
			return UI_LOTTERY_BG_EPIC
		"prayer":
			return UI_LOTTERY_BG_PRAYER
		_:
			return UI_LOTTERY_BG_ADVANCED
