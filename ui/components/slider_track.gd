@tool
class_name SliderTrack
extends Control
## The custom-drawn part of an RGB slider: a gradient pill showing what this
## channel would do to the current color, plus a knob filled with that color.

const TRACK_HEIGHT := 10.0

@export var from_color := Color.BLACK:
	set(v):
		from_color = v
		queue_redraw()
@export var to_color := Color.RED:
	set(v):
		to_color = v
		queue_redraw()
@export var knob_color := Color.GRAY:
	set(v):
		knob_color = v
		queue_redraw()
@export_range(0.0, 255.0) var value := 128.0:
	set(v):
		value = v
		queue_redraw()
@export var active := false:
	set(v):
		active = v
		queue_redraw()


## Channel value (0-255) under a local x position.
func value_at(x: float) -> int:
	return clampi(roundi(x / maxf(size.x, 1.0) * 255.0), 0, 255)


func _draw() -> void:
	var t := Rect2(0.0, (size.y - TRACK_HEIGHT) * 0.5, size.x, TRACK_HEIGHT)
	_capsule(t.grow(2.0), UIColors.LINE, UIColors.LINE)
	_capsule(t, from_color, to_color)
	var k := Vector2(size.x * value / 255.0, size.y * 0.5)
	var r := 13.0 if active else 10.0
	draw_circle(k, r, Color(1, 1, 1, 0.95 if active else 0.55), true, -1.0, true)
	draw_circle(k, r - 3.0, knob_color, true, -1.0, true)


func _capsule(t: Rect2, c0: Color, c1: Color) -> void:
	var rad := t.size.y * 0.5
	var cy := t.get_center().y
	var x0 := t.position.x + rad
	var x1 := t.end.x - rad
	draw_circle(Vector2(x0, cy), rad, c0, true, -1.0, true)
	draw_circle(Vector2(x1, cy), rad, c1, true, -1.0, true)
	draw_polygon(
		PackedVector2Array([Vector2(x0, t.position.y), Vector2(x1, t.position.y), Vector2(x1, t.end.y), Vector2(x0, t.end.y)]),
		PackedColorArray([c0, c1, c1, c0]))
