extends Control

const BlockCatalogScript := preload("res://scripts/models/block_catalog.gd")
const MergeBoardModelScript := preload("res://scripts/models/merge_board_model.gd")
const SaveManagerScript := preload("res://scripts/services/save_manager.gd")
const LoadingReferenceScreenScript := preload("res://scripts/loading_reference_screen.gd")
const UILayoutReferencePreviewScript := preload("res://scripts/ui_layout_reference_preview.gd")
const CELL_SIZE := 78
const CELL_GAP := 8
const BOARD_ORIGIN := Vector2(360, 92)
const SPRITE_DIR := "res://assets/sprites/"
const CHARACTER_DIR := "res://data/characters/"
const UI_LAYOUT_REFERENCE := "res://data/ui_layout_reference.json"

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
var character_mode := "maids"
var character_index := 0
var ui_layout_sources: Array = []
var ui_layout_index := 0
var ui_layout_title_label: Label
var ui_layout_meta_label: Label
var ui_layout_preview: Control
var loading_reference_screen: Control
var loading_reference_visible := false

func _ready() -> void:
	catalog.load_from_file("res://data/blocks.json")
	catalog.load_rules("res://data/block_rules.json")
	_load_character_data()
	_load_ui_layout_reference()
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

	var title := Label.new()
	title.text = "MergeMaidCafe Godot Prototype"
	title.position = Vector2(32, 24)
	title.add_theme_font_size_override("font_size", 30)
	add_child(title)

	var info := Label.new()
	info.text = "Drag matching blocks to merge. Spawn consumes AP. Save uses user://prototype-save.json."
	info.position = Vector2(34, 62)
	info.add_theme_font_size_override("font_size", 15)
	add_child(info)

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
	add_child(spawn_button)

	produce_button = _make_button("Produce", Vector2(34, 340))
	produce_button.pressed.connect(func() -> void:
		_produce_selected()
	)
	add_child(produce_button)

	var save_button := _make_button("Save", Vector2(34, 394))
	save_button.pressed.connect(func() -> void:
		save_manager.call("save_board", board)
		_set_status("Saved.")
	)
	add_child(save_button)

	var load_button := _make_button("Load", Vector2(34, 448))
	load_button.pressed.connect(func() -> void:
		if save_manager.call("load_board", board):
			_set_status("Loaded.")
		else:
			_set_status("No save file yet.")
	)
	add_child(load_button)

	var reset_button := _make_button("Reset", Vector2(34, 502))
	reset_button.pressed.connect(func() -> void:
		board.call("setup", catalog, "res://data/initial_board.json")
		selected_cell = Vector2i(-1, -1)
		_refresh_selection()
		_set_status("Reset to initial board.")
	)
	add_child(reset_button)

	var loading_button := _make_button("Loading Ref", Vector2(34, 556))
	loading_button.pressed.connect(func() -> void:
		_toggle_loading_reference()
	)
	add_child(loading_button)

	selected_label = Label.new()
	selected_label.position = Vector2(34, 602)
	selected_label.size = Vector2(260, 40)
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_label.add_theme_font_size_override("font_size", 14)
	add_child(selected_label)

	status_label = Label.new()
	status_label.text = "Ready."
	status_label.position = Vector2(34, 648)
	status_label.size = Vector2(260, 48)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	add_child(status_label)

	board_layer = Control.new()
	board_layer.position = BOARD_ORIGIN
	add_child(board_layer)

	block_layer = Control.new()
	block_layer.position = BOARD_ORIGIN
	add_child(block_layer)

	_build_character_panel()
	_build_ui_layout_panel()
	_build_loading_reference_screen()

	drag_preview = TextureRect.new()
	drag_preview.visible = false
	drag_preview.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(drag_preview)
	_refresh_selection()
	_refresh_character_panel()
	_refresh_ui_layout_panel(false)

func _build_character_panel() -> void:
	var title := Label.new()
	title.text = "Character"
	title.position = Vector2(995, 92)
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)

	character_mode_button = _make_button("Maids", Vector2(995, 132))
	character_mode_button.size = Vector2(122, 36)
	character_mode_button.pressed.connect(func() -> void:
		_toggle_character_mode()
	)
	add_child(character_mode_button)

	var prev_button := _make_button("<", Vector2(1126, 132))
	prev_button.size = Vector2(48, 36)
	prev_button.pressed.connect(func() -> void:
		_step_character(-1)
	)
	add_child(prev_button)

	var next_button := _make_button(">", Vector2(1184, 132))
	next_button.size = Vector2(48, 36)
	next_button.pressed.connect(func() -> void:
		_step_character(1)
	)
	add_child(next_button)

	character_image = TextureRect.new()
	character_image.position = Vector2(1010, 182)
	character_image.size = Vector2(210, 210)
	character_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(character_image)

	character_image_status_label = Label.new()
	character_image_status_label.position = Vector2(1010, 270)
	character_image_status_label.size = Vector2(210, 86)
	character_image_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_image_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	character_image_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_image_status_label.add_theme_font_size_override("font_size", 14)
	add_child(character_image_status_label)

	character_title_label = Label.new()
	character_title_label.position = Vector2(995, 406)
	character_title_label.size = Vector2(240, 32)
	character_title_label.add_theme_font_size_override("font_size", 20)
	add_child(character_title_label)

	character_meta_label = Label.new()
	character_meta_label.position = Vector2(995, 442)
	character_meta_label.size = Vector2(240, 88)
	character_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_meta_label.add_theme_font_size_override("font_size", 14)
	add_child(character_meta_label)

	character_detail_label = Label.new()
	character_detail_label.position = Vector2(995, 536)
	character_detail_label.size = Vector2(240, 132)
	character_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_detail_label.add_theme_font_size_override("font_size", 14)
	add_child(character_detail_label)

func _build_ui_layout_panel() -> void:
	ui_layout_title_label = Label.new()
	ui_layout_title_label.text = "UI Ref"
	ui_layout_title_label.position = Vector2(995, 24)
	ui_layout_title_label.add_theme_font_size_override("font_size", 18)
	add_child(ui_layout_title_label)

	var next_button := _make_button("Next UI", Vector2(995, 52))
	next_button.size = Vector2(104, 32)
	next_button.pressed.connect(func() -> void:
		if ui_layout_sources.is_empty():
			_set_status("No UI layout reference data.")
			return
		ui_layout_index = posmod(ui_layout_index + 1, ui_layout_sources.size())
		_refresh_ui_layout_panel(true)
	)
	add_child(next_button)

	ui_layout_meta_label = Label.new()
	ui_layout_meta_label.position = Vector2(1108, 52)
	ui_layout_meta_label.size = Vector2(132, 34)
	ui_layout_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_layout_meta_label.add_theme_font_size_override("font_size", 12)
	add_child(ui_layout_meta_label)

	ui_layout_preview = UILayoutReferencePreviewScript.new()
	ui_layout_preview.position = Vector2(742, 92)
	ui_layout_preview.size = Vector2(230, 408)
	ui_layout_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_layout_preview)

func _build_loading_reference_screen() -> void:
	loading_reference_screen = LoadingReferenceScreenScript.new()
	loading_reference_screen.position = Vector2(320, 24)
	loading_reference_screen.size = Vector2(650, 672)
	loading_reference_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_reference_screen.visible = false
	add_child(loading_reference_screen)

func _make_currency_label(icon_name: String, pos: Vector2) -> Label:
	var icon := TextureRect.new()
	icon.texture = load(SPRITE_DIR + icon_name)
	icon.position = pos
	icon.custom_minimum_size = Vector2(34, 34)
	icon.size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(icon)

	var label := Label.new()
	label.position = pos + Vector2(44, 5)
	label.add_theme_font_size_override("font_size", 21)
	add_child(label)
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

func _load_ui_layout_reference() -> void:
	var text := FileAccess.get_file_as_string(UI_LAYOUT_REFERENCE)
	var payload = JSON.parse_string(text)
	if typeof(payload) == TYPE_DICTIONARY:
		ui_layout_sources = payload.get("sources", [])

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
	var loading_source := _ui_layout_source_by_name("UILoading")
	if loading_source.is_empty():
		_set_status("UILoading reference data is missing.")
		return
	loading_reference_visible = not loading_reference_visible
	loading_reference_screen.visible = loading_reference_visible
	loading_reference_screen.call("set_source", loading_source)
	_set_status("Loading reference %s." % ("shown" if loading_reference_visible else "hidden"))

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
	cell.size = Vector2(CELL_SIZE, CELL_SIZE)
	cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cell.stretch_mode = TextureRect.STRETCH_SCALE
	cell.texture = load(SPRITE_DIR + ("BlockLock.png" if board.is_locked(x, y) else "Board01.png"))
	board_layer.add_child(cell)
	cell_nodes[_key(x, y)] = cell

func _draw_block(x: int, y: int, block_id: String) -> void:
	var data: Dictionary = catalog.get_block(block_id)
	var button := TextureButton.new()
	button.position = _cell_pos(x, y) + Vector2(5, 5)
	button.size = Vector2(CELL_SIZE - 10, CELL_SIZE - 10)
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

func _update_drag_preview() -> void:
	drag_preview.position = get_viewport().get_mouse_position() - Vector2(CELL_SIZE, CELL_SIZE) * 0.5

func _screen_to_cell(pos: Vector2) -> Vector2i:
	var local := pos - BOARD_ORIGIN
	var pitch := CELL_SIZE + CELL_GAP
	return Vector2i(floori(local.x / pitch), floori(local.y / pitch))

func _cell_pos(x: int, y: int) -> Vector2:
	return Vector2(x * (CELL_SIZE + CELL_GAP), y * (CELL_SIZE + CELL_GAP))

func _key(x: int, y: int) -> String:
	return "%d,%d" % [x, y]

func _set_status(text: String) -> void:
	status_label.text = text
