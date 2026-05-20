extends Control

const MAIN_DEMO := "res://scenes/main_demo.tscn"
const RESOURCE_BROWSER := "res://scenes/resource_browser.tscn"
const TEXTURE_MAP_PATH := "res://data/login_texture_map.json"
const LAYOUT_MANIFEST_PATH := "res://data/prefab_layouts.json"
const BAG_ITEM_LAYOUT_PATH := "res://data/prefab_layouts/GridBoxItemPre.json"
const EQUIPMENT_ICON_INDEX_PATH := "res://data/equipment_icon_index.json"
const NAMED_RESOURCE_INDEX_PATH := "res://data/named_resource_index.json"
const PREFAB_NODE_HINTS_PATH := "res://data/prefab_node_name_hints.json"
const HERO_105004_SPINE := "res://data/spine_runtime/105004.json"
const SimpleSpinePlayerScript := preload("res://scripts/simple_spine_player.gd")

var root_container: VBoxContainer
var top_bar: HBoxContainer
var canvas: Control
var detail: Label
var layout_buttons: HFlowContainer
var title: Label
var current_layout := "登录选服"
var texture_map: Dictionary = {}
var layouts: Dictionary = {}
var layout_stats: Dictionary = {}
var equipment_icons: Array = []
var named_resources: Dictionary = {}
var prefab_node_hints: Dictionary = {}
var prefab_mask_clips: Dictionary = {}
var prefab_nodes_by_index: Dictionary = {}
var prefab_mask_parent_by_node: Dictionary = {}
var prefab_inferred_mask_by_node: Dictionary = {}

func _ready() -> void:
	_load_texture_map()
	_load_layout_manifest()
	_load_equipment_icons()
	_load_named_resources()
	_load_prefab_node_hints()
	_build_ui()
	var requested_layout := _requested_layout()
	if requested_layout != "":
		current_layout = requested_layout
	_load_layout(current_layout)
	_capture_if_requested()

func _build_ui() -> void:
	root_container = VBoxContainer.new()
	root_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_container.offset_left = 12
	root_container.offset_top = 10
	root_container.offset_right = -12
	root_container.offset_bottom = -10
	add_child(root_container)

	top_bar = HBoxContainer.new()
	root_container.add_child(top_bar)

	title = Label.new()
	title.text = "原始 Cocos Prefab 预览"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title)

	Navigation.add_buttons(top_bar)

	var enter := Button.new()
	enter.text = "进入本地 Demo"
	enter.pressed.connect(func(): Navigation.go(MAIN_DEMO))
	top_bar.add_child(enter)

	var resources := Button.new()
	resources.text = "资源浏览"
	resources.pressed.connect(func(): Navigation.go(RESOURCE_BROWSER))
	top_bar.add_child(resources)

	var back := Button.new()
	back.text = "手工 Demo"
	back.pressed.connect(func(): Navigation.go(MAIN_DEMO))
	top_bar.add_child(back)

	layout_buttons = HFlowContainer.new()
	root_container.add_child(layout_buttons)

	for layout_name in layouts.keys():
		var btn := Button.new()
		btn.text = layout_name
		btn.pressed.connect(_load_layout.bind(layout_name))
		layout_buttons.add_child(btn)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_container.add_child(body)

	canvas = Control.new()
	canvas.custom_minimum_size = Vector2(880, 620)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.clip_contents = true
	body.add_child(canvas)

	detail = Label.new()
	detail.custom_minimum_size = Vector2(320, 0)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(detail)

func _load_layout(layout_name: String) -> void:
	if not layouts.has(layout_name):
		if title:
			title.text = "原始 Cocos Prefab 预览 - 缺少布局：%s" % layout_name
		if detail:
			detail.text = "未在 data/prefab_layouts.json 中找到该布局。请先把对应 prefab 加入 tools/export_cocos_prefab_layout.py 的 PREFABS 列表并重新导出。"
		return
	current_layout = layout_name
	for child in canvas.get_children():
		child.queue_free()
	var layout_path: String = layouts.get(layout_name, "")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var nodes: Array = parsed.get("nodes", [])
	var stats: Dictionary = layout_stats.get(layout_name, {})
	title.text = "原始 Cocos Prefab 预览 - %s" % layout_name
	detail.text = _layout_detail_text(parsed, nodes, stats)
	_apply_prefab_preview_mode()
	_index_prefab_nodes(nodes)
	_build_prefab_mask_clips(nodes)
	_build_inferred_scrollview_masks(nodes)
	_build_prefab_mask_parent_map(nodes)
	for node in _sorted_nodes(nodes):
		_add_node_rect(node)
	_add_layout_mock()

func _apply_prefab_preview_mode() -> void:
	var clean := _is_clean_prefab_preview_layout()
	top_bar.visible = not clean
	detail.visible = not clean
	layout_buttons.visible = not clean
	if clean:
		root_container.offset_left = 0
		root_container.offset_top = 0
		root_container.offset_right = 0
		root_container.offset_bottom = 0
		canvas.custom_minimum_size = Vector2(1280, 720)
		canvas.size = get_viewport_rect().size
	else:
		root_container.offset_left = 12
		root_container.offset_top = 10
		root_container.offset_right = -12
		root_container.offset_bottom = -10
		canvas.custom_minimum_size = Vector2(880, 620)
		canvas.size = Vector2.ZERO

func _add_node_rect(node: Dictionary) -> void:
	if _should_skip_node(node):
		return
	var size_arr: Array = node.get("size", [80, 36])
	var pos_arr: Array = node.get("global_position", node.get("position", [0, 0]))
	var anchor_arr: Array = node.get("anchor", [0.5, 0.5])
	var size := Vector2(float(size_arr[0]), float(size_arr[1]))
	var rect_bounds := _prefab_node_rect(node)
	var name := str(node.get("name", ""))
	var label_text := _node_label_text(node)
	var rect: Control
	var manual_texture_path := _texture_for_node(name) if _is_login_layout() else ""
	var texture_path := manual_texture_path
	if texture_path == "":
		texture_path = str(node.get("texture_path", ""))
	if _is_clean_prefab_preview_layout() and texture_path == "" and label_text == "":
		return
	if texture_path != "":
		var tex := _load_node_texture("res://" + texture_path, node, manual_texture_path == "")
		if _is_sliced_sprite(node):
			var nine := NinePatchRect.new()
			nine.texture = tex
			_apply_nine_patch_margins(nine, node)
			nine.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = nine
		else:
			var img := TextureRect.new()
			img.texture = tex
			img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img.stretch_mode = _texture_stretch_mode(node)
			img.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = img
	else:
		if _node_label_text(node) != "":
			var text_rect := Control.new()
			text_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = text_rect
		else:
			var panel := PanelContainer.new()
			panel.modulate = _color_for_name(name)
			panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect = panel
	var target_parent := _prefab_parent_for_node(node)
	var parent_origin := Vector2.ZERO
	if target_parent != canvas:
		parent_origin = target_parent.position
	rect.position = rect_bounds.position - parent_origin
	if _is_clean_prefab_preview_layout():
		rect.size = Vector2(max(size.x, 1.0), max(size.y, 1.0))
	else:
		rect.size = Vector2(max(size.x, 48.0), max(size.y, 28.0))
	rect.scale = _node_scale(node)
	rect.tooltip_text = JSON.stringify(node, "\t")
	target_parent.add_child(rect)

	if _is_action_node(name):
		var hit := Button.new()
		hit.text = ""
		hit.flat = true
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hit.tooltip_text = "进入主城"
		hit.pressed.connect(_load_layout.bind("主城"))
		rect.add_child(hit)

	if label_text != "":
		_add_text_label(rect, node, label_text)
	elif not _is_clean_prefab_preview_layout() and (texture_path == "" or not _is_login_layout()):
		var label := Label.new()
		label.text = name
		label.clip_text = true
		label.position = Vector2(4, 3)
		rect.add_child(label)

func _add_layout_mock() -> void:
	if current_layout == "英雄":
		_add_hero_panel_mock()
	elif current_layout == "背包":
		_add_bag_panel_mock()
	elif current_layout == "抽卡":
		_add_draw_card_mock()
	elif current_layout == "公会":
		_add_guild_mock()
	elif current_layout == "天空城":
		_add_sky_city_mock()
	elif current_layout == "竞技":
		_add_jingji_mock()
	elif current_layout == "战斗":
		_add_battle_mock()
	elif current_layout == "活动抽卡":
		_add_draw_card_activity_mock()
	elif current_layout == "活动抽卡-登录领取":
		_add_draw_activity_login_reward_runtime_mock()
	elif current_layout == "活动抽卡-循环礼包":
		_add_draw_activity_cycle_runtime_mock()
	elif current_layout == "活动抽卡-抽数任务":
		_add_draw_activity_task_runtime_mock()
	elif current_layout == "活动抽卡-许愿礼包":
		_add_draw_activity_wish_gift_runtime_mock()

func _add_hero_panel_mock() -> void:
	var player: Node2D = SimpleSpinePlayerScript.new()
	player.z_index = 30
	canvas.add_child(player)
	if not player.load_spine(HERO_105004_SPINE, "idle"):
		return
	player.update_preview_pose(0.0)
	var bounds: Rect2 = player.get_draw_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var target: Rect2 = Rect2(_canvas_center() + Vector2(-430, -205), Vector2(270, 470))
	var scale_value: float = min(target.size.x / bounds.size.x, target.size.y / bounds.size.y)
	player.scale = Vector2(scale_value, scale_value)
	var bounds_center: Vector2 = bounds.position + bounds.size * 0.5
	var target_center: Vector2 = target.position + target.size * 0.5
	player.position = target_center - bounds_center * scale_value
	_add_hero_roster_mock()
	_add_hero_detail_mock()
	_add_hero_skill_mock()
	_add_hero_equipment_mock()

func _add_hero_roster_mock() -> void:
	var center := _canvas_center()
	var ids := ["105004", "205008", "305006", "405007", "505004", "204001"]
	for i in ids.size():
		var pos := center + Vector2(-430, -214 + i * 78)
		_add_hero_grid_item(pos, ids[i], i == 0)

func _add_hero_grid_item(position: Vector2, hero_id: String, selected: bool) -> void:
	var button := Button.new()
	button.position = position
	button.size = Vector2(72, 72)
	button.z_index = 70
	button.text = ""
	button.tooltip_text = hero_id
	canvas.add_child(button)
	_add_named_image_to(button, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(0, 0), Vector2(72, 72), TextureRect.STRETCH_SCALE)
	_add_named_image_to(button, "image/head/%s" % hero_id, Vector2(8, 8), Vector2(56, 56), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_named_image_to(button, "image/comHeroGrid/cm_tag_SSR1", Vector2(0, 0), Vector2(34, 22), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	if selected:
		var border := ColorRect.new()
		border.position = Vector2(0, 0)
		border.size = Vector2(72, 72)
		border.color = Color(1.0, 0.86, 0.18, 0.25)
		button.add_child(border)

func _add_hero_detail_mock() -> void:
	var center := _canvas_center()
	var panel := PanelContainer.new()
	panel.position = center + Vector2(164, -228)
	panel.size = Vector2(286, 246)
	panel.z_index = 70
	panel.modulate = Color(0.08, 0.08, 0.13, 0.62)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "伊卡洛斯  Lv.120"
	title_label.position = Vector2(18, 14)
	title_label.size = Vector2(244, 32)
	title_label.add_theme_font_size_override("font_size", 23)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.5))
	panel.add_child(title_label)
	var attrs := [
		["战力", "3027113"],
		["攻击", "120360"],
		["生命", "568420"],
		["防御", "42310"],
		["速度", "1785"],
	]
	for i in attrs.size():
		var label := Label.new()
		label.text = "%s  %s" % [attrs[i][0], attrs[i][1]]
		label.position = Vector2(24, 56 + i * 32)
		label.size = Vector2(220, 28)
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0))
		panel.add_child(label)
	var button := Button.new()
	button.text = "升2级"
	button.position = Vector2(42, 204)
	button.size = Vector2(202, 34)
	panel.add_child(button)

func _add_hero_skill_mock() -> void:
	var center := _canvas_center()
	var skills := ["10511", "10521", "10531", "10541"]
	for i in skills.size():
		var pos := center + Vector2(168, 54 + i * 64)
		var slot := PanelContainer.new()
		slot.position = pos
		slot.size = Vector2(236, 54)
		slot.z_index = 70
		slot.modulate = Color(0.08, 0.08, 0.12, 0.62)
		canvas.add_child(slot)
		_add_named_image_to(slot, "image/en/HeroPanel/yx_frame_JiNeng", Vector2(8, 5), Vector2(44, 44), TextureRect.STRETCH_SCALE)
		_add_named_image_to(slot, "image/skill/%s" % skills[i], Vector2(10, 7), Vector2(40, 40), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		var label := Label.new()
		label.text = ["普攻", "必杀", "被动", "觉醒"][i] + "  Lv.%d" % (i + 1)
		label.position = Vector2(60, 9)
		label.size = Vector2(160, 32)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
		slot.add_child(label)

func _add_hero_equipment_mock() -> void:
	var center := _canvas_center()
	var equips := ["yx_icon_zhuangbei0", "yx_icon_zhuangbei1", "yx_icon_zhuangbei2", "yx_icon_zhuangbei3", "yx_icon_zhuangbei4", "yx_icon_zhuangbei5"]
	for i in equips.size():
		var pos := center + Vector2(-238 + (i % 3) * 68, 196 + int(i / 3) * 62)
		var slot := PanelContainer.new()
		slot.position = pos
		slot.size = Vector2(58, 58)
		slot.z_index = 70
		slot.modulate = Color(0.08, 0.08, 0.13, 0.68)
		canvas.add_child(slot)
		_add_named_image_to(slot, "image/en/HeroPanel/yx_frame_ZBCheng", Vector2(0, 0), Vector2(58, 58), TextureRect.STRETCH_SCALE)
		_add_named_image_to(slot, "image/en/HeroPanel/%s" % equips[i], Vector2(9, 9), Vector2(40, 40), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

func _add_bag_panel_mock() -> void:
	var names := ["神铸核心", "星辉宝箱", "召唤券", "经验药剂", "升星石", "秘银"]
	var start := _canvas_center() + Vector2(-395, -136)
	for i in 8:
		var icon_data := _equipment_icon(i)
		_add_bag_item_row(start + Vector2(0, i * 64), icon_data, names[i % names.size()], (i + 1) * 5, i == 0)
	_add_bag_tabs_mock()
	_add_bag_detail_mock()
	_add_bag_actions_mock()

func _add_bag_item_row(origin: Vector2, icon_data: Dictionary, item_name: String, item_count: int, checked: bool) -> void:
	var row := Control.new()
	row.position = origin
	row.size = Vector2(251, 58)
	row.z_index = 90
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(row)

	var bg := PanelContainer.new()
	bg.size = row.size
	bg.modulate = Color(0.11, 0.09, 0.13, 0.72)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bg)

	var item_box := _node_from_layout("ItemBox")
	var icon_box := PanelContainer.new()
	icon_box.position = Vector2(12, 5)
	icon_box.size = Vector2(54, 54)
	icon_box.modulate = Color(0.25, 0.22, 0.32, 0.95)
	icon_box.tooltip_text = JSON.stringify(item_box, "\t") if item_box else "GridBoxItemPre.ItemBox"
	row.add_child(icon_box)

	var icon := TextureRect.new()
	icon.position = Vector2(5, 5)
	icon.size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _load_indexed_texture(icon_data)
	icon_box.add_child(icon)

	var name_label := Label.new()
	name_label.text = item_name
	name_label.position = Vector2(76, 8)
	name_label.size = Vector2(130, 22)
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.62, 1.0))
	row.add_child(name_label)

	var count_label := Label.new()
	count_label.text = "x%d" % item_count
	count_label.position = Vector2(76, 33)
	count_label.size = Vector2(80, 20)
	count_label.add_theme_font_size_override("font_size", 16)
	count_label.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0, 1.0))
	row.add_child(count_label)

	var check := _node_from_layout("chek2" if checked else "chek1")
	var check_rect := TextureRect.new()
	check_rect.position = Vector2(212, 18)
	check_rect.size = Vector2(24, 24)
	check_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	check_rect.stretch_mode = TextureRect.STRETCH_SCALE
	if check and str(check.get("texture_path", "")) != "":
		check_rect.texture = _load_node_texture("res://" + str(check.get("texture_path", "")), check)
	else:
		check_rect.modulate = Color(0.4, 0.52, 0.72, 0.85)
	row.add_child(check_rect)

func _add_bag_tabs_mock() -> void:
	var center := _canvas_center()
	var tabs := ["装备", "道具", "碎片", "符文", "神器"]
	for i in tabs.size():
		var button := Button.new()
		button.position = center + Vector2(468, -224 + i * 70)
		button.size = Vector2(150, 46)
		button.z_index = 90
		button.text = tabs[i]
		button.add_theme_font_size_override("font_size", 20)
		canvas.add_child(button)

func _add_bag_detail_mock() -> void:
	var center := _canvas_center()
	var panel := PanelContainer.new()
	panel.position = center + Vector2(-56, -170)
	panel.size = Vector2(410, 265)
	panel.z_index = 90
	panel.modulate = Color(0.18, 0.16, 0.23, 0.92)
	canvas.add_child(panel)
	var icon_data := _equipment_icon(2)
	var icon_box := PanelContainer.new()
	icon_box.position = Vector2(24, 28)
	icon_box.size = Vector2(88, 88)
	icon_box.modulate = Color(0.22, 0.18, 0.32, 0.86)
	panel.add_child(icon_box)
	var icon := TextureRect.new()
	icon.position = Vector2(10, 10)
	icon.size = Vector2(68, 68)
	icon.texture = _load_indexed_texture(icon_data)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_box.add_child(icon)
	var title_label := Label.new()
	title_label.text = "星辉宝箱"
	title_label.position = Vector2(132, 30)
	title_label.size = Vector2(240, 32)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	panel.add_child(title_label)
	var desc := Label.new()
	desc.text = "可开出英雄培养材料、金币和稀有装备。\n拥有数量：15\n品质：SSR"
	desc.position = Vector2(132, 74)
	desc.size = Vector2(250, 104)
	desc.add_theme_font_size_override("font_size", 17)
	desc.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0))
	panel.add_child(desc)
	var source := Label.new()
	source.text = "获取途径：副本、活动、召唤奖励"
	source.position = Vector2(28, 190)
	source.size = Vector2(350, 28)
	source.add_theme_font_size_override("font_size", 16)
	source.add_theme_color_override("font_color", Color(0.72, 0.82, 0.96))
	panel.add_child(source)

func _add_bag_actions_mock() -> void:
	var center := _canvas_center()
	var actions := [
		{"text": "使用", "pos": Vector2(0, 130)},
		{"text": "出售", "pos": Vector2(142, 130)},
		{"text": "一键出售", "pos": Vector2(284, 130)},
	]
	for action in actions:
		var button := Button.new()
		button.position = center + Vector2(-48, 120) + action.pos
		button.size = Vector2(122, 40)
		button.z_index = 90
		button.text = str(action.text)
		button.add_theme_font_size_override("font_size", 18)
		canvas.add_child(button)

func _node_from_layout(node_name: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(BAG_ITEM_LAYOUT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	for node in parsed.get("nodes", []):
		if typeof(node) == TYPE_DICTIONARY and str(node.get("name", "")) == node_name:
			return node
	return {}

func _equipment_icon(index: int) -> Dictionary:
	if equipment_icons.is_empty():
		return {}
	var sprite_entries := equipment_icons.filter(func(item: Dictionary) -> bool:
		return int(item.get("type_index", 0)) == 9 and str(item.get("texture_path", "")) != ""
	)
	if sprite_entries.is_empty():
		return equipment_icons[index % equipment_icons.size()]
	return sprite_entries[index % sprite_entries.size()]

func _load_indexed_texture(icon_data: Dictionary) -> Texture2D:
	var path := str(icon_data.get("texture_path", ""))
	if path == "":
		return null
	return _load_node_texture("res://" + path, icon_data, true)

func _add_draw_card_mock() -> void:
	var center := _canvas_center()
	var bg := _add_named_image("image/com/DrawCard/zh_bg", center + Vector2(-420, -230), Vector2(820, 360), TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	bg.modulate = Color(1, 1, 1, 0.72)
	bg.z_index = 40
	var card_names := ["普通召唤", "高级召唤", "友情召唤"]
	var card_resources := ["image/com/DrawCard/zh_image_pan2", "image/com/DrawCard/bx_icon_03", "image/com/DrawCard/bx_icon_02"]
	for i in 3:
		var card := PanelContainer.new()
		card.position = _mock_cocos_position(Vector2(-220 + i * 170, 70), 0.68)
		card.size = Vector2(150, 205)
		card.z_index = 100
		card.self_modulate = Color(0.18, 0.14, 0.28, 0.86)
		canvas.add_child(card)
		_add_named_image_to(card, card_resources[i], Vector2(22, 18), Vector2(106, 112), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		var label := Label.new()
		label.text = card_names[i]
		label.position = Vector2(0, 140)
		label.size = Vector2(150, 28)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
		card.add_child(label)
		var button := Button.new()
		button.text = "召唤"
		button.position = Vector2(28, 170)
		button.size = Vector2(94, 28)
		card.add_child(button)
	_add_draw_card_reward_bar(_mock_cocos_position(Vector2(-445.515, -34.509), 0.68) + Vector2(-12, -46))
	_add_draw_card_tabs()
	_add_draw_card_cost_panel(_mock_cocos_position(Vector2(-466, -96), 0.68) + Vector2(-119, -33))
	_add_draw_card_result_preview(_mock_cocos_position(Vector2(0, -205), 0.68) + Vector2(-180, -16))
	_add_draw_card_exchange_panel(_mock_cocos_position(Vector2(250, -96), 0.68) + Vector2(-105, -33))

func _add_draw_card_reward_bar(origin: Vector2) -> void:
	var bg := _add_named_image("image/com/DrawCard/zh_progressBG_jiangli", origin, Vector2(340, 22), TextureRect.STRETCH_SCALE)
	bg.z_index = 100
	var bar := _add_named_image("image/com/DrawCard/zh_progressbar_jiangli", origin + Vector2(6, 6), Vector2(220, 10), TextureRect.STRETCH_SCALE)
	bar.z_index = 101
	for i in 4:
		var box := _add_named_image("image/com/DrawCard/bx_icon_0%d" % (i + 1), origin + Vector2(52 + i * 82, -48), Vector2(58, 58), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		box.z_index = 102

func _add_draw_card_tabs() -> void:
	var tabs := [
		{"text": "英灵来袭", "res": "image/com/DrawCard/zh_btn_gaojioff", "pos": Vector2(501, 252)},
		{"text": "普通", "res": "image/com/DrawCard/zh_btn_putongon", "pos": Vector2(501, 158)},
		{"text": "友情", "res": "image/com/DrawCard/zh_btn_youqingoff", "pos": Vector2(501, 53.774)},
		{"text": "高级", "res": "image/com/DrawCard/zh_btn_gaojioff", "pos": Vector2(501, -44.813)},
		{"text": "天命", "res": "image/com/DrawCard/zh_btn_xianzhioff", "pos": Vector2(501, -150.879)},
	]
	for i in tabs.size():
		var button := Button.new()
		button.position = _mock_cocos_position(tabs[i].pos, 0.68) + Vector2(-68, -26)
		button.size = Vector2(138, 52)
		button.text = ""
		button.z_index = 100
		canvas.add_child(button)
		_add_named_image_to(button, str(tabs[i].res), Vector2(0, 0), Vector2(138, 52), TextureRect.STRETCH_SCALE)
		var label := Label.new()
		label.text = str(tabs[i].text)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 19)
		label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.62))
		button.add_child(label)

func _add_draw_card_cost_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(238, 118)
	panel.z_index = 100
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.9)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "召唤积分  11/120"
	title_label.position = Vector2(14, 10)
	title_label.size = Vector2(210, 26)
	title_label.add_theme_font_size_override("font_size", 17)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	panel.add_child(title_label)
	var calls := [
		{"text": "召唤1次", "cost": "1000"},
		{"text": "召唤10次", "cost": "9000"},
	]
	for i in calls.size():
		var button := Button.new()
		button.position = Vector2(16 + i * 108, 50)
		button.size = Vector2(96, 52)
		button.text = "%s\n%s" % [calls[i].text, calls[i].cost]
		button.add_theme_font_size_override("font_size", 15)
		panel.add_child(button)

func _add_draw_card_result_preview(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(360, 142)
	panel.z_index = 100
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.9)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "十连结果预览"
	title_label.position = Vector2(0, 10)
	title_label.size = Vector2(360, 26)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 19)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	panel.add_child(title_label)
	var heroes := ["105004", "205008", "305006", "405007", "505004"]
	for i in heroes.size():
		var x := 22 + i * 66
		_add_named_image_to(panel, "image/comHeroGrid/cm_frame_TouXiangDi5", Vector2(x, 48), Vector2(56, 56), TextureRect.STRETCH_SCALE)
		_add_named_image_to(panel, "image/head/%s" % heroes[i], Vector2(x + 6, 54), Vector2(44, 44), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		_add_named_image_to(panel, "image/comHeroGrid/cm_tag_SSR1", Vector2(x, 48), Vector2(30, 18), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

func _add_draw_card_exchange_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(210, 142)
	panel.z_index = 100
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.9)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/DrawCard/zh_btn_duihuan", Vector2(34, 14), Vector2(142, 46), TextureRect.STRETCH_SCALE)
	var info := Label.new()
	info.text = "积分兑换\nSSR碎片、召唤券\n当前积分：360"
	info.position = Vector2(16, 70)
	info.size = Vector2(178, 62)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 16)
	info.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0))
	panel.add_child(info)

func _add_named_image(resource_path: String, position: Vector2, size: Vector2, stretch_mode: TextureRect.StretchMode) -> TextureRect:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _texture_for_named_resource(resource_path)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch_mode
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(image)
	return image

func _add_named_image_to(parent: Control, resource_path: String, position: Vector2, size: Vector2, stretch_mode: TextureRect.StretchMode) -> TextureRect:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _texture_for_named_resource(resource_path)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = stretch_mode
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func _texture_for_named_resource(resource_path: String) -> Texture2D:
	var item: Dictionary = named_resources.get(resource_path, {})
	if item.is_empty():
		return null
	return _load_indexed_texture(item)

func _add_guild_mock() -> void:
	var center := _canvas_center()
	var bg := _add_named_image("image/com/Guild/GongHui_BG01", center + Vector2(-455, -250), Vector2(860, 470), TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	bg.modulate = Color(1, 1, 1, 0.76)
	_add_named_image("image/com/Guild/GongHui_BG02", center + Vector2(130, -215), Vector2(240, 420), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.65)
	_add_guild_info_panel(center + Vector2(-405, -200))
	_add_guild_flag(center + Vector2(-75, -130))
	var entries := [
		{"text": "公会首领", "res": "image/com/Guild/gh_frame_rukoudi1"},
		{"text": "公会科技", "res": "image/com/Guild/gh_frame_rukoudi2"},
		{"text": "成员管理", "res": "image/com/Guild/gh_frame_rukoudi3"},
		{"text": "公会战", "res": "image/com/Guild/gh_frame_rukoudi4"},
	]
	for i in entries.size():
		var pos := center + Vector2(135 + (i % 2) * 175, -95 + int(i / 2) * 135)
		_add_guild_entry(pos, str(entries[i].text), str(entries[i].res))

func _add_guild_info_panel(origin: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = origin
	panel.size = Vector2(310, 156)
	panel.modulate = Color(0.12, 0.1, 0.08, 0.72)
	canvas.add_child(panel)
	var title := Label.new()
	title.text = "星辉骑士团"
	title.position = Vector2(18, 14)
	title.size = Vector2(250, 30)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.46))
	panel.add_child(title)
	var info := Label.new()
	info.text = "等级 12\n成员 42/50\n宣言：欢迎来到本地公会预览"
	info.position = Vector2(20, 52)
	info.size = Vector2(270, 88)
	info.add_theme_font_size_override("font_size", 18)
	info.add_theme_color_override("font_color", Color(0.86, 0.93, 1.0))
	panel.add_child(info)

func _add_guild_flag(origin: Vector2) -> void:
	var flag_bg := PanelContainer.new()
	flag_bg.position = origin
	flag_bg.size = Vector2(132, 172)
	flag_bg.modulate = Color(0.18, 0.1, 0.08, 0.55)
	canvas.add_child(flag_bg)
	_add_named_image("image/guildFlag/1", origin + Vector2(16, 10), Vector2(100, 100), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var label := Label.new()
	label.text = "Lv.12"
	label.position = Vector2(0, 126)
	label.size = Vector2(132, 26)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	flag_bg.add_child(label)

func _add_guild_entry(position: Vector2, text: String, resource_path: String) -> void:
	var button := Button.new()
	button.position = position
	button.size = Vector2(150, 92)
	button.text = ""
	button.tooltip_text = text
	canvas.add_child(button)
	_add_named_image_to(button, resource_path, Vector2(8, 4), Vector2(134, 64), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var label := Label.new()
	label.text = text
	label.position = Vector2(0, 62)
	label.size = Vector2(150, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.98, 0.91, 0.68))
	button.add_child(label)

func _add_sky_city_mock() -> void:
	var center := _canvas_center()
	_add_named_image("image/com/skyCity/huayuan/kongzhonghuayuan-dao.j", center + Vector2(-520, -258), Vector2(820, 430), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.72)
	_add_named_image("image/com/skyCity/huayuan/kongzhonghuayuan-qianbiandeyun", center + Vector2(-520, 210), Vector2(820, 72), TextureRect.STRETCH_SCALE).modulate = Color(1, 1, 1, 0.88)
	_add_sky_city_building(center + Vector2(-350, -66), "image/com/skyCity/buildBody/0001", "主城堡", "Lv.8")
	_add_sky_city_building(center + Vector2(-145, 12), "image/com/skyCity/buildBody/11301", "工坊", "Lv.5")
	_add_sky_city_building(center + Vector2(-500, 72), "image/com/skyCity/buildBody/5301", "空港", "Lv.4")
	_add_sky_city_mine(center + Vector2(100, -118), "image/com/skyCity/kuangwu/kuangwu-lansekuang", "蓝晶矿", "12/h")
	_add_sky_city_mine(center + Vector2(275, -28), "image/com/skyCity/kuangwu/kuangwu-huangsekuang", "金辉矿", "8/h")
	_add_sky_city_bubble(center + Vector2(-12, 126), "image/com/skyCity/fuben/fuben-qipao-bossdao", "首领岛")
	_add_sky_city_bubble(center + Vector2(178, 136), "image/com/skyCity/fuben/fuben-qipao-ziyuanxiaodao", "资源岛")
	_add_sky_city_action_button(center + Vector2(142, 244), "一键领取")
	_add_sky_city_action_button(center + Vector2(354, 244), "战意制作")

func _add_sky_city_building(position: Vector2, resource_path: String, title_text: String, level_text: String) -> void:
	var root := Control.new()
	root.position = position
	root.size = Vector2(160, 150)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)
	_add_named_image_to(root, resource_path, Vector2(10, 0), Vector2(140, 104), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var plate := PanelContainer.new()
	plate.position = Vector2(14, 103)
	plate.size = Vector2(132, 40)
	plate.modulate = Color(0.12, 0.12, 0.18, 0.72)
	root.add_child(plate)
	var label := Label.new()
	label.text = "%s  %s" % [title_text, level_text]
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.68))
	plate.add_child(label)

func _add_sky_city_mine(position: Vector2, resource_path: String, title_text: String, rate_text: String) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(148, 94)
	panel.modulate = Color(0.08, 0.12, 0.18, 0.66)
	canvas.add_child(panel)
	_add_named_image_to(panel, resource_path, Vector2(10, 8), Vector2(62, 62), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var label := Label.new()
	label.text = "%s\n%s" % [title_text, rate_text]
	label.position = Vector2(76, 16)
	label.size = Vector2(66, 60)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.84, 0.95, 1.0))
	panel.add_child(label)

func _add_sky_city_bubble(position: Vector2, resource_path: String, title_text: String) -> void:
	var button := Button.new()
	button.position = position
	button.size = Vector2(128, 104)
	button.text = ""
	button.tooltip_text = title_text
	canvas.add_child(button)
	_add_named_image_to(button, resource_path, Vector2(16, 4), Vector2(96, 64), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var label := Label.new()
	label.text = title_text
	label.position = Vector2(0, 70)
	label.size = Vector2(128, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	button.add_child(label)

func _add_sky_city_action_button(position: Vector2, text: String) -> void:
	var button := Button.new()
	button.position = position
	button.size = Vector2(178, 52)
	button.text = text
	button.add_theme_font_size_override("font_size", 21)
	canvas.add_child(button)

func _add_maoxian_map_mock() -> void:
	var center := _canvas_center()
	_add_named_image("image/com/MaoxianPanel/mxbg1", center + Vector2(-542, -270), Vector2(980, 520), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.72)
	_add_named_image("image/com/MaoxianPanel/BG01", center + Vector2(-610, -272), Vector2(1120, 560), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.28)
	var stages := [
		{"title": "1-1", "pos": Vector2(-470, 80), "res": "image/com/MaoxianPanel/1-2"},
		{"title": "1-4", "pos": Vector2(-286, -18), "res": "image/com/MaoxianPanel/1-4"},
		{"title": "1-7", "pos": Vector2(-92, 66), "res": "image/com/MaoxianPanel/1-7"},
		{"title": "2-3", "pos": Vector2(92, -28), "res": "image/com/MaoxianPanel/2-3"},
		{"title": "2-7", "pos": Vector2(280, 72), "res": "image/com/MaoxianPanel/2-7"},
		{"title": "3-2", "pos": Vector2(452, -20), "res": "image/com/MaoxianPanel/3-2"},
	]
	for i in stages.size():
		_add_maoxian_stage(center + stages[i].pos, str(stages[i].title), str(stages[i].res), i <= 3)
	_add_maoxian_side_panel(center + Vector2(-620, -214))
	_add_maoxian_bottom_panel(center + Vector2(-468, 232))

func _add_maoxian_stage(position: Vector2, title_text: String, resource_path: String, unlocked: bool) -> void:
	var button := Button.new()
	button.position = position
	button.size = Vector2(120, 104)
	button.text = ""
	button.tooltip_text = title_text
	canvas.add_child(button)
	_add_named_image_to(button, resource_path, Vector2(10, 0), Vector2(100, 74), TextureRect.STRETCH_KEEP_ASPECT_CENTERED).modulate = Color(1, 1, 1, 1.0 if unlocked else 0.48)
	var label := Label.new()
	label.text = title_text
	label.position = Vector2(10, 72)
	label.size = Vector2(100, 26)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58) if unlocked else Color(0.65, 0.66, 0.72))
	button.add_child(label)

func _add_maoxian_side_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(190, 430)
	panel.modulate = Color(0.07, 0.08, 0.12, 0.66)
	canvas.add_child(panel)
	for i in 5:
		var btn := Button.new()
		btn.position = Vector2(18, 22 + i * 78)
		btn.size = Vector2(154, 58)
		btn.text = ["主线", "魔塔", "试炼", "支援", "奖励"][i]
		btn.add_theme_font_size_override("font_size", 19)
		panel.add_child(btn)

func _add_maoxian_bottom_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(936, 74)
	panel.modulate = Color(0.04, 0.05, 0.08, 0.7)
	canvas.add_child(panel)
	var info := Label.new()
	info.text = "冒险地图  当前章节 1-4  推荐战力 3027113"
	info.position = Vector2(28, 16)
	info.size = Vector2(560, 36)
	info.add_theme_font_size_override("font_size", 21)
	info.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	panel.add_child(info)
	var fight := Button.new()
	fight.position = Vector2(720, 12)
	fight.size = Vector2(174, 50)
	fight.text = "开始战斗"
	fight.add_theme_font_size_override("font_size", 21)
	panel.add_child(fight)

func _add_jingji_mock() -> void:
	var center := _canvas_center()
	_add_named_image("image/com/pvpActivity/sky-bg", center + Vector2(-472, -260), Vector2(872, 494), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.62)
	_add_named_image("image/com/pvpActivity/slmu-dabiaoti", center + Vector2(-142, -250), Vector2(300, 74), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_jingji_mode_card(center + Vector2(-106, -180), Vector2(230, 126), "冠军联赛", "image/com/pvpActivity/slmu-1", "排名 99", "可挑战")
	_add_jingji_mode_card(center + Vector2(-382, -42), Vector2(230, 126), "战神殿", "image/com/Jingji/team/rk_zhanshendiankuang", "暂未开放", "冠军联赛前 50")
	_add_jingji_mode_card(center + Vector2(168, -42), Vector2(230, 126), "王者争霸", "image/com/Jingji/team/rk_wangzhezhengba_72", "历史最高 99", "赛季玩法")
	_add_jingji_mode_card(center + Vector2(-382, 130), Vector2(230, 126), "组队竞技", "image/com/Jingji/team/rk_zuduijingjikuang", "暂未开放", "3v3 队伍")
	_add_jingji_mode_card(center + Vector2(168, 130), Vector2(230, 126), "巅峰对决", "image/com/pvpActivity/slmu-4", "暂未开放", "跨服竞技")
	_add_jingji_rank_panel(center + Vector2(-596, -208))
	_add_jingji_reward_panel(center + Vector2(430, -166))
	_add_jingji_bottom_notice(center + Vector2(-170, 272))

func _add_jingji_mode_card(position: Vector2, size: Vector2, title_text: String, resource_path: String, status_text: String, subtitle: String) -> void:
	var button := Button.new()
	button.position = position
	button.size = size
	button.text = ""
	button.tooltip_text = title_text
	canvas.add_child(button)
	_add_named_image_to(button, "image/com/pvpActivity/slmu-moren", Vector2.ZERO, size, TextureRect.STRETCH_SCALE).modulate = Color(1, 1, 1, 0.72)
	_add_named_image_to(button, resource_path, Vector2(16, 12), Vector2(88, 82), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var title_label := Label.new()
	title_label.text = title_text
	title_label.position = Vector2(100, 16)
	title_label.size = Vector2(size.x - 108, 30)
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	button.add_child(title_label)
	var status := Label.new()
	status.text = status_text
	status.position = Vector2(102, 51)
	status.size = Vector2(size.x - 112, 24)
	status.add_theme_font_size_override("font_size", 17)
	status.add_theme_color_override("font_color", Color(0.86, 0.95, 1.0))
	button.add_child(status)
	var sub := Label.new()
	sub.text = subtitle
	sub.position = Vector2(20, size.y - 32)
	sub.size = Vector2(size.x - 40, 24)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86))
	button.add_child(sub)

func _add_jingji_rank_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(170, 220)
	panel.modulate = Color(0.08, 0.09, 0.14, 0.72)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/Jingji/jj_icon_mobai", Vector2(42, 16), Vector2(86, 86), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var label := Label.new()
	label.text = "被膜拜次数\n128\n今日奖励 x2"
	label.position = Vector2(12, 112)
	label.size = Vector2(146, 90)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.72))
	panel.add_child(label)

func _add_jingji_reward_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(208, 250)
	panel.modulate = Color(0.08, 0.09, 0.14, 0.68)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "赛季奖励"
	title_label.position = Vector2(0, 14)
	title_label.size = Vector2(208, 28)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	panel.add_child(title_label)
	for i in 3:
		_add_named_image_to(panel, "image/com/pvpActivity/slmu-jiangpinkuang", Vector2(26, 56 + i * 56), Vector2(156, 44), TextureRect.STRETCH_SCALE)
		var reward := Label.new()
		reward.text = ["钻石 x300", "竞技币 x1200", "英雄碎片 x20"][i]
		reward.position = Vector2(42, 66 + i * 56)
		reward.size = Vector2(126, 24)
		reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward.add_theme_font_size_override("font_size", 16)
		reward.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0))
		panel.add_child(reward)

func _add_jingji_bottom_notice(position: Vector2) -> void:
	_add_named_image("image/com/pvpActivity/slmu-heichangtiao", position, Vector2(360, 34), TextureRect.STRETCH_SCALE).modulate = Color(1, 1, 1, 0.76)
	var label := Label.new()
	label.text = "赛季结束时将通过邮件发送排名奖励"
	label.position = position
	label.size = Vector2(360, 34)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.86, 0.92, 1.0))
	canvas.add_child(label)

func _add_battle_mock() -> void:
	var center := _canvas_center()
	_add_named_image("image/com/map/1001", center + Vector2(-508, -270), Vector2(930, 520), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.72)
	_add_battle_top_bar(center + Vector2(-456, -256))
	var left_positions := [
		center + Vector2(-330, 44),
		center + Vector2(-448, -38),
		center + Vector2(-224, -58),
		center + Vector2(-386, 156),
		center + Vector2(-152, 132),
	]
	var right_positions := [
		center + Vector2(314, 38),
		center + Vector2(442, -48),
		center + Vector2(194, -70),
		center + Vector2(374, 156),
		center + Vector2(126, 128),
	]
	var left_heads := ["image/head/105004", "image/head/205008", "image/head/305006", "image/head/204001", "image/head/504002"]
	var right_heads := ["image/head/505004", "image/head/405007", "image/head/304001", "image/head/204002", "image/head/1000201"]
	for i in 5:
		_add_battle_unit(left_positions[i], left_heads[i], "我方%d" % (i + 1), 0.82 - i * 0.08, false)
		_add_battle_unit(right_positions[i], right_heads[i], "敌方%d" % (i + 1), 0.76 - i * 0.07, true)
	_add_battle_damage(center + Vector2(102, -146), "暴击 12876")
	_add_battle_damage(center + Vector2(-226, -122), "治疗 +2480", Color(0.5, 1.0, 0.58))
	_add_battle_result_panel(center + Vector2(-160, 196))

func _add_battle_top_bar(position: Vector2) -> void:
	var bar := PanelContainer.new()
	bar.position = position
	bar.size = Vector2(860, 52)
	bar.modulate = Color(0.06, 0.07, 0.1, 0.72)
	canvas.add_child(bar)
	var left := Label.new()
	left.text = "本地战斗预览"
	left.position = Vector2(18, 10)
	left.size = Vector2(260, 32)
	left.add_theme_font_size_override("font_size", 22)
	left.add_theme_color_override("font_color", Color(1.0, 0.92, 0.62))
	bar.add_child(left)
	var right := Label.new()
	right.text = "1/3 回合    自动战斗"
	right.position = Vector2(620, 12)
	right.size = Vector2(220, 28)
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_theme_font_size_override("font_size", 18)
	right.add_theme_color_override("font_color", Color(0.84, 0.92, 1.0))
	bar.add_child(right)

func _add_battle_unit(position: Vector2, head_path: String, title_text: String, hp_ratio: float, flip: bool) -> void:
	var unit := Control.new()
	unit.position = position
	unit.size = Vector2(118, 158)
	unit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(unit)
	var shadow := PanelContainer.new()
	shadow.position = Vector2(14, 116)
	shadow.size = Vector2(90, 24)
	shadow.modulate = Color(0, 0, 0, 0.42)
	unit.add_child(shadow)
	var body := TextureRect.new()
	body.position = Vector2(16, 8)
	body.size = Vector2(86, 86)
	body.texture = _texture_for_named_resource(head_path)
	body.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	body.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	body.flip_h = flip
	unit.add_child(body)
	var name_label := Label.new()
	name_label.text = title_text
	name_label.position = Vector2(0, 94)
	name_label.size = Vector2(118, 22)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	unit.add_child(name_label)
	_add_battle_hp_bar(unit, Vector2(10, 122), hp_ratio)

func _add_battle_hp_bar(parent: Control, position: Vector2, ratio: float) -> void:
	var bg := ColorRect.new()
	bg.position = position
	bg.size = Vector2(98, 10)
	bg.color = Color(0.16, 0.04, 0.04, 0.9)
	parent.add_child(bg)
	var fill := ColorRect.new()
	fill.position = position + Vector2(1, 1)
	fill.size = Vector2(maxf(0.0, minf(1.0, ratio)) * 96.0, 8)
	fill.color = Color(0.72, 0.1, 0.08, 0.95)
	parent.add_child(fill)

func _add_battle_damage(position: Vector2, text: String, color: Color = Color(1.0, 0.35, 0.22)) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = Vector2(180, 36)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", color)
	canvas.add_child(label)

func _add_battle_result_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(320, 104)
	panel.modulate = Color(0.08, 0.07, 0.1, 0.74)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/BattleEnd/sl_frame9_shengli", Vector2(12, 10), Vector2(296, 42), TextureRect.STRETCH_SCALE)
	var title_label := Label.new()
	title_label.text = "战斗胜利"
	title_label.position = Vector2(0, 16)
	title_label.size = Vector2(320, 30)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	panel.add_child(title_label)
	var reward := Label.new()
	reward.text = "金币 x12000    经验 x460    装备宝箱 x1"
	reward.position = Vector2(18, 62)
	reward.size = Vector2(284, 28)
	reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward.add_theme_font_size_override("font_size", 17)
	reward.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0))
	panel.add_child(reward)

func _add_draw_card_activity_mock() -> void:
	var center := _canvas_center()
	_add_named_image("image/com/ActivityPanel/ZhaoHuan/jfzh_image_bg", center + Vector2(-428, -248), Vector2(820, 420), TextureRect.STRETCH_KEEP_ASPECT_COVERED).modulate = Color(1, 1, 1, 0.62)
	_add_named_image("image/com/ActivityPanel/ZhaoHuan/Title", center + Vector2(-430, -265), Vector2(360, 90), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_draw_activity_time(center + Vector2(-600, 238))
	_add_draw_activity_tabs(center + Vector2(420, -236))
	_add_draw_activity_login_pick(center + Vector2(-600, -146))
	_add_draw_activity_featured_hero(center + Vector2(-428, -110))
	_add_draw_activity_reward_track(center + Vector2(-360, 176))
	_add_draw_activity_task_panel(center + Vector2(-72, -168))
	_add_draw_activity_shop_panel(center + Vector2(186, -190))
	_add_draw_activity_button(center + Vector2(-108, 232), "前往召唤")
	_add_draw_activity_button(center + Vector2(146, 232), "领取奖励")

func _add_draw_activity_tabs(position: Vector2) -> void:
	var tabs := [
		{"id": "13002", "text": "登录领取", "layout": "活动抽卡-登录领取"},
		{"id": "13003", "text": "循环礼包", "layout": "活动抽卡-循环礼包"},
		{"id": "13004", "text": "抽数任务", "layout": "活动抽卡-抽数任务"},
		{"id": "13005", "text": "许愿礼包", "layout": "活动抽卡-许愿礼包"},
	]
	for i in tabs.size():
		var button := Button.new()
		button.position = position + Vector2(0, i * 58)
		button.size = Vector2(142, 48)
		button.text = ""
		button.tooltip_text = "DrawCardActivity%s" % tabs[i].id
		button.pressed.connect(_load_layout.bind(str(tabs[i].layout)))
		canvas.add_child(button)
		_add_named_image_to(button, "image/common/cm_btn2" if i == 0 else "image/common/cm_btn1", Vector2.ZERO, Vector2(142, 48), TextureRect.STRETCH_SCALE)
		var label := Label.new()
		label.text = str(tabs[i].text)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.62))
		button.add_child(label)

func _add_draw_activity_login_pick(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(200, 214)
	panel.self_modulate = Color(0.08, 0.08, 0.14, 0.68)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "13002 登录领取"
	title_label.position = Vector2(0, 14)
	title_label.size = Vector2(200, 28)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	panel.add_child(title_label)
	for i in 3:
		var y := 58 + i * 48
		_add_named_image_to(panel, "image/com/DrawCard/bx_icon_0%d" % (i + 1), Vector2(18, y), Vector2(38, 38), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		var label := Label.new()
		label.text = ["第1天 召唤券 x1", "第2天 钻石 x300", "第3天 SSR碎片 x10"][i]
		label.position = Vector2(62, y + 7)
		label.size = Vector2(126, 24)
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0))
		panel.add_child(label)

func _add_draw_activity_time(position: Vector2) -> void:
	var label := Label.new()
	label.text = "活动剩余 2天23时"
	label.position = position
	label.size = Vector2(260, 30)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	canvas.add_child(label)

func _add_draw_activity_featured_hero(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(420, 260)
	panel.modulate = Color(0.08, 0.08, 0.14, 0.54)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/NewHeroComing/JiangLin/yxjl_frame_di", Vector2(18, 24), Vector2(384, 210), TextureRect.STRETCH_SCALE)
	_add_named_image_to(panel, "image/head/105004", Vector2(34, 46), Vector2(132, 132), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_named_image_to(panel, "image/com/ActivityPanel/NewHeroComing/JiangLin/yxjl_btn_bofang", Vector2(126, 154), Vector2(44, 44), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var title_label := Label.new()
	title_label.text = "限定英雄概率提升"
	title_label.position = Vector2(180, 50)
	title_label.size = Vector2(205, 34)
	title_label.add_theme_font_size_override("font_size", 23)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	panel.add_child(title_label)
	var desc := Label.new()
	desc.text = "首次十连必得 SR 或 SSR\n活动积分可兑换专属奖励"
	desc.position = Vector2(180, 96)
	desc.size = Vector2(210, 72)
	desc.add_theme_font_size_override("font_size", 17)
	desc.add_theme_color_override("font_color", Color(0.86, 0.94, 1.0))
	panel.add_child(desc)

func _add_draw_activity_reward_track(position: Vector2) -> void:
	_add_named_image("image/com/ActivityPanel/thousandDrawCardActivity/Chouka_img_tiaobg", position, Vector2(480, 44), TextureRect.STRETCH_SCALE)
	for i in 4:
		var icon_pos := position + Vector2(34 + i * 118, -38)
		_add_named_image("image/com/ActivityPanel/thousandDrawCardActivity/1_icon_juanzhou0%d" % (2 + i % 2), icon_pos, Vector2(58, 58), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		var label := Label.new()
		label.text = "%d抽" % ((i + 1) * 30)
		label.position = icon_pos + Vector2(-8, 58)
		label.size = Vector2(74, 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.72))
		canvas.add_child(label)

func _add_draw_activity_shop_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(245, 326)
	panel.modulate = Color(0.08, 0.08, 0.12, 0.72)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "活动兑换"
	title_label.position = Vector2(0, 18)
	title_label.size = Vector2(245, 30)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	panel.add_child(title_label)
	var goods := [
		{"name": "限定碎片 x20", "cost": "积分 600"},
		{"name": "高级召唤券 x5", "cost": "积分 300"},
		{"name": "星辉宝箱 x1", "cost": "积分 180"},
	]
	for i in goods.size():
		var y := 66 + i * 74
		_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(18, y), Vector2(210, 58), TextureRect.STRETCH_SCALE)
		var name_label := Label.new()
		name_label.text = str(goods[i].name)
		name_label.position = Vector2(32, y + 7)
		name_label.size = Vector2(180, 22)
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
		panel.add_child(name_label)
		var cost := Label.new()
		cost.text = str(goods[i].cost)
		cost.position = Vector2(32, y + 31)
		cost.size = Vector2(180, 20)
		cost.add_theme_font_size_override("font_size", 14)
		cost.add_theme_color_override("font_color", Color(1.0, 0.82, 0.46))
		panel.add_child(cost)

func _add_draw_activity_task_panel(position: Vector2) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(235, 256)
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.68)
	canvas.add_child(panel)
	var title_label := Label.new()
	title_label.text = "13004 抽数任务"
	title_label.position = Vector2(0, 16)
	title_label.size = Vector2(235, 28)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	panel.add_child(title_label)
	var tasks := [
		{"text": "累计召唤 30 次", "state": "可领取"},
		{"text": "累计召唤 60 次", "state": "18/60"},
		{"text": "累计召唤 100 次", "state": "18/100"},
	]
	for i in tasks.size():
		var y := 58 + i * 58
		_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(14, y), Vector2(207, 46), TextureRect.STRETCH_SCALE)
		var task := Label.new()
		task.text = str(tasks[i].text)
		task.position = Vector2(26, y + 7)
		task.size = Vector2(132, 20)
		task.add_theme_font_size_override("font_size", 14)
		task.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0))
		panel.add_child(task)
		var state := Label.new()
		state.text = str(tasks[i].state)
		state.position = Vector2(154, y + 7)
		state.size = Vector2(58, 22)
		state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		state.add_theme_font_size_override("font_size", 13)
		state.add_theme_color_override("font_color", Color(1.0, 0.82, 0.46))
		panel.add_child(state)

func _add_draw_activity_button(position: Vector2, text: String) -> void:
	var button := Button.new()
	button.position = position
	button.size = Vector2(210, 54)
	button.text = text
	button.add_theme_font_size_override("font_size", 21)
	canvas.add_child(button)

func _add_draw_activity_login_reward_runtime_mock() -> void:
	_add_activity_runtime_title("DrawCardActivity13002 / 登录领取", "rewardOne(): 领取当天奖励    rewardall(): 一键领取")
	_add_named_image("image/com/ActivityPanel/ZhaoHuan/Title", _mock_cocos_position(Vector2(-302, 230)), Vector2(310, 78), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_named_image("image/com/ActivityPanel/NewHeroComing/JiangLin/yxjl_frame_di", _mock_cocos_position(Vector2(150, -52)), Vector2(520, 260), TextureRect.STRETCH_SCALE)
	_add_named_image("image/head/105004", _mock_cocos_position(Vector2(54, -14)), Vector2(152, 152), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_activity_badge(_mock_cocos_position(Vector2(278, 219)), "今日可领取", Color(0.9, 0.16, 0.12))
	_add_activity_button_like(_mock_cocos_position(Vector2(196, -186)), "领取")
	_add_activity_button_like(_mock_cocos_position(Vector2(338, -186)), "一键领取")
	var days := [
		{"day": "第1天", "reward": "召唤券 x1", "state": "已领取"},
		{"day": "第2天", "reward": "钻石 x300", "state": "可领取"},
		{"day": "第3天", "reward": "SSR碎片 x10", "state": "未达成"},
		{"day": "第4天", "reward": "英雄宝箱 x1", "state": "未达成"},
	]
	for i in days.size():
		var pos := _mock_cocos_position(Vector2(-324 + i * 152, -176))
		_add_activity_reward_card(pos, str(days[i].day), str(days[i].reward), str(days[i].state), i == 1)

func _add_draw_activity_cycle_runtime_mock() -> void:
	_add_activity_runtime_title("DrawCardActivity13003 / 循环礼包", "setData(e,t): content 子节点复用 DrawCardActivityCycleItemCom")
	var rows := [
		{"name": "累计召唤 10 次", "reward": "高级召唤券 x2", "progress": "10/10", "state": "领取", "icon_index": 8},
		{"name": "累计召唤 30 次", "reward": "钻石 x500", "progress": "18/30", "state": "前往", "icon_index": 12},
		{"name": "累计召唤 60 次", "reward": "SSR碎片 x20", "progress": "18/60", "state": "前往", "icon_index": 18},
		{"name": "累计召唤 100 次", "reward": "限定头像框", "progress": "18/100", "state": "已领取", "icon_index": 24},
	]
	var clip := _create_activity_clip_container("13003")
	for i in rows.size():
		_add_activity_cycle_template_row(Vector2(0, 122 - i * 108), rows[i], _activity_scroll_clip_rect("13003"), clip)

func _add_draw_activity_task_runtime_mock() -> void:
	_add_activity_runtime_title("DrawCardActivity13004 / 抽数任务", "setData(e,t,n): boxList 驱动宝箱红点，taskList 驱动任务列表")
	var box_positions := [Vector2(-258, 175), Vector2(-141, 175), Vector2(-27, 175), Vector2(87, 175), Vector2(201, 175), Vector2(315, 175)]
	var boxes := [
		{"need": 30, "state": 2}, {"need": 60, "state": 1}, {"need": 100, "state": 0},
		{"need": 150, "state": 0}, {"need": 200, "state": 0}, {"need": 300, "state": 0},
	]
	_add_activity_progress_bar(_mock_cocos_position(Vector2(-256, 144)), Vector2(604, 18), 0.36)
	for i in boxes.size():
		var box: Dictionary = boxes[i]
		var state := int(box.get("state", 0))
		var icon := "image/com/DrawCard/bx_icon_0%d%s" % [2 + int(i / 2), "" if state == 2 else "a"]
		var pos := _mock_cocos_position(box_positions[i])
		_add_named_image(icon, pos + Vector2(-34, -40), Vector2(68, 68), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		_add_activity_small_label(str(box.get("need", 0)), pos + Vector2(-28, 24), Vector2(56, 20), Color(1.0, 0.88, 0.48), HORIZONTAL_ALIGNMENT_CENTER)
		if state == 1:
			_add_activity_red_dot(pos + Vector2(20, -34))
		elif state == 2:
			_add_activity_badge(pos + Vector2(-32, -48), "已领", Color(0.22, 0.22, 0.22, 0.82), Vector2(58, 22), 13)
	var tasks := [
		{"text": "活动期间累计召唤 30 次", "reward": "积分 +30 / 召唤券 x1", "progress": "30/30", "state": "领取", "icon_index": 8},
		{"text": "活动期间累计召唤 60 次", "reward": "积分 +60 / 钻石 x300", "progress": "42/60", "state": "前往", "icon_index": 12},
		{"text": "活动期间累计召唤 100 次", "reward": "积分 +100 / SSR碎片 x10", "progress": "42/100", "state": "前往", "icon_index": 18},
		{"text": "活动期间累计召唤 150 次", "reward": "积分 +150 / 英雄宝箱 x1", "progress": "42/150", "state": "未完成", "icon_index": 24},
	]
	var clip := _create_activity_clip_container("13004")
	for i in tasks.size():
		_add_activity_task_template_row(Vector2(0, -102 - i * 96), tasks[i], _activity_scroll_clip_rect("13004"), clip)

func _add_draw_activity_wish_gift_runtime_mock() -> void:
	_add_activity_runtime_title("DrawCardActivity13005 / 许愿礼包", "giftContent 动态实例化 giftItemPre，本地预览模拟购买状态")
	var gifts := [
		{"name": "许愿礼包 I", "reward": "召唤券 x5\n钻石 x600", "price": "￥6", "state": "购买"},
		{"name": "许愿礼包 II", "reward": "召唤券 x12\nSSR碎片 x20", "price": "￥30", "state": "购买"},
		{"name": "许愿礼包 III", "reward": "限定英雄碎片 x50\n星辉宝箱 x2", "price": "￥68", "state": "已购"},
	]
	for i in gifts.size():
		_add_activity_gift_card(_mock_cocos_position(Vector2(-286 + i * 276, 46)), gifts[i])

func _add_activity_runtime_title(title: String, subtitle: String) -> void:
	var label := Label.new()
	label.text = title
	label.position = _canvas_center() + Vector2(-402, -286)
	label.size = Vector2(520, 30)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	canvas.add_child(label)
	var sub := Label.new()
	sub.text = subtitle
	sub.position = _canvas_center() + Vector2(-400, -256)
	sub.size = Vector2(720, 24)
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0, 0.86))
	canvas.add_child(sub)

func _add_activity_reward_card(position: Vector2, title: String, reward: String, state: String, highlighted: bool) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(130, 126)
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.78)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(10, 10), Vector2(110, 74), TextureRect.STRETCH_SCALE)
	_add_named_image_to(panel, "image/com/DrawCard/bx_icon_02a", Vector2(39, 18), Vector2(52, 52), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_activity_small_label(title, position + Vector2(0, 82), Vector2(130, 20), Color(1.0, 0.88, 0.5), HORIZONTAL_ALIGNMENT_CENTER)
	_add_activity_small_label(reward, position + Vector2(0, 102), Vector2(130, 20), Color(0.88, 0.94, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	if highlighted:
		_add_activity_red_dot(position + Vector2(108, 6))
	else:
		_add_activity_badge(position + Vector2(8, 8), state, Color(0.08, 0.08, 0.08, 0.72), Vector2(58, 22), 12)

func _add_activity_cycle_row(position: Vector2, data: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(760, 82)
	panel.z_index = 160
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.72)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(10, 9), Vector2(740, 64), TextureRect.STRETCH_SCALE)
	_add_activity_reward_icon(panel, Vector2(28, 17), Vector2(48, 48), int(data.get("icon_index", 0)))
	_add_activity_small_label(str(data.get("name", "")), position + Vector2(94, 14), Vector2(260, 24), Color(1.0, 0.88, 0.5), HORIZONTAL_ALIGNMENT_LEFT, 18)
	_add_activity_small_label(str(data.get("reward", "")), position + Vector2(94, 42), Vector2(260, 22), Color(0.86, 0.94, 1.0), HORIZONTAL_ALIGNMENT_LEFT, 15)
	_add_activity_progress_bar(position + Vector2(386, 32), Vector2(170, 16), 1.0 if str(data.get("state", "")) == "领取" else 0.58)
	_add_activity_small_label(str(data.get("progress", "")), position + Vector2(386, 50), Vector2(170, 20), Color(0.96, 0.9, 0.68), HORIZONTAL_ALIGNMENT_CENTER, 13)
	_add_activity_button_like(position + Vector2(612, 20), str(data.get("state", "")), Vector2(104, 42))

func _add_activity_cycle_template_row(cocos_center: Vector2, data: Dictionary, clip_rect: Rect2 = Rect2(), parent: Control = null) -> void:
	var origin := _mock_cocos_position(cocos_center)
	if not _activity_rect_visible(Rect2(origin + Vector2(-420, -63), Vector2(840, 108)), clip_rect):
		return
	var target_parent := parent if parent != null else canvas
	var parent_origin := target_parent.position
	var panel := PanelContainer.new()
	panel.position = origin + Vector2(-420, -63) - parent_origin
	panel.size = Vector2(840, 108)
	panel.z_index = 160
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.7)
	target_parent.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(0, 0), Vector2(840, 127), TextureRect.STRETCH_SCALE)
	_add_activity_reward_icon_to(target_parent, origin + Vector2(-360 - 31, -17 - 31) - parent_origin, Vector2(62, 62), int(data.get("icon_index", 0)))
	_add_activity_small_label_to(target_parent, str(data.get("name", "")), origin + Vector2(-396, -48) - parent_origin, Vector2(328, 26), Color(1.0, 0.88, 0.5), HORIZONTAL_ALIGNMENT_LEFT, 18)
	_add_activity_small_label_to(target_parent, str(data.get("reward", "")), origin + Vector2(95, -48) - parent_origin, Vector2(212, 26), Color(0.86, 0.94, 1.0), HORIZONTAL_ALIGNMENT_LEFT, 15)
	var state := str(data.get("state", ""))
	if state == "已领取":
		_add_activity_badge_to(target_parent, origin + Vector2(318.754 - 58, -22) - parent_origin, "已领取", Color(0.12, 0.12, 0.12, 0.82), Vector2(116, 42), 17)
	elif state == "领取":
		_add_activity_button_like_to(target_parent, origin + Vector2(318.388 - 52, -22) - parent_origin, "领取", Vector2(104, 42))
	else:
		_add_activity_button_like_to(target_parent, origin + Vector2(318.388 - 52, -22) - parent_origin, "前往", Vector2(104, 42))
	_add_activity_progress_bar_to(target_parent, origin + Vector2(323.706 - 78, 19) - parent_origin, Vector2(155, 16), 1.0 if state == "领取" else 0.58)
	_add_activity_small_label_to(target_parent, str(data.get("progress", "")), origin + Vector2(248, 37) - parent_origin, Vector2(160, 20), Color(0.96, 0.9, 0.68), HORIZONTAL_ALIGNMENT_CENTER, 13)

func _add_activity_task_row(position: Vector2, data: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(668, 78)
	panel.z_index = 160
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.7)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(8, 8), Vector2(652, 60), TextureRect.STRETCH_SCALE)
	_add_activity_reward_icon(panel, Vector2(24, 15), Vector2(46, 46), int(data.get("icon_index", 0)))
	_add_activity_small_label(str(data.get("text", "")), position + Vector2(86, 14), Vector2(304, 22), Color(1.0, 0.88, 0.5), HORIZONTAL_ALIGNMENT_LEFT, 17)
	_add_activity_small_label(str(data.get("reward", "")), position + Vector2(86, 40), Vector2(304, 22), Color(0.86, 0.94, 1.0), HORIZONTAL_ALIGNMENT_LEFT, 14)
	_add_activity_progress_bar(position + Vector2(410, 30), Vector2(112, 14), 1.0 if str(data.get("state", "")) == "领取" else 0.42)
	_add_activity_small_label(str(data.get("progress", "")), position + Vector2(410, 48), Vector2(112, 18), Color(0.96, 0.9, 0.68), HORIZONTAL_ALIGNMENT_CENTER, 12)
	_add_activity_button_like(position + Vector2(548, 18), str(data.get("state", "")), Vector2(94, 40))

func _add_activity_task_template_row(cocos_center: Vector2, data: Dictionary, clip_rect: Rect2 = Rect2(), parent: Control = null) -> void:
	var origin := _mock_cocos_position(cocos_center)
	var row_pos := origin + Vector2(-334, -47)
	if not _activity_rect_visible(Rect2(row_pos, Vector2(668, 95)), clip_rect):
		return
	var target_parent := parent if parent != null else canvas
	var parent_origin := target_parent.position
	var panel := PanelContainer.new()
	panel.position = row_pos - parent_origin
	panel.size = Vector2(668, 95)
	panel.z_index = 160
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.7)
	target_parent.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(0, 0), Vector2(668, 95), TextureRect.STRETCH_SCALE)
	var item_pos := origin + Vector2(-278.491 - 28, -0.098 - 28)
	_add_activity_reward_icon_to(target_parent, item_pos - parent_origin, Vector2(56, 56), int(data.get("icon_index", 0)))
	_add_activity_small_label_to(target_parent, str(data.get("text", "")), origin + Vector2(-221.491 - 6, -10) - parent_origin, Vector2(292, 26), Color(1.0, 0.88, 0.5), HORIZONTAL_ALIGNMENT_LEFT, 17)
	_add_activity_small_label_to(target_parent, str(data.get("reward", "")), origin + Vector2(-221.491 - 6, 18) - parent_origin, Vector2(292, 22), Color(0.86, 0.94, 1.0), HORIZONTAL_ALIGNMENT_LEFT, 14)
	var ready := str(data.get("state", "")) == "领取"
	_add_activity_progress_bar_to(target_parent, origin + Vector2(-77.491 - 147, 20) - parent_origin, Vector2(294, 10), 1.0 if ready else 0.42)
	_add_activity_small_label_to(target_parent, str(data.get("progress", "")), origin + Vector2(-149, 30) - parent_origin, Vector2(142, 20), Color(0.96, 0.9, 0.68), HORIZONTAL_ALIGNMENT_CENTER, 12)
	if str(data.get("state", "")) == "已完成":
		_add_activity_badge_to(target_parent, origin + Vector2(238.509 - 58, -20) - parent_origin, "已完成", Color(0.12, 0.12, 0.12, 0.82), Vector2(116, 38), 17)
	else:
		_add_activity_button_like_to(target_parent, origin + Vector2(238.509 - 47, -22) - parent_origin, str(data.get("state", "")), Vector2(94, 40))

func _activity_scroll_clip_rect(panel_id: String) -> Rect2:
	if panel_id == "13003":
		return Rect2(_canvas_center() + Vector2(-408.0, -170.0), Vector2(848.0, 440.0))
	if panel_id == "13004":
		return Rect2(_canvas_center() + Vector2(-350.0, 60.0), Vector2(760.0, 392.0))
	return Rect2()

func _create_activity_clip_container(panel_id: String) -> Control:
	var clip_rect := _activity_scroll_clip_rect(panel_id)
	var clip := Control.new()
	clip.position = clip_rect.position
	clip.size = clip_rect.size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.z_index = 150
	canvas.add_child(clip)
	return clip

func _activity_rect_visible(rect: Rect2, clip_rect: Rect2) -> bool:
	if clip_rect.size.x <= 0.0 or clip_rect.size.y <= 0.0:
		return true
	return rect.intersects(clip_rect)

func _add_activity_gift_card(position: Vector2, data: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = Vector2(238, 330)
	panel.z_index = 160
	panel.self_modulate = Color(0.08, 0.08, 0.12, 0.76)
	canvas.add_child(panel)
	_add_named_image_to(panel, "image/com/ActivityPanel/ZhaoHuan/wxzh_item_bg", Vector2(18, 18), Vector2(202, 170), TextureRect.STRETCH_SCALE)
	_add_named_image_to(panel, "image/head/105004", Vector2(54, 34), Vector2(130, 130), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_activity_small_label(str(data.get("name", "")), position + Vector2(0, 196), Vector2(238, 28), Color(1.0, 0.88, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 20)
	_add_activity_multiline_label(str(data.get("reward", "")), position + Vector2(20, 228), Vector2(198, 46), Color(0.86, 0.94, 1.0), 15)
	_add_activity_button_like(position + Vector2(57, 278), "%s %s" % [str(data.get("price", "")), str(data.get("state", ""))], Vector2(124, 40))

func _add_activity_reward_icon(parent: Control, position: Vector2, size: Vector2, icon_index: int) -> void:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.texture = _load_indexed_texture(_equipment_icon(icon_index))
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)

func _add_activity_reward_icon_to_canvas(position: Vector2, size: Vector2, icon_index: int) -> void:
	_add_activity_reward_icon_to(canvas, position, size, icon_index)

func _add_activity_reward_icon_to(parent: Control, position: Vector2, size: Vector2, icon_index: int) -> void:
	var image := TextureRect.new()
	image.position = position
	image.size = size
	image.z_index = 210
	image.texture = _load_indexed_texture(_equipment_icon(icon_index))
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)

func _add_activity_button_like(position: Vector2, text: String, size: Vector2 = Vector2(118, 42)) -> void:
	_add_activity_button_like_to(canvas, position, text, size)

func _add_activity_button_like_to(parent: Control, position: Vector2, text: String, size: Vector2 = Vector2(118, 42)) -> void:
	var button := Button.new()
	button.position = position
	button.size = size
	button.z_index = 190
	button.text = text
	button.add_theme_font_size_override("font_size", 17)
	parent.add_child(button)

func _add_activity_progress_bar(position: Vector2, size: Vector2, progress: float) -> void:
	_add_activity_progress_bar_to(canvas, position, size, progress)

func _add_activity_progress_bar_to(parent: Control, position: Vector2, size: Vector2, progress: float) -> void:
	var bg := ColorRect.new()
	bg.position = position
	bg.size = size
	bg.z_index = 180
	bg.color = Color(0.06, 0.07, 0.09, 0.86)
	parent.add_child(bg)
	var fill := ColorRect.new()
	fill.position = position + Vector2(2, 2)
	fill.size = Vector2(max(0.0, size.x - 4.0) * clampf(progress, 0.0, 1.0), max(0.0, size.y - 4.0))
	fill.z_index = 181
	fill.color = Color(0.96, 0.66, 0.18, 0.92)
	parent.add_child(fill)

func _add_activity_red_dot(position: Vector2) -> void:
	var dot := ColorRect.new()
	dot.position = position
	dot.size = Vector2(16, 16)
	dot.z_index = 220
	dot.color = Color(0.92, 0.04, 0.04, 0.95)
	canvas.add_child(dot)

func _add_activity_badge(position: Vector2, text: String, color: Color, size: Vector2 = Vector2(86, 24), font_size: int = 14) -> void:
	_add_activity_badge_to(canvas, position, text, color, size, font_size)

func _add_activity_badge_to(parent: Control, position: Vector2, text: String, color: Color, size: Vector2 = Vector2(86, 24), font_size: int = 14) -> void:
	var bg := ColorRect.new()
	bg.position = position
	bg.size = size
	bg.z_index = 200
	bg.color = color
	parent.add_child(bg)
	_add_activity_small_label_to(parent, text, position, size, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, font_size)

func _add_activity_small_label(text: String, position: Vector2, size: Vector2, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, font_size: int = 14) -> void:
	_add_activity_small_label_to(canvas, text, position, size, color, align, font_size)

func _add_activity_small_label_to(parent: Control, text: String, position: Vector2, size: Vector2, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, font_size: int = 14) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.z_index = 210
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func _add_activity_multiline_label(text: String, position: Vector2, size: Vector2, color: Color, font_size: int = 14) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.z_index = 210
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	canvas.add_child(label)

func _node_label_text(node: Dictionary) -> String:
	return str(node.get("label_text", ""))

func _is_sliced_sprite(node: Dictionary) -> bool:
	var type_name := str(node.get("sprite_type_name", ""))
	if type_name != "" and type_name != "sliced":
		return false
	if type_name == "" and int(node.get("sprite_type", 0)) != 1:
		return false
	var insets: Array = node.get("sprite_cap_insets", [])
	if insets.size() < 4:
		return false
	return float(insets[0]) > 0.0 or float(insets[1]) > 0.0 or float(insets[2]) > 0.0 or float(insets[3]) > 0.0

func _texture_stretch_mode(node: Dictionary) -> TextureRect.StretchMode:
	var type_name := str(node.get("sprite_type_name", "simple"))
	if type_name == "tiled":
		return TextureRect.STRETCH_TILE
	return TextureRect.STRETCH_SCALE

func _apply_nine_patch_margins(nine: NinePatchRect, node: Dictionary) -> void:
	var insets: Array = node.get("sprite_cap_insets", [])
	if insets.size() < 4:
		return
	nine.patch_margin_left = int(round(float(insets[0])))
	nine.patch_margin_top = int(round(float(insets[1])))
	nine.patch_margin_right = int(round(float(insets[2])))
	nine.patch_margin_bottom = int(round(float(insets[3])))

func _add_text_label(parent: Control, node: Dictionary, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.clip_text = true
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", int(node.get("label_font_size", 18)))
	label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	label.horizontal_alignment = _to_horizontal_alignment(int(node.get("label_horizontal_align", 0)))
	label.vertical_alignment = _to_vertical_alignment(int(node.get("label_vertical_align", 0)))
	parent.add_child(label)

func _to_horizontal_alignment(value: int) -> HorizontalAlignment:
	if value == 1:
		return HORIZONTAL_ALIGNMENT_CENTER
	if value == 2:
		return HORIZONTAL_ALIGNMENT_RIGHT
	return HORIZONTAL_ALIGNMENT_LEFT

func _to_vertical_alignment(value: int) -> VerticalAlignment:
	if value == 1:
		return VERTICAL_ALIGNMENT_CENTER
	if value == 2:
		return VERTICAL_ALIGNMENT_BOTTOM
	return VERTICAL_ALIGNMENT_TOP

func _should_skip_node(node: Dictionary) -> bool:
	if not bool(node.get("active", true)):
		return true
	var name := str(node.get("name", ""))
	var texture_path := str(node.get("texture_path", ""))
	var label_text := _node_label_text(node)
	if _should_skip_layout_static_node(name, texture_path, label_text):
		return true
	var parent_index: Variant = node.get("parent_index")
	if parent_index == null and texture_path == "" and name.to_lower().ends_with("pre"):
		return true
	if _should_skip_placeholder_node(name, texture_path, label_text):
		return true
	return false

func _should_skip_layout_static_node(name: String, texture_path: String, label_text: String) -> bool:
	if current_layout == "英雄":
		if name == "tabTxt":
			return true
	if current_layout == "抽卡":
		var keep_names := ["btn_dh", "Background", "img_tip"]
		if name in keep_names and texture_path != "":
			return false
		return true
	if current_layout in ["活动抽卡-循环礼包", "活动抽卡-抽数任务", "活动抽卡-许愿礼包"]:
		if label_text != "":
			return true
		if name in ["Item", "item", "liuguang", "select"] or name.begins_with("JDT_"):
			return true
		if name in ["btn_buy", "btn_qianwang", "submitBtn", "btnLabel", "img_receive", "imgComplete"]:
			return true
	return false

func _should_skip_placeholder_node(name: String, texture_path: String, label_text: String) -> bool:
	if texture_path != "" or label_text != "":
		return false
	if not _uses_runtime_mock_overlay():
		return false
	if name in ["loginBtn", "btn_start", "btnStart"]:
		return false
	var lowered := name.to_lower()
	if lowered.begins_with("btn") or lowered.begins_with("button"):
		return false
	return true

func _uses_runtime_mock_overlay() -> bool:
	return current_layout in [
		"英雄", "背包", "抽卡", "公会", "天空城", "竞技", "战斗",
		"活动抽卡", "活动抽卡-登录领取", "活动抽卡-循环礼包", "活动抽卡-抽数任务", "活动抽卡-许愿礼包",
	]

func _is_clean_prefab_preview_layout() -> bool:
	return current_layout in ["冒险地图顶部", "冒险地图底部"]

func _canvas_center() -> Vector2:
	if canvas.size.x > 0.0 and canvas.size.y > 0.0:
		return canvas.size * 0.5
	return Vector2(440, 310)

func _mock_cocos_position(cocos_position: Vector2, scale: float = 1.0) -> Vector2:
	return _canvas_center() + Vector2(cocos_position.x, -cocos_position.y) * scale

func _node_scale(node: Dictionary) -> Vector2:
	var scale_arr: Array = node.get("scale", [1.0, 1.0])
	if scale_arr.size() < 2:
		return Vector2.ONE
	var scale := Vector2(float(scale_arr[0]), float(scale_arr[1]))
	if is_zero_approx(scale.x):
		scale.x = 1.0
	if is_zero_approx(scale.y):
		scale.y = 1.0
	return scale

func _texture_for_node(name: String) -> String:
	if texture_map.has(name):
		return str(texture_map[name])
	for key in texture_map.keys():
		var key_string := str(key)
		if name.to_lower().contains(key_string.to_lower()):
			return str(texture_map[key])
	return ""

func _load_texture_map() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEXTURE_MAP_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		texture_map = parsed

func _load_layout_manifest() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_MANIFEST_PATH))
	if typeof(parsed) != TYPE_ARRAY:
		return
	for item in parsed:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var label := str(item.get("label", ""))
		var layout_path := str(item.get("layout", ""))
		if label == "" or layout_path == "":
			continue
		layouts[label] = "res://" + layout_path
		layout_stats[label] = item

func _load_equipment_icons() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(EQUIPMENT_ICON_INDEX_PATH))
	if typeof(parsed) == TYPE_ARRAY:
		equipment_icons = parsed

func _load_named_resources() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(NAMED_RESOURCE_INDEX_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		named_resources = parsed

func _load_prefab_node_hints() -> void:
	if not FileAccess.file_exists(PREFAB_NODE_HINTS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PREFAB_NODE_HINTS_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		prefab_node_hints = parsed

func _layout_detail_text(parsed: Dictionary, nodes: Array, stats: Dictionary) -> String:
	var prefab_name := str(parsed.get("prefab", ""))
	var lines := [
		prefab_name,
		"nodes: %d" % nodes.size(),
		"texture nodes: %d" % int(stats.get("texture_nodes", 0)),
	]
	var mask_count := _count_nodes_with_component(nodes, "cc.Mask")
	var scroll_count := _count_nodes_with_component(nodes, "cc.ScrollView")
	if mask_count > 0 or scroll_count > 0:
		lines.append("mask/scroll: %d / %d" % [mask_count, scroll_count])
	var hint_info := _hint_info_for_prefab(prefab_name)
	if not hint_info.is_empty():
		lines.append("")
		lines.append("节点名推断用途:")
		lines.append(_format_hint_counts(hint_info.get("hint_counts", {}), 12))
		var examples := _format_hint_examples(hint_info.get("nodes", []), 8)
		if examples != "":
			lines.append("")
			lines.append("关键节点:")
			lines.append(examples)
	var component_bindings: Array = parsed.get("component_bindings", [])
	var binding_text := _format_component_bindings(component_bindings, 8)
	if binding_text != "":
		lines.append("")
		lines.append("脚本字段绑定:")
		lines.append(binding_text)
	lines.append("")
	lines.append("这是从原始 Cocos Prefab 提取的节点布局预览。当前已尽量关联 SpriteFrame/native 图片；无法自动确认贴图的节点继续显示半透明矩形。节点用途由拼音/缩写推断，仅作辅助，仍需结合源码和坐标确认。")
	return "\n".join(lines)

func _hint_info_for_prefab(prefab_name: String) -> Dictionary:
	var key := prefab_name.get_file()
	if prefab_node_hints.has(key):
		return prefab_node_hints.get(key, {})
	key = key.trim_suffix(".json")
	if prefab_node_hints.has(key):
		return prefab_node_hints.get(key, {})
	return prefab_node_hints.get(current_layout, {})

func _count_nodes_with_component(nodes: Array, component: String) -> int:
	var count := 0
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var component_types: Array = node.get("component_types", [])
		if component in component_types:
			count += 1
	return count

func _format_hint_counts(counts: Dictionary, limit: int) -> String:
	var pairs: Array = []
	for key in counts.keys():
		pairs.append({"name": str(key), "count": int(counts[key])})
	pairs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.count) > int(b.count)
	)
	var parts: Array[String] = []
	for i in min(limit, pairs.size()):
		parts.append("%s %d" % [pairs[i].name, int(pairs[i].count)])
	return " / ".join(parts)

func _format_hint_examples(nodes: Array, limit: int) -> String:
	var wanted := ["按钮", "页签", "入口", "兑换", "召唤", "英雄", "Spine/特效", "红点", "内容容器"]
	var lines: Array[String] = []
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var hints: Array = node.get("hints", [])
		if hints.is_empty():
			continue
		var include := false
		for hint in hints:
			if str(hint) in wanted:
				include = true
				break
		if not include:
			continue
		lines.append("%s => %s" % [str(node.get("name", "")), "/".join(hints)])
		if lines.size() >= limit:
			break
	return "\n".join(lines)

func _format_component_bindings(bindings: Array, limit: int) -> String:
	var lines: Array[String] = []
	for binding in bindings:
		if typeof(binding) != TYPE_DICTIONARY:
			continue
		var fields: Dictionary = binding.get("fields", {})
		if fields.is_empty():
			continue
		var parts: Array[String] = []
		for field in fields.keys():
			var target: Variant = fields[field]
			if typeof(target) != TYPE_DICTIONARY:
				continue
			parts.append("%s->%s" % [str(field), str(target.get("name", ""))])
			if parts.size() >= 5:
				break
		if parts.is_empty():
			continue
		lines.append("%s: %s" % [str(binding.get("owner_name", "")), " / ".join(parts)])
		if lines.size() >= limit:
			break
	return "\n".join(lines)

func _requested_layout() -> String:
	var scene_args := Navigation.consume_scene_args()
	var layout := str(scene_args.get("layout", ""))
	if layout != "":
		return layout
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	var index := args.find("--prefab-layout")
	if index >= 0 and index + 1 < args.size():
		return str(args[index + 1])
	return ""

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _load_node_texture(path: String, node: Dictionary, crop_sprite: bool = true) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var sprite_rect: Array = node.get("sprite_rect", [])
	if crop_sprite and sprite_rect.size() == 4:
		var crop := Rect2i(
			int(sprite_rect[0]),
			int(sprite_rect[1]),
			int(sprite_rect[2]),
			int(sprite_rect[3])
		)
		var original_size := _arr_to_vec2i(node.get("sprite_original_size", []))
		var offset := _arr_to_vec2(node.get("sprite_offset", []))
		return _make_sprite_frame_texture(image, crop, bool(node.get("sprite_rotated", false)), original_size, offset)
	return ImageTexture.create_from_image(image)

func _make_sprite_frame_texture(atlas: Image, region: Rect2i, rotated := false, original_size := Vector2i.ZERO, offset := Vector2.ZERO) -> Texture2D:
	var crop := region
	if rotated:
		crop = Rect2i(region.position, Vector2i(region.size.y, region.size.x))
	if crop.size.x <= 0 or crop.size.y <= 0 or not Rect2i(Vector2i.ZERO, atlas.get_size()).encloses(crop):
		return ImageTexture.create_from_image(atlas)
	var frame := atlas.get_region(crop)
	if rotated:
		frame.rotate_90(COUNTERCLOCKWISE)
	if original_size.x <= 0 or original_size.y <= 0 or original_size == frame.get_size():
		return ImageTexture.create_from_image(frame)
	frame.convert(Image.FORMAT_RGBA8)
	var canvas := Image.create_empty(original_size.x, original_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	var paste_x := int(round((float(original_size.x - frame.get_width()) * 0.5) + offset.x))
	var paste_y := int(round((float(original_size.y - frame.get_height()) * 0.5) - offset.y))
	canvas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(paste_x, paste_y))
	return ImageTexture.create_from_image(canvas)

func _is_login_layout() -> bool:
	return current_layout == "登录面板" or current_layout == "登录选服"

func _is_action_node(name: String) -> bool:
	return name in ["loginBtn", "btn_start", "btnStart"]

func _build_prefab_mask_clips(nodes: Array) -> void:
	prefab_mask_clips.clear()
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var component_types: Array = node.get("component_types", [])
		if not "cc.Mask" in component_types:
			continue
		var bounds := _prefab_node_rect(node)
		var clip := Control.new()
		clip.position = bounds.position
		clip.size = bounds.size
		clip.clip_contents = true
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.z_index = 20
		canvas.add_child(clip)
		prefab_mask_clips[_dict_int(node, "index", -1)] = clip

func _build_inferred_scrollview_masks(nodes: Array) -> void:
	prefab_inferred_mask_by_node.clear()
	var views: Array = []
	var contents: Array = []
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var name := str(node.get("name", "")).to_lower()
		var component_types: Array = node.get("component_types", [])
		if name == "view" and "cc.Mask" in component_types:
			views.append(node)
		elif name == "content" and "cc.Layout" in component_types:
			contents.append(node)
	for content in contents:
		if _dict_int(content, "parent_index", -1) >= 0:
			continue
		var view := _nearest_scrollview_mask(content, views)
		if view.is_empty():
			continue
		var view_index := _dict_int(view, "index", -1)
		var content_index := _dict_int(content, "index", -1)
		if view_index < 0 or content_index < 0:
			continue
		prefab_inferred_mask_by_node[content_index] = view_index
		for child in nodes:
			if typeof(child) != TYPE_DICTIONARY:
				continue
			if _is_descendant_of_node(child, content_index):
				var child_index := _dict_int(child, "index", -1)
				if child_index >= 0:
					prefab_inferred_mask_by_node[child_index] = view_index

func _nearest_scrollview_mask(content: Dictionary, views: Array) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	var content_rect := _prefab_node_rect(content)
	var content_center := content_rect.get_center()
	var content_size := content_rect.size
	for view in views:
		if typeof(view) != TYPE_DICTIONARY:
			continue
		var view_index := _dict_int(view, "index", -1)
		if not prefab_mask_clips.has(view_index):
			continue
		var view_rect := _prefab_node_rect(view)
		var view_size := view_rect.size
		var similar_width: bool = abs(view_size.x - content_size.x) <= max(20.0, view_size.x * 0.08)
		var similar_height: bool = abs(view_size.y - content_size.y) <= max(20.0, view_size.y * 0.08)
		if not (similar_width or similar_height):
			continue
		var distance: float = content_center.distance_to(view_rect.get_center())
		if distance < best_distance:
			best_distance = distance
			best = view
	return best

func _is_descendant_of_node(node: Dictionary, ancestor_index: int) -> bool:
	var parent_index := _dict_int(node, "parent_index", -1)
	var guard := 0
	while parent_index >= 0 and guard < 256:
		if parent_index == ancestor_index:
			return true
		if not prefab_nodes_by_index.has(parent_index):
			return false
		var parent_node: Dictionary = prefab_nodes_by_index[parent_index]
		parent_index = _dict_int(parent_node, "parent_index", -1)
		guard += 1
	return false

func _index_prefab_nodes(nodes: Array) -> void:
	prefab_nodes_by_index.clear()
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var index := _dict_int(node, "index", -1)
		if index >= 0:
			prefab_nodes_by_index[index] = node

func _build_prefab_mask_parent_map(nodes: Array) -> void:
	prefab_mask_parent_by_node.clear()
	for node in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var node_index := _dict_int(node, "index", -1)
		if prefab_inferred_mask_by_node.has(node_index):
			prefab_mask_parent_by_node[node_index] = prefab_inferred_mask_by_node[node_index]
			continue
		var mask_index := _nearest_mask_parent_index(node)
		if node_index >= 0 and mask_index >= 0:
			prefab_mask_parent_by_node[node_index] = mask_index

func _nearest_mask_parent_index(node: Dictionary) -> int:
	var parent_index := _dict_int(node, "parent_index", -1)
	var guard := 0
	while parent_index >= 0 and guard < 256:
		if prefab_mask_clips.has(parent_index):
			return parent_index
		if not prefab_nodes_by_index.has(parent_index):
			return -1
		var parent_node: Dictionary = prefab_nodes_by_index[parent_index]
		parent_index = _dict_int(parent_node, "parent_index", -1)
		guard += 1
	return -1

func _prefab_parent_for_node(node: Dictionary) -> Control:
	var node_index := _dict_int(node, "index", -1)
	if node_index >= 0 and prefab_mask_parent_by_node.has(node_index):
		var mask_index: int = prefab_mask_parent_by_node[node_index]
		if prefab_mask_clips.has(mask_index):
			return prefab_mask_clips[mask_index]
	return canvas

func _dict_int(data: Dictionary, key: String, fallback: int) -> int:
	var value: Variant = data.get(key, fallback)
	if value == null:
		return fallback
	return int(value)

func _prefab_node_rect(node: Dictionary) -> Rect2:
	var screen_rect: Array = node.get("screen_rect", [])
	if screen_rect.size() >= 4:
		var design_pos := Vector2(float(screen_rect[0]), float(screen_rect[1]))
		var design_size := Vector2(float(screen_rect[2]), float(screen_rect[3]))
		return Rect2(_canvas_design_origin() + design_pos, design_size)
	var size_arr: Array = node.get("size", [80, 36])
	var pos_arr: Array = node.get("global_position", node.get("position", [0, 0]))
	var anchor_arr: Array = node.get("anchor", [0.5, 0.5])
	var size := Vector2(float(size_arr[0]), float(size_arr[1]))
	var pos := Vector2(float(pos_arr[0]), -float(pos_arr[1]))
	var anchor := Vector2(float(anchor_arr[0]), 1.0 - float(anchor_arr[1]))
	return Rect2(_canvas_center() + pos - Vector2(size.x * anchor.x, size.y * anchor.y), size)

func _canvas_design_origin() -> Vector2:
	return _canvas_center() - Vector2(640.0, 360.0)

func _sorted_nodes(nodes: Array) -> Array:
	var sorted := nodes.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa := _draw_priority(str(a.get("name", "")), a)
		var pb := _draw_priority(str(b.get("name", "")), b)
		if pa == pb:
			return int(a.get("index", 0)) < int(b.get("index", 0))
		return pa < pb
	)
	return sorted

func _arr_to_vec2(value: Variant) -> Vector2:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _draw_priority(name: String, node: Dictionary) -> int:
	var lowered := name.to_lower()
	var size_arr: Array = node.get("size", [0, 0])
	var area := float(size_arr[0]) * float(size_arr[1]) if size_arr.size() >= 2 else 0.0
	if lowered in ["bg", "node_de"] or area > 800000.0:
		return 0
	if lowered.contains("alert") or lowered.contains("panel") or lowered.contains("frame"):
		return 10
	if lowered == "wenzidi" or lowered.contains("di") or lowered.contains("background"):
		return 20
	if lowered.contains("logo"):
		return 40
	if lowered.contains("btn") or lowered == "button":
		return 70
	if lowered.contains("label") or lowered.begins_with("txt") or lowered.begins_with("lbl"):
		return 90
	return 50

func _color_for_name(name: String) -> Color:
	if name.contains("btn") or name.contains("Btn"):
		return Color(0.35, 0.58, 1.0, 0.72)
	if name.contains("icon"):
		return Color(0.35, 1.0, 0.62, 0.70)
	if name.contains("bg") or name.contains("BG"):
		return Color(0.8, 0.62, 0.28, 0.48)
	if name.contains("panel") or name.contains("Panel"):
		return Color(0.8, 0.45, 0.95, 0.55)
	return Color(0.75, 0.78, 0.88, 0.42)

func _capture_if_requested() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if not "--capture-prefab-preview" in args:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var index := args.find("--capture-prefab-preview")
	var output_path := "user://prefab_preview.png"
	if index >= 0 and index + 1 < args.size():
		output_path = args[index + 1]
	var image := get_viewport().get_texture().get_image()
	image.save_png(output_path)
	get_tree().quit()
