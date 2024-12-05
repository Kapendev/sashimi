# ---
# Copyright 2024 Alexandros F. G. Kapretsos
# SPDX-License-Identifier: MIT
# Email: alexandroskapretsos@gmail.com
# Project: https://github.com/Kapendev/sashimi
# Version: v0.0.1
# ---

extends RefCounted
class_name SashimiCore

static var core_state: CoreState
static var result_buffer: Result

const MIN_INT   := -9223372036854775808
const MAX_INT   := 9223372036854775807
const MIN_FLOAT := -1.79769e308
const MAX_FLOAT := 1.79769e308

const GRAY1 := Color("202020")
const GRAY2 := Color("606060")
const GRAY3 := Color("9f9f9f")
const GRAY4 := Color("dfdfdf")

const DIGIT_CHARS := "0123456789"
const UPPER_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const LOWER_CHARS := "abcdefghijklmnopqrstuvwxyz"
const ALPHA_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

const TYPE_ERROR_MESSAGE := "Function does not support the given type."
const MAP_ERROR_MESSAGE := "Tile does not exist."

const DEFAULT_ASSETS_PATH := "res://assets/"
const TEXT_FILE_TYPES := ["txt", "ini", "sv", "md"]

# ( General Utilities )

class CoreState extends Node2D:
	var elapsed_time: float
	var elapsed_tick_count: int
	var shapes: Array[Rect2]
	var colors: Array[Color]
	var assets_path: String

	func _ready() -> void:
		assets_path = DEFAULT_ASSETS_PATH
		z_index = 999
		# Ready input keys.
		if not InputMap.has_action("0"):
			for c: String in DIGIT_CHARS:
				var event := InputEventKey.new()
				@warning_ignore("int_as_enum_without_cast")
				event.keycode = c.unicode_at(0)
				InputMap.add_action(c)
				InputMap.action_add_event(c, event)
			for c: String in UPPER_CHARS:
				var event := InputEventKey.new()
				@warning_ignore("int_as_enum_without_cast")
				event.keycode = c.unicode_at(0)
				InputMap.add_action(c)
				InputMap.action_add_event(c, event)
				InputMap.add_action(c.to_lower())
				InputMap.action_add_event(c.to_lower(), event)
			var esc_event := InputEventKey.new()
			esc_event.keycode = KEY_ESCAPE
			InputMap.add_action("esc")
			InputMap.action_add_event("esc", esc_event)
			var mouse_event1 := InputEventMouseButton.new()
			mouse_event1.button_index = MOUSE_BUTTON_LEFT
			InputMap.add_action("mouse_left")
			InputMap.action_add_event("mouse_left", mouse_event1)
			var mouse_event2 := InputEventMouseButton.new()
			mouse_event2.button_index = MOUSE_BUTTON_RIGHT
			InputMap.add_action("mouse_right")
			InputMap.action_add_event("mouse_right", mouse_event2)

	func _process(dt: float) -> void:
		elapsed_time = fmod((elapsed_time + dt), MAX_FLOAT)
		elapsed_tick_count = (elapsed_tick_count + 1) % MAX_INT
		if len(shapes) != 0: queue_redraw()

	func _draw() -> void:
		for i: int in range(len(shapes)): draw_rect(shapes[i], colors[i])
		shapes.clear()
		colors.clear()

static func is_number_type(value: Variant) -> bool:
	return value is int or value is float

static func is_vector_type(value: Variant) -> bool:
	return value is Vector2 or value is Vector3 or value is Vector4

static func quit() -> void:
	core_state.get_tree().quit()

static func panic(message: String) -> void:
	print(message)
	quit()
	@warning_ignore("assert_always_false")
	assert(0, message)

# TODO: Think about it. I only use it for text files. Also assets path in Godot is maybe weird.
# NOTE: There is also this thing about exporting and not including some files...
static func read(path: String) -> Variant:
	for type: String in TEXT_FILE_TYPES:
		if (path.ends_with(type)):
			var file := FileAccess.open(core_state.assets_path + path, FileAccess.READ)
			if file == null: return null
			return file.get_as_text()
	return load(core_state.assets_path + path)

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

static func move_to(from: Variant, to: Variant, delta: Variant) -> Variant:
	if from is float and to is float and delta is float:
		if abs(to - from) > abs(delta): return from + sign(to - from) * delta
		else: return to
	elif is_vector_type(from) and is_vector_type(to) and is_vector_type(delta):
		var result: Variant = from
		var offset: Variant = from.direction_to(to) * delta
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
		panic(TYPE_ERROR_MESSAGE)
		return 0.0

static func move_to_with_slowdown(from: Variant, to: Variant, delta: Variant, slowdown: float) -> Variant:
	if from is float and to is float and delta is float:
		if slowdown <= 0.0 or is_equal_approx(from, to): return to
		var target: float = ((from * (slowdown - 1.0)) + to) / slowdown
		var offset: float = target - from
		return from + offset * delta
	elif is_vector_type(from) and is_vector_type(to) and is_vector_type(delta):
		var result: Variant = from
		result.x = move_to_with_slowdown(from.x, to.x, delta.x, slowdown)
		result.y = move_to_with_slowdown(from.y, to.y, delta.y, slowdown)
		if from is Vector3:
			result.z = move_to_with_slowdown(from.z, to.z, delta.z, slowdown)
		if from is Vector4:
			result.w = move_to_with_slowdown(from.w, to.w, delta.w, slowdown)
		return result
	else:
		panic(TYPE_ERROR_MESSAGE)
		return 0.0

static func follow_position(object: Variant, to: Variant, delta: Variant) -> void:
	if object == null: return
	object.position = move_to(object.position, to, delta)

static func follow_rotation(object: Variant, to: Variant, delta: Variant) -> void:
	if object == null: return
	object.rotation = move_to(object.rotation, to, delta)

static func follow_scale(object: Variant, to: Variant, delta: Variant) -> void:
	if object == null: return
	object.scale = move_to(object.scale, to, delta)

static func follow_position_with_slowdown(object: Variant, to: Variant, delta: Variant, slowdown: float) -> void:
	if object == null: return
	object.position = move_to_with_slowdown(object.position, to, delta, slowdown)

static func follow_rotation_with_slowdown(object: Variant, to: Variant, delta: Variant, slowdown: float) -> void:
	if object == null: return
	object.rotation = move_to_with_slowdown(object.rotation, to, delta, slowdown)

static func follow_scale_with_slowdown(object: Variant, to: Variant, delta: Variant, slowdown: float) -> void:
	if object == null: return
	object.scale = move_to_with_slowdown(object.scale, to, delta, slowdown)

static func elapsed_time() -> float:
	return core_state.elapsed_time

static func elapsed_tick_count() -> float:
	return core_state.elapsed_tick_count

static func resolution_width() -> int:
	return core_state.get_tree().get_root().content_scale_size.x

static func resolution_height() -> int:
	return core_state.get_tree().get_root().content_scale_size.y

static func resolution() -> Vector2:
	return core_state.get_tree().get_root().content_scale_size

static func mouse() -> Vector2:
	return core_state.get_viewport().get_mouse_position()

static func world_mouse() -> Vector2:
	return core_state.get_global_mouse_position()

static func is_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

static func is_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)

static func is_released(action: String) -> bool:
	return Input.is_action_just_released(action)

static func wasd() -> Vector2:
	var result := Vector2()
	result.y -= (is_pressed("w") or is_pressed("ui_up")) as int
	result.x -= (is_pressed("a") or is_pressed("ui_left")) as int
	result.y += (is_pressed("s") or is_pressed("ui_down")) as int
	result.x += (is_pressed("d") or is_pressed("ui_right")) as int
	return result

static func wasd_just_pressed() -> Vector2:
	var result := Vector2()
	result.y -= (is_just_pressed("w") or is_just_pressed("ui_up")) as int
	result.x -= (is_just_pressed("a") or is_just_pressed("ui_left")) as int
	result.y += (is_just_pressed("s") or is_just_pressed("ui_down")) as int
	result.x += (is_just_pressed("d") or is_just_pressed("ui_right")) as int
	return result

static func wasd_released() -> Vector2:
	var result := Vector2()
	result.y -= (is_released("w") or is_released("ui_up")) as int
	result.x -= (is_released("a") or is_released("ui_left")) as int
	result.y += (is_released("s") or is_released("ui_down")) as int
	result.x += (is_released("d") or is_released("ui_right")) as int
	return result

static func draw_rect(shape: Rect2, color: Color) -> void:
	core_state.shapes.append(shape)
	core_state.colors.append(color)

static func add_child(node: Node, to: Node) -> Variant:
	if node.name.is_empty(): node.name = "node"
	else: node.name = node.name.to_lower()
	if node is Node2D: node.z_as_relative = false
	to.add_child(node, true)
	return node

static func add_node(node: Node) -> Variant:
	return add_child(node, core_state)

# ( Sprite )

class Sprite extends Sprite2D:
	var width: int
	var height: int
	var atlas_left: int
	var atlas_top: int
	
	var frame_progress: float
	var frame_row := 0
	var frame_count := 1
	var frame_speed := 6

	func update(dt: float) -> void:
		# Update animation.
		if (has_animation):
			if (frame_count > 1): frame_progress = fmod(frame_progress + frame_speed * dt, frame_count);
		# Update sprite.
		if width == 0 or height == 0: return
		var top := atlas_top + frame_row * height if has_animation() else 0
		var grid_width := int(max(texture.get_width() - atlas_left, 0) / width)
		var grid_height := int(max(texture.get_height() - top, 0) / height)
		if grid_width == 0 or grid_height == 0: return
		var row := int(frame() / float(grid_width))
		var col := frame() % grid_width
		var area := Rect2(atlas_left + col * width, top + row * height, width, height)
		region_enabled = true
		region_rect = area

	func has_animation() -> bool:
		return frame_count != 0

	func has_same_animation(other_frame_row: int, other_frame_count: int, other_frame_speed: int) -> bool:
		return frame_row == other_frame_row and frame_count == other_frame_count and frame_speed == other_frame_speed

	func has_first_frame() -> bool:
		return frame() == 0

	func has_last_frame() -> bool:
		if frame_count != 0: return frame() == frame_count - 1
		else: return true

	func size() -> Vector2:
		return Vector2(width, height)

	func frame() -> int:
		return int(frame_progress)

	func reset(reset_frame := 0) -> void:
		frame_progress = reset_frame

	func play(new_frame_row: int, new_frame_count: int, new_frame_speed: int, can_keep_frame := false) -> void:
		if not has_same_animation(new_frame_row, new_frame_count, new_frame_speed):
			if can_keep_frame: reset()
			frame_row = new_frame_row
			frame_count = new_frame_count
			frame_speed = new_frame_speed

	func has_point(point: Vector2) -> bool:
		return SashimiCore.has_point(self, point)

	func has_area(area: Rect2) -> bool:
		return SashimiCore.has_area(self, area)

static func make_animated_sprite(texture: Texture2D, width: int, height: int, atlas_left: int, atlas_top: int, frame_row: int, frame_count: int, frame_speed: int) -> Sprite:
	var result := Sprite.new()
	result.name = "sprite"
	result.width = width
	result.height = height
	result.atlas_left = atlas_left
	result.atlas_top = atlas_top
	result.frame_row = frame_row
	result.frame_count = frame_count
	result.frame_speed = frame_speed
	result.texture = texture
	return result

static func make_sliced_sprite(texture: Texture2D, width: int, height: int, atlas_left: int, atlas_top: int) -> Sprite:
	return make_animated_sprite(texture, width, height, atlas_left, atlas_top, 0, 0, 0)

static func make_sprite(texture: Texture2D) -> Sprite:
	var result := make_animated_sprite(texture, 0, 0, 0, 0, 0, 0, 0)
	result.width = result.texture.get_width()
	result.height = result.texture.get_height()
	return result

static func add_animated_sprite(texture: Texture2D, width: int, height: int, atlas_left: int, atlas_top: int, frame_row: int, frame_count: int, frame_speed: int) -> Sprite:
	return add_node(make_animated_sprite(texture, width, height, atlas_left, atlas_top, frame_row, frame_count, frame_speed))

static func add_sliced_sprite(texture: Texture2D, width: int, height: int, atlas_left: int, atlas_top: int) -> Sprite:
	return add_node(make_sliced_sprite(texture, width, height, atlas_left, atlas_top))

static func add_sprite(texture: Texture2D) -> Sprite:
	return add_node(make_sprite(texture))

# ( Tile Map )

class Map extends Node2D:
	var tiles: PackedInt32Array
	var tile_width: int
	var tile_height: int
	var texture: Texture2D
	var estimated_max_row_count: int
	var estimated_max_col_count: int
	const max_row_count := 128
	const max_col_count := 128

	# TODO: Maybe make it work with a camera.
	func _draw() -> void:
		var texture_grid_width := int(texture.get_width() / float(tile_width))
		var texture_grid_height := int(texture.get_height() / float(tile_height))
		if texture_grid_width == 0 or texture_grid_height == 0: return
		var i := 0
		for tile in tiles:
			if i == length():
				break
			if tile == -1:
				i += 1
				continue
			var texture_grid_row := int(tile / float(texture_grid_width))
			var texture_grid_col := tile % texture_grid_height
			var texture_area := Rect2(texture_grid_col * tile_width, texture_grid_row * tile_height, tile_width, tile_height)
			var map_grid_row := int(i / float(max_col_count))
			var map_grid_col := i % max_col_count
			var map_area := Rect2(map_grid_col * tile_width, map_grid_row * tile_height, tile_width, tile_height)
			draw_texture_rect_region(texture, map_area, texture_area, modulate)
			i += 1

	func length() -> int:
		return max_row_count * max_col_count

	func has(row: int, col: int) -> bool:
		return row >= 0 and row < max_row_count and col >= 0 and col < max_col_count

	func take(row: int, col: int) -> int:
		if not has(row, col): SashimiCore.panic(MAP_ERROR_MESSAGE)
		return tiles[max_col_count * row + col]

	func put(value: int, row: int, col: int) -> void:
		if not has(row, col): SashimiCore.panic(MAP_ERROR_MESSAGE)
		tiles[max_col_count * row + col] = value
		queue_redraw()

	func fill(value: int) -> void:
		for i in range(0, len(tiles)):
			tiles[i] = value

	# TODO: Not done yet.
	func parse(csv: String) -> void:
		fill(-1)
		estimated_max_row_count = 0
		estimated_max_col_count = 0
		for line: String in csv.rsplit("\n"):
			if len(line) == 0: continue
			estimated_max_row_count += 1
			estimated_max_col_count = 0
			for value: String in line.rsplit(","):
				estimated_max_col_count += 1
				if value.is_valid_int(): put(value.to_int(), estimated_max_row_count - 1, estimated_max_col_count - 1)
				else: return

static func make_map(texture: Texture2D, tile_width: int, tile_height: int) -> Map:
	var result := Map.new()
	result.name = "map"
	result.tile_width = tile_width
	result.tile_height = tile_height
	result.texture = texture
	result.tiles = []
	for i: int in range(result.max_row_count * result.max_col_count):
		result.tiles.append(-1)
	return result

static func add_map(texture: Texture2D, tile_width: int, tile_height: int) -> Map:
	return add_node(make_map(texture, tile_width, tile_height))

# ( GUI )

# TODO: Will be funny if it works.
static func button(object: Variant) -> bool:
	var is_rect := true
	var area := Rect2()
	if object is Rect2:
		area = object
	elif object is Sprite2D:
		area = take_area(object)
		is_rect = false
	else:
		panic(TYPE_ERROR_MESSAGE)
	# Update.
	var is_hot := area.has_point(mouse())
	var is_active := is_hot and is_pressed("mouse_left")
	var is_clicked := is_hot and is_just_pressed("mouse_left")
	# Draw.
	if is_rect:
		if is_active: draw_rect(area, GRAY2)
		elif is_hot: draw_rect(area, GRAY4)
		else: draw_rect(area, GRAY3)
	return is_clicked

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
			SashimiCore.panic("Fault `{0}` was detected.".format([fault]))
		return value

	func take_or() -> Variant:
		return value

static func some(value: Variant) -> Result:
	result_buffer.value = value
	result_buffer.fault = 0
	return result_buffer

static func none(fault := 1) -> Result:
	result_buffer.value = null
	result_buffer.fault = fault
	return result_buffer

# ( Script )

static func is_script_ready() -> bool:
	return core_state != null

static func ready_script(parent: Node) -> void:
	if is_script_ready(): return
	core_state = CoreState.new()
	core_state.name = "sashimi_core_state"
	parent.add_child(core_state)
	result_buffer = Result.new()

static func test_script() -> void:
	assert(none().is_none() == true);
	assert(none().is_some() == false);
	assert(none().take_or() == null);
	assert(some(9).is_none() == false);
	assert(some(9).is_some() == true);
	assert(some(9).take_or() == 9);

