@tool
class_name Stat
extends VBoxContainer
## Small caption above a bold value, used in the HUD and on the game-over card.

@export var caption := "STAT":
	set(v):
		caption = v
		if is_node_ready():
			_caption.text = v
@export var value := "0":
	set(v):
		value = v
		if is_node_ready():
			_value.text = v
@export var alignment_h := HORIZONTAL_ALIGNMENT_LEFT:
	set(v):
		alignment_h = v
		if is_node_ready():
			_apply_alignment()

@onready var _caption: Label = %Caption
@onready var _value: Label = %Value


func _ready() -> void:
	_caption.text = caption
	_value.text = value
	_apply_alignment()


func set_value(text: String, color := UIColors.TEXT) -> void:
	value = text
	_value.add_theme_color_override("font_color", color)


func _apply_alignment() -> void:
	_caption.horizontal_alignment = alignment_h
	_value.horizontal_alignment = alignment_h
