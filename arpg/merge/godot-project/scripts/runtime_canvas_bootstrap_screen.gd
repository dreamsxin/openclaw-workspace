class_name RuntimeCanvasBootstrapScreen
extends Control

var progress := 0.0
var message := "Initializing UI..."

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func set_loading_state(next_progress: float, next_message: String) -> void:
	progress = clampf(next_progress, 0.0, 1.0)
	message = next_message
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.027, 0.03, 0.98), true)
	var reference_size := Vector2(1080, 1920)
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	draw_rect(screen_rect, Color(0.1, 0.13, 0.14, 1.0), true)
	_draw_canvas_stack(screen_rect)
	_draw_safe_area(screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.65, 0.82, 0.9, 0.68), false, 2.0)

func _draw_canvas_stack(screen_rect: Rect2) -> void:
	var bg_canvas := screen_rect.grow(-screen_rect.size.x * 0.055)
	var ui_canvas := screen_rect.grow(-screen_rect.size.x * 0.095)
	var touch_canvas := screen_rect.grow(-screen_rect.size.x * 0.135)
	draw_rect(bg_canvas, Color(0.26, 0.42, 0.44, 0.36), true)
	draw_rect(bg_canvas, Color(0.55, 0.86, 0.86, 0.44), false, 1.5)
	draw_rect(ui_canvas, Color(0.42, 0.3, 0.18, 0.24), true)
	draw_rect(ui_canvas, Color(0.94, 0.72, 0.45, 0.46), false, 1.5)
	draw_rect(touch_canvas, Color(0.52, 0.58, 0.66, 0.12), true)
	draw_rect(touch_canvas, Color(0.78, 0.88, 1.0, 0.38), false, 1.2)

func _draw_safe_area(screen_rect: Rect2) -> void:
	var safe_rect := screen_rect.grow(-screen_rect.size.x * 0.035)
	draw_rect(safe_rect, Color(0.04, 0.05, 0.055, 0.18), true)
	draw_rect(safe_rect, Color(0.9, 0.96, 0.82, 0.62), false, 2.0)
	var center := safe_rect.get_center()
	draw_line(Vector2(center.x, safe_rect.position.y), Vector2(center.x, safe_rect.end.y), Color(0.9, 0.96, 0.82, 0.18), 1.0)
	draw_line(Vector2(safe_rect.position.x, center.y), Vector2(safe_rect.end.x, center.y), Color(0.9, 0.96, 0.82, 0.18), 1.0)

func _draw_progress(screen_rect: Rect2) -> void:
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.2, screen_rect.size.y * 0.82),
		Vector2(screen_rect.size.x * 0.6, 16)
	)
	draw_rect(bar_rect, Color(0.04, 0.045, 0.05, 0.92), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.58, 0.82, 0.9, 0.92), true)
	draw_rect(bar_rect, Color(0.85, 0.95, 1.0, 0.72), false, 1.2)
	draw_string(ThemeDB.fallback_font, bar_rect.position + Vector2(0, -24), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(0.92, 0.98, 1.0, 0.92))
