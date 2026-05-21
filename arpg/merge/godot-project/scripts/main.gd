extends Control

const BlockCatalogScript := preload("res://scripts/models/block_catalog.gd")
const MergeBoardModelScript := preload("res://scripts/models/merge_board_model.gd")
const SaveManagerScript := preload("res://scripts/services/save_manager.gd")
const CELL_SIZE := 78
const CELL_GAP := 8
const BOARD_ORIGIN := Vector2(360, 92)
const SPRITE_DIR := "res://assets/sprites/"

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
var selected_cell := Vector2i(-1, -1)

func _ready() -> void:
	catalog.load_from_file("res://data/blocks.json")
	catalog.load_rules("res://data/block_rules.json")
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

	selected_label = Label.new()
	selected_label.position = Vector2(34, 558)
	selected_label.size = Vector2(260, 58)
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_label.add_theme_font_size_override("font_size", 14)
	add_child(selected_label)

	status_label = Label.new()
	status_label.text = "Ready."
	status_label.position = Vector2(34, 622)
	status_label.size = Vector2(260, 70)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	add_child(status_label)

	board_layer = Control.new()
	board_layer.position = BOARD_ORIGIN
	add_child(board_layer)

	block_layer = Control.new()
	block_layer.position = BOARD_ORIGIN
	add_child(block_layer)

	drag_preview = TextureRect.new()
	drag_preview.visible = false
	drag_preview.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(drag_preview)
	_refresh_selection()

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
			text = "Selected: %s L%s\nID %s%s" % [
				data.get("name", block_id),
				data.get("level", "?"),
				block_id,
				" | Producer" if has_produce else ""
			]
			if cooldown > 0:
				text += "\nCooldown: %ss" % cooldown
	selected_label.text = text
	if produce_button != null:
		produce_button.disabled = not has_produce or (selected_cell.x >= 0 and board.get_cooldown_remaining(selected_cell.x, selected_cell.y) > 0)

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
