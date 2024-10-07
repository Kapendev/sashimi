extends Node

const basic = preload("res://source/sashimi/basic.gd")

var can_follow: bool
var animation1: basic.SpriteAnimation
var animation2: basic.SpriteAnimation
var sprite: basic.Sprite

var map: basic.Map

func _ready() -> void:
	basic.test_script()
	basic.ready_script(self)
	print(basic.read("secret.txt"))

	var temp := basic.add_sliced_sprite("../icon.svg", 32, 32, 0, 0)
	temp.position = basic.resolution() * Vector2(0.5, 0.5)

	can_follow = true
	animation1 = basic.make_sprite_animation(0, 2, 4)
	animation2 = basic.make_sprite_animation(1, 2, 4)
	sprite = basic.add_animated_sprite("../icon.svg", 64, 64, 0, 0, animation1)

	map = basic.add_map("../icon.svg", 32, 32)

func _process(dt: float) -> void:
	if basic.is_just_pressed("q"): basic.quit()

	if basic.is_just_pressed("1"):
		map.put(0, 0, 0)
		map.put(0, 1, 1)
		map.put(0, 2, 2)
		map.put(0, 3, 3)
		map.put(1, 0, 4)
		map.put(1, 1, 5)
		map.put(1, 2, 6)
		map.put(1, 3, 7)

	var slowdown := 0.3
	var position_value := basic.mouse_world_position()
	var scale_value := basic.to_v2((position_value.x / basic.resolution_width()) * 2 + 1)
	if can_follow:
		sprite.follow_position_with_slowdown(position_value, Vector2(dt, dt), slowdown)
		sprite.follow_scale_with_slowdown(scale_value, Vector2(dt, dt), slowdown)
		map.position.x = basic.mouse_screen_position().x

	if sprite.has_point(basic.mouse_screen_position()):
		basic.draw_rect(Rect2(32, 32, 32, 32), Color.SKY_BLUE)
		sprite.play(animation2)
	else:
		basic.draw_rect(Rect2(32, 32, 32, 32), Color.WHITE)
		sprite.play(animation1)

	if basic.button(sprite):
		can_follow = not can_follow
		print("Pressed a button! ", basic.elapsed_tick_count())
