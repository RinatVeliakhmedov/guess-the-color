@tool
class_name Swatch
extends PanelContainer
## A large rounded color block with a caption and an optional detail line.
## The panel style is white; the color is applied with self_modulate.

@export var color := Color(0.5, 0.5, 0.5):
	set(v):
		color = v
		self_modulate = v
		if is_node_ready():
			_apply_ink()
@export var caption := "TARGET":
	set(v):
		caption = v
		if is_node_ready():
			_caption.text = v
@export var detail := "":
	set(v):
		detail = v
		if is_node_ready():
			_detail.text = v

@onready var _caption: Label = %Caption
@onready var _detail: Label = %Detail


func _ready() -> void:
	self_modulate = color
	_caption.text = caption
	_detail.text = detail
	_apply_ink()


func _apply_ink() -> void:
	var ink := UIColors.ink_on(color)
	_caption.add_theme_color_override("font_color", ink)
	_detail.add_theme_color_override("font_color", ink)
