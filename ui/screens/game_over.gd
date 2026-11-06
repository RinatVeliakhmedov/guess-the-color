class_name GameOverScreen
extends Control
## Summary card shown over the last round when the player runs out of lives.

signal play_again_requested
signal menu_requested

const INPUT_LOCK := 0.25

var active := false
var _since := 0.0

@onready var score_label: Label = %Score
@onready var best_label: Label = %Best
@onready var rounds_stat: Stat = %Rounds
@onready var streak_stat: Stat = %BestStreak
@onready var all_time_stat: Stat = %AllTime
@onready var mode_label: Label = %Mode
@onready var again_button: Button = %Again
@onready var menu_button: Button = %Menu


func _ready() -> void:
	again_button.pressed.connect(play_again_requested.emit)
	menu_button.pressed.connect(menu_requested.emit)


## d: score, new_best, best_score, rounds, best_streak, all_time_streak, mode
func show_summary(d: Dictionary) -> void:
	score_label.text = Rules.fmt(d["score"])
	if d["new_best"]:
		best_label.text = "New best score!"
		best_label.theme_type_variation = &"Highlight"
	else:
		best_label.text = "Best " + Rules.fmt(d["best_score"])
		best_label.theme_type_variation = &"BodyDim"
	rounds_stat.value = str(d["rounds"])
	streak_stat.value = str(d["best_streak"])
	all_time_stat.set_value(str(d["all_time_streak"]), UIColors.TEXT_DIM)
	mode_label.text = d["mode"]
	_since = 0.0
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.3)


func _process(delta: float) -> void:
	_since += delta


func _unhandled_input(event: InputEvent) -> void:
	if not active or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.is_action_pressed("g_confirm") and _since > INPUT_LOCK:
		play_again_requested.emit()
	elif event.is_action_pressed("g_back"):
		menu_requested.emit()
	else:
		return
	get_viewport().set_input_as_handled()
