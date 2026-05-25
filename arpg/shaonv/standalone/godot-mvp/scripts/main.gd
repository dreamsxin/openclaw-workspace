# UTF-8 source. Keep Chinese UI labels readable when editing on Windows.
extends Control

const SAVE_PATH := "user://shaonv_godot_mvp_save.json"
const DEFAULT_HERO_ID := 240037
const LEGACY_DEFAULT_HERO_ID := 240065
const HERO_DATA_PATH := "res://data/heroes_mvp.json"
const HERO_RESOURCE_MAP_PATH := "res://data/hero_resource_map.json"
const POOL_DATA_PATH := "res://data/gacha_pools_mvp.json"
const LIVE_OPS_DATA_PATH := "res://data/live_ops_mvp.json"
const ADVENTURE_DATA_PATH := "res://data/adventure_mvp.json"
const BAKED_SPINE_CANVAS := preload("res://scripts/spine_baked_preview_canvas.gd")
const STARTUP_SCREEN := preload("res://scripts/screens/startup_screen.gd")
const HOME_SCREEN := preload("res://scripts/screens/home_screen.gd")
const GACHA_SCREEN := preload("res://scripts/screens/gacha_screen.gd")
const GACHA_RESULT_SCREEN := preload("res://scripts/screens/gacha_result_screen.gd")
const GAL_SCREEN := preload("res://scripts/screens/gal_screen.gd")
const UI_LOGIN_BG := "res://assets/ui/background/login_bg_01.png"
const UI_MAIN_BG := "res://assets/ui/background/mainui_bg_01.png"
const UI_LOGIN_LOGO := "res://assets/ui/login/logo.png"
const UI_LOGIN_SERVER_BG := "res://assets/ui/login/server_bg_03.png"
const UI_LOTTERY_BG := "res://assets/ui/lottery/lottery_img_01.png"
const UI_LOTTERY_STAGE_BG := "res://assets/ui/lottery/lottery_img_60.png"
const UI_LOTTERY_LIGHT_L := "res://assets/ui/lottery/lottery_img_60_l.png"
const UI_LOTTERY_LIGHT_R := "res://assets/ui/lottery/lottery_img_60_r.png"
const UI_LOTTERY_ALPHA_L := "res://assets/ui/lottery/lottery_img_alpha_l.png"
const UI_LOTTERY_ALPHA_R := "res://assets/ui/lottery/lottery_img_alpha_r.png"
const UI_MAIN_TOP_ACCENT := "res://assets/ui/mainui/mainui_img_10.png"
const UI_LOTTERY_BTN_SINGLE := "res://assets/ui/common/lottery_btn_05.png"
const UI_LOTTERY_BTN_TEN := "res://assets/ui/common/lottery_btn_06.png"
const UI_LOTTERY_BG_NORMAL := "res://assets/ui/lottery/bg/lottery_bg_02.png"
const UI_LOTTERY_BG_ADVANCED := "res://assets/ui/lottery/bg/lottery_bg_01.png"
const UI_LOTTERY_BG_EPIC := "res://assets/ui/lottery/bg/lottery_bg_03.png"
const UI_LOTTERY_BG_PRAYER := "res://assets/ui/lottery/bg/lottery_bg_08.png"
const UI_LOTTERY_SIDE_1 := "res://assets/ui/lottery/lottery_img_11.png"
const UI_LOTTERY_SIDE_2 := "res://assets/ui/lottery/lottery_img_12.png"
const UI_LOTTERY_POOL_FRAME := "res://assets/ui/lottery/lottery_img_55.png"
const UI_LOTTERY_PRAYER_FRAME := "res://assets/ui/lottery/lottery_img_57.png"
const UI_LOTTERY_TICKET_ICON := "res://assets/ui/item/draw_03.png"
const UI_HERO_BG_MAIN := "res://assets/ui/background/hero_bg_01.png"
const UI_HERO_BG_DETAIL := "res://assets/ui/background/hero_bg_10.png"
const UI_HERO_DETAIL_INFO_BG := "res://assets/ui/background/guessing_bg_03.png"
const UI_HERO_SELECTOR_BG := "res://assets/ui/hero/hero_img_36.png"
const UI_HERO_SELECTOR_TOP := "res://assets/ui/hero/hero_img_36a.png"
const UI_HERO_SORT_BTN := "res://assets/ui/hero/hero_btn_05.png"
const UI_HERO_FILTER_BG := "res://assets/ui/hero/hero_img_108.png"
const UI_HERO_HIGHLIGHT := "res://assets/ui/hero/hero_img_119.png"
const UI_HERO_STAR_SMALL := "res://assets/ui/hero/hero_img_60.png"
const UI_HERO_TAB_HOME := "res://assets/ui/hero/hero_img_37.png"
const UI_HERO_TAB_CULTIVATE := "res://assets/ui/hero/hero_img_43.png"
const UI_HERO_TAB_EQUIP := "res://assets/ui/hero/hero_img_44.png"
const UI_HERO_TAB_STAGE := "res://assets/ui/hero/hero_img_45.png"
const UI_COMMON_TAB_HIGHLIGHT := "res://assets/ui/common/common_btn_07.png"
const UI_COMMON_HEAD_FRAME := "res://assets/ui/common/common_img_07.png"
const UI_COMMON_HERO_HEAD_FRAME := "res://assets/ui/common/common_img_64.png"
const UI_COMMON_HERO_STAR_BAR := "res://assets/ui/common/common_img_62.png"
const UI_COMMON_STAR := "res://assets/ui/common/common_img_73.png"
const UI_COMMON_STAR_OFF := "res://assets/ui/common/common_img_74.png"
const UI_COMMON_RARE := "res://assets/ui/common/common_img_163.png"
const UI_COMMON_SECTION := "res://assets/ui/common/common_img_199.png"
const UI_COMMON_SKILL_FRAME := "res://assets/ui/common/common_img_208.png"
const UI_REMNANTS_BG := "res://assets/ui/background/mainui_bg_01.png"
const UI_REMNANT_STAGE_BG := "res://assets/spine/hero_017/hero_017_bg.png"

var heroes: Array = []
var hero_resource_map: Array = []
var pools: Array = []
var tasks: Array = []
var mails: Array = []
var daily := {}
var shop := {}
var chapters: Array = []
var afk_reward := {}
var save := {
	"profile": {
		"name": "Player",
		"level": 88,
		"base_power": 999999
	},
	"settings": {
		"wallpaper_auto_play": true,
		"music": true,
		"effects": true
	},
	"tickets": 120,
	"gems": 16800,
	"owned": {},
	"shards": {},
	"pity": {},
	"history": [],
	"draw_count": 0,
	"claimed_tasks": {},
	"claimed_mail": {},
	"daily_claimed_date": "",
	"selected_hero_id": DEFAULT_HERO_ID,
	"active_pool_id": "advanced",
	"battle_count": 0,
	"max_stage_id": 0,
	"next_stage_id": 101,
	"afk_claimed_date": ""
}

var rng := RandomNumberGenerator.new()
# ── CanvasLayer 视图栈 ──
var _mid_layer: CanvasLayer
var _high_layer: CanvasLayer
var _all_views: Array[Control] = []       # 视图栈 [最底, ..., 最顶]
var _view_names: Array[String] = []       # 并行名称栈
var title_label: Label
var wallet_label: Label
var top_bar: Control
var current_view := "boot"
var gallery_filter := "all"
var remnants_page := 0
var selected_remnant_id := DEFAULT_HERO_ID
var startup_screen
var home_screen
var gal_screen
var gacha_screen
var gacha_result_screen

func _view_container() -> Control:
	if _all_views.is_empty():
		return self  # fallback: draw on root before first push
	return _all_views.back()

func _ready() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	position = Vector2.ZERO
	size = Vector2(1280, 720)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("Shaonv MVP _ready")
	rng.randomize()
	heroes = _read_json(HERO_DATA_PATH).get("heroes", [])
	hero_resource_map = _read_json_array(HERO_RESOURCE_MAP_PATH)
	pools = _read_json(POOL_DATA_PATH).get("pools", [])
	var live_ops := _read_json(LIVE_OPS_DATA_PATH)
	tasks = live_ops.get("tasks", [])
	mails = live_ops.get("mails", [])
	daily = live_ops.get("daily", {"tickets": 3, "gems": 480})
	shop = live_ops.get("shop", {"exchangeGemCost": 160, "ticketAmount": 1})
	var adventure := _read_json(ADVENTURE_DATA_PATH)
	chapters = adventure.get("chapters", [])
	afk_reward = adventure.get("afkReward", {"tickets": 1, "gems": 240, "shards": {}})
	_load_save()
	_build_root()
	startup_screen = STARTUP_SCREEN.new(self)
	home_screen = HOME_SCREEN.new(self)
	gacha_screen = GACHA_SCREEN.new(self)
	gacha_result_screen = GACHA_RESULT_SCREEN.new(self)
	gal_screen = GAL_SCREEN.new(self)
	_startup_sequence()
	if not OS.get_environment("SHAONV_MVP_CAPTURE").is_empty():
		call_deferred("_capture_debug_screenshot")

func _capture_debug_screenshot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		push_warning("Shaonv MVP screenshot skipped: --headless has no renderable viewport texture.")
		return
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		push_warning("Shaonv MVP screenshot skipped: viewport texture is null, likely running with --headless.")
		return
	var image := viewport_texture.get_image()
	if image == null or image.is_empty():
		push_warning("Shaonv MVP screenshot skipped: viewport image is empty, likely running with --headless.")
		return
	var path := OS.get_environment("SHAONV_MVP_CAPTURE")
	image.save_png(path)
	print("Shaonv MVP screenshot saved: %s" % path)

func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_warning("Missing or empty JSON: %s" % path)
		return {}
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid JSON object: %s" % path)
		return {}
	return parsed


func _read_json_array(path: String) -> Array:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_warning("Missing or empty JSON array: %s" % path)
		return []
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_warning("Invalid JSON array: %s" % path)
		return []
	return parsed


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		save.merge(parsed, true)
	if int(save.get("selected_hero_id", DEFAULT_HERO_ID)) == LEGACY_DEFAULT_HERO_ID:
		save["selected_hero_id"] = DEFAULT_HERO_ID

func _persist() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save))

func _build_root() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.036, 0.031, 0.028)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	top_bar = Control.new()
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(1280, 74)
	add_child(top_bar)

	var top_bg := ColorRect.new()
	top_bg.color = Color(0.034, 0.028, 0.024, 0.94)
	top_bg.position = Vector2(0, 0)
	top_bg.size = Vector2(1280, 74)
	top_bar.add_child(top_bg)

	var profile_button := Button.new()
	profile_button.text = _profile_summary()
	profile_button.position = Vector2(16, 8)
	profile_button.size = Vector2(238, 56)
	profile_button.pressed.connect(_show_player_info)
	top_bar.add_child(profile_button)

	title_label = _label("MainScene", 18, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.position = Vector2(548, 22)
	title_label.size = Vector2(184, 30)
	add_child(title_label)

	wallet_label = _label("", 18, HORIZONTAL_ALIGNMENT_RIGHT)
	wallet_label.position = Vector2(808, 18)
	wallet_label.size = Vector2(440, 36)
	add_child(wallet_label)

	_setup_layers()

func _setup_layers() -> void:
	# Layer 0: 锁屏 (最底)
	var lock_layer := CanvasLayer.new()
	lock_layer.layer = 0
	lock_layer.name = "lock_layer"
	add_child(lock_layer)
	# Layer 10: 根背景
	var root_layer := CanvasLayer.new()
	root_layer.layer = 10
	root_layer.name = "root_layer"
	add_child(root_layer)
	# Layer 20: 备用底层
	var low_layer := CanvasLayer.new()
	low_layer.layer = 20
	low_layer.name = "low_layer"
	add_child(low_layer)
	# Layer 30: 主界面 View (mid)
	_mid_layer = CanvasLayer.new()
	_mid_layer.layer = 30
	_mid_layer.name = "mid_layer"
	add_child(_mid_layer)
	# Layer 40: PopUp/弹窗
	_high_layer = CanvasLayer.new()
	_high_layer.layer = 40
	_high_layer.name = "high_layer"
	add_child(_high_layer)
	# Layer 50: 系统弹窗
	var highest_layer := CanvasLayer.new()
	highest_layer.layer = 50
	highest_layer.name = "highest_layer"
	add_child(highest_layer)

func _push_view(view_name: String, params: Dictionary = {}) -> void:
	if not _all_views.is_empty():
		_all_views.back().hide()
	var container := Control.new()
	container.position = Vector2(0, 0)
	container.size = Vector2(1280, 720)
	container.name = "view_%s_%d" % [view_name, _all_views.size()]
	_mid_layer.add_child(container)
	_all_views.push_back(container)
	_view_names.push_back(view_name)
	title_label.text = view_name
	_refresh_wallet()

func _replace_view(view_name: String, params: Dictionary = {}) -> void:
	if not _all_views.is_empty():
		var old = _all_views.pop_back()
		_view_names.pop_back()
		old.queue_free()
	_push_view(view_name, params)

func _pop_view() -> void:
	if _all_views.size() <= 1:
		print("[view_stack] cannot pop last view (%s)" % (_view_names.back() if not _view_names.is_empty() else "none"))
		return
	var old = _all_views.pop_back()
	_view_names.pop_back()
	old.queue_free()
	var prev = _all_views.back()
	prev.show()
	title_label.text = _view_names.back()
	_refresh_wallet()

func _clear_mid_layer() -> void:
	for view in _all_views:
		view.queue_free()
	_all_views.clear()
	_view_names.clear()

func _current_view_name() -> String:
	return _view_names.back() if not _view_names.is_empty() else "none"

var _startup_stage := 0
var _startup_timer: Timer

func _startup_sequence() -> void:
	# Check env override
	var start_view := OS.get_environment("SHAONV_MVP_START_VIEW").to_lower()
	if not start_view.is_empty():
		_show_start_view_from_env()
		return
	
	# Default: Launch → Login → Loading → Main 全自动
	_startup_stage = 0
	_startup_timer = Timer.new()
	_startup_timer.name = "startup_state_timer"
	_startup_timer.one_shot = true
	_startup_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_startup_timer.timeout.connect(_startup_tick)
	add_child(_startup_timer)
	_startup_tick()

func _startup_step_timer(duration: float) -> Signal:
	return get_tree().create_timer(duration).timeout

func _startup_tick() -> void:
	match _startup_stage:
		0:
			_show_launch()
			_startup_stage = 1
			_startup_timer.start(1.5)
		1:
			_show_login()
			_startup_stage = 2
			_startup_timer.start(2.0)
		2:
			_show_loading()
		_:
			pass

func _show_start_view_from_env() -> void:
	var start_view := OS.get_environment("SHAONV_MVP_START_VIEW").to_lower()
	if start_view == "preloading":
		_show_preloading()
	elif start_view == "login":
		_show_login()
	elif start_view == "loading":
		_show_loading()
	elif start_view == "main":
		_enter_main_scene()
	elif start_view == "gacha":
		_enter_main_scene()
		_show_gacha()
	elif start_view == "draw_animation":
		_show_draw_animation(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10)
	elif start_view == "draw_reveal":
		gacha_result_screen.show_recruit_reveal(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10)
	elif start_view == "draw_result":
		_draw_and_show(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10)
	elif start_view == "prayer":
		_enter_main_scene()
		_open_prayer_pool()
	elif start_view == "battle":
		_enter_main_scene()
		_show_battle()
	elif start_view == "gallery":
		_enter_main_scene()
		_show_gallery()
	elif start_view == "remnants":
		_enter_main_scene()
		_show_remnants_list()
	elif start_view == "remnant_detail":
		_enter_main_scene()
		_show_remnant_detail(int(OS.get_environment("SHAONV_MVP_HERO_ID")) if not OS.get_environment("SHAONV_MVP_HERO_ID").is_empty() else int(_remnants_primary_heroes()[0].get("id", DEFAULT_HERO_ID)))
	elif start_view == "gal":
		_enter_main_scene()
		var gal_view := OS.get_environment("SHAONV_MVP_GAL_VIEW").to_lower()
		if gal_view.is_empty():
			_show_gal()
		else:
			gal_screen.show_view(gal_view)
	elif start_view == "hero_detail":
		_enter_main_scene()
		_show_hero_detail(int(OS.get_environment("SHAONV_MVP_HERO_ID")) if not OS.get_environment("SHAONV_MVP_HERO_ID").is_empty() else int(save.get("selected_hero_id", DEFAULT_HERO_ID)))
	else:
		_show_launch()

func _set_chrome_visible(visible: bool) -> void:
	top_bar.visible = visible
	title_label.visible = visible
	wallet_label.visible = visible

func _clear(title: String) -> void:
	_replace_view(title)

func _show_launch() -> void:
	startup_screen.show_launch()

func _show_preloading() -> void:
	startup_screen.show_preloading()

func _show_login() -> void:
	startup_screen.show_login()

func _show_loading() -> void:
	startup_screen.show_loading()

func _enter_main_scene() -> void:
	_set_chrome_visible(false)
	_show_home()

func _refresh_wallet() -> void:
	if top_bar != null and top_bar.get_child_count() > 1 and top_bar.get_child(1) is Button:
		top_bar.get_child(1).text = _profile_summary()
	wallet_label.text = "郵件 %d   喚靈券 %s   源石 %s" % [_unclaimed_mail_count(), save.get("tickets", 0), save.get("gems", 0)]

func _show_home() -> void:
	home_screen.show_home()

func _show_gacha() -> void:
	_push_view("喚靈")
	gacha_screen.show_gacha()

func _show_draw_animation(count: int) -> void:
	_push_view("招募演出")
	gacha_result_screen.show_draw_animation(count)

func _draw_and_show(count: int) -> void:
	_push_view("喚灵结果")
	gacha_result_screen.draw_and_show(count)

func _show_gal() -> void:
	gal_screen.show_gal()


func _show_gallery() -> void:
	_clear("英雄列表")
	_draw_hero_list_background()
	_draw_hero_list_header()
	_draw_hero_list_filters()
	_draw_hero_list_cards()

func _draw_hero_list_background() -> void:
	_draw_image(UI_HERO_BG_MAIN, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.84))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.018, 0.016, 0.025, 0.36)))
	_draw_image(UI_HERO_BG_DETAIL, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.18))
	_view_container().add_child(_panel(Vector2(20, 84), Vector2(218, 576), Color(0.04, 0.035, 0.052, 0.62)))
	_view_container().add_child(_panel(Vector2(260, 86), Vector2(980, 574), Color(0.038, 0.032, 0.050, 0.58)))


func _draw_hero_list_header() -> void:
	var header := _label("英雄圖鑑", 34)
	header.position = Vector2(38, 22)
	header.size = Vector2(240, 50)
	header.modulate = Color(1.0, 0.92, 0.76)
	_view_container().add_child(header)

	var owned_count: int = save.get("owned", {}).size()
	var progress := _label("收集進度  %d / %d" % [owned_count, heroes.size()], 20, HORIZONTAL_ALIGNMENT_RIGHT)
	progress.position = Vector2(806, 30)
	progress.size = Vector2(396, 34)
	progress.modulate = Color(0.96, 0.90, 0.82)
	_view_container().add_child(progress)

	_draw_image(UI_HERO_FILTER_BG, Vector2(836, 82), Vector2(360, 130), false, Color(1, 1, 1, 0.86))
	var sort_hint := _label("排序  戰力", 18, HORIZONTAL_ALIGNMENT_CENTER)
	sort_hint.position = Vector2(978, 94)
	sort_hint.size = Vector2(130, 28)
	_view_container().add_child(sort_hint)
	_draw_image(UI_HERO_SORT_BTN, Vector2(1142, 116), Vector2(42, 42), false, Color(1, 1, 1, 0.92))


func _draw_hero_list_filters() -> void:
	var tabs := [
		{"text": "總覽", "filter": "all"},
		{"text": "已獲得", "filter": "owned"},
		{"text": "未獲得", "filter": "unowned"},
		{"text": "四星", "filter": "r4"},
		{"text": "三星", "filter": "r3"},
		{"text": "二星", "filter": "r2"},
	]
	var y := 116.0
	for tab in tabs:
		_draw_hero_list_tab(str(tab.get("text", "")), str(tab.get("filter", "")), Vector2(42, y))
		y += 72.0


func _draw_hero_list_tab(text: String, filter: String, pos: Vector2) -> void:
	var selected := gallery_filter == filter
	if selected:
		_draw_image(UI_COMMON_TAB_HIGHLIGHT, pos, Vector2(176, 56), false, Color(1, 1, 1, 0.96))
	else:
		_view_container().add_child(_panel(pos + Vector2(8, 4), Vector2(160, 48), Color(0.10, 0.075, 0.10, 0.48)))

	var label := _label(text, 20, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos + Vector2(50, 8)
	label.size = Vector2(104, 38)
	label.modulate = Color(1.0, 0.92, 0.78) if selected else Color(0.86, 0.82, 0.78)
	_view_container().add_child(label)
	var dot_color := Color(1.0, 0.64, 0.30, 0.95) if selected else Color(0.42, 0.36, 0.44, 0.75)
	_view_container().add_child(_panel(pos + Vector2(22, 18), Vector2(18, 18), dot_color))

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = Vector2(176, 56)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		gallery_filter = filter
		_show_gallery()
	)
	_view_container().add_child(button)


func _draw_hero_list_cards() -> void:
	var filtered := _gallery_filtered_heroes()
	if filtered.is_empty():
		var empty := _label("暫無符合條件的角色", 22, HORIZONTAL_ALIGNMENT_CENTER)
		empty.position = Vector2(382, 330)
		empty.size = Vector2(720, 40)
		_view_container().add_child(empty)
		return

	var x := 290.0
	var y := 132.0
	var col := 0
	for hero in filtered:
		_draw_hero_list_card(hero, Vector2(x, y))
		col += 1
		x += 228.0
		if col >= 4:
			col = 0
			x = 290.0
			y += 178.0


func _draw_hero_list_card(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var copies := int(save.get("owned", {}).get(str(hero_id), 0))
	var shards := int(save.get("shards", {}).get(str(hero_id), 0))
	var owned := copies > 0
	var frame_color := _rarity_color(rarity, 0.26 if owned else 0.12)
	_view_container().add_child(_panel(pos, Vector2(196, 142), Color(0.045, 0.038, 0.058, 0.78)))
	_view_container().add_child(_panel(pos + Vector2(2, 2), Vector2(192, 138), frame_color))
	_draw_image(UI_HERO_HIGHLIGHT, pos + Vector2(10, 8), Vector2(80, 80), false, Color(1, 1, 1, 0.55))

	var tint := Color(1, 1, 1, 1) if owned else Color(0.42, 0.42, 0.45, 1)
	_draw_hero_thumb(hero, pos + Vector2(18, 16), Vector2(68, 72), tint)
	_draw_hero_card_stars(rarity, pos + Vector2(16, 94), 13)

	var display_name := str(hero.get("name", "Unknown")) if owned else "未獲得"
	var name_label := _label(display_name, 19)
	name_label.position = pos + Vector2(96, 18)
	name_label.size = Vector2(88, 28)
	name_label.modulate = Color(1.0, 0.94, 0.82) if owned else Color(0.72, 0.70, 0.72)
	_view_container().add_child(name_label)

	var state_text := "持有 %d  碎片 %d" % [copies, shards] if owned else "線索未解鎖"
	var state := _label(state_text, 14)
	state.position = pos + Vector2(96, 52)
	state.size = Vector2(88, 42)
	state.modulate = Color(0.92, 0.86, 0.82)
	_view_container().add_child(state)

	var power := _hero_power(hero)
	var power_label := _label("戰力 %d" % power, 14)
	power_label.position = pos + Vector2(96, 98)
	power_label.size = Vector2(88, 26)
	power_label.modulate = Color(1.0, 0.82, 0.52)
	_view_container().add_child(power_label)

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = Vector2(196, 142)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		_show_hero_detail(hero_id)
	)
	_view_container().add_child(button)

func _show_remnants_list() -> void:
	current_view = "remnants"
	_set_chrome_visible(false)
	_clear("幻靈列表")
	_draw_remnants_background()
	_draw_remnants_top_bar()
	_draw_remnants_side_filters()
	var list: Array = _remnants_primary_heroes()
	var page_size: int = 10
	var page_count: int = max(1, int(ceil(float(list.size()) / float(page_size))))
	remnants_page = clamp(remnants_page, 0, page_count - 1)
	var start: int = remnants_page * page_size
	var page_items: Array = list.slice(start, min(start + page_size, list.size()))
	_draw_remnants_section("靈能原體", Vector2(260, 82), page_items, true)
	_draw_remnants_sync_section(Vector2(260, 586), list.size(), page_count)


func _draw_remnants_background() -> void:
	_draw_image(UI_REMNANTS_BG, Vector2(0, 0), Vector2(1280, 720), true, Color(0.70, 0.76, 0.92, 0.86))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.010, 0.018, 0.035, 0.40)))
	_view_container().add_child(_panel(Vector2(0, 548), Vector2(1280, 172), Color(0.34, 0.43, 0.60, 0.30)))
	for i in range(7):
		var y := 80.0 + i * 80.0
		_view_container().add_child(_panel(Vector2(38, y), Vector2(2, 58), Color(0.45, 0.55, 0.72, 0.36)))
		_view_container().add_child(_panel(Vector2(31, y + 22), Vector2(14, 14), Color(0.90, 0.96, 1.0, 0.60)))


func _draw_remnants_top_bar() -> void:
	_add_action_button("返回", Vector2(46, 18), _show_home, Vector2(116, 38))
	_add_action_button("?", Vector2(176, 18), _show_player_info, Vector2(42, 38))
	var tabs := ["編隊", "陣容推薦", "戰力", "品質", "星級", "等級"]
	var x := 506.0
	for i in range(tabs.size()):
		var selected := i == 2
		_view_container().add_child(_panel(Vector2(x, 20), Vector2(96, 30), Color(0.10, 0.12, 0.18, 0.62)))
		var label := _label(str(tabs[i]), 15, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(x, 24)
		label.size = Vector2(96, 22)
		label.modulate = Color(0.80, 1.0, 0.18) if selected else Color(0.95, 0.95, 0.98)
		_view_container().add_child(label)
		x += 96


func _draw_remnants_side_filters() -> void:
	var filters := [
		["全部", Color(0.66, 0.94, 0.20, 1)],
		["水相", Color(0.82, 0.92, 1.0, 1)],
		["風相", Color(0.82, 1.0, 0.88, 1)],
		["火相", Color(1.0, 0.78, 0.62, 1)],
		["土相", Color(0.98, 0.90, 0.72, 1)],
		["輝星", Color(0.88, 0.90, 1.0, 1)]
	]
	var y := 120.0
	for i in range(filters.size()):
		var selected := i == 0
		if selected:
			_view_container().add_child(_panel(Vector2(58, y - 12), Vector2(108, 30), Color(0.38, 0.58, 0.12, 0.72)))
		var bullet := _panel(Vector2(72, y - 5), Vector2(16, 16), filters[i][1])
		_view_container().add_child(bullet)
		var label := _label(str(filters[i][0]), 17)
		label.position = Vector2(106, y - 9)
		label.size = Vector2(86, 26)
		label.modulate = Color(0.88, 1.0, 0.58) if selected else Color(0.96, 0.96, 1.0)
		_view_container().add_child(label)
		y += 64


func _draw_remnants_section(title: String, pos: Vector2, list: Array, featured: bool) -> void:
	_draw_remnants_section_header(title, pos)
	var columns := 5
	var start_x := pos.x + 98
	for i in range(list.size()):
		var col := i % columns
		var row := i / columns
		_draw_remnants_card(list[i], Vector2(start_x + col * 132.0, pos.y + 48 + row * 214.0), featured)


func _draw_remnants_sync_section(pos: Vector2, total_count: int, page_count: int) -> void:
	_draw_remnants_section_header("同調者", pos)
	var tip := _label("當前共用養成：幻靈等級-86級  靈階-0星  靈裝-紫色Lv.30  靈裝強化-20級", 16)
	tip.position = pos + Vector2(190, 7)
	tip.size = Vector2(730, 26)
	tip.modulate = Color(1.0, 0.94, 0.58)
	_view_container().add_child(tip)
	var count := _label("全部幻靈：%d  第 %d/%d 頁" % [total_count, remnants_page + 1, page_count], 15, HORIZONTAL_ALIGNMENT_RIGHT)
	count.position = pos + Vector2(606, 7)
	count.size = Vector2(224, 24)
	count.modulate = Color(0.82, 0.94, 1.0)
	_view_container().add_child(count)
	_add_action_button("上一頁", pos + Vector2(646, 42), func() -> void:
		remnants_page = max(0, remnants_page - 1)
		_show_remnants_list()
	, Vector2(82, 36))
	_add_action_button("下一頁", pos + Vector2(742, 42), func() -> void:
		remnants_page = min(page_count - 1, remnants_page + 1)
		_show_remnants_list()
	, Vector2(82, 36))


func _draw_remnants_section_header(title: String, pos: Vector2) -> void:
	_view_container().add_child(_panel(pos, Vector2(846, 30), Color(0.08, 0.10, 0.18, 0.76)))
	var marker := _panel(pos + Vector2(12, 7), Vector2(18, 16), Color(0.68, 0.96, 0.22, 0.95))
	_view_container().add_child(marker)
	var label := _label(title, 18)
	label.position = pos + Vector2(42, 3)
	label.size = Vector2(180, 26)
	label.modulate = Color(0.78, 1.0, 0.32)
	_view_container().add_child(label)


func _draw_remnants_card(hero: Dictionary, pos: Vector2, featured: bool) -> void:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var level := 78 + rarity * 4 + hero_id % 13
	var card_size := Vector2(118, 202)
	var frame_color := Color(0.92, 0.64, 0.20, 0.90) if rarity >= 4 else Color(0.34, 0.62, 0.92, 0.86)
	_view_container().add_child(_panel(pos, card_size, Color(0.04, 0.055, 0.085, 0.88)))
	_view_container().add_child(_panel(pos + Vector2(2, 2), card_size - Vector2(4, 4), Color(frame_color.r, frame_color.g, frame_color.b, 0.22)))
	_draw_hero_thumb(hero, pos + Vector2(6, 6), Vector2(106, 142), Color(1, 1, 1, 1))
	_view_container().add_child(_panel(pos + Vector2(4, 150), Vector2(110, 48), Color(0.45, 0.25, 0.06, 0.84)))
	var rare := _label("SSR", 24)
	rare.position = pos + Vector2(10, 154)
	rare.size = Vector2(58, 30)
	rare.modulate = Color(1.0, 0.82, 0.36)
	_view_container().add_child(rare)
	var level_label := _label("等級%d" % level, 12, HORIZONTAL_ALIGNMENT_RIGHT)
	level_label.position = pos + Vector2(58, 154)
	level_label.size = Vector2(54, 18)
	level_label.modulate = Color(1.0, 0.96, 0.88)
	_view_container().add_child(level_label)
	var name := _label(str(hero.get("name", "幻靈")), 13, HORIZONTAL_ALIGNMENT_RIGHT)
	name.position = pos + Vector2(48, 174)
	name.size = Vector2(62, 20)
	name.modulate = Color(1.0, 0.96, 0.88)
	_view_container().add_child(name)
	if featured:
		_draw_red_dot(pos + Vector2(104, -6))
		var tag := _label("特薦", 13, HORIZONTAL_ALIGNMENT_CENTER)
		tag.position = pos + Vector2(75, 4)
		tag.size = Vector2(38, 18)
		tag.modulate = Color(1.0, 0.98, 0.20)
		_view_container().add_child(tag)
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos
	button.size = card_size
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		_show_remnant_detail(hero_id)
	)
	_view_container().add_child(button)


func _show_remnant_detail(hero_id: int) -> void:
	selected_remnant_id = hero_id
	current_view = "remnant_detail"
	_set_chrome_visible(false)
	var hero := _hero_by_id(hero_id)
	_clear("幻靈詳情")
	_draw_remnant_detail_background(hero)
	_draw_remnant_detail_left_strip(hero_id)
	_draw_remnant_detail_tabs()
	_draw_hero_stage(hero, Vector2(160, -74), Vector2(760, 840), false)
	_draw_remnant_detail_panel(hero)


func _draw_remnant_detail_background(hero: Dictionary) -> void:
	_draw_image(UI_HERO_BG_DETAIL, Vector2(0, 0), Vector2(1280, 720), true, Color(0.92, 0.94, 1.0, 0.96))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.012, 0.018, 0.030, 0.32)))
	if int(hero.get("id", 0)) == 240069:
		_draw_image(UI_REMNANT_STAGE_BG, Vector2(154, -394), Vector2(700, 1400), false, Color(1.0, 1.0, 1.0, 0.90))
		_view_container().add_child(_panel(Vector2(760, 0), Vector2(520, 720), Color(0.010, 0.014, 0.026, 0.38)))
	_view_container().add_child(_panel(Vector2(250, 0), Vector2(520, 720), Color(0.92, 0.78, 0.42, 0.05)))
	_view_container().add_child(_panel(Vector2(846, 26), Vector2(352, 520), Color(0.020, 0.024, 0.038, 0.42)))
	_add_action_button("返回", Vector2(46, 18), _show_remnants_list, Vector2(116, 38))
	_add_action_button("?", Vector2(176, 18), _show_player_info, Vector2(42, 38))


func _draw_remnant_detail_left_strip(selected_id: int) -> void:
	var list := _remnants_primary_heroes()
	var selected_index := 0
	for i in range(list.size()):
		if int(list[i].get("id", 0)) == selected_id:
			selected_index = i
			break
	var start: int = clamp(selected_index - 2, 0, max(0, list.size() - 7))
	var visible := list.slice(start, min(start + 7, list.size()))
	_draw_image(UI_HERO_SELECTOR_BG, Vector2(26, 66), Vector2(76, 628), false, Color(1, 1, 1, 0.90))
	_draw_image(UI_HERO_SELECTOR_TOP, Vector2(26, 646), Vector2(76, 42), false, Color(1, 1, 1, 0.82))
	for i in range(visible.size()):
		var hero: Dictionary = visible[i]
		var pos := Vector2(33, 73 + i * 82.0)
		var is_selected := int(hero.get("id", 0)) == selected_id
		if is_selected:
			_draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(15, 15), Vector2(100, 100), false, Color(1, 1, 1, 0.86))
		_draw_hero_round_thumb(hero, pos, Vector2(70, 70), Color(1, 1, 1, 1))
		_draw_image(UI_COMMON_HERO_HEAD_FRAME, pos, Vector2(70, 70), false, Color(1, 1, 1, 0.92))
		_draw_image(UI_COMMON_HERO_STAR_BAR, pos + Vector2(0, 62), Vector2(70, 12), false, Color(1, 1, 1, 0.42))
		var stars := _label("★★★★★", 8, HORIZONTAL_ALIGNMENT_CENTER)
		stars.position = pos + Vector2(0, 61)
		stars.size = Vector2(70, 12)
		stars.modulate = Color(1.0, 1.0, 1.0, 0.72)
		_view_container().add_child(stars)
		var level := _label(str(_remnant_level(hero)), 11, HORIZONTAL_ALIGNMENT_RIGHT)
		level.position = pos + Vector2(36, 2)
		level.size = Vector2(26, 16)
		level.modulate = Color(1.0, 0.96, 0.76)
		_view_container().add_child(level)
		var hero_id := int(hero.get("id", 0))
		var button := Button.new()
		button.text = ""
		button.flat = true
		button.position = pos - Vector2(6, 6)
		button.size = Vector2(70, 78)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void:
			_show_remnant_detail(hero_id)
		)
		_view_container().add_child(button)


func _draw_remnant_detail_tabs() -> void:
	var tabs := [
		["主頁", UI_HERO_TAB_HOME, Color(0.70, 1.0, 0.22)],
		["養成", UI_HERO_TAB_CULTIVATE, Color(1, 1, 1)],
		["靈裝", UI_HERO_TAB_EQUIP, Color(1, 1, 1)],
		["靈階", UI_HERO_TAB_STAGE, Color(1, 1, 1)]
	]
	var y := 104.0
	for i in range(tabs.size()):
		var selected := i == 0
		if selected:
			_view_container().add_child(_panel(Vector2(130, y - 19), Vector2(104, 48), Color(0.08, 0.14, 0.09, 0.58)))
		_draw_image(str(tabs[i][1]), Vector2(132, y - 26), Vector2(54, 54), false, Color(0.78, 1.0, 0.22, 1.0) if selected else Color(0.92, 0.96, 1.0, 0.96))
		var label := _label(str(tabs[i][0]), 21)
		label.position = Vector2(190, y - 12)
		label.size = Vector2(86, 28)
		label.modulate = tabs[i][2]
		_view_container().add_child(label)
		y += 72


func _draw_remnant_detail_panel(hero: Dictionary) -> void:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var level := _remnant_level(hero)
	var pos := Vector2(876, 54)
	var type_name := _remnant_element_name(hero_id)
	var role := _remnant_role_name(hero_id)
	var small := _label(_remnant_title_name(hero_id), 16)
	small.position = pos
	small.size = Vector2(180, 24)
	small.modulate = Color(1.0, 0.82, 0.34)
	_view_container().add_child(small)
	var name := _label(str(hero.get("name", "幻靈")), 30)
	name.position = pos + Vector2(0, 26)
	name.size = Vector2(210, 42)
	name.modulate = Color(1.0, 1.0, 1.0)
	_view_container().add_child(name)
	var ssr := _label("SSR", 36, HORIZONTAL_ALIGNMENT_RIGHT)
	ssr.position = pos + Vector2(224, 2)
	ssr.size = Vector2(96, 50)
	ssr.modulate = Color(1.0, 0.76, 0.24)
	_view_container().add_child(ssr)
	_view_container().add_child(_panel(pos + Vector2(0, 88), Vector2(284, 2), Color(0.84, 0.90, 1.0, 0.22)))
	_draw_remnant_stars(_remnant_star_level(hero), pos + Vector2(12, 108))
	var role_label := _label("狂刃" if role == "attack" else "守護", 17, HORIZONTAL_ALIGNMENT_CENTER)
	role_label.position = pos + Vector2(176, 112)
	role_label.size = Vector2(70, 24)
	_view_container().add_child(role_label)
	var element := _label(type_name, 17, HORIZONTAL_ALIGNMENT_CENTER)
	element.position = pos + Vector2(260, 112)
	element.size = Vector2(70, 24)
	_view_container().add_child(element)
	var desc := _label("反擊疊暴    暴擊輸出", 15)
	desc.position = pos + Vector2(12, 150)
	desc.size = Vector2(260, 24)
	desc.modulate = Color(0.92, 0.92, 1.0)
	_view_container().add_child(desc)
	_view_container().add_child(_panel(pos + Vector2(0, 188), Vector2(284, 2), Color(0.84, 0.90, 1.0, 0.18)))

	var power := _remnant_power(hero)
	var level_label := _label("等級", 17)
	level_label.position = pos + Vector2(10, 214)
	level_label.size = Vector2(90, 24)
	_view_container().add_child(level_label)
	var level_value := _label("%d/180" % level, 22)
	level_value.position = pos + Vector2(10, 240)
	level_value.size = Vector2(130, 30)
	level_value.modulate = Color(0.72, 1.0, 0.18)
	_view_container().add_child(level_value)
	var power_title := _label("戰力", 20, HORIZONTAL_ALIGNMENT_CENTER)
	power_title.position = pos + Vector2(178, 214)
	power_title.size = Vector2(106, 28)
	power_title.modulate = Color(1.0, 0.95, 0.48)
	_view_container().add_child(power_title)
	var power_label := _label(str(power), 20, HORIZONTAL_ALIGNMENT_CENTER)
	power_label.position = pos + Vector2(178, 244)
	power_label.size = Vector2(106, 30)
	power_label.modulate = Color(1.0, 0.90, 0.40)
	_view_container().add_child(power_label)
	var attrs := _remnant_attrs(hero)
	_draw_remnant_attr("攻擊", str(attrs["攻擊"]), pos + Vector2(10, 294))
	_draw_remnant_attr("生命", str(attrs["生命"]), pos + Vector2(178, 294))
	_draw_remnant_attr("防禦", str(attrs["防禦"]), pos + Vector2(10, 326))
	_draw_remnant_attr("速度", str(attrs["速度"]), pos + Vector2(178, 326))
	_add_action_button("詳情屬性", pos + Vector2(0, 372), _show_player_info, Vector2(284, 28))
	_draw_remnant_skill_badges(hero, pos + Vector2(8, 408))


func _draw_remnant_stars(rarity: int, pos: Vector2) -> void:
	for i in range(5):
		var path := UI_COMMON_STAR if i < rarity else UI_COMMON_STAR_OFF
		_draw_image(path, pos + Vector2(i * 28.0, 0), Vector2(26, 26), false, Color(1, 1, 1, 0.96))


func _draw_remnant_skill_badges(hero: Dictionary, pos: Vector2) -> void:
	var skill_paths: Array = hero.get("skillResources", [])
	for i in range(4):
		var icon_pos := pos + Vector2(i * 68.0, 0)
		_draw_image(UI_COMMON_SKILL_FRAME, icon_pos, Vector2(62, 62), false, Color(1.0, 0.86, 0.28, 0.36))
		if i < skill_paths.size():
			_draw_image(_godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(3, 3), Vector2(56, 56), false, Color(1, 1, 1, 0.98))
		else:
			var icon := _label("威", 24, HORIZONTAL_ALIGNMENT_CENTER)
			icon.position = icon_pos + Vector2(3, 16)
			icon.size = Vector2(56, 30)
			icon.modulate = Color(1.0, 0.96, 0.62)
			_view_container().add_child(icon)


func _draw_remnant_attr(label_text: String, value_text: String, pos: Vector2) -> void:
	var label := _label(label_text, 15)
	label.position = pos
	label.size = Vector2(58, 22)
	label.modulate = Color(0.94, 0.94, 1.0)
	_view_container().add_child(label)
	var value := _label(value_text, 16, HORIZONTAL_ALIGNMENT_RIGHT)
	value.position = pos + Vector2(60, 0)
	value.size = Vector2(72, 22)
	value.modulate = Color(1.0, 1.0, 1.0)
	_view_container().add_child(value)


func _remnant_power(hero: Dictionary) -> int:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	if hero_id == 240069:
		return 274369
	return 88000 + rarity * 42000 + (hero_id % 100) * 1137


func _remnant_attrs(hero: Dictionary) -> Dictionary:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	if hero_id == 240069:
		return {
			"攻擊": 23746,
			"生命": 212970,
			"防禦": 1805,
			"速度": 104,
		}
	return {
		"攻擊": 16400 + rarity * 1800 + hero_id % 900,
		"生命": 145000 + rarity * 18500 + (hero_id % 100) * 210,
		"防禦": 1300 + rarity * 120 + hero_id % 90,
		"速度": 96 + rarity * 2 + hero_id % 5,
	}


func _remnant_level(hero: Dictionary) -> int:
	var hero_id := int(hero.get("id", 0))
	if hero_id == 240069:
		return 100
	return 78 + int(hero.get("rarity", 1)) * 4 + hero_id % 13


func _remnant_star_level(hero: Dictionary) -> int:
	var hero_id := int(hero.get("id", 0))
	if hero_id == 240069:
		return 2
	return int(hero.get("rarity", 1))


func _remnant_title_name(hero_id: int) -> String:
	if hero_id == 240069:
		return "昭陽"
	return _remnant_element_name(hero_id)


func _remnant_element_name(hero_id: int) -> String:
	if hero_id == 240069:
		return "土相"
	var names := ["水相", "風相", "火相", "土相", "輝星"]
	return names[hero_id % names.size()]


func _remnant_role_name(hero_id: int) -> String:
	if hero_id == 240069:
		return "attack"
	return "attack" if hero_id % 2 == 0 else "guard"


func _remnants_primary_heroes() -> Array:
	var list := heroes.duplicate(true)
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("rarity", 1)) > int(b.get("rarity", 1)) if int(a.get("rarity", 1)) != int(b.get("rarity", 1)) else int(a.get("id", 0)) < int(b.get("id", 0))
	)
	return list


func _remnants_sync_heroes() -> Array:
	var list := _remnants_primary_heroes()
	return list.slice(2, min(list.size(), 10))

func _show_history() -> void:
	_clear("記錄")
	var lines := []
	for row in save.get("history", []):
		lines.append("%s %s\n%s" % [row.get("time", ""), row.get("pool_name", ""), row.get("result_text", "")])
	var label := _label("\n\n".join(lines) if not lines.is_empty() else "暫無抽卡記錄", 18)
	label.position = Vector2(44, 44)
	label.size = Vector2(1080, 440)
	_view_container().add_child(label)
	_add_action_button("重置存檔", Vector2(44, 524), func() -> void:
		save = {
			"tickets": 120,
			"gems": 16800,
			"profile": {
				"name": "Player",
				"level": 88,
				"base_power": 999999
			},
			"settings": {
				"wallpaper_auto_play": true,
				"music": true,
				"effects": true
			},
			"owned": {},
			"shards": {},
			"pity": {},
			"history": [],
			"draw_count": 0,
			"claimed_tasks": {},
			"claimed_mail": {},
			"daily_claimed_date": "",
			"selected_hero_id": DEFAULT_HERO_ID,
			"active_pool_id": "advanced"
		}
		_persist()
		_show_home()
	)
	_add_action_button("返回主界面", Vector2(190, 524), _show_home, Vector2(146, 44))

func _perform_draw(count: int) -> Array:
	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	var cost := count * int(pool.get("ticketCost", 1))
	if int(save.get("tickets", 0)) < cost:
		return []
	save["tickets"] = int(save.get("tickets", 0)) - cost
	save["draw_count"] = int(save.get("draw_count", 0)) + count
	var results: Array = []
	for i in range(count):
		results.append(_draw_one(pool))
	var history: Array = save.get("history", [])
	history.push_front({
		"time": Time.get_datetime_string_from_system(false, true),
		"pool_name": pool.get("name", ""),
		"result_text": "、".join(results.map(func(result): return "%s%s" % [result.get("hero", {}).get("name", ""), "(NEW)" if result.get("is_new", false) else ""]))
	})
	while history.size() > 30:
		history.pop_back()
	save["history"] = history
	_persist()
	return results

func _draw_one(pool: Dictionary) -> Dictionary:
	var pool_id := str(pool.get("id", "advanced"))
	var pity := _pity(pool_id) + 1
	var rarity := 2
	var roll := rng.randf()
	var rates: Dictionary = pool.get("rates", {"4": 0.02, "3": 0.14, "2": 0.84})
	var rare4_rate := float(rates.get("4", 0.02))
	var rare3_rate := float(rates.get("3", 0.14))
	if pity >= int(pool.get("pityLimit", 60)) or roll < rare4_rate:
		rarity = 4
		pity = 0
	elif roll < rare4_rate + rare3_rate:
		rarity = 3
	_set_pity(pool_id, pity)

	var candidates := []
	for hero in heroes:
		var hero_rarity := int(hero.get("rarity", 1))
		if rarity == 4:
			if hero_rarity == 4 or pool.get("featuredHeroIds", []).has(int(hero.get("id", 0))):
				candidates.append(hero)
		elif hero_rarity == rarity:
			candidates.append(hero)
	if candidates.is_empty():
		candidates = heroes.duplicate()

	var featured := []
	for hero in candidates:
		if pool.get("featuredHeroIds", []).has(int(hero.get("id", 0))):
			featured.append(hero)
	var list := featured if rarity >= 3 and not featured.is_empty() and rng.randf() < float(pool.get("upRate", 0.55)) else candidates
	var hero: Dictionary = list[rng.randi_range(0, list.size() - 1)]
	var owned: Dictionary = save.get("owned", {})
	var shards: Dictionary = save.get("shards", {})
	var key := str(hero.get("id", 0))
	var is_new := not owned.has(key)
	owned[key] = int(owned.get(key, 0)) + 1
	var shard_gain := 0 if is_new else _duplicate_shards(pool, int(hero.get("rarity", 1)))
	if shard_gain > 0:
		shards[key] = int(shards.get(key, 0)) + shard_gain
	save["owned"] = owned
	save["shards"] = shards
	return {"hero": hero, "rolled_rarity": max(rarity, int(hero.get("rarity", 1))), "is_new": is_new, "shards": shard_gain}

func _show_hero_detail(hero_id: int) -> void:
	var hero := _hero_by_id(hero_id)
	_clear(str(hero.get("name", "角色")))
	_draw_hero_detail_background()
	_draw_hero_selector_strip(hero_id)
	_draw_hero_stage(hero, Vector2(300, 34), Vector2(500, 650), false)
	_draw_hero_detail_tabs(Vector2(720, 38), "總覽")
	_draw_hero_detail_summary(hero, Vector2(720, 104))
	_draw_hero_detail_info_panel(hero, Vector2(706, 382))

	var key := str(hero.get("id", 0))
	var copies := int(save.get("owned", {}).get(key, 0))
	if copies <= 0:
		var mask := _panel(Vector2(300, 34), Vector2(500, 650), Color(0.0, 0.0, 0.0, 0.42))
		_view_container().add_child(mask)
		var locked := _label("未獲得", 36, HORIZONTAL_ALIGNMENT_CENTER)
		locked.position = Vector2(300, 304)
		locked.size = Vector2(500, 56)
		_view_container().add_child(locked)
		_add_action_button("前往喚靈", Vector2(1004, 636), _show_gacha, Vector2(132, 44))
	else:
		_add_action_button("設為看板", Vector2(1004, 636), func() -> void:
			save["selected_hero_id"] = hero_id
			_persist()
			_show_home()
		, Vector2(132, 44))
	_add_action_button("返回列表", Vector2(858, 636), _show_gallery, Vector2(132, 44))


func _draw_hero_detail_background() -> void:
	_draw_image(UI_HERO_BG_MAIN, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.76))
	_draw_image(UI_HERO_BG_DETAIL, Vector2(0, 0), Vector2(1280, 720), true, Color(1, 1, 1, 0.32))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0.014, 0.012, 0.020, 0.30)))
	_view_container().add_child(_panel(Vector2(36, 80), Vector2(100, 560), Color(0.035, 0.030, 0.050, 0.68)))
	_draw_image(UI_HERO_SELECTOR_BG, Vector2(36, 80), Vector2(100, 560), true, Color(1, 1, 1, 0.76))
	_draw_image(UI_HERO_SELECTOR_TOP, Vector2(36, 80), Vector2(100, 48), false, Color(1, 1, 1, 0.92))
	_view_container().add_child(_panel(Vector2(690, 22), Vector2(548, 676), Color(0.030, 0.024, 0.040, 0.62)))


func _draw_hero_selector_strip(selected_hero_id: int) -> void:
	var y := 142.0
	for hero in _hero_selector_heroes():
		var hero_id := int(hero.get("id", 0))
		var selected = hero_id == selected_hero_id
		_draw_hero_selector_grid(hero, Vector2(52, y), selected)
		y += 82.0


func _hero_selector_heroes() -> Array:
	var list := heroes.duplicate(true)
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("rarity", 1)) > int(b.get("rarity", 1)) if int(a.get("rarity", 1)) != int(b.get("rarity", 1)) else int(a.get("id", 0)) < int(b.get("id", 0))
	)
	return list.slice(0, min(6, list.size()))


func _draw_hero_selector_grid(hero: Dictionary, pos: Vector2, selected: bool) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	if selected:
		_draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(10, 10), Vector2(90, 90), false, Color(1, 1, 1, 0.72))
	else:
		_view_container().add_child(_panel(pos - Vector2(4, 4), Vector2(78, 78), Color(0.08, 0.065, 0.09, 0.58)))
	_draw_hero_thumb(hero, pos, Vector2(70, 70), Color(1, 1, 1, 1))
	_draw_hero_card_stars(rarity, pos + Vector2(8, 58), 10)

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.position = pos - Vector2(6, 6)
	button.size = Vector2(82, 82)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		_show_hero_detail(hero_id)
	)
	_view_container().add_child(button)


func _draw_hero_detail_tabs(pos: Vector2, selected: String) -> void:
	var tabs := ["總覽", "屬性", "技能", "羈絆"]
	var x := pos.x
	for tab in tabs:
		var is_selected = tab == selected
		if is_selected:
			_draw_image(UI_COMMON_TAB_HIGHLIGHT, Vector2(x, pos.y), Vector2(132, 48), false, Color(1, 1, 1, 0.92))
		else:
			_view_container().add_child(_panel(Vector2(x + 8, pos.y + 6), Vector2(116, 36), Color(0.075, 0.058, 0.083, 0.62)))
		var label := _label(tab, 18, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(x + 18, pos.y + 8)
		label.size = Vector2(96, 28)
		label.modulate = Color(1.0, 0.92, 0.74) if is_selected else Color(0.82, 0.78, 0.78)
		_view_container().add_child(label)
		x += 126.0


func _draw_hero_detail_summary(hero: Dictionary, pos: Vector2) -> void:
	var hero_id := int(hero.get("id", 0))
	var rarity := int(hero.get("rarity", 1))
	var key := str(hero_id)
	var copies := int(save.get("owned", {}).get(key, 0))
	var shards := int(save.get("shards", {}).get(key, 0))
	var owned := copies > 0

	_draw_image(UI_COMMON_HEAD_FRAME, pos, Vector2(118, 118), false, Color(1, 1, 1, 0.92))
	_draw_hero_thumb(hero, pos + Vector2(10, 10), Vector2(98, 98), Color(1, 1, 1, 1) if owned else Color(0.48, 0.48, 0.50, 1))

	var title := _label(str(hero.get("name", "角色")), 34)
	title.position = pos + Vector2(136, 4)
	title.size = Vector2(240, 48)
	title.modulate = Color(1.0, 0.92, 0.76)
	_view_container().add_child(title)

	var spine := _label("Spine  %s" % str(hero.get("spine", "")), 17)
	spine.position = pos + Vector2(138, 52)
	spine.size = Vector2(280, 26)
	spine.modulate = Color(0.90, 0.84, 0.78)
	_view_container().add_child(spine)

	_view_container().add_child(_panel(pos + Vector2(388, 10), Vector2(98, 44), _rarity_color(rarity, 0.50)))
	var rare_label := _label("R%d" % rarity, 20, HORIZONTAL_ALIGNMENT_CENTER)
	rare_label.position = pos + Vector2(388, 18)
	rare_label.size = Vector2(98, 28)
	rare_label.modulate = Color(1.0, 0.92, 0.72)
	_view_container().add_child(rare_label)
	_draw_hero_card_stars(rarity, pos + Vector2(136, 86), 28)

	var state_text := "已獲得  持有 %d  碎片 %d" % [copies, shards] if owned else "未獲得  碎片 %d" % shards
	var state := _label(state_text, 18)
	state.position = pos + Vector2(300, 88)
	state.size = Vector2(220, 28)
	state.modulate = Color(1.0, 0.82, 0.58)
	_view_container().add_child(state)

	var power_panel := _panel(pos + Vector2(0, 144), Vector2(496, 52), Color(0.07, 0.052, 0.075, 0.78))
	_view_container().add_child(power_panel)
	var power := _label("戰力  %d" % _hero_power(hero), 24)
	power.position = pos + Vector2(22, 152)
	power.size = Vector2(190, 36)
	power.modulate = Color(1.0, 0.82, 0.45)
	_view_container().add_child(power)
	var route := _label("獲得途徑  喚靈 / 祈願 / 活動", 17, HORIZONTAL_ALIGNMENT_RIGHT)
	route.position = pos + Vector2(214, 156)
	route.size = Vector2(260, 30)
	route.modulate = Color(0.92, 0.86, 0.82)
	_view_container().add_child(route)


func _draw_hero_detail_info_panel(hero: Dictionary, pos: Vector2) -> void:
	_draw_image(UI_HERO_DETAIL_INFO_BG, pos, Vector2(540, 240), true, Color(1, 1, 1, 0.86))
	_view_container().add_child(_panel(pos, Vector2(540, 240), Color(0.025, 0.020, 0.035, 0.30)))

	_draw_hero_section_header("屬性詳情", pos + Vector2(18, 18), Vector2(250, 30))
	_draw_hero_section_header("技能列表", pos + Vector2(276, 18), Vector2(246, 30))

	var attrs := _hero_attrs(hero)
	var x1 := pos.x + 34
	var y := pos.y + 66
	var index := 0
	for key in attrs.keys():
		var col := index / 4
		var row := index % 4
		var ax := x1 + col * 128.0
		var ay := y + row * 32.0
		var label := _label(str(key), 15)
		label.position = Vector2(ax, ay)
		label.size = Vector2(66, 24)
		label.modulate = Color(0.92, 0.86, 0.80)
		_view_container().add_child(label)
		var value := _label(str(attrs[key]), 15, HORIZONTAL_ALIGNMENT_RIGHT)
		value.position = Vector2(ax + 58, ay)
		value.size = Vector2(52, 24)
		value.modulate = Color(1.0, 0.86, 0.60)
		_view_container().add_child(value)
		index += 1

	var skill_paths: Array = hero.get("skillResources", [])
	var sx := pos.x + 294
	for i in range(4):
		var icon_pos := Vector2(sx + i * 56.0, pos.y + 68)
		_draw_image(UI_COMMON_SKILL_FRAME, icon_pos, Vector2(48, 48), false, Color(1, 1, 1, 0.78))
		if i < skill_paths.size():
			_draw_image(_godot_resource_path(str(skill_paths[i])), icon_pos + Vector2(4, 4), Vector2(40, 40), false)
		var skill_label := _label("技能%d" % (i + 1), 11, HORIZONTAL_ALIGNMENT_CENTER)
		skill_label.position = icon_pos + Vector2(-4, 48)
		skill_label.size = Vector2(56, 20)
		_view_container().add_child(skill_label)

	_draw_hero_section_header("靈裝 / 源神 / 神具", pos + Vector2(276, 150), Vector2(246, 30))
	var equip := _label("MVP 裝備槽位已按 HeroDetailInfoView 區塊預留，後續接裝備表即可填充。", 14)
	equip.position = pos + Vector2(292, 184)
	equip.size = Vector2(216, 42)
	equip.modulate = Color(0.92, 0.86, 0.82)
	_view_container().add_child(equip)


func _draw_hero_section_header(text: String, pos: Vector2, size: Vector2) -> void:
	_draw_image(UI_COMMON_SECTION, pos, size, true, Color(1, 1, 1, 0.78))
	var label := _label(text, 15, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos
	label.size = size
	label.modulate = Color(1.0, 0.92, 0.78)
	_view_container().add_child(label)


func _draw_hero_card_stars(rarity: int, pos: Vector2, size: int) -> void:
	if size < 20:
		var badge := _label("R%d" % clamp(rarity, 1, 5), size + 2, HORIZONTAL_ALIGNMENT_CENTER)
		badge.position = pos
		badge.size = Vector2(38, size + 10)
		badge.modulate = Color(1.0, 0.86, 0.52)
		_view_container().add_child(badge)
		return
	for i in range(clamp(rarity, 1, 5)):
		var star_path := UI_COMMON_STAR if size >= 20 else UI_HERO_STAR_SMALL
		_draw_image(star_path, pos + Vector2(i * (size * 0.74), 0), Vector2(size, size), false, Color(1, 1, 1, 0.96))


func _hero_power(hero: Dictionary) -> int:
	var rarity := int(hero.get("rarity", 1))
	var hero_id := int(hero.get("id", 0))
	var owned := int(save.get("owned", {}).get(str(hero_id), 0))
	return 2600 + rarity * 920 + max(owned, 1) * 360 + (hero_id % 100) * 13


func _hero_attrs(hero: Dictionary) -> Dictionary:
	var rarity := int(hero.get("rarity", 1))
	var power := _hero_power(hero)
	return {
		"攻擊": 900 + rarity * 220,
		"防禦": 520 + rarity * 150,
		"生命": 5200 + rarity * 1280,
		"速度": 92 + rarity * 7,
		"命中": "%d%%" % (82 + rarity * 3),
		"暴擊": "%d%%" % (12 + rarity * 4),
		"抗暴": "%d%%" % (8 + rarity * 3),
		"戰力": power,
	}

func _show_player_info() -> void:
	_clear("玩家信息")
	var profile: Dictionary = save.get("profile", {})
	var settings: Dictionary = save.get("settings", {})
	var panel := _panel(Vector2(44, 44), Vector2(620, 360), Color(0.095, 0.078, 0.065, 0.94))
	_view_container().add_child(panel)
	var info := _label("玩家資料\n名稱：%s\n等級：%d\n戰力：%d\n\n收集武將：%d\n累計喚靈：%d\n看板自動播放：%s" % [
		profile.get("name", "Player"),
		int(profile.get("level", 1)),
		_player_power(),
		save.get("owned", {}).size(),
		int(save.get("draw_count", 0)),
		"開" if bool(settings.get("wallpaper_auto_play", true)) else "關"
	], 21)
	info.position = Vector2(70, 70)
	info.size = Vector2(520, 230)
	_view_container().add_child(info)
	_add_action_button("設定", Vector2(70, 330), _show_settings)
	_add_action_button("返回主界面", Vector2(216, 330), _show_home, Vector2(146, 44))

func _show_settings() -> void:
	_clear("設定")
	var settings: Dictionary = save.get("settings", {})
	var panel := _panel(Vector2(44, 44), Vector2(700, 370), Color(0.095, 0.078, 0.065, 0.94))
	_view_container().add_child(panel)
	var title := _label("SystemSettingView MVP", 30)
	title.position = Vector2(70, 70)
	title.size = Vector2(440, 44)
	_view_container().add_child(title)
	_add_toggle_button("看板自動播放", "wallpaper_auto_play", Vector2(70, 140), bool(settings.get("wallpaper_auto_play", true)))
	_add_toggle_button("音樂", "music", Vector2(70, 202), bool(settings.get("music", true)))
	_add_toggle_button("音效", "effects", Vector2(70, 264), bool(settings.get("effects", true)))
	_add_action_button("玩家信息", Vector2(70, 340), _show_player_info)
	_add_action_button("返回主界面", Vector2(216, 340), _show_home, Vector2(146, 44))

func _show_shop() -> void:
	_clear("商店")
	var title := _label("資源補給", 34)
	title.position = Vector2(44, 44)
	title.size = Vector2(420, 52)
	_view_container().add_child(title)
	var desc := _label("單機 MVP 暫定兌換規則：源石 %d = 喚靈券 %d。日常、郵件和章節任務也會產出喚靈資源。" % [int(shop.get("exchangeGemCost", 160)), int(shop.get("ticketAmount", 1))], 20)
	desc.position = Vector2(44, 112)
	desc.size = Vector2(760, 72)
	_view_container().add_child(desc)
	_add_action_button("兌換 1 張", Vector2(44, 210), func() -> void: _buy_tickets(1))
	_add_action_button("兌換 10 張", Vector2(190, 210), func() -> void: _buy_tickets(10))
	_add_action_button("每日補給", Vector2(336, 210), _show_daily)
	_add_action_button("郵件", Vector2(482, 210), _show_mail)
	_add_action_button("任務", Vector2(628, 210), _show_tasks)
	_add_action_button("前往喚靈", Vector2(44, 284), _show_gacha)

func _show_daily() -> void:
	_clear("每日補給")
	var today := Time.get_date_string_from_system()
	var claimed := str(save.get("daily_claimed_date", "")) == today
	var reward_tickets := int(daily.get("tickets", 3))
	var reward_gems := int(daily.get("gems", 480))
	var title := _label(str(daily.get("name", "每日補給")), 34)
	title.position = Vector2(44, 44)
	title.size = Vector2(420, 52)
	_view_container().add_child(title)
	var text := "%s\n喚靈券 x%d\n源石 x%d\n\n狀態：%s" % [daily.get("desc", "今日補給"), reward_tickets, reward_gems, "已領取" if claimed else "可領取"]
	var label := _label(text, 22)
	label.position = Vector2(44, 126)
	label.size = Vector2(520, 180)
	_view_container().add_child(label)
	if not claimed:
		_add_action_button("領取", Vector2(44, 330), func() -> void:
			save["daily_claimed_date"] = today
			_grant_reward(reward_tickets, reward_gems)
			_show_daily()
		)
	_add_action_button("返回商店", Vector2(190, 330), _show_shop, Vector2(146, 44))
	_add_action_button("前往喚靈", Vector2(350, 330), _show_gacha, Vector2(146, 44))

func _show_mail() -> void:
	_clear("郵件")
	var title := _label("郵件", 34)
	title.position = Vector2(44, 32)
	title.size = Vector2(420, 52)
	_view_container().add_child(title)
	var claimed: Dictionary = save.get("claimed_mail", {})
	var y := 104.0
	for mail in mails:
		var mail_id := str(mail.get("id", ""))
		var is_claimed := bool(claimed.get(mail_id, false))
		var panel := _panel(Vector2(44, y), Vector2(760, 92), Color(0.095, 0.078, 0.065, 0.9))
		_view_container().add_child(panel)
		var row := _label("%s\n%s\n獎勵：喚靈券 x%d  源石 x%d   %s" % [mail.get("title", ""), mail.get("body", ""), int(mail.get("tickets", 0)), int(mail.get("gems", 0)), "已領取" if is_claimed else "可領取"], 17)
		row.position = Vector2(60, y + 8)
		row.size = Vector2(600, 78)
		_view_container().add_child(row)
		if not is_claimed:
			_add_action_button("領取", Vector2(670, y + 24), func(id := mail_id, tickets := int(mail.get("tickets", 0)), gems := int(mail.get("gems", 0))) -> void:
				var mail_claimed: Dictionary = save.get("claimed_mail", {})
				mail_claimed[id] = true
				save["claimed_mail"] = mail_claimed
				_grant_reward(tickets, gems)
				_show_mail()
			, Vector2(104, 42))
		y += 108
	_add_action_button("返回主界面", Vector2(44, 548), _show_home, Vector2(146, 44))
	_add_action_button("前往喚靈", Vector2(204, 548), _show_gacha, Vector2(146, 44))

func _show_tasks() -> void:
	_clear("任務")
	var title := _label("章節任務", 34)
	title.position = Vector2(44, 32)
	title.size = Vector2(420, 52)
	_view_container().add_child(title)
	var claimed: Dictionary = save.get("claimed_tasks", {})
	var y := 104.0
	for task in tasks:
		var task_id := str(task.get("id", ""))
		var progress := _task_progress(task_id)
		var target := int(task.get("target", 1))
		var done := progress >= target
		var is_claimed := bool(claimed.get(task_id, false))
		var panel := _panel(Vector2(44, y), Vector2(820, 86), Color(0.095, 0.078, 0.065, 0.9))
		_view_container().add_child(panel)
		var row := _label("%s\n%s  %d/%d\n獎勵：喚靈券 x%d  源石 x%d" % [task.get("name", ""), task.get("desc", ""), progress, target, int(task.get("tickets", 0)), int(task.get("gems", 0))], 17)
		row.position = Vector2(60, y + 8)
		row.size = Vector2(630, 72)
		_view_container().add_child(row)
		if is_claimed:
			var claimed_label := _label("已領取", 18, HORIZONTAL_ALIGNMENT_CENTER)
			claimed_label.position = Vector2(724, y + 22)
			claimed_label.size = Vector2(110, 42)
			_view_container().add_child(claimed_label)
		elif done:
			_add_action_button("領取", Vector2(724, y + 22), func(id := task_id, tickets := int(task.get("tickets", 0)), gems := int(task.get("gems", 0))) -> void:
				var task_claimed: Dictionary = save.get("claimed_tasks", {})
				task_claimed[id] = true
				save["claimed_tasks"] = task_claimed
				_grant_reward(tickets, gems)
				_show_tasks()
			, Vector2(110, 42))
		else:
			var todo := _label("進行中", 18, HORIZONTAL_ALIGNMENT_CENTER)
			todo.position = Vector2(724, y + 22)
			todo.size = Vector2(110, 42)
			_view_container().add_child(todo)
		y += 102
	_add_action_button("返回主界面", Vector2(44, 548), _show_home, Vector2(146, 44))
	_add_action_button("前往喚靈", Vector2(204, 548), _show_gacha, Vector2(146, 44))

func _show_battle(message := "") -> void:
	_clear("戰役")
	_draw_image(UI_MAIN_BG, Vector2(0, 0), Vector2(1280, 646), true, Color(1, 1, 1, 0.42))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 646), Color(0.018, 0.014, 0.012, 0.50)))
	var title := _label("戰役推進", 34)
	title.position = Vector2(44, 32)
	title.size = Vector2(360, 52)
	_view_container().add_child(title)
	var current_stage := _next_stage()
	var player_power := _player_power()
	var stage_power := int(current_stage.get("power", 0))
	var status := "可挑戰" if player_power >= stage_power else "戰力不足"
	if current_stage.is_empty():
		status = "章節已完成"
	var summary := _label("目前戰力: %d\n已通關: %s\n下一關: %s\n推薦戰力: %d\n狀態: %s" % [
		player_power,
		_stage_name(int(save.get("max_stage_id", 0))),
		current_stage.get("name", "全部完成"),
		stage_power,
		status
	], 20)
	summary.position = Vector2(58, 102)
	summary.size = Vector2(430, 150)
	_view_container().add_child(summary)
	if not message.is_empty():
		var result := _label(message, 19)
		result.position = Vector2(58, 268)
		result.size = Vector2(520, 92)
		result.modulate = Color(1.0, 0.86, 0.48, 1.0)
		_view_container().add_child(result)

	var y := 94.0
	for chapter in chapters:
		var panel := _panel(Vector2(586, y), Vector2(598, 120), Color(0.048, 0.038, 0.033, 0.82))
		_view_container().add_child(panel)
		var name := _label(str(chapter.get("name", "")), 22)
		name.position = Vector2(606, y + 12)
		name.size = Vector2(360, 30)
		_view_container().add_child(name)
		var stage_text := []
		for stage in chapter.get("stages", []):
			var sid := int(stage.get("id", 0))
			var mark := "已通關" if sid <= int(save.get("max_stage_id", 0)) else ("下一關" if sid == int(current_stage.get("id", 0)) else "未解鎖")
			stage_text.append("%s  %s  戰力%d" % [mark, stage.get("name", ""), int(stage.get("power", 0))])
		var rows := _label("\n".join(stage_text), 15)
		rows.position = Vector2(606, y + 48)
		rows.size = Vector2(548, 64)
		_view_container().add_child(rows)
		y += 136

	if not current_stage.is_empty():
		_add_action_button("挑戰", Vector2(58, 386), _fight_next_stage, Vector2(132, 46))
	_add_action_button("收取掛機", Vector2(210, 386), _claim_afk_reward, Vector2(132, 46))
	_add_action_button("前往喚靈", Vector2(362, 386), _show_gacha, Vector2(132, 46))
	_add_action_button("返回主界面", Vector2(58, 548), _show_home, Vector2(146, 44))

func _buy_tickets(count: int) -> void:
	var cost := count * int(shop.get("exchangeGemCost", 160))
	if int(save.get("gems", 0)) < cost:
		return
	save["gems"] = int(save.get("gems", 0)) - cost
	save["tickets"] = int(save.get("tickets", 0)) + count * int(shop.get("ticketAmount", 1))
	_persist()
	_show_shop()

func _duplicate_shards(pool: Dictionary, rarity: int) -> int:
	var shards: Dictionary = pool.get("duplicateShards", {"4": 25, "3": 8, "2": 3})
	return int(shards.get(str(rarity), shards.get("2", 3)))

func _draw_wallpaper_stage(hero: Dictionary) -> void:
	home_screen.draw_wallpaper_stage(hero)

func _draw_home_side_entries() -> void:
	home_screen.draw_home_side_entries()

func _open_prayer_pool() -> void:
	save["active_pool_id"] = "prayer"
	_persist()
	_show_gacha()

func _open_present_pool() -> void:
	if str(save.get("active_pool_id", "advanced")) == "prayer":
		save["active_pool_id"] = "advanced"
		_persist()
	_show_gacha()

func _draw_home_bottom_bar() -> void:
	home_screen.draw_home_bottom_bar()

func _active_gacha_realm() -> String:
	return "prayer" if str(save.get("active_pool_id", "advanced")) == "prayer" else "present"

func _pool_in_realm(pool_id: String, realm: String) -> bool:
	return pool_id == "prayer" if realm == "prayer" else pool_id != "prayer"

func _lottery_bg_for_pool(pool_id: String) -> String:
	match pool_id:
		"normal":
			return UI_LOTTERY_BG_NORMAL
		"epic":
			return UI_LOTTERY_BG_EPIC
		"prayer":
			return UI_LOTTERY_BG_PRAYER
		_:
			return UI_LOTTERY_BG_ADVANCED

func _add_realm_button(text: String, realm: String, pos: Vector2) -> void:
	var button := Button.new()
	button.text = "%s%s" % ["✓ " if _active_gacha_realm() == realm else "", text]
	button.position = pos
	button.size = Vector2(96, 44)
	button.pressed.connect(func() -> void:
		if realm == "prayer":
			save["active_pool_id"] = "prayer"
		elif str(save.get("active_pool_id", "advanced")) == "prayer":
			save["active_pool_id"] = "advanced"
		_persist()
		_show_gacha()
	)
	_view_container().add_child(button)

func _draw_home_status() -> void:
	home_screen.draw_home_status()

func _draw_result_stage(result: Dictionary) -> void:
	var hero: Dictionary = result.get("hero", _hero_by_id(240065))
	var rarity := int(result.get("rolled_rarity", hero.get("rarity", 1)))
	var bg_path := UI_LOTTERY_STAGE_BG if rarity >= 4 else UI_LOTTERY_BG
	_draw_image(bg_path, Vector2(0, 0), Vector2(1280, 646), true)
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 646), Color(0.02, 0.014, 0.016, 0.40)))
	_draw_image(UI_LOTTERY_LIGHT_L, Vector2(0, 0), Vector2(640, 430), true, Color(1, 1, 1, 0.42))
	_draw_image(UI_LOTTERY_LIGHT_R, Vector2(640, 0), Vector2(640, 430), true, Color(1, 1, 1, 0.42))
	_view_container().add_child(_panel(Vector2(254, 40), Vector2(772, 360), _rarity_color(rarity, 0.16)))
	_view_container().add_child(_panel(Vector2(320, 72), Vector2(640, 292), _rarity_color(rarity, 0.12)))
	var title_text := "源神降臨" if rarity >= 4 else "喚靈結果"
	var title := _label(title_text, 40, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(400, 22)
	title.size = Vector2(480, 56)
	_view_container().add_child(title)

	var tag := _label("NEW" if result.get("is_new", false) else "碎片 +%d" % int(result.get("shards", 0)), 24, HORIZONTAL_ALIGNMENT_CENTER)
	tag.position = Vector2(520, 82)
	tag.size = Vector2(240, 36)
	tag.modulate = _rarity_color(rarity, 1.0)
	_view_container().add_child(tag)

	var name := _label("%s  %s" % [_stars(rarity), hero.get("name", "")], 34, HORIZONTAL_ALIGNMENT_CENTER)
	name.position = Vector2(382, 352)
	name.size = Vector2(520, 56)
	_view_container().add_child(name)
	_draw_hero_stage(hero, Vector2(420, 70), Vector2(440, 340), false)

	var hint := _label("點擊下方獎勵格查看角色", 18, HORIZONTAL_ALIGNMENT_CENTER)
	hint.position = Vector2(432, 396)
	hint.size = Vector2(416, 32)
	_view_container().add_child(hint)

func _draw_result_grid(results: Array) -> void:
	var strip := _panel(Vector2(42, 430), Vector2(1196, 92), Color(0.04, 0.033, 0.031, 0.72))
	_view_container().add_child(strip)
	var x := 66.0
	for result in results:
		var hero: Dictionary = result.get("hero", {})
		var hero_id := int(hero.get("id", 0))
		var rarity := int(result.get("rolled_rarity", hero.get("rarity", 1)))
		var frame := _panel(Vector2(x - 4, 436), Vector2(116, 82), _rarity_color(rarity, 0.58))
		_view_container().add_child(frame)
		_draw_hero_portrait(hero, Vector2(x, 440), Vector2(44, 74), Color(1, 1, 1, 1))
		var card_label := _label("%s\n%s\n%s" % [_stars(rarity), hero.get("name", ""), "NEW" if result.get("is_new", false) else "碎片 +%d" % int(result.get("shards", 0))], 13)
		card_label.position = Vector2(x + 48, 442)
		card_label.size = Vector2(56, 68)
		_view_container().add_child(card_label)
		var card := Button.new()
		card.text = ""
		card.flat = true
		card.position = Vector2(x, 440)
		card.size = Vector2(108, 74)
		card.pressed.connect(func() -> void:
			_show_hero_detail(hero_id)
		)
		_view_container().add_child(card)
		x += 118

func _draw_hero_stage(hero: Dictionary, pos := Vector2(470, 0), size := Vector2(500, 560), show_text := true) -> void:
	if show_text:
		var name_label := _label(str(hero.get("name", "")), 42)
		name_label.position = Vector2(54, 28)
		name_label.size = Vector2(420, 58)
		_view_container().add_child(name_label)

		var meta := _label("%s / %s" % [_stars(int(hero.get("rarity", 1))), hero.get("spine", "")], 20)
		meta.position = Vector2(54, 92)
		meta.size = Vector2(520, 40)
		_view_container().add_child(meta)

	var texture := TextureRect.new()
	texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.position = pos
	texture.size = size
	var resource_path := str(hero.get("artResource", ""))
	if not resource_path.is_empty():
		var spine_base_path := "res://%s" % resource_path.replace("Art/Spine", "assets/spine")
		var baked_path := "%s.baked.json" % spine_base_path
		if FileAccess.file_exists(baked_path):
			var canvas: Control = BAKED_SPINE_CANVAS.new()
			canvas.position = pos
			canvas.size = size
			_view_container().add_child(canvas)
			canvas.set_baked_path(baked_path, "wait")
			return
		print("[spine] baked not found: %s, falling back to PNG" % baked_path)
		var godot_path := "%s.png" % spine_base_path
		var source_texture := _load_png_source_texture(godot_path)
		if source_texture != null:
			texture.texture = source_texture
		else:
			var portrait_texture := _hero_portrait_texture(hero)
			if portrait_texture != null:
				texture.texture = portrait_texture
			else:
				var missing := _label("資源缺失\n%s" % godot_path, 16, HORIZONTAL_ALIGNMENT_CENTER)
				missing.position = pos
				missing.size = Vector2(size.x, 64)
				_view_container().add_child(missing)
	else:
		var fallback_texture := _hero_portrait_texture(hero)
		if fallback_texture != null:
			texture.texture = fallback_texture
	_view_container().add_child(texture)

func _load_png_source_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_warning("Failed to load PNG source: %s error=%d" % [path, error])
		return null
	return ImageTexture.create_from_image(image)

func _hero_portrait_path(hero: Dictionary) -> String:
	var path := str(hero.get("portraitResource", ""))
	if path.is_empty():
		return ""
	return _godot_resource_path(path)

func _hero_portrait_texture(hero: Dictionary) -> Texture2D:
	var path := _hero_portrait_path(hero)
	if path.is_empty():
		return null
	return _load_png_source_texture(path)

func _hero_round_head_path(hero: Dictionary) -> String:
	var explicit := str(hero.get("roundHeadResource", ""))
	if not explicit.is_empty():
		return _godot_resource_path(explicit)
	var spine := str(hero.get("spine", ""))
	if spine.begins_with("hero_"):
		var candidates: Array[String] = []
		var suffix := spine.trim_prefix("hero_")
		candidates.append(suffix)
		var base_suffix := suffix.split("_")[0]
		if not candidates.has(base_suffix):
			candidates.append(base_suffix)
		if base_suffix.length() > 1:
			var last_char := base_suffix.substr(base_suffix.length() - 1, 1)
			if last_char == "r" or last_char == "h":
				var normalized_suffix := base_suffix.substr(0, base_suffix.length() - 1)
				if not candidates.has(normalized_suffix):
					candidates.append(normalized_suffix)
		for candidate in candidates:
			var path := "res://assets/ui/hero/round/yhero_%s.png" % candidate
			if FileAccess.file_exists(path):
				return path
	return ""

func _hero_round_head_texture(hero: Dictionary) -> Texture2D:
	var path := _hero_round_head_path(hero)
	if path.is_empty():
		return null
	return _load_png_source_texture(path)

func _godot_resource_path(path: String) -> String:
	return path if path.begins_with("res://") else "res://%s" % path

func _draw_hero_portrait(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint := Color(1, 1, 1, 1)) -> TextureRect:
	var source_texture := _hero_portrait_texture(hero)
	if source_texture == null:
		return null
	var rect := TextureRect.new()
	rect.texture = source_texture
	rect.position = pos
	rect.size = draw_size
	rect.clip_contents = true
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.modulate = tint
	_view_container().add_child(rect)
	return rect

func _draw_hero_thumb(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint := Color(1, 1, 1, 1)) -> Control:
	var source_texture = _hero_portrait_texture(hero)
	if source_texture == null:
		return null
	var clip := Control.new()
	clip.position = pos
	clip.size = draw_size
	clip.clip_contents = true
	_view_container().add_child(clip)

	var rect := TextureRect.new()
	rect.texture = source_texture
	rect.position = Vector2.ZERO
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.modulate = tint
	clip.add_child(rect)
	return clip

func _draw_hero_round_thumb(hero: Dictionary, pos: Vector2, draw_size: Vector2, tint := Color(1, 1, 1, 1)) -> Control:
	var source_texture := _hero_round_head_texture(hero)
	if source_texture == null:
		return _draw_hero_thumb(hero, pos + Vector2(4, 4), draw_size - Vector2(8, 8), Color(tint.r, tint.g, tint.b, tint.a * 0.72))
	var rect := TextureRect.new()
	rect.texture = source_texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.modulate = tint
	_view_container().add_child(rect)
	return rect

func _draw_detail_portrait(hero: Dictionary) -> void:
	var path := str(hero.get("detailPortraitResource", ""))
	if path.is_empty():
		return
	var frame := _panel(Vector2(428, 104), Vector2(206, 216), Color(0.08, 0.058, 0.048, 0.72))
	_view_container().add_child(frame)
	_draw_image(_godot_resource_path(path), Vector2(442, 116), Vector2(178, 190), false, Color(1, 1, 1, 0.92))

func _draw_skill_icons(hero: Dictionary) -> void:
	var skill_paths: Array = hero.get("skillResources", [])
	if skill_paths.is_empty():
		return
	var panel := _panel(Vector2(54, 404), Vector2(560, 122), Color(0.052, 0.040, 0.034, 0.82))
	_view_container().add_child(panel)
	var title := _label("技能", 20)
	title.position = Vector2(76, 414)
	title.size = Vector2(160, 30)
	_view_container().add_child(title)
	var x := 78.0
	var index := 1
	for raw_path in skill_paths:
		var icon_frame := _panel(Vector2(x - 4, 452), Vector2(78, 74), _rarity_color(int(hero.get("rarity", 1)), 0.28))
		_view_container().add_child(icon_frame)
		_draw_image(_godot_resource_path(str(raw_path)), Vector2(x, 456), Vector2(70, 56), false)
		var label := _label("技能%d" % index, 13, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(x, 510)
		label.size = Vector2(70, 18)
		_view_container().add_child(label)
		x += 92
		index += 1

func _draw_image(path: String, pos: Vector2, draw_size: Vector2, cover := false, tint := Color(1, 1, 1, 1)) -> TextureRect:
	var source_texture := _load_png_source_texture(path)
	if source_texture == null:
		return null
	var rect := TextureRect.new()
	rect.texture = source_texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_SCALE
	rect.modulate = tint
	_view_container().add_child(rect)
	return rect

func _draw_clipped_image(path: String, pos: Vector2, draw_size: Vector2, cover := false, tint := Color(1, 1, 1, 1)) -> Control:
	var source_texture := _load_png_source_texture(path)
	if source_texture == null:
		return null
	var clip := Control.new()
	clip.position = pos
	clip.size = draw_size
	clip.clip_contents = true
	_view_container().add_child(clip)
	var rect := TextureRect.new()
	rect.texture = source_texture
	rect.position = Vector2.ZERO
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.modulate = tint
	clip.add_child(rect)
	return clip

func _show_gacha_rate() -> void:
	_clear("概率")
	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	var rates: Dictionary = pool.get("rates", {})
	var source: Dictionary = pool.get("sourceStatic", {})
	var shards: Dictionary = pool.get("duplicateShards", {})
	var text := "卡池：%s\n\nMVP 概率：\n%s %.2f%%，保底 %d 抽\n%s %.2f%%\n%s %.2f%%\n\nUP 權重：%.0f%%\n重複碎片：%s=%d  %s=%d  %s=%d\n\n來源：%s %s / cnt3=%s / rateUp=%s" % [
		pool.get("name", ""),
		_stars(4),
		float(rates.get("4", 0.02)) * 100.0,
		int(pool.get("pityLimit", 60)),
		_stars(3),
		float(rates.get("3", 0.14)) * 100.0,
		_stars(2),
		float(rates.get("2", 0.84)) * 100.0,
		float(pool.get("upRate", 0.55)) * 100.0,
		_stars(4),
		int(shards.get("4", 25)),
		_stars(3),
		int(shards.get("3", 8)),
		_stars(2),
		int(shards.get("2", 3)),
		source.get("table", "mvp"),
		str(source.get("id", "")),
		str(source.get("cnt3", "")),
		str(source.get("rateUp", ""))
	]
	var label := _label(text, 22)
	label.position = Vector2(54, 60)
	label.size = Vector2(760, 260)
	_view_container().add_child(label)
	_add_action_button("返回卡池", Vector2(54, 360), _show_gacha)

func _hero_by_id(id: int) -> Dictionary:
	for hero in heroes:
		if int(hero.get("id", 0)) == id:
			return hero
	return heroes[0] if not heroes.is_empty() else {}

func _pool_by_id(id: String) -> Dictionary:
	for pool in pools:
		if str(pool.get("id", "")) == id:
			return pool
	return pools[0] if not pools.is_empty() else {}

func _pity(pool_id: String) -> int:
	return int(save.get("pity", {}).get(pool_id, 0))

func _set_pity(pool_id: String, value: int) -> void:
	var pity: Dictionary = save.get("pity", {})
	pity[pool_id] = value
	save["pity"] = pity

func _add_gallery_filter_button(text: String, filter: String, pos: Vector2) -> void:
	var button := Button.new()
	button.text = ("✓ " if gallery_filter == filter else "") + text
	button.position = pos
	button.size = Vector2(96, 38)
	button.pressed.connect(func() -> void:
		gallery_filter = filter
		_show_gallery()
	)
	_view_container().add_child(button)

func _gallery_filtered_heroes() -> Array:
	var list := []
	for hero in heroes:
		var hero_id := int(hero.get("id", 0))
		var rarity := int(hero.get("rarity", 1))
		var owned := int(save.get("owned", {}).get(str(hero_id), 0)) > 0
		var include := true
		match gallery_filter:
			"owned":
				include = owned
			"unowned":
				include = not owned
			"r4":
				include = rarity >= 4
			"r3":
				include = rarity == 3
			"r2":
				include = rarity <= 2
			_:
				include = true
		if include:
			list.append(hero)
	list.sort_custom(_sort_gallery_heroes)
	return list

func _sort_gallery_heroes(a: Dictionary, b: Dictionary) -> bool:
	var a_id := int(a.get("id", 0))
	var b_id := int(b.get("id", 0))
	var a_owned := int(save.get("owned", {}).get(str(a_id), 0)) > 0
	var b_owned := int(save.get("owned", {}).get(str(b_id), 0)) > 0
	if a_owned != b_owned:
		return a_owned
	var a_rarity := int(a.get("rarity", 1))
	var b_rarity := int(b.get("rarity", 1))
	if a_rarity != b_rarity:
		return a_rarity > b_rarity
	return a_id < b_id

func _grant_reward(tickets: int, gems: int) -> void:
	save["tickets"] = int(save.get("tickets", 0)) + tickets
	save["gems"] = int(save.get("gems", 0)) + gems
	_persist()

func _grant_shards(shards: Dictionary) -> void:
	var shard_save: Dictionary = save.get("shards", {})
	for raw_id in shards.keys():
		var key := str(raw_id)
		shard_save[key] = int(shard_save.get(key, 0)) + int(shards.get(raw_id, 0))
	save["shards"] = shard_save

func _next_stage() -> Dictionary:
	var next_id := int(save.get("next_stage_id", 101))
	for chapter in chapters:
		for stage in chapter.get("stages", []):
			if int(stage.get("id", 0)) == next_id:
				return stage
	return {}

func _stage_after(stage_id: int) -> int:
	var found := false
	for chapter in chapters:
		for stage in chapter.get("stages", []):
			var sid := int(stage.get("id", 0))
			if found:
				return sid
			if sid == stage_id:
				found = true
	return 0

func _stage_name(stage_id: int) -> String:
	if stage_id <= 0:
		return "尚未通關"
	for chapter in chapters:
		for stage in chapter.get("stages", []):
			if int(stage.get("id", 0)) == stage_id:
				return str(stage.get("name", stage_id))
	return str(stage_id)

func _fight_next_stage() -> void:
	var stage := _next_stage()
	if stage.is_empty():
		_show_battle("所有 MVP 關卡已通關。")
		return
	var required_power := int(stage.get("power", 0))
	if _player_power() < required_power:
		_show_battle("挑戰失敗：推薦戰力 %d，請先喚靈或領取資源提升收集。" % required_power)
		return
	_grant_reward(int(stage.get("tickets", 0)), int(stage.get("gems", 0)))
	_grant_shards(stage.get("shards", {}))
	save["battle_count"] = int(save.get("battle_count", 0)) + 1
	save["max_stage_id"] = max(int(save.get("max_stage_id", 0)), int(stage.get("id", 0)))
	save["next_stage_id"] = _stage_after(int(stage.get("id", 0)))
	_persist()
	_show_battle("通關 %s\n獲得 喚靈券 x%d / 源石 x%d / 碎片 %s" % [
		stage.get("name", ""),
		int(stage.get("tickets", 0)),
		int(stage.get("gems", 0)),
		_shard_reward_text(stage.get("shards", {}))
	])

func _afk_claimed_today() -> bool:
	return str(save.get("afk_claimed_date", "")) == Time.get_date_string_from_system()

func _afk_time_display() -> String:
	var elapsed = int(Time.get_unix_time_from_system() - float(save.get("afk_last_claim", Time.get_unix_time_from_system())))
	var hours = elapsed / 3600
	var mins = (elapsed % 3600) / 60
	var secs = elapsed % 60
	return "%02d:%02d:%02d" % [min(hours, 99), mins, secs]

func _claim_afk_reward() -> void:
	if _afk_claimed_today():
		_show_battle("今日掛機收益已收取。")
		return
	_grant_reward(int(afk_reward.get("tickets", 1)), int(afk_reward.get("gems", 240)))
	_grant_shards(afk_reward.get("shards", {}))
	save["afk_claimed_date"] = Time.get_date_string_from_system()
	_persist()
	_show_battle("收取掛機收益\n獲得 喚靈券 x%d / 源石 x%d / 碎片 %s" % [
		int(afk_reward.get("tickets", 1)),
		int(afk_reward.get("gems", 240)),
		_shard_reward_text(afk_reward.get("shards", {}))
	])

func _shard_reward_text(shards: Dictionary) -> String:
	if shards.is_empty():
		return "無"
	var parts := []
	for raw_id in shards.keys():
		parts.append("%s x%d" % [_hero_by_id(int(raw_id)).get("name", raw_id), int(shards.get(raw_id, 0))])
	return " / ".join(parts)

func _task_progress(task_id: String) -> int:
	var metric := ""
	for task in tasks:
		if str(task.get("id", "")) == task_id:
			metric = str(task.get("metric", ""))
			break
	if metric == "draw_count":
		return int(save.get("draw_count", 0))
	if metric == "owned_count":
		return save.get("owned", {}).size()
	if metric == "battle_count":
		return int(save.get("battle_count", 0))
	if metric == "max_stage_id":
		return int(save.get("max_stage_id", 0))
	return 0

func _next_task_text() -> String:
	var claimed: Dictionary = save.get("claimed_tasks", {})
	for task in tasks:
		var task_id := str(task.get("id", ""))
		if bool(claimed.get(task_id, false)):
			continue
		return "%s %d/%d" % [task.get("name", ""), _task_progress(task_id), int(task.get("target", 1))]
	return "章節任務已完成"

func _unclaimed_mail_count() -> int:
	var claimed: Dictionary = save.get("claimed_mail", {})
	var count := 0
	for mail in mails:
		if not bool(claimed.get(str(mail.get("id", "")), false)):
			count += 1
	return count

func _profile_summary() -> String:
	var profile: Dictionary = save.get("profile", {})
	return "Lv.%d  %s\n戰力 %d" % [int(profile.get("level", 1)), profile.get("name", "Player"), _player_power()]

func _player_power() -> int:
	var profile: Dictionary = save.get("profile", {})
	return int(profile.get("base_power", 0)) + save.get("owned", {}).size() * 24000 + int(save.get("draw_count", 0)) * 120 + int(save.get("battle_count", 0)) * 18000

func _add_toggle_button(label: String, key: String, pos: Vector2, value: bool) -> void:
	_add_action_button("%s：%s" % [label, "開" if value else "關"], pos, func() -> void:
		var settings: Dictionary = save.get("settings", {})
		settings[key] = not bool(settings.get(key, true))
		save["settings"] = settings
		_persist()
		_show_settings()
	, Vector2(220, 44))

func _draw_startup_backdrop(base_color: Color, shade_color: Color) -> void:
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), base_color))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), shade_color))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 96), Color(0.01, 0.008, 0.007, 0.36)))
	_view_container().add_child(_panel(Vector2(0, 624), Vector2(1280, 96), Color(0.01, 0.008, 0.007, 0.46)))
	for index in range(5):
		var x := 90.0 + float(index) * 236.0
		_view_container().add_child(_panel(Vector2(x, 118), Vector2(1, 486), Color(0.92, 0.74, 0.44, 0.08)))

func _show_login_notice_popup() -> void:
	_show_login()
	_draw_overlay_popup("公告", "離線 MVP 已載入本地抽卡、角色與主界面資料。\n後續將接入原公告與活動表。")

func _show_repair_popup() -> void:
	_show_login()
	_draw_overlay_popup("資源修復", "當前資源來自已提交的 Godot MVP 目錄。\n若圖片缺失，請重新執行資源導出與同步。")

func _show_login_account_popup() -> void:
	_show_login()
	_draw_overlay_popup("帳號", "Player\nOpenId: offline-player\n登入方式：本地單機")

func _draw_overlay_popup(title: String, message: String) -> void:
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(1280, 720), Color(0, 0, 0, 0.42)))
	_view_container().add_child(_panel(Vector2(390, 220), Vector2(500, 260), Color(0.10, 0.075, 0.06, 0.96)))
	var heading := _label(title, 28, HORIZONTAL_ALIGNMENT_CENTER)
	heading.position = Vector2(430, 244)
	heading.size = Vector2(420, 46)
	_view_container().add_child(heading)
	var body := _label(message, 19, HORIZONTAL_ALIGNMENT_CENTER)
	body.position = Vector2(430, 308)
	body.size = Vector2(420, 88)
	_view_container().add_child(body)
	_add_action_button("確定", Vector2(574, 416), _show_login, Vector2(132, 44))

func _label(text: String, size: int, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = Color(0.96, 0.91, 0.84)
	return label

func _panel(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = pos
	panel.size = size
	panel.color = color
	return panel

func _draw_progress_bar(pos: Vector2, size: Vector2, ratio: float) -> void:
	var bg := _panel(pos, size, Color(0.025, 0.022, 0.02))
	_view_container().add_child(bg)
	var fill := _panel(pos + Vector2(2, 2), Vector2((size.x - 4) * clamp(ratio, 0.0, 1.0), size.y - 4), Color(0.82, 0.62, 0.28))
	_view_container().add_child(fill)

func _draw_red_dot(pos: Vector2) -> void:
	var dot := _panel(pos, Vector2(12, 12), Color(0.86, 0.08, 0.06, 0.95))
	_view_container().add_child(dot)

func _rarity_color(rarity: int, alpha := 1.0) -> Color:
	if rarity >= 4:
		return Color(1.0, 0.72, 0.22, alpha)
	if rarity == 3:
		return Color(0.78, 0.42, 1.0, alpha)
	return Color(0.32, 0.62, 1.0, alpha)

func _add_action_button(text: String, pos: Vector2, callback: Callable, size := Vector2(132, 44)) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = size
	button.pressed.connect(callback)
	_view_container().add_child(button)

func _stars(count: int) -> String:
	return "★".repeat(clamp(count, 1, 5))
