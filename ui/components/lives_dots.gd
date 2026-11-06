@tool
class_name LivesDots
extends Control
## Filled dots for remaining lives, hollow rings for lost ones.

@export var max_lives := 3:
	set(v):
		max_lives = v
		update_minimum_size()
		queue_redraw()
@export var lives := 3:
	set(v):
		lives = v
		queue_redraw()
@export var spacing := 20.0


func _get_minimum_size() -> Vector2:
	return Vector2(max_lives * spacing, 14.0)


func _draw() -> void:
	for i in max_lives:
		var p := Vector2(size.x * 0.5 + (i - (max_lives - 1) * 0.5) * spacing, size.y * 0.5)
		if i < lives:
			draw_circle(p, 5.5, UIColors.TEXT, true, -1.0, true)
		else:
			draw_circle(p, 5.0, UIColors.LINE, false, 1.5, true)
