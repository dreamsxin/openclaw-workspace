# UTF-8 source. Spine Animation Browser — full hero list from heroes_list.json
extends Node2D

var heroes: Array = []
var current_index := 0
var anim_index := 0
var anim_names: Array = []
var speed := 1.0
var info_label: Label
var anim_label: Label
var status_label: Label
var canvas: Control
var scroll: ScrollContainer

func _ready():
	position = Vector2.ZERO
	_load_heroes()
	_build_ui()
	if heroes.size() > 0:
		_select_hero(0)

func _load_heroes():
	var file = FileAccess.open("res://assets/spine/heroes_list.json", FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Array:
			heroes = parsed

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.09)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	# Left panel with scroll
	var panel = ColorRect.new()
	panel.color = Color(0.10, 0.08, 0.14, 0.95)
	panel.size = Vector2(200, 720)
	add_child(panel)

	var title = _lbl("%d 角色" % heroes.size(), 20, Vector2(0, 10), Vector2(200, 32), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(title)

	# Scrollable hero list
	scroll = ScrollContainer.new()
	scroll.position = Vector2(4, 46)
	scroll.size = Vector2(192, 666)
	scroll.name = "HeroScroll"
	add_child(scroll)

	var list = VBoxContainer.new()
	list.name = "HeroList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	for i in heroes.size():
		var h = heroes[i]
		var btn = Button.new()
		btn.text = "%s [%s]" % [h["name"], h["key"]]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 36)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_select_hero.bind(i))
		btn.name = "btn_%d" % i
		list.add_child(btn)

	# Info bar at bottom
	info_label = _lbl("", 18, Vector2(210, 598), Vector2(340, 26))
	add_child(info_label)
	anim_label = _lbl("", 15, Vector2(210, 632), Vector2(500, 22))
	add_child(anim_label)
	status_label = _lbl("", 14, Vector2(210, 662), Vector2(300, 20))
	add_child(status_label)

	# Controls
	_btn("◀◀", Vector2(720, 598), _clip_prev, 44, 32)
	_btn("▶/‖", Vector2(772, 598), _toggle_play, 56, 32)
	_btn("▶▶", Vector2(836, 598), _clip_next, 44, 32)
	_btn("−",  Vector2(890, 598), _speed_down, 40, 32)
	_btn("＋",  Vector2(936, 598), _speed_up, 40, 32)
	_btn("1x", Vector2(982, 598), _reset_speed, 40, 32)
	_btn("⇄",  Vector2(1028, 598), _flip, 44, 32)
	_btn("←",  Vector2(1080, 598), _prev_hero, 44, 32)
	_btn("→",  Vector2(1130, 598), _next_hero, 44, 32)

	# Preview area
	canvas = Control.new()
	canvas.position = Vector2(200, 0)
	canvas.size = Vector2(1080, 594)
	canvas.name = "Preview"
	add_child(canvas)

func _select_hero(index: int):
	current_index = index
	var hero = heroes[index]
	info_label.text = "%s [%s]  id=%d" % [hero["name"], hero["key"], hero["id"]]

	# Clear previous
	for child in canvas.get_children():
		child.queue_free()

	var baked_path = "res://assets/spine/%s/%s.baked.json" % [hero["key"], hero["key"]]
	var baked_disk = baked_path.replace("res://", "")
	if not FileAccess.file_exists(baked_disk):
		anim_label.text = "無 baked 動畫"
		status_label.text = "缺失"
		return

	# Get animation names
	var file = FileAccess.open(baked_disk, FileAccess.READ)
	anim_names.clear()
	if file:
		var data = JSON.parse_string(file.get_as_text())
		var clips: Dictionary = data.get("clips", {})
		for k in clips:
			if clips[k] is Dictionary and clips[k].get("frames", []).size() > 0:
				anim_names.append(k)
	if anim_names.size() == 0:
		anim_names = ["(empty)"]

	# Create baked canvas
	var BakedClass = load("res://scripts/spine_baked_preview_canvas.gd")
	var c = Control.new()
	c.set_script(BakedClass)
	c.position = Vector2(0, 0)
	c.size = Vector2(1080, 594)
	c.name = "Baked"
	c.set_baked_path(baked_path, anim_names[0])
	canvas.add_child(c)

	anim_index = 0
	speed = 1.0
	_update_labels()

func _clip_next():
	if anim_names.size() <= 1: return
	anim_index = (anim_index + 1) % anim_names.size()
	_apply_clip()
func _clip_prev():
	if anim_names.size() <= 1: return
	anim_index = (anim_index - 1 + anim_names.size()) % anim_names.size()
	_apply_clip()
func _apply_clip():
	var c = canvas.get_node_or_null("Baked") as Control
	if c and c.has_method("set_clip"):
		c.set_clip(anim_names[anim_index])
		c.set_playing(true)
	_update_labels()
func _toggle_play():
	var c = canvas.get_node_or_null("Baked") as Control
	if c and c.has_method("set_playing"):
		var p = c.get("playing")
		c.set_playing(not p)
func _speed_up(): speed = min(speed * 1.25, 4.0); _update_labels()
func _speed_down(): speed = max(speed / 1.25, 0.25); _update_labels()
func _reset_speed(): speed = 1.0; _update_labels()
func _flip():
	var c = canvas.get_node_or_null("Baked") as Control
	if c: c.scale.x *= -1.0
func _prev_hero():
	if heroes.size() == 0: return
	_select_hero((current_index - 1 + heroes.size()) % heroes.size())
func _next_hero():
	if heroes.size() == 0: return
	_select_hero((current_index + 1) % heroes.size())

func _update_labels():
	var hero = heroes[current_index] if current_index < heroes.size() else {"name":"?", "key":"?", "id":0}
	info_label.text = "%s [%s]  id=%d" % [hero["name"], hero["key"], hero["id"]]
	if anim_names.size() > 0:
		anim_label.text = "動畫 [%d/%d]: %s  @ %.1fx" % [anim_index + 1, anim_names.size(), anim_names[anim_index], speed]
	else:
		anim_label.text = "無動畫"
	status_label.text = "角色 %d/%d" % [current_index + 1, heroes.size()]

func _lbl(text: String, size: int, pos: Vector2, sz: Vector2, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l = Label.new()
	l.text = text; l.add_theme_font_size_override("font_size", size)
	l.horizontal_alignment = align; l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = pos; l.size = sz
	l.modulate = Color(0.90, 0.86, 0.80)
	return l

func _btn(text: String, pos: Vector2, cb: Callable, w: float, h: float):
	var b = Button.new(); b.text = text; b.position = pos; b.size = Vector2(w, h)
	b.pressed.connect(cb); add_child(b)
