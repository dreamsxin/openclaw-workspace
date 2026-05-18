extends Node2D
class_name SimpleSpinePlayer

const DEG := PI / 180.0

var data_path := ""
var animation_name := "idle"
var loop := true
var time_scale := 1.0

var skeleton: Dictionary = {}
var atlas: Dictionary = {}
var skeleton_name := ""
var page_textures: Dictionary = {}
var page_images: Dictionary = {}
var region_textures: Dictionary = {}
var bones: Array = []
var bone_by_name: Dictionary = {}
var slots: Array = []
var skins: Dictionary = {}
var draw_nodes: Array = []
var elapsed := 0.0
var duration := 1.0
var only_slots: Array = []

func load_spine(path: String, anim := "idle") -> bool:
	data_path = path
	animation_name = anim
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var payload: Dictionary = parsed
	skeleton_name = str(payload.get("name", ""))
	skeleton = payload.get("skeleton", {})
	atlas = payload.get("atlas", {})
	_load_textures(payload)
	_build_skeleton()
	_build_draw_nodes()
	_set_animation_duration()
	set_process(true)
	return true

func play(anim: String) -> void:
	animation_name = anim
	elapsed = 0.0
	_set_animation_duration()

func update_preview_pose(anim_time := 0.0) -> void:
	if skeleton.is_empty():
		return
	_update_pose(anim_time)

func get_draw_bounds() -> Rect2:
	var has_bounds := false
	var bounds := Rect2()
	for node in draw_nodes:
		if node is Polygon2D and node.visible:
			var polygon := node as Polygon2D
			for point in polygon.polygon:
				if not has_bounds:
					bounds = Rect2(point, Vector2.ZERO)
					has_bounds = true
				else:
					bounds = bounds.expand(point)
	if has_bounds:
		return bounds
	return Rect2(Vector2(-100, -300), Vector2(200, 300))

func _process(delta: float) -> void:
	if skeleton.is_empty():
		return
	elapsed += delta * time_scale
	if loop and duration > 0.0:
		elapsed = fmod(elapsed, duration)
	_update_pose(elapsed)

func _load_textures(payload: Dictionary) -> void:
	page_textures.clear()
	page_images.clear()
	region_textures.clear()
	var texture_names: Array = payload.get("texture_names", [])
	var texture_paths: Array = payload.get("texture_paths", [])
	for i in range(texture_names.size()):
		if i >= texture_paths.size():
			continue
		var image := Image.new()
		var path := "res://%s" % str(texture_paths[i])
		if image.load(path) == OK:
			page_images[str(texture_names[i])] = image
			page_textures[str(texture_names[i])] = ImageTexture.create_from_image(image)

func _build_skeleton() -> void:
	bones.clear()
	bone_by_name.clear()
	var source_bones: Array = skeleton.get("bones", [])
	for i in range(source_bones.size()):
		var source: Dictionary = source_bones[i]
		var bone := {
			"name": str(source.get("name", "")),
			"parent": str(source.get("parent", "")),
			"parent_index": -1,
			"length": float(source.get("length", 0.0)),
			"x": float(source.get("x", 0.0)),
			"y": float(source.get("y", 0.0)),
			"rotation": float(source.get("rotation", 0.0)),
			"scale_x": float(source.get("scaleX", 1.0)),
			"scale_y": float(source.get("scaleY", 1.0)),
			"wx": 0.0,
			"wy": 0.0,
			"wa": 1.0,
			"wb": 0.0,
			"wc": 0.0,
			"wd": 1.0,
		}
		bones.append(bone)
		bone_by_name[bone["name"]] = i
	for i in range(bones.size()):
		var parent_name := str(bones[i]["parent"])
		if parent_name != "" and bone_by_name.has(parent_name):
			bones[i]["parent_index"] = int(bone_by_name[parent_name])

	slots = skeleton.get("slots", [])
	skins.clear()
	var source_skins: Variant = skeleton.get("skins", [])
	if typeof(source_skins) == TYPE_ARRAY:
		for skin in source_skins:
			if typeof(skin) == TYPE_DICTIONARY:
				skins[str(skin.get("name", "default"))] = skin.get("attachments", {})
	elif typeof(source_skins) == TYPE_DICTIONARY:
		for skin_name in source_skins:
			skins[str(skin_name)] = source_skins[skin_name]

func _build_draw_nodes() -> void:
	for child in get_children():
		child.queue_free()
	draw_nodes.clear()
	for slot_index in range(slots.size()):
		var slot: Dictionary = slots[slot_index]
		var attachment_name := str(slot.get("attachment", ""))
		var attachment := _get_attachment(str(slot.get("name", "")), attachment_name)
		var item := _create_attachment_node(attachment_name, attachment)
		item.visible = attachment_name != "" and not attachment.is_empty()
		item.z_index = slot_index
		_apply_slot_blend(item, slot)
		add_child(item)
		draw_nodes.append(item)

func _create_attachment_node(attachment_name: String, attachment: Dictionary) -> CanvasItem:
	var attachment_type := str(attachment.get("type", "region"))
	if attachment_type == "mesh":
		var polygon := Polygon2D.new()
		polygon.texture = _page_texture_for_attachment(attachment_name, attachment)
		polygon.polygon = _mesh_vertices(attachment)
		polygon.uv = _mesh_uvs(attachment_name, attachment)
		polygon.polygons = _triangles_to_polygons(attachment.get("triangles", []))
		polygon.antialiased = true
		return polygon
	var region_polygon := Polygon2D.new()
	region_polygon.texture = _page_texture_for_attachment(attachment_name, attachment)
	region_polygon.polygon = _region_local_vertices(attachment)
	region_polygon.uv = _region_uvs(attachment_name, attachment)
	region_polygon.polygons = [PackedInt32Array([0, 1, 2]), PackedInt32Array([2, 3, 0])]
	region_polygon.antialiased = true
	return region_polygon

func _update_pose(anim_time: float) -> void:
	_apply_bone_timelines(anim_time)
	_compute_world_bones()
	_apply_ik_constraints()
	_update_slots(anim_time)

func _apply_bone_timelines(anim_time: float) -> void:
	var anim := _current_animation()
	var bone_timelines: Dictionary = anim.get("bones", {})
	var source_bones: Array = skeleton.get("bones", [])
	for i in range(bones.size()):
		var source: Dictionary = source_bones[i]
		var bone: Dictionary = bones[i]
		var timelines: Dictionary = bone_timelines.get(str(bone["name"]), {})
		bone["x"] = float(source.get("x", 0.0)) + _timeline_xy(timelines.get("translate", []), anim_time, "x", 0.0)
		bone["y"] = float(source.get("y", 0.0)) + _timeline_xy(timelines.get("translate", []), anim_time, "y", 0.0)
		bone["rotation"] = float(source.get("rotation", 0.0)) + _timeline_value(timelines.get("rotate", []), anim_time, "angle", 0.0)
		bone["scale_x"] = float(source.get("scaleX", 1.0)) * _timeline_scale(timelines.get("scale", []), anim_time, "x", 1.0)
		bone["scale_y"] = float(source.get("scaleY", 1.0)) * _timeline_scale(timelines.get("scale", []), anim_time, "y", 1.0)
		bones[i] = bone

func _apply_ik_constraints() -> void:
	var constraints: Array = skeleton.get("ik", [])
	for constraint in constraints:
		if typeof(constraint) != TYPE_DICTIONARY:
			continue
		var chain: Array = constraint.get("bones", [])
		var target_name := str(constraint.get("target", ""))
		if chain.size() == 1:
			_apply_one_bone_ik(str(chain[0]), target_name, float(constraint.get("mix", 1.0)))
		elif chain.size() >= 2:
			_apply_two_bone_ik(str(chain[0]), str(chain[1]), target_name, bool(constraint.get("bendPositive", true)), float(constraint.get("mix", 1.0)))

func _apply_one_bone_ik(bone_name: String, target_name: String, mix: float) -> void:
	if not bone_by_name.has(bone_name) or not bone_by_name.has(target_name):
		return
	var bone_index := int(bone_by_name[bone_name])
	var target: Dictionary = bones[int(bone_by_name[target_name])]
	var bone: Dictionary = bones[bone_index]
	var target_angle := atan2(float(target["wy"]) - float(bone["wy"]), float(target["wx"]) - float(bone["wx"]))
	var current_angle := atan2(float(bone["wc"]), float(bone["wa"]))
	var angle := lerp_angle(current_angle, target_angle, clamp(mix, 0.0, 1.0))
	_set_bone_world_rotation(bone_index, angle, float(bone["wx"]), float(bone["wy"]))

func _apply_two_bone_ik(parent_name: String, child_name: String, target_name: String, bend_positive: bool, mix: float) -> void:
	if not bone_by_name.has(parent_name) or not bone_by_name.has(child_name) or not bone_by_name.has(target_name):
		return
	var parent_index := int(bone_by_name[parent_name])
	var child_index := int(bone_by_name[child_name])
	var target: Dictionary = bones[int(bone_by_name[target_name])]
	var parent: Dictionary = bones[parent_index]
	var child: Dictionary = bones[child_index]
	var px := float(parent["wx"])
	var py := float(parent["wy"])
	var tx := float(target["wx"])
	var ty := float(target["wy"])
	var dx := tx - px
	var dy := ty - py
	var distance: float = max(sqrt(dx * dx + dy * dy), 0.0001)
	var parent_scale := _bone_world_x_scale(parent)
	var child_scale := _bone_world_x_scale(child)
	var parent_len: float = max(float(parent.get("length", 0.0)) * parent_scale, 0.0001)
	var child_len: float = max(float(child.get("length", 0.0)) * child_scale, 0.0001)
	var clamped_cos: float = clamp((distance * distance - parent_len * parent_len - child_len * child_len) / (2.0 * parent_len * child_len), -1.0, 1.0)
	var bend := 1.0 if bend_positive else -1.0
	var child_angle := acos(clamped_cos) * bend
	var parent_angle := atan2(dy, dx) - atan2(child_len * sin(child_angle), parent_len + child_len * cos(child_angle))
	if mix < 1.0:
		parent_angle = lerp_angle(atan2(float(parent["wc"]), float(parent["wa"])), parent_angle, clamp(mix, 0.0, 1.0))
		child_angle = lerp_angle(atan2(float(child["wc"]), float(child["wa"])) - parent_angle, child_angle, clamp(mix, 0.0, 1.0))
	var child_x: float = px + cos(parent_angle) * parent_len
	var child_y: float = py + sin(parent_angle) * parent_len
	_set_bone_world_rotation(parent_index, parent_angle, px, py)
	_set_bone_world_rotation(child_index, parent_angle + child_angle, child_x, child_y)
	_recompute_child_bones(parent_index, {parent_index: true, child_index: true})
	_recompute_child_bones(child_index, {child_index: true})

func _recompute_child_bones(parent_index: int, locked: Dictionary = {}) -> void:
	for i in range(bones.size()):
		var bone: Dictionary = bones[i]
		if int(bone.get("parent_index", -1)) != parent_index:
			continue
		if not locked.has(i):
			_compute_single_world_bone(i)
		_recompute_child_bones(i, locked)

func _compute_single_world_bone(index: int) -> void:
	var bone: Dictionary = bones[index]
	var r := float(bone["rotation"]) * DEG
	var cos_r := cos(r)
	var sin_r := sin(r)
	var la := cos_r * float(bone["scale_x"])
	var lb := -sin_r * float(bone["scale_y"])
	var lc := sin_r * float(bone["scale_x"])
	var ld := cos_r * float(bone["scale_y"])
	if int(bone["parent_index"]) >= 0:
		var parent: Dictionary = bones[int(bone["parent_index"])]
		bone["wx"] = float(parent["wx"]) + float(bone["x"]) * float(parent["wa"]) + float(bone["y"]) * float(parent["wb"])
		bone["wy"] = float(parent["wy"]) + float(bone["x"]) * float(parent["wc"]) + float(bone["y"]) * float(parent["wd"])
		bone["wa"] = float(parent["wa"]) * la + float(parent["wb"]) * lc
		bone["wb"] = float(parent["wa"]) * lb + float(parent["wb"]) * ld
		bone["wc"] = float(parent["wc"]) * la + float(parent["wd"]) * lc
		bone["wd"] = float(parent["wc"]) * lb + float(parent["wd"]) * ld
	else:
		bone["wx"] = float(bone["x"])
		bone["wy"] = float(bone["y"])
		bone["wa"] = la
		bone["wb"] = lb
		bone["wc"] = lc
		bone["wd"] = ld
	bones[index] = bone

func _bone_world_x_scale(bone: Dictionary) -> float:
	return max(sqrt(float(bone["wa"]) * float(bone["wa"]) + float(bone["wc"]) * float(bone["wc"])), 0.0001)

func _bone_world_y_scale(bone: Dictionary) -> float:
	return max(sqrt(float(bone["wb"]) * float(bone["wb"]) + float(bone["wd"]) * float(bone["wd"])), 0.0001)

func _set_bone_world_rotation(bone_index: int, angle: float, wx: float, wy: float) -> void:
	var bone: Dictionary = bones[bone_index]
	var scale_x := _bone_world_x_scale(bone)
	var scale_y := _bone_world_y_scale(bone)
	var cos_a := cos(angle)
	var sin_a := sin(angle)
	bone["wx"] = wx
	bone["wy"] = wy
	bone["wa"] = cos_a * scale_x
	bone["wb"] = -sin_a * scale_y
	bone["wc"] = sin_a * scale_x
	bone["wd"] = cos_a * scale_y
	bones[bone_index] = bone

func _compute_world_bones() -> void:
	for i in range(bones.size()):
		var bone: Dictionary = bones[i]
		var r := float(bone["rotation"]) * DEG
		var cos_r := cos(r)
		var sin_r := sin(r)
		var la := cos_r * float(bone["scale_x"])
		var lb := -sin_r * float(bone["scale_y"])
		var lc := sin_r * float(bone["scale_x"])
		var ld := cos_r * float(bone["scale_y"])
		if int(bone["parent_index"]) >= 0:
			var parent: Dictionary = bones[int(bone["parent_index"])]
			bone["wx"] = float(parent["wx"]) + float(bone["x"]) * float(parent["wa"]) + float(bone["y"]) * float(parent["wb"])
			bone["wy"] = float(parent["wy"]) + float(bone["x"]) * float(parent["wc"]) + float(bone["y"]) * float(parent["wd"])
			bone["wa"] = float(parent["wa"]) * la + float(parent["wb"]) * lc
			bone["wb"] = float(parent["wa"]) * lb + float(parent["wb"]) * ld
			bone["wc"] = float(parent["wc"]) * la + float(parent["wd"]) * lc
			bone["wd"] = float(parent["wc"]) * lb + float(parent["wd"]) * ld
		else:
			bone["wx"] = float(bone["x"])
			bone["wy"] = float(bone["y"])
			bone["wa"] = la
			bone["wb"] = lb
			bone["wc"] = lc
			bone["wd"] = ld
		bones[i] = bone

func _update_slots(anim_time: float) -> void:
	var slot_timelines: Dictionary = _current_animation().get("slots", {})
	var draw_order := _draw_order_at_time(anim_time)
	for i in range(slots.size()):
		var draw_index := int(draw_order[i]) if i < draw_order.size() else i
		var slot: Dictionary = slots[i]
		var slot_name := str(slot.get("name", ""))
		if not only_slots.is_empty() and not only_slots.has(slot_name):
			draw_nodes[i].visible = false
			continue
		var attachment_name := _attachment_at_time(slot_name, str(slot.get("attachment", "")), anim_time)
		var attachment := _get_attachment(slot_name, attachment_name)
		var node: CanvasItem = draw_nodes[i]
		node.visible = attachment_name != "" and not attachment.is_empty()
		if not node.visible:
			continue
		node.z_index = draw_index
		var color := _slot_color_at_time(slot, slot_timelines.get(slot_name, {}), anim_time)
		node.modulate = color
		_apply_attachment_transform(node, slot_name, str(slot.get("bone", "")), attachment_name, attachment, anim_time)

func _apply_attachment_transform(node: CanvasItem, slot_name: String, bone_name: String, attachment_name: String, attachment: Dictionary, anim_time: float) -> void:
	if not bone_by_name.has(bone_name):
		return
	var bone: Dictionary = bones[int(bone_by_name[bone_name])]
	if node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.texture = _region_texture_for_attachment(attachment_name, attachment)
		var x := float(attachment.get("x", 0.0))
		var y := float(attachment.get("y", 0.0))
		var ar := float(attachment.get("rotation", 0.0)) * DEG
		var region_scale := _region_attachment_scale(sprite.texture, attachment)
		var asx := float(attachment.get("scaleX", 1.0)) * region_scale.x
		var asy := float(attachment.get("scaleY", 1.0)) * region_scale.y
		var lx := cos(ar) * asx
		var ly := sin(ar) * asx
		var rx := -sin(ar) * asy
		var ry := cos(ar) * asy
		var a := float(bone["wa"]) * lx + float(bone["wb"]) * ly
		var b := float(bone["wa"]) * rx + float(bone["wb"]) * ry
		var c := float(bone["wc"]) * lx + float(bone["wd"]) * ly
		var d := float(bone["wc"]) * rx + float(bone["wd"]) * ry
		var px := float(bone["wx"]) + x * float(bone["wa"]) + y * float(bone["wb"])
		var py := float(bone["wy"]) + x * float(bone["wc"]) + y * float(bone["wd"])
		sprite.transform = _godot_transform(a, b, c, d, px, py)
	elif node is Polygon2D:
		var polygon := node as Polygon2D
		polygon.texture = _page_texture_for_attachment(attachment_name, attachment)
		if str(attachment.get("type", "region")) == "mesh":
			var deform := _deform_at_time(slot_name, attachment_name, attachment, anim_time)
			var vertices := _mesh_world_vertices(attachment, bone, deform)
			vertices = _apply_slot_vertex_correction(slot_name, vertices)
			polygon.polygon = vertices
			polygon.uv = _mesh_uvs(attachment_name, attachment)
			polygon.polygons = _triangles_to_polygons(attachment.get("triangles", []))
		else:
			polygon.polygon = _apply_slot_vertex_correction(slot_name, _region_world_vertices(attachment, bone))
			polygon.uv = _region_uvs(attachment_name, attachment)
			polygon.polygons = [PackedInt32Array([0, 1, 2]), PackedInt32Array([2, 3, 0])]
		polygon.transform = Transform2D.IDENTITY

func _apply_slot_vertex_correction(slot_name: String, vertices: PackedVector2Array) -> PackedVector2Array:
	if skeleton_name != "YiKaLuoSi":
		return vertices
	var offset := Vector2.ZERO
	match slot_name:
		"YiKaLuoSi_toushi03":
			offset = Vector2(-10, 30)
		_:
			return vertices
	var out := PackedVector2Array()
	for vertex in vertices:
		out.append(vertex + offset)
	return out

func _mesh_world_vertices(attachment: Dictionary, slot_bone: Dictionary, deform: Array = []) -> PackedVector2Array:
	var raw: Array = attachment.get("vertices", [])
	var uv_count := int(attachment.get("uvs", []).size() / 2)
	var out := PackedVector2Array()
	if raw.size() == uv_count * 2:
		for i in uv_count:
			var x := float(raw[i * 2]) + _deform_value(deform, i * 2)
			var y := float(raw[i * 2 + 1]) + _deform_value(deform, i * 2 + 1)
			out.append(_bone_to_godot(slot_bone, x, y))
		return out
	var index := 0
	var deform_index := 0
	for _i in uv_count:
		var influences := int(raw[index])
		index += 1
		var wx := 0.0
		var wy := 0.0
		for _j in influences:
			var bone_index := int(raw[index])
			var x := float(raw[index + 1]) + _deform_value(deform, deform_index)
			var y := float(raw[index + 2]) + _deform_value(deform, deform_index + 1)
			var weight := float(raw[index + 3])
			index += 4
			deform_index += 2
			if bone_index < 0 or bone_index >= bones.size():
				continue
			var bone: Dictionary = bones[bone_index]
			var gx := float(bone["wx"]) + x * float(bone["wa"]) + y * float(bone["wb"])
			var gy := float(bone["wy"]) + x * float(bone["wc"]) + y * float(bone["wd"])
			wx += gx * weight
			wy += gy * weight
		out.append(Vector2(wx, -wy))
	return out

func _bone_to_godot(bone: Dictionary, x: float, y: float) -> Vector2:
	var gx := float(bone["wx"]) + x * float(bone["wa"]) + y * float(bone["wb"])
	var gy := float(bone["wy"]) + x * float(bone["wc"]) + y * float(bone["wd"])
	return Vector2(gx, -gy)

func _region_world_vertices(attachment: Dictionary, bone: Dictionary) -> PackedVector2Array:
	var local := _region_local_vertices(attachment)
	var out := PackedVector2Array()
	for point in local:
		out.append(_bone_to_godot(bone, point.x, point.y))
	return out

func _region_local_vertices(attachment: Dictionary) -> PackedVector2Array:
	var width: float = float(attachment.get("width", 0.0))
	var height: float = float(attachment.get("height", 0.0))
	var half_w: float = width * 0.5
	var half_h: float = height * 0.5
	var x: float = float(attachment.get("x", 0.0))
	var y: float = float(attachment.get("y", 0.0))
	var rotation: float = float(attachment.get("rotation", 0.0)) * DEG
	var scale_x: float = float(attachment.get("scaleX", 1.0))
	var scale_y: float = float(attachment.get("scaleY", 1.0))
	var cos_r: float = cos(rotation)
	var sin_r: float = sin(rotation)
	var points: Array[Vector2] = [
		Vector2(-half_w * scale_x, -half_h * scale_y),
		Vector2(-half_w * scale_x, half_h * scale_y),
		Vector2(half_w * scale_x, half_h * scale_y),
		Vector2(half_w * scale_x, -half_h * scale_y),
	]
	var out := PackedVector2Array()
	for point in points:
		var rx: float = point.x * cos_r - point.y * sin_r + x
		var ry: float = point.x * sin_r + point.y * cos_r + y
		out.append(Vector2(rx, ry))
	return out

func _godot_transform(a: float, b: float, c: float, d: float, x: float, y: float) -> Transform2D:
	return Transform2D(Vector2(a, -c), Vector2(b, -d), Vector2(x, -y))

func _page_texture_for_attachment(attachment_name: String, attachment: Dictionary) -> Texture2D:
	var path := str(attachment.get("path", attachment_name))
	var region: Dictionary = atlas.get("regions", {}).get(path, atlas.get("regions", {}).get(attachment_name, {}))
	var page := str(region.get("page", ""))
	return page_textures.get(page, null)

func _region_texture_for_attachment(attachment_name: String, attachment: Dictionary) -> Texture2D:
	var path := str(attachment.get("path", attachment_name))
	var region: Dictionary = _atlas_region(attachment_name, attachment)
	var page := str(region.get("page", ""))
	var key := "%s:%s" % [page, path]
	if region_textures.has(key):
		return region_textures[key]
	var image: Image = page_images.get(page, null)
	if image == null:
		return null
	var xy := _arr_to_vec2i(region.get("xy", [0, 0]))
	var size := _arr_to_vec2i(region.get("size", [0, 0]))
	var crop_size := size
	if bool(region.get("rotate", false)):
		crop_size = Vector2i(size.y, size.x)
	if crop_size.x <= 0 or crop_size.y <= 0:
		return null
	var crop := Rect2i(xy, crop_size)
	if not Rect2i(Vector2i.ZERO, image.get_size()).encloses(crop):
		return null
	var frame := image.get_region(crop)
	if bool(region.get("rotate", false)):
		frame.rotate_90(COUNTERCLOCKWISE)
	var texture := ImageTexture.create_from_image(frame)
	region_textures[key] = texture
	return texture

func _region_attachment_scale(texture: Texture2D, attachment: Dictionary) -> Vector2:
	if texture == null:
		return Vector2.ONE
	var width := float(attachment.get("width", texture.get_width()))
	var height := float(attachment.get("height", texture.get_height()))
	if texture.get_width() <= 0 or texture.get_height() <= 0:
		return Vector2.ONE
	return Vector2(width / float(texture.get_width()), height / float(texture.get_height()))

func _mesh_vertices(attachment: Dictionary) -> PackedVector2Array:
	var raw: Array = attachment.get("vertices", [])
	var uv_count := int(attachment.get("uvs", []).size() / 2)
	var out := PackedVector2Array()
	if raw.size() >= uv_count * 2:
		for i in uv_count:
			out.append(Vector2(float(raw[i * 2]), -float(raw[i * 2 + 1])))
	return out

func _mesh_uvs(attachment_name: String, attachment: Dictionary) -> PackedVector2Array:
	var region := _atlas_region(attachment_name, attachment)
	var xy: Array = region.get("xy", [0, 0])
	var size: Array = region.get("size", [0, 0])
	var uvs: Array = attachment.get("uvs", [])
	var out := PackedVector2Array()
	for i in range(int(uvs.size() / 2)):
		var u := float(uvs[i * 2])
		var v := float(uvs[i * 2 + 1])
		var px := 0.0
		var py := 0.0
		if bool(region.get("rotate", false)):
			px = float(xy[0]) + v * float(size[1])
			py = float(xy[1]) + (1.0 - u) * float(size[0])
		else:
			px = float(xy[0]) + u * float(size[0])
			py = float(xy[1]) + v * float(size[1])
		out.append(Vector2(px, py))
	return out

func _region_uvs(attachment_name: String, attachment: Dictionary) -> PackedVector2Array:
	var region := _atlas_region(attachment_name, attachment)
	var xy := _arr_to_vec2i(region.get("xy", [0, 0]))
	var size := _arr_to_vec2i(region.get("size", [0, 0]))
	if bool(region.get("rotate", false)):
		var x := float(xy.x)
		var y := float(xy.y)
		var w := float(size.y)
		var h := float(size.x)
		return PackedVector2Array([
			Vector2(x + w, y + h),
			Vector2(x, y + h),
			Vector2(x, y),
			Vector2(x + w, y),
		])
	return PackedVector2Array([
		Vector2(float(xy.x), float(xy.y + size.y)),
		Vector2(float(xy.x), float(xy.y)),
		Vector2(float(xy.x + size.x), float(xy.y)),
		Vector2(float(xy.x + size.x), float(xy.y + size.y)),
	])

func _triangles_to_polygons(triangles: Array) -> Array:
	var out: Array = []
	for i in range(0, triangles.size() - 2, 3):
		out.append(PackedInt32Array([int(triangles[i]), int(triangles[i + 1]), int(triangles[i + 2])]))
	return out

func _atlas_region(attachment_name: String, attachment: Dictionary) -> Dictionary:
	var path := str(attachment.get("path", attachment_name))
	return atlas.get("regions", {}).get(path, atlas.get("regions", {}).get(attachment_name, {}))

func _arr_to_vec2i(value: Variant) -> Vector2i:
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _get_attachment(slot_name: String, attachment_name: String) -> Dictionary:
	if attachment_name == "":
		return {}
	var default_skin: Dictionary = skins.get("default", {})
	var slot_attachments: Dictionary = default_skin.get(slot_name, {})
	return slot_attachments.get(attachment_name, {})

func _attachment_at_time(slot_name: String, base_attachment: String, anim_time: float) -> String:
	var timelines: Dictionary = _current_animation().get("slots", {}).get(slot_name, {})
	var keys: Array = timelines.get("attachment", [])
	if keys.is_empty():
		return base_attachment
	var chosen: Variant = keys[0]
	for key in keys:
		if float(key.get("time", 0.0)) <= anim_time:
			chosen = key
		else:
			break
	var name_value: Variant = chosen.get("name", base_attachment)
	return "" if name_value == null else str(name_value)

func _draw_order_at_time(anim_time: float) -> Array:
	var order: Array = []
	order.resize(slots.size())
	for i in range(slots.size()):
		order[i] = i
	var keys: Array = _current_animation().get("drawOrder", _current_animation().get("draworder", []))
	if keys.is_empty():
		return order
	var chosen: Dictionary = {}
	for key in keys:
		if float(key.get("time", 0.0)) <= anim_time:
			chosen = key
		else:
			break
	if chosen.is_empty():
		return order
	var unchanged: Array = []
	unchanged.resize(slots.size() - chosen.get("offsets", []).size())
	var original_index := 0
	var unchanged_index := 0
	var offsets: Array = chosen.get("offsets", [])
	for offset_item in offsets:
		var slot_index := _slot_index(str(offset_item.get("slot", "")))
		if slot_index < 0:
			continue
		while original_index != slot_index and unchanged_index < unchanged.size():
			unchanged[unchanged_index] = original_index
			unchanged_index += 1
			original_index += 1
		order[original_index + int(offset_item.get("offset", 0))] = original_index
		original_index += 1
	while original_index < slots.size() and unchanged_index < unchanged.size():
		unchanged[unchanged_index] = original_index
		unchanged_index += 1
		original_index += 1
	for i in range(slots.size() - 1, -1, -1):
		if order[i] == i:
			unchanged_index -= 1
			if unchanged_index >= 0:
				order[i] = unchanged[unchanged_index]
	var z_by_slot: Array = []
	z_by_slot.resize(slots.size())
	for z in range(order.size()):
		var slot_i := int(order[z])
		if slot_i >= 0 and slot_i < z_by_slot.size():
			z_by_slot[slot_i] = z
	return z_by_slot

func _slot_index(slot_name: String) -> int:
	for i in range(slots.size()):
		var slot: Dictionary = slots[i]
		if str(slot.get("name", "")) == slot_name:
			return i
	return -1

func _slot_color_at_time(slot: Dictionary, timelines: Dictionary, anim_time: float) -> Color:
	var base := _parse_color(str(slot.get("color", "ffffffff")))
	var keys: Array = timelines.get("color", [])
	if keys.is_empty():
		return base
	var prev: Dictionary = keys[0]
	var next: Dictionary = keys[keys.size() - 1]
	for i in range(1, keys.size()):
		next = keys[i]
		if float(next.get("time", 0.0)) >= anim_time:
			break
		prev = next
	if float(next.get("time", 0.0)) <= anim_time:
		return _parse_color(str(next.get("color", "ffffffff")))
	if str(prev.get("curve", "")) == "stepped":
		return _parse_color(str(prev.get("color", "ffffffff")))
	var next_color := _parse_color(str(next.get("color", "ffffffff")))
	var prev_color := _parse_color(str(prev.get("color", slot.get("color", "ffffffff"))))
	var start_time: float = float(prev.get("time", 0.0))
	var end_time: float = float(next.get("time", 0.0))
	var alpha: float = _timeline_alpha(prev, (anim_time - start_time) / max(end_time - start_time, 0.0001))
	return prev_color.lerp(next_color, alpha)

func _apply_slot_blend(node: CanvasItem, slot: Dictionary) -> void:
	match str(slot.get("blend", "normal")):
		"additive":
			node.material = _canvas_blend_material(CanvasItemMaterial.BLEND_MODE_ADD)
		"multiply":
			node.material = _canvas_blend_material(CanvasItemMaterial.BLEND_MODE_MUL)
		"screen":
			node.material = _canvas_blend_material(CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA)
		_:
			node.material = null

func _canvas_blend_material(mode: CanvasItemMaterial.BlendMode) -> CanvasItemMaterial:
	var material := CanvasItemMaterial.new()
	material.blend_mode = mode
	return material

func _deform_at_time(slot_name: String, attachment_name: String, attachment: Dictionary, anim_time: float) -> Array:
	var deform_root: Dictionary = _current_animation().get("deform", {})
	var skin_deform: Dictionary = deform_root.get("default", {})
	var slot_deform: Dictionary = skin_deform.get(slot_name, {})
	var keys: Array = slot_deform.get(attachment_name, [])
	if keys.is_empty():
		return []
	var target_len := _deform_target_length(attachment)
	var prev: Dictionary = keys[0]
	var next: Dictionary = keys[keys.size() - 1]
	for i in range(1, keys.size()):
		next = keys[i]
		if float(next.get("time", 0.0)) >= anim_time:
			break
		prev = next
	if float(next.get("time", 0.0)) <= anim_time:
		return _expanded_deform(next, target_len)
	if str(prev.get("curve", "")) == "stepped":
		return _expanded_deform(prev, target_len)
	var start_time: float = float(prev.get("time", 0.0))
	var end_time: float = float(next.get("time", 0.0))
	var alpha: float = _timeline_alpha(prev, (anim_time - start_time) / max(end_time - start_time, 0.0001))
	var prev_values: Array = _expanded_deform(prev, target_len)
	var next_values: Array = _expanded_deform(next, target_len)
	var out: Array = []
	for i in range(target_len):
		out.append(lerpf(float(prev_values[i]), float(next_values[i]), alpha))
	return out

func _deform_target_length(attachment: Dictionary) -> int:
	var raw: Array = attachment.get("vertices", [])
	var uv_count := int(attachment.get("uvs", []).size() / 2)
	if raw.size() == uv_count * 2:
		return raw.size()
	var index := 0
	var count := 0
	for _i in range(uv_count):
		if index >= raw.size():
			break
		var influences := int(raw[index])
		index += 1
		count += influences * 2
		index += influences * 4
	return count

func _expanded_deform(key: Dictionary, target_len: int) -> Array:
	var out: Array = []
	out.resize(target_len)
	out.fill(0.0)
	var values: Array = key.get("vertices", [])
	var offset := int(key.get("offset", 0))
	for i in range(values.size()):
		var at := offset + i
		if at >= 0 and at < target_len:
			out[at] = float(values[i])
	return out

func _deform_value(values: Array, index: int) -> float:
	if index >= 0 and index < values.size():
		return float(values[index])
	return 0.0

func _parse_color(hex: String) -> Color:
	if hex.length() < 8:
		return Color.WHITE
	var r := hex.substr(0, 2).hex_to_int() / 255.0
	var g := hex.substr(2, 2).hex_to_int() / 255.0
	var b := hex.substr(4, 2).hex_to_int() / 255.0
	var a := hex.substr(6, 2).hex_to_int() / 255.0
	return Color(r, g, b, a)

func _timeline_xy(keys: Array, anim_time: float, key: String, setup_value: float) -> float:
	return _timeline_value(keys, anim_time, key, setup_value)

func _timeline_scale(keys: Array, anim_time: float, key: String, setup_value: float) -> float:
	return _timeline_value(keys, anim_time, key, setup_value)

func _timeline_value(keys: Array, anim_time: float, key: String, default_value: float) -> float:
	if keys.is_empty():
		return default_value
	if keys.size() == 1:
		return float(keys[0].get(key, default_value))
	var prev: Dictionary = keys[0]
	var next: Dictionary = keys[keys.size() - 1]
	for i in range(1, keys.size()):
		next = keys[i]
		if float(next.get("time", 0.0)) >= anim_time:
			break
		prev = next
	if float(next.get("time", 0.0)) <= anim_time:
		return float(next.get(key, prev.get(key, default_value)))
	if str(prev.get("curve", "")) == "stepped":
		return float(prev.get(key, default_value))
	var start_time: float = float(prev.get("time", 0.0))
	var end_time: float = float(next.get("time", 0.0))
	var denom: float = max(end_time - start_time, 0.0001)
	var alpha: float = _timeline_alpha(prev, (anim_time - start_time) / denom)
	return lerpf(float(prev.get(key, default_value)), float(next.get(key, prev.get(key, default_value))), alpha)

func _timeline_alpha(keyframe: Dictionary, progress: float) -> float:
	var t: float = clamp(progress, 0.0, 1.0)
	var curve: Variant = keyframe.get("curve", null)
	if curve == null or str(curve) == "stepped":
		return t
	var x1: float = float(curve)
	var y1: float = float(keyframe.get("c2", 0.0))
	var x2: float = float(keyframe.get("c3", 1.0))
	var y2: float = float(keyframe.get("c4", 1.0))
	return _bezier_y_for_x(t, x1, y1, x2, y2)

func _bezier_y_for_x(x: float, x1: float, y1: float, x2: float, y2: float) -> float:
	var low: float = 0.0
	var high: float = 1.0
	var t: float = x
	for _i in range(10):
		t = (low + high) * 0.5
		var sample_x: float = _cubic_bezier(t, 0.0, x1, x2, 1.0)
		if sample_x < x:
			low = t
		else:
			high = t
	return _cubic_bezier(t, 0.0, y1, y2, 1.0)

func _cubic_bezier(t: float, p0: float, p1: float, p2: float, p3: float) -> float:
	var inv: float = 1.0 - t
	return inv * inv * inv * p0 + 3.0 * inv * inv * t * p1 + 3.0 * inv * t * t * p2 + t * t * t * p3

func _current_animation() -> Dictionary:
	return skeleton.get("animations", {}).get(animation_name, {})

func _set_animation_duration() -> void:
	duration = 1.0
	duration = max(duration, _scan_duration(_current_animation()))

func _scan_duration(value: Variant) -> float:
	var max_time := 0.0
	if typeof(value) == TYPE_DICTIONARY:
		for key in value:
			if key == "time":
				max_time = max(max_time, float(value[key]))
			else:
				max_time = max(max_time, _scan_duration(value[key]))
	elif typeof(value) == TYPE_ARRAY:
		for item in value:
			max_time = max(max_time, _scan_duration(item))
	return max_time
