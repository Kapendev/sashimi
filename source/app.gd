extends Node

const core  := preload("sashimi/core.gd")
const icon  := preload("../icon.svg")

var sprite: core.Sprite
var map: core.Map

func _ready() -> void:
	# Ready and test the script.
	core.ready_script(self)
	core.test_script()
	# Create a sprite and a map.
	sprite = core.add_animated_sprite(icon, 64, 64, 0, 0, 0, 4, 2)
	sprite.scale = Vector2(2, 2)
	map = core.add_map(icon, 32, 32)
	map.read_and_parse("map.txt")

func _process(dt: float) -> void:
	if core.is_just_pressed("q"): core.quit()
	sprite.update(dt)
	core.follow_position_with_slowdown(sprite, core.mouse(), Vector2(dt, dt), 0.1)
	core.draw_rect(Rect2(150, 32, 64, 64), Color.SKY_BLUE)
