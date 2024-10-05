# Sashimi

A utility library for the Godot Engine.
It provides basic data structures and functions that work without the editor.
Each script is standalone and can be easily copied into a project with no extra setup required.

```gd
extends Node

const basic = preload("res://source/sashimi/basic.gd")

var sprite: Sprite2D

func _ready() -> void:
	basic.ready_script(self)
	sprite = basic.add_sprite("../icon.svg")

func _process(dt: float) -> void:
	if basic.is_pressed("1"): basic.quit()
	if basic.is_pressed("2"): basic.panic("An error occurred.")
	sprite.follow_position_with_slowdown(basic.mouse_screen_position(), basic.to_v2(dt), 0.3)
```

> [!WARNING]
> This is alpha software. Use it only if you are very cool.

## Examples

Look at the [app.gd](source/app.gd) file.

## Note

I add things to Sashimi when I need them and I support only Godot 4.

## License

The project is released under the terms of the MIT License.
Please refer to the LICENSE file.
