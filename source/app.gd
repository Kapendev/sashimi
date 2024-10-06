extends Node

const basic = preload("res://source/sashimi/basic.gd")

var animation1: basic.SpriteAnimation
var animation2: basic.SpriteAnimation
var sprite: basic.Sprite

func _ready() -> void:
	basic.test_script()
	basic.ready_script(self)
	print(basic.read("secret.txt"))

	var temp := basic.add_sliced_sprite("../icon.svg", 32, 32, 0, 0)
	temp.position = basic.resolution() * Vector2(0.5, 0.5)

	animation1 = basic.make_sprite_animation(0, 2, 4)
	animation2 = basic.make_sprite_animation(1, 2, 4)
	sprite = basic.add_animated_sprite("../icon.svg", 64, 64, 0, 0, animation1)

func _process(dt: float) -> void:
	if basic.is_just_pressed("q"): basic.quit()

	var slowdown := 0.3
	var position_value := basic.mouse_world_position()
	var scale_value := basic.to_v2((position_value.x / basic.resolution_width()) * 2 + 1)
	sprite.follow_position_with_slowdown(position_value, Vector2(dt, dt), slowdown)
	sprite.follow_scale_with_slowdown(scale_value, Vector2(dt, dt), slowdown)

	if basic.has_point(sprite, basic.mouse_screen_position()):
		basic.draw_rect(Rect2(32, 32, 32, 32), Color.SKY_BLUE)
		sprite.play(animation2)
	else:
		basic.draw_rect(Rect2(32, 32, 32, 32), Color.WHITE)
		sprite.play(animation1)

	if basic.button(Rect2(100, 32, 32, 32)):
		print("Pressed a button! ", basic.elapsed_tick_count())
