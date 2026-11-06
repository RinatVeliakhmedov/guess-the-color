class_name Progress
extends RefCounted
## Menu settings and per-mode high scores, persisted to user://.

const SAVE_PATH := "user://save.cfg"

var difficulty := 1 # Normal
var colors := 1 # Named
var timer := 1 # 30 s
var highscores := {} # "difficulty_colors_timer" -> {"score": int, "streak": int}
var read_only := false # set for screenshot runs so they never touch the save


func change(row: int, delta: int) -> void:
	match row:
		0: difficulty = wrapi(difficulty + delta, 0, Rules.DIFFICULTIES.size())
		1: colors = wrapi(colors + delta, 0, Rules.SETS.size())
		2: timer = wrapi(timer + delta, 0, Rules.TIMERS.size())
		_: return
	save_file()


func mode_key() -> String:
	return "%d_%d_%d" % [difficulty, colors, timer]


func best() -> Dictionary:
	return highscores.get(mode_key(), {"score": 0, "streak": 0})


## Stores the run if it beats the current mode's records.
## Returns true when the score is a new best.
func record(score: int, streak: int) -> bool:
	var rec := best().duplicate()
	var new_best := score > int(rec["score"])
	if new_best:
		rec["score"] = score
	if streak > int(rec["streak"]):
		rec["streak"] = streak
	elif not new_best:
		return false
	highscores[mode_key()] = rec
	save_file()
	return new_best


func save_file() -> void:
	if read_only:
		return
	var cf := ConfigFile.new()
	cf.set_value("prefs", "difficulty", difficulty)
	cf.set_value("prefs", "colors", colors)
	cf.set_value("prefs", "timer", timer)
	cf.set_value("scores", "table", highscores)
	cf.save(SAVE_PATH)


func load_file() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return
	difficulty = clampi(int(cf.get_value("prefs", "difficulty", difficulty)), 0, Rules.DIFFICULTIES.size() - 1)
	colors = clampi(int(cf.get_value("prefs", "colors", colors)), 0, Rules.SETS.size() - 1)
	timer = clampi(int(cf.get_value("prefs", "timer", timer)), 0, Rules.TIMERS.size() - 1)
	var t = cf.get_value("scores", "table", {})
	if t is Dictionary:
		highscores = t
