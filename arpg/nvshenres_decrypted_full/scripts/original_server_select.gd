extends Control

const MAIN_CITY := "res://scenes/original_home_screen.tscn"
const LOGIN_SCENE := "res://scenes/original_login.tscn"
const PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const LAYOUT_PATH := "res://data/prefab_layouts/pfLoginPanelPre.json"
const BG_PATH := "res://converted/png/a84d3470-bde7-4589-9b33-65a957c34507.png"
const LOGIN_ATLAS_PATH := "res://assets/resources/native/1d/1d1cac610.png"
const UI_ATLAS_PATH := "res://assets/resources/native/14/1430d496a.png"
const BUTTON_ATLAS_PATH := "res://assets/resources/native/14/14d2fafcf.png"
const LOGIN_BUTTON_SHEET := "res://assets/resources/native/11/1109b405e.png"
const BOTTOM_RECT := Rect2i(206, 996, 2, 34)
const SERVER_BOX_RECT := Rect2i(987, 43, 29, 28)
const SERVER_FLOAT_BG_RECT := Rect2i(976, 893, 43, 48)
const SERVER_TAG_HOT_RECT := Rect2i(987, 3, 34, 34)
const SERVER_TAG_NEW_RECT := Rect2i(955, 987, 34, 34)
const SERVER_TAG_MAINTAIN_RECT := Rect2i(915, 987, 34, 34)
const SWITCH_ICON_RECT := Rect2i(170, 996, 30, 24)
const ICON_ACCOUNT_RECT := Rect2i(787, 893, 58, 58)
const ICON_NOTICE_RECT := Rect2i(851, 957, 58, 58)
const START_BUTTON_RECT := Rect2i(3, 3, 414, 102)
const TOGGLE_OFF_RECT := Rect2i(451, 524, 30, 30)
const ALERT_ATLAS_PATH := "res://assets/resources/native/1d/1d816a710.png"
const ALERT_FRAME_RECT := Rect2i(65, 644, 603, 369)
const DESIGN_SIZE := Vector2(1280, 720)

var design_root: Control
var layout_nodes: Dictionary = {}
var selected_server_name := "本地演示服"
var selected_server_status := "hot"
var server_label: Label
var server_popup: Control
var server_status_icon: TextureRect
var notice_overlay: Control
var connect_overlay: Control
var connect_label: Label
var connect_elapsed := 0.0
var connect_running := false

func _ready() -> void:
	_load_layout_index()
	_build_ui()
	_apply_startup_args()
	_capture_if_requested()

func _process(delta: float) -> void:
	if not connect_running:
		return
	connect_elapsed += delta
	if connect_label and connect_elapsed > 0.85:
		connect_label.text = "正在登录服务器"
	if connect_elapsed > 1.65:
		connect_running = false
		Navigation.go(MAIN_CITY)

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color.BLACK
	add_child(backdrop)

	design_root = Control.new()
	design_root.size = DESIGN_SIZE
	add_child(design_root)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture(BG_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bg)

	var bottom := TextureRect.new()
	var bottom_rect := Rect2(Vector2(-147.5, 607.0), Vector2(1575, 113))
	bottom.position = bottom_rect.position
	bottom.size = bottom_rect.size
	bottom.texture = _load_texture_region(UI_ATLAS_PATH, BOTTOM_RECT, true)
	bottom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bottom.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(bottom)

	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(920, 16)
	top_bar.size = Vector2(344, 38)
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	design_root.add_child(top_bar)
	Navigation.add_buttons(top_bar)
	var prefab := Button.new()
	prefab.text = "原始选服"
	prefab.pressed.connect(func(): Navigation.go_with_args(PREFAB_PREVIEW, {"layout": "登录选服"}))
	top_bar.add_child(prefab)

	_add_icon_button(_layout_rect("btnGG", Rect2(Vector2(1168, 103.559), Vector2(58, 58))), ICON_NOTICE_RECT, "公告", func(): _show_local_notice())
	_add_icon_button(_layout_rect("btnSwitchAcount", Rect2(Vector2(1168, 179.559), Vector2(58, 58))), ICON_ACCOUNT_RECT, "切换账号", func(): Navigation.go(LOGIN_SCENE))
	_add_icon_button(_layout_rect("btnDiscord", Rect2(Vector2(1168, 262.559), Vector2(58, 58))), ICON_NOTICE_RECT, "discord", func(): _show_local_notice())
	_add_icon_button(_layout_rect("btnFacebook", Rect2(Vector2(1168, 344.559), Vector2(58, 58))), ICON_NOTICE_RECT, "facebook", func(): _show_local_notice())

	var floating_bg_rect := _layout_rect("xuanfu_bg", Rect2(Vector2(903.073, 436.971), Vector2(247, 47)))
	var floating_bg := NinePatchRect.new()
	floating_bg.position = floating_bg_rect.position
	floating_bg.size = floating_bg_rect.size
	floating_bg.texture = _load_texture_region(UI_ATLAS_PATH, SERVER_FLOAT_BG_RECT)
	floating_bg.patch_margin_left = 15
	floating_bg.patch_margin_top = 15
	floating_bg.patch_margin_right = 13
	floating_bg.patch_margin_bottom = 17
	floating_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(floating_bg)

	var server_row := Control.new()
	var server_rect := _layout_rect("btnSelect1", Rect2(Vector2(904, 439.386), Vector2(242, 40)))
	server_row.position = server_rect.position
	server_row.size = server_rect.size
	design_root.add_child(server_row)

	var server_bg := NinePatchRect.new()
	server_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	server_bg.texture = _load_texture_region(LOGIN_ATLAS_PATH, SERVER_BOX_RECT)
	server_bg.patch_margin_left = 10
	server_bg.patch_margin_top = 10
	server_bg.patch_margin_right = 10
	server_bg.patch_margin_bottom = 10
	server_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	server_row.add_child(server_bg)

	server_label = Label.new()
	var server_label_rect := _layout_rect("txtServer", Rect2(Vector2(1001.893, 442.168), Vector2(92, 35.28)))
	server_label.position = server_label_rect.position - server_rect.position - Vector2(50, 0)
	server_label.size = Vector2(150, server_label_rect.size.y)
	server_label.text = selected_server_name
	server_label.add_theme_font_size_override("font_size", 20)
	server_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	server_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	server_row.add_child(server_label)

	server_status_icon = TextureRect.new()
	server_status_icon.position = Vector2(184, 3)
	server_status_icon.size = Vector2(34, 34)
	server_status_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	server_status_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	server_status_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	server_row.add_child(server_status_icon)
	_update_selected_server_visual()

	var switch_icon := TextureRect.new()
	switch_icon.position = Vector2(212, 8)
	switch_icon.size = Vector2(30, 24)
	switch_icon.texture = _load_texture_region(UI_ATLAS_PATH, SWITCH_ICON_RECT)
	switch_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	switch_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	switch_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	server_row.add_child(switch_icon)

	var server_hit := Button.new()
	server_hit.text = ""
	server_hit.flat = true
	server_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	server_hit.tooltip_text = "选择服务器"
	server_hit.pressed.connect(_show_server_popup)
	server_row.add_child(server_hit)

	var start_box := Control.new()
	var start_rect := _layout_rect("btn_start", Rect2(Vector2(753.176, 492.225), Vector2(550, 102)))
	start_box.position = start_rect.position
	start_box.size = start_rect.size
	design_root.add_child(start_box)

	var start_image := TextureRect.new()
	start_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_image.texture = _load_texture_region(LOGIN_BUTTON_SHEET, START_BUTTON_RECT)
	start_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	start_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	start_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_box.add_child(start_image)

	var start_hit := Button.new()
	start_hit.text = ""
	start_hit.flat = true
	start_hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_hit.tooltip_text = "进入主城"
	start_hit.pressed.connect(_on_start_game)
	start_box.add_child(start_hit)
	_add_label(start_box, "进入游戏", Vector2.ZERO, start_box.size, 24, Color(1.0, 0.96, 0.74)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var banhao_rect := _layout_rect("lblBanhao", Rect2(Vector2(408.02, 637.166), Vector2(466.67, 56.5)))
	var banhao := _add_label(design_root, "批许文号：新广出审[2017]6390号  ISBN：978-7-7979-9552-8\n著作权人：长沙骁之翼网络有限公司    出版单位：长沙骁之翼有限公司", banhao_rect.position, banhao_rect.size, 13, Color(0.86, 0.86, 0.9))
	banhao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banhao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var tip_rect := _layout_rect("lblTip", Rect2(Vector2(393.015, 687.553), Vector2(496.68, 31.5)))
	_add_label(design_root, "本网络游戏适合年满16周岁以上的用户使用：请您确认已如实进行实名注册", tip_rect.position, tip_rect.size, 13, Color(0.86, 0.86, 0.9)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var version_rect := _layout_rect("vesiontxt", Rect2(Vector2(42.638, 688.346), Vector2(174.82, 28.98)))
	_add_label(design_root, "资源版本号:v1.0.0", version_rect.position, version_rect.size, 13, Color(0.86, 0.86, 0.9)).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_add_privacy_row()
	_build_server_popup()
	_build_notice_overlay()
	_build_connect_overlay()

	_layout_design_root()

func _load_layout_index() -> void:
	if not FileAccess.file_exists(LAYOUT_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for node in parsed.get("nodes", []):
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var name := str(node.get("name", ""))
		if name != "" and not layout_nodes.has(name):
			layout_nodes[name] = node

func _layout_rect(name: String, fallback: Rect2) -> Rect2:
	if not layout_nodes.has(name):
		return fallback
	var node: Dictionary = layout_nodes[name]
	var rect: Array = node.get("screen_rect", [])
	if rect.size() >= 4:
		return Rect2(Vector2(float(rect[0]), float(rect[1])), Vector2(float(rect[2]), float(rect[3])))
	return fallback

func _add_icon_button(bounds: Rect2, rect: Rect2i, tooltip: String, callback: Callable) -> void:
	var box := Control.new()
	box.position = bounds.position
	box.size = bounds.size
	design_root.add_child(box)

	var image := TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.texture = _load_texture_region(UI_ATLAS_PATH, rect)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(image)

	var hit := Button.new()
	hit.text = ""
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = tooltip
	hit.pressed.connect(callback)
	box.add_child(hit)
	var label := _add_label(design_root, tooltip, bounds.position + Vector2(-12, 60), Vector2(82, 26), 15, Color(0.92, 0.94, 1.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_privacy_row() -> void:
	var rich_rect := _layout_rect("richtext", Rect2(Vector2(832.036, 578.608), Vector2(440, 27.72)))
	var toggle_rect := Rect2(rich_rect.position - Vector2(34, 1), Vector2(30, 30))
	var toggle := TextureRect.new()
	toggle.position = toggle_rect.position
	toggle.size = toggle_rect.size
	toggle.texture = _load_texture_region(UI_ATLAS_PATH, TOGGLE_OFF_RECT)
	toggle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	toggle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	toggle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(toggle)
	var privacy := RichTextLabel.new()
	privacy.position = rich_rect.position
	privacy.size = rich_rect.size + Vector2(10, 8)
	privacy.bbcode_enabled = true
	privacy.fit_content = true
	privacy.scroll_active = false
	privacy.text = "[color=#e5e8ff]我已阅读并同意[/color][color=#8fd7ff]《用户协议》[/color][color=#e5e8ff]和[/color][color=#8fd7ff]《隐私政策》[/color]"
	privacy.add_theme_font_size_override("normal_font_size", 15)
	privacy.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	privacy.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	privacy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	design_root.add_child(privacy)

func _build_server_popup() -> void:
	server_popup = Control.new()
	server_popup.visible = false
	server_popup.position = Vector2.ZERO
	server_popup.size = DESIGN_SIZE
	server_popup.z_index = 50
	design_root.add_child(server_popup)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.45)
	server_popup.add_child(dim)

	var close_area := Button.new()
	close_area.text = ""
	close_area.flat = true
	close_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	close_area.pressed.connect(_hide_server_popup)
	server_popup.add_child(close_area)

	var panel_rect := _layout_rect("svBg", Rect2(Vector2(97.5, 171.0), Vector2(953.0, 512.0)))
	var panel := PanelContainer.new()
	panel.position = panel_rect.position
	panel.size = panel_rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.94)
	style.border_color = Color(0.78, 0.69, 0.48, 1.0)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	server_popup.add_child(panel)

	_add_label(server_popup, "选择服务器", Vector2(panel_rect.position.x + 390, panel_rect.position.y + 14), Vector2(180, 36), 24, Color(1.0, 0.91, 0.65)).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var tab_rect := _layout_rect("scrollTab", Rect2(Vector2(98.598, 201.0), Vector2(180.0, 470.0)))
	var tab_box := VBoxContainer.new()
	tab_box.position = tab_rect.position + Vector2(12, 58)
	tab_box.size = Vector2(tab_rect.size.x - 24, tab_rect.size.y - 80)
	tab_box.add_theme_constant_override("separation", 12)
	server_popup.add_child(tab_box)
	for label in ["最近登录", "推荐", "全部服务器"]:
		var tab := Button.new()
		tab.text = label
		tab.custom_minimum_size = Vector2(tab_box.size.x, 48)
		tab_box.add_child(tab)

	var list_rect := _layout_rect("scrollserver", Rect2(Vector2(283.866, 201.0), Vector2(742.0, 401.0)))
	var list := GridContainer.new()
	list.columns = 2
	list.position = list_rect.position + Vector2(20, 56)
	list.size = list_rect.size - Vector2(40, 78)
	list.add_theme_constant_override("h_separation", 18)
	list.add_theme_constant_override("v_separation", 14)
	server_popup.add_child(list)

	var servers := [
		{"name": "本地演示服", "id": "S148", "status": "hot"},
		{"name": "曙光新服", "id": "S149", "status": "new"},
		{"name": "稳定测试服", "id": "S147", "status": "hot"},
		{"name": "维护演示服", "id": "S146", "status": "maintain"},
		{"name": "离线预览服", "id": "S145", "status": "hot"},
		{"name": "资源检查服", "id": "S144", "status": "new"},
	]
	for server in servers:
		_add_server_list_item(list, str(server.id), str(server.name), str(server.status))

	var tip := _add_label(server_popup, "本地 Demo 不连接服务器，选择项只用于界面展示。", Vector2(panel_rect.position.x + 285, panel_rect.position.y + 454), Vector2(420, 26), 15, Color(0.78, 0.8, 0.9))
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var close := Button.new()
	close.text = "关闭"
	close.position = Vector2(panel_rect.position.x + panel_rect.size.x - 118, panel_rect.position.y + 18)
	close.size = Vector2(82, 34)
	close.pressed.connect(_hide_server_popup)
	server_popup.add_child(close)

func _build_notice_overlay() -> void:
	notice_overlay = Control.new()
	notice_overlay.visible = false
	notice_overlay.position = Vector2.ZERO
	notice_overlay.size = DESIGN_SIZE
	notice_overlay.z_index = 60
	design_root.add_child(notice_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	notice_overlay.add_child(dim)

	var close_area := Button.new()
	close_area.text = ""
	close_area.flat = true
	close_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	close_area.pressed.connect(_hide_local_notice)
	notice_overlay.add_child(close_area)

	var panel_rect := Rect2(Vector2(224.0, 33.968), Vector2(832.0, 603.0))
	var panel := PanelContainer.new()
	panel.position = panel_rect.position
	panel.size = panel_rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.91, 0.88, 0.78, 0.98)
	style.border_color = Color(0.46, 0.37, 0.23, 1.0)
	style.set_border_width_all(3)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)
	notice_overlay.add_child(panel)

	var title_rect := Rect2(Vector2(609.964, 70.934), Vector2(72.0, 45.36))
	var title := _add_label(notice_overlay, "公告", title_rect.position - Vector2(34, 0), title_rect.size + Vector2(68, 0), 28, Color(0.33, 0.26, 0.16))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var scroll_rect := Rect2(Vector2(264.494, 170.473), Vector2(750.0, 400.0))
	var scroll := ScrollContainer.new()
	scroll.position = scroll_rect.position
	scroll.size = scroll_rect.size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	notice_overlay.add_child(scroll)

	var body := RichTextLabel.new()
	body.custom_minimum_size = Vector2(scroll_rect.size.x - 28, 760)
	body.bbcode_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.add_theme_font_size_override("normal_font_size", 22)
	body.add_theme_color_override("default_color", Color(0.25, 0.23, 0.2))
	body.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	body.text = "[center][b]本地资源还原公告[/b][/center]\n\n欢迎进入 Maiden Academy 本地 Demo。\n\n当前版本用于离线检查已解密资源、界面布局、Spine 动画和主流程跳转，不会连接真实服务器。\n\n已还原流程：启动加载、登录调试页、平台选服页、连接服务器提示、主城、英雄列表、英雄详情、召唤、仓库和商会。\n\n后续会继续按原始 prefab 和源码入口补齐公告、隐私协议、活动页、系统入口和英雄详情子功能。"
	scroll.add_child(body)

	var close_tip_rect := Rect2(Vector2(556.879, 652.596), Vector2(154.0, 27.72))
	var close_tip := _add_label(notice_overlay, "点击空白处关闭", close_tip_rect.position, close_tip_rect.size, 18, Color(0.86, 0.82, 0.68))
	close_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_connect_overlay() -> void:
	connect_overlay = Control.new()
	connect_overlay.visible = false
	connect_overlay.position = Vector2.ZERO
	connect_overlay.size = DESIGN_SIZE
	connect_overlay.z_index = 80
	design_root.add_child(connect_overlay)

	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture("res://assets/resources/native/75/750b6077-9d0c-4446-9e4c-3c3ae2fb6ee5.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	connect_overlay.add_child(bg)

	var alert_rect := Rect2(Vector2(338.5, 175.5), Vector2(603.0, 369.0))
	var alert_frame := TextureRect.new()
	alert_frame.position = alert_rect.position
	alert_frame.size = alert_rect.size
	alert_frame.texture = _load_texture_region(ALERT_ATLAS_PATH, ALERT_FRAME_RECT)
	alert_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	alert_frame.stretch_mode = TextureRect.STRETCH_SCALE
	alert_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	connect_overlay.add_child(alert_frame)

	var spinner := Control.new()
	var spinner_rect := Rect2(Vector2(581.265, 257.51), Vector2(117.47, 204.98))
	spinner.position = spinner_rect.position
	spinner.size = spinner_rect.size
	connect_overlay.add_child(spinner)

	var ring := ColorRect.new()
	ring.position = Vector2(28, 70)
	ring.size = Vector2(62, 62)
	ring.color = Color(0.98, 0.86, 0.44, 0.35)
	spinner.add_child(ring)
	var dot := ColorRect.new()
	dot.position = Vector2(55, 16)
	dot.size = Vector2(12, 12)
	dot.color = Color(1.0, 0.95, 0.58, 1.0)
	spinner.add_child(dot)

	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(spinner, "rotation", TAU, 1.2).from(0.0)

	var label_rect := Rect2(Vector2(552.5, 494.144), Vector2(175.0, 31.5))
	connect_label = _add_label(connect_overlay, "正在连接服务器", label_rect.position - Vector2(34, 0), label_rect.size + Vector2(68, 0), 24, Color(0.98, 0.92, 0.74))
	connect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_server_list_item(parent: Control, server_id: String, server_name: String, status: String) -> void:
	var row := Button.new()
	row.text = ""
	row.custom_minimum_size = Vector2(334, 54)
	row.pressed.connect(func(): _select_server(server_name, status))
	parent.add_child(row)

	var bg := NinePatchRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture = _load_texture_region(LOGIN_ATLAS_PATH, SERVER_BOX_RECT)
	bg.patch_margin_left = 10
	bg.patch_margin_top = 10
	bg.patch_margin_right = 10
	bg.patch_margin_bottom = 10
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bg)

	var id_label := _add_label(row, server_id, Vector2(16, 7), Vector2(76, 40), 18, Color(0.88, 0.9, 1.0))
	id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var name_label := _add_label(row, server_name, Vector2(96, 7), Vector2(150, 40), 18, Color(1.0, 0.96, 0.78))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var tag := TextureRect.new()
	tag.position = Vector2(282, 10)
	tag.size = Vector2(34, 34)
	tag.texture = _server_tag_texture(status)
	tag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tag.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(tag)

func _show_server_popup() -> void:
	if server_popup:
		server_popup.visible = true

func _hide_server_popup() -> void:
	if server_popup:
		server_popup.visible = false

func _select_server(name: String, status: String) -> void:
	selected_server_name = name
	selected_server_status = status
	_update_selected_server_visual()
	_hide_server_popup()

func _update_selected_server_visual() -> void:
	if server_label:
		server_label.text = selected_server_name
	if server_status_icon:
		server_status_icon.texture = _server_tag_texture(selected_server_status)

func _server_tag_texture(status: String) -> Texture2D:
	match status:
		"new":
			return _load_texture_region(UI_ATLAS_PATH, SERVER_TAG_NEW_RECT)
		"maintain":
			return _load_texture_region(UI_ATLAS_PATH, SERVER_TAG_MAINTAIN_RECT)
		_:
			return _load_texture_region(LOGIN_ATLAS_PATH, SERVER_TAG_HOT_RECT)

func _apply_startup_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if "--open-server-list" in args:
		_show_server_popup()
	if "--open-notice" in args:
		_show_local_notice()
	if "--connect-overlay" in args or "--start-game" in args:
		_show_connect_overlay()

func _show_local_notice() -> void:
	if server_popup:
		server_popup.visible = false
	if notice_overlay:
		notice_overlay.visible = true

func _hide_local_notice() -> void:
	if notice_overlay:
		notice_overlay.visible = false

func _on_start_game() -> void:
	if selected_server_status == "maintain":
		var dialog := AcceptDialog.new()
		dialog.title = "提示"
		dialog.dialog_text = "服务器正在维护"
		add_child(dialog)
		dialog.popup_centered()
		return
	_show_connect_overlay()

func _show_connect_overlay() -> void:
	if server_popup:
		server_popup.visible = false
	if notice_overlay:
		notice_overlay.visible = false
	if connect_overlay:
		connect_overlay.visible = true
	if connect_label:
		connect_label.text = "正在连接服务器"
	connect_elapsed = 0.0
	connect_running = true

func _add_label(parent: Control, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_texture_region(path: String, region: Rect2i, rotated: bool = false) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x > 0 and crop.size.y > 0 and Rect2i(Vector2i.ZERO, image.get_size()).encloses(crop):
		image = image.get_region(crop)
		if rotated:
			image.rotate_90(COUNTERCLOCKWISE)
	return ImageTexture.create_from_image(image)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and design_root:
		_layout_design_root()

func _layout_design_root() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var scale_value: float = min(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	design_root.scale = Vector2(scale_value, scale_value)
	design_root.position = (viewport_size - DESIGN_SIZE * scale_value) * 0.5

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-server-select" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-server-select")
	var output_path := "user://server_select.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		get_tree().quit()
		return
	var image := viewport_texture.get_image()
	if image == null:
		get_tree().quit()
		return
	image.save_png(output_path)
	get_tree().quit()
