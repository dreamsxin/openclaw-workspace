class_name SceneLoadingReferenceScreen
extends Control

const SPINE_ASSET_DIR := "res://assets/spine/loading/kokomi_Loading/"
const SPINE_ATLAS_PATH := SPINE_ASSET_DIR + "kokomi_Loading.atlas.txt"
const SPINE_RIG_PATH := SPINE_ASSET_DIR + "kokomi_Loading.rig.json"
const SPINE_PAGE_NAMES := ["kokomi_Loading_2.png", "kokomi_Loading.png"]

var source: Dictionary = {}
var progress := 0.0
var message := "Scene loading..."
var spine_time := 0.0
var spine_pages: Dictionary = {}
var spine_regions: Dictionary = {}
var spine_rig: Dictionary = {}
var spine_bones: Dictionary = {}
var spine_attachments: Array = []
var spine_draw_order: Array = []
var spine_assets_ready := false

func _ready() -> void:
	_load_spine_assets()
	set_process(true)

func _process(delta: float) -> void:
	if not visible:
		return
	spine_time += delta
	queue_redraw()

func set_source(next_source: Dictionary) -> void:
	source = next_source
	queue_redraw()

func set_loading_state(next_progress: float, next_message: String) -> void:
	progress = clampf(next_progress, 0.0, 1.0)
	message = next_message
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.035, 0.04, 0.96), true)
	if source.is_empty():
		return

	var reference_size := _reference_size()
	var scale_factor := minf(size.x / reference_size.x, size.y / reference_size.y)
	var viewport_size := reference_size * scale_factor
	var origin := (size - viewport_size) * 0.5
	var screen_rect := Rect2(origin, viewport_size)

	draw_rect(screen_rect, Color(0.1, 0.16, 0.18, 1.0), true)
	_draw_background(reference_size, scale_factor, origin)
	_draw_character(screen_rect)
	_draw_progress(screen_rect)
	draw_rect(screen_rect, Color(0.58, 0.78, 0.86, 0.85), false, 2.0)

func _draw_background(reference_size: Vector2, scale_factor: float, origin: Vector2) -> void:
	var normal_bg := _rect_by_suffix("SceneObjects/TypeNormal/BG")
	var christmas_bg := _rect_by_suffix("SceneObjects/TypeChristMas (1)/BG")
	for rect in [normal_bg, christmas_bg]:
		if rect.is_empty():
			continue
		var preview_rect := _to_preview_rect(rect, reference_size, scale_factor, origin)
		draw_rect(preview_rect, Color(0.2, 0.42, 0.48, 0.34), true)
		draw_rect(preview_rect, Color(0.78, 0.95, 1.0, 0.26), false, 1.0)

func _draw_character(screen_rect: Rect2) -> void:
	var target := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.12, screen_rect.size.y * 0.2),
		Vector2(screen_rect.size.x * 0.76, screen_rect.size.y * 0.58)
	)
	draw_rect(target, Color(0.12, 0.16, 0.18, 0.64), true)
	draw_rect(target, Color(0.7, 0.88, 0.94, 0.72), false, 2.0)
	if spine_assets_ready:
		_draw_spine_region_animation(target)
	else:
		_draw_spine_fallback(target)

func _draw_progress(screen_rect: Rect2) -> void:
	var bar_rect := Rect2(
		screen_rect.position + Vector2(screen_rect.size.x * 0.18, screen_rect.size.y * 0.82),
		Vector2(screen_rect.size.x * 0.64, 18)
	)
	draw_rect(bar_rect, Color(0.04, 0.06, 0.07, 0.94), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * progress, bar_rect.size.y)), Color(0.56, 0.88, 0.94, 0.92), true)
	draw_rect(bar_rect, Color(0.92, 0.96, 1.0, 0.8), false, 1.5)
	draw_string(ThemeDB.fallback_font, bar_rect.position + Vector2(0, -24), message, HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 18, Color(1, 1, 1, 0.92))

func _reference_size() -> Vector2:
	var resolution: Dictionary = source.get("reference_resolution", {})
	return Vector2(float(resolution.get("width", 1080)), float(resolution.get("height", 1920)))

func _rect_by_suffix(suffix: String) -> Dictionary:
	var rects: Array = source.get("key_rects", [])
	for rect in rects:
		if String(rect.get("node_path", "")).ends_with(suffix):
			return rect
	return {}

func _to_preview_rect(rect: Dictionary, reference_size: Vector2, scale_factor: float, origin: Vector2) -> Rect2:
	if rect.is_empty():
		return Rect2()
	var anchor_min := _vec2(rect.get("anchor_min", {}))
	var anchor_max := _vec2(rect.get("anchor_max", {}))
	var anchored_position := _vec2(rect.get("anchored_position", {}))
	var size_delta := _vec2(rect.get("size_delta", {}))
	var pivot := _vec2(rect.get("pivot", {"x": 0.5, "y": 0.5}))

	if anchor_min.distance_to(anchor_max) > 0.001:
		var top_left := Vector2(anchor_min.x * reference_size.x, (1.0 - anchor_max.y) * reference_size.y)
		var bottom_right := Vector2(anchor_max.x * reference_size.x, (1.0 - anchor_min.y) * reference_size.y)
		var stretch_size := bottom_right - top_left + Vector2(size_delta.x, -size_delta.y)
		return Rect2(origin + top_left * scale_factor, stretch_size.abs() * scale_factor)

	var center := Vector2(
		anchor_min.x * reference_size.x + anchored_position.x,
		(1.0 - anchor_min.y) * reference_size.y - anchored_position.y
	)
	var top_left := center - Vector2(size_delta.x * pivot.x, size_delta.y * (1.0 - pivot.y))
	return Rect2(origin + top_left * scale_factor, size_delta.abs() * scale_factor)

func _vec2(value) -> Vector2:
	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	if typeof(value) == TYPE_ARRAY:
		return Vector2(float(value[0]) if value.size() > 0 else 0.0, float(value[1]) if value.size() > 1 else 0.0)
	return Vector2.ZERO

func _load_spine_assets() -> void:
	spine_pages.clear()
	spine_regions.clear()
	spine_rig.clear()
	spine_bones.clear()
	spine_attachments.clear()
	spine_draw_order.clear()
	for page_name in SPINE_PAGE_NAMES:
		var texture := load(SPINE_ASSET_DIR + page_name)
		if texture != null:
			spine_pages[page_name] = texture
	if spine_pages.is_empty() or not FileAccess.file_exists(SPINE_ATLAS_PATH):
		spine_assets_ready = false
		return

	var current_page := ""
	var current_region := ""
	var atlas_text := FileAccess.get_file_as_string(SPINE_ATLAS_PATH)
	for raw_line in atlas_text.split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty():
			continue
		var separator := line.find(":")
		if separator == -1:
			if line.ends_with(".png"):
				current_page = line
				current_region = ""
			else:
				current_region = line
				spine_regions[current_region] = {
					"page": current_page,
					"bounds": Rect2(),
					"rotate": "",
				}
			continue
		if current_region.is_empty() or not spine_regions.has(current_region):
			continue
		var key := line.substr(0, separator).strip_edges()
		var value := line.substr(separator + 1).strip_edges()
		if key == "bounds":
			var numbers := _parse_atlas_numbers(value)
			if numbers.size() >= 4:
				var region: Dictionary = spine_regions[current_region]
				region["bounds"] = Rect2(numbers[0], numbers[1], numbers[2], numbers[3])
				spine_regions[current_region] = region
		elif key == "rotate":
			var region: Dictionary = spine_regions[current_region]
			region["rotate"] = value
			spine_regions[current_region] = region
	_load_spine_rig()
	spine_assets_ready = spine_regions.has("Head") and spine_regions.has("Cafe_Table") and not spine_attachments.is_empty()

func _load_spine_rig() -> void:
	if not FileAccess.file_exists(SPINE_RIG_PATH):
		return
	var file := FileAccess.open(SPINE_RIG_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	spine_rig = parsed
	var bones: Array = spine_rig.get("bones", [])
	for bone in bones:
		var bone_name := String(bone.get("name", ""))
		if bone_name.is_empty():
			continue
		spine_bones[bone_name] = bone
	spine_attachments = spine_rig.get("attachments", [])
	spine_draw_order = spine_rig.get("draw_order", [])

func _parse_atlas_numbers(value: String) -> Array[float]:
	var numbers: Array[float] = []
	for part in value.split(","):
		numbers.append(float(part.strip_edges()))
	return numbers

func _draw_spine_region_animation(target: Rect2) -> void:
	var rig_origin := target.position + Vector2(target.size.x * 0.5, target.size.y * 0.5)
	var scale_factor := minf(target.size.x / 1220.0, target.size.y / 1700.0)
	var pose := _evaluate_spine_pose()

	for attachment in spine_attachments:
		_draw_spine_attachment(attachment, target, rig_origin, scale_factor, pose)
	draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y - 28), "SkeletonGraphic (kokomi_Loading)", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 16, Color(0.9, 0.98, 1.0, 0.82))

func _draw_spine_attachment(attachment: Dictionary, target: Rect2, rig_origin: Vector2, scale_factor: float, pose: Dictionary) -> void:
	var region_name := String(attachment.get("region", ""))
	if not spine_regions.has(region_name):
		return
	var region: Dictionary = spine_regions[region_name]
	var page_name := String(region.get("page", ""))
	if not spine_pages.has(page_name):
		return
	var bounds: Rect2 = region.get("bounds", Rect2())
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return

	var src_size := bounds.size
	var rotated := String(region.get("rotate", "")) == "90"
	if rotated:
		src_size = Vector2(bounds.size.y, bounds.size.x)
	var dest := Rect2(_spine_attachment_position(attachment, src_size, rig_origin, scale_factor, pose), src_size * scale_factor)
	if region_name == "Background/Background":
		dest = target.grow(-8.0)
	if bool(pose.get("blink", false)) and region_name.begins_with("Eye_"):
		dest.size.y = maxf(dest.size.y * 0.22, 2.0)
		dest.position.y += bounds.size.y * scale_factor * 0.36

	draw_texture_rect_region(spine_pages[page_name], dest, bounds, Color(1, 1, 1, 0.98), rotated, true)

func _spine_attachment_position(attachment: Dictionary, src_size: Vector2, rig_origin: Vector2, scale_factor: float, pose: Dictionary) -> Vector2:
	var bone_name := String(attachment.get("bone", "root"))
	var bone_transform: Dictionary = pose.get("bones", {}).get(bone_name, {"position": Vector2.ZERO})
	var local_position := _vec2_array(attachment.get("position", [0, 0]))
	var atlas_position: Vector2 = bone_transform.get("position", Vector2.ZERO) + local_position
	return Vector2(
		(rig_origin.x + atlas_position.x * scale_factor) - src_size.x * scale_factor * 0.5,
		(rig_origin.y + atlas_position.y * scale_factor) - src_size.y * scale_factor * 0.5
	)

func _evaluate_spine_pose() -> Dictionary:
	var animation: Dictionary = spine_rig.get("animations", {}).get("loading_idle", {})
	var channels: Dictionary = animation.get("bone_channels", {})
	var global_bones: Dictionary = {}
	for bone_name in spine_bones.keys():
		_evaluate_bone_pose(String(bone_name), channels, global_bones)
	var blink_data: Dictionary = animation.get("blink", {})
	var blink_period := float(blink_data.get("period", 3.4))
	var blink_start := float(blink_data.get("start", 3.16))
	var blink_duration := float(blink_data.get("duration", 0.16))
	var blink_time := fposmod(spine_time, blink_period)
	return {
		"bones": global_bones,
		"blink": blink_time >= blink_start and blink_time <= blink_start + blink_duration,
	}

func _evaluate_bone_pose(bone_name: String, channels: Dictionary, global_bones: Dictionary) -> Dictionary:
	if global_bones.has(bone_name):
		return global_bones[bone_name]
	var bone: Dictionary = spine_bones.get(bone_name, {})
	var parent_name := String(bone.get("parent", ""))
	var parent_position := Vector2.ZERO
	if not parent_name.is_empty():
		parent_position = _evaluate_bone_pose(parent_name, channels, global_bones).get("position", Vector2.ZERO)
	var local_position := _vec2_array(bone.get("position", [0, 0]))
	var channel: Dictionary = channels.get(bone_name, {})
	var translate := _vec2_array(channel.get("translate", [0, 0]))
	var frequency := float(channel.get("frequency", 1.0))
	var phase := float(channel.get("phase", 0.0))
	var wave := sin(spine_time * frequency + phase)
	var result := {
		"position": parent_position + local_position + translate * wave,
	}
	global_bones[bone_name] = result
	return result

func _vec2_array(value) -> Vector2:
	if typeof(value) == TYPE_ARRAY:
		return Vector2(float(value[0]) if value.size() > 0 else 0.0, float(value[1]) if value.size() > 1 else 0.0)
	return Vector2.ZERO

func _draw_spine_fallback(target: Rect2) -> void:
	var center := target.position + target.size * 0.5
	draw_circle(center + Vector2(0, -target.size.y * 0.18), target.size.x * 0.09, Color(0.7, 0.88, 0.94, 0.42))
	draw_line(center + Vector2(0, -target.size.y * 0.08), center + Vector2(0, target.size.y * 0.2), Color(0.7, 0.88, 0.94, 0.72), 4.0)
	draw_line(center + Vector2(0, target.size.y * 0.02), center + Vector2(-target.size.x * 0.16, target.size.y * 0.12), Color(0.7, 0.88, 0.94, 0.72), 3.0)
	draw_line(center + Vector2(0, target.size.y * 0.02), center + Vector2(target.size.x * 0.16, target.size.y * 0.12), Color(0.7, 0.88, 0.94, 0.72), 3.0)
	draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y * 0.72), "Spine assets missing", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 22, Color(1, 1, 1, 0.86))
	draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y * 0.8), "SkeletonGraphic (kokomi_Loading)", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 16, Color(0.82, 0.92, 0.96, 0.78))
