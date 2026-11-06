@tool
class_name Triangle
extends Control
## A small filled arrowhead, centered in the control. Used for option arrows
## and arrow-key caps (the default font has no arrow glyphs).

@export var direction := Vector2.RIGHT:
	set(v):
		direction = v
		queue_redraw()
@export var color := Color.WHITE:
	set(v):
		color = v
		queue_redraw()
@export var radius := 6.0:
	set(v):
		radius = v
		queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var d := direction.normalized()
	var p := d.orthogonal()
	draw_colored_polygon(PackedVector2Array([
		c + d * radius,
		c - d * radius * 0.6 + p * radius * 0.9,
		c - d * radius * 0.6 - p * radius * 0.9,
	]), color)
