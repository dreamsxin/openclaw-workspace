class_name GameStartLoadReferenceScreen
extends Control

var progress := 0.0
var message := "GameManager.OnGameStartLoad"

var load_steps := [
	{"name": "OnGameStartLoad", "detail": "Enter game startup load routine"},
	{"name": "InitCheck", "detail": "Gate init policy and first user flags"},
	{"name": "LoadABMode", "detail": "Resolve asset-bundle mode"},
	{"name": "LoadVersionData", "detail": "Read app and build version data"},
	{"name": "LoadTableData", "detail": "Load recovered table/config data"},
	{"name": "LoadProcess", "detail": "Run queued service/data loaders"},
	{"name": "CheckPlatformLogin", "detail": "Wait platform login callback"},
	{"name": "LoadComplete", "detail": "Mark readyLoadComplete"},
	{"name": "LoadMenu", "detail": "Transition toward Reload/UILoading"},
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
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.019, 0.022, 0.98), true)
	var reference_size := Vector2(1080, 1920)
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)
	draw_rect(screen_rect, Color(0.08, 0.078, 0.072, 1.0), true)
	_draw_header(screen_rect)
	_draw_pipeline(screen_rect)
	_draw_status_panel(screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.88, 0.72, 0.48, 0.68), false, 2.0)

func _draw_header(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var title_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.1, screen_rect.size.y * 0.09),
		Vector2(screen_rect.size.x * 0.8, screen_rect.size.y * 0.12)
	)
	draw_rect(title_rect.grow(22.0), Color(0.035, 0.032, 0.027, 0.58), true)
	draw_string(font, title_rect.position + Vector2(0, 38), "Game Start Load", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 42, Color(0.98, 0.95, 0.88, 0.96))
	draw_string(font, title_rect.position + Vector2(0, 84), "Recovered GameManager operation order before Reload scene", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 20, Color(0.84, 0.76, 0.62, 0.88))

func _draw_pipeline(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var list_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.1, screen_rect.size.y * 0.25),
		Vector2(screen_rect.size.x * 0.8, screen_rect.size.y * 0.45)
	)
	draw_rect(list_rect, Color(0.035, 0.032, 0.029, 0.7), true)
	draw_rect(list_rect, Color(0.82, 0.62, 0.35, 0.42), false, 1.5)
	var row_height := list_rect.size.y / load_steps.size()
	var active_index := clampi(floori(progress * load_steps.size()), 0, load_steps.size() - 1)
	for index in load_steps.size():
		var step: Dictionary = load_steps[index]
		var row_rect := Rect2(
			Vector2(list_rect.position.x, list_rect.position.y + row_height * index),
			Vector2(list_rect.size.x, row_height)
		)
		var completed := index < active_index or progress >= 0.99
		var active := index == active_index and not completed
		if active:
			draw_rect(row_rect, Color(0.28, 0.18, 0.08, 0.28), true)
		if index > 0:
			draw_line(Vector2(row_rect.position.x + 30, row_rect.position.y - row_height * 0.5), Vector2(row_rect.position.x + 30, row_rect.position.y + row_height * 0.5), Color(0.74, 0.58, 0.38, 0.34), 2.0)
		var badge_color := Color(0.86, 0.72, 0.42, 0.95) if completed else Color(0.95, 0.5, 0.28, 0.96) if active else Color(0.24, 0.24, 0.23, 0.95)
		draw_circle(Vector2(row_rect.position.x + 30, row_rect.position.y + row_height * 0.5), 11.0, badge_color)
		draw_string(font, row_rect.position + Vector2(54, 25), String(step.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, row_rect.size.x - 70, 19, Color(0.98, 0.94, 0.86, 0.95))
		draw_string(font, row_rect.position + Vector2(54, 47), String(step.get("detail", "")), HORIZONTAL_ALIGNMENT_LEFT, row_rect.size.x - 70, 14, Color(0.74, 0.68, 0.56, 0.86))

func _draw_status_panel(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var panel_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.16, screen_rect.size.y * 0.72),
		Vector2(screen_rect.size.x * 0.68, screen_rect.size.y * 0.08)
	)
	draw_rect(panel_rect, Color(0.02, 0.024, 0.024, 0.56), true)
	draw_rect(panel_rect, Color(0.68, 0.55, 0.36, 0.42), false, 1.2)
	draw_string(font, panel_rect.position + Vector2(20, 34), "flags: readyAnalytics / readyPlatformLogin / readyLoadComplete", HORIZONTAL_ALIGNMENT_LEFT, panel_rect.size.x - 40, 16, Color(0.9, 0.84, 0.72, 0.9))
	draw_string(font, panel_rect.position + Vector2(20, 66), "next: Reload scene Canvas/UILoading", HORIZONTAL_ALIGNMENT_LEFT, panel_rect.size.x - 40, 16, Color(0.9, 0.84, 0.72, 0.9))

func _draw_progress(screen_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.2, screen_rect.size.y * 0.84),
		Vector2(screen_rect.size.x * 0.6, 16)
	)
	draw_rect(bar_rect, Color(0.024, 0.024, 0.023, 0.95), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.9, 0.66, 0.36, 0.94), true)
	draw_rect(bar_rect, Color(1.0, 0.9, 0.66, 0.72), false, 1.2)
	draw_string(font, bar_rect.position + Vector2(0, -28), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(0.98, 0.94, 0.84, 0.94))
