@tool
class_name OptionRow
extends PanelContainer
## A menu setting: title and description on the left, ‹ value › on the right.
## Clicking the left arrow side steps back, anywhere else steps forward.

signal changed(delta: int)

@export var title := "Option":
	set(v):
		title = v
		if is_node_ready():
			_title.text = v
@export var selected := false:
	set(v):
		selected = v
		if is_node_ready():
			_apply_selected()

@onready var _title: Label = %Title
@onready var _info: Label = %Info
@onready var _value: Label = %Value
@onready var _left: Triangle = %Left
@onready var _right: Triangle = %Right


func _ready() -> void:
	_title.text = title
	_apply_selected()


func set_value(value: String, info: String) -> void:
	_value.text = value
	_info.text = info


func _apply_selected() -> void:
	self_modulate.a = 1.0 if selected else 0.0
	_title.add_theme_color_override("font_color", UIColors.TEXT if selected else UIColors.TEXT_DIM)
	_info.add_theme_color_override("font_color", UIColors.TEXT_DIM if selected else UIColors.TEXT_FAINT)
	_value.add_theme_color_override("font_color", UIColors.TEXT if selected else UIColors.TEXT_DIM)
	_left.color = UIColors.ACCENT if selected else UIColors.LINE
	_right.color = _left.color


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var x: float = event.global_position.x
		var back := x > _left.get_global_rect().position.x - 16.0 and x < _value.get_global_rect().get_center().x
		changed.emit(-1 if back else 1)
		accept_event()
