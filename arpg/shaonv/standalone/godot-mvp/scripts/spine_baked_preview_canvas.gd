extends Control

var baked: Dictionary = {}
var textures: Dictionary = {}
var clip_name := ""
var time := 0.0
var playing := true
var load_error := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_baked_path(baked_path: String, preferred_clip := "") -> void:
	baked.clear()
	textures.clear()
	clip_name = preferred_clip
	time = 0.0
	load_error = ""

	if not FileAccess.file_exists(baked_path):
		load_error = "Missing baked file: %s" % baked_path
		queue_redraw()
		return
	var file := FileAccess.open(baked_path, FileAccess.READ)
	if file == null:
		load_error = "Cannot open baked file: %s" % baked_path
		queue_redraw()
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		load_error = "Invalid baked JSON: %s" % baked_path
		queue_redraw()
		return
	baked = parsed
	var pages: Dictionary = baked.get("character", {}).get("pages", {})
	for page_name in pages.keys():
		var texture := _load_png_source_texture(String(pages[page_name]))
		if texture != null:
			textures[String(page_name)] = texture
	if clip_name.is_empty():
		clip_name = String(baked.get("bake", {}).get("defaultClip", ""))
	var clips: Dictionary = baked.get("clips", {})
	if clip_name.is_empty() and not clips.is_empty():
		clip_name = String(clips.keys()[0])
	queue_redraw()

func set_clip(next_clip_name: String) -> void:
	if clip_name == next_clip_name:
		return
	clip_name = next_clip_name
	time = 0.0
	queue_redraw()

func set_playing(next_playing: bool) -> void:
	playing = next_playing

func _process(delta: float) -> void:
	if not visible or not playing:
		return
	time += delta
	queue_redraw()

func _draw() -> void:
	if not load_error.is_empty():
		_draw_center_text(load_error, Color(1.0, 0.62, 0.48, 0.95))
		return
	if baked.is_empty():
		return
	var clip := _active_clip()
	if clip.is_empty():
		_draw_center_text("No baked clip.", Color(1.0, 0.72, 0.56, 0.92))
		return
	_draw_baked_clip(clip, Rect2(Vector2.ZERO, size))

func _draw_center_text(text: String, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(0, size.y * 0.5), text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 18, color)

func _active_clip() -> Dictionary:
	var clips: Dictionary = baked.get("clips", {})
	if clips.has(clip_name):
		return clips.get(clip_name, {})
	if not clips.is_empty():
		clip_name = String(clips.keys()[0])
		return clips.get(clip_name, {})
	return {}

func _draw_baked_clip(clip: Dictionary, target: Rect2) -> void:
	var attachments: Array = clip.get("attachments", [])
	var frames: Array = clip.get("frames", [])
	var fps := float(clip.get("fps", baked.get("bake", {}).get("fps", 8.0)))
	var duration := float(clip.get("duration", frames.size() / maxf(fps, 1.0)))
	var frame_count := frames.size()
	if frame_count <= 0:
		return
	var clip_time := fposmod(time, maxf(duration, 1.0 / maxf(fps, 1.0)))
	var frame_index := int(floor(clip_time * fps)) % frame_count
	var frame: Dictionary = frames[frame_index]
	var bounds := _baked_animation_bounds(clip)
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var scale_factor := minf(target.size.x / bounds.size.x, target.size.y / bounds.size.y) * 0.94
	var center := target.position + target.size * 0.5

	var items: Array = frame.get("items", [])
	var drawn := 0
	for item in items:
		if typeof(item) != TYPE_ARRAY or item.size() < 2:
			continue
		var attachment_index := int(item[0])
		if attachment_index < 0 or attachment_index >= attachments.size():
			continue
		var attachment: Dictionary = attachments[attachment_index]
		drawn += _draw_attachment(attachment, item[1], bounds, center, scale_factor)
	if drawn == 0:
		_draw_center_text("Baked clip has no drawable triangles.", Color(1.0, 0.72, 0.56, 0.92))

func _baked_animation_bounds(clip: Dictionary) -> Rect2:
	var bounds: Dictionary = clip.get("bounds", {})
	if bounds.is_empty():
		return Rect2()
	var min_x := float(bounds.get("minX", 0.0))
	var max_y := float(bounds.get("maxY", 0.0))
	var width := float(bounds.get("width", 0.0))
	var height := float(bounds.get("height", 0.0))
	return Rect2(Vector2(min_x, -max_y), Vector2(width, height))

func _draw_attachment(attachment: Dictionary, vertices: Array, bounds: Rect2, center: Vector2, scale_factor: float) -> int:
	var page_name := String(attachment.get("page", ""))
	if not textures.has(page_name):
		return 0
	var uvs: Array = attachment.get("uvs", [])
	var triangles: Array = attachment.get("triangles", [])
	if vertices.size() < 6 or uvs.size() < 6 or triangles.size() < 3:
		return 0

	var points: Array[Vector2] = []
	var uv_points: Array[Vector2] = []
	var index := 0
	while index + 1 < vertices.size() and index + 1 < uvs.size():
		var spine_point := Vector2(float(vertices[index]), -float(vertices[index + 1]))
		var local := (spine_point - bounds.position - bounds.size * 0.5) * scale_factor
		points.append(center + local)
		uv_points.append(Vector2(float(uvs[index]), float(uvs[index + 1])))
		index += 2

	var drawn := 0
	var page_texture: Texture2D = textures[page_name]
	for tri_index in range(0, triangles.size(), 3):
		if tri_index + 2 >= triangles.size():
			break
		var a := int(triangles[tri_index])
		var b := int(triangles[tri_index + 1])
		var c := int(triangles[tri_index + 2])
		if a >= points.size() or b >= points.size() or c >= points.size():
			continue
		if _triangle_area(points[a], points[b], points[c]) < 0.01:
			continue
		draw_polygon(
			PackedVector2Array([points[a], points[b], points[c]]),
			PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE]),
			PackedVector2Array([uv_points[a], uv_points[b], uv_points[c]]),
			page_texture
		)
		drawn += 1
	return drawn

func _triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return abs((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) * 0.5

func _load_png_source_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)
