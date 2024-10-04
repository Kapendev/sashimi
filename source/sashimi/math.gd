static func is_number_type(value) -> bool:
	return value is int or value is float

static func is_vector_type(value) -> bool:
	return value is Vector2 or value is Vector3 or value is Vector4

static func type_error_message() -> String:
	return "Function does not support the given type."

static func to_v2(value) -> Vector2:
	if value is bool:
		var temp := 1 if value else 0
		return Vector2(temp, temp)
	elif is_number_type(value):
		return Vector2(value, value)
	else:
		@warning_ignore("assert_always_false")
		assert(0, type_error_message())
		return Vector2()

static func to_v3(value) -> Vector3:
	if value is bool:
		var temp := 1 if value else 0
		return Vector3(temp, temp, temp)
	elif is_number_type(value):
		return Vector3(value, value, value)
	else:
		@warning_ignore("assert_always_false")
		assert(0, type_error_message())
		return Vector3()

static func to_v4(value) -> Vector4:
	if value is bool:
		var temp := 1 if value else 0
		return Vector4(temp, temp, temp, temp)
	elif is_number_type(value):
		return Vector4(value, value, value, value)
	else:
		@warning_ignore("assert_always_false")
		assert(0, type_error_message())
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
		@warning_ignore("assert_always_false")
		assert(0, type_error_message())
		return 0.0

static func move_to_with_slowdown(from, to, delta, slowdown) -> Variant:
	if not (slowdown is float):
		@warning_ignore("assert_always_false")
		assert(0, type_error_message())
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
		@warning_ignore("assert_always_false")
		assert(0, type_error_message())
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

static func test_script() -> void:
	pass

