extends Control

const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const LOGIN_DEMO := "res://scenes/login_demo.tscn"
const COCOS_PREFAB_PREVIEW := "res://scenes/cocos_prefab_preview.tscn"
const CATALOG_PATH := "res://data/catalog.json"

const BG_MAIN := "res://assets/resources/native/f5/f58085bc-21e6-40ed-a4cf-b55f6b0cc8f9.png"
const LOGIN_BG := "res://assets/resources/native/24/247375b4-3477-4384-8f97-172c5b1476e7.jpg"

const HERO_IMAGES := [
	"res://assets/resources/native/24/247375b4-3477-4384-8f97-172c5b1476e7.jpg",
	"res://assets/resources/native/28/2838fdf0-43ac-4a2f-af2a-aedbab39b9a1.jpg",
	"res://assets/resources/native/46/46b92da5-280c-4fe9-8ea6-48af57f97b56.jpg",
	"res://assets/resources/native/a8/a84d3470-bde7-4589-9b33-65a957c34507.jpg",
]

const ICONS := [
	"res://assets/resources/native/1e/1e2ee7b1-085b-43c3-aae7-824347743853.png",
	"res://assets/resources/native/28/28842728-99ef-48c8-9831-27040e50969b.png",
	"res://assets/resources/native/2d/2d4c634d-c23d-485d-8b0d-112bc6a1c7d.png",
	"res://assets/resources/native/38/388d049f-2869-44b2-8fce-266280ee3b5a.png",
	"res://assets/resources/native/87/87a1dce7-5b3e-43b3-aff1-6d181ae86031.png",
	"res://assets/resources/native/93/93e457e9-3554-4660-801b-b9c1613abdc8.png",
]

var content: Control
var title: Label
var catalog: Dictionary = {}
var prefab_groups: Array[Dictionary] = []

func _ready() -> void:
	_load_catalog()
	_build_shell()
	_show_home()

func _build_shell() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture = _load_texture(BG_MAIN)
	add_child(bg)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.02, 0.035, 0.46)
	add_child(shade)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 18
	root.offset_top = 14
	root.offset_right = -18
	root.offset_bottom = -14
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)

	title = Label.new()
	title.text = "女神降临 本地 Demo"
	title.add_theme_font_size_override("font_size", 26)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)

	for item in [["主城", "_show_home"], ["原始主城", "_open_cocos_prefab_preview"], ["总览", "_show_modules"], ["英雄", "_show_heroes"], ["背包", "_show_bag"], ["抽卡", "_show_draw"], ["战斗", "_show_battle"], ["资源", "_open_resource_browser"], ["返回登录", "_open_login"]]:
		var btn := Button.new()
		btn.text = item[0]
		btn.pressed.connect(Callable(self, item[1]))
		top.add_child(btn)

	content = Control.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(content)

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()

func _show_home() -> void:
	title.text = "主城"
	_clear_content()
	var layout := HBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 16)
	content.add_child(layout)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(320, 0)
	layout.add_child(left)
	_add_stat_card(left, "玩家", "local_demo")
	_add_stat_card(left, "等级", "88")
	_add_stat_card(left, "战力", "1,284,560")
	_add_stat_card(left, "模式", "离线资源展示")

	var center := GridContainer.new()
	center.columns = 3
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(center)
	for item in [["原始主城预览", "_open_cocos_prefab_preview"], ["模块总览", "_show_modules"], ["英雄", "_show_heroes"], ["背包", "_show_bag"], ["抽卡", "_show_draw"], ["活动", "_show_activity"], ["战斗", "_show_battle"], ["资源浏览", "_open_resource_browser"]]:
		var b := Button.new()
		b.text = item[0]
		b.custom_minimum_size = Vector2(180, 96)
		b.pressed.connect(Callable(self, item[1]))
		center.add_child(b)

	var right := TextureRect.new()
	right.custom_minimum_size = Vector2(360, 0)
	right.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	right.texture = _load_texture(HERO_IMAGES[0])
	layout.add_child(right)

func _show_modules() -> void:
	title.text = "模块总览"
	_clear_content()
	var layout := HBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 14)
	content.add_child(layout)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(340, 0)
	layout.add_child(left)
	var stats: Dictionary = catalog.get("stats", {})
	_add_stat_card(left, "Prefab 总数", str(stats.get("prefabs", 0)))
	_add_stat_card(left, "Scene", str(stats.get("scenes", 0)))
	_add_stat_card(left, "Spine", str(stats.get("spine", 0)))
	_add_stat_card(left, "资源文件", str(stats.get("files", 0)))
	var open := Button.new()
	open.text = "打开资源浏览器 / Prefab 对照"
	open.custom_minimum_size = Vector2(280, 58)
	open.pressed.connect(_open_resource_browser)
	left.add_child(open)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	for group in prefab_groups:
		var panel := _make_panel_card(str(group.get("name", "")))
		panel.custom_minimum_size = Vector2(250, 128)
		var box := VBoxContainer.new()
		panel.add_child(box)
		var label := Label.new()
		label.text = "%s\nPrefab: %d" % [group.get("name", ""), group.get("count", 0)]
		label.add_theme_font_size_override("font_size", 18)
		box.add_child(label)
		var sample := Label.new()
		sample.text = "\n".join(group.get("examples", []))
		sample.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(sample)
		grid.add_child(panel)

func _show_heroes() -> void:
	title.text = "英雄"
	_clear_content()
	var grid := GridContainer.new()
	grid.columns = 4
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	content.add_child(grid)
	for i in range(12):
		var card := _make_panel_card("Hero %02d" % [i + 1])
		card.custom_minimum_size = Vector2(220, 160)
		var box := VBoxContainer.new()
		card.add_child(box)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(110, 86)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _load_texture(HERO_IMAGES[i % HERO_IMAGES.size()])
		box.add_child(icon)
		var info := Label.new()
		info.text = "SSR  Lv.%d\n战力 %d" % [80 + i, 42000 + i * 2350]
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(info)
		grid.add_child(card)

func _show_bag() -> void:
	title.text = "背包"
	_clear_content()
	var grid := GridContainer.new()
	grid.columns = 8
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	content.add_child(grid)
	for i in range(48):
		var slot := _make_panel_card("")
		slot.custom_minimum_size = Vector2(104, 104)
		var box := VBoxContainer.new()
		slot.add_child(box)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(72, 58)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _load_texture(ICONS[i % ICONS.size()])
		box.add_child(icon)
		var label := Label.new()
		label.text = "x%d" % [i * 3 + 1]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(label)
		grid.add_child(slot)

func _show_draw() -> void:
	title.text = "召唤"
	_clear_content()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	content.add_child(box)
	var banner := TextureRect.new()
	banner.custom_minimum_size = Vector2(760, 330)
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	banner.texture = _load_texture(LOGIN_BG)
	box.add_child(banner)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	for text in ["召唤 1 次", "召唤 10 次", "预览奖励"]:
		var b := Button.new()
		b.text = text
		b.custom_minimum_size = Vector2(180, 58)
		b.pressed.connect(func(): _toast("离线演示：未连接服务器"))
		buttons.add_child(b)

func _show_battle() -> void:
	title.text = "战斗预览"
	_clear_content()
	var arena := Control.new()
	arena.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_child(arena)
	for i in range(5):
		_add_unit(arena, Vector2(150, 120 + i * 92), "我方 %d" % [i + 1], HERO_IMAGES[i % HERO_IMAGES.size()])
		_add_unit(arena, Vector2(820, 120 + i * 92), "敌方 %d" % [i + 1], HERO_IMAGES[(i + 2) % HERO_IMAGES.size()])
	var start := Button.new()
	start.text = "播放本地战斗演示"
	start.custom_minimum_size = Vector2(260, 58)
	start.anchor_left = 0.5
	start.anchor_top = 1.0
	start.anchor_right = 0.5
	start.anchor_bottom = 1.0
	start.offset_left = -130
	start.offset_top = -80
	start.offset_right = 130
	start.offset_bottom = -22
	start.pressed.connect(func(): _toast("离线演示：仅展示阵容和资源"))
	arena.add_child(start)

func _show_activity() -> void:
	title.text = "活动"
	_clear_content()
	var list := VBoxContainer.new()
	list.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_child(list)
	for item in ["七日登录", "限时召唤", "节日礼包", "竞技排行", "资源预览"]:
		_add_stat_card(list, item, "离线展示内容")

func _add_unit(parent: Control, pos: Vector2, name: String, path: String) -> void:
	var card := _make_panel_card(name)
	card.position = pos
	card.size = Vector2(260, 74)
	parent.add_child(card)
	var icon := TextureRect.new()
	icon.position = Vector2(8, 8)
	icon.size = Vector2(58, 58)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _load_texture(path)
	card.add_child(icon)
	var label := Label.new()
	label.position = Vector2(78, 16)
	label.text = "%s\nHP 100%%" % name
	card.add_child(label)

func _add_stat_card(parent: Control, key: String, value: String) -> void:
	var panel := _make_panel_card(key)
	panel.custom_minimum_size = Vector2(260, 74)
	var label := Label.new()
	label.text = "%s\n%s" % [key, value]
	label.position = Vector2(14, 10)
	panel.add_child(label)
	parent.add_child(panel)

func _make_panel_card(label: String) -> PanelContainer:
	var panel := PanelContainer.new()
	if label != "":
		panel.tooltip_text = label
	return panel

func _toast(text: String) -> void:
	title.text = text

func _open_resource_browser() -> void:
	get_tree().change_scene_to_file(RESOURCE_BROWSER)

func _open_login() -> void:
	get_tree().change_scene_to_file(LOGIN_DEMO)

func _open_cocos_prefab_preview() -> void:
	get_tree().change_scene_to_file(COCOS_PREFAB_PREVIEW)

func _load_catalog() -> void:
	var text := FileAccess.get_file_as_string(CATALOG_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	catalog = parsed
	var groups := {}
	for prefab in catalog.get("prefabs", []):
		var path: String = str(prefab.get("path", ""))
		var parts := path.split("/")
		var group_name := "unknown"
		if parts.size() >= 2 and parts[0] == "Prefab":
			group_name = parts[1]
		if not groups.has(group_name):
			groups[group_name] = {"name": group_name, "count": 0, "examples": []}
		groups[group_name]["count"] += 1
		if groups[group_name]["examples"].size() < 3:
			groups[group_name]["examples"].append(path)
	prefab_groups.clear()
	for key in groups.keys():
		prefab_groups.append(groups[key])
	prefab_groups.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["count"]) > int(b["count"]))

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)
