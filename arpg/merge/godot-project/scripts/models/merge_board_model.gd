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
var designed_drop_queues: Dictionary = {}
var produce_energy: Dictionary = {}
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
	designed_drop_queues.clear()
	produce_energy.clear()
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
		_move_cell_state(_key(from_x, from_y), _key(to_x, to_y))
		return true
	if catalog.can_merge(from_id, to_id):
		set_block(from_x, from_y, "", false)
		_clear_cell_state(_key(from_x, from_y))
		set_block(to_x, to_y, catalog.get_next(from_id), true)
		_clear_cell_state(_key(to_x, to_y))
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

func produce_from_block(block_id: String, cell_key := "") -> String:
	var rule: Dictionary = catalog.get_produce_rule(block_id)
	var designed_drops: Array = rule.get("designed_drops", [])
	if not designed_drops.is_empty():
		return _pop_designed_drop(cell_key, designed_drops)
	var drops: Array = rule.get("drops", [])
	if not drops.is_empty():
		return _pick_weighted_drop(drops)
	return ""

func _pop_designed_drop(cell_key: String, designed_drops: Array) -> String:
	if cell_key.is_empty():
		return _pick_designed_drop_without_state(designed_drops)
	var queue: Array = designed_drop_queues.get(cell_key, [])
	if queue.is_empty():
		queue = _build_designed_drop_queue(designed_drops)
	if queue.is_empty():
		return ""
	var block_id := String(queue.pop_front())
	designed_drop_queues[cell_key] = queue
	return block_id

func _pick_designed_drop_without_state(designed_drops: Array) -> String:
	var queue := _build_designed_drop_queue(designed_drops)
	if queue.is_empty():
		return ""
	return String(queue[0])

func _build_designed_drop_queue(designed_drops: Array) -> Array:
	var queue: Array = []
	for drop in designed_drops:
		var block_id := String(drop.get("block_id", ""))
		if block_id.is_empty():
			continue
		var min_count := maxi(0, int(drop.get("count_min", 0)))
		var max_count := maxi(min_count, int(drop.get("count_max", min_count)))
		var count := randi_range(min_count, max_count)
		for _index in range(count):
			queue.append(block_id)
	queue.shuffle()
	return queue

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
	var energy_cost := 1
	if _get_remaining_produce_energy(cell_key, source_id) < energy_cost:
		return ""
	var produced_id := produce_from_block(source_id, cell_key)
	if produced_id.is_empty():
		return ""
	for y in range(height):
		for x in range(width):
			if not is_locked(x, y) and get_block(x, y).is_empty():
				wallet["ap"] = int(wallet.get("ap", 0)) - 1
				consume_produce_energy(cell_key, source_id, energy_cost)
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

func get_designed_drop_queue_count(x: int, y: int) -> int:
	return designed_drop_queues.get(_key(x, y), []).size()

func get_remaining_produce_energy(x: int, y: int) -> int:
	var block_id := get_block(x, y)
	if block_id.is_empty():
		return 0
	return _get_remaining_produce_energy(_key(x, y), block_id)

func _get_remaining_produce_energy(cell_key: String, block_id: String) -> int:
	var default_energy: int = catalog.get_produce_energy(block_id)
	if default_energy <= 0:
		return 0
	if not produce_energy.has(cell_key):
		produce_energy[cell_key] = default_energy
	return int(produce_energy[cell_key])

func consume_produce_energy(cell_key: String, block_id: String, amount: int) -> void:
	var remaining := _get_remaining_produce_energy(cell_key, block_id)
	produce_energy[cell_key] = maxi(0, remaining - amount)

func _move_cell_state(from_key: String, to_key: String) -> void:
	if cooldown_until.has(from_key):
		cooldown_until[to_key] = cooldown_until[from_key]
		cooldown_until.erase(from_key)
	if designed_drop_queues.has(from_key):
		designed_drop_queues[to_key] = designed_drop_queues[from_key]
		designed_drop_queues.erase(from_key)
	if produce_energy.has(from_key):
		produce_energy[to_key] = produce_energy[from_key]
		produce_energy.erase(from_key)

func _clear_cell_state(cell_key: String) -> void:
	cooldown_until.erase(cell_key)
	designed_drop_queues.erase(cell_key)
	produce_energy.erase(cell_key)

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
		"cooldown_until": cooldown_until,
		"designed_drop_queues": designed_drop_queues,
		"produce_energy": produce_energy
	}

func load_save_data(data: Dictionary) -> void:
	width = int(data.get("width", width))
	height = int(data.get("height", height))
	wallet = data.get("wallet", wallet).duplicate(true)
	blocks.clear()
	locked_cells.clear()
	cooldown_until = data.get("cooldown_until", {}).duplicate(true)
	designed_drop_queues = data.get("designed_drop_queues", {}).duplicate(true)
	produce_energy = data.get("produce_energy", {}).duplicate(true)
	for cell in data.get("locked_cells", []):
		locked_cells[_key(int(cell.x), int(cell.y))] = true
	for block in data.get("blocks", []):
		set_block(int(block.x), int(block.y), String(block.block_id), false)
	emit_signal("wallet_changed")
	emit_signal("board_changed")
	emit_signal("cooldown_changed")
