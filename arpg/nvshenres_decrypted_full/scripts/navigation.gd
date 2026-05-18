extends Node

var history: Array[String] = []
var cursor := -1
var navigating_history := false

func _ready() -> void:
	var scene := _current_scene_path()
	if scene != "":
		history = [scene]
		cursor = 0

func go(path: String) -> void:
	if path == "":
		return
	var current := _current_scene_path()
	if current != "":
		if cursor < 0:
			history = [current]
			cursor = 0
		elif cursor < history.size() and history[cursor] != current:
			history = history.slice(0, cursor + 1)
			history.append(current)
			cursor = history.size() - 1
	if cursor < history.size() - 1:
		history = history.slice(0, cursor + 1)
	history.append(path)
	cursor = history.size() - 1
	get_tree().change_scene_to_file(path)

func back() -> void:
	if not can_back():
		return
	cursor -= 1
	get_tree().change_scene_to_file(history[cursor])

func forward() -> void:
	if not can_forward():
		return
	cursor += 1
	get_tree().change_scene_to_file(history[cursor])

func can_back() -> bool:
	return cursor > 0 and cursor < history.size()

func can_forward() -> bool:
	return cursor >= 0 and cursor < history.size() - 1

func add_buttons(container: Container) -> void:
	var back_button := Button.new()
	back_button.text = "后退"
	back_button.disabled = not can_back()
	back_button.pressed.connect(back)
	container.add_child(back_button)

	var forward_button := Button.new()
	forward_button.text = "前进"
	forward_button.disabled = not can_forward()
	forward_button.pressed.connect(forward)
	container.add_child(forward_button)

func _current_scene_path() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path
