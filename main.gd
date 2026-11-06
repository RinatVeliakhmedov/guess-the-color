extends Control
## Game flow: menu -> rounds -> game over.
## Screens display state and report what the player did; this script owns the
## run (score, streak, lives, targets) and the saved progress.

enum State { MENU, PLAY, RESULT, GAMEOVER }

@onready var menu: MenuScreen = $Menu
@onready var game: GameScreen = $Game
@onready var game_over: GameOverScreen = $GameOver

var progress := Progress.new()
var state := State.MENU

var score := 0
var streak := 0
var best_run_streak := 0
var lives := Rules.START_LIVES
var round_n := 0
var new_high := false
var target_rgb := [0, 0, 0]
var target_name := ""
var bag: Array = [] # shuffled palette indices still to come
var last_index := -1


func _ready() -> void:
	progress.load_file()
	menu.start_requested.connect(_start_run)
	menu.setting_changed.connect(_on_setting_changed)
	game.submitted.connect(_on_submitted)
	game.continue_requested.connect(_on_continue)
	game.menu_requested.connect(_show_menu)
	game_over.play_again_requested.connect(_start_run)
	game_over.menu_requested.connect(_show_menu)
	_show_menu()
	_apply_debug_args()


func _set_state(s: State) -> void:
	state = s
	menu.visible = s == State.MENU
	game.visible = s != State.MENU # stays visible behind the game-over card
	game_over.visible = s == State.GAMEOVER
	menu.active = s == State.MENU
	game.active = s == State.PLAY or s == State.RESULT
	game_over.active = s == State.GAMEOVER


func _show_menu() -> void:
	menu.refresh(progress)
	_set_state(State.MENU)


func _on_setting_changed(row: int, delta: int) -> void:
	progress.change(row, delta)
	menu.refresh(progress)


func _start_run() -> void:
	score = 0
	streak = 0
	best_run_streak = 0
	lives = Rules.START_LIVES
	round_n = 0
	new_high = false
	bag.clear()
	_update_hud()
	game.snap_score()
	_next_round()


func _next_round() -> void:
	round_n += 1
	_pick_target()
	game.start_round(target_rgb, Rules.TIMERS[progress.timer])
	_update_hud()
	_set_state(State.PLAY)


func _pick_target() -> void:
	var set_name: String = Rules.SETS[progress.colors]
	if set_name == "Random":
		target_rgb = [randi_range(0, 255), randi_range(0, 255), randi_range(0, 255)]
		target_name = ""
		return
	var pal: Array = Rules.PALETTES[set_name]
	if bag.is_empty():
		bag = range(pal.size())
		bag.shuffle()
		if bag.size() > 1 and bag.back() == last_index:
			bag.push_front(bag.pop_back()) # no immediate repeat across refills
	last_index = bag.pop_back()
	target_name = pal[last_index][0]
	var c := Color.html(str(pal[last_index][1]))
	target_rgb = [c.r8, c.g8, c.b8]


func _on_submitted(rgb: Array, time_left: float, timed_out: bool) -> void:
	var acc := Rules.accuracy(rgb, target_rgb)
	var need: float = Rules.DIFFICULTIES[progress.difficulty]["need"]
	var ok := acc >= need - 0.001
	var pts := 0
	if ok:
		streak += 1
		best_run_streak = maxi(best_run_streak, streak)
		var total: float = Rules.TIMERS[progress.timer]
		pts = Rules.points(acc, progress.difficulty, time_left / total if total > 0.0 else -1.0, streak)
		score += pts
	else:
		streak = 0
		lives -= 1
	if progress.record(score, best_run_streak):
		new_high = true
	_update_hud()
	game.show_result({
		"acc": acc, "ok": ok, "timed_out": timed_out, "need": need, "points": pts,
		"streak": streak, "lives": lives,
		"diff": [rgb[0] - target_rgb[0], rgb[1] - target_rgb[1], rgb[2] - target_rgb[2]],
		"target": target_rgb, "target_name": target_name,
	})
	_set_state(State.RESULT)


func _on_continue() -> void:
	if lives > 0:
		_next_round()
		return
	var t: float = Rules.TIMERS[progress.timer]
	game_over.show_summary({
		"score": score,
		"new_best": new_high and score > 0,
		"best_score": int(progress.best()["score"]),
		"rounds": round_n,
		"best_streak": best_run_streak,
		"all_time_streak": int(progress.best()["streak"]),
		"mode": "%s  ·  %s  ·  %s" % [Rules.DIFFICULTIES[progress.difficulty]["name"],
			Rules.SETS[progress.colors], "no timer" if t == 0.0 else "%d s" % int(t)],
	})
	_set_state(State.GAMEOVER)


func _update_hud() -> void:
	game.set_hud(score, streak, maxi(int(progress.best()["score"]), score), lives,
		Rules.DIFFICULTIES[progress.difficulty]["need"])


## Dev helper for screenshots (never writes the save file):
## godot -- --shot=menu|play|result|gameover [--diff=N --colors=N --timer=N]
func _apply_debug_args() -> void:
	var shot := ""
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=")
		if kv.size() != 2:
			continue
		match kv[0]:
			"shot": shot = kv[1]
			"diff": progress.difficulty = int(kv[1])
			"colors": progress.colors = int(kv[1])
			"timer": progress.timer = int(kv[1])
	if shot == "":
		return
	progress.read_only = true
	progress.highscores = {}
	seed(42)
	if shot == "menu":
		_show_menu()
		return
	_start_run()
	score = 1240
	streak = 4
	_update_hud()
	game.snap_score()
	match shot:
		"play":
			game.set_debug_state([214, 120, 88], 1, 0.62)
		"result":
			game.set_debug_state([clampi(target_rgb[0] + 9, 0, 255), clampi(target_rgb[1] - 14, 0, 255),
				clampi(target_rgb[2] + 3, 0, 255)], 0, 0.62)
			game.submit()
		"gameover":
			lives = 1
			game.set_debug_state([255 - target_rgb[0], 255 - target_rgb[1], 255 - target_rgb[2]], 0, 0.0)
			game.submit()
			best_run_streak = 7
			round_n = 12
			_on_continue()
