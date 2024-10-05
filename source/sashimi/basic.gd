extends RefCounted
class_name SashimiBasic

static var basic_state: BasicState

const int_min   := -9223372036854775808
const int_max   := 9223372036854775807
const float_min := -1.79769e308
const float_max := 1.79769e308

const digit_chars := "0123456789"
const assets_path := "res://assets/"

const type_error_message := "Function does not support the given type."

# ( General Utilities )

class BasicState extends Node2D:
	var time: float
	var tick_count: int
	var shapes: Array[Rect2]
	var colors: Array[Color]

	func _ready() -> void:
		z_index = 999

	func _process(dt: float) -> void:
		time = fmod((time + dt), float_max)
		tick_count = (tick_count + 1) % int_max
		queue_redraw()

	func _draw() -> void:
		for i in range(len(shapes)):
			draw_rect(shapes[i], colors[i])
		shapes.clear()
		colors.clear()

static func is_number_type(value) -> bool:
	return value is int or value is float

static func is_vector_type(value) -> bool:
	return value is Vector2 or value is Vector3 or value is Vector4

static func quit() -> void:
	basic_state.get_tree().quit()

static func panic(message: String) -> void:
	print(message)
	quit()
	@warning_ignore("assert_always_false")
	assert(0, message)

static func enter(path: String) -> void:
	basic_state.get_tree().change_scene(assets_path + path)

static func read(path: String) -> Variant:
	const kinds := ["txt", "ini", "sv", "md"]
	for kind in kinds:
		if (path.ends_with(kind)):
			var file := FileAccess.open(assets_path + path, FileAccess.READ)
			if file == null: return null
			return file.get_as_text()
	return load(assets_path + path)

static func to_v2(value) -> Vector2:
	if value is bool:
		var temp := 1 if value else 0
		return Vector2(temp, temp)
	elif is_number_type(value):
		return Vector2(value, value)
	else:
		panic(type_error_message)
		return Vector2()

static func to_v3(value) -> Vector3:
	if value is bool:
		var temp := 1 if value else 0
		return Vector3(temp, temp, temp)
	elif is_number_type(value):
		return Vector3(value, value, value)
	else:
		panic(type_error_message)
		return Vector3()

static func to_v4(value) -> Vector4:
	if value is bool:
		var temp := 1 if value else 0
		return Vector4(temp, temp, temp, temp)
	elif is_number_type(value):
		return Vector4(value, value, value, value)
	else:
		panic(type_error_message)
		return Vector4()

static func take_area(node: Sprite2D) -> Rect2:
	var result := node.get_rect()
	result.position = node.global_position + node.offset
	result.size = result.size * node.scale
	if node.centered: result.position -= Vector2(result.size.x * 0.5, result.size.y * 0.5)
	return result

static func has_point(node: Sprite2D, point: Vector2) -> bool:
	return take_area(node).has_point(point)

static func has_area(node: Sprite2D, area: Rect2) -> bool:
	return take_area(node).intersects(area)

static func move_to(from, to, delta) -> Variant:
	if from is float and to is float and delta is float:
		if abs(to - from) > abs(delta): return from + sign(to - from) * delta
		else: return to
	elif is_vector_type(from) and is_vector_type(to) and is_vector_type(delta):
		var result = from
		var offset = from.direction_to(to) * delta
		if abs(to.x - from.x) > abs(offset.x): result.x = from.x + offset.x
		else: result.x = to.x
		if abs(to.y - from.y) > abs(offset.y): result.y = from.y + offset.y
		else: result.y = to.y
		if from is Vector3:
			if abs(to.y - from.y) > abs(offset.y): result.y = from.y + offset.y
			else: result.y = to.y
		if from is Vector4:
			if abs(to.y - from.y) > abs(offset.y): result.y = from.y + offset.y
			else: result.y = to.y
		return result
	else:
		panic(type_error_message)
		return 0.0

static func move_to_with_slowdown(from, to, delta, slowdown) -> Variant:
	if not (slowdown is float):
		panic(type_error_message)
		return 0.0

	if from is float and to is float and delta is float:
		if slowdown <= 0.0 or is_equal_approx(from, to): return to
		var target = ((from * (slowdown - 1.0)) + to) / slowdown
		var offset = target - from
		return from + offset * delta
	elif is_vector_type(from) and is_vector_type(to) and is_vector_type(delta):
		var result = from
		result.x = move_to_with_slowdown(from.x, to.x, delta.x, slowdown)
		result.y = move_to_with_slowdown(from.y, to.y, delta.y, slowdown)
		if from is Vector3:
			result.z = move_to_with_slowdown(from.z, to.z, delta.z, slowdown)
		if from is Vector4:
			result.w = move_to_with_slowdown(from.w, to.w, delta.w, slowdown)
		return result
	else:
		panic(type_error_message)
		return 0.0

static func follow_position(object, to, delta) -> void:
	object.position = move_to(object.position, to, delta)

static func follow_rotation(object, to, delta) -> void:
	object.rotation = move_to(object.rotation, to, delta)

static func follow_scale(object, to, delta) -> void:
	object.scale = move_to(object.scale, to, delta)

static func follow_position_with_slowdown(object, to, delta, slowdown) -> void:
	object.position = move_to_with_slowdown(object.position, to, delta, slowdown)

static func follow_rotation_with_slowdown(object, to, delta, slowdown) -> void:
	object.rotation = move_to_with_slowdown(object.rotation, to, delta, slowdown)

static func follow_scale_with_slowdown(object, to, delta, slowdown) -> void:
	object.scale = move_to_with_slowdown(object.scale, to, delta, slowdown)

static func elapsed_time() -> float:
	return basic_state.time

static func elapsed_tick_count() -> float:
	return basic_state.tick_count

static func resolution_width() -> int:
	return basic_state.get_tree().get_root().content_scale_size.x

static func resolution_height() -> int:
	return basic_state.get_tree().get_root().content_scale_size.y

static func resolution() -> Vector2:
	return basic_state.get_tree().get_root().content_scale_size

static func mouse_screen_position() -> Vector2:
	return basic_state.get_viewport().get_mouse_position()

static func mouse_world_position() -> Vector2:
	return basic_state.get_global_mouse_position()

static func is_pressed(key: String) -> bool:
	if len(key) != 1:
		panic("String is not a valid key. Length must be 1.")
		return false
	var target := key.to_upper().unicode_at(0)
	return Input.is_physical_key_pressed(target)

static func wasd() -> Vector2:
	var result := Vector2()
	if is_pressed("w") or Input.is_action_pressed("ui_up"): result.y += -1
	if is_pressed("a") or Input.is_action_pressed("ui_left"): result.x += -1
	if is_pressed("s") or Input.is_action_pressed("ui_down"): result.y += 1
	if is_pressed("d") or Input.is_action_pressed("ui_right"): result.x += 1
	return result

static func draw_rect(shape: Rect2, color: Color) -> void:
	basic_state.shapes.append(shape)
	basic_state.colors.append(color)

static func add_node(node) -> Variant:
	basic_state.add_child(node)
	if node is Node2D:
		node.z_as_relative = false
	return node

static func add_child(node, to) -> Variant:
	to.add_child(node)
	if node is Node2D:
		node.z_as_relative = false
	return node

# ( Sprite Animation )

class SpriteAnimation extends RefCounted:
	var frame_row := 0
	var frame_count := 1
	var frame_speed := 6

static func make_sprite_animation(frame_row: int, frame_count: int, frame_speed: int) -> SpriteAnimation:
	var result := SpriteAnimation.new()
	result.frame_row = frame_row
	result.frame_count = frame_count
	result.frame_speed = frame_speed
	return result

class Sprite extends Sprite2D:
	var width: int
	var height: int
	var atlas_left: int
	var atlas_top: int
	var frame_progress: float
	var animation: SpriteAnimation

	func _process(dt: float) -> void:
		# Update animation.
		if (animation):
			if not (animation.frame_count <= 1):
				frame_progress = fmod(frame_progress + animation.frame_speed * dt, animation.frame_count);
		# Update sprite.
		if width == 0 or height == 0: return
		var top := atlas_top + animation.frame_row * height if animation else 0
		var grid_width := int(max(texture.get_width() - atlas_left, 0) / width)
		var grid_height := int(max(texture.get_height() - top, 0) / height)
		if grid_width == 0 or grid_height == 0: return
		var row := int(frame() / float(grid_width))
		var col := frame() % grid_width
		var area := Rect2(atlas_left + col * width, top + row * height, width, height)
		region_enabled = true
		region_rect = area

	func has_first_frame() -> bool:
		return frame() == 0

	func has_last_frame() -> bool:
		if animation.frameCount != 0: return frame() == animation.frameCount - 1
		else: return true

	func size() -> Vector2:
		return Vector2(width, height)

	func frame() -> int:
		return int(frame_progress)

	func reset(reset_frame := 0) -> void:
		frame_progress = reset_frame

	func play(other: SpriteAnimation, can_keep_frame := false) -> void:
		if animation != other:
			if can_keep_frame: reset()
			animation = other

	func follow_position(to: Vector2, delta: Vector2) -> void:
		position = SashimiBasic.move_to(position, to, delta)

	func follow_position_with_slowdown(to: Vector2, delta: Vector2, slowdown: float) -> void:
		position = SashimiBasic.move_to_with_slowdown(position, to, delta, slowdown)

static func make_animated_sprite(path: String, width: int, height: int, atlas_left: int, atlas_top: int, animation: SpriteAnimation) -> Sprite:
	var result := Sprite.new()
	result.width = width
	result.height = height
	result.atlas_left = atlas_left
	result.atlas_top = atlas_top
	result.animation = animation
	result.texture = read(path)
	return result

static func add_animated_sprite(path: String, width: int, height: int, atlas_left: int, atlas_top: int, animation: SpriteAnimation) -> Sprite:
	return add_node(make_animated_sprite(path, width, height, atlas_left, atlas_top, animation))

static func make_sprite(path: String) -> Sprite:
	var result := make_animated_sprite(path, 0, 0, 0, 0, null)
	result.width = result.texture.get_width()
	result.height = result.texture.get_height()
	return result

static func add_sprite(path: String) -> Sprite:
	return add_node(make_sprite(path))

# ( Error Handling )

class Result extends RefCounted:
	var value: Variant
	var fault: int

	func is_none() -> bool:
		return fault != 0

	func is_some() -> bool:
		return fault == 0

	func take() -> Variant:
		if is_some():
			SashimiBasic.panic("Fault `{0}` was detected.".format([fault]))
		return value

	func take_or() -> Variant:
		return value

static func some(value) -> Result:
	var result := Result.new()
	result.value = value
	return result

static func none(fault := 1) -> Result:
	var result := Result.new()
	result.fault = fault
	return result

# ( Script )

static func is_script_ready() -> bool:
	return basic_state != null and basic_state.is_inside_tree()

static func ready_script(parent: Node) -> void:
	if basic_state != null and basic_state.is_inside_tree(): return
	basic_state = BasicState.new()
	basic_state.name = "sashimi_basic_state"
	parent.add_child(basic_state)

static func test_script() -> void:
	assert(none().is_none() == true);
	assert(none().is_some() == false);
	assert(none().take_or() == null);
	assert(some(9).is_none() == false);
	assert(some(9).is_some() == true);
	assert(some(9).take_or() == 9);

