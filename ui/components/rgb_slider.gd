class_name RgbSlider
extends PanelContainer
## One channel row: label, gradient track and value. Click or drag anywhere
## on the row to set the value; keyboard input is handled by the game screen.

signal picked(channel: int, value: int)

@export_range(0, 2) var channel := 0

var _value := 128
var _display := 128.0
var _dragging := false

@onready var _label: Label = %Channel
@onready var _track: SliderTrack = %Track
@onready var _value_label: Label = %Value


func _ready() -> void:
	_label.text = Rules.CHANNELS[channel]


func show_state(rgb: Array, selected: bool) -> void:
	_value = rgb[channel]
	var a := rgb.duplicate()
	a[channel] = 0
	_track.from_color = Rules.to_color(a)
	a[channel] = 255
	_track.to_color = Rules.to_color(a)
	_track.knob_color = Rules.to_color(rgb)
	_track.active = selected
	_value_label.text = str(_value)
	self_modulate.a = 1.0 if selected else 0.0
	_label.add_theme_color_override("font_color", UIColors.CHANNEL_TINT[channel] if selected else UIColors.TEXT_FAINT)
	_value_label.add_theme_color_override("font_color", UIColors.TEXT if selected else UIColors.TEXT_DIM)


## Jump the knob to its value instead of easing there.
func snap() -> void:
	_display = _value
	_track.value = _display


func _process(delta: float) -> void:
	_display = lerpf(_display, float(_value), 1.0 - exp(-delta * 25.0))
	_track.value = _display


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if event.pressed:
			_pick(event.global_position.x)
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_pick(event.global_position.x)
		accept_event()


func _pick(global_x: float) -> void:
	picked.emit(channel, _track.value_at(global_x - _track.get_global_rect().position.x))
