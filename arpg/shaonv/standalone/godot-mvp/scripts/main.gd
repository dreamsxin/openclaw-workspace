# UTF-8 source. Keep Chinese UI labels readable when editing on Windows.
extends Control

const SAVE_PATH := "user://shaonv_godot_mvp_save.json"
const DEFAULT_HERO_ID := 240030
const LEGACY_DEFAULT_HERO_IDS := [240037, 240065]
const HERO_DATA_PATH := "res://data/heroes_mvp.json"
const HERO_RESOURCE_MAP_PATH := "res://data/hero_resource_map.json"
const HERO_RARITY_GRADE_PATH := "res://data/hero_rarity_grades.json"
const POOL_DATA_PATH := "res://data/gacha_pools_mvp.json"
const VIDEO_MANIFEST_PATH := "res://data/video_manifest.json"
const LIVE_OPS_DATA_PATH := "res://data/live_ops_mvp.json"
const ADVENTURE_DATA_PATH := "res://data/adventure_mvp.json"
const BAKED_SPINE_CANVAS := preload("res://scripts/spine_baked_preview_canvas.gd")
const STARTUP_SCREEN := preload("res://scripts/screens/startup_screen.gd")
const HOME_SCREEN := preload("res://scripts/screens/home_screen.gd")
const CHAPTER_SCREEN := preload("res://scripts/screens/chapter_screen.gd")
const EXPEDITION_SCREEN := preload("res://scripts/screens/expedition_screen.gd")
const BATTLE_SCREEN := preload("res://scripts/screens/battle_screen.gd")
const SHOP_SCREEN := preload("res://scripts/screens/shop_screen.gd")
const ACTIVITY_SCREEN := preload("res://scripts/screens/activity_screen.gd")
const HERO_SCREEN := preload("res://scripts/screens/hero_screen.gd")
const REMNANTS_SCREEN := preload("res://scripts/screens/remnants_screen.gd")
const HOME_PANEL_SCREEN := preload("res://scripts/screens/home_panel_screen.gd")
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
const UI_MAIN_FULLSCREEN_OVERLAY := "res://assets/ui/mainui/mainui_img_44.png"
const UI_MAIN_SMALL_PANEL := "res://assets/ui/mainui/mainui_img_38.png"
const UI_MAIN_SMALL_PANEL_ALT := "res://assets/ui/mainui/mainui_img_39.png"
const UI_MAIN_WIDE_PANEL := "res://assets/ui/mainui/mainui_img_37.png"
const UI_MAIN_DIVIDER := "res://assets/ui/mainui/mainui_img_40.png"
const UI_MAIN_REWARD_FRAME := "res://assets/ui/mainui/mainui_img_45.png"
const UI_MAIN_LIMIT_ICON_FRAME := "res://assets/ui/mainui/mainui_btn_14.png"
const UI_MAIN_LIMIT_ICONS := [
	"res://assets/ui/mainui/mainui_btn_15.png",
	"res://assets/ui/mainui/mainui_btn_16.png",
	"res://assets/ui/mainui/mainui_btn_17.png",
	"res://assets/ui/mainui/mainui_btn_20.png",
	"res://assets/ui/mainui/mainui_btn_18.png",
	"res://assets/ui/mainui/mainui_btn_19.png"
]
const UI_MAIN_FUNNY_ARENA := "res://assets/ui/mainui/mainui_txt_03.png"
const UI_MAIN_CHARGE_ICONS := [
	"res://assets/ui/mainui/mainui_btn_06.png",
	"res://assets/ui/mainui/mainui_btn_07.png",
	"res://assets/ui/mainui/mainui_btn_10.png",
	"res://assets/ui/mainui/mainui_btn_08.png",
	"res://assets/ui/mainui/mainui_btn_09.png"
]
const UI_LOTTERY_BTN_SINGLE := "res://assets/ui/common/lottery_btn_05.png"
const UI_LOTTERY_BTN_TEN := "res://assets/ui/common/lottery_btn_06.png"
const UI_COMMON_BTN_GOLD := "res://assets/ui/common/tongyong_btn_08.png"
const UI_COMMON_BTN_WHITE := "res://assets/ui/common/tongyong_btn_01.png"
const UI_LOTTERY_BG_NORMAL := "res://assets/ui/lottery/bg/lottery_bg_02.png"
const UI_LOTTERY_BG_ADVANCED := "res://assets/ui/lottery/bg/lottery_bg_01.png"
const UI_LOTTERY_BG_EPIC := "res://assets/ui/lottery/bg/lottery_bg_03.png"
const UI_LOTTERY_BG_PRAYER := "res://assets/ui/lottery/bg/lottery_bg_08.png"
const UI_LOTTERY_SIDE_1 := "res://assets/ui/lottery/lottery_img_11.png"
const UI_LOTTERY_SIDE_2 := "res://assets/ui/lottery/lottery_img_12.png"
const UI_LOTTERY_POOL_FRAME := "res://assets/ui/lottery/lottery_img_55.png"
const UI_LOTTERY_PRAYER_FRAME := "res://assets/ui/lottery/lottery_img_57.png"
const UI_LOTTERY_TICKET_ICON := "res://assets/ui/item/draw_03.png"
const UI_HERO_BG_DETAIL := "res://assets/ui/background/hero_bg_10.png"
const UI_HERO_SELECTOR_BG := "res://assets/ui/hero/hero_img_36.png"
const UI_HERO_SELECTOR_TOP := "res://assets/ui/hero/hero_img_36a.png"
const UI_HERO_HIGHLIGHT := "res://assets/ui/hero/hero_img_119.png"
const UI_HERO_STAR_SMALL := "res://assets/ui/hero/hero_img_60.png"
const UI_HERO_TAB_HOME := "res://assets/ui/hero/hero_img_37.png"
const UI_HERO_TAB_CULTIVATE := "res://assets/ui/hero/hero_img_43.png"
const UI_HERO_TAB_EQUIP := "res://assets/ui/hero/hero_img_44.png"
const UI_HERO_TAB_STAGE := "res://assets/ui/hero/hero_img_45.png"
const UI_COMMON_TAB_HIGHLIGHT := "res://assets/ui/common/common_btn_07.png"
const UI_COMMON_HERO_HEAD_FRAME := "res://assets/ui/common/common_img_64.png"
const UI_COMMON_HERO_STAR_BAR := "res://assets/ui/common/common_img_62.png"
const UI_COMMON_STAR := "res://assets/ui/common/common_img_73.png"
const UI_COMMON_STAR_OFF := "res://assets/ui/common/common_img_74.png"
const UI_COMMON_SECTION := "res://assets/ui/common/common_img_199.png"
const UI_COMMON_SKILL_FRAME := "res://assets/ui/common/common_img_208.png"
const UI_REMNANTS_BG := "res://assets/ui/background/mainui_bg_01.png"
const UI_REMNANT_STAGE_BG := "res://assets/spine/hero_017/hero_017_bg.png"
const AUDIO_BGM_LOGIN := "res://assets/audio/bgm/login.wav"
const AUDIO_BGM_MAIN := "res://assets/audio/bgm/main.wav"
const AUDIO_SFX_UI_CONFIRM := "res://assets/audio/ui/ui_confirm.wav"
const AUDIO_SFX_UI_DRAW_ENTER := "res://assets/audio/ui/ui_draw_enter.wav"
const AUDIO_SFX_UI_MAIN := "res://assets/audio/ui/ui_main.wav"
const AUDIO_SFX_POP_OPEN := "res://assets/audio/effect/pop_open.wav"
const AUDIO_SFX_GET_REWARD := "res://assets/audio/effect/getreward.wav"
const AUDIO_SFX_DRAW_ANIMATION := "res://assets/audio/effect/draw_animation.wav"
const AUDIO_SFX_DRAW_RESULT_1 := "res://assets/audio/effect/draw_result_1.wav"
const AUDIO_SFX_DRAW_RESULT_10 := "res://assets/audio/effect/draw_result_10.wav"
const AUDIO_SFX_POOL_SIZE := 6
const CANVAS_WIDTH := 1670.0
const CANVAS_HEIGHT := 750.0
const CANVAS_SIZE := Vector2(CANVAS_WIDTH, CANVAS_HEIGHT)
const CONTENT_HEIGHT := 646.0
const CONTENT_SIZE := Vector2(CANVAS_WIDTH, CONTENT_HEIGHT)

var heroes: Array = []
var hero_resource_map: Array = []
var hero_rarity_grades := {}
var video_manifest := {}
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
var startup_screen
var home_screen
var chapter_screen
var expedition_screen
var battle_screen
var shop_screen
var activity_screen
var hero_screen
var remnants_screen
var home_panel_screen
var gal_screen
var gacha_screen
var gacha_result_screen
var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _audio_cache := {}
var _audio_missing_warned := {}
var _current_bgm_path := ""

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
	size = CANVAS_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("Shaonv MVP _ready")
	rng.randomize()
	heroes = _read_json(HERO_DATA_PATH).get("heroes", [])
	hero_resource_map = _read_json_array(HERO_RESOURCE_MAP_PATH)
	hero_rarity_grades = _read_json(HERO_RARITY_GRADE_PATH)
	video_manifest = _read_json(VIDEO_MANIFEST_PATH)
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
	if OS.get_environment("SHAONV_MVP_GACHA_POOL") != "":
		save["active_pool_id"] = OS.get_environment("SHAONV_MVP_GACHA_POOL")
	_build_root()
	startup_screen = STARTUP_SCREEN.new(self)
	home_screen = HOME_SCREEN.new(self)
	chapter_screen = CHAPTER_SCREEN.new(self)
	expedition_screen = EXPEDITION_SCREEN.new(self)
	battle_screen = BATTLE_SCREEN.new(self)
	shop_screen = SHOP_SCREEN.new(self)
	activity_screen = ACTIVITY_SCREEN.new(self)
	hero_screen = HERO_SCREEN.new(self)
	remnants_screen = REMNANTS_SCREEN.new(self)
	home_panel_screen = HOME_PANEL_SCREEN.new(self)
	gacha_screen = GACHA_SCREEN.new(self)
	gacha_result_screen = GACHA_RESULT_SCREEN.new(self)
	gal_screen = GAL_SCREEN.new(self)
	_startup_sequence()
	if not OS.get_environment("SHAONV_MVP_CAPTURE").is_empty():
		call_deferred("_capture_debug_screenshot")

func _capture_debug_screenshot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var delay := float(OS.get_environment("SHAONV_MVP_CAPTURE_DELAY")) if not OS.get_environment("SHAONV_MVP_CAPTURE_DELAY").is_empty() else 0.0
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
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
	if int(save.get("selected_hero_id", DEFAULT_HERO_ID)) in LEGACY_DEFAULT_HERO_IDS:
		save["selected_hero_id"] = DEFAULT_HERO_ID

func _persist() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save))

func _build_root() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.036, 0.031, 0.028)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_ensure_audio_players()

	top_bar = Control.new()
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(CANVAS_WIDTH, 74)
	add_child(top_bar)

	var top_bg := ColorRect.new()
	top_bg.color = Color(0.034, 0.028, 0.024, 0.94)
	top_bg.position = Vector2(0, 0)
	top_bg.size = Vector2(CANVAS_WIDTH, 74)
	top_bar.add_child(top_bg)

	var profile_button := Button.new()
	profile_button.text = _profile_summary()
	profile_button.position = Vector2(16, 8)
	profile_button.size = Vector2(238, 56)
	profile_button.pressed.connect(_show_player_info)
	top_bar.add_child(profile_button)

	title_label = _label("MainScene", 18, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.position = Vector2((CANVAS_WIDTH - 184.0) * 0.5, 22)
	title_label.size = Vector2(184, 30)
	add_child(title_label)

	wallet_label = _label("", 18, HORIZONTAL_ALIGNMENT_RIGHT)
	wallet_label.position = Vector2(CANVAS_WIDTH - 472.0, 18)
	wallet_label.size = Vector2(440, 36)
	add_child(wallet_label)

	_setup_layers()

func _ensure_audio_players() -> void:
	if _bgm_player == null or not is_instance_valid(_bgm_player):
		_bgm_player = AudioStreamPlayer.new()
		_bgm_player.name = "BgmPlayer"
		add_child(_bgm_player)
	for index in range(_sfx_players.size() - 1, -1, -1):
		if _sfx_players[index] == null or not is_instance_valid(_sfx_players[index]):
			_sfx_players.remove_at(index)
	while _sfx_players.size() < AUDIO_SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % _sfx_players.size()
		add_child(player)
		_sfx_players.append(player)

func _audio_enabled(kind: String) -> bool:
	var settings: Dictionary = save.get("settings", {})
	if kind == "music" or kind == "bgm":
		return bool(settings.get("music", true))
	if kind == "effects" or kind == "sfx":
		return bool(settings.get("effects", true))
	return true

func _play_bgm(path: String, volume := 1.0, loop := true) -> void:
	if not _audio_enabled("music"):
		_stop_bgm()
		return
	if path.is_empty():
		_stop_bgm()
		return
	_ensure_audio_players()
	if _current_bgm_path == path and _bgm_player.playing:
		_bgm_player.volume_db = linear_to_db(clampf(volume, 0.01, 1.0))
		return
	var stream := _load_wav_stream(path, loop)
	if stream == null:
		return
	_current_bgm_path = path
	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(clampf(volume, 0.01, 1.0))
	_bgm_player.play()

func _stop_bgm() -> void:
	if _bgm_player != null and is_instance_valid(_bgm_player):
		_bgm_player.stop()
	_current_bgm_path = ""

func _play_sfx(path: String, volume := 1.0) -> void:
	if not _audio_enabled("effects"):
		return
	if path.is_empty():
		return
	_ensure_audio_players()
	var stream := _load_wav_stream(path, false)
	if stream == null:
		return
	var player := _next_sfx_player()
	player.stream = stream
	player.volume_db = linear_to_db(clampf(volume, 0.01, 1.0))
	player.play()

func _next_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	var player := _sfx_players[0]
	player.stop()
	return player

func _load_wav_stream(path: String, loop := false) -> AudioStreamWAV:
	var cache_key := "%s|%s" % [path, str(loop)]
	if _audio_cache.has(cache_key):
		return _audio_cache[cache_key]
	if not FileAccess.file_exists(path):
		_warn_missing_audio(path)
		return null
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 44 or _ascii4(bytes, 0) != "RIFF" or _ascii4(bytes, 8) != "WAVE":
		push_warning("Audio file is not a PCM WAV: %s" % path)
		return null
	var offset := 12
	var channels := 1
	var sample_rate := 22050
	var bits_per_sample := 16
	var data_start := -1
	var data_size := 0
	while offset + 8 <= bytes.size():
		var chunk := _ascii4(bytes, offset)
		var chunk_size := _u32le(bytes, offset + 4)
		var chunk_data := offset + 8
		if chunk == "fmt " and chunk_data + 16 <= bytes.size():
			var audio_format := _u16le(bytes, chunk_data)
			channels = _u16le(bytes, chunk_data + 2)
			sample_rate = _u32le(bytes, chunk_data + 4)
			bits_per_sample = _u16le(bytes, chunk_data + 14)
			if audio_format != 1:
				push_warning("Unsupported WAV format %d: %s" % [audio_format, path])
				return null
		elif chunk == "data":
			data_start = chunk_data
			data_size = mini(chunk_size, bytes.size() - data_start)
			break
		offset = chunk_data + chunk_size + (chunk_size % 2)
	if data_start < 0 or data_size <= 0:
		push_warning("WAV data chunk missing: %s" % path)
		return null
	var stream := AudioStreamWAV.new()
	if bits_per_sample == 8:
		stream.format = AudioStreamWAV.FORMAT_8_BITS
	elif bits_per_sample == 16:
		stream.format = AudioStreamWAV.FORMAT_16_BITS
	else:
		push_warning("Unsupported WAV bit depth %d: %s" % [bits_per_sample, path])
		return null
	stream.mix_rate = sample_rate
	stream.stereo = channels == 2
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	stream.data = bytes.slice(data_start, data_start + data_size)
	_audio_cache[cache_key] = stream
	return stream

func _warn_missing_audio(path: String) -> void:
	if _audio_missing_warned.has(path):
		return
	_audio_missing_warned[path] = true
	push_warning("Missing audio file: %s" % path)

func _u16le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8)

func _u32le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8) | (int(bytes[offset + 2]) << 16) | (int(bytes[offset + 3]) << 24)

func _ascii4(bytes: PackedByteArray, offset: int) -> String:
	if offset + 4 > bytes.size():
		return ""
	var out := ""
	for index in range(4):
		out += char(bytes[offset + index])
	return out

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
	container.size = CANVAS_SIZE
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
			_startup_timer.start(startup_screen.LAUNCH_VIDEO_SECONDS)
		1:
			_show_login()
			_startup_stage = 2
			_startup_timer.start(2.0)
		2:
			_show_loading()
		_:
			pass

func _skip_launch_video() -> void:
	if current_view != "launch":
		return
	if _startup_timer != null and not _startup_timer.is_stopped():
		_startup_timer.stop()
	_startup_stage = 2
	_show_login()
	if _startup_timer != null:
		_startup_timer.start(2.0)

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
	elif start_view == "bag":
		_enter_main_scene()
		_show_bag()
	elif start_view == "relics":
		_enter_main_scene()
		_show_relics()
	elif start_view == "develop":
		_enter_main_scene()
		_show_develop()
	elif start_view == "guild":
		_enter_main_scene()
		_show_guild()
	elif start_view == "activity":
		_enter_main_scene()
		_show_activity_center()
	elif start_view == "welfare":
		_enter_main_scene()
		_show_welfare()
	elif start_view == "month_card":
		_enter_main_scene()
		_show_month_card()
	elif start_view == "competition":
		_enter_main_scene()
		_show_competition()
	elif start_view == "assist":
		_enter_main_scene()
		_show_assist()
	elif start_view == "chat":
		_enter_main_scene()
		_show_chat()
	elif start_view == "wallpaper_select":
		_enter_main_scene()
		_show_wallpaper_select()
	elif start_view == "home_menu":
		_enter_main_scene()
		_show_home_menu()
	elif start_view == "charge":
		_enter_main_scene()
		_show_charge()
	elif start_view == "auto_fight":
		_enter_main_scene()
		_show_auto_fight()
	elif start_view == "chapter":
		_enter_main_scene()
		_show_chapter_progress()
	elif start_view == "shop":
		_enter_main_scene()
		_show_shop()
	elif start_view == "daily":
		_enter_main_scene()
		_show_daily()
	elif start_view == "mail":
		_enter_main_scene()
		_show_mail()
	elif start_view == "tasks":
		_enter_main_scene()
		_show_tasks()
	elif start_view == "gacha":
		_enter_main_scene()
		_show_gacha()
	elif start_view == "draw_animation":
		_enter_main_scene()
		_show_gacha()
		_show_draw_animation(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10)
	elif start_view == "draw_reveal":
		_enter_main_scene()
		_show_gacha()
		gacha_result_screen.show_recruit_reveal(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10)
	elif start_view == "draw_result":
		_enter_main_scene()
		_show_gacha()
		_draw_and_show(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10)
	elif start_view == "prayer":
		_enter_main_scene()
		_open_prayer_pool()
	elif start_view == "prayer_result":
		_enter_main_scene()
		_open_prayer_pool() if OS.get_environment("SHAONV_MVP_GACHA_POOL").is_empty() else _show_gacha()
		_show_prayer_rewards(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10, false)
	elif start_view == "prayer_reveal":
		_enter_main_scene()
		_open_prayer_pool() if OS.get_environment("SHAONV_MVP_GACHA_POOL").is_empty() else _show_gacha()
		_show_prayer_rewards(int(OS.get_environment("SHAONV_MVP_DRAW_COUNT")) if not OS.get_environment("SHAONV_MVP_DRAW_COUNT").is_empty() else 10, true)
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
	elif start_view == "expedition":
		_enter_main_scene()
		_show_expedition_main()
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
	_play_bgm(AUDIO_BGM_LOGIN, 0.65, true)
	startup_screen.show_login()

func _show_loading() -> void:
	startup_screen.show_loading()

func _enter_main_scene() -> void:
	_play_bgm(AUDIO_BGM_MAIN, 0.58, true)
	_set_chrome_visible(false)
	_show_home()

func _refresh_wallet() -> void:
	if top_bar != null and top_bar.get_child_count() > 1 and top_bar.get_child(1) is Button:
		top_bar.get_child(1).text = _profile_summary()
	wallet_label.text = "郵件 %d   喚靈券 %s   源石 %s" % [_unclaimed_mail_count(), save.get("tickets", 0), save.get("gems", 0)]

func _show_home() -> void:
	_play_bgm(AUDIO_BGM_MAIN, 0.58, true)
	home_screen.show_home()

func _show_gacha() -> void:
	_play_sfx(AUDIO_SFX_UI_DRAW_ENTER, 0.78)
	_push_view("喚靈")
	gacha_screen.show_gacha()

func _show_draw_animation(count: int) -> void:
	_push_view("招募演出")
	gacha_result_screen.show_draw_animation(count)

func _draw_and_show(count: int) -> void:
	_push_view("喚灵结果")
	gacha_result_screen.draw_and_show(count)

func _show_prayer_rewards(count: int, play_reveal: bool) -> void:
	_push_view("祈願结果")
	gacha_result_screen.show_prayer_rewards(count, play_reveal)

func _show_gal() -> void:
	gal_screen.show_gal()


func _show_gallery() -> void:
	hero_screen._show_gallery()

func _show_remnants_list() -> void:
	remnants_screen.show_list()


func _show_remnant_detail(hero_id: int) -> void:
	remnants_screen.show_detail(hero_id)


func _remnant_power(hero: Dictionary) -> int:
	return remnants_screen.remnant_power(hero)


func _remnant_attrs(hero: Dictionary) -> Dictionary:
	return remnants_screen.remnant_attrs(hero)


func _remnant_level(hero: Dictionary) -> int:
	return remnants_screen.remnant_level(hero)


func _remnant_star_level(hero: Dictionary) -> int:
	return remnants_screen.remnant_star_level(hero)


func _remnant_title_name(hero_id: int) -> String:
	return remnants_screen.remnant_title_name(hero_id)


func _remnant_element_name(hero_id: int) -> String:
	return remnants_screen.remnant_element_name(hero_id)


func _remnant_role_name(hero_id: int) -> String:
	return remnants_screen.remnant_role_name(hero_id)


func _remnants_primary_heroes() -> Array:
	return remnants_screen.primary_heroes()


func _remnants_sync_heroes() -> Array:
	return remnants_screen.sync_heroes()

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
	var forced_draw := not OS.get_environment("SHAONV_MVP_FORCE_DRAW_HERO_ID").is_empty()
	if not forced_draw and int(save.get("tickets", 0)) < cost:
		return []
	if not forced_draw:
		save["tickets"] = int(save.get("tickets", 0)) - cost
	save["draw_count"] = int(save.get("draw_count", 0)) + count
	save["gacha_integral"] = int(save.get("gacha_integral", 0)) + count * 10
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
	var forced_hero_id := int(OS.get_environment("SHAONV_MVP_FORCE_DRAW_HERO_ID")) if not OS.get_environment("SHAONV_MVP_FORCE_DRAW_HERO_ID").is_empty() else 0
	if forced_hero_id > 0:
		var forced_hero := _hero_by_id(forced_hero_id)
		if not forced_hero.is_empty():
			return _draw_result_for_hero(pool, forced_hero, int(forced_hero.get("rarity", 1)))
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
	return _draw_result_for_hero(pool, hero, rarity)

func _draw_result_for_hero(pool: Dictionary, hero: Dictionary, rarity: int) -> Dictionary:
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
	hero_screen._show_hero_detail(hero_id)

func _hero_power(hero: Dictionary) -> int:
	return hero_screen._hero_power(hero)

func _hero_unlock_shard_cost(hero: Dictionary) -> int:
	return hero_screen._hero_unlock_shard_cost(hero)

func _show_player_info() -> void:
	home_panel_screen.show_player_info()


func _show_settings() -> void:
	home_panel_screen.show_settings()


func _show_home_menu() -> void:
	home_panel_screen.show_home_menu()


func _show_home_notice() -> void:
	home_panel_screen.show_home_notice()


func _show_repair_notice() -> void:
	home_panel_screen.show_repair_notice()

func _show_home_panel(title_text: String, subtitle_text: String) -> Vector2:
	_clear(title_text)
	_draw_image(UI_MAIN_BG, Vector2(0, 0), CANVAS_SIZE, true, Color(1, 1, 1, 0.68))
	_draw_image(UI_MAIN_FULLSCREEN_OVERLAY, Vector2(0, 0), CANVAS_SIZE, true, Color(1, 1, 1, 0.14))
	_view_container().add_child(_panel(Vector2(0, 0), CANVAS_SIZE, Color(0.012, 0.016, 0.030, 0.58)))
	_view_container().add_child(_panel(Vector2(68, 54), Vector2(1144, 592), Color(0.045, 0.062, 0.100, 0.42)))
	_view_container().add_child(_panel(Vector2(72, 58), Vector2(1136, 586), Color(0.018, 0.025, 0.046, 0.58)))
	_draw_image(UI_MAIN_DIVIDER, Vector2(68, 54), Vector2(1144, 8), true, Color(0.72, 0.80, 1.0, 0.46))
	_draw_image(UI_MAIN_DIVIDER, Vector2(68, 638), Vector2(1144, 8), true, Color(0.72, 0.80, 1.0, 0.28))
	_draw_image(UI_COMMON_SECTION, Vector2(100, 122), Vector2(760, 32), true, Color(0.92, 0.96, 1.0, 0.44))
	_draw_image(UI_MAIN_DIVIDER, Vector2(98, 170), Vector2(1010, 10), true, Color(0.82, 0.90, 1.0, 0.42))
	var title := _label(title_text, 34)
	title.position = Vector2(104, 82)
	title.size = Vector2(320, 50)
	title.modulate = Color(1.0, 0.95, 0.76)
	_view_container().add_child(title)
	var subtitle := _label(subtitle_text, 18)
	subtitle.position = Vector2(106, 132)
	subtitle.size = Vector2(760, 34)
	subtitle.modulate = Color(0.92, 0.86, 0.82)
	_view_container().add_child(subtitle)
	_add_action_button("返回主界面", Vector2(104, 580), _show_home, Vector2(146, 44), UI_COMMON_BTN_WHITE)
	return Vector2(104, 188)


func _draw_home_resource_card(pos: Vector2, card_size: Vector2, tint := Color(1, 1, 1, 0.72), alt := false) -> void:
	if card_size.x > 520.0:
		_view_container().add_child(_panel(pos, card_size, Color(tint.r * 0.22, tint.g * 0.20, tint.b * 0.18, max(tint.a, 0.22))))
		_draw_image(UI_MAIN_DIVIDER, pos + Vector2(8, 0), Vector2(card_size.x - 16, 6), true, Color(tint.r, tint.g, tint.b, 0.30))
		_draw_image(UI_MAIN_DIVIDER, pos + Vector2(8, card_size.y - 6), Vector2(card_size.x - 16, 6), true, Color(tint.r, tint.g, tint.b, 0.18))
		return
	var path := UI_MAIN_SMALL_PANEL_ALT if alt else UI_MAIN_SMALL_PANEL
	_draw_image(path, pos, card_size, true, tint)
	_view_container().add_child(_panel(pos + Vector2(8, 8), card_size - Vector2(16, 16), Color(0.018, 0.022, 0.040, 0.30)))


func _draw_home_reward_icon(path: String, pos: Vector2, label_text := "", count_text := "") -> void:
	_draw_image(UI_MAIN_REWARD_FRAME, pos, Vector2(76, 96), true, Color(1, 1, 1, 0.76))
	_draw_image(path, pos + Vector2(12, 12), Vector2(52, 52), false, Color(1, 1, 1, 0.94))
	if not count_text.is_empty():
		var count := _label(count_text, 13, HORIZONTAL_ALIGNMENT_RIGHT)
		count.position = pos + Vector2(8, 59)
		count.size = Vector2(58, 18)
		count.modulate = Color(1.0, 0.92, 0.64)
		_view_container().add_child(count)
	if not label_text.is_empty():
		var label := _label(label_text, 12, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = pos + Vector2(2, 76)
		label.size = Vector2(72, 18)
		label.modulate = Color(0.92, 0.90, 0.84)
		_view_container().add_child(label)


func _draw_home_feature_icon(icon_path: String, pos: Vector2, label_text: String, callback: Callable, selected := false) -> void:
	_draw_image(UI_MAIN_LIMIT_ICON_FRAME, pos, Vector2(86, 86), false, Color(1, 1, 1, 0.76))
	_draw_image(icon_path, pos, Vector2(86, 86), false, Color(1, 1, 1, 0.94))
	if selected:
		_draw_image(UI_HERO_HIGHLIGHT, pos - Vector2(8, 8), Vector2(102, 102), false, Color(0.78, 1.0, 0.22, 0.48))
	var label := _label(label_text, 14, HORIZONTAL_ALIGNMENT_CENTER)
	label.position = pos + Vector2(-8, 82)
	label.size = Vector2(102, 24)
	label.modulate = Color(1.0, 0.95, 0.78)
	_view_container().add_child(label)
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.position = pos
	button.size = Vector2(86, 108)
	button.pressed.connect(func() -> void:
		_play_sfx(AUDIO_SFX_UI_MAIN, 0.72)
		callback.call()
	)
	_view_container().add_child(button)


func _show_bag() -> void:
	home_panel_screen.show_bag()


func _show_relics() -> void:
	home_panel_screen.show_relics()


func _show_develop() -> void:
	home_panel_screen.show_develop()


func _show_guild() -> void:
	home_panel_screen.show_guild()


func _show_activity_center() -> void:
	activity_screen.show_activity_center()


func _show_welfare() -> void:
	activity_screen.show_welfare()


func _show_month_card() -> void:
	activity_screen.show_month_card()


func _show_competition() -> void:
	activity_screen.show_competition()


func _show_assist() -> void:
	home_panel_screen.show_assist()


func _show_chat() -> void:
	home_panel_screen.show_chat()


func _show_wallpaper_select() -> void:
	home_panel_screen.show_wallpaper_select()

func _show_home_wallpaper_focus() -> void:
	home_screen.enter_wallpaper_focus()


func _show_charge() -> void:
	shop_screen.show_charge()


func _show_shop() -> void:
	shop_screen.show_shop()

func _show_daily() -> void:
	shop_screen.show_daily()

func _show_mail() -> void:
	home_panel_screen.show_mail()


func _show_tasks() -> void:
	home_panel_screen.show_tasks()

func _show_auto_fight() -> void:
	battle_screen.show_auto_fight()


func _show_chapter_progress() -> void:
	_show_expedition_main()


func _show_dust_transition() -> void:
	chapter_screen.show_dust_transition()


func _show_expedition_main() -> void:
	expedition_screen.show_expedition_main()


func _show_chapter_panel() -> void:
	chapter_screen.show_dust_exploration()


func _show_chapter_panel_for(chapter_index: int) -> void:
	chapter_screen.show_dust_exploration_for_chapter(chapter_index)


func _show_dust_exploration() -> void:
	chapter_screen.show_dust_exploration()


func _current_chapter_state() -> Dictionary:
	return chapter_screen.current_chapter_state()


func _chapter_state_for_index(chapter_index: int) -> Dictionary:
	return chapter_screen.chapter_state_for_index(chapter_index)


func _chapter_display_name(chapter: Dictionary, fallback_index: int = 1) -> String:
	return chapter_screen.chapter_display_name(chapter, fallback_index)


func _chapter_reward_items(chapter: Dictionary) -> Array:
	return chapter_screen.chapter_reward_items(chapter)


func _show_battle(message := "") -> void:
	battle_screen.show_battle(message)

func _buy_tickets(count: int) -> void:
	var cost := count * int(shop.get("exchangeGemCost", 160))
	if int(save.get("gems", 0)) < cost:
		return
	save["gems"] = int(save.get("gems", 0)) - cost
	save["tickets"] = int(save.get("tickets", 0)) + count * int(shop.get("ticketAmount", 1))
	_persist()
	_show_shop()


func _buy_charge_pack(pack: Dictionary) -> void:
	var key := str(pack.get("key", "charge_pack"))
	if bool(pack.get("once", false)):
		if bool(save.get(key, false)):
			_show_charge()
			return
		save[key] = true
	else:
		save[key] = int(save.get(key, 0)) + 1
	_grant_reward(int(pack.get("tickets", 0)), int(pack.get("gems", 0)))
	_persist()
	_show_charge()


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
	if _active_gacha_realm() == "prayer":
		save["active_pool_id"] = "normal"
		_persist()
	_show_gacha()

func _draw_home_bottom_bar() -> void:
	home_screen.draw_home_bottom_bar()

func _active_gacha_realm() -> String:
	var pool := _pool_by_id(str(save.get("active_pool_id", "advanced")))
	return "prayer" if str(pool.get("realm", "")) == "prayer" or str(pool.get("id", "")) == "prayer" else "present"

func _pool_in_realm(pool_id: String, realm: String) -> bool:
	var pool := _pool_by_id(pool_id)
	var pool_realm := str(pool.get("realm", "prayer" if pool_id == "prayer" else "present"))
	return pool_realm == realm

func _lottery_bg_for_pool(pool_id: String) -> String:
	match pool_id:
		"normal":
			return UI_LOTTERY_BG_NORMAL
		"epic":
			return UI_LOTTERY_BG_EPIC
		"prayer":
			return "res://assets/ui/lottery/bg/lottery_bg_05.png"
		"self_select_prayer":
			return "res://assets/ui/lottery/bg/lottery_bg_05.png"
		"source_prayer":
			return UI_LOTTERY_BG_PRAYER
		"saint_source_prayer":
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
		elif _active_gacha_realm() == "prayer":
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
	_draw_image(bg_path, Vector2(0, 0), CONTENT_SIZE, true)
	_view_container().add_child(_panel(Vector2(0, 0), CONTENT_SIZE, Color(0.02, 0.014, 0.016, 0.40)))
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
	rect.custom_minimum_size = draw_size
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_SCALE
	rect.modulate = tint
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view_container().add_child(rect)
	rect.size = draw_size
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

func _hero_recruit_video_path(hero: Dictionary) -> String:
	var spine_key := str(hero.get("spine", ""))
	if spine_key.is_empty():
		return ""
	var hero_recruit: Dictionary = video_manifest.get("heroRecruit", {})
	var path := str(hero_recruit.get(spine_key, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return ""
	return path

func _draw_video(path: String, pos: Vector2, draw_size: Vector2, on_finished := Callable(), autoplay := true) -> VideoStreamPlayer:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var stream := load(path)
	if stream == null:
		return null
	var video := VideoStreamPlayer.new()
	video.stream = stream
	video.position = pos
	video.size = draw_size
	video.expand = true
	video.autoplay = autoplay
	video.modulate.a = 0.0
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if on_finished.is_valid():
		video.finished.connect(func() -> void:
			on_finished.call()
		)
	_view_container().add_child(video)
	var tween := create_tween()
	tween.tween_property(video, "modulate:a", 1.0, 0.12).set_delay(0.08)
	if autoplay:
		video.play()
	return video

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

func _hero_grade(hero_or_id) -> String:
	var hero_id := 0
	if typeof(hero_or_id) == TYPE_DICTIONARY:
		hero_id = int(hero_or_id.get("id", 0))
	else:
		hero_id = int(hero_or_id)
	for item in hero_rarity_grades.get("heroes", []):
		if int(item.get("heroId", 0)) == hero_id:
			return str(item.get("grade", ""))
	var hero := {}
	if typeof(hero_or_id) == TYPE_DICTIONARY:
		hero = hero_or_id
	else:
		hero = _hero_by_id(hero_id)
	return str(hero_rarity_grades.get("rareToGrade", {}).get(str(int(hero.get("rarity", 1))), _stars(int(hero.get("rarity", 1)))))

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

func _gallery_filtered_heroes() -> Array:
	return hero_screen._gallery_filtered_heroes()

func _grant_reward(tickets: int, gems: int) -> void:
	_play_sfx(AUDIO_SFX_GET_REWARD, 0.85)
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
		if key == "music" and not _audio_enabled("music"):
			_stop_bgm()
		_show_settings()
	, Vector2(220, 44))

func _draw_startup_backdrop(base_color: Color, shade_color: Color) -> void:
	_view_container().add_child(_panel(Vector2(0, 0), CANVAS_SIZE, base_color))
	_view_container().add_child(_panel(Vector2(0, 0), CANVAS_SIZE, shade_color))
	_view_container().add_child(_panel(Vector2(0, 0), Vector2(CANVAS_WIDTH, 96), Color(0.01, 0.008, 0.007, 0.36)))
	_view_container().add_child(_panel(Vector2(0, CANVAS_HEIGHT - 96.0), Vector2(CANVAS_WIDTH, 96), Color(0.01, 0.008, 0.007, 0.46)))
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
	_play_sfx(AUDIO_SFX_POP_OPEN, 0.85)
	_view_container().add_child(_panel(Vector2(0, 0), CANVAS_SIZE, Color(0, 0, 0, 0.42)))
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

func _add_action_button(text: String, pos: Vector2, callback: Callable, size := Vector2(132, 44), bg_path := "") -> void:
	if not str(bg_path).is_empty():
		_draw_image(str(bg_path), pos, size, true, Color(1, 1, 1, 0.88))
	var button := Button.new()
	button.text = text
	button.flat = not str(bg_path).is_empty()
	button.focus_mode = Control.FOCUS_NONE
	button.position = pos
	button.size = size
	button.pressed.connect(func() -> void:
		_play_sfx(AUDIO_SFX_UI_CONFIRM, 0.70)
		callback.call()
	)
	_view_container().add_child(button)


func _add_hit_button(pos: Vector2, hit_size: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.position = pos
	button.size = hit_size
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(func() -> void:
		_play_sfx(AUDIO_SFX_UI_CONFIRM, 0.70)
		callback.call()
	)
	_view_container().add_child(button)

func _stars(count: int) -> String:
	return "★".repeat(clamp(count, 1, 5))
