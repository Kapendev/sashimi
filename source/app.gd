extends Node

const core  := preload("sashimi/core.gd")
const icon  := preload("../icon.svg")
const scene := preload("scene.tscn")

var sprite: core.Sprite
var map: core.Map

func _ready() -> void:
	core.ready_script(self)
	core.test_script()
	map = core.add_map(icon, 32, 32)
	map.parse(core.read("map.txt"))
	sprite = core.add_animated_sprite(icon, 64, 64, 0, 0, 0, 4, 2)

func _process(dt: float) -> void:
	if core.is_just_pressed("q"): core.quit()
	sprite.update(dt)
	core.follow_position_with_slowdown(sprite, core.mouse(), Vector2(dt, dt), 0.2)
	core.follow_position_with_slowdown(map, core.mouse(), Vector2(dt, dt), 1.0)
	core.draw_rect(Rect2(32, 32, 32, 32), Color.SKY_BLUE)
