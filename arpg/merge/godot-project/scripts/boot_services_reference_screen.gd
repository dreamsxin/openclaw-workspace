class_name BootServicesReferenceScreen
extends Control

var progress := 0.0
var message := "Starting services..."

var startup_steps := [
	{"name": "RuntimeInitializeOnLoad", "detail": "Game startup hooks"},
	{"name": "GameManager.OnGameStart", "detail": "Create startup state"},
	{"name": "HighscoreService.OnGameStart", "detail": "Register score service"},
	{"name": "GameManager.InitCheck", "detail": "Run init gates"},
	{"name": "PlatformLoginManager.CheckPlatformLogin", "detail": "Validate platform session"},
	{"name": "GameManager.CheckNetwork", "detail": "Verify network state"},
	{"name": "ReloadManager.LoadScene", "detail": "Load Reload scene"},
	{"name": "UIManager.Initialize", "detail": "Prepare runtime UI roots"},
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
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.019, 0.021, 0.98), true)
	var reference_size := Vector2(1080, 1920)
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	draw_rect(screen_rect, Color(0.075, 0.088, 0.085, 1.0), true)
	_draw_header(screen_rect)
	_draw_step_list(screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.68, 0.86, 0.78, 0.64), false, 2.0)

func _draw_header(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var title_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.1, screen_rect.size.y * 0.12),
		Vector2(screen_rect.size.x * 0.8, screen_rect.size.y * 0.12)
	)
	draw_rect(title_rect.grow(22.0), Color(0.02, 0.026, 0.026, 0.52), true)
	draw_string(font, title_rect.position + Vector2(0, 38), "Boot Services", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 42, Color(0.94, 0.98, 0.94, 0.96))
	draw_string(font, title_rect.position + Vector2(0, 84), "Recovered startup order before visible loading UI", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 21, Color(0.73, 0.84, 0.78, 0.88))

func _draw_step_list(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var list_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.12, screen_rect.size.y * 0.28),
		Vector2(screen_rect.size.x * 0.76, screen_rect.size.y * 0.42)
	)
	draw_rect(list_rect, Color(0.03, 0.036, 0.037, 0.66), true)
	draw_rect(list_rect, Color(0.5, 0.75, 0.62, 0.38), false, 1.5)
	var row_height := list_rect.size.y / startup_steps.size()
	var active_index := clampi(floori(progress * startup_steps.size()), 0, startup_steps.size() - 1)
	for index in startup_steps.size():
		var step: Dictionary = startup_steps[index]
		var row_y := list_rect.position.y + row_height * index
		var row_rect := Rect2(Vector2(list_rect.position.x, row_y), Vector2(list_rect.size.x, row_height))
		var completed := index < active_index or progress >= 0.99
		var active := index == active_index and not completed
		var badge_color := Color(0.42, 0.82, 0.6, 0.95) if completed else Color(0.88, 0.68, 0.38, 0.94) if active else Color(0.22, 0.26, 0.26, 0.95)
		if active:
			draw_rect(row_rect, Color(0.18, 0.15, 0.08, 0.28), true)
		draw_circle(Vector2(row_rect.position.x + 28, row_rect.position.y + row_height * 0.5), 12.0, badge_color)
		var badge := "OK" if completed else "RUN" if active else "--"
		draw_string(font, row_rect.position + Vector2(16, row_height * 0.5 + 6), badge, HORIZONTAL_ALIGNMENT_CENTER, 24, 12, Color(0.04, 0.05, 0.045, 0.92))
		draw_string(font, row_rect.position + Vector2(56, 27), String(step.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, row_rect.size.x - 70, 20, Color(0.94, 0.98, 0.94, 0.95))
		draw_string(font, row_rect.position + Vector2(56, 51), String(step.get("detail", "")), HORIZONTAL_ALIGNMENT_LEFT, row_rect.size.x - 70, 15, Color(0.64, 0.75, 0.68, 0.84))

func _draw_progress(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.2, screen_rect.size.y * 0.78),
		Vector2(screen_rect.size.x * 0.6, 16)
	)
	draw_rect(bar_rect, Color(0.025, 0.028, 0.028, 0.95), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.62, 0.86, 0.68, 0.94), true)
	draw_rect(bar_rect, Color(0.82, 0.96, 0.84, 0.72), false, 1.2)
	draw_string(font, bar_rect.position + Vector2(0, -28), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(0.92, 0.98, 0.92, 0.94))
