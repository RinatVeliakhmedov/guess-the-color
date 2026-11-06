class_name ResultPanel
extends PanelContainer
## Shown in place of the sliders after a guess: accuracy, verdict, points and
## how far off each channel was.

@onready var _accuracy: Label = %Accuracy
@onready var _verdict: Label = %Verdict
@onready var _need: Label = %Need
@onready var _points: Label = %Points
@onready var _sub: Label = %Sub
@onready var _diffs: Array[Label] = [%RValue, %GValue, %BValue]


## r: acc, ok, timed_out, need, points, streak, lives, diff ([dr, dg, db], yours minus target)
func show_result(r: Dictionary) -> void:
	_accuracy.text = "%.1f%%" % r["acc"]
	var ok: bool = r["ok"]
	_verdict.text = "Match!" if ok else ("Time's up" if r["timed_out"] else "Not quite")
	_verdict.add_theme_color_override("font_color", UIColors.GOOD if ok else UIColors.BAD)
	_need.text = "needed %d%%" % int(r["need"])
	_points.add_theme_color_override("font_color", UIColors.GOOD if ok else UIColors.BAD)
	if ok:
		_points.text = "+" + Rules.fmt(r["points"])
		_sub.text = "streak %d" % r["streak"]
		if r["streak"] > 1:
			_sub.text += "  ·  ×%.1f" % Rules.streak_mult(r["streak"])
	else:
		_points.text = "-1 life"
		_sub.text = ("%d left" % r["lives"]) if r["lives"] > 0 else "no lives left"
	for i in 3:
		var d: int = r["diff"][i]
		_diffs[i].text = ("+%d" % d) if d > 0 else str(d)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)
