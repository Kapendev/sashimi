static var utils_node: UtilsNode

const int_min   := -9223372036854775808
const int_max   := 9223372036854775807
const float_min := -1.79769e308
const float_max := 1.79769e308

class UtilsNode extends Node:
	var time: float
	var tick_count: int

	func _process(dt: float) -> void:
		time = fmod((time + dt), float_max)
		tick_count = (tick_count + 1) % int_max

static func elapsed_time() -> float:
	check_script()
	return utils_node.time

static func elapsed_tick_count() -> float:
	check_script()
	return utils_node.tick_count

static func resolution_width() -> int:
	check_script()
	return utils_node.get_tree().get_root().content_scale_size.x

static func resolution_height() -> int:
	check_script()
	return utils_node.get_tree().get_root().content_scale_size.y

static func resolution() -> int:
	check_script()
	return utils_node.get_tree().get_root().content_scale_size.y

static func mouse_screen_position() -> Vector2:
	check_script()
	return utils_node.get_viewport().get_mouse_position()

static func mouse_world_position() -> Vector2:
	check_script()
	return utils_node.get_global_mouse_position()

static func is_script_ready() -> bool:
	return utils_node != null and utils_node.is_inside_tree()

static func check_script() -> void:
	assert(is_script_ready(), "Script is not ready. Call `ready_script` before using this function.")

static func ready_script(parent: Node) -> void:
	if utils_node != null and utils_node.is_inside_tree(): return
	utils_node = UtilsNode.new()
	utils_node.name = "sashimi_utils_node"
	parent.add_child(utils_node)

static func test_script() -> void:
	pass

