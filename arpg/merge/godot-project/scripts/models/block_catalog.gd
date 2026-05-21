class_name BlockCatalog
extends RefCounted

var blocks: Dictionary = {}
var chains: Dictionary = {}
var rules: Dictionary = {}
var seed_blocks: Array[String] = []

func load_from_file(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid block catalog: %s" % path)
		return
	chains = parsed.get("chains", {}).duplicate(true)
	blocks.clear()
	seed_blocks.clear()
	for chain_id in chains.keys():
		for block in chains[chain_id]:
			var copy: Dictionary = block.duplicate(true)
			copy["chain_id"] = chain_id
			blocks[copy["id"]] = copy
			if int(copy.get("level", 0)) == 1:
				seed_blocks.append(copy["id"])

func load_rules(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid block rules: %s" % path)
		return
	rules = parsed.duplicate(true)

func get_block(block_id: String) -> Dictionary:
	return blocks.get(block_id, {})

func get_next(block_id: String) -> String:
	return get_block(block_id).get("next", "")

func can_merge(left_id: String, right_id: String) -> bool:
	return left_id == right_id and get_next(left_id) != ""

func get_seed_block() -> String:
	if seed_blocks.is_empty():
		return ""
	return seed_blocks[0]

func get_produce_rule(block_id: String) -> Dictionary:
	return rules.get("produce_by_block", {}).get(block_id, {})

func get_cooldown_rules(group_name: String) -> Array:
	return rules.get("cooldown_by_group", {}).get(group_name, [])

func get_cooldown_seconds(block_id: String) -> int:
	var block: Dictionary = get_block(block_id)
	var chain_id := String(block.get("chain_id", ""))
	if chain_id.is_empty():
		return 0
	var cooldowns: Array = get_cooldown_rules(chain_id)
	if cooldowns.is_empty():
		return 0
	return int(cooldowns[0].get("cool_time_during", 0))
