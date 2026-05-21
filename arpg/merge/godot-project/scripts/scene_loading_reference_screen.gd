class_name SceneLoadingReferenceScreen
extends Control

const SPINE_ASSET_DIR := "res://assets/spine/loading/kokomi_Loading/"
const SPINE_ATLAS_PATH := SPINE_ASSET_DIR + "kokomi_Loading.atlas.txt"
const SPINE_PAGE_NAMES := ["kokomi_Loading_2.png", "kokomi_Loading.png"]
const SPINE_DRAW_ORDER := [
	"Background/Background",
	"Back_Ribbon_2",
	"Back_Ribbon_5",
	"Twintails_L_1",
	"Twintails_R_2",
	"Twintails_L_2",
	"Skirt_Back",
	"Leg_Thigh_R",
	"Leg_Thigh_L",
	"Leg_Calf_R",
	"Leg_Calf_L",
	"Leg_Foot_R",
	"Leg_Foot_L",
	"Skrit_Frill_Back",
	"Skirt_Front",
	"Skirt_Frill_Front",
	"Chest",
	"Breast",
	"Apron_Back",
	"Apron_Front",
	"Shoulder_Frill_L_Back",
	"Shoulder_Frill_R",
	"Arm_R_Upper",
	"Arm_R_Lower",
	"Hand_R",
	"Sleeves_L_Puff",
	"Arm_L_Upper",
	"Arm_L_Lower",
	"Hand_L",
	"Neck",
	"Head",
	"Ear",
	"Hairband",
	"Hairband_Frill",
	"Hair_Bang_1",
	"Hair_Bang_2",
	"Hair_Bang_3",
	"Side_Hair_L_Upper",
	"Side_Hair_R_Upper",
	"Eye_Whites_L",
	"Eye_Whites_R",
	"Eye_Iris_L",
	"Eye_Iris_R",
	"Eye_Pupil_L",
	"Eye_Pupil_R",
	"Eye_Highlights_L_1",
	"Eye_Highlights_R_1",
	"Eyelashes_Lower_L",
	"Eyelashes_Lower_R",
	"Eyelsahes_Upper_L",
	"Eyelsahes_Upper_R",
	"Eyebrow",
	"Nose",
	"Mouth",
	"Cafe_Table",
	"Dishcloth_Front",
]

var source: Dictionary = {}
var progress := 0.0
var message := "Scene loading..."
var spine_time := 0.0
var spine_pages: Dictionary = {}
var spine_regions: Dictionary = {}
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
	spine_assets_ready = spine_regions.has("Head") and spine_regions.has("Cafe_Table")

func _parse_atlas_numbers(value: String) -> Array[float]:
	var numbers: Array[float] = []
	for part in value.split(","):
		numbers.append(float(part.strip_edges()))
	return numbers

func _draw_spine_region_animation(target: Rect2) -> void:
	var rig_origin := target.position + Vector2(target.size.x * 0.5, target.size.y * 0.5)
	var scale_factor := minf(target.size.x / 1220.0, target.size.y / 1700.0)
	var breath := sin(spine_time * 2.2)
	var sway := sin(spine_time * 1.35)
	var blink := fposmod(spine_time, 3.4) > 3.16

	for region_name in SPINE_DRAW_ORDER:
		_draw_spine_region(region_name, target, rig_origin, scale_factor, breath, sway, blink)
	draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y - 28), "SkeletonGraphic (kokomi_Loading)", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 16, Color(0.9, 0.98, 1.0, 0.82))

func _draw_spine_region(region_name: String, target: Rect2, rig_origin: Vector2, scale_factor: float, breath: float, sway: float, blink: bool) -> void:
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
	var dest := Rect2(_spine_region_position(region_name, src_size, rig_origin, scale_factor, breath, sway, blink), src_size * scale_factor)
	if region_name == "Background/Background":
		dest = target.grow(-8.0)
	if blink and region_name.begins_with("Eye_"):
		dest.size.y = maxf(dest.size.y * 0.22, 2.0)
		dest.position.y += bounds.size.y * scale_factor * 0.36

	draw_texture_rect_region(spine_pages[page_name], dest, bounds, Color(1, 1, 1, 0.98), rotated, true)

func _spine_region_position(region_name: String, src_size: Vector2, rig_origin: Vector2, scale_factor: float, breath: float, sway: float, blink: bool) -> Vector2:
	var atlas_position := _canonical_spine_position(region_name)
	var offset := _animated_spine_offset(region_name, breath, sway, blink)
	return Vector2(
		(rig_origin.x + (atlas_position.x + offset.x) * scale_factor) - src_size.x * scale_factor * 0.5,
		(rig_origin.y + (atlas_position.y + offset.y) * scale_factor) - src_size.y * scale_factor * 0.5
	)

func _canonical_spine_position(region_name: String) -> Vector2:
	if region_name == "Cafe_Table":
		return Vector2(0, 520)
	if region_name == "Dishcloth_Front":
		return Vector2(180, 395)
	if region_name.begins_with("Leg_Foot_L"):
		return Vector2(-165, 445)
	if region_name.begins_with("Leg_Foot_R"):
		return Vector2(145, 448)
	if region_name.begins_with("Leg_Calf_L"):
		return Vector2(-145, 320)
	if region_name.begins_with("Leg_Calf_R"):
		return Vector2(120, 325)
	if region_name.begins_with("Leg_Thigh_L"):
		return Vector2(-108, 175)
	if region_name.begins_with("Leg_Thigh_R"):
		return Vector2(90, 180)
	if region_name.begins_with("Skirt") or region_name.begins_with("Skrit"):
		return Vector2(0, 120)
	if region_name in ["Chest", "Breast", "Apron_Back", "Apron_Front", "Shoulder_Frill_Front"]:
		return Vector2(0, -75)
	if region_name.begins_with("Shoulder_Frill_L") or region_name.begins_with("Sleeves_L") or region_name.begins_with("Arm_L") or region_name == "Hand_L":
		return Vector2(-205, -15)
	if region_name.begins_with("Shoulder_Frill_R") or region_name.begins_with("Arm_R") or region_name == "Hand_R":
		return Vector2(210, -5)
	if region_name == "Neck":
		return Vector2(0, -235)
	if region_name == "Head" or region_name == "Ear":
		return Vector2(0, -330)
	if region_name.begins_with("Eye_") or region_name.begins_with("Eyel") or region_name.begins_with("Eyels") or region_name in ["Eyebrow", "Mouth", "Mouth_Closed", "Nose", "Nose_Highlights"]:
		return Vector2(0, -335)
	if region_name.begins_with("Hair_Bang") or region_name.begins_with("Hairband"):
		return Vector2(0, -430)
	if region_name.begins_with("Side_Hair_L") or region_name.begins_with("Twintails_L"):
		return Vector2(-150, -260)
	if region_name.begins_with("Side_Hair_R") or region_name.begins_with("Twintails_R"):
		return Vector2(155, -260)
	if region_name.begins_with("Back_Ribbon"):
		return Vector2(0, -180)
	return Vector2.ZERO

func _animated_spine_offset(region_name: String, breath: float, sway: float, blink: bool) -> Vector2:
	var offset := Vector2(0, breath * -5.0)
	if region_name == "Cafe_Table" or region_name.begins_with("Background"):
		return Vector2.ZERO
	if region_name.begins_with("Head") or region_name == "Ear":
		return Vector2(sway * 9.0, breath * -8.0)
	if region_name.begins_with("Eye_") or region_name.begins_with("Eyel") or region_name.begins_with("Eyels") or region_name in ["Eyebrow", "Mouth", "Mouth_Closed", "Nose", "Nose_Highlights"]:
		return Vector2(sway * 9.0, breath * -8.0 + (8.0 if blink else 0.0))
	if region_name.begins_with("Hair") or region_name.begins_with("Side_Hair") or region_name.begins_with("Twintails") or region_name.begins_with("Back_Ribbon"):
		return Vector2(sway * 18.0, breath * -7.0)
	if region_name.begins_with("Arm_L") or region_name == "Hand_L" or region_name.begins_with("Sleeves_L"):
		return Vector2(sway * -8.0, breath * 6.0)
	if region_name.begins_with("Arm_R") or region_name == "Hand_R":
		return Vector2(sway * 8.0, breath * 6.0)
	if region_name.begins_with("Skirt") or region_name.begins_with("Skrit") or region_name.begins_with("Apron"):
		return Vector2(sway * 5.0, breath * 3.0)
	return offset

func _draw_spine_fallback(target: Rect2) -> void:
	var center := target.position + target.size * 0.5
	draw_circle(center + Vector2(0, -target.size.y * 0.18), target.size.x * 0.09, Color(0.7, 0.88, 0.94, 0.42))
	draw_line(center + Vector2(0, -target.size.y * 0.08), center + Vector2(0, target.size.y * 0.2), Color(0.7, 0.88, 0.94, 0.72), 4.0)
	draw_line(center + Vector2(0, target.size.y * 0.02), center + Vector2(-target.size.x * 0.16, target.size.y * 0.12), Color(0.7, 0.88, 0.94, 0.72), 3.0)
	draw_line(center + Vector2(0, target.size.y * 0.02), center + Vector2(target.size.x * 0.16, target.size.y * 0.12), Color(0.7, 0.88, 0.94, 0.72), 3.0)
	draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y * 0.72), "Spine assets missing", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 22, Color(1, 1, 1, 0.86))
	draw_string(ThemeDB.fallback_font, target.position + Vector2(0, target.size.y * 0.8), "SkeletonGraphic (kokomi_Loading)", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 16, Color(0.82, 0.92, 0.96, 0.78))
