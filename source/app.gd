extends Node

const faults = preload("res://source/sashimi/faults.gd")
const math = preload("res://source/sashimi/math.gd")
const utils = preload("res://source/sashimi/utils.gd")

var sprite: Sprite2D
var target: Vector2

func _ready() -> void:
	# Test scripts.
	faults.test_script()
	math.test_script()
	utils.test_script()
	# Have some fun.
	utils.ready_script(self)
	sprite = get_node("sprite")

func _process(dt: float) -> void:
	# Have some fun (again).
	var slowdown := 0.3
	var position_value := utils.mouse_screen_position()
	var rotation_value := sin(utils.elapsed_time() * 3)
	var scale_value := math.to_v2((position_value.x / utils.resolution_width()) * 2 + 1)

	math.follow_position_with_slowdown(sprite, position_value, math.to_v2(dt), slowdown)
	math.follow_scale_with_slowdown(sprite, scale_value, math.to_v2(dt), slowdown)
	math.follow_rotation_with_slowdown(sprite, rotation_value, dt, slowdown)
