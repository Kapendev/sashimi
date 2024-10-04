extends Node

const basic = preload("res://source/sashimi/basic.gd")

var sprite: Sprite2D
var target: Vector2

func _ready() -> void:
	basic.test_script()
	basic.ready_script(self)
	sprite = get_node("sprite")

func _process(dt: float) -> void:
	var slowdown := 0.3
	var position_value := basic.mouse_screen_position()
	var rotation_value := sin(basic.elapsed_time() * 3)
	var scale_value := basic.to_v2((position_value.x / basic.resolution_width()) * 2 + 1)

	basic.follow_position_with_slowdown(sprite, position_value, basic.to_v2(dt), slowdown)
	basic.follow_scale_with_slowdown(sprite, scale_value, basic.to_v2(dt), slowdown)
	basic.follow_rotation_with_slowdown(sprite, rotation_value, dt, slowdown)

	print("WASD keys: ", basic.wasd())
	if basic.is_down("0"): basic.quit()
	if basic.is_down("1"): basic.panic("An error occurred.")
