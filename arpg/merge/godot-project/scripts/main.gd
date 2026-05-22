extends Control

const BlockCatalogScript := preload("res://scripts/models/block_catalog.gd")
const MergeBoardModelScript := preload("res://scripts/models/merge_board_model.gd")
const SaveManagerScript := preload("res://scripts/services/save_manager.gd")
const BootServicesReferenceScreenScript := preload("res://scripts/boot_services_reference_screen.gd")
const GameStartLoadReferenceScreenScript := preload("res://scripts/game_start_load_reference_screen.gd")
const ReloadSceneReferenceScreenScript := preload("res://scripts/reload_scene_reference_screen.gd")
const RuntimeCanvasBootstrapScreenScript := preload("res://scripts/runtime_canvas_bootstrap_screen.gd")
const LoadingReferenceScreenScript := preload("res://scripts/loading_reference_screen.gd")
const SceneLoadingReferenceScreenScript := preload("res://scripts/scene_loading_reference_screen.gd")
const MaidLobbyLoadingReferenceScreenScript := preload("res://scripts/maid_lobby_loading_reference_screen.gd")
const OutGameReferenceScreenScript := preload("res://scripts/out_game_reference_screen.gd")
const OutGameAppPopupReferenceScreenScript := preload("res://scripts/out_game_app_popup_reference_screen.gd")
const ShopPopupReferenceScreenScript := preload("res://scripts/shop_popup_reference_screen.gd")
const MailSettingsPopupReferenceScreenScript := preload("res://scripts/mail_settings_popup_reference_screen.gd")
const BagMenuPopupReferenceScreenScript := preload("res://scripts/bag_menu_popup_reference_screen.gd")
const FurnitureQuestPopupReferenceScreenScript := preload("res://scripts/furniture_quest_popup_reference_screen.gd")
const StoryMemoryPopupReferenceScreenScript := preload("res://scripts/story_memory_popup_reference_screen.gd")
const MaidLobbyReferenceScreenScript := preload("res://scripts/maid_lobby_reference_screen.gd")
const MaidLobbySelectPopupReferenceScreenScript := preload("res://scripts/maid_lobby_select_popup_reference_screen.gd")
const MaidDialogPopupReferenceScreenScript := preload("res://scripts/maid_dialog_popup_reference_screen.gd")
const InGameReferenceShellScript := preload("res://scripts/ingame_reference_shell.gd")
const InventoryPopupReferenceScreenScript := preload("res://scripts/inventory_popup_reference_screen.gd")
const RequestDetailPopupReferenceScreenScript := preload("res://scripts/request_detail_popup_reference_screen.gd")
const UILayoutReferencePreviewScript := preload("res://scripts/ui_layout_reference_preview.gd")
const CELL_SIZE := 78
const CELL_GAP := 8
const BOARD_ORIGIN := Vector2(360, 92)
const PORTRAIT_CELL_SIZE := 62
const PORTRAIT_CELL_GAP := 5
const PORTRAIT_BOARD_MARGIN := 24
const RESTORED_BOOT_SERVICES_SECONDS := 0.75
const RESTORED_GAME_START_LOAD_SECONDS := 0.95
const RESTORED_RELOAD_SCENE_SECONDS := 0.7
const RESTORED_UI_BOOTSTRAP_SECONDS := 0.55
const RESTORED_APP_LOADING_SECONDS := 2.0
const RESTORED_SCENE_LOADING_SECONDS := 1.7
const RESTORED_MAID_LOBBY_LOADING_SECONDS := 1.1
const STARTUP_CAPTURE_ARG := "--startup-capture-dir="
const AUTO_ENTER_INGAME_ARG := "--auto-enter-ingame"
const AUTO_ENTER_MAID_LOBBY_ARG := "--auto-enter-maid-lobby"
const AUTO_CAPTURE_OUTGAME_POPUPS_ARG := "--auto-capture-outgame-popups"
const SPRITE_DIR := "res://assets/sprites/"
const CHARACTER_DIR := "res://data/characters/"
const UI_LAYOUT_REFERENCE := "res://data/ui_layout_reference.json"
const UI_OUTGAME_LAYOUT_REFERENCE := "res://data/uioutgame_layout_reference.json"
const FOCUSED_UI_LAYOUT_REFERENCE := "res://data/focused_ui_layout_reference.json"

var catalog = BlockCatalogScript.new()
var board = MergeBoardModelScript.new()
var save_manager = SaveManagerScript.new()
var cell_nodes: Dictionary = {}
var block_nodes: Dictionary = {}
var dragging := false
var drag_from := Vector2i(-1, -1)
var drag_preview: TextureRect
var board_layer: Control
var block_layer: Control
var status_label: Label
var selected_label: Label
var produce_button: Button
var ap_label: Label
var gold_label: Label
var jewel_label: Label
var character_title_label: Label
var character_image: TextureRect
var character_image_status_label: Label
var character_meta_label: Label
var character_detail_label: Label
var character_mode_button: Button
var selected_cell := Vector2i(-1, -1)
var maids: Array = []
var customers: Array = []
var dialogs: Array = []
var character_mode := "maids"
var character_index := 0
var ui_layout_sources: Array = []
var ui_layout_index := 0
var uioutgame_layout_source: Dictionary = {}
var focused_ui_layout_sources: Dictionary = {}
var ui_layout_title_label: Label
var ui_layout_meta_label: Label
var ui_layout_preview: Control
var runtime_canvas_bootstrap_screen: Control
var loading_reference_screen: Control
var scene_loading_reference_screen: Control
var maid_lobby_loading_reference_screen: Control
var out_game_reference_screen: Control
var out_game_app_popup_reference_screen: Control
var shop_popup_reference_screen: Control
var mail_settings_popup_reference_screen: Control
var bag_menu_popup_reference_screen: Control
var furniture_quest_popup_reference_screen: Control
var story_memory_popup_reference_screen: Control
var maid_lobby_reference_screen: Control
var maid_lobby_select_popup_reference_screen: Control
var maid_dialog_popup_reference_screen: Control
var ingame_reference_shell: Control
var inventory_popup_reference_screen: Control
var request_detail_popup_reference_screen: Control
var boot_services_reference_screen: Control
var game_start_load_reference_screen: Control
var reload_scene_reference_screen: Control
var gameplay_root: Control
var portrait_hidden_controls: Array = []
var board_origin := BOARD_ORIGIN
var cell_size := CELL_SIZE
var cell_gap := CELL_GAP
var boot_services_reference_visible := false
var game_start_load_reference_visible := false
var reload_scene_reference_visible := false
var runtime_canvas_bootstrap_visible := false
var loading_reference_visible := false
var scene_loading_reference_visible := false
var maid_lobby_loading_reference_visible := false
var out_game_reference_visible := false
var out_game_app_popup_visible := false
var out_game_app_popup_key := "shop"
var shop_popup_visible := false
var mail_settings_popup_visible := false
var mail_settings_popup_key := "mail"
var bag_menu_popup_visible := false
var bag_menu_popup_key := "bag"
var furniture_quest_popup_visible := false
var story_memory_popup_visible := false
var out_game_maid_interaction_mode := false
var maid_lobby_reference_visible := false
var maid_lobby_select_popup_visible := false
var maid_dialog_popup_visible := false
var maid_dialog_index := 0
var inventory_popup_visible := false
var request_detail_popup_visible := false
var gameplay_visible := true
var restored_startup_mode := false
var restored_startup_elapsed := 0.0
var restored_startup_finished := false
var startup_capture_dir := ""
var startup_capture_flags := {}
var auto_enter_ingame := false
var auto_enter_ingame_done := false
var auto_enter_maid_lobby := false
var auto_enter_maid_lobby_done := false
var auto_capture_outgame_popups := false
var auto_capture_outgame_popups_done := false

func _ready() -> void:
	var user_args := OS.get_cmdline_user_args()
	restored_startup_mode = user_args.has("--restored-startup")
	auto_enter_ingame = user_args.has(AUTO_ENTER_INGAME_ARG)
	auto_enter_maid_lobby = user_args.has(AUTO_ENTER_MAID_LOBBY_ARG)
	auto_capture_outgame_popups = user_args.has(AUTO_CAPTURE_OUTGAME_POPUPS_ARG)
	for arg in user_args:
		if arg.begins_with(STARTUP_CAPTURE_ARG):
			startup_capture_dir = arg.substr(STARTUP_CAPTURE_ARG.length())
	catalog.load_from_file("res://data/blocks.json")
	catalog.load_rules("res://data/block_rules.json")
	_load_character_data()
	_load_ui_layout_reference()
	_load_uioutgame_layout_reference()
	_load_focused_ui_layout_reference()
	board.call("setup", catalog, "res://data/initial_board.json")
	board.board_changed.connect(_refresh_board)
	board.wallet_changed.connect(_refresh_wallet)
	board.cooldown_changed.connect(_refresh_selection)
	_build_ui()
	_refresh_wallet()
	_refresh_board()

func _build_ui() -> void:
	var bg := TextureRect.new()
	bg.texture = load(SPRITE_DIR + "BG_gameboard2.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var shade := ColorRect.new()
	shade.color = Color(0.06, 0.07, 0.08, 0.58)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	gameplay_root = Control.new()
	gameplay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(gameplay_root)

	ingame_reference_shell = InGameReferenceShellScript.new()
	ingame_reference_shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ingame_reference_shell.mouse_filter = Control.MOUSE_FILTER_PASS
	ingame_reference_shell.produce_requested.connect(_produce_selected)
	ingame_reference_shell.out_game_requested.connect(_return_to_out_game_from_ingame)
	ingame_reference_shell.inventory_requested.connect(_toggle_inventory_popup)
	ingame_reference_shell.request_detail_requested.connect(_show_request_detail_popup)
	gameplay_root.add_child(ingame_reference_shell)

	var title := Label.new()
	title.text = "MergeMaidCafe Godot Prototype"
	title.position = Vector2(32, 24)
	title.add_theme_font_size_override("font_size", 30)
	gameplay_root.add_child(title)
	portrait_hidden_controls.append(title)

	var info := Label.new()
	info.text = "Drag matching blocks to merge. Spawn consumes AP. Save uses user://prototype-save.json."
	info.position = Vector2(34, 62)
	info.add_theme_font_size_override("font_size", 15)
	gameplay_root.add_child(info)
	portrait_hidden_controls.append(info)

	ap_label = _make_currency_label("CURRENCY_AP.png", Vector2(34, 118))
	gold_label = _make_currency_label("CURRENCY_GOLD.png", Vector2(34, 166))
	jewel_label = _make_currency_label("CURRENCY_JEWEL.png", Vector2(34, 214))

	var spawn_button := _make_button("Spawn", Vector2(34, 286))
	spawn_button.pressed.connect(func() -> void:
		if not board.add_random_seed_block():
			_set_status("No AP or empty cells.")
		else:
			_set_status("Spawned a recovered level 1 block.")
	)
	gameplay_root.add_child(spawn_button)
	portrait_hidden_controls.append(spawn_button)

	produce_button = _make_button("Produce", Vector2(34, 340))
	produce_button.pressed.connect(func() -> void:
		_produce_selected()
	)
	gameplay_root.add_child(produce_button)

	var save_button := _make_button("Save", Vector2(34, 394))
	save_button.pressed.connect(func() -> void:
		save_manager.call("save_board", board)
		_set_status("Saved.")
	)
	gameplay_root.add_child(save_button)
	portrait_hidden_controls.append(save_button)

	var load_button := _make_button("Load", Vector2(34, 448))
	load_button.pressed.connect(func() -> void:
		if save_manager.call("load_board", board):
			_set_status("Loaded.")
		else:
			_set_status("No save file yet.")
	)
	gameplay_root.add_child(load_button)
	portrait_hidden_controls.append(load_button)

	var reset_button := _make_button("Reset", Vector2(34, 502))
	reset_button.pressed.connect(func() -> void:
		board.call("setup", catalog, "res://data/initial_board.json")
		selected_cell = Vector2i(-1, -1)
		_refresh_selection()
		_set_status("Reset to initial board.")
	)
	gameplay_root.add_child(reset_button)
	portrait_hidden_controls.append(reset_button)

	var loading_button := _make_button("Loading Ref", Vector2(34, 556))
	loading_button.size = Vector2(128, 40)
	loading_button.pressed.connect(func() -> void:
		_toggle_loading_reference()
	)
	gameplay_root.add_child(loading_button)
	portrait_hidden_controls.append(loading_button)

	var out_game_button := _make_button("OutGame Ref", Vector2(172, 556))
	out_game_button.size = Vector2(122, 40)
	out_game_button.pressed.connect(func() -> void:
		_toggle_out_game_reference()
	)
	gameplay_root.add_child(out_game_button)
	portrait_hidden_controls.append(out_game_button)

	selected_label = Label.new()
	selected_label.position = Vector2(34, 602)
	selected_label.size = Vector2(260, 40)
	selected_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_label.add_theme_font_size_override("font_size", 14)
	gameplay_root.add_child(selected_label)

	status_label = Label.new()
	status_label.text = "Ready."
	status_label.position = Vector2(34, 648)
	status_label.size = Vector2(260, 48)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	gameplay_root.add_child(status_label)

	board_layer = Control.new()
	board_layer.position = BOARD_ORIGIN
	gameplay_root.add_child(board_layer)

	block_layer = Control.new()
	block_layer.position = BOARD_ORIGIN
	gameplay_root.add_child(block_layer)

	_build_character_panel()
	_build_ui_layout_panel()
	_build_boot_services_reference_screen()
	_build_game_start_load_reference_screen()
	_build_reload_scene_reference_screen()
	_build_runtime_canvas_bootstrap_screen()
	_build_loading_reference_screen()
	_build_scene_loading_reference_screen()
	_build_maid_lobby_loading_reference_screen()
	_build_out_game_reference_screen()
	_build_out_game_app_popup_reference_screen()
	_build_shop_popup_reference_screen()
	_build_mail_settings_popup_reference_screen()
	_build_bag_menu_popup_reference_screen()
	_build_furniture_quest_popup_reference_screen()
	_build_story_memory_popup_reference_screen()
	_build_maid_lobby_reference_screen()
	_build_maid_lobby_select_popup_reference_screen()
	_build_maid_dialog_popup_reference_screen()
	_build_inventory_popup_reference_screen()
	_build_request_detail_popup_reference_screen()

	drag_preview = TextureRect.new()
	drag_preview.visible = false
	drag_preview.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gameplay_root.add_child(drag_preview)
	_refresh_selection()
	_refresh_character_panel()
	_refresh_ui_layout_panel(false)
	_apply_gameplay_layout()
	if restored_startup_mode:
		_set_gameplay_visible(false)
		_show_boot_services_reference()
		_set_boot_services_reference_state(0.0, "RuntimeInitializeOnLoad")
	else:
		_show_loading_reference()

func _process(delta: float) -> void:
	if not restored_startup_mode or restored_startup_finished:
		return
	restored_startup_elapsed += delta
	if restored_startup_elapsed < RESTORED_BOOT_SERVICES_SECONDS:
		var boot_progress := clampf(restored_startup_elapsed / RESTORED_BOOT_SERVICES_SECONDS, 0.0, 1.0)
		_set_boot_services_reference_state(boot_progress, _restored_boot_services_message(boot_progress))
		_maybe_capture_startup_frame("01-bootservices", 0.35)
		return
	var game_start_load_elapsed := restored_startup_elapsed - RESTORED_BOOT_SERVICES_SECONDS
	if game_start_load_elapsed < RESTORED_GAME_START_LOAD_SECONDS:
		var game_start_load_progress := clampf(game_start_load_elapsed / RESTORED_GAME_START_LOAD_SECONDS, 0.0, 1.0)
		if boot_services_reference_visible:
			boot_services_reference_visible = false
			_apply_boot_services_reference_visibility()
			_show_game_start_load_reference()
		_set_game_start_load_reference_state(game_start_load_progress, _restored_game_start_load_message(game_start_load_progress))
		_maybe_capture_startup_frame("02-gamestartload", RESTORED_BOOT_SERVICES_SECONDS + 0.45)
		return
	var reload_scene_elapsed := game_start_load_elapsed - RESTORED_GAME_START_LOAD_SECONDS
	if reload_scene_elapsed < RESTORED_RELOAD_SCENE_SECONDS:
		var reload_scene_progress := clampf(reload_scene_elapsed / RESTORED_RELOAD_SCENE_SECONDS, 0.0, 1.0)
		if game_start_load_reference_visible:
			game_start_load_reference_visible = false
			_apply_game_start_load_reference_visibility()
			_show_reload_scene_reference()
		_set_reload_scene_reference_state(reload_scene_progress, _restored_reload_scene_message(reload_scene_progress))
		_maybe_capture_startup_frame("03-reloadscene", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + 0.35)
		return
	var bootstrap_elapsed := reload_scene_elapsed - RESTORED_RELOAD_SCENE_SECONDS
	if bootstrap_elapsed < RESTORED_UI_BOOTSTRAP_SECONDS:
		var bootstrap_progress := clampf(bootstrap_elapsed / RESTORED_UI_BOOTSTRAP_SECONDS, 0.0, 1.0)
		if reload_scene_reference_visible:
			reload_scene_reference_visible = false
			_apply_reload_scene_reference_visibility()
			_show_runtime_canvas_bootstrap()
		_set_runtime_canvas_bootstrap_state(bootstrap_progress, _restored_ui_bootstrap_message(bootstrap_progress))
		_maybe_capture_startup_frame("04-runtimecanvas", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + RESTORED_RELOAD_SCENE_SECONDS + 0.3)
		return
	var app_elapsed := bootstrap_elapsed - RESTORED_UI_BOOTSTRAP_SECONDS
	if app_elapsed < RESTORED_APP_LOADING_SECONDS:
		var app_progress := clampf(app_elapsed / RESTORED_APP_LOADING_SECONDS, 0.0, 1.0)
		if runtime_canvas_bootstrap_visible:
			runtime_canvas_bootstrap_visible = false
			_apply_runtime_canvas_bootstrap_visibility()
			_show_loading_reference()
		_set_loading_reference_state(app_progress, _restored_app_loading_message(app_progress))
		_maybe_capture_startup_frame("05-uiloading", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + RESTORED_RELOAD_SCENE_SECONDS + RESTORED_UI_BOOTSTRAP_SECONDS + 1.0)
		return
	var scene_elapsed := app_elapsed - RESTORED_APP_LOADING_SECONDS
	if scene_elapsed < RESTORED_SCENE_LOADING_SECONDS:
		var scene_progress := clampf(scene_elapsed / RESTORED_SCENE_LOADING_SECONDS, 0.0, 1.0)
		if loading_reference_visible:
			loading_reference_visible = false
			_apply_loading_reference_visibility()
			_show_scene_loading_reference()
		_set_scene_loading_reference_state(scene_progress, _restored_scene_loading_message(scene_progress))
		_maybe_capture_startup_frame("06-uisceneloading", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + RESTORED_RELOAD_SCENE_SECONDS + RESTORED_UI_BOOTSTRAP_SECONDS + RESTORED_APP_LOADING_SECONDS + 0.9)
		_maybe_capture_startup_frame("07-uisceneloading-late", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + RESTORED_RELOAD_SCENE_SECONDS + RESTORED_UI_BOOTSTRAP_SECONDS + RESTORED_APP_LOADING_SECONDS + 1.45)
		return
	var maid_lobby_elapsed := scene_elapsed - RESTORED_SCENE_LOADING_SECONDS
	var maid_lobby_progress := clampf(maid_lobby_elapsed / RESTORED_MAID_LOBBY_LOADING_SECONDS, 0.0, 1.0)
	if scene_loading_reference_visible:
		scene_loading_reference_visible = false
		_apply_scene_loading_reference_visibility()
		_show_maid_lobby_loading_reference()
	_set_maid_lobby_loading_reference_state(maid_lobby_progress, _restored_maid_lobby_loading_message(maid_lobby_progress))
	_maybe_capture_startup_frame("08-maidlobbyloading", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + RESTORED_RELOAD_SCENE_SECONDS + RESTORED_UI_BOOTSTRAP_SECONDS + RESTORED_APP_LOADING_SECONDS + RESTORED_SCENE_LOADING_SECONDS + 0.45)
	if maid_lobby_progress >= 1.0:
		_finish_restored_startup()
		_maybe_capture_startup_frame("09-outgame", RESTORED_BOOT_SERVICES_SECONDS + RESTORED_GAME_START_LOAD_SECONDS + RESTORED_RELOAD_SCENE_SECONDS + RESTORED_UI_BOOTSTRAP_SECONDS + RESTORED_APP_LOADING_SECONDS + RESTORED_SCENE_LOADING_SECONDS + RESTORED_MAID_LOBBY_LOADING_SECONDS)
		if auto_enter_ingame and not auto_enter_ingame_done:
			auto_enter_ingame_done = true
			call_deferred("_auto_enter_gameplay_after_capture")
		elif auto_enter_maid_lobby and not auto_enter_maid_lobby_done:
			auto_enter_maid_lobby_done = true
			call_deferred("_auto_enter_maid_lobby_after_capture")
		elif auto_capture_outgame_popups and not auto_capture_outgame_popups_done:
			auto_capture_outgame_popups_done = true
			call_deferred("_auto_capture_outgame_popups_after_startup")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_gameplay_layout()

func _build_character_panel() -> void:
	var title := Label.new()
	title.text = "Character"
	title.position = Vector2(995, 92)
	title.add_theme_font_size_override("font_size", 24)
	gameplay_root.add_child(title)
	portrait_hidden_controls.append(title)

	character_mode_button = _make_button("Maids", Vector2(995, 132))
	character_mode_button.size = Vector2(122, 36)
	character_mode_button.pressed.connect(func() -> void:
		_toggle_character_mode()
	)
	gameplay_root.add_child(character_mode_button)
	portrait_hidden_controls.append(character_mode_button)

	var prev_button := _make_button("<", Vector2(1126, 132))
	prev_button.size = Vector2(48, 36)
	prev_button.pressed.connect(func() -> void:
		_step_character(-1)
	)
	gameplay_root.add_child(prev_button)
	portrait_hidden_controls.append(prev_button)

	var next_button := _make_button(">", Vector2(1184, 132))
	next_button.size = Vector2(48, 36)
	next_button.pressed.connect(func() -> void:
		_step_character(1)
	)
	gameplay_root.add_child(next_button)
	portrait_hidden_controls.append(next_button)

	character_image = TextureRect.new()
	character_image.position = Vector2(1010, 182)
	character_image.size = Vector2(210, 210)
	character_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gameplay_root.add_child(character_image)
	portrait_hidden_controls.append(character_image)

	character_image_status_label = Label.new()
	character_image_status_label.position = Vector2(1010, 270)
	character_image_status_label.size = Vector2(210, 86)
	character_image_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_image_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	character_image_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_image_status_label.add_theme_font_size_override("font_size", 14)
	gameplay_root.add_child(character_image_status_label)
	portrait_hidden_controls.append(character_image_status_label)

	character_title_label = Label.new()
	character_title_label.position = Vector2(995, 406)
	character_title_label.size = Vector2(240, 32)
	character_title_label.add_theme_font_size_override("font_size", 20)
	gameplay_root.add_child(character_title_label)
	portrait_hidden_controls.append(character_title_label)

	character_meta_label = Label.new()
	character_meta_label.position = Vector2(995, 442)
	character_meta_label.size = Vector2(240, 88)
	character_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_meta_label.add_theme_font_size_override("font_size", 14)
	gameplay_root.add_child(character_meta_label)
	portrait_hidden_controls.append(character_meta_label)

	character_detail_label = Label.new()
	character_detail_label.position = Vector2(995, 536)
	character_detail_label.size = Vector2(240, 132)
	character_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_detail_label.add_theme_font_size_override("font_size", 14)
	gameplay_root.add_child(character_detail_label)
	portrait_hidden_controls.append(character_detail_label)

func _build_ui_layout_panel() -> void:
	ui_layout_title_label = Label.new()
	ui_layout_title_label.text = "UI Ref"
	ui_layout_title_label.position = Vector2(995, 24)
	ui_layout_title_label.add_theme_font_size_override("font_size", 18)
	gameplay_root.add_child(ui_layout_title_label)
	portrait_hidden_controls.append(ui_layout_title_label)

	var next_button := _make_button("Next UI", Vector2(995, 52))
	next_button.size = Vector2(104, 32)
	next_button.pressed.connect(func() -> void:
		if ui_layout_sources.is_empty():
			_set_status("No UI layout reference data.")
			return
		ui_layout_index = posmod(ui_layout_index + 1, ui_layout_sources.size())
		_refresh_ui_layout_panel(true)
	)
	gameplay_root.add_child(next_button)
	portrait_hidden_controls.append(next_button)

	ui_layout_meta_label = Label.new()
	ui_layout_meta_label.position = Vector2(1108, 52)
	ui_layout_meta_label.size = Vector2(132, 34)
	ui_layout_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_layout_meta_label.add_theme_font_size_override("font_size", 12)
	gameplay_root.add_child(ui_layout_meta_label)
	portrait_hidden_controls.append(ui_layout_meta_label)

	ui_layout_preview = UILayoutReferencePreviewScript.new()
	ui_layout_preview.position = Vector2(742, 92)
	ui_layout_preview.size = Vector2(230, 408)
	ui_layout_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameplay_root.add_child(ui_layout_preview)
	portrait_hidden_controls.append(ui_layout_preview)

func _build_runtime_canvas_bootstrap_screen() -> void:
	runtime_canvas_bootstrap_screen = RuntimeCanvasBootstrapScreenScript.new()
	if restored_startup_mode:
		runtime_canvas_bootstrap_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		runtime_canvas_bootstrap_screen.position = Vector2(320, 24)
		runtime_canvas_bootstrap_screen.size = Vector2(650, 672)
	runtime_canvas_bootstrap_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	runtime_canvas_bootstrap_screen.visible = runtime_canvas_bootstrap_visible
	add_child(runtime_canvas_bootstrap_screen)

func _build_boot_services_reference_screen() -> void:
	boot_services_reference_screen = BootServicesReferenceScreenScript.new()
	if restored_startup_mode:
		boot_services_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		boot_services_reference_screen.position = Vector2(320, 24)
		boot_services_reference_screen.size = Vector2(650, 672)
	boot_services_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boot_services_reference_screen.visible = boot_services_reference_visible
	add_child(boot_services_reference_screen)

func _build_game_start_load_reference_screen() -> void:
	game_start_load_reference_screen = GameStartLoadReferenceScreenScript.new()
	if restored_startup_mode:
		game_start_load_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		game_start_load_reference_screen.position = Vector2(320, 24)
		game_start_load_reference_screen.size = Vector2(650, 672)
	game_start_load_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_start_load_reference_screen.visible = game_start_load_reference_visible
	add_child(game_start_load_reference_screen)

func _build_reload_scene_reference_screen() -> void:
	reload_scene_reference_screen = ReloadSceneReferenceScreenScript.new()
	if restored_startup_mode:
		reload_scene_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		reload_scene_reference_screen.position = Vector2(320, 24)
		reload_scene_reference_screen.size = Vector2(650, 672)
	reload_scene_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reload_scene_reference_screen.visible = reload_scene_reference_visible
	add_child(reload_scene_reference_screen)

func _build_loading_reference_screen() -> void:
	loading_reference_screen = LoadingReferenceScreenScript.new()
	if restored_startup_mode:
		loading_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		loading_reference_screen.position = Vector2(320, 24)
		loading_reference_screen.size = Vector2(650, 672)
	loading_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_reference_screen.visible = loading_reference_visible
	add_child(loading_reference_screen)

func _build_scene_loading_reference_screen() -> void:
	scene_loading_reference_screen = SceneLoadingReferenceScreenScript.new()
	if restored_startup_mode:
		scene_loading_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		scene_loading_reference_screen.position = Vector2(320, 24)
		scene_loading_reference_screen.size = Vector2(650, 672)
	scene_loading_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_loading_reference_screen.visible = scene_loading_reference_visible
	add_child(scene_loading_reference_screen)

func _build_maid_lobby_loading_reference_screen() -> void:
	maid_lobby_loading_reference_screen = MaidLobbyLoadingReferenceScreenScript.new()
	if restored_startup_mode:
		maid_lobby_loading_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		maid_lobby_loading_reference_screen.position = Vector2(320, 24)
		maid_lobby_loading_reference_screen.size = Vector2(650, 672)
	maid_lobby_loading_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	maid_lobby_loading_reference_screen.visible = maid_lobby_loading_reference_visible
	add_child(maid_lobby_loading_reference_screen)

func _build_out_game_reference_screen() -> void:
	out_game_reference_screen = OutGameReferenceScreenScript.new()
	if restored_startup_mode:
		out_game_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		out_game_reference_screen.position = Vector2(320, 24)
		out_game_reference_screen.size = Vector2(650, 672)
	out_game_reference_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	out_game_reference_screen.ingame_requested.connect(_enter_gameplay_from_out_game)
	out_game_reference_screen.maid_lobby_requested.connect(_enter_maid_lobby_from_out_game)
	out_game_reference_screen.interaction_requested.connect(_show_maid_dialog_popup)
	out_game_reference_screen.app_navigation_requested.connect(_show_out_game_app_popup)
	out_game_reference_screen.furniture_quest_requested.connect(_show_furniture_quest_popup)
	out_game_reference_screen.maid_interaction_mode_requested.connect(_set_out_game_maid_interaction_mode)
	out_game_reference_screen.maid_normal_requested.connect(_set_out_game_maid_normal_mode)
	out_game_reference_screen.visible = out_game_reference_visible
	add_child(out_game_reference_screen)

func _build_out_game_app_popup_reference_screen() -> void:
	out_game_app_popup_reference_screen = OutGameAppPopupReferenceScreenScript.new()
	out_game_app_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	out_game_app_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	out_game_app_popup_reference_screen.visible = false
	out_game_app_popup_reference_screen.close_requested.connect(_hide_out_game_app_popup)
	add_child(out_game_app_popup_reference_screen)

func _build_shop_popup_reference_screen() -> void:
	shop_popup_reference_screen = ShopPopupReferenceScreenScript.new()
	shop_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_popup_reference_screen.visible = false
	shop_popup_reference_screen.close_requested.connect(_hide_shop_popup)
	add_child(shop_popup_reference_screen)

func _build_mail_settings_popup_reference_screen() -> void:
	mail_settings_popup_reference_screen = MailSettingsPopupReferenceScreenScript.new()
	mail_settings_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mail_settings_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mail_settings_popup_reference_screen.visible = false
	mail_settings_popup_reference_screen.close_requested.connect(_hide_mail_settings_popup)
	add_child(mail_settings_popup_reference_screen)

func _build_bag_menu_popup_reference_screen() -> void:
	bag_menu_popup_reference_screen = BagMenuPopupReferenceScreenScript.new()
	bag_menu_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bag_menu_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bag_menu_popup_reference_screen.visible = false
	bag_menu_popup_reference_screen.close_requested.connect(_hide_bag_menu_popup)
	add_child(bag_menu_popup_reference_screen)

func _build_furniture_quest_popup_reference_screen() -> void:
	furniture_quest_popup_reference_screen = FurnitureQuestPopupReferenceScreenScript.new()
	furniture_quest_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	furniture_quest_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	furniture_quest_popup_reference_screen.visible = false
	furniture_quest_popup_reference_screen.close_requested.connect(_hide_furniture_quest_popup)
	add_child(furniture_quest_popup_reference_screen)

func _build_story_memory_popup_reference_screen() -> void:
	story_memory_popup_reference_screen = StoryMemoryPopupReferenceScreenScript.new()
	story_memory_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	story_memory_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	story_memory_popup_reference_screen.visible = false
	story_memory_popup_reference_screen.close_requested.connect(_hide_story_memory_popup)
	add_child(story_memory_popup_reference_screen)

func _build_maid_lobby_reference_screen() -> void:
	maid_lobby_reference_screen = MaidLobbyReferenceScreenScript.new()
	if restored_startup_mode:
		maid_lobby_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		maid_lobby_reference_screen.position = Vector2(320, 24)
		maid_lobby_reference_screen.size = Vector2(650, 672)
	maid_lobby_reference_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	maid_lobby_reference_screen.back_requested.connect(_return_to_out_game_from_maid_lobby)
	maid_lobby_reference_screen.dialog_requested.connect(_show_maid_dialog_popup)
	maid_lobby_reference_screen.select_requested.connect(_show_maid_lobby_select_popup)
	maid_lobby_reference_screen.visible = maid_lobby_reference_visible
	add_child(maid_lobby_reference_screen)

func _build_maid_lobby_select_popup_reference_screen() -> void:
	maid_lobby_select_popup_reference_screen = MaidLobbySelectPopupReferenceScreenScript.new()
	maid_lobby_select_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	maid_lobby_select_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	maid_lobby_select_popup_reference_screen.visible = false
	maid_lobby_select_popup_reference_screen.close_requested.connect(_hide_maid_lobby_select_popup)
	maid_lobby_select_popup_reference_screen.maid_selected.connect(_select_maid_from_lobby_popup)
	add_child(maid_lobby_select_popup_reference_screen)

func _build_maid_dialog_popup_reference_screen() -> void:
	maid_dialog_popup_reference_screen = MaidDialogPopupReferenceScreenScript.new()
	maid_dialog_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	maid_dialog_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	maid_dialog_popup_reference_screen.visible = false
	maid_dialog_popup_reference_screen.close_requested.connect(_hide_maid_dialog_popup)
	maid_dialog_popup_reference_screen.next_requested.connect(_next_maid_dialog)
	add_child(maid_dialog_popup_reference_screen)

func _build_inventory_popup_reference_screen() -> void:
	inventory_popup_reference_screen = InventoryPopupReferenceScreenScript.new()
	inventory_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventory_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_popup_reference_screen.visible = false
	inventory_popup_reference_screen.close_requested.connect(_hide_inventory_popup)
	add_child(inventory_popup_reference_screen)

func _build_request_detail_popup_reference_screen() -> void:
	request_detail_popup_reference_screen = RequestDetailPopupReferenceScreenScript.new()
	request_detail_popup_reference_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	request_detail_popup_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	request_detail_popup_reference_screen.visible = false
	request_detail_popup_reference_screen.close_requested.connect(_hide_request_detail_popup)
	add_child(request_detail_popup_reference_screen)

func _make_currency_label(icon_name: String, pos: Vector2) -> Label:
	var icon := TextureRect.new()
	icon.texture = load(SPRITE_DIR + icon_name)
	icon.position = pos
	icon.custom_minimum_size = Vector2(34, 34)
	icon.size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gameplay_root.add_child(icon)
	portrait_hidden_controls.append(icon)

	var label := Label.new()
	label.position = pos + Vector2(44, 5)
	label.add_theme_font_size_override("font_size", 21)
	gameplay_root.add_child(label)
	portrait_hidden_controls.append(label)
	return label

func _make_button(text: String, pos: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(180, 40)
	return button

func _load_character_data() -> void:
	var maid_text := FileAccess.get_file_as_string(CHARACTER_DIR + "maids.json")
	var maid_payload = JSON.parse_string(maid_text)
	if typeof(maid_payload) == TYPE_DICTIONARY:
		maids = maid_payload.get("maids", [])
	var customer_text := FileAccess.get_file_as_string(CHARACTER_DIR + "customers.json")
	var customer_payload = JSON.parse_string(customer_text)
	if typeof(customer_payload) == TYPE_DICTIONARY:
		customers = customer_payload.get("customers", [])
	var dialog_text := FileAccess.get_file_as_string(CHARACTER_DIR + "dialogs.json")
	var dialog_payload = JSON.parse_string(dialog_text)
	if typeof(dialog_payload) == TYPE_DICTIONARY:
		dialogs = dialog_payload.get("dialogs", [])

func _load_ui_layout_reference() -> void:
	var text := FileAccess.get_file_as_string(UI_LAYOUT_REFERENCE)
	var payload = JSON.parse_string(text)
	if typeof(payload) == TYPE_DICTIONARY:
		ui_layout_sources = payload.get("sources", [])

func _load_uioutgame_layout_reference() -> void:
	if not FileAccess.file_exists(UI_OUTGAME_LAYOUT_REFERENCE):
		return
	var text := FileAccess.get_file_as_string(UI_OUTGAME_LAYOUT_REFERENCE)
	var payload = JSON.parse_string(text)
	if typeof(payload) != TYPE_DICTIONARY:
		return
	for prefab in payload.get("prefabs", []):
		if typeof(prefab) == TYPE_DICTIONARY and String(prefab.get("path", "")) == "Assets/Resources/prefabs/ui/UIOutGame.prefab":
			uioutgame_layout_source = prefab.duplicate(true)
			uioutgame_layout_source["name"] = "UIOutGame"
			uioutgame_layout_source["source_type"] = "prefab"
			uioutgame_layout_source["source_path"] = prefab.get("path", "")
			uioutgame_layout_source["reference_resolution"] = {
				"width": 1080,
				"height": 1920,
				"basis": "inferred from recovered UILoading root; CanvasScaler still unconfirmed"
			}
			return

func _load_focused_ui_layout_reference() -> void:
	if not FileAccess.file_exists(FOCUSED_UI_LAYOUT_REFERENCE):
		return
	var text := FileAccess.get_file_as_string(FOCUSED_UI_LAYOUT_REFERENCE)
	var payload = JSON.parse_string(text)
	if typeof(payload) != TYPE_DICTIONARY:
		return
	for target in payload.get("targets", []):
		if typeof(target) != TYPE_DICTIONARY:
			continue
		var name := String(target.get("name", ""))
		var prefab: Dictionary = target.get("prefab", {})
		if name.is_empty() or prefab.is_empty():
			continue
		var source := prefab.duplicate(true)
		source["name"] = name
		source["source_type"] = "prefab"
		source["source_path"] = prefab.get("path", "")
		source["reference_resolution"] = {
			"width": 1080,
			"height": 1920,
			"basis": "inferred from recovered UILoading root; CanvasScaler still unconfirmed"
		}
		focused_ui_layout_sources[name] = source

func _refresh_ui_layout_panel(write_status: bool) -> void:
	if ui_layout_meta_label == null:
		return
	if ui_layout_sources.is_empty():
		ui_layout_meta_label.text = "no data"
		return
	ui_layout_index = clampi(ui_layout_index, 0, ui_layout_sources.size() - 1)
	var source: Dictionary = ui_layout_sources[ui_layout_index]
	ui_layout_meta_label.text = "%s\n%s rects" % [
		source.get("name", "UI"),
		source.get("rect_transform_count", 0)
	]
	if ui_layout_preview != null:
		ui_layout_preview.call("set_source", source)
	if write_status:
		_set_status(_describe_ui_layout_source(source))

func _toggle_loading_reference() -> void:
	if loading_reference_screen == null:
		return
	loading_reference_visible = not loading_reference_visible
	_apply_loading_reference_visibility()
	_set_status("Loading reference %s." % ("shown" if loading_reference_visible else "hidden"))

func _toggle_out_game_reference() -> void:
	if out_game_reference_screen == null:
		return
	out_game_reference_visible = not out_game_reference_visible
	_apply_out_game_reference_visibility()
	_set_status("OutGame reference %s." % ("shown" if out_game_reference_visible else "hidden"))

func _show_runtime_canvas_bootstrap() -> void:
	runtime_canvas_bootstrap_visible = true
	_apply_runtime_canvas_bootstrap_visibility()

func _show_boot_services_reference() -> void:
	boot_services_reference_visible = true
	_apply_boot_services_reference_visibility()

func _show_game_start_load_reference() -> void:
	game_start_load_reference_visible = true
	_apply_game_start_load_reference_visibility()

func _show_reload_scene_reference() -> void:
	reload_scene_reference_visible = true
	_apply_reload_scene_reference_visibility()

func _apply_boot_services_reference_visibility() -> void:
	if boot_services_reference_screen == null:
		return
	boot_services_reference_screen.visible = boot_services_reference_visible

func _apply_game_start_load_reference_visibility() -> void:
	if game_start_load_reference_screen == null:
		return
	game_start_load_reference_screen.visible = game_start_load_reference_visible

func _apply_reload_scene_reference_visibility() -> void:
	if reload_scene_reference_screen == null:
		return
	reload_scene_reference_screen.visible = reload_scene_reference_visible

func _apply_runtime_canvas_bootstrap_visibility() -> void:
	if runtime_canvas_bootstrap_screen == null:
		return
	runtime_canvas_bootstrap_screen.visible = runtime_canvas_bootstrap_visible

func _show_loading_reference() -> void:
	loading_reference_visible = true
	_apply_loading_reference_visibility()

func _apply_loading_reference_visibility() -> void:
	if loading_reference_screen == null:
		return
	var loading_source := _ui_layout_source_by_name("UILoading")
	if loading_source.is_empty():
		loading_reference_screen.visible = false
		return
	loading_reference_screen.call("set_source", loading_source)
	loading_reference_screen.visible = loading_reference_visible

func _show_scene_loading_reference() -> void:
	scene_loading_reference_visible = true
	_apply_scene_loading_reference_visibility()

func _apply_scene_loading_reference_visibility() -> void:
	if scene_loading_reference_screen == null:
		return
	var scene_loading_source := _ui_layout_source_by_name("UISceneLoading")
	if scene_loading_source.is_empty():
		scene_loading_reference_screen.visible = false
		return
	scene_loading_reference_screen.call("set_source", scene_loading_source)
	scene_loading_reference_screen.visible = scene_loading_reference_visible

func _show_maid_lobby_loading_reference() -> void:
	maid_lobby_loading_reference_visible = true
	_apply_maid_lobby_loading_reference_visibility()

func _apply_maid_lobby_loading_reference_visibility() -> void:
	if maid_lobby_loading_reference_screen == null:
		return
	var maid_lobby_loading_source := _ui_layout_source_by_name("UIMaidLobbyLoading")
	if maid_lobby_loading_source.is_empty():
		maid_lobby_loading_reference_screen.visible = false
		return
	maid_lobby_loading_reference_screen.call("set_source", maid_lobby_loading_source)
	maid_lobby_loading_reference_screen.visible = maid_lobby_loading_reference_visible

func _show_out_game_reference() -> void:
	out_game_reference_visible = true
	_apply_out_game_reference_visibility()

func _apply_out_game_reference_visibility() -> void:
	if out_game_reference_screen == null:
		return
	var out_game_source := _ui_layout_source_by_name("UIOutGame")
	if not uioutgame_layout_source.is_empty():
		out_game_source = uioutgame_layout_source
	if out_game_source.is_empty():
		out_game_reference_screen.visible = false
		return
	out_game_reference_screen.call("set_source", out_game_source)
	out_game_reference_screen.call("set_wallet", board.wallet)
	out_game_reference_screen.call("set_maid_interaction_mode", out_game_maid_interaction_mode)
	out_game_reference_screen.visible = out_game_reference_visible
	if not out_game_reference_visible:
		_hide_out_game_app_popup()
		_hide_shop_popup()
		_hide_mail_settings_popup()
		_hide_bag_menu_popup()
		_hide_furniture_quest_popup()
		_hide_story_memory_popup()

func _apply_out_game_app_popup() -> void:
	if out_game_app_popup_reference_screen == null:
		return
	out_game_app_popup_reference_screen.call("set_popup_state", out_game_app_popup_visible, out_game_app_popup_key)

func _apply_shop_popup() -> void:
	if shop_popup_reference_screen == null:
		return
	var source: Dictionary = focused_ui_layout_sources.get("UIPopup_Shop", {})
	if not source.is_empty():
		shop_popup_reference_screen.call("set_source", source)
	shop_popup_reference_screen.call("set_popup_state", shop_popup_visible, board.wallet)

func _apply_mail_settings_popup() -> void:
	if mail_settings_popup_reference_screen == null:
		return
	mail_settings_popup_reference_screen.call("set_popup_state", mail_settings_popup_visible, mail_settings_popup_key)

func _apply_bag_menu_popup() -> void:
	if bag_menu_popup_reference_screen == null:
		return
	bag_menu_popup_reference_screen.call("set_popup_state", bag_menu_popup_visible, bag_menu_popup_key)

func _apply_furniture_quest_popup() -> void:
	if furniture_quest_popup_reference_screen == null:
		return
	var source: Dictionary = focused_ui_layout_sources.get("UIFurnitureQuest", {})
	if not source.is_empty():
		furniture_quest_popup_reference_screen.call("set_source", source)
	furniture_quest_popup_reference_screen.call("set_popup_state", furniture_quest_popup_visible, board.wallet)

func _apply_story_memory_popup() -> void:
	if story_memory_popup_reference_screen == null:
		return
	story_memory_popup_reference_screen.call("set_popup_open", story_memory_popup_visible)

func _apply_maid_lobby_reference_visibility() -> void:
	if maid_lobby_reference_screen == null:
		return
	var source: Dictionary = focused_ui_layout_sources.get("UIMaidLobby", {})
	if not source.is_empty():
		maid_lobby_reference_screen.call("set_source", source)
	maid_lobby_reference_screen.call("set_maids", maids, character_index)
	maid_lobby_reference_screen.visible = maid_lobby_reference_visible
	maid_lobby_reference_screen.mouse_filter = Control.MOUSE_FILTER_STOP if maid_lobby_reference_visible else Control.MOUSE_FILTER_IGNORE
	if not maid_lobby_reference_visible:
		_hide_maid_lobby_select_popup()

func _apply_maid_lobby_select_popup() -> void:
	if maid_lobby_select_popup_reference_screen == null:
		return
	var source: Dictionary = focused_ui_layout_sources.get("UIPopup_MaidLobbySelect", {})
	if not source.is_empty():
		maid_lobby_select_popup_reference_screen.call("set_source", source)
	maid_lobby_select_popup_reference_screen.call("set_maids", maids, character_index)
	maid_lobby_select_popup_reference_screen.call("set_popup_open", maid_lobby_select_popup_visible)

func _apply_maid_dialog_popup() -> void:
	if maid_dialog_popup_reference_screen == null:
		return
	maid_dialog_popup_reference_screen.call("set_dialog_state", _current_maid_entry(), _current_maid_dialogs(), maid_dialog_index)
	maid_dialog_popup_reference_screen.call("set_popup_open", maid_dialog_popup_visible)

func _set_gameplay_visible(next_visible: bool) -> void:
	gameplay_visible = next_visible
	if gameplay_root != null:
		gameplay_root.visible = gameplay_visible
	if not gameplay_visible:
		_hide_inventory_popup()
		_hide_request_detail_popup()

func _enter_gameplay_from_out_game() -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_bag_menu_popup()
	_set_out_game_maid_normal_mode()
	out_game_reference_visible = false
	_apply_out_game_reference_visibility()
	maid_lobby_reference_visible = false
	_apply_maid_lobby_reference_visibility()
	_hide_maid_lobby_select_popup()
	_hide_maid_dialog_popup()
	_set_gameplay_visible(true)
	_apply_gameplay_layout()
	_set_status("Entered recovered merge gameplay from UIOutGame/InGameBtn.")
	_maybe_capture_ingame_frame()

func _enter_maid_lobby_from_out_game() -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_bag_menu_popup()
	_set_out_game_maid_normal_mode()
	out_game_reference_visible = false
	_apply_out_game_reference_visibility()
	maid_lobby_reference_visible = true
	_apply_maid_lobby_reference_visibility()
	_set_gameplay_visible(false)
	_set_status("Entered first-pass UIMaidLobby shell from UIOutGame/MaidLobbyBtn.")
	_maybe_capture_maid_lobby_frame()

func _auto_enter_gameplay_after_capture() -> void:
	await RenderingServer.frame_post_draw
	_enter_gameplay_from_out_game_without_capture()
	_select_first_producer_for_capture()
	await RenderingServer.frame_post_draw
	_maybe_capture_ingame_frame()
	await RenderingServer.frame_post_draw
	_show_inventory_popup()

func _auto_enter_maid_lobby_after_capture() -> void:
	await RenderingServer.frame_post_draw
	_enter_maid_lobby_from_out_game()
	await RenderingServer.frame_post_draw
	_show_maid_lobby_select_popup()
	await RenderingServer.frame_post_draw
	_hide_maid_lobby_select_popup()
	_show_maid_dialog_popup()

func _auto_capture_outgame_popups_after_startup() -> void:
	await RenderingServer.frame_post_draw
	_maybe_capture_named_frame("10-outgame-home")
	var sequence := [
		{"key": "shop", "label": "11-outgame-shop"},
		{"key": "story", "label": "12-outgame-story"},
		{"key": "furniture", "label": "13-outgame-furniture"},
		{"key": "mail", "label": "14-outgame-mail"},
		{"key": "settings", "label": "15-outgame-settings"},
		{"key": "bag", "label": "16-outgame-bag"},
		{"key": "menu", "label": "17-outgame-menu"},
	]
	for entry in sequence:
		_hide_all_out_game_popups()
		await RenderingServer.frame_post_draw
		var key := String(entry.get("key", ""))
		if key == "furniture":
			_show_furniture_quest_popup()
		else:
			_show_out_game_app_popup(key)
		await RenderingServer.frame_post_draw
		_maybe_capture_named_frame(String(entry.get("label", key)))
		await RenderingServer.frame_post_draw
	_hide_all_out_game_popups()
	_set_status("Captured UIOutGame popup regression set.")

func _enter_gameplay_from_out_game_without_capture() -> void:
	out_game_reference_visible = false
	_apply_out_game_reference_visibility()
	maid_lobby_reference_visible = false
	_apply_maid_lobby_reference_visibility()
	_set_gameplay_visible(true)
	_apply_gameplay_layout()
	_set_status("Entered recovered merge gameplay from UIOutGame/InGameBtn.")

func _return_to_out_game_from_ingame() -> void:
	_hide_inventory_popup()
	_hide_request_detail_popup()
	_set_gameplay_visible(false)
	_show_out_game_reference()
	_set_status("Returned to UIOutGame from UIInGame/Bottom/Lobby.")

func _return_to_out_game_from_maid_lobby() -> void:
	_hide_maid_lobby_select_popup()
	_hide_maid_dialog_popup()
	maid_lobby_reference_visible = false
	_apply_maid_lobby_reference_visibility()
	_show_out_game_reference()
	_set_status("Returned to UIOutGame from UIMaidLobby.")

func _show_out_game_app_popup(app_key: String) -> void:
	_hide_furniture_quest_popup()
	_hide_story_memory_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_bag_menu_popup()
	_set_out_game_maid_normal_mode()
	if app_key == "story":
		_show_story_memory_popup()
		return
	if app_key == "shop":
		_show_shop_popup()
		return
	if app_key == "mail" or app_key == "settings":
		_show_mail_settings_popup(app_key)
		return
	if app_key == "bag" or app_key == "menu":
		_show_bag_menu_popup(app_key)
		return
	out_game_app_popup_key = app_key
	out_game_app_popup_visible = true
	_apply_out_game_app_popup()
	_set_status("Opened first-pass UIOutGame %s popup shell." % app_key)

func _hide_out_game_app_popup() -> void:
	out_game_app_popup_visible = false
	_apply_out_game_app_popup()

func _hide_all_out_game_popups() -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_bag_menu_popup()
	_hide_furniture_quest_popup()
	_hide_story_memory_popup()

func _show_shop_popup() -> void:
	_hide_out_game_app_popup()
	_hide_furniture_quest_popup()
	_hide_story_memory_popup()
	_set_out_game_maid_normal_mode()
	shop_popup_visible = true
	_apply_shop_popup()
	_set_status("Opened first-pass UIOutGame Shop shell.")

func _hide_shop_popup() -> void:
	shop_popup_visible = false
	_apply_shop_popup()

func _show_mail_settings_popup(app_key: String) -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_furniture_quest_popup()
	_hide_story_memory_popup()
	_set_out_game_maid_normal_mode()
	mail_settings_popup_key = app_key
	mail_settings_popup_visible = true
	_apply_mail_settings_popup()
	_set_status("Opened first-pass UIOutGame %s shell." % app_key)

func _hide_mail_settings_popup() -> void:
	mail_settings_popup_visible = false
	_apply_mail_settings_popup()

func _show_bag_menu_popup(app_key: String) -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_furniture_quest_popup()
	_hide_story_memory_popup()
	_set_out_game_maid_normal_mode()
	bag_menu_popup_key = app_key
	bag_menu_popup_visible = true
	_apply_bag_menu_popup()
	_set_status("Opened first-pass UIOutGame %s shell." % app_key)

func _hide_bag_menu_popup() -> void:
	bag_menu_popup_visible = false
	_apply_bag_menu_popup()

func _show_furniture_quest_popup() -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_bag_menu_popup()
	_hide_story_memory_popup()
	_set_out_game_maid_normal_mode()
	furniture_quest_popup_visible = true
	_apply_furniture_quest_popup()
	_set_status("Opened first-pass UIOutGame FurnitureQuest shell.")

func _hide_furniture_quest_popup() -> void:
	furniture_quest_popup_visible = false
	_apply_furniture_quest_popup()

func _show_story_memory_popup() -> void:
	_hide_out_game_app_popup()
	_hide_shop_popup()
	_hide_mail_settings_popup()
	_hide_bag_menu_popup()
	_hide_furniture_quest_popup()
	_set_out_game_maid_normal_mode()
	story_memory_popup_visible = true
	_apply_story_memory_popup()
	_set_status("Opened first-pass UIOutGame Story/Memory shell.")

func _hide_story_memory_popup() -> void:
	story_memory_popup_visible = false
	_apply_story_memory_popup()

func _set_out_game_maid_interaction_mode() -> void:
	out_game_maid_interaction_mode = true
	_apply_out_game_reference_visibility()
	_set_status("Entered UIOutGame/UIMaidLD interaction mode.")

func _set_out_game_maid_normal_mode() -> void:
	out_game_maid_interaction_mode = false
	_apply_out_game_reference_visibility()

func _apply_request_detail_popup() -> void:
	if request_detail_popup_reference_screen == null:
		return
	request_detail_popup_reference_screen.call("set_request_state", request_detail_popup_visible, _selected_block_summary(), _board_block_summaries(), board.wallet)

func _show_request_detail_popup() -> void:
	request_detail_popup_visible = true
	_apply_request_detail_popup()
	_set_status("Opened first-pass UIInGame request detail shell.")

func _hide_request_detail_popup() -> void:
	request_detail_popup_visible = false
	_apply_request_detail_popup()

func _show_maid_lobby_select_popup() -> void:
	maid_lobby_select_popup_visible = true
	_apply_maid_lobby_select_popup()
	_set_status("Opened recovered UIPopup_MaidLobbySelect shell.")
	_maybe_capture_maid_lobby_select_frame()

func _hide_maid_lobby_select_popup() -> void:
	maid_lobby_select_popup_visible = false
	_apply_maid_lobby_select_popup()

func _select_maid_from_lobby_popup(index: int) -> void:
	if maids.is_empty():
		return
	character_index = clampi(index, 0, maids.size() - 1)
	_apply_maid_lobby_reference_visibility()
	_hide_maid_lobby_select_popup()
	_set_status("Selected maid from UIPopup_MaidLobbySelect.")

func _show_maid_dialog_popup() -> void:
	maid_dialog_popup_visible = true
	maid_dialog_index = 0
	_apply_maid_dialog_popup()
	_set_status("Opened recovered maid dialog shell.")
	_maybe_capture_maid_dialog_frame()

func _hide_maid_dialog_popup() -> void:
	maid_dialog_popup_visible = false
	_apply_maid_dialog_popup()

func _next_maid_dialog() -> void:
	var candidates := _current_maid_dialogs()
	if candidates.is_empty():
		return
	maid_dialog_index = posmod(maid_dialog_index + 1, candidates.size())
	_apply_maid_dialog_popup()

func _select_first_producer_for_capture() -> void:
	for y in range(board.height):
		for x in range(board.width):
			var block_id := board.get_block(x, y)
			if block_id.is_empty():
				continue
			if not catalog.get_produce_rule(block_id).is_empty():
				selected_cell = Vector2i(x, y)
				_refresh_selection()
				_set_status("Auto-selected recovered producer for UIInGame operation capture.")
				return

func _toggle_inventory_popup() -> void:
	if inventory_popup_visible:
		_hide_inventory_popup()
	else:
		_show_inventory_popup()

func _show_inventory_popup() -> void:
	inventory_popup_visible = true
	_apply_inventory_popup()
	_set_status("Opened recovered UIPopup_Inventory shell.")
	_maybe_capture_inventory_frame()

func _hide_inventory_popup() -> void:
	inventory_popup_visible = false
	_apply_inventory_popup()

func _apply_inventory_popup() -> void:
	if inventory_popup_reference_screen == null:
		return
	var source: Dictionary = focused_ui_layout_sources.get("UIPopup_Inventory", {})
	if not source.is_empty():
		inventory_popup_reference_screen.call("set_source", source)
	inventory_popup_reference_screen.call("set_inventory_state", _selected_block_summary(), _board_block_summaries(), board.wallet)
	inventory_popup_reference_screen.call("set_popup_open", inventory_popup_visible)

func _apply_gameplay_layout() -> void:
	if gameplay_root == null:
		return
	var viewport_size := get_viewport_rect().size
	var is_portrait := viewport_size.y >= viewport_size.x
	var pitch: float
	if is_portrait:
		cell_size = PORTRAIT_CELL_SIZE
		cell_gap = PORTRAIT_CELL_GAP
		pitch = cell_size + cell_gap
		var board_size := Vector2(board.width * cell_size + maxf(0, board.width - 1) * cell_gap, board.height * cell_size + maxf(0, board.height - 1) * cell_gap)
		board_origin = Vector2((viewport_size.x - board_size.x) * 0.5, 170)
		_layout_control(selected_label, Vector2(PORTRAIT_BOARD_MARGIN, 696), Vector2(viewport_size.x - PORTRAIT_BOARD_MARGIN * 2.0, 48), 14)
		_layout_control(status_label, Vector2(PORTRAIT_BOARD_MARGIN, 746), Vector2(viewport_size.x - PORTRAIT_BOARD_MARGIN * 2.0, 44), 14)
		if selected_label != null:
			selected_label.visible = false
		if status_label != null:
			status_label.visible = false
		_layout_control(produce_button, Vector2(PORTRAIT_BOARD_MARGIN, 790), Vector2(150, 40), 0)
		if produce_button != null:
			produce_button.visible = false
		_hide_desktop_side_panels(true)
	else:
		cell_size = CELL_SIZE
		cell_gap = CELL_GAP
		board_origin = BOARD_ORIGIN
		_layout_control(selected_label, Vector2(34, 602), Vector2(260, 40), 14)
		_layout_control(status_label, Vector2(34, 648), Vector2(260, 48), 16)
		if selected_label != null:
			selected_label.visible = true
		if status_label != null:
			status_label.visible = true
		_layout_control(produce_button, Vector2(34, 340), Vector2(180, 40), 0)
		if produce_button != null:
			produce_button.visible = true
		_hide_desktop_side_panels(false)
	board_layer.position = board_origin
	block_layer.position = board_origin
	if drag_preview != null:
		drag_preview.custom_minimum_size = Vector2(cell_size, cell_size)
		drag_preview.size = Vector2(cell_size, cell_size)
	_refresh_board()
	_refresh_selection()
	_apply_ingame_reference_shell()

func _layout_control(control: Control, pos: Vector2, next_size: Vector2, font_size: int) -> void:
	if control == null:
		return
	control.position = pos
	control.size = next_size
	if font_size > 0 and control is Label:
		control.add_theme_font_size_override("font_size", font_size)

func _hide_desktop_side_panels(hidden: bool) -> void:
	var controls: Array = [
		character_title_label,
		character_image,
		character_image_status_label,
		character_meta_label,
		character_detail_label,
		character_mode_button,
		ui_layout_title_label,
		ui_layout_meta_label,
		ui_layout_preview,
	]
	for control in controls:
		if control != null:
			control.visible = not hidden
	for control in portrait_hidden_controls:
		if control != null:
			control.visible = not hidden

func _apply_ingame_reference_shell() -> void:
	if ingame_reference_shell == null:
		return
	var source := _ui_layout_source_by_name("UIInGame")
	ingame_reference_shell.call("set_source", source)
	ingame_reference_shell.call("set_wallet", board.wallet)
	ingame_reference_shell.call("set_selected_block", _selected_block_summary())
	_apply_inventory_popup()
	_apply_request_detail_popup()

func _set_runtime_canvas_bootstrap_state(progress: float, message: String) -> void:
	if runtime_canvas_bootstrap_screen == null:
		return
	runtime_canvas_bootstrap_screen.call("set_loading_state", progress, message)

func _set_boot_services_reference_state(progress: float, message: String) -> void:
	if boot_services_reference_screen == null:
		return
	boot_services_reference_screen.call("set_loading_state", progress, message)

func _set_game_start_load_reference_state(progress: float, message: String) -> void:
	if game_start_load_reference_screen == null:
		return
	game_start_load_reference_screen.call("set_loading_state", progress, message)

func _set_reload_scene_reference_state(progress: float, message: String) -> void:
	if reload_scene_reference_screen == null:
		return
	reload_scene_reference_screen.call("set_loading_state", progress, message)

func _set_loading_reference_state(progress: float, message: String) -> void:
	if loading_reference_screen == null:
		return
	loading_reference_screen.call("set_loading_state", progress, message)

func _set_scene_loading_reference_state(progress: float, message: String) -> void:
	if scene_loading_reference_screen == null:
		return
	scene_loading_reference_screen.call("set_loading_state", progress, message)

func _set_maid_lobby_loading_reference_state(progress: float, message: String) -> void:
	if maid_lobby_loading_reference_screen == null:
		return
	maid_lobby_loading_reference_screen.call("set_loading_state", progress, message)

func _restored_boot_services_message(progress: float) -> String:
	if progress < 0.2:
		return "RuntimeInitializeOnLoad"
	if progress < 0.42:
		return "GameManager.OnGameStart"
	if progress < 0.62:
		return "Checking login and network..."
	if progress < 0.82:
		return "ReloadManager.LoadScene"
	return "Preparing UIManager..."

func _restored_game_start_load_message(progress: float) -> String:
	if progress < 0.16:
		return "GameManager.OnGameStartLoad"
	if progress < 0.32:
		return "InitCheck"
	if progress < 0.48:
		return "LoadABMode / LoadVersionData"
	if progress < 0.64:
		return "LoadTableData"
	if progress < 0.8:
		return "LoadProcess / CheckPlatformLogin"
	return "LoadComplete / LoadMenu"

func _restored_reload_scene_message(progress: float) -> String:
	if progress < 0.25:
		return "ReloadManager.LoadScene"
	if progress < 0.5:
		return "Loading Reload.unity canvas..."
	if progress < 0.75:
		return "Applying CanvasScaler and SafeArea..."
	return "Mounting UILoading..."

func _restored_ui_bootstrap_message(progress: float) -> String:
	if progress < 0.5:
		return "Initializing canvases..."
	if progress < 1.0:
		return "Applying safe area..."
	return "UI ready"

func _restored_app_loading_message(progress: float) -> String:
	if progress < 0.35:
		return "Loading assets..."
	if progress < 0.7:
		return "Preparing cafe..."
	if progress < 1.0:
		return "Opening..."
	return "Ready"

func _restored_scene_loading_message(progress: float) -> String:
	if progress < 0.45:
		return "Loading scene..."
	if progress < 0.85:
		return "Preparing UI..."
	return "Entering cafe..."

func _restored_maid_lobby_loading_message(progress: float) -> String:
	if progress < 0.45:
		return "Opening lobby..."
	if progress < 0.85:
		return "Preparing maids..."
	return "Entering out game..."

func _finish_restored_startup() -> void:
	restored_startup_finished = true
	boot_services_reference_visible = false
	game_start_load_reference_visible = false
	reload_scene_reference_visible = false
	runtime_canvas_bootstrap_visible = false
	loading_reference_visible = false
	scene_loading_reference_visible = false
	maid_lobby_loading_reference_visible = false
	_apply_boot_services_reference_visibility()
	_apply_game_start_load_reference_visibility()
	_apply_reload_scene_reference_visibility()
	_apply_runtime_canvas_bootstrap_visibility()
	_apply_loading_reference_visibility()
	_apply_scene_loading_reference_visibility()
	_apply_maid_lobby_loading_reference_visibility()
	maid_lobby_reference_visible = false
	_apply_maid_lobby_reference_visibility()
	_set_gameplay_visible(false)
	_show_out_game_reference()
	_set_status("Restored startup complete.")

func _maybe_capture_startup_frame(label: String, threshold_seconds: float) -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has(label):
		return
	if restored_startup_elapsed < threshold_seconds:
		return
	startup_capture_flags[label] = true
	call_deferred("_capture_startup_frame", label)

func _maybe_capture_ingame_frame() -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has("10-ingame"):
		return
	startup_capture_flags["10-ingame"] = true
	call_deferred("_capture_startup_frame", "10-ingame")

func _maybe_capture_inventory_frame() -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has("11-inventory"):
		return
	startup_capture_flags["11-inventory"] = true
	call_deferred("_capture_startup_frame", "11-inventory")

func _maybe_capture_maid_lobby_frame() -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has("10-maidlobby"):
		return
	startup_capture_flags["10-maidlobby"] = true
	call_deferred("_capture_startup_frame", "10-maidlobby")

func _maybe_capture_maid_lobby_select_frame() -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has("11-maidlobbyselect"):
		return
	startup_capture_flags["11-maidlobbyselect"] = true
	call_deferred("_capture_startup_frame", "11-maidlobbyselect")

func _maybe_capture_maid_dialog_frame() -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has("12-maiddialog"):
		return
	startup_capture_flags["12-maiddialog"] = true
	call_deferred("_capture_startup_frame", "12-maiddialog")

func _maybe_capture_named_frame(label: String) -> void:
	if startup_capture_dir.is_empty() or startup_capture_flags.has(label):
		return
	startup_capture_flags[label] = true
	call_deferred("_capture_startup_frame", label)

func _capture_startup_frame(label: String) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(startup_capture_dir)
	var image := get_viewport().get_texture().get_image()
	var output_path := startup_capture_dir.path_join(label + ".png")
	var error := image.save_png(output_path)
	if error == OK:
		print("startup_capture=", output_path)
	else:
		push_warning("Failed to save startup capture %s: %s" % [output_path, error])

func _ui_layout_source_by_name(source_name: String) -> Dictionary:
	for source in ui_layout_sources:
		if String(source.get("name", "")) == source_name:
			return source
	return {}

func _describe_ui_layout_source(source: Dictionary) -> String:
	var resolution: Dictionary = source.get("reference_resolution", {})
	var rects: Array = source.get("key_rects", [])
	var lines := [
		"%s: %s RectTransforms" % [source.get("name", "UI"), source.get("rect_transform_count", 0)],
		"Reference %sx%s" % [resolution.get("width", "?"), resolution.get("height", "?")]
	]
	for index in range(mini(3, rects.size())):
		var rect: Dictionary = rects[index]
		var size: Dictionary = rect.get("size_delta", {})
		lines.append("%s %sx%s" % [
			String(rect.get("node_path", "")).get_file(),
			size.get("x", 0),
			size.get("y", 0)
		])
	return "\n".join(lines)

func _toggle_character_mode() -> void:
	character_mode = "customers" if character_mode == "maids" else "maids"
	character_index = 0
	_refresh_character_panel()

func _step_character(delta: int) -> void:
	var entries := _current_character_entries()
	if entries.is_empty():
		return
	character_index = posmod(character_index + delta, entries.size())
	_refresh_character_panel()

func _current_character_entries() -> Array:
	return customers if character_mode == "customers" else maids

func _current_maid_entry() -> Dictionary:
	if maids.is_empty():
		return {}
	character_index = clampi(character_index, 0, maids.size() - 1)
	return maids[character_index]

func _current_maid_dialogs() -> Array:
	var maid := _current_maid_entry()
	if maid.is_empty():
		return []
	var npc_id := int(maid.get("maid_id", 0))
	var candidates: Array = []
	for dialog in dialogs:
		if typeof(dialog) != TYPE_DICTIONARY:
			continue
		if int(dialog.get("npc_id", -1)) != npc_id:
			continue
		var text: Dictionary = dialog.get("text", {})
		if String(text.get("eng", "")).is_empty():
			continue
		candidates.append(dialog)
		if candidates.size() >= 6:
			break
	return candidates

func _refresh_character_panel() -> void:
	if character_title_label == null:
		return
	var entries := _current_character_entries()
	character_mode_button.text = "Customers" if character_mode == "customers" else "Maids"
	if entries.is_empty():
		character_title_label.text = "No data"
		character_meta_label.text = ""
		character_detail_label.text = ""
		character_image.texture = null
		return
	character_index = clampi(character_index, 0, entries.size() - 1)
	var entry: Dictionary = entries[character_index]
	if character_mode == "customers":
		_refresh_customer_profile(entry)
	else:
		_refresh_maid_profile(entry)

func _refresh_maid_profile(entry: Dictionary) -> void:
	var npc := _first_npc_record(entry)
	var profile: Dictionary = entry.get("profile", {})
	var preview: Dictionary = npc.get("preview", {})
	character_title_label.text = "%s  %s/%s" % [
		npc.get("name", "Maid"),
		character_index + 1,
		maids.size()
	]
	character_meta_label.text = "ID %s\n%s\n%s | %s" % [
		entry.get("maid_id", ""),
		profile.get("member", ""),
		profile.get("tribe", ""),
		profile.get("height", "")
	]
	var skill_summary := "Skill %s" % entry.get("skill_id", "")
	var skills: Array = entry.get("skills", [])
	if not skills.is_empty():
		var first_skill: Dictionary = skills[0]
		skill_summary += "\nTarget: %s\nValue L1: %s" % [
			first_skill.get("target_id", ""),
			first_skill.get("value", "")
		]
	character_detail_label.text = "%s\nFavorite: %s\nHate: %s" % [
		skill_summary,
		profile.get("favorite", ""),
		profile.get("hate", "")
	]
	_set_character_preview(preview)

func _refresh_customer_profile(entry: Dictionary) -> void:
	var preview: Dictionary = entry.get("preview", {})
	character_title_label.text = "%s  %s/%s" % [
		entry.get("name", "Customer"),
		character_index + 1,
		customers.size()
	]
	var unlock: Dictionary = entry.get("unlock", {})
	character_meta_label.text = "ID %s\nSkin %s\nColor %s" % [
		entry.get("npc_id", ""),
		entry.get("skin_id", ""),
		entry.get("personal_color", "")
	]
	character_detail_label.text = "Unlock quest: %s\nFurniture: %s\nType: %s\nAsset: %s" % [
		unlock.get("quest_id", 0),
		unlock.get("furniture_id", 0),
		entry.get("npc_type", 0),
		_preview_label(preview)
	]
	_set_character_preview(preview)

func _first_npc_record(entry: Dictionary) -> Dictionary:
	var records: Array = entry.get("npc_records", [])
	if records.is_empty():
		return {}
	return records[0]

func _set_character_preview(preview: Dictionary) -> void:
	var kind := String(preview.get("kind", "missing"))
	var path := String(preview.get("path", ""))
	if kind == "static_png_only" and not path.is_empty():
		character_image.texture = load(path)
		character_image_status_label.text = ""
		return
	character_image.texture = null
	if kind.begins_with("spine_atlas_page"):
		character_image_status_label.text = "Spine atlas page\n%s regions\n%s" % [
			preview.get("region_count", 0),
			"skel present" if bool(preview.get("has_skel", false)) else "skel missing"
		]
	elif kind == "missing":
		character_image_status_label.text = "No preview asset"
	else:
		character_image_status_label.text = kind

func _preview_label(preview: Dictionary) -> String:
	var kind := String(preview.get("kind", "missing"))
	if kind == "static_png_only":
		return "static PNG"
	if kind.begins_with("spine_atlas_page"):
		return "Spine atlas (%s regions)" % preview.get("region_count", 0)
	return kind

func _refresh_wallet() -> void:
	if ap_label == null:
		return
	ap_label.text = str(board.wallet.get("ap", 0))
	gold_label.text = str(board.wallet.get("gold", 0))
	jewel_label.text = str(board.wallet.get("jewel", 0))
	if ingame_reference_shell != null:
		ingame_reference_shell.call("set_wallet", board.wallet)
	if out_game_reference_screen != null:
		out_game_reference_screen.call("set_wallet", board.wallet)

func _refresh_board() -> void:
	if board_layer == null:
		return
	for child in board_layer.get_children():
		child.queue_free()
	for child in block_layer.get_children():
		child.queue_free()
	cell_nodes.clear()
	block_nodes.clear()
	for y in range(board.height):
		for x in range(board.width):
			_draw_cell(x, y)
			var block_id: String = board.get_block(x, y)
			if not block_id.is_empty():
				_draw_block(x, y, block_id)

func _draw_cell(x: int, y: int) -> void:
	var cell := TextureRect.new()
	cell.position = _cell_pos(x, y)
	cell.size = Vector2(cell_size, cell_size)
	cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cell.stretch_mode = TextureRect.STRETCH_SCALE
	cell.texture = load(SPRITE_DIR + ("BlockLock.png" if board.is_locked(x, y) else "Board01.png"))
	board_layer.add_child(cell)
	cell_nodes[_key(x, y)] = cell

func _draw_block(x: int, y: int, block_id: String) -> void:
	var data: Dictionary = catalog.get_block(block_id)
	var button := TextureButton.new()
	button.position = _cell_pos(x, y) + Vector2(5, 5)
	button.size = Vector2(cell_size - 10, cell_size - 10)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = load(data.get("sprite", SPRITE_DIR + "Block_Unknown.png"))
	button.texture_hover = button.texture_normal
	button.texture_pressed = button.texture_normal
	button.gui_input.connect(_on_block_input.bind(Vector2i(x, y), block_id))
	block_layer.add_child(button)
	block_nodes[_key(x, y)] = button

	var level := Label.new()
	level.text = str(data.get("level", "?"))
	level.position = button.position + Vector2(4, 2)
	level.add_theme_font_size_override("font_size", 16)
	level.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block_layer.add_child(level)

func _on_block_input(event: InputEvent, cell: Vector2i, block_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected_cell = cell
			_refresh_selection()
			dragging = true
			drag_from = cell
			drag_preview.texture = load(catalog.get_block(block_id).get("sprite", SPRITE_DIR + "Block_Unknown.png"))
			drag_preview.visible = true
			_update_drag_preview()
		else:
			_finish_drag()
	elif event is InputEventMouseMotion and dragging:
		_update_drag_preview()

func _input(event: InputEvent) -> void:
	if inventory_popup_visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_hide_inventory_popup()
		return
	if event is InputEventMouseMotion and dragging:
		_update_drag_preview()
	if event is InputEventMouseButton and not event.pressed and dragging:
		_finish_drag()

func _finish_drag() -> void:
	var target := _screen_to_cell(get_viewport().get_mouse_position())
	var moved: bool = board.try_move_or_merge(drag_from.x, drag_from.y, target.x, target.y)
	if moved:
		selected_cell = target
		_set_status("Moved or merged.")
	else:
		_set_status("Invalid move.")
	dragging = false
	drag_from = Vector2i(-1, -1)
	drag_preview.visible = false
	_refresh_selection()

func _produce_selected() -> void:
	if selected_cell.x < 0:
		_set_status("Select a producer block first.")
		return
	var source_id := board.get_block(selected_cell.x, selected_cell.y)
	var produced_id := board.produce_to_empty_cell(selected_cell.x, selected_cell.y)
	if produced_id.is_empty():
		var name: String = String(catalog.get_block(source_id).get("name", source_id))
		var remaining := board.get_cooldown_remaining(selected_cell.x, selected_cell.y)
		if remaining > 0:
			_set_status("%s is cooling down: %ss." % [name, remaining])
		elif int(board.wallet.get("ap", 0)) <= 0:
			_set_status("No AP.")
		elif board.get_remaining_produce_energy(selected_cell.x, selected_cell.y) <= 0:
			_set_status("%s has no produce energy." % name)
		else:
			_set_status("No available production rule or empty cell for %s." % name)
	else:
		var data: Dictionary = catalog.get_block(produced_id)
		_set_status("Produced %s." % data.get("name", produced_id))
	_refresh_selection()

func _refresh_selection() -> void:
	if selected_label == null:
		return
	var text := "Selected: none"
	var has_produce := false
	if selected_cell.x >= 0:
		var block_id := board.get_block(selected_cell.x, selected_cell.y)
		var data := catalog.get_block(block_id)
		if not block_id.is_empty():
			var rule := catalog.get_produce_rule(block_id)
			has_produce = not rule.is_empty()
			var cooldown := board.get_cooldown_remaining(selected_cell.x, selected_cell.y)
			var queued_drops := board.get_designed_drop_queue_count(selected_cell.x, selected_cell.y)
			var remaining_energy := board.get_remaining_produce_energy(selected_cell.x, selected_cell.y)
			var max_energy := catalog.get_produce_energy(block_id)
			text = "Selected: %s L%s\nID %s%s" % [
				data.get("name", block_id),
				data.get("level", "?"),
				block_id,
				" | Producer" if has_produce else ""
			]
			if has_produce:
				text += "\nAP cost: 1 | Energy: %s/%s" % [remaining_energy, max_energy]
			if queued_drops > 0:
				text += "\nDesigned queue: %s" % queued_drops
			if cooldown > 0:
				text += "\nCooldown: %ss" % cooldown
	selected_label.text = text
	if produce_button != null:
		produce_button.disabled = not has_produce or (
			selected_cell.x >= 0
			and (
				board.get_cooldown_remaining(selected_cell.x, selected_cell.y) > 0
				or board.get_remaining_produce_energy(selected_cell.x, selected_cell.y) <= 0
			)
		)
	if ingame_reference_shell != null:
		ingame_reference_shell.call("set_selected_block", _selected_block_summary())
	_apply_inventory_popup()
	_apply_request_detail_popup()

func _selected_block_summary() -> Dictionary:
	if selected_cell.x < 0:
		return {}
	var block_id := board.get_block(selected_cell.x, selected_cell.y)
	if block_id.is_empty():
		return {}
	var data := catalog.get_block(block_id)
	return {
		"id": block_id,
		"name": data.get("name", block_id),
		"level": data.get("level", "?"),
		"sprite": data.get("sprite", SPRITE_DIR + "Block_Unknown.png"),
		"has_produce": not catalog.get_produce_rule(block_id).is_empty(),
		"energy": board.get_remaining_produce_energy(selected_cell.x, selected_cell.y),
		"max_energy": catalog.get_produce_energy(block_id),
	}

func _board_block_summaries() -> Array:
	var summaries: Array = []
	for y in range(board.height):
		for x in range(board.width):
			var block_id := board.get_block(x, y)
			if block_id.is_empty():
				continue
			var data := catalog.get_block(block_id)
			summaries.append({
				"id": block_id,
				"name": data.get("name", block_id),
				"level": data.get("level", "?"),
				"sprite": data.get("sprite", SPRITE_DIR + "Block_Unknown.png"),
				"has_produce": not catalog.get_produce_rule(block_id).is_empty(),
				"energy": board.get_remaining_produce_energy(x, y),
				"max_energy": catalog.get_produce_energy(block_id),
				"cell": Vector2i(x, y),
			})
	return summaries

func _update_drag_preview() -> void:
	drag_preview.position = get_viewport().get_mouse_position() - Vector2(cell_size, cell_size) * 0.5

func _screen_to_cell(pos: Vector2) -> Vector2i:
	var local := pos - board_origin
	var pitch := cell_size + cell_gap
	return Vector2i(floori(local.x / pitch), floori(local.y / pitch))

func _cell_pos(x: int, y: int) -> Vector2:
	return Vector2(x * (cell_size + cell_gap), y * (cell_size + cell_gap))

func _key(x: int, y: int) -> String:
	return "%d,%d" % [x, y]

func _set_status(text: String) -> void:
	if status_label != null:
		status_label.text = text
