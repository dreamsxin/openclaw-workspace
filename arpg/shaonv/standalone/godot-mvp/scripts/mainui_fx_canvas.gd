extends Control

var fx_kind := "gal"
var time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat


func set_kind(next_kind: String) -> void:
	fx_kind = next_kind
	queue_redraw()


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	if fx_kind == "menu":
		_draw_menu_fx()
	else:
		_draw_gal_fx()


func _draw_gal_fx() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	var pulse := 0.5 + 0.5 * sin(time * 3.2)
	draw_circle(center, radius * (1.05 + pulse * 0.07), Color(0.22, 0.78, 1.0, 0.10 + pulse * 0.08))
	for index in range(5):
		var phase := time * (0.42 + 0.06 * float(index)) + float(index) * 1.13
		var ring_radius := radius * (0.82 + 0.09 * float(index))
		var color := Color(0.22, 0.82, 1.0, 0.25 - float(index) * 0.025)
		_draw_arc_segment(center, ring_radius, phase, phase + PI * 1.18, 3.0, color)
	for index in range(14):
		var angle := time * 1.7 + float(index) * TAU / 14.0
		var orbit := radius * (0.78 + 0.2 * sin(time * 0.9 + float(index)))
		var point := center + Vector2(cos(angle), sin(angle)) * orbit
		draw_circle(point, 1.8 + 1.2 * sin(time * 2.6 + float(index)), Color(0.76, 0.95, 1.0, 0.38))


func _draw_menu_fx() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.42
	var pulse := 0.5 + 0.5 * sin(time * 3.8)
	draw_circle(center, radius * (0.94 + pulse * 0.08), Color(1.0, 0.72, 0.22, 0.12 + pulse * 0.06))
	for index in range(3):
		var start := -time * (0.75 + float(index) * 0.15) + float(index) * 1.6
		_draw_arc_segment(center, radius * (0.72 + float(index) * 0.15), start, start + PI * 0.82, 2.6, Color(1.0, 0.84, 0.36, 0.24))


func _draw_arc_segment(center: Vector2, radius: float, start_angle: float, end_angle: float, width: float, color: Color) -> void:
	var points := PackedVector2Array()
	var steps := 24
	for index in range(steps + 1):
		var t := float(index) / float(steps)
		var angle := lerpf(start_angle, end_angle, t)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	if points.size() > 1:
		draw_polyline(points, color, width, true)
