class_name MergeBoardModel
extends RefCounted

signal board_changed
signal wallet_changed
signal cooldown_changed

var width: int = 0
var height: int = 0
var blocks: Dictionary = {}
var locked_cells: Dictionary = {}
var cooldown_until: Dictionary = {}
var wallet: Dictionary = {
	"ap": 0,
	"gold": 0,
	"jewel": 0
}
var catalog

func setup(block_catalog, initial_path: String) -> void:
	catalog = block_catalog
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(initial_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid board data: %s" % initial_path)
		return
	width = int(parsed.get("width", 7))
	height = int(parsed.get("height", 7))
	wallet = parsed.get("wallet", wallet).duplicate(true)
	blocks.clear()
	locked_cells.clear()
	cooldown_until.clear()
	for cell in parsed.get("locked_cells", []):
		locked_cells[_key(int(cell.x), int(cell.y))] = true
	for block in parsed.get("blocks", []):
		set_block(int(block.x), int(block.y), String(block.block_id), false)
	emit_signal("wallet_changed")
	emit_signal("board_changed")

func now_seconds() -> int:
	return int(Time.get_unix_time_from_system())

func _key(x: int, y: int) -> String:
	return "%d,%d" % [x, y]

func is_inside(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height

func is_locked(x: int, y: int) -> bool:
	return locked_cells.has(_key(x, y))

func get_block(x: int, y: int) -> String:
	return blocks.get(_key(x, y), "")

func set_block(x: int, y: int, block_id: String, notify := true) -> void:
	if not is_inside(x, y) or is_locked(x, y):
		return
	var key := _key(x, y)
	if block_id.is_empty():
		blocks.erase(key)
	else:
		blocks[key] = block_id
	if notify:
		emit_signal("board_changed")

func try_move_or_merge(from_x: int, from_y: int, to_x: int, to_y: int) -> bool:
	if not is_inside(to_x, to_y) or is_locked(to_x, to_y):
		return false
	if from_x == to_x and from_y == to_y:
		return false
	var from_id := get_block(from_x, from_y)
	if from_id.is_empty():
		return false
	var to_id := get_block(to_x, to_y)
	if to_id.is_empty():
		set_block(from_x, from_y, "", false)
		set_block(to_x, to_y, from_id, true)
		return true
	if catalog.can_merge(from_id, to_id):
		set_block(from_x, from_y, "", false)
		set_block(to_x, to_y, catalog.get_next(from_id), true)
		return true
	return false

func add_random_seed_block() -> bool:
	if int(wallet.get("ap", 0)) <= 0:
		return false
	var seed_block: String = catalog.get_seed_block()
	if seed_block.is_empty():
		return false
	for y in range(height):
		for x in range(width):
			if not is_locked(x, y) and get_block(x, y).is_empty():
				wallet["ap"] = int(wallet.get("ap", 0)) - 1
				set_block(x, y, seed_block, true)
				emit_signal("wallet_changed")
				return true
	return false

func produce_from_block(block_id: String) -> String:
	var rule: Dictionary = catalog.get_produce_rule(block_id)
	var designed_drops: Array = rule.get("designed_drops", [])
	if not designed_drops.is_empty():
		return String(designed_drops[0].get("block_id", ""))
	var drops: Array = rule.get("drops", [])
	if not drops.is_empty():
		return _pick_weighted_drop(drops)
	return ""

func _pick_weighted_drop(drops: Array) -> String:
	var total_weight := 0
	for drop in drops:
		total_weight += maxi(0, int(drop.get("weight", 0)))
	if total_weight <= 0:
		return String(drops[0].get("block_id", ""))
	var roll := randi_range(1, total_weight)
	var cursor := 0
	for drop in drops:
		cursor += maxi(0, int(drop.get("weight", 0)))
		if roll <= cursor:
			return String(drop.get("block_id", ""))
	return String(drops[0].get("block_id", ""))

func produce_to_empty_cell(from_x: int, from_y: int) -> String:
	var source_id := get_block(from_x, from_y)
	if source_id.is_empty():
		return ""
	var cell_key := _key(from_x, from_y)
	if get_cooldown_remaining(from_x, from_y) > 0:
		return ""
	if int(wallet.get("ap", 0)) <= 0:
		return ""
	var produced_id := produce_from_block(source_id)
	if produced_id.is_empty():
		return ""
	for y in range(height):
		for x in range(width):
			if not is_locked(x, y) and get_block(x, y).is_empty():
				wallet["ap"] = int(wallet.get("ap", 0)) - 1
				var cooldown_seconds: int = catalog.get_cooldown_seconds(source_id)
				if cooldown_seconds > 0:
					cooldown_until[cell_key] = now_seconds() + cooldown_seconds
				set_block(x, y, produced_id, true)
				emit_signal("wallet_changed")
				emit_signal("cooldown_changed")
				return produced_id
	return ""

func get_cooldown_remaining(x: int, y: int) -> int:
	var until := int(cooldown_until.get(_key(x, y), 0))
	return maxi(0, until - now_seconds())

func to_save_data() -> Dictionary:
	var block_list: Array = []
	for key in blocks.keys():
		var parts := String(key).split(",")
		block_list.append({
			"x": int(parts[0]),
			"y": int(parts[1]),
			"block_id": blocks[key]
		})
	var locked_list: Array = []
	for key in locked_cells.keys():
		var parts := String(key).split(",")
		locked_list.append({
			"x": int(parts[0]),
			"y": int(parts[1])
		})
	return {
		"width": width,
		"height": height,
		"wallet": wallet,
		"blocks": block_list,
		"locked_cells": locked_list,
		"cooldown_until": cooldown_until
	}

func load_save_data(data: Dictionary) -> void:
	width = int(data.get("width", width))
	height = int(data.get("height", height))
	wallet = data.get("wallet", wallet).duplicate(true)
	blocks.clear()
	locked_cells.clear()
	cooldown_until = data.get("cooldown_until", {}).duplicate(true)
	for cell in data.get("locked_cells", []):
		locked_cells[_key(int(cell.x), int(cell.y))] = true
	for block in data.get("blocks", []):
		set_block(int(block.x), int(block.y), String(block.block_id), false)
	emit_signal("wallet_changed")
	emit_signal("board_changed")
	emit_signal("cooldown_changed")
