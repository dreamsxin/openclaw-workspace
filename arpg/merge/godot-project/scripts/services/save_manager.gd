class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://prototype-save.json"

func save_board(board) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write save: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(board.to_save_data(), "\t"))

func load_board(board) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	board.load_save_data(parsed)
	return true
