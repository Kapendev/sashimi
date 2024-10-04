extends Node

const basic = preload("res://source/sashimi/basic.gd")

var sprite: Sprite2D
var target: Vector2
var color: ColorRect

func _ready() -> void:
	basic.test_script()
	basic.ready_script(self)
	sprite = get_node("sprite")
	color = get_node("color")
	print(basic.read("secret.txt"))

func _process(dt: float) -> void:
	if basic.is_down("1"): basic.quit()
	if basic.is_down("2"): basic.panic("An error occurred.")

	if (basic.wasd()): print("WASD keys: ", basic.wasd())
	color.visible = basic.has_point(sprite, basic.mouse_screen_position())

	var slowdown := 0.3
	var position_value := basic.mouse_world_position()
	var scale_value := basic.to_v2((position_value.x / basic.resolution_width()) * 2 + 1)
	basic.follow_position_with_slowdown(sprite, position_value, basic.to_v2(dt), slowdown)
	basic.follow_scale_with_slowdown(sprite, scale_value, basic.to_v2(dt), slowdown)

