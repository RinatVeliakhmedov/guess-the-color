class_name GameScreen
extends Control
## One round: target and your color side by side, three sliders, the timer.
## Reports the guess with `submitted`; main.gd scores it and calls show_result().

signal submitted(rgb: Array, time_left: float, timed_out: bool)
signal continue_requested
signal menu_requested

const STEP := 5
const STEP_FINE := 1 # with Shift held
const REPEAT_DELAY := 0.28
const REPEAT_RATE := 0.03
const INPUT_LOCK := 0.25 # ignore confirm right after the result appears
const MAX_CONTENT_WIDTH := 1360.0
const SIDE_MARGIN := 32

var active := false
var playing := false # false while the result is shown
var rgb := [128, 128, 128]
var sel := 0
var time_total := 0.0
var time_left := 0.0

var _since := 0.0
var _hold_dir := 0
var _hold_t := 0.0
var _score := 0
var _score_shown := 0.0
var _bar_fill: StyleBoxFlat

@onready var margin: MarginContainer = $Margin
@onready var score_stat: Stat = %Score
@onready var streak_stat: Stat = %Streak
@onready var best_stat: Stat = %Best
@onready var time_stat: Stat = %Time
@onready var need_stat: Stat = %Need
@onready var lives_dots: LivesDots = %LivesDots
@onready var timer_bar: ProgressBar = %TimerBar
@onready var target_swatch: Swatch = %Target
@onready var yours_swatch: Swatch = %Yours
@onready var sliders_box: Control = %Sliders
@onready var sliders: Array[RgbSlider] = [%R, %G, %B]
@onready var result_panel: ResultPanel = %Result
@onready var action_button: Button = %ActionButton
@onready var action_title: Label = %ActionTitle
@onready var action_keys: Label = %ActionKeys
@onready var play_hints: Control = %PlayHints
@onready var result_hints: Control = %ResultHints


func _ready() -> void:
	for s in sliders:
		s.picked.connect(_on_picked)
	action_button.pressed.connect(_on_action)
	# Own copy of the fill style so its color can follow the remaining time.
	_bar_fill = (timer_bar.get_theme_stylebox("fill") as StyleBoxFlat).duplicate()
	timer_bar.add_theme_stylebox_override("fill", _bar_fill)
	resized.connect(_fit_width)
	_fit_width()


func start_round(target: Array, total_time: float) -> void:
	rgb = [128, 128, 128]
	sel = 0
	time_total = total_time
	time_left = total_time
	playing = true
	_since = 0.0
	_hold_dir = 0
	target_swatch.color = Rules.to_color(target)
	target_swatch.caption = "TARGET"
	target_swatch.detail = ""
	yours_swatch.caption = "YOURS"
	yours_swatch.detail = ""
	sliders_box.show()
	result_panel.hide()
	play_hints.show()
	result_hints.hide()
	action_title.text = "Match"
	action_keys.text = "Enter  /  Space"
	_refresh()


## r: see ResultPanel.show_result(), plus target, target_name.
func show_result(r: Dictionary) -> void:
	playing = false
	_since = 0.0
	_hold_dir = 0
	sliders_box.hide()
	result_panel.show()
	result_panel.show_result(r)
	play_hints.hide()
	result_hints.show()
	action_title.text = "Next" if r["lives"] > 0 else "Results"
	action_keys.text = "Enter  /  Space"
	var target_name: String = r["target_name"]
	target_swatch.caption = "TARGET" if target_name == "" else "TARGET  ·  " + target_name.to_upper()
	target_swatch.detail = Rules.hex(r["target"])
	yours_swatch.detail = Rules.hex(rgb)


func set_hud(score: int, streak: int, best: int, lives: int, need: float) -> void:
	_score = score
	streak_stat.set_value(str(streak), UIColors.WARN if streak >= 3 else UIColors.TEXT)
	best_stat.set_value(Rules.fmt(best), UIColors.TEXT_DIM)
	lives_dots.lives = lives
	need_stat.set_value("%d%%" % int(need))


## Show the score immediately instead of counting up to it.
func snap_score() -> void:
	_score_shown = _score


func submit(timed_out := false) -> void:
	if not playing:
		return
	playing = false
	submitted.emit(rgb.duplicate(), time_left, timed_out)


## For screenshot runs.
func set_debug_state(new_rgb: Array, new_sel: int, time_frac: float) -> void:
	rgb = new_rgb
	sel = new_sel
	time_left = time_total * time_frac
	_refresh()
	for s in sliders:
		s.snap()


func _process(delta: float) -> void:
	_score_shown = lerpf(_score_shown, float(_score), 1.0 - exp(-delta * 10.0))
	if absf(_score_shown - _score) < 0.5:
		_score_shown = _score
	score_stat.set_value(Rules.fmt(roundi(_score_shown)))
	if not visible:
		return
	_since += delta
	if active and playing:
		_process_hold(delta)
		if time_total > 0.0:
			time_left = maxf(time_left - delta, 0.0)
			if time_left <= 0.0:
				submit(true)
	_update_timer()


func _process_hold(delta: float) -> void:
	if _hold_dir == 0:
		return
	if not Input.is_action_pressed("g_left" if _hold_dir < 0 else "g_right"):
		_hold_dir = 0
		return
	_hold_t += delta
	while _hold_t >= REPEAT_RATE:
		_hold_t -= REPEAT_RATE
		_nudge(_hold_dir)


func _unhandled_input(event: InputEvent) -> void:
	if not active or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if playing:
		_play_key(event)
	elif event.is_action_pressed("g_confirm") and _since > INPUT_LOCK:
		continue_requested.emit()
	elif event.is_action_pressed("g_back"):
		menu_requested.emit()
	get_viewport().set_input_as_handled()


func _play_key(e: InputEvent) -> void:
	var code := (e as InputEventKey).physical_keycode
	if e.is_action_pressed("g_up"):
		sel = wrapi(sel - 1, 0, 3)
	elif e.is_action_pressed("g_down"):
		sel = wrapi(sel + 1, 0, 3)
	elif e.is_action_pressed("g_left") or e.is_action_pressed("g_right"):
		_hold_dir = -1 if e.is_action_pressed("g_left") else 1
		_hold_t = -REPEAT_DELAY
		_nudge(_hold_dir)
		return
	elif e.is_action_pressed("g_confirm"):
		submit(false)
		return
	elif e.is_action_pressed("g_back"):
		menu_requested.emit()
		return
	elif code >= KEY_1 and code <= KEY_3:
		sel = code - KEY_1
	_refresh()


## Clicking empty space on the result screen also continues.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if active and not playing and _since > INPUT_LOCK:
			continue_requested.emit()


func _nudge(d: int) -> void:
	var step := STEP_FINE if Input.is_key_pressed(KEY_SHIFT) else STEP
	rgb[sel] = clampi(rgb[sel] + d * step, 0, 255)
	_refresh()


func _on_picked(channel: int, value: int) -> void:
	if not (active and playing):
		return
	sel = channel
	rgb[channel] = value
	_refresh()


func _on_action() -> void:
	if playing:
		submit(false)
	elif _since > INPUT_LOCK:
		continue_requested.emit()


func _refresh() -> void:
	yours_swatch.color = Rules.to_color(rgb)
	for i in 3:
		sliders[i].show_state(rgb, i == sel)


func _update_timer() -> void:
	if time_total <= 0.0:
		timer_bar.modulate.a = 0.0
		time_stat.set_value("--", UIColors.TEXT_FAINT)
		return
	var f := clampf(time_left / time_total, 0.0, 1.0)
	timer_bar.modulate.a = 1.0
	timer_bar.value = f
	_bar_fill.bg_color = UIColors.ACCENT \
		.lerp(UIColors.WARN, clampf((0.5 - f) * 2.0, 0.0, 1.0)) \
		.lerp(UIColors.BAD, clampf((0.2 - f) * 5.0, 0.0, 1.0))
	var low := time_left <= minf(3.0, time_total * 0.3)
	time_stat.set_value("%.1f" % time_left, UIColors.BAD if low and playing else UIColors.TEXT)


## Keep the content at most MAX_CONTENT_WIDTH wide on very large screens.
func _fit_width() -> void:
	var side := maxi(SIDE_MARGIN, int((size.x - MAX_CONTENT_WIDTH) * 0.5))
	margin.add_theme_constant_override("margin_left", side)
	margin.add_theme_constant_override("margin_right", side)
