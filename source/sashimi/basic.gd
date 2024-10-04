extends RefCounted
class_name SashimiBasic

static var basic_state: BasicState

const int_min   := -9223372036854775808
const int_max   := 9223372036854775807
const float_min := -1.79769e308
const float_max := 1.79769e308

const type_error_message := "Function does not support the given type."

# ( General Utilities )

class BasicState extends Node:
	var time: float
	var tick_count: int

	func _process(dt: float) -> void:
		time = fmod((time + dt), float_max)
		tick_count = (tick_count + 1) % int_max

static func is_number_type(value) -> bool:
	return value is int or value is float

static func is_vector_type(value) -> bool:
	return value is Vector2 or value is Vector3 or value is Vector4

static func quit() -> void:
	basic_state.get_tree().quit()

static func panic(message: String) -> void:
	print(message)
	quit()

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

static func is_down(key: String) -> bool:
	if len(key) != 1:
		panic("String is not a valid key. Length must be 1.")
		return false
	var target := key.to_upper().unicode_at(0)
	return Input.is_physical_key_pressed(target)

static func wasd() -> Vector2:
	var result := Vector2()
	if is_down("w") or Input.is_action_pressed("ui_up"): result.y += -1
	if is_down("a") or Input.is_action_pressed("ui_left"): result.x += -1
	if is_down("s") or Input.is_action_pressed("ui_down"): result.y += 1
	if is_down("d") or Input.is_action_pressed("ui_right"): result.x += 1
	return result

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

