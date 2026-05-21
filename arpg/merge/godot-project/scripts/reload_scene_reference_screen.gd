class_name ReloadSceneReferenceScreen
extends Control

var progress := 0.0
var message := "ReloadManager.LoadScene"

var reload_steps := [
	{"name": "ReloadManager.LoadScene", "detail": "Start Reload scene coroutine"},
	{"name": "Assets/Scenes/Reload.unity", "detail": "Load scene asset"},
	{"name": "Canvas", "detail": "Screen-space camera canvas, sorting 0"},
	{"name": "CanvasScaler", "detail": "Attach scaler component"},
	{"name": "Canvas/SafeArea", "detail": "Apply full-screen safe area rect"},
	{"name": "Canvas/UILoading", "detail": "Create visible loading root, sorting 10"},
	{"name": "Btn_ContactUs / Ver", "detail": "Mount corner support/version controls"},
	{"name": "LoadingBar", "detail": "Prepare app loading progress UI"},
]

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
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.017, 0.019, 0.022, 0.98), true)
	var reference_size := Vector2(1080, 1920)
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	draw_rect(screen_rect, Color(0.065, 0.075, 0.085, 1.0), true)
	_draw_header(screen_rect)
	_draw_reload_stack(screen_rect)
	_draw_step_list(screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.58, 0.78, 0.96, 0.66), false, 2.0)

func _draw_header(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var title_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.1, screen_rect.size.y * 0.08),
		Vector2(screen_rect.size.x * 0.8, screen_rect.size.y * 0.1)
	)
	draw_rect(title_rect.grow(20.0), Color(0.02, 0.026, 0.032, 0.58), true)
	draw_string(font, title_rect.position + Vector2(0, 36), "Reload Scene", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 40, Color(0.9, 0.96, 1.0, 0.96))
	draw_string(font, title_rect.position + Vector2(0, 78), "Recovered Reload.unity mount order before UILoading is visible", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 19, Color(0.7, 0.82, 0.92, 0.88))

func _draw_reload_stack(screen_rect: Rect2) -> void:
	var stack_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.16, screen_rect.size.y * 0.23),
		Vector2(screen_rect.size.x * 0.68, screen_rect.size.y * 0.32)
	)
	draw_rect(stack_rect, Color(0.025, 0.032, 0.04, 0.72), true)
	draw_rect(stack_rect, Color(0.5, 0.72, 0.92, 0.42), false, 1.5)
	var canvas_rect := stack_rect.grow(-18.0)
	var safe_rect := canvas_rect.grow(-28.0)
	var loading_rect := safe_rect.grow(-44.0)
	var bar_rect := Rect2(
		loading_rect.position + Vector2(loading_rect.size.x * 0.18, loading_rect.size.y * 0.76),
		Vector2(loading_rect.size.x * 0.64, 14.0)
	)
	draw_rect(canvas_rect, Color(0.12, 0.2, 0.27, 0.42), true)
	draw_rect(canvas_rect, Color(0.54, 0.76, 0.96, 0.55), false, 1.4)
	draw_rect(safe_rect, Color(0.1, 0.16, 0.13, 0.42), true)
	draw_rect(safe_rect, Color(0.72, 0.9, 0.74, 0.58), false, 1.4)
	draw_rect(loading_rect, Color(0.22, 0.18, 0.12, 0.52), true)
	draw_rect(loading_rect, Color(0.98, 0.76, 0.45, 0.58), false, 1.4)
	draw_rect(bar_rect, Color(0.04, 0.048, 0.055, 0.92), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.5, 0.84, 0.96, 0.94), true)
	draw_rect(bar_rect, Color(0.95, 0.92, 0.7, 0.72), false, 1.0)
	var font := ThemeDB.fallback_font
	draw_string(font, canvas_rect.position + Vector2(14, 28), "Canvas", HORIZONTAL_ALIGNMENT_LEFT, canvas_rect.size.x - 28, 17, Color(0.86, 0.94, 1.0, 0.92))
	draw_string(font, safe_rect.position + Vector2(14, 28), "SafeArea", HORIZONTAL_ALIGNMENT_LEFT, safe_rect.size.x - 28, 17, Color(0.84, 0.96, 0.82, 0.92))
	draw_string(font, loading_rect.position + Vector2(14, 28), "UILoading", HORIZONTAL_ALIGNMENT_LEFT, loading_rect.size.x - 28, 17, Color(1.0, 0.9, 0.72, 0.92))
	draw_string(font, loading_rect.position + Vector2(16, loading_rect.size.y - 24), "Btn_ContactUs", HORIZONTAL_ALIGNMENT_LEFT, loading_rect.size.x * 0.35, 13, Color(1, 1, 1, 0.68))
	draw_string(font, loading_rect.position + Vector2(loading_rect.size.x * 0.55, loading_rect.size.y - 24), "Ver", HORIZONTAL_ALIGNMENT_RIGHT, loading_rect.size.x * 0.4, 13, Color(1, 1, 1, 0.68))

func _draw_step_list(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var list_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.13, screen_rect.size.y * 0.59),
		Vector2(screen_rect.size.x * 0.74, screen_rect.size.y * 0.22)
	)
	draw_rect(list_rect, Color(0.025, 0.03, 0.036, 0.66), true)
	draw_rect(list_rect, Color(0.42, 0.62, 0.82, 0.38), false, 1.2)
	var row_height := list_rect.size.y / reload_steps.size()
	var active_index := clampi(floori(progress * reload_steps.size()), 0, reload_steps.size() - 1)
	for index in reload_steps.size():
		var step: Dictionary = reload_steps[index]
		var row_rect := Rect2(Vector2(list_rect.position.x, list_rect.position.y + row_height * index), Vector2(list_rect.size.x, row_height))
		var completed := index < active_index or progress >= 0.99
		var active := index == active_index and not completed
		var marker_color := Color(0.48, 0.82, 0.96, 0.95) if completed else Color(0.9, 0.68, 0.38, 0.95) if active else Color(0.22, 0.25, 0.27, 0.95)
		if active:
			draw_rect(row_rect, Color(0.16, 0.18, 0.2, 0.36), true)
		draw_circle(Vector2(row_rect.position.x + 22, row_rect.position.y + row_height * 0.5), 7.0, marker_color)
		draw_string(font, row_rect.position + Vector2(42, row_height * 0.5 + 5), "%s - %s" % [step.get("name", ""), step.get("detail", "")], HORIZONTAL_ALIGNMENT_LEFT, row_rect.size.x - 54, 13, Color(0.9, 0.96, 1.0, 0.9))

func _draw_progress(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.2, screen_rect.size.y * 0.86),
		Vector2(screen_rect.size.x * 0.6, 16)
	)
	draw_rect(bar_rect, Color(0.024, 0.027, 0.032, 0.95), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.48, 0.8, 0.96, 0.94), true)
	draw_rect(bar_rect, Color(0.86, 0.94, 1.0, 0.72), false, 1.2)
	draw_string(font, bar_rect.position + Vector2(0, -28), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(0.92, 0.98, 1.0, 0.94))
