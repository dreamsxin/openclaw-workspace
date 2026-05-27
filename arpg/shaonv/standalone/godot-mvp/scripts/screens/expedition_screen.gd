# UTF-8 source. ExpeditionMainView / ExpeditionMapView reconstruction for the real dust exploration main scene.
extends RefCounted

const BAKED_SPINE_CANVAS := preload("res://scripts/spine_baked_preview_canvas.gd")
const UI_EXP_BG := "res://assets/ui/background/expedition_bg_02.png"
const UI_EXP_BTN_DISPATCH := "res://assets/ui/expedition/expedition_btn_02.png"
const UI_EXP_BTN_HERO := "res://assets/ui/expedition/expedition_btn_03.png"
const UI_EXP_BTN_MARCH := "res://assets/ui/expedition/expedition_btn_04.png"
const UI_EXP_BTN_FIGHT := "res://assets/ui/expedition/expedition_btn_05.png"
const UI_EXP_BTN_STRONGER := "res://assets/ui/expedition/expedition_btn_06.png"
const UI_EXP_CROSS_REWARD := "res://assets/ui/expedition/expedition_img_01.png"
const UI_EXP_MAP := "res://assets/ui/expedition/expedition_img_02.png"
const UI_EXP_MAP_RING := "res://assets/ui/expedition/expedition_img_03.png"
const UI_EXP_REWARD := "res://assets/ui/expedition/expedition_img_05.png"
const UI_EXP_HOOK_TIME := "res://assets/ui/expedition/expedition_img_06.png"
const UI_EXP_LIMIT := "res://assets/ui/expedition/expedition_img_21.png"
const UI_EXP_CHAPTER_TAG := "res://assets/ui/expedition/expedition_img_22.png"
const UI_EXP_REWARD_TIP := "res://assets/ui/expedition/expedition_img_24.png"
const UI_EXP_REWARD_ICON := "res://assets/ui/expedition/goods_200021.png"
const UI_EXP_AFKMAP_BG := "res://assets/ui/expedition/afkmap/worldmap04_main_view.png"
const UI_EXP_WORLD_TILE_BASE := "res://assets/ui/expedition/worldmap/"
const UI_COMMON_BG_08 := "res://assets/ui/background/common_bg_08.png"
const UI_COMMON_BTN_16 := "res://assets/ui/common/common_btn_16.png"
const UI_COMMON_BTN_17 := "res://assets/ui/common/common_btn_17.png"
const UI_EXP_DETAIL_COVER := "res://assets/ui/expedition/expedition_img_10.png"
const CHAPTER_META_PATH := "res://data/chapter_meta_mvp.json"
const EXPEDITION_SCREENSHOT_HERO_ID := 240101
const EXPEDITION_SCREENSHOT_HERO_SPINE := "hero_053"
const EXPEDITION_SCREENSHOT_HEROQ_S01_BAKED := "res://assets/spine/all_export/HeroQ__hero_053q_s01/HeroQ__hero_053q_s01.baked.json"
const EXPEDITION_HERO_S02_BAKED := "res://assets/spine/all_export/Hero__hero_053_s02/Hero__hero_053_s02.baked.json"
const EXPEDITION_HERO_S02H_BAKED := "res://assets/spine/all_export/Hero__hero_053_s02h/Hero__hero_053_s02h.baked.json"
const CONFIRMED_WORLDMAP_ICON_KEYS := {
	"map_pic_1001": true
}
const MAP_CONTENT_SIZE := Vector2(4096, 4096)
const MAP_VIEWPORT_POS := Vector2(104, 74)
const MAP_VIEWPORT_SIZE := Vector2(988, 590)
const MAP_COORD_ORIGIN := Vector2(1876, 1844)
const MAIN_MAP_POS := Vector2(1056, 23)
const MAIN_MAP_SIZE := Vector2(160, 160)
const MAIN_MAP_RING_SIZE := Vector2(180, 180)
const MAIN_CROSS_REWARD_POS := Vector2(64, 100)
const MAIN_CROSS_REWARD_SIZE := Vector2(352, 70)
const MAP_NODE_SIZE := Vector2(168, 180)
const WORLDMAP_ID_BASE := 1000
const MAIN_WORLD_FOCUS_OFFSET := Vector2(360, 438)
const MAIN_AFK_PATH_POINTS := [
	Vector2(612, 366),
	Vector2(668, 332),
	Vector2(720, 352),
	Vector2(778, 322),
	Vector2(836, 346)
]
const WORLDMAP_NODE_DEFAULTS := {
	1001: {
		"fallback_name": "雾港学院",
		"map_pic": "map_pic_1001",
		"map_move_hint": "学院驻扎点",
		"vehicle_tip": "点击进入载具巡逻",
		"confirm_text": "前往挑战",
		"fallback_dec": "海雾沿着学院旧墙弥漫，这里是尘世探秘最早开放的驻扎区域。"
	},
	1002: {
		"fallback_name": "千星都会",
		"map_pic": "map_pic_1002",
		"map_move_hint": "都会待命",
		"vehicle_tip": "点击进入巡航载具",
		"confirm_text": "已通关",
		"fallback_dec": "星灯贯穿城市主街，探索队会在这里整理补给后继续深入。"
	},
	1003: {
		"fallback_name": "逐月庭院",
		"map_pic": "map_pic_1003",
		"map_move_hint": "庭院驻扎",
		"vehicle_tip": "点击进入庭院巡礼",
		"confirm_text": "前往章节",
		"fallback_dec": "月庭高墙与回廊层层展开，适合作为中继据点与角色休整点。"
	},
	1004: {
		"fallback_name": "潮汐前哨",
		"map_pic": "map_pic_1004",
		"map_move_hint": "前哨待命",
		"vehicle_tip": "点击进入前哨机动",
		"confirm_text": "前往章节",
		"fallback_dec": "潮汐风口附近的前哨区域仍有未清理敌影，推进时会更谨慎。"
	},
	1005: {
		"fallback_name": "回音长街",
		"map_pic": "map_pic_1005",
		"map_move_hint": "街区驻扎",
		"vehicle_tip": "点击进入街区穿梭",
		"confirm_text": "前往章节",
		"fallback_dec": "长街结构更复杂，探索队会在这里短暂停留后再选择路线。"
	},
	1006: {
		"fallback_name": "鎏金宫",
		"map_pic": "map_pic_1006",
		"map_move_hint": "宫廷待命",
		"vehicle_tip": "点击进入宫廷座驾",
		"confirm_text": "前往章节",
		"fallback_dec": "进入鎏金宫前需要整备阵容，这里更接近章节挑战前的集结点。"
	},
	1007: {
		"fallback_name": "流光别院",
		"map_pic": "map_pic_1007",
		"map_move_hint": "区域待开放",
		"vehicle_tip": "载具逻辑待开放",
		"confirm_text": "待实装",
		"fallback_dec": "当前只闭合到地图点位，章节文案与真实图标仍待继续追源。"
	},
	1008: {
		"fallback_name": "灰烬古城",
		"map_pic": "map_pic_1008",
		"map_move_hint": "区域待开放",
		"vehicle_tip": "载具逻辑待开放",
		"confirm_text": "待实装",
		"fallback_dec": "当前只闭合到地图点位，章节文案与真实图标仍待继续追源。"
	},
	1009: {
		"fallback_name": "遥星湾",
		"map_pic": "map_pic_1009",
		"map_move_hint": "区域待开放",
		"vehicle_tip": "载具逻辑待开放",
		"confirm_text": "待实装",
		"fallback_dec": "当前只闭合到地图点位，章节文案与真实图标仍待继续追源。"
	},
	1010: {
		"fallback_name": "月蚀焰地",
		"map_pic": "map_pic_1010",
		"map_move_hint": "区域待开放",
		"vehicle_tip": "载具逻辑待开放",
		"confirm_text": "待实装",
		"fallback_dec": "当前只闭合到地图点位，章节文案与真实图标仍待继续追源。"
	}
}

var app
var _map_drag_origin := Vector2.ZERO
var _map_content_origin := Vector2.ZERO
var _map_detail_node: Control
var _chapter_meta := {}


func _init(app_ref) -> void:
	app = app_ref
	_chapter_meta = _read_local_json(CHAPTER_META_PATH)


func _read_local_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


func show_expedition_main() -> void:
	app.current_view = "expedition_main"
	app._clear("尘世探秘")
	_draw_main_afk_scene()
	_draw_top_back()
	_draw_map_zone()
	_draw_bottom_actions()


func _draw_top_back() -> void:
	app._add_action_button("返回", Vector2(42, 18), app._show_home, Vector2(96, 38), app.UI_COMMON_BTN_WHITE)


func _draw_main_afk_scene() -> void:
	var scene := Control.new()
	scene.position = Vector2.ZERO
	scene.size = Vector2(1280, 720)
	scene.clip_contents = true
	app._view_container().add_child(scene)

	# ExpeditionMainView is the UI overlay; the underlying scene is AFKMap WorldMap04 from manifest assets.
	_draw_image_in(scene, UI_EXP_AFKMAP_BG, Vector2.ZERO, scene.size, true, Color(1, 1, 1, 1))
	scene.add_child(app._panel(Vector2.ZERO, scene.size, Color(0.02, 0.03, 0.05, 0.04)))
	_draw_main_afk_move_layer(scene)


func _add_scene_backdrop(parent: Control) -> void:
	parent.add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.47, 0.53, 0.63, 1.0)))
	_add_iso_polygon(parent, [Vector2(0, 108), Vector2(348, -42), Vector2(718, 126), Vector2(346, 292)], Color(0.58, 0.55, 0.64))
	_add_iso_polygon(parent, [Vector2(710, 74), Vector2(1102, -26), Vector2(1354, 90), Vector2(948, 252)], Color(0.66, 0.63, 0.70))
	for i in range(9):
		var y := 84.0 + float(i) * 42.0
		var mist: ColorRect = app._panel(Vector2(0, y), Vector2(1280, 14), Color(0.84, 0.88, 0.95, 0.07))
		parent.add_child(mist)


func _add_scene_building(parent: Control, pos: Vector2, size: Vector2, wall_color: Color, roof_color: Color) -> void:
	var roof_top := [
		pos + Vector2(38, 18),
		pos + Vector2(size.x - 82, -20),
		pos + Vector2(size.x - 18, 18),
		pos + Vector2(82, 60)
	]
	_add_iso_polygon(parent, roof_top, roof_color)
	_add_iso_polygon(parent, [
		pos + Vector2(82, 60),
		pos + Vector2(size.x - 18, 18),
		pos + Vector2(size.x - 18, 86),
		pos + Vector2(82, 126)
	], wall_color)
	_add_iso_polygon(parent, [
		pos + Vector2(38, 18),
		pos + Vector2(82, 60),
		pos + Vector2(82, 126),
		pos + Vector2(38, 82)
	], Color(wall_color.r * 0.72, wall_color.g * 0.72, wall_color.b * 0.72, 1.0))
	for i in range(5):
		var pillar_x := pos.x + 112.0 + float(i) * 68.0
		var pillar: ColorRect = app._panel(Vector2(pillar_x, pos.y + 55), Vector2(10, 88), Color(0.76, 0.27, 0.20, 1.0))
		parent.add_child(pillar)
	_add_iso_polygon(parent, [
		pos + Vector2(44, 28),
		pos + Vector2(size.x - 78, -8),
		pos + Vector2(size.x - 36, 14),
		pos + Vector2(82, 52)
	], Color(0.84, 0.38, 0.30, 0.92))


func _add_scene_stone_platform(parent: Control) -> void:
	_add_iso_polygon(parent, [Vector2(112, 292), Vector2(608, 78), Vector2(972, 248), Vector2(460, 522)], Color(0.70, 0.69, 0.74))
	_add_iso_polygon(parent, [Vector2(460, 522), Vector2(972, 248), Vector2(972, 326), Vector2(462, 600)], Color(0.35, 0.37, 0.45))
	_add_iso_polygon(parent, [Vector2(112, 292), Vector2(460, 522), Vector2(462, 600), Vector2(82, 372)], Color(0.42, 0.44, 0.52))
	for i in range(7):
		var start := Vector2(194 + i * 74, 276 - i * 12)
		_add_iso_line(parent, start, start + Vector2(360, 170), Color(0.88, 0.86, 0.86, 0.26), 2.0)
	for i in range(6):
		var start := Vector2(240 + i * 88, 132 + i * 42)
		_add_iso_line(parent, start, start + Vector2(-276, 148), Color(0.36, 0.36, 0.42, 0.20), 2.0)
	_add_iso_polygon(parent, [Vector2(390, 370), Vector2(552, 300), Vector2(682, 362), Vector2(522, 444)], Color(0.45, 0.51, 0.59, 0.56))
	_add_iso_polygon(parent, [Vector2(430, 374), Vector2(552, 322), Vector2(640, 364), Vector2(520, 426)], Color(0.70, 0.72, 0.76, 0.62))


func _add_scene_bridge_and_trees(parent: Control) -> void:
	_add_iso_polygon(parent, [Vector2(48, 426), Vector2(224, 334), Vector2(324, 378), Vector2(146, 482)], Color(0.29, 0.34, 0.42))
	_add_iso_polygon(parent, [Vector2(30, 456), Vector2(146, 482), Vector2(146, 530), Vector2(0, 492)], Color(0.20, 0.25, 0.34))
	_add_scene_tree(parent, Vector2(116, 318), Color(0.61, 0.50, 0.82))
	_add_scene_tree(parent, Vector2(238, 346), Color(0.20, 0.42, 0.33))
	_add_scene_tree(parent, Vector2(960, 332), Color(0.16, 0.44, 0.34))
	_add_scene_tree(parent, Vector2(1070, 286), Color(0.19, 0.50, 0.40))
	for p in [Vector2(196, 304), Vector2(284, 280), Vector2(690, 238), Vector2(830, 250)]:
		parent.add_child(app._panel(p, Vector2(10, 76), Color(0.72, 0.19, 0.15, 0.96)))
		parent.add_child(app._panel(p + Vector2(-20, 8), Vector2(58, 8), Color(0.84, 0.24, 0.18, 0.90)))


func _add_scene_tree(parent: Control, pos: Vector2, foliage: Color) -> void:
	parent.add_child(app._panel(pos + Vector2(18, 62), Vector2(18, 70), Color(0.31, 0.20, 0.14, 0.92)))
	_add_iso_polygon(parent, [pos + Vector2(24, 4), pos + Vector2(74, 48), pos + Vector2(42, 92), pos + Vector2(-22, 52)], foliage)
	_add_iso_polygon(parent, [pos + Vector2(36, 28), pos + Vector2(92, 68), pos + Vector2(50, 118), pos + Vector2(-8, 76)], Color(foliage.r * 0.78, foliage.g * 0.88, foliage.b * 0.82, 1.0))


func _draw_main_afk_move_layer(parent: Control) -> void:
	var hero: Dictionary = _expedition_scene_hero()
	var runner := Control.new()
	runner.position = MAIN_AFK_PATH_POINTS[0]
	runner.size = Vector2(216, 214)
	parent.add_child(runner)

	_add_scene_vehicle_base(runner, Vector2(8, 132))
	_add_scene_shadow_oval(runner, Vector2(32, 146), 52.0, 16.0, Color(0.02, 0.02, 0.03, 0.22))
	_add_scene_hero_actor(runner, hero, Vector2(-32, -34), Vector2(138, 170), "run")
	var vehicle_tip := _worldmap_default_meta(_current_expedition_chapter().get("chapter_id", 1001))
	var tip_bg: ColorRect = app._panel(Vector2(94, 18), Vector2(112, 26), Color(0.08, 0.09, 0.12, 0.72))
	runner.add_child(tip_bg)
	var tip_label: Label = app._label(str(vehicle_tip.get("vehicle_tip", "点击进入载具巡逻")), 11, HORIZONTAL_ALIGNMENT_CENTER)
	tip_label.position = Vector2(98, 21)
	tip_label.size = Vector2(104, 20)
	tip_label.modulate = Color(1.0, 0.95, 0.82)
	runner.add_child(tip_label)
	var label_bg: ColorRect = app._panel(Vector2(-26, 158), Vector2(132, 30), Color(0.05, 0.06, 0.08, 0.62))
	runner.add_child(label_bg)
	var label: Label = app._label("当前驻扎", 14, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = Vector2(-18, 161)
	label.size = Vector2(116, 22)
	label.modulate = Color(1.0, 0.95, 0.80)
	runner.add_child(label)
	var enter_badge: ColorRect = app._panel(Vector2(82, 112), Vector2(46, 18), Color(0.10, 0.10, 0.12, 0.72))
	runner.add_child(enter_badge)
	var enter_text: Label = app._label("巡逻", 10, HORIZONTAL_ALIGNMENT_CENTER)
	enter_text.position = Vector2(84, 111)
	enter_text.size = Vector2(42, 18)
	enter_text.modulate = Color(0.98, 0.94, 0.82)
	runner.add_child(enter_text)

	var click_area := Button.new()
	click_area.text = ""
	click_area.flat = true
	click_area.focus_mode = Control.FOCUS_NONE
	click_area.position = Vector2(-24, 8)
	click_area.size = Vector2(230, 184)
	click_area.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	click_area.modulate = Color(1, 1, 1, 0.01)
	click_area.pressed.connect(_open_current_map_detail_from_main)
	runner.add_child(click_area)

	var tween := runner.create_tween()
	tween.set_loops()
	for i in range(1, MAIN_AFK_PATH_POINTS.size()):
		tween.tween_property(runner, "position", MAIN_AFK_PATH_POINTS[i], 0.82).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.25)
	for i in range(MAIN_AFK_PATH_POINTS.size() - 2, -1, -1):
		tween.tween_property(runner, "position", MAIN_AFK_PATH_POINTS[i], 0.82).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.35)


func _add_scene_vehicle_base(parent: Control, pos: Vector2) -> void:
	_add_iso_polygon(parent, [
		pos + Vector2(8, 24),
		pos + Vector2(92, 0),
		pos + Vector2(154, 22),
		pos + Vector2(70, 50)
	], Color(0.24, 0.28, 0.36, 0.70))
	_add_iso_polygon(parent, [
		pos + Vector2(18, 34),
		pos + Vector2(70, 18),
		pos + Vector2(108, 30),
		pos + Vector2(58, 46)
	], Color(0.60, 0.52, 0.32, 0.86))
	parent.add_child(app._panel(pos + Vector2(48, 2), Vector2(5, 30), Color(0.67, 0.48, 0.24, 0.92)))
	parent.add_child(app._panel(pos + Vector2(110, 18), Vector2(20, 5), Color(0.78, 0.62, 0.28, 0.94)))


func _add_scene_shadow_oval(parent: Control, center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	var shadow := Polygon2D.new()
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	shadow.polygon = points
	shadow.color = color
	parent.add_child(shadow)


func _add_scene_hero_actor(parent: Control, hero: Dictionary, pos: Vector2, draw_size: Vector2, preferred_clip := "") -> void:
	for candidate in _afk_hero_baked_candidates(hero, preferred_clip):
		var baked_path := str(candidate.get("baked", ""))
		if baked_path.is_empty() or not FileAccess.file_exists(baked_path):
			continue
		var canvas: Control = BAKED_SPINE_CANVAS.new()
		canvas.position = pos
		canvas.size = draw_size
		canvas.modulate = Color(1, 1, 1, 0.98)
		parent.add_child(canvas)
		canvas.set_baked_path(baked_path, str(candidate.get("clip", preferred_clip if not preferred_clip.is_empty() else "wait")))
		return
	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		var spine_base_path := "res://%s" % resource_path.replace("Art/Spine", "assets/spine")
		var godot_path := "%s.png" % spine_base_path
		if FileAccess.file_exists(godot_path):
			_draw_image_in(parent, godot_path, pos, draw_size, false, Color(1, 1, 1, 0.98))
			return
	var portrait: Control = app._draw_hero_thumb(hero, pos + Vector2(18, 20), draw_size - Vector2(36, 42), Color(1, 1, 1, 0.96))
	if portrait != null:
		_reparent_to(portrait, parent)


func _afk_hero_baked_candidates(hero: Dictionary, preferred_clip := "") -> Array:
	var candidates: Array = []
	var spine_key := str(hero.get("spine", "")).strip_edges()
	if spine_key.is_empty():
		return candidates
	if spine_key == EXPEDITION_SCREENSHOT_HERO_SPINE:
		var variant := _preferred_expedition_baked_variant()
		var main_clip := str(variant.get("main_clip", "standby"))
		var map_clip := str(variant.get("map_clip", "standby"))
		var selected_clip := preferred_clip if not preferred_clip.is_empty() else map_clip
		candidates.append({
			"baked": str(variant.get("baked", EXPEDITION_SCREENSHOT_HEROQ_S01_BAKED)),
			"clip": selected_clip
		})
		for fallback in _expedition_baked_variant_fallbacks():
			if str(fallback.get("baked", "")) == str(variant.get("baked", "")):
				continue
			var fallback_main_clip := str(fallback.get("main_clip", "wait"))
			var fallback_map_clip := str(fallback.get("map_clip", fallback_main_clip))
			candidates.append({
				"baked": str(fallback.get("baked", "")),
				"clip": preferred_clip if not preferred_clip.is_empty() else fallback_map_clip
			})
	var home_baked := "res://assets/spine/%sh/%sh.baked.json" % [spine_key, spine_key]
	var base_baked := "res://assets/spine/%s/%s.baked.json" % [spine_key, spine_key]
	candidates.append({"baked": home_baked, "clip": "wait"})
	candidates.append({"baked": base_baked, "clip": "wait"})
	return candidates


func _expedition_baked_variant_fallbacks() -> Array:
	return [
		{
			"id": "heroq_s01",
			"baked": EXPEDITION_SCREENSHOT_HEROQ_S01_BAKED,
			"main_clip": "run",
			"map_clip": "standby"
		},
		{
			"id": "hero_s02h",
			"baked": EXPEDITION_HERO_S02H_BAKED,
			"main_clip": "wait",
			"map_clip": "wait"
		},
		{
			"id": "hero_s02",
			"baked": EXPEDITION_HERO_S02_BAKED,
			"main_clip": "wait",
			"map_clip": "wait"
		}
	]


func _preferred_expedition_baked_variant() -> Dictionary:
	var requested := OS.get_environment("SHAONV_MVP_EXPEDITION_HERO_VARIANT").strip_edges().to_lower()
	for item in _expedition_baked_variant_fallbacks():
		if requested == str(item.get("id", "")):
			return item
	# Default to the restored hero_s02h variant first: it now comes from the
	# original Hero spine bundles we recovered from local YooAsset caches and is
	# a closer match for the static expedition hub presentation than HeroQ run.
	return _expedition_baked_variant_fallbacks()[1]


func _expedition_scene_hero() -> Dictionary:
	var screenshot_hero: Dictionary = app._hero_by_id(EXPEDITION_SCREENSHOT_HERO_ID)
	if not screenshot_hero.is_empty():
		return screenshot_hero
	return app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))


func _add_scene_move_dot(parent: Control, point: Vector2) -> void:
	var dot: ColorRect = app._panel(point - Vector2(5, 5), Vector2(10, 10), Color(1.0, 0.84, 0.36, 0.90))
	parent.add_child(dot)
	var glow: ColorRect = app._panel(point - Vector2(13, 13), Vector2(26, 26), Color(1.0, 0.78, 0.28, 0.16))
	parent.add_child(glow)


func _add_iso_polygon(parent: Control, points: Array, color: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	var packed := PackedVector2Array()
	for point in points:
		packed.append(point)
	polygon.polygon = packed
	polygon.color = color
	parent.add_child(polygon)
	return polygon


func _add_iso_line(parent: Control, from: Vector2, to: Vector2, color: Color, width: float) -> Line2D:
	var line := Line2D.new()
	line.points = PackedVector2Array([from, to])
	line.default_color = color
	line.width = width
	parent.add_child(line)
	return line


func _draw_main_world_scene() -> void:
	var scene_clip := Control.new()
	scene_clip.position = Vector2.ZERO
	scene_clip.size = Vector2(1280, 720)
	scene_clip.clip_contents = true
	app._view_container().add_child(scene_clip)

	var content := Control.new()
	content.position = _main_scene_content_position()
	content.size = MAP_CONTENT_SIZE
	scene_clip.add_child(content)

	var scene_chunk := Control.new()
	scene_chunk.position = Vector2.ZERO
	scene_chunk.size = MAP_CONTENT_SIZE
	content.add_child(scene_chunk)
	_draw_world_tiles(scene_chunk)

	var scene_shadow: ColorRect = app._panel(Vector2.ZERO, MAP_CONTENT_SIZE, Color(0.01, 0.01, 0.02, 0.08))
	content.add_child(scene_shadow)

	var current_pos := _current_map_node_position()
	var hero: Dictionary = app._hero_by_id(int(app.save.get("selected_hero_id", app.DEFAULT_HERO_ID)))
	var pulse: TextureRect = _draw_image_in(content, UI_EXP_MAP_RING, current_pos - Vector2(78, 78), Vector2(156, 156), false, Color(1.0, 0.95, 0.80, 0.28))
	if pulse != null:
		var tween := pulse.create_tween()
		tween.set_loops()
		tween.tween_property(pulse, "scale", Vector2(1.06, 1.06), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(pulse, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var portrait: Control = app._draw_hero_round_thumb(hero, current_pos - Vector2(42, 118), Vector2(84, 84), Color(1, 1, 1, 0.98))
	if portrait != null:
		_reparent_to(portrait, content)

	var chapter_icon_path: String = _world_icon_path(_current_expedition_chapter().get("chapter_id", WORLDMAP_ID_BASE + 1))
	if not chapter_icon_path.is_empty():
		_draw_image_in(content, chapter_icon_path, current_pos - Vector2(56, 166), Vector2(112, 112), false, Color(1, 1, 1, 0.94))

	var marker := ColorRect.new()
	marker.position = current_pos - Vector2(7, 30)
	marker.size = Vector2(14, 30)
	marker.color = Color(0.98, 0.82, 0.34, 0.94)
	content.add_child(marker)


func _main_scene_content_position() -> Vector2:
	return _clamp_map_content(MAIN_WORLD_FOCUS_OFFSET - _current_map_node_position())


func _current_expedition_chapter() -> Dictionary:
	var state: Dictionary = app._current_chapter_state()
	var chapter: Dictionary = state.get("chapter", {})
	var chapter_index: int = int(state.get("chapter_index", 1))
	var worldmap_chapter_id := _worldmap_chapter_id_for_index(chapter_index)
	var current_node := _worldmap_default_meta(worldmap_chapter_id)
	return {
		"state": state,
		"chapter": chapter,
		"chapter_id": worldmap_chapter_id,
		"chapter_index": chapter_index,
		"display_name": app._chapter_display_name(chapter, chapter_index),
		"map_pic": str(current_node.get("map_pic", "map_pic_%d" % worldmap_chapter_id)),
		"map_dec": str(current_node.get("map_dec", "")),
	}


func _reward_summary_text(items: Array) -> String:
	if items.is_empty():
		return "「初级回响」x5"
	var reward: Dictionary = items[0]
	var reward_name: String = str(reward.get("name", "")).strip_edges()
	var reward_count: String = str(reward.get("count", "1"))
	if reward_name.is_empty():
		reward_name = "章节奖励"
	return "「%s」x%s" % [reward_name, reward_count]


func _fight_state() -> Dictionary:
	var next_stage: Dictionary = app._next_stage()
	if next_stage.is_empty():
		return {
			"available": false,
			"can_fight": false,
			"status_text": "全部通关",
			"button_text": "已通关"
		}
	var required_power := int(next_stage.get("power", 0))
	var can_fight := app._player_power() >= required_power
	return {
		"available": true,
		"can_fight": can_fight,
		"status_text": "可进行挑战" if can_fight else ("推荐战力%d" % required_power),
		"button_text": "前往章节"
	}


func _reparent_to(node: Node, parent: Node) -> Node:
	if node == null:
		return null
	var old_parent := node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	parent.add_child(node)
	return node


func _draw_image_in(parent: Control, path: String, pos: Vector2, draw_size: Vector2, cover := false, tint := Color(1, 1, 1, 1)) -> TextureRect:
	var rect: TextureRect = app._draw_image(path, pos, draw_size, cover, tint)
	return _reparent_to(rect, parent) as TextureRect


func _draw_map_zone() -> void:
	var expedition_meta := _current_expedition_chapter()
	var state: Dictionary = expedition_meta.get("state", {})
	var chapter_index: int = int(expedition_meta.get("chapter_index", 1))
	var chapter_name: String = str(expedition_meta.get("display_name", ""))
	var fallback_stage_name: String = str(app._stage_name(int(app.save.get("next_stage_id", 101))))
	if chapter_name.is_empty():
		chapter_name = fallback_stage_name

	var map_panel := Control.new()
	map_panel.position = Vector2.ZERO
	map_panel.size = Vector2(1280, 720)
	app._view_container().add_child(map_panel)

	_draw_image_in(map_panel, UI_EXP_MAP, MAIN_MAP_POS, MAIN_MAP_SIZE, false, Color(1, 1, 1, 0.98))
	_draw_image_in(map_panel, UI_EXP_MAP_RING, MAIN_MAP_POS + Vector2(-10, -10), MAIN_MAP_RING_SIZE, false, Color(1, 1, 1, 0.96))
	_add_main_map_move_marker(map_panel, MAIN_MAP_POS + Vector2(80, 80))

	var stage_text := fallback_stage_name if not fallback_stage_name.is_empty() else ("第%d章·%s" % [chapter_index, chapter_name])
	var stage_label: Label = app._label(stage_text, 18, HORIZONTAL_ALIGNMENT_CENTER)
	stage_label.position = MAIN_MAP_POS + Vector2(37, 154)
	stage_label.size = Vector2(86, 26)
	stage_label.modulate = Color(0.96, 0.95, 0.88)
	map_panel.add_child(stage_label)

	var map_button := Button.new()
	map_button.text = ""
	map_button.flat = true
	map_button.focus_mode = Control.FOCUS_NONE
	map_button.position = MAIN_MAP_POS
	map_button.size = MAIN_MAP_SIZE
	map_button.modulate = Color(1, 1, 1, 0.01)
	map_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	map_button.pressed.connect(_open_current_map_detail_from_main)
	map_panel.add_child(map_button)

	_draw_image_in(map_panel, UI_EXP_CROSS_REWARD, MAIN_CROSS_REWARD_POS, MAIN_CROSS_REWARD_SIZE, false, Color(1, 1, 1, 0.96))
	_draw_image_in(map_panel, UI_EXP_REWARD_ICON, MAIN_CROSS_REWARD_POS + Vector2(4, -8), Vector2(80, 80), false, Color(1, 1, 1, 0.96))

	var remain: int = max(int(app.save.get("next_stage_id", 101)) - int(app.save.get("max_stage_id", 0)) - 1, 1)
	var cross_title: Label = app._label("再过 %d 关可得" % remain, 20)
	cross_title.position = MAIN_CROSS_REWARD_POS + Vector2(25, 8)
	cross_title.size = Vector2(132, 29)
	cross_title.modulate = Color(0.96, 0.92, 0.78)
	map_panel.add_child(cross_title)

	var cross_count: Label = app._label(_reward_summary_text(state.get("chapter_rewards", [])), 20)
	cross_count.position = MAIN_CROSS_REWARD_POS + Vector2(31, 43)
	cross_count.size = Vector2(144, 29)
	cross_count.modulate = Color(1.0, 0.83, 0.48)
	map_panel.add_child(cross_count)

	var cross_button := Button.new()
	cross_button.text = ""
	cross_button.flat = true
	cross_button.focus_mode = Control.FOCUS_NONE
	cross_button.position = MAIN_CROSS_REWARD_POS
	cross_button.size = MAIN_CROSS_REWARD_SIZE
	cross_button.modulate = Color(1, 1, 1, 0.01)
	cross_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cross_button.pressed.connect(app.chapter_screen.show_chapter_reward_detail)
	map_panel.add_child(cross_button)


func _add_main_map_move_marker(parent: Control, center: Vector2) -> void:
	var pulse: TextureRect = _draw_image_in(parent, UI_EXP_MAP_RING, center - Vector2(16, 16), Vector2(32, 32), false, Color(1.0, 0.94, 0.76, 0.36))
	if pulse != null:
		var tween := pulse.create_tween()
		tween.set_loops()
		tween.tween_property(pulse, "scale", Vector2(1.20, 1.20), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(pulse, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var marker := ColorRect.new()
	marker.position = center - Vector2(4, 12)
	marker.size = Vector2(8, 12)
	marker.color = Color(0.98, 0.82, 0.34, 0.96)
	parent.add_child(marker)


func _draw_bottom_actions() -> void:
	var reward_pos := Vector2(855, 525)
	var afk_claimed: bool = app._afk_claimed_today()
	var fight_state := _fight_state()
	app._draw_image(UI_EXP_REWARD, reward_pos, Vector2(172, 172), false, Color(1, 1, 1, 0.96))
	app._draw_image(UI_EXP_HOOK_TIME, reward_pos + Vector2(17, 118), Vector2(138, 26), false, Color(1, 1, 1, 0.90))
	var hook_time: Label = app._label(app._afk_time_display(), 22, HORIZONTAL_ALIGNMENT_CENTER)
	hook_time.position = reward_pos + Vector2(17, 118)
	hook_time.size = Vector2(138, 26)
	hook_time.modulate = Color(0.83, 0.97, 0.35) if not afk_claimed else Color(0.72, 0.72, 0.72)
	app._view_container().add_child(hook_time)
	app._draw_image(UI_EXP_REWARD_TIP, reward_pos + Vector2(104, -8), Vector2(68, 68), false, Color(1, 1, 1, 0.96))
	var reward_tip_text := "快速战斗99次\n可提升等级"
	if afk_claimed:
		reward_tip_text = "今日挂机收益\n已领取"
	var reward_tip: Label = app._label(reward_tip_text, 18, HORIZONTAL_ALIGNMENT_CENTER)
	reward_tip.position = reward_pos + Vector2(104, -8)
	reward_tip.size = Vector2(122, 48)
	reward_tip.modulate = Color(0.19, 0.19, 0.19) if not afk_claimed else Color(0.36, 0.36, 0.36)
	app._view_container().add_child(reward_tip)
	var reward_soft_guide: ColorRect = app._panel(reward_pos + Vector2(60, 34), Vector2(52, 52), Color(1.0, 0.84, 0.28, 0.10))
	reward_soft_guide.visible = not afk_claimed
	app._view_container().add_child(reward_soft_guide)
	var reward_hotspot := Button.new()
	reward_hotspot.text = ""
	reward_hotspot.flat = true
	reward_hotspot.focus_mode = Control.FOCUS_NONE
	reward_hotspot.position = reward_pos
	reward_hotspot.size = Vector2(172, 172)
	reward_hotspot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reward_hotspot.modulate = Color(1, 1, 1, 0.01)
	reward_hotspot.pressed.connect(app._claim_afk_reward)
	app._view_container().add_child(reward_hotspot)
	app._add_hit_button(reward_pos, Vector2(172, 172), app._claim_afk_reward)

	var action_specs := [
		{"path": UI_EXP_BTN_STRONGER, "label": "我要变强", "pos": Vector2(64, 544), "callback": app._show_develop, "size": Vector2(152, 152)},
		{"path": UI_EXP_BTN_DISPATCH, "label": "派遣", "pos": Vector2(555, 603), "callback": app._show_tasks, "size": Vector2(90, 90)},
		{"path": UI_EXP_BTN_HERO, "label": "星灵", "pos": Vector2(655, 603), "callback": app._show_develop, "size": Vector2(90, 90)},
		{"path": UI_EXP_BTN_MARCH, "label": "阵容", "pos": Vector2(755, 603), "callback": app._show_battle, "size": Vector2(90, 90)},
		{"path": UI_EXP_BTN_FIGHT, "label": "挑战", "pos": Vector2(1056, 537), "callback": show_chapter_panel, "size": Vector2(160, 160), "enabled": bool(fight_state.get("available", false))}
	]
	for item in action_specs:
		var size: Vector2 = item.get("size", Vector2(84, 84))
		var pos: Vector2 = item.get("pos", Vector2.ZERO)
		var enabled: bool = bool(item.get("enabled", true))
		app._draw_image(str(item.get("path", "")), pos, size, false, Color(1, 1, 1, 0.96 if enabled else 0.52))
		if str(item.get("label", "")) == "挑战":
			app._draw_image(UI_EXP_LIMIT, pos + Vector2(-14, 76), Vector2(188, 76), false, Color(1, 1, 1, 0.94))
			var fight_limit_text := str(fight_state.get("status_text", "玩家4级解锁"))
			var fight_limit: Label = app._label(fight_limit_text, 18, HORIZONTAL_ALIGNMENT_CENTER)
			fight_limit.position = pos + Vector2(19, 90)
			fight_limit.size = Vector2(150, 50)
			fight_limit.modulate = Color(0.10, 0.10, 0.10) if enabled else Color(0.42, 0.42, 0.42)
			app._view_container().add_child(fight_limit)
			# Keep a lightweight soft-guide marker aligned with the prefab's pnlSoftGuide.
			var fight_glow: ColorRect = app._panel(pos + Vector2(54, 32), Vector2(52, 52), Color(1.0, 0.84, 0.28, 0.12))
			fight_glow.visible = bool(fight_state.get("can_fight", false))
			app._view_container().add_child(fight_glow)
		var label_size := Vector2(size.x, 24)
		var label_pos := pos + Vector2(0, size.y - 28)
		var label_font := 18
		if size.x <= 90:
			label_size = Vector2(size.x - 54, size.y - 64)
			label_pos = pos + Vector2(27, 52)
			label_font = 16
		elif str(item.get("label", "")) == "我要变强":
			label_pos = pos + Vector2(22, 84)
			label_size = Vector2(108, 24)
			label_font = 18
		var label: Label = app._label(str(item.get("label", "")), label_font, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = label_pos
		label.size = label_size
		label.modulate = Color(1.0, 0.96, 0.88) if enabled else Color(0.76, 0.76, 0.76)
		app._view_container().add_child(label)
		if size.x <= 90:
			var red_dot: ColorRect = app._panel(pos + Vector2(18, 10), Vector2(12, 12), Color(0.96, 0.20, 0.26, 0.22))
			app._view_container().add_child(red_dot)
		if enabled:
			app._add_hit_button(pos, size, item.get("callback", app._show_home))


func _draw_side_actions() -> void:
	var level_limit_pos := Vector2(1094, 448)
	app._draw_image(UI_EXP_LIMIT, level_limit_pos, Vector2(144, 58), false, Color(1, 1, 1, 0.94))
	var level_text: Label = app._label("玩家 4 级解锁", 15, HORIZONTAL_ALIGNMENT_CENTER)
	level_text.position = level_limit_pos + Vector2(0, 8)
	level_text.size = Vector2(144, 36)
	level_text.modulate = Color(1.0, 0.90, 0.78)
	app._view_container().add_child(level_text)


func show_chapter_panel() -> void:
	app._show_chapter_panel()


func _show_chapter_panel_for_node(item: Dictionary) -> void:
	var chapter_index: int = int(item.get("chapter_index", 0))
	if chapter_index > 0:
		app._show_chapter_panel_for(chapter_index)
		return
	show_chapter_panel()


func show_expedition_map() -> void:
	app.current_view = "expedition_map"
	app._clear("尘世探索地图")
	app._draw_image(UI_EXP_BG, Vector2(0, 0), Vector2(1280, 720), true)
	app._view_container().add_child(app._panel(Vector2(0, 0), Vector2(1280, 720), Color(0.01, 0.02, 0.03, 0.06)))
	_map_detail_node = null
	_draw_map_back()
	_draw_map_canvas()
	_draw_map_side_buttons()


func _open_current_map_detail_from_main() -> void:
	show_expedition_map()
	call_deferred("_show_current_map_detail")


func _show_current_map_detail() -> void:
	var current_node := _current_map_node()
	if current_node.is_empty():
		return
	_show_map_detail(current_node)


func _draw_map_back() -> void:
	app._add_action_button("返回", Vector2(42, 18), show_expedition_main, Vector2(96, 38), app.UI_COMMON_BTN_WHITE)
	var title: Label = app._label("尘世探索地图", 26)
	title.position = Vector2(150, 18)
	title.size = Vector2(220, 36)
	title.modulate = Color(1.0, 0.95, 0.82)
	app._view_container().add_child(title)


func _draw_map_canvas() -> void:
	var viewport := Control.new()
	viewport.position = MAP_VIEWPORT_POS
	viewport.size = MAP_VIEWPORT_SIZE
	viewport.clip_contents = true
	app._view_container().add_child(viewport)

	var content := Control.new()
	content.size = MAP_CONTENT_SIZE
	viewport.add_child(content)
	content.position = _initial_map_content_position()
	_attach_map_drag(viewport, content)

	var pnl_chunk := Control.new()
	pnl_chunk.position = Vector2.ZERO
	pnl_chunk.size = MAP_CONTENT_SIZE
	content.add_child(pnl_chunk)

	var bg := ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = MAP_CONTENT_SIZE
	bg.color = Color(0.11, 0.09, 0.13, 0.28)
	pnl_chunk.add_child(bg)

	var img_map := Control.new()
	img_map.position = Vector2.ZERO
	img_map.size = MAP_CONTENT_SIZE
	content.add_child(img_map)

	_draw_world_tiles(pnl_chunk)

	var pnl_shadow := Control.new()
	pnl_shadow.position = Vector2.ZERO
	pnl_shadow.size = MAP_CONTENT_SIZE
	img_map.add_child(pnl_shadow)
	for shadow_pos in _shadow_specs():
		_add_shadow_marker(pnl_shadow, shadow_pos)

	var pnl_grid := Control.new()
	pnl_grid.position = Vector2.ZERO
	pnl_grid.size = MAP_CONTENT_SIZE
	img_map.add_child(pnl_grid)
	for item in _map_node_specs():
		_add_map_node(pnl_grid, item)

	var pnl_move_tool := Control.new()
	pnl_move_tool.position = Vector2.ZERO
	pnl_move_tool.size = MAP_CONTENT_SIZE
	img_map.add_child(pnl_move_tool)
	_add_move_tool_marker(pnl_move_tool)


func _shadow_specs() -> Array:
	var centered_positions := [
		Vector2(-862, 0), Vector2(-312, -203), Vector2(-862, -437), Vector2(-1441, -241), Vector2(-1413, 219), Vector2(-862, 410),
		Vector2(486, 794), Vector2(1001, 794), Vector2(1516, 794), Vector2(2031, 794), Vector2(2546, 794),
		Vector2(486, 321), Vector2(1001, 321), Vector2(1516, 321), Vector2(2031, 321), Vector2(2546, 321),
		Vector2(486, -152), Vector2(1001, -152), Vector2(1516, -152), Vector2(2031, -152), Vector2(2546, -152),
		Vector2(486, -625), Vector2(1001, -625), Vector2(1516, -625), Vector2(2031, -625), Vector2(2546, -625),
		Vector2(-2740, 794), Vector2(-2740, 321), Vector2(-2740, -152), Vector2(-2740, -625)
	]
	var result: Array = []
	for centered_pos in centered_positions:
		result.append(MAP_COORD_ORIGIN + centered_pos)
	return result


func _map_node_specs() -> Array:
	var runtime_state: Dictionary = _current_expedition_chapter().get("state", {})
	var current_chapter_index: int = int(runtime_state.get("chapter_index", 1))
	var nodes := [
		{"id": 1001, "fallback_name": "雾港学院", "pos": Vector2(1014, 1844), "chapter_index": 1},
		{"id": 1002, "fallback_name": "千星都会", "pos": Vector2(1564, 1641), "chapter_index": 2},
		{"id": 1003, "fallback_name": "逐月庭院", "pos": Vector2(1014, 1407), "chapter_index": 3},
		{"id": 1004, "fallback_name": "潮汐前哨", "pos": Vector2(435, 1603), "chapter_index": 4},
		{"id": 1005, "fallback_name": "回音长街", "pos": Vector2(463, 2063), "chapter_index": 5},
		{"id": 1006, "fallback_name": "鎏金宫", "pos": Vector2(1014, 2254), "chapter_index": 6},
		{"id": 1007, "fallback_name": "流光别院", "pos": Vector2(2362, 2638), "chapter_index": 0},
		{"id": 1008, "fallback_name": "灰烬古城", "pos": Vector2(2877, 2638), "chapter_index": 0},
		{"id": 1009, "fallback_name": "遥星湾", "pos": Vector2(3392, 2638), "chapter_index": 0},
		{"id": 1010, "fallback_name": "月蚀焰地", "pos": Vector2(3907, 2638), "chapter_index": 0}
	]
	for item in nodes:
		var chapter_id: int = int(item.get("id", 0))
		var node_meta: Dictionary = WORLDMAP_NODE_DEFAULTS.get(chapter_id, {})
		var chapter_index: int = int(item.get("chapter_index", 0))
		var chapter_state: Dictionary = app._chapter_state_for_index(chapter_index) if chapter_index > 0 else {}
		var chapter: Dictionary = chapter_state.get("chapter", {})
		var chapter_meta: Dictionary = _chapter_meta_for_index(chapter_index)
		var display_name := str(node_meta.get("fallback_name", item.get("fallback_name", "未命名区域")))
		if not chapter.is_empty():
			display_name = app._chapter_display_name(chapter, chapter_index)
		elif not str(chapter_meta.get("nameResolved", "")).is_empty():
			display_name = str(chapter_meta.get("nameResolved", ""))
		item["chapter"] = chapter
		item["state"] = chapter_state
		item["name"] = display_name
		item["map_pic"] = str(node_meta.get("map_pic", "map_pic_%d" % chapter_id))
		item["map_dec"] = _worldmap_description(node_meta, chapter_meta, chapter, chapter_index)
		item["reward_desc"] = str(chapter_meta.get("rewardDesResolved", "")).strip_edges()
		item["map_move_hint"] = str(node_meta.get("map_move_hint", "当前驻扎"))
		item["vehicle_tip"] = str(node_meta.get("vehicle_tip", "点击进入载具巡逻"))
		item["confirm_text"] = str(node_meta.get("confirm_text", "前往挑战"))
		item["current"] = chapter_index > 0 and chapter_index == current_chapter_index
		item["unlocked"] = chapter_index > 0 and chapter_index <= current_chapter_index
		item["available"] = chapter_index > 0 and chapter_index <= app.chapters.size()
		item["placeholder_icon"] = not _is_confirmed_world_icon_key(str(item.get("map_pic", "")))
	return nodes


func _worldmap_chapter_id_for_index(chapter_index: int) -> int:
	if chapter_index <= 0:
		return WORLDMAP_ID_BASE + 1
	return WORLDMAP_ID_BASE + chapter_index


func _current_map_node() -> Dictionary:
	for item in _map_node_specs():
		if bool(item.get("current", false)):
			return item
	return {}


func _map_node_by_id(chapter_id: int) -> Dictionary:
	for item in _map_node_specs():
		if int(item.get("id", 0)) == chapter_id:
			return item
	return {}


func _worldmap_default_meta(chapter_id: int) -> Dictionary:
	return WORLDMAP_NODE_DEFAULTS.get(chapter_id, {
		"map_pic": "map_pic_%d" % chapter_id,
		"fallback_dec": "",
		"map_move_hint": "当前驻扎",
		"vehicle_tip": "点击进入载具巡逻",
		"confirm_text": "前往挑战",
	})


func _chapter_meta_for_index(chapter_index: int) -> Dictionary:
	if chapter_index <= 0:
		return {}
	return _chapter_meta.get(str(chapter_index), {})


func _worldmap_description(node_meta: Dictionary, chapter_meta: Dictionary, chapter: Dictionary, chapter_index: int) -> String:
	var desc := str(chapter_meta.get("descriptionResolved", "")).strip_edges()
	if not desc.is_empty():
		return desc
	desc = str(node_meta.get("fallback_dec", "")).strip_edges()
	if not desc.is_empty():
		return desc
	if not chapter.is_empty():
		return "第%d章的地图详情仍在补齐中，当前先按已导出的章节与资源做恢复。" % chapter_index
	return "当前只闭合到地图点位，章节详情与真实字段仍待继续追源。"


func _current_map_node_position() -> Vector2:
	var current_node := _current_map_node()
	if not current_node.is_empty():
		return current_node.get("pos", MAP_COORD_ORIGIN)
	return MAP_COORD_ORIGIN


func _initial_map_content_position() -> Vector2:
	var current_pos := _current_map_node_position()
	var focus_offset := Vector2(MAP_VIEWPORT_SIZE.x * 0.5, MAP_VIEWPORT_SIZE.y * 0.58)
	return _clamp_map_content(focus_offset - current_pos)


func _add_move_tool_marker(parent: Control) -> void:
	var current_pos := _current_map_node_position()
	var current_node := _current_map_node()
	var ring: TextureRect = _draw_image_in(parent, UI_EXP_MAP_RING, current_pos - Vector2(36, 36), Vector2(72, 72), false, Color(1.0, 0.95, 0.78, 0.42))
	if ring != null:
		var tween := ring.create_tween()
		tween.set_loops()
		tween.tween_property(ring, "scale", Vector2(1.12, 1.12), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ring, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var marker := ColorRect.new()
	marker.position = current_pos - Vector2(8, 56)
	marker.size = Vector2(16, 52)
	marker.color = Color(0.96, 0.84, 0.38, 0.94)
	parent.add_child(marker)
	_add_map_move_tool_actor(parent, current_pos, current_node)

	_draw_image_in(parent, UI_EXP_CHAPTER_TAG, current_pos + Vector2(-84, 42), Vector2(168, 46), false, Color(1, 1, 1, 0.92))

	var move_label: Label = app._label("当前驻扎", 14, HORIZONTAL_ALIGNMENT_CENTER)
	move_label.position = current_pos + Vector2(-70, 51)
	move_label.size = Vector2(140, 24)
	move_label.modulate = Color(1.0, 0.95, 0.82)
	parent.add_child(move_label)

	if not current_node.is_empty():
		var tip_bg: ColorRect = app._panel(current_pos + Vector2(42, -118), Vector2(116, 28), Color(0.05, 0.06, 0.09, 0.72))
		parent.add_child(tip_bg)
		var tip_label: Label = app._label(str(current_node.get("vehicle_tip", "点击进入载具巡逻")), 11, HORIZONTAL_ALIGNMENT_CENTER)
		tip_label.position = current_pos + Vector2(46, -114)
		tip_label.size = Vector2(108, 20)
		tip_label.modulate = Color(1.0, 0.95, 0.82)
		parent.add_child(tip_label)


func _add_map_move_tool_actor(parent: Control, center: Vector2, item: Dictionary) -> void:
	var hero: Dictionary = _expedition_scene_hero()
	var actor_root := Control.new()
	actor_root.position = center + Vector2(-84, -198)
	actor_root.size = Vector2(176, 206)
	parent.add_child(actor_root)
	_add_scene_vehicle_base(actor_root, Vector2(8, 134))
	_add_scene_shadow_oval(actor_root, Vector2(86, 176), 46.0, 14.0, Color(0.02, 0.02, 0.03, 0.24))
	_add_scene_hero_actor(actor_root, hero, Vector2(24, 14), Vector2(128, 162), "standby")
	var tween := actor_root.create_tween()
	tween.set_loops()
	var start_pos := actor_root.position
	tween.tween_property(actor_root, "position", start_pos + Vector2(0, -8), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(actor_root, "position", start_pos, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if not item.is_empty():
		var tip: Label = app._label(str(item.get("vehicle_tip", "AFKMap 待命")), 11, HORIZONTAL_ALIGNMENT_CENTER)
		tip.position = Vector2(22, 150)
		tip.size = Vector2(124, 20)
		tip.modulate = Color(0.96, 0.93, 0.80, 0.86)
		actor_root.add_child(tip)
	var click_area := Button.new()
	click_area.text = ""
	click_area.flat = true
	click_area.focus_mode = Control.FOCUS_NONE
	click_area.position = Vector2(20, 10)
	click_area.size = Vector2(136, 170)
	click_area.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	click_area.modulate = Color(1, 1, 1, 0.01)
	click_area.pressed.connect(func() -> void:
		if not item.is_empty():
			_show_map_detail(item)
	)
	actor_root.add_child(click_area)


func _add_map_node(parent: Control, item: Dictionary) -> void:
	var pos: Vector2 = item.get("pos", Vector2.ZERO)
	var is_current: bool = bool(item.get("current", false))
	var is_unlocked: bool = bool(item.get("unlocked", false))
	var is_available: bool = bool(item.get("available", false))
	var ring_size := Vector2(116, 116) if is_current else Vector2(96, 96)
	var ring_pos := pos - ring_size * 0.5
	_draw_image_in(parent, UI_EXP_MAP_RING, ring_pos, ring_size, false, Color(1, 1, 1, 0.92 if is_current else (0.78 if is_unlocked else 0.36)))

	var core_size := Vector2(80, 80) if is_current else Vector2(64, 64)
	var core_pos := pos - core_size * 0.5
	_draw_image_in(parent, UI_EXP_MAP, core_pos, core_size, false, Color(1, 1, 1, 0.98 if is_unlocked else 0.42))

	var icon_path: String = _world_icon_path_from_key(str(item.get("map_pic", "")))
	if not icon_path.is_empty() and (is_current or is_unlocked):
		_draw_image_in(parent, icon_path, pos - Vector2(46, 92), Vector2(92, 92), false, Color(1, 1, 1, 0.98 if not bool(item.get("placeholder_icon", false)) else 0.88))

	var tag_pos := pos + Vector2(-84, 64)
	_draw_image_in(parent, UI_EXP_CHAPTER_TAG, tag_pos, Vector2(168, 46), false, Color(1, 1, 1, 0.98 if is_available else 0.56))

	var label: Label = app._label(str(item.get("name", "")), 14, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = tag_pos + Vector2(8, 9)
	label.size = Vector2(152, 24)
	label.modulate = Color(0.96, 0.95, 0.88) if is_available else Color(0.72, 0.72, 0.72)
	parent.add_child(label)

	if not is_unlocked:
		var lock_text: String = "未解锁" if is_available else "待实装"
		var lock_label: Label = app._label(lock_text, 12, HORIZONTAL_ALIGNMENT_CENTER)
		lock_label.position = pos + Vector2(-48, -14)
		lock_label.size = Vector2(96, 20)
		lock_label.modulate = Color(0.90, 0.76, 0.42, 0.94) if is_available else Color(0.66, 0.66, 0.70, 0.88)
		parent.add_child(lock_label)

	var btn := Button.new()
	btn.text = ""
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.position = pos - Vector2(MAP_NODE_SIZE.x * 0.5, MAP_NODE_SIZE.y * 0.5)
	btn.size = MAP_NODE_SIZE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.disabled = not is_available
	btn.modulate = Color(1, 1, 1, 0.01)
	btn.pressed.connect(func() -> void:
		_show_map_detail(item)
	)
	parent.add_child(btn)


func _add_shadow_marker(parent: Control, pos: Vector2) -> void:
	var shadow := ColorRect.new()
	shadow.position = pos - Vector2(212, 196)
	shadow.size = Vector2(424, 392)
	shadow.color = Color(0.07, 0.08, 0.10, 0.22)
	parent.add_child(shadow)


func _draw_world_tiles(parent: Control) -> void:
	var tiles := [
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-3_2.png", "grid": Vector2(0, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-2_2.png", "grid": Vector2(1, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-1_2.png", "grid": Vector2(2, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_0_2.png", "grid": Vector2(3, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_1_2.png", "grid": Vector2(4, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_2_2.png", "grid": Vector2(5, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_3_2.png", "grid": Vector2(6, 0)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-3_1.png", "grid": Vector2(0, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-2_1.png", "grid": Vector2(1, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-1_1.png", "grid": Vector2(2, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_0_1.png", "grid": Vector2(3, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_1_1.png", "grid": Vector2(4, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_2_1.png", "grid": Vector2(5, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_3_1.png", "grid": Vector2(6, 1)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-3_0.png", "grid": Vector2(0, 2)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-2_0.png", "grid": Vector2(1, 2)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_0_0.png", "grid": Vector2(3, 2)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_1_0.png", "grid": Vector2(4, 2)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_2_0.png", "grid": Vector2(5, 2)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_3_0.png", "grid": Vector2(6, 2)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-3_-1.png", "grid": Vector2(0, 3)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-2_-1.png", "grid": Vector2(1, 3)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_1_-1.png", "grid": Vector2(4, 3)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_2_-1.png", "grid": Vector2(5, 3)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_3_-1.png", "grid": Vector2(6, 3)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-3_-2.png", "grid": Vector2(0, 4)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-2_-2.png", "grid": Vector2(1, 4)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_-1_-2.png", "grid": Vector2(2, 4)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_0_-2.png", "grid": Vector2(3, 4)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_1_-2.png", "grid": Vector2(4, 4)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_2_-2.png", "grid": Vector2(5, 4)},
		{"path": UI_EXP_WORLD_TILE_BASE + "WorldMap_3_-2.png", "grid": Vector2(6, 4)}
	]
	for item in tiles:
		var tile_path: String = item.get("path", "")
		var grid: Vector2 = item.get("grid", Vector2.ZERO)
		var tile_pos := Vector2(grid.x * 1024.0, grid.y * 1024.0)
		_draw_image_in(parent, tile_path, tile_pos, Vector2(1024, 1024), false, Color(1, 1, 1, 0.94))


func _world_icon_path(chapter_id: int) -> String:
	return _world_icon_path_from_key("map_pic_%d" % chapter_id)


func _is_confirmed_world_icon_key(icon_key: String) -> bool:
	return bool(CONFIRMED_WORLDMAP_ICON_KEYS.get(icon_key, false))


func _world_icon_path_from_key(icon_key: String) -> String:
	if icon_key.is_empty():
		return ""
	if not _is_confirmed_world_icon_key(icon_key):
		return ""
	var normalized := icon_key if icon_key.ends_with(".png") else "%s.png" % icon_key
	var path := "%s%s" % [UI_EXP_WORLD_TILE_BASE, normalized]
	return path if FileAccess.file_exists(path) else ""


func _show_map_detail(item: Dictionary) -> void:
	if _map_detail_node != null:
		_map_detail_node.queue_free()
		_map_detail_node = null
	var overlay := Control.new()
	overlay.position = Vector2.ZERO
	overlay.size = Vector2(1280, 720)
	app._view_container().add_child(overlay)
	_map_detail_node = overlay

	var dismiss := Button.new()
	dismiss.text = ""
	dismiss.flat = true
	dismiss.focus_mode = Control.FOCUS_NONE
	dismiss.position = Vector2.ZERO
	dismiss.size = overlay.size
	dismiss.modulate = Color(1, 1, 1, 0.01)
	dismiss.pressed.connect(_close_map_detail)
	overlay.add_child(app._panel(Vector2(0, 0), overlay.size, Color(0.01, 0.01, 0.02, 0.72)))
	overlay.add_child(dismiss)

	# Match ExpeditionChapterMapDetailView prefab size/placement more closely.
	var card_pos := Vector2(286, 56)
	var card_size := Vector2(708, 608)
	_draw_image_in(overlay, UI_COMMON_BG_08, card_pos, card_size, false, Color(1, 1, 1, 0.98))

	var title: Label = app._label(str(item.get("name", "未知区域")), 24)
	title.position = card_pos + Vector2(56, 26)
	title.size = Vector2(354, 42)
	title.modulate = Color(1.0, 1.0, 1.0)
	overlay.add_child(title)

	var close_btn := Button.new()
	close_btn.text = ""
	close_btn.flat = true
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.position = card_pos + Vector2(614, 28)
	close_btn.size = Vector2(60, 60)
	close_btn.modulate = Color(1, 1, 1, 0.01)
	close_btn.pressed.connect(_close_map_detail)
	_draw_image_in(overlay, UI_COMMON_BTN_16, card_pos + Vector2(614, 28), Vector2(60, 60), false, Color(1, 1, 1, 0.98))
	overlay.add_child(close_btn)

	var cover_path: String = _world_icon_path_from_key(str(item.get("map_pic", "")))
	_draw_image_in(overlay, UI_EXP_DETAIL_COVER, card_pos + Vector2(34, 183), Vector2(640, 200), false, Color(1, 1, 1, 0.98))
	if not cover_path.is_empty():
		_draw_image_in(overlay, cover_path, card_pos + Vector2(34, 183), Vector2(640, 200), true, Color(1, 1, 1, 0.98))

	var state: Dictionary = item.get("state", {})
	var chapter: Dictionary = item.get("chapter", {})
	var chapter_index: int = int(item.get("chapter_index", 0))
	var chapter_meta: Dictionary = _chapter_meta_for_index(chapter_index)
	var unlocked: bool = bool(item.get("unlocked", false))
	var available: bool = bool(item.get("available", false))
	var completed: int = int(state.get("completed", 0))
	var stage_count: int = int(state.get("stage_count", 0))
	var desc_lines: Array[String] = []
	desc_lines.append("WorldMap chapterId: %d" % int(item.get("id", 0)))
	if chapter_index > 0:
		desc_lines.append("映射章节: 第%d章" % chapter_index)
		desc_lines.append("进度: %d/%d" % [completed, max(stage_count, 1)])
	else:
		desc_lines.append("映射章节: 暂无 adventure 数据")
	desc_lines.append("状态: %s" % ("已解锁" if unlocked else ("未解锁" if available else "待实装")))
	desc_lines.append("驻扎提示: %s" % str(item.get("map_move_hint", "当前驻扎")))
	if bool(item.get("placeholder_icon", false)):
		desc_lines.append("图标: 当前 key 未在本地真实资源集中闭合，按无 icon 处理")
	else:
		desc_lines.append("图标: 已命中当前本地真实导出 icon")
	var next_stage: Dictionary = state.get("next_stage", {})
	if not next_stage.is_empty():
		desc_lines.append("推荐挑战: %s" % str(next_stage.get("name", "")))
	var map_desc := str(chapter_meta.get("descriptionResolved", "")).strip_edges()
	if map_desc.is_empty():
		map_desc = str(item.get("map_dec", "")).strip_edges()
	if map_desc.is_empty():
		map_desc = "详情按 ExpeditionChapterMapDetailView 语义恢复。"
	var reward_desc := str(item.get("reward_desc", "")).strip_edges()
	var detail_text := map_desc
	if not reward_desc.is_empty():
		detail_text = "%s\n\n%s" % [detail_text, reward_desc]
	elif not chapter.is_empty():
		detail_text = "%s\n\n章节奖励预览：%s" % [detail_text, _reward_summary_text(state.get("chapter_rewards", []))]
	var detail: Label = app._label(detail_text, 20)
	detail.position = card_pos + Vector2(34, 418)
	detail.size = Vector2(640, 160)
	detail.modulate = Color(0.20, 0.20, 0.20)
	overlay.add_child(detail)

	var status_bg: ColorRect = app._panel(card_pos + Vector2(24, 508), Vector2(660, 34), Color(0.10, 0.10, 0.10, 0.10))
	overlay.add_child(status_bg)
	var tip: Label = app._label("\n".join(desc_lines), 13)
	tip.position = card_pos + Vector2(32, 512)
	tip.size = Vector2(644, 56)
	tip.modulate = Color(0.36, 0.36, 0.36)
	overlay.add_child(tip)
	for reward_index in range(min(int(state.get("chapter_rewards", []).size()), 3)):
		var reward: Dictionary = state.get("chapter_rewards", [])[reward_index]
		app._draw_home_reward_icon(
			str(reward.get("icon", "")),
			card_pos + Vector2(360 + reward_index * 86, 102),
			"",
			str(reward.get("count", ""))
		)

	var task_button := Button.new()
	task_button.text = ""
	task_button.flat = true
	task_button.focus_mode = Control.FOCUS_NONE
	task_button.position = card_pos + Vector2(194, 518)
	task_button.size = Vector2(320, 64)
	task_button.disabled = not available
	task_button.modulate = Color(1, 1, 1, 0.01)
	task_button.pressed.connect(func() -> void:
		_close_map_detail()
		_show_chapter_panel_for_node(item)
	)
	_draw_image_in(overlay, UI_COMMON_BTN_17, card_pos + Vector2(194, 518), Vector2(320, 64), false, Color(1, 1, 1, 0.98 if available else 0.52))
	overlay.add_child(task_button)
	var confirm_text := str(item.get("confirm_text", "前往挑战"))
	if available:
		confirm_text = "前往章节"
	elif not unlocked:
		confirm_text = "未解锁"
	var confirm_label: Label = app._label(confirm_text, 26, HORIZONTAL_ALIGNMENT_CENTER)
	confirm_label.position = card_pos + Vector2(194, 534)
	confirm_label.size = Vector2(320, 24)
	confirm_label.modulate = Color(1.0, 1.0, 1.0, 0.98 if available else 0.72)
	overlay.add_child(confirm_label)


func _close_map_detail() -> void:
	if _map_detail_node == null:
		return
	_map_detail_node.queue_free()
	_map_detail_node = null


func _attach_map_drag(viewport: Control, content: Control) -> void:
	var drag := Control.new()
	drag.position = Vector2.ZERO
	drag.size = MAP_VIEWPORT_SIZE
	drag.mouse_filter = Control.MOUSE_FILTER_STOP
	drag.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_map_drag_origin = event.position
				_map_content_origin = content.position
			else:
				_map_drag_origin = Vector2.ZERO
		elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var next_pos: Vector2 = _map_content_origin + (event.position - _map_drag_origin)
			content.position = _clamp_map_content(next_pos)
	)
	viewport.add_child(drag)


func _clamp_map_content(next_pos: Vector2) -> Vector2:
	var min_x: float = MAP_VIEWPORT_SIZE.x - MAP_CONTENT_SIZE.x
	var min_y: float = MAP_VIEWPORT_SIZE.y - MAP_CONTENT_SIZE.y
	return Vector2(clampf(next_pos.x, min_x, 0.0), clampf(next_pos.y, min_y, 0.0))


func _draw_map_side_buttons() -> void:
	var fight_state := _fight_state()
	var buttons := [
		{"path": UI_EXP_BTN_DISPATCH, "label": "派遣", "pos": Vector2(1122, 188), "callback": app._show_tasks},
		{"path": UI_EXP_BTN_MARCH, "label": "阵容", "pos": Vector2(1122, 298), "callback": app._show_battle},
		{"path": UI_EXP_BTN_FIGHT, "label": "挑战", "pos": Vector2(1104, 438), "callback": show_chapter_panel, "size": Vector2(126, 126), "enabled": bool(fight_state.get("available", false))}
	]
	for item in buttons:
		var size: Vector2 = item.get("size", Vector2(84, 84))
		var pos: Vector2 = item.get("pos", Vector2.ZERO)
		var enabled: bool = bool(item.get("enabled", true))
		app._draw_image(str(item.get("path", "")), pos, size, false, Color(1, 1, 1, 0.96 if enabled else 0.52))
		var label: Label = app._label(str(item.get("label", "")), 15, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + Vector2(0, size.y - 6)
		label.size = Vector2(size.x, 20)
		label.modulate = Color(1.0, 0.96, 0.88) if enabled else Color(0.76, 0.76, 0.76)
		app._view_container().add_child(label)
		if str(item.get("label", "")) == "挑战":
			var side_status: Label = app._label(str(fight_state.get("status_text", "")), 12, HORIZONTAL_ALIGNMENT_CENTER)
			side_status.position = pos + Vector2(-6, size.y + 10)
			side_status.size = Vector2(size.x + 12, 18)
			side_status.modulate = Color(0.94, 0.90, 0.78) if enabled else Color(0.70, 0.70, 0.70)
			app._view_container().add_child(side_status)
		if enabled:
			app._add_hit_button(pos, size, item.get("callback", show_expedition_main))
