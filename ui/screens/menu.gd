class_name MenuScreen
extends Control
## Title screen with the three settings and the Start button.

signal start_requested
signal setting_changed(row: int, delta: int)

const START_ROW := 3

var active := false
var selected := START_ROW
var _t := 0.0

@onready var rows: Array[OptionRow] = [%Difficulty, %Colors, %Timer]
@onready var start_button: Button = %StartButton
@onready var best_label: Label = %BestLabel
@onready var chips: Array[Node] = %Chips.get_children()


func _ready() -> void:
	for i in rows.size():
		rows[i].changed.connect(func(d: int) -> void:
			_select(i)
			setting_changed.emit(i, d))
		rows[i].mouse_entered.connect(_select.bind(i))
	start_button.pressed.connect(start_requested.emit)
	start_button.mouse_entered.connect(_select.bind(START_ROW))
	_select(selected)


func refresh(p: Progress) -> void:
	var diff: Dictionary = Rules.DIFFICULTIES[p.difficulty]
	rows[0].set_value(diff["name"], "Match with at least %d%% accuracy" % int(diff["need"]))
	rows[1].set_value(Rules.SETS[p.colors], Rules.SET_INFO[p.colors])
	var t: float = Rules.TIMERS[p.timer]
	if t == 0.0:
		rows[2].set_value("Off", "No time limit")
	else:
		rows[2].set_value("%d s" % int(t), "%d seconds per color" % int(t))
	var b := p.best()
	if int(b["score"]) > 0 or int(b["streak"]) > 0:
		best_label.text = "Best score %s   ·   Best streak %d" % [Rules.fmt(int(b["score"])), int(b["streak"])]
	else:
		best_label.text = "No score yet for this mode"


func _select(i: int) -> void:
	selected = i
	for j in rows.size():
		rows[j].selected = j == i
	start_button.theme_type_variation = &"PrimaryButton" if i == START_ROW else &""


func _process(delta: float) -> void:
	if not visible:
		return
	# A slowly drifting row of swatches as a quiet logo.
	_t += delta
	for i in chips.size():
		(chips[i] as CanvasItem).self_modulate = Color.from_hsv(fposmod(0.02 + i * 0.13 + _t * 0.015, 1.0), 0.42, 0.88)


func _unhandled_input(event: InputEvent) -> void:
	if not active or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.is_action_pressed("g_up"):
		_select(wrapi(selected - 1, 0, START_ROW + 1))
	elif event.is_action_pressed("g_down"):
		_select(wrapi(selected + 1, 0, START_ROW + 1))
	elif event.is_action_pressed("g_left") and selected < START_ROW:
		setting_changed.emit(selected, -1)
	elif event.is_action_pressed("g_right") and selected < START_ROW:
		setting_changed.emit(selected, 1)
	elif event.is_action_pressed("g_confirm"):
		start_requested.emit()
	else:
		return
	get_viewport().set_input_as_handled()
