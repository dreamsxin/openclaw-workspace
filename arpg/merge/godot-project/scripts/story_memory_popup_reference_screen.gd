class_name StoryMemoryPopupReferenceScreen
extends Control

signal close_requested

const STORY_ICONS := [
	"res://assets/sprites/SubStory_MemoryBox.png",
	"res://assets/sprites/SubStory_Aiko1_1.png",
	"res://assets/sprites/SubStory_Kurone1_1.png",
	"res://assets/sprites/SubStory_School1_1.png",
]

var open := false
var texture_cache: Dictionary = {}

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	if open:
		queue_redraw()

func set_popup_open(next_open: bool) -> void:
	open = next_open
	visible = open
	mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not open:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var pos: Vector2 = event.position
		if _close_rect().has_point(pos) or not _panel_rect().has_point(pos):
			emit_signal("close_requested")
			accept_event()
			return
		accept_event()

func _draw() -> void:
	if not open:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5), true)
	var panel := _panel_rect()
	draw_rect(panel, Color(0.085, 0.075, 0.075, 0.98), true)
	draw_rect(panel, Color(0.9, 0.72, 0.45, 0.9), false, 2.0)
	_draw_header(panel)
	_draw_tabs(panel)
	_draw_story_cards(panel)
	_draw_close_button()

func _draw_header(panel: Rect2) -> void:
	var header := Rect2(panel.position, Vector2(panel.size.x, 62))
	draw_rect(header, Color(0.17, 0.12, 0.1, 0.98), true)
	draw_rect(Rect2(header.position + Vector2(0, header.size.y - 2), Vector2(header.size.x, 2)), Color(0.9, 0.72, 0.45, 0.74), true)
	draw_string(ThemeDB.fallback_font, header.position + Vector2(22, 39), "Story / Memory", HORIZONTAL_ALIGNMENT_LEFT, header.size.x - 90, 23, Color(1, 0.92, 0.72, 0.96))

func _draw_tabs(panel: Rect2) -> void:
	var tabs := ["Story", "Memory", "Echo"]
	var tab_y := panel.position.y + 78
	var tab_w := (panel.size.x - 48) / float(tabs.size())
	for index in range(tabs.size()):
		var rect := Rect2(panel.position + Vector2(24 + float(index) * tab_w, 78), Vector2(tab_w - 6, 34))
		var active := index == 0
		draw_rect(rect, Color(0.24, 0.16, 0.1, 0.96) if active else Color(0.12, 0.1, 0.09, 0.9), true)
		draw_rect(rect, Color(1.0, 0.78, 0.42, 0.86) if active else Color(0.58, 0.46, 0.3, 0.56), false, 1.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 23), tabs[index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color(1, 0.9, 0.72, 0.94))

func _draw_story_cards(panel: Rect2) -> void:
	var list := Rect2(panel.position + Vector2(24, 130), Vector2(panel.size.x - 48, panel.size.y - 164))
	draw_rect(list, Color(0.045, 0.04, 0.038, 0.88), true)
	draw_rect(list, Color(0.56, 0.44, 0.28, 0.4), false, 1.0)
	var cards := [
		{"title": "Memory Box", "detail": "CollectionSaveData / Echo archive"},
		{"title": "Aiko Sub Story", "detail": "SubStory_Aiko chain assets"},
		{"title": "Kurone Sub Story", "detail": "SubStory_Kurone chain assets"},
		{"title": "School Event", "detail": "UIEvent_SchoolUniform evidence"},
	]
	for index in range(cards.size()):
		_draw_card(list, index, cards[index])

func _draw_card(list: Rect2, index: int, card: Dictionary) -> void:
	var columns := 2
	var gap := 12.0
	var card_w := (list.size.x - 28 - gap) / float(columns)
	var card_h := 132.0
	var col := index % columns
	var row := index / columns
	var rect := Rect2(list.position + Vector2(14 + float(col) * (card_w + gap), 14 + float(row) * (card_h + gap)), Vector2(card_w, card_h))
	draw_rect(rect, Color(0.13, 0.1, 0.085, 0.94), true)
	draw_rect(rect, Color(0.64, 0.5, 0.32, 0.55), false, 1.0)
	var thumb := Rect2(rect.position + Vector2(10, 10), Vector2(rect.size.x - 20, 66))
	draw_rect(thumb, Color(0.05, 0.045, 0.04, 0.96), true)
	var texture := _texture_for(STORY_ICONS[index])
	if texture != null:
		draw_texture_rect(texture, thumb.grow(-4), false, Color(1, 1, 1, 0.94))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 96), String(card.get("title", "Story")), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 14, Color(1, 0.9, 0.72, 0.95))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 116), String(card.get("detail", "")), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 10, Color(0.82, 0.72, 0.58, 0.82))

func _draw_close_button() -> void:
	var close := _close_rect()
	draw_rect(close, Color(0.26, 0.12, 0.08, 0.96), true)
	draw_rect(close, Color(0.98, 0.72, 0.48, 0.86), false, 1.5)
	draw_string(ThemeDB.fallback_font, close.position + Vector2(0, 29), "X", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 20, Color(1, 0.92, 0.78, 0.96))

func _panel_rect() -> Rect2:
	var width := minf(size.x * 0.94, 520.0)
	var height := minf(size.y * 0.72, 680.0)
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - height) * 0.5), Vector2(width, height))

func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 52, 12), Vector2(38, 38))

func _texture_for(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not texture_cache.has(path):
		texture_cache[path] = load(path)
	return texture_cache[path]

