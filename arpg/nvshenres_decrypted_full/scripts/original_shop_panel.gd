extends Control

const HOME_SCENE := "res://scenes/original_home_screen.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const DESIGN_SIZE := Vector2(1280, 720)
const BG_PATH := "res://assets/resources/native/92/929b60ed-1b1e-4419-b357-d7c9d1e43436.jpg"
const MONEY_GOLD := "image/equipment/101"
const MONEY_DIAMOND := "image/equipment/102"
const SHOP_TAG_ATLAS := "res://assets/resources/native/18/184257350.png"
const SHOP_TAG_DISCOUNT_RECT := Rect2i(327, 770, 88, 22)
const SHOP_TAG_RARE_RECT := Rect2i(238, 738, 109, 26)
const COMMON_DISABLED_ATLAS := "res://assets/resources/native/71/71561142-4c83-4933-afca-cb7a17f67053.png"
const COMMON_DISABLED_RECT := Rect2i(0, 0, 40, 40)
const DIALOG_BG_ATLAS := "res://assets/resources/native/e8/e851e89b-faa2-4484-bea6-5c01dd9f06e2.png"
const DIALOG_BG_RECT := Rect2i(0, 0, 40, 40)
const GREEN_BUTTON_ATLAS := "res://assets/resources/native/15/15a1d9111.png"
const GREEN_BUTTON_RECT := Rect2i(512, 589, 285, 66)
const GREEN_SMALL_BUTTON_ATLAS := "res://assets/resources/native/1d/1d816a710.png"
const GREEN_SMALL_BUTTON_RECT := Rect2i(861, 782, 238, 66)
const PLUS_ATLAS := "res://assets/resources/native/15/15a1d9111.png"
const PLUS_RECT := Rect2i(996, 828, 24, 24)
const SMALL_FRAME_RECT := Rect2i(125, 841, 54, 56)
const SLIDER_ATLAS := "res://assets/resources/native/1a/1a61aeab8.png"
const SLIDER_BG_RECT := Rect2i(747, 87, 256, 18)
const SHOP_SEPARATOR_RECT := Rect2i(39, 963, 2, 46)

const MAIN_TYPES := [
	{"label": "基础商店", "type": 1},
	{"label": "战斗商店", "type": 2},
]
const SHOP_TYPES := [
	{"label": "黑市", "icon": "101", "type": 1, "main_type": 1},
	{"label": "道具", "icon": "102", "type": 2, "main_type": 1},
	{"label": "竞技", "icon": "109", "type": 8, "main_type": 2},
	{"label": "公会", "icon": "110", "type": 4, "main_type": 2},
	{"label": "许愿", "icon": "201", "type": 5, "main_type": 2},
	{"label": "英魂", "icon": "202", "type": 15, "main_type": 2},
]
const GOODS := [
	{"name": "高级召唤券", "item": 9, "price": 1200, "currency": MONEY_GOLD, "limit": "每日限购: 2/5", "rare": 2, "discount": "8折"},
	{"name": "星辉宝箱", "item": 14, "price": 300, "currency": MONEY_DIAMOND, "limit": "每周限购: 1/3", "rare": 1, "discount": ""},
	{"name": "突破石", "item": 8, "price": 450, "currency": MONEY_GOLD, "limit": "限购: 6/10", "rare": 0, "discount": ""},
	{"name": "神铸核心", "item": 0, "price": 1280, "currency": MONEY_DIAMOND, "limit": "终身限购: 1/1", "rare": 2, "discount": "限时"},
	{"name": "升星石", "item": 4, "price": 980, "currency": MONEY_GOLD, "limit": "每日限购: 4/8", "rare": 1, "discount": ""},
	{"name": "英雄碎片", "item": 6, "price": 600, "currency": MONEY_DIAMOND, "limit": "每月限购: 8/20", "rare": 1, "discount": "9折"},
	{"name": "符文原石", "item": 13, "price": 360, "currency": MONEY_GOLD, "limit": "限购: 12/30", "rare": 0, "discount": ""},
	{"name": "装备精华", "item": 11, "price": 180, "currency": MONEY_GOLD, "limit": "不限购", "rare": 0, "discount": ""},
]

var design_root: Control
var goods_grid: GridContainer
var shop_type_box: VBoxContainer
var main_type_buttons: Array[Button] = []
var shop_type_buttons: Array[Button] = []
var named_resources: Dictionary = {}
var equipment_icons: Array = []
var buy_dialog: Control
var selected_main_type := 1
var selected_shop_type := 1

func _ready() -> void:
	_load_named_resources()
	_load_equipment_icons()
	_build_ui()
	_apply_cmdline_args()
	_capture_if_requested()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.025, 0.028, 0.04, 1.0)
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.72, 0.78, 0.9, 0.45)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.5)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(shade)

	_build_top_bar()
	_build_money_bar()
	_build_main_type_tabs()
	_build_goods_area()
	_build_shop_type_tabs()
	_build_refresh_bar()
	_layout_design_root()
	_refresh_main_type_tabs()
	_refresh_shop_type_tabs()
	_refresh_goods()

func _build_top_bar() -> void:
	var top := HBoxContainer.new()
	top.anchor_left = 1.0
	top.anchor_right = 1.0
	top.offset_left = -690
	top.offset_top = 676
	top.offset_right = -12
	top.offset_bottom = 710
	top.alignment = BoxContainer.ALIGNMENT_END
	top.add_theme_constant_override("separation", 6)
	add_child(top)

	var title := Label.new()
	title.text = "ShopPre | 商会"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	Navigation.add_buttons(top)
	_add_top_button(top, "主城", func(): Navigation.go(HOME_SCENE))
	_add_top_button(top, "Prefab", func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "商店"}))

func _build_money_bar() -> void:
	var money := HBoxContainer.new()
	money.position = Vector2(800, 12)
	money.size = Vector2(408, 48)
	money.add_theme_constant_override("separation", 6)
	design_root.add_child(money)
	_add_money_item(money, MONEY_GOLD, "2.25M")
	_add_money_item(money, MONEY_DIAMOND, "878")

func _add_money_item(parent: Container, icon_name: String, value: String) -> void:
	var box := Control.new()
	box.custom_minimum_size = Vector2(194, 42)
	parent.add_child(box)
	var bg := ColorRect.new()
	bg.position = Vector2(18, 4)
	bg.size = Vector2(164, 34)
	bg.color = Color(0.025, 0.028, 0.04, 0.76)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)
	var icon := TextureRect.new()
	icon.position = Vector2(0, -4)
	icon.size = Vector2(52, 52)
	icon.texture = _texture_for_named_resource(icon_name)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)
	_add_label(box, value, Vector2(58, 7), Vector2(88, 28), 18, Color(0.96, 0.9, 0.72), HORIZONTAL_ALIGNMENT_RIGHT)
	var plus := Button.new()
	plus.text = ""
	plus.position = Vector2(152, 7)
	plus.size = Vector2(30, 28)
	box.add_child(plus)
	_add_sprite_frame_image(plus, PLUS_ATLAS, PLUS_RECT, Vector2(3, 2), Vector2(24, 24), false, Vector2i(24, 24), Vector2.ZERO, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

func _build_main_type_tabs() -> void:
	var box := HBoxContainer.new()
	box.position = Vector2(312.671, 86.602)
	box.size = Vector2(386, 48)
	box.add_theme_constant_override("separation", 85)
	design_root.add_child(box)
	for item in MAIN_TYPES:
		var button := Button.new()
		button.text = str(item.label)
		button.custom_minimum_size = Vector2(150, 40)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_select_main_type.bind(int(item.type)))
		box.add_child(button)
		main_type_buttons.append(button)

func _build_goods_area() -> void:
	var panel := Control.new()
	panel.position = Vector2(269.456, 64.114)
	panel.size = Vector2(834, 662)
	design_root.add_child(panel)
	var panel_bg := ColorRect.new()
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_bg.color = Color(0.035, 0.04, 0.065, 0.54)
	panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(panel_bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(67.0, 115.661)
	scroll.size = Vector2(700, 550)
	panel.add_child(scroll)

	goods_grid = GridContainer.new()
	goods_grid.columns = 2
	goods_grid.add_theme_constant_override("h_separation", 0)
	goods_grid.add_theme_constant_override("v_separation", 0)
	goods_grid.custom_minimum_size = Vector2(700, 800)
	scroll.add_child(goods_grid)

func _build_shop_type_tabs() -> void:
	shop_type_box = VBoxContainer.new()
	shop_type_box.position = Vector2(1069, 138.388)
	shop_type_box.size = Vector2(250, 480)
	shop_type_box.add_theme_constant_override("separation", 30)
	design_root.add_child(shop_type_box)

func _build_refresh_bar() -> void:
	var bar := Control.new()
	bar.position = Vector2(760, 64)
	bar.size = Vector2(330, 70)
	design_root.add_child(bar)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.035, 0.05, 0.46)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(bg)
	_add_label(bar, "01:26:34", Vector2(8, 9), Vector2(92, 28), 18, Color(0.74, 0.9, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(bar, "免费(1/3)", Vector2(112, 13), Vector2(98, 24), 16, Color(0.9, 0.92, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var refresh := Button.new()
	refresh.text = "刷新"
	refresh.position = Vector2(118, 7)
	refresh.size = Vector2(196, 54)
	bar.add_child(refresh)

func _refresh_goods() -> void:
	for child in goods_grid.get_children():
		child.queue_free()
	for i in GOODS.size():
		var card := Button.new()
		card.custom_minimum_size = Vector2(350, 120)
		card.text = ""
		card.pressed.connect(_buy_goods.bind(i))
		goods_grid.add_child(card)
		_draw_goods_card(card, GOODS[i], i)

func _draw_goods_card(parent: Control, item: Dictionary, index: int) -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.065, 0.058, 0.09, 0.92)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)

	var rare := int(item.get("rare", 0))
	var frame_colors: Array[Color] = [Color(0.36, 0.34, 0.43), Color(0.38, 0.3, 0.62), Color(0.76, 0.45, 0.14)]
	var frame_color := frame_colors[rare]
	var icon_bg := ColorRect.new()
	icon_bg.position = Vector2(8, 5)
	icon_bg.size = Vector2(110, 110)
	icon_bg.color = frame_color
	icon_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon_bg)

	var icon := TextureRect.new()
	icon.position = Vector2(20, 17)
	icon.size = Vector2(86, 86)
	icon.texture = _load_indexed_texture(_equipment_icon(int(item.item)))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)

	_add_label(parent, str(item.name), Vector2(126, 14), Vector2(198, 30), 21, Color(1.0, 0.88, 0.54))
	_add_label(parent, str(item.limit), Vector2(126, 52), Vector2(190, 24), 16, Color(0.75, 0.88, 1.0))
	if str(item.discount) != "":
		_add_sprite_frame_image(parent, SHOP_TAG_ATLAS, SHOP_TAG_DISCOUNT_RECT, Vector2(0, 0), Vector2(70, 30), true, Vector2i(88, 22))
		_add_label(parent, str(item.discount), Vector2(7, 2), Vector2(56, 26), 15, Color(1.0, 0.9, 0.7), HORIZONTAL_ALIGNMENT_CENTER)

	if rare > 0:
		if rare == 1:
			_add_sprite_frame_image(parent, SHOP_TAG_ATLAS, SHOP_TAG_RARE_RECT, Vector2(19, 91), Vector2(88, 22))
		else:
			_add_sprite_frame_image(parent, COMMON_DISABLED_ATLAS, COMMON_DISABLED_RECT, Vector2(19, 91), Vector2(88, 22))
		_add_label(parent, "稀有" if rare == 1 else "战意专属", Vector2(19, 89), Vector2(88, 25), 14, Color(1.0, 0.88, 0.58), HORIZONTAL_ALIGNMENT_CENTER)

	var price_icon := TextureRect.new()
	price_icon.position = Vector2(118, 82)
	price_icon.size = Vector2(34, 34)
	price_icon.texture = _texture_for_named_resource(str(item.currency))
	price_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	price_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	price_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(price_icon)
	_add_label(parent, str(item.price), Vector2(154, 84), Vector2(82, 28), 18, Color(0.96, 0.9, 0.74))

	var buy_bg := _add_sprite_frame_image(parent, GREEN_SMALL_BUTTON_ATLAS, GREEN_SMALL_BUTTON_RECT, Vector2(256, 78), Vector2(78, 32), true, Vector2i(238, 66), Vector2.ZERO, TextureRect.STRETCH_SCALE)
	buy_bg.modulate = Color(0.9, 1.0, 1.0, 0.82)
	_add_label(parent, "购买", Vector2(256, 77), Vector2(78, 34), 18, Color(0.95, 1.0, 0.92), HORIZONTAL_ALIGNMENT_CENTER)

func _refresh_shop_type_tabs() -> void:
	for child in shop_type_box.get_children():
		child.queue_free()
	shop_type_buttons.clear()
	for item in SHOP_TYPES:
		if int(item.main_type) != selected_main_type:
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(180, 64)
		button.text = ""
		button.add_theme_font_size_override("font_size", 21)
		button.pressed.connect(_select_shop_type.bind(int(item.type)))
		shop_type_box.add_child(button)
		shop_type_buttons.append(button)
		_add_shop_type_button_content(button, item)
		if selected_shop_type == int(item.type):
			button.disabled = true

func _refresh_main_type_tabs() -> void:
	for i in main_type_buttons.size():
		main_type_buttons[i].disabled = int(MAIN_TYPES[i].type) == selected_main_type

func _select_main_type(value: int) -> void:
	selected_main_type = value
	for item in SHOP_TYPES:
		if int(item.main_type) == selected_main_type:
			selected_shop_type = int(item.type)
			break
	_refresh_main_type_tabs()
	_refresh_shop_type_tabs()
	_refresh_goods()

func _select_shop_type(value: int) -> void:
	selected_shop_type = value
	_refresh_shop_type_tabs()
	_refresh_goods()

func _buy_goods(index: int) -> void:
	var item: Dictionary = GOODS[index % GOODS.size()]
	_show_buy_dialog(item)

func _show_buy_dialog(item: Dictionary) -> void:
	if buy_dialog:
		buy_dialog.queue_free()
	buy_dialog = Control.new()
	buy_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	design_root.add_child(buy_dialog)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.58)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	buy_dialog.add_child(dim)

	var panel := Control.new()
	panel.position = Vector2(407, 106)
	panel.size = Vector2(465, 507)
	buy_dialog.add_child(panel)

	_add_sprite_frame_image(panel, DIALOG_BG_ATLAS, DIALOG_BG_RECT, Vector2.ZERO, panel.size, false, Vector2i(40, 40), Vector2.ZERO, TextureRect.STRETCH_SCALE)

	_add_sprite_frame_image(panel, COMMON_DISABLED_ATLAS, COMMON_DISABLED_RECT, Vector2(82, 54), Vector2(302, 8), false, Vector2i(40, 40), Vector2.ZERO, TextureRect.STRETCH_SCALE)

	_add_label(panel, str(item.name), Vector2(120, 74), Vector2(224, 36), 24, Color(1.0, 0.88, 0.55), HORIZONTAL_ALIGNMENT_CENTER)

	var icon_bg := ColorRect.new()
	icon_bg.position = Vector2(177, 118)
	icon_bg.size = Vector2(110, 110)
	icon_bg.color = Color(0.16, 0.12, 0.22, 0.96)
	icon_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(icon_bg)
	var icon := TextureRect.new()
	icon.position = Vector2(189, 130)
	icon.size = Vector2(86, 86)
	icon.texture = _load_indexed_texture(_equipment_icon(int(item.item)))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(icon)
	_add_label(panel, "x1", Vector2(286, 202), Vector2(52, 30), 20, Color(0.93, 0.94, 1.0))
	_add_label(panel, "拥有：99", Vector2(172, 242), Vector2(130, 28), 17, Color(0.72, 0.88, 0.74), HORIZONTAL_ALIGNMENT_CENTER)
	_add_label(panel, str(item.limit), Vector2(142, 270), Vector2(180, 28), 17, Color(0.82, 0.86, 0.96), HORIZONTAL_ALIGNMENT_CENTER)

	var count_state := {"value": 1}
	var count_label := _add_label(panel, "1", Vector2(218, 317), Vector2(36, 30), 20, Color(1.0, 0.9, 0.65), HORIZONTAL_ALIGNMENT_CENTER)
	var total_label := _add_label(panel, str(item.price), Vector2(218, 421), Vector2(80, 30), 19, Color(1.0, 0.9, 0.65))
	var bar_bg := _add_sprite_frame_image(panel, SLIDER_ATLAS, SLIDER_BG_RECT, Vector2(120, 330), Vector2(185, 18), false, Vector2i(256, 18), Vector2.ZERO, TextureRect.STRETCH_SCALE)
	var bar_fill := ColorRect.new()
	bar_fill.position = Vector2(122, 333)
	bar_fill.size = Vector2(32, 12)
	bar_fill.color = Color(0.67, 0.46, 0.2, 0.95)
	bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(bar_fill)
	panel.move_child(bar_bg, bar_fill.get_index())

	var update_count := func() -> void:
		count_label.text = str(count_state.value)
		total_label.text = str(int(item.price) * int(count_state.value))
		bar_fill.size.x = 32 + 148 * float(count_state.value) / 10.0

	_add_count_button(panel, "-", Vector2(58, 314), func():
		count_state.value = maxi(1, int(count_state.value) - 1)
		update_count.call()
	)
	_add_count_button(panel, "+", Vector2(320, 314), func():
		count_state.value = mini(10, int(count_state.value) + 1)
		update_count.call()
	)
	_add_count_button(panel, "MAX", Vector2(382, 319), func():
		count_state.value = 10
		update_count.call()
	, Vector2(54, 31))

	var price_icon := TextureRect.new()
	price_icon.position = Vector2(166, 416)
	price_icon.size = Vector2(34, 34)
	price_icon.texture = _texture_for_named_resource(str(item.currency))
	price_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	price_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	price_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(price_icon)
	_add_label(panel, "总价", Vector2(96, 418), Vector2(70, 30), 18, Color(0.82, 0.86, 0.96), HORIZONTAL_ALIGNMENT_RIGHT)

	var confirm := Button.new()
	confirm.text = ""
	confirm.position = Vector2(112, 462)
	confirm.size = Vector2(240, 38)
	confirm.add_theme_font_size_override("font_size", 20)
	confirm.pressed.connect(func(): _close_buy_dialog())
	panel.add_child(confirm)
	_add_sprite_frame_image(confirm, GREEN_BUTTON_ATLAS, GREEN_BUTTON_RECT, Vector2.ZERO, confirm.size, false, Vector2i(285, 66), Vector2.ZERO, TextureRect.STRETCH_SCALE)
	confirm.move_child(confirm.get_child(confirm.get_child_count() - 1), 0)
	_add_center_label(confirm, "购买", 20, Color(0.95, 1.0, 0.92))

	var close := Button.new()
	close.text = "X"
	close.position = Vector2(410, 14)
	close.size = Vector2(36, 32)
	close.pressed.connect(_close_buy_dialog)
	panel.add_child(close)
	update_count.call()

func _add_count_button(parent: Control, text: String, position: Vector2, callback: Callable, size := Vector2(44, 44)) -> void:
	var button := Button.new()
	button.text = ""
	button.position = position
	button.size = size
	button.pressed.connect(callback)
	parent.add_child(button)
	if text in ["-", "+"]:
		_add_sprite_frame_image(button, SHOP_TAG_ATLAS, SMALL_FRAME_RECT, Vector2.ZERO, button.size, true, Vector2i(54, 56), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		button.move_child(button.get_child(button.get_child_count() - 1), 0)
	elif text == "MAX":
		_add_sprite_frame_image(button, GREEN_SMALL_BUTTON_ATLAS, GREEN_SMALL_BUTTON_RECT, Vector2.ZERO, button.size, true, Vector2i(238, 66), Vector2.ZERO, TextureRect.STRETCH_SCALE)
		button.move_child(button.get_child(button.get_child_count() - 1), 0)
	_add_center_label(button, text, 18 if text != "MAX" else 14, Color(0.95, 1.0, 0.92))

func _add_shop_type_button_content(button: Button, item: Dictionary) -> void:
	_add_sprite_frame_image(button, SHOP_TAG_ATLAS, SHOP_SEPARATOR_RECT, Vector2(0, 8), Vector2(4, 48), false, Vector2i(2, 46), Vector2.ZERO, TextureRect.STRETCH_SCALE)
	var icon := TextureRect.new()
	icon.position = Vector2(12, 2)
	icon.size = Vector2(58, 58)
	icon.texture = _texture_for_named_resource(str(item.icon))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)
	_add_label(button, str(item.label), Vector2(70, 13), Vector2(96, 34), 21, Color(0.92, 0.88, 0.76), HORIZONTAL_ALIGNMENT_CENTER)

func _close_buy_dialog() -> void:
	if buy_dialog:
		buy_dialog.queue_free()
		buy_dialog = null

func _add_top_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(74, 30)
	button.pressed.connect(callback)
	parent.add_child(button)

func _add_center_label(parent: Control, text: String, font_size: int, color: Color) -> Label:
	return _add_label(parent, text, Vector2.ZERO, parent.size, font_size, color, HORIZONTAL_ALIGNMENT_CENTER)

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _load_named_resources() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/named_resource_index.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		named_resources = parsed

func _load_equipment_icons() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/equipment_icon_index.json"))
	if typeof(parsed) == TYPE_ARRAY:
		equipment_icons = parsed

func _equipment_icon(index: int) -> Dictionary:
	var sprite_entries := equipment_icons.filter(func(item: Dictionary) -> bool:
		return int(item.get("type_index", 0)) == 9 and str(item.get("texture_path", "")) != ""
	)
	if sprite_entries.is_empty():
		return {}
	return sprite_entries[index % sprite_entries.size()]

func _texture_for_named_resource(resource_name: String) -> Texture2D:
	var entry: Dictionary = named_resources.get(resource_name, {})
	if entry.is_empty():
		return null
	var native_path := "res://" + str(entry.get("native_path", entry.get("texture_path", "")))
	var rect_arr: Array = entry.get("rect", [])
	if rect_arr.is_empty():
		rect_arr = entry.get("sprite_rect", [])
	var rotated := bool(entry.get("rotated", entry.get("sprite_rotated", false)))
	var original_size := _arr_to_vec2i(entry.get("original_size", entry.get("sprite_original_size", [])))
	var offset := _arr_to_vec2(entry.get("offset", entry.get("sprite_offset", [])))
	if rect_arr.size() == 4:
		return _load_texture_region(native_path, Rect2i(int(rect_arr[0]), int(rect_arr[1]), int(rect_arr[2]), int(rect_arr[3])), rotated, original_size, offset)
	return _load_texture(native_path)

func _load_indexed_texture(icon_data: Dictionary) -> Texture2D:
	var path := str(icon_data.get("texture_path", ""))
	if path == "":
		return null
	var rect_arr: Array = icon_data.get("sprite_rect", [])
	var original_size := _arr_to_vec2i(icon_data.get("sprite_original_size", []))
	var offset := _arr_to_vec2(icon_data.get("sprite_offset", []))
	if rect_arr.size() == 4:
		return _load_texture_region("res://" + path, Rect2i(int(rect_arr[0]), int(rect_arr[1]), int(rect_arr[2]), int(rect_arr[3])), bool(icon_data.get("sprite_rotated", false)), original_size, offset)
	return _load_texture("res://" + path)

func _layout_design_root() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(factor, factor)
	design_root.position = (viewport_size - DESIGN_SIZE * factor) * 0.5

func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return _make_sprite_frame_texture(image, region, rotated, original_size, offset)

func _add_sprite_frame_image(parent: Control, atlas_path: String, rect: Rect2i, position: Vector2, size: Vector2, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _load_texture_region(atlas_path, rect, rotated, original_size, offset)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _make_sprite_frame_texture(atlas: Image, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(crop):
		return ImageTexture.create_from_image(atlas)
	var frame := atlas.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x <= 0 or original_size.y <= 0:
		return ImageTexture.create_from_image(frame)
	if original_size == frame.get_size():
		return ImageTexture.create_from_image(frame)
	frame.convert(Image.FORMAT_RGBA8)
	var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
	var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
	canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
	return ImageTexture.create_from_image(canvas)

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _apply_cmdline_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var shop_arg := _cmd_arg_value(args, "--shop-type")
	if shop_arg.is_valid_int():
		selected_shop_type = int(shop_arg)
	for item in SHOP_TYPES:
		if int(item.type) == selected_shop_type:
			selected_main_type = int(item.main_type)
			break
	_refresh_main_type_tabs()
	_refresh_shop_type_tabs()
	_refresh_goods()
	var buy_arg := _cmd_arg_value(args, "--shop-open-buy")
	if buy_arg.is_valid_int():
		var index := clampi(int(buy_arg), 0, GOODS.size() - 1)
		_show_buy_dialog(GOODS[index])

func _cmd_arg_value(args: Array, key: String) -> String:
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-shop-panel" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-shop-panel")
	var output_path := "user://shop_panel.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
