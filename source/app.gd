extends Node

const core  := preload("sashimi/core.gd")
const icon  := preload("../icon.svg")
const scene := preload("scene.tscn")

var sprite: core.Sprite
var map: core.Map

func _ready() -> void:
	core.ready_script(self)
	sprite = core.add_sprite(icon)
	map = core.add_map(icon, 32, 32)
	map.parse(core.read("map.txt"))
	core.print_current_scene()

func _process(dt: float) -> void:
	if core.is_just_pressed("q"): core.quit()
	if core.is_just_pressed("e"): core.change_scene(scene)
	core.draw_rect(Rect2(32, 32, 32, 32), Color.SKY_BLUE)
	core.follow_position_with_slowdown(
		sprite,
		core.mouse_screen_position(),
		core.to_v2(dt),
		0.2,
	)
	core.follow_position_with_slowdown(
		map,
		core.mouse_screen_position(),
		core.to_v2(dt),
		1.0,
	)
