extends Node

const basic = preload("res://source/sashimi/basic.gd")

var animation1: basic.SpriteAnimation
var animation2: basic.SpriteAnimation
var sprite: basic.Sprite

func _ready() -> void:
	basic.test_script()
	basic.ready_script(self)

	animation1 = basic.make_sprite_animation(0, 2, 4)
	animation2 = basic.make_sprite_animation(1, 2, 4)
	sprite = basic.add_animated_sprite("../icon.svg", 64, 64, 0, 0, animation1)
	print(basic.read("secret.txt"))

func _process(dt: float) -> void:
	if basic.is_pressed("1"): basic.quit()
	if basic.is_pressed("2"): basic.panic("An error occurred.")

	var slowdown := 0.3
	var position_value := basic.mouse_world_position()
	var scale_value := basic.to_v2((position_value.x / basic.resolution_width()) * 2 + 1)
	basic.follow_position_with_slowdown(sprite, position_value, basic.to_v2(dt), slowdown)
	basic.follow_scale_with_slowdown(sprite, scale_value, basic.to_v2(dt), slowdown)

	if basic.has_point(sprite, basic.mouse_screen_position()):
		basic.draw_rect(Rect2(32, 32, 32, 32), Color.SKY_BLUE)
		sprite.play(animation2)
	else:
		basic.draw_rect(Rect2(32, 32, 32, 32), Color.WHITE)
		sprite.play(animation1)
