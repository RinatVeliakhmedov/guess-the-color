class_name Rules
extends RefCounted
## Game rules, color sets and scoring. No UI or state in here.

const DIFFICULTIES := [
	{"name": "Easy", "need": 85.0, "mult": 1.0},
	{"name": "Normal", "need": 90.0, "mult": 1.5},
	{"name": "Hard", "need": 95.0, "mult": 2.0},
	{"name": "Expert", "need": 98.0, "mult": 3.0},
]
const TIMERS := [0.0, 30.0, 15.0, 8.0] # seconds per attempt, 0 = no limit
const SETS := ["Random", "Named", "Pastel", "Vivid", "Earth"]
const SET_INFO := [
	"Any of 16.7 million RGB colors",
	"Well-known web color names",
	"Soft, light tints",
	"Bold, saturated UI colors",
	"Muted natural tones",
]
const PALETTES := {
	"Named": [
		["Coral", "#ff7f50"], ["Tomato", "#ff6347"], ["Crimson", "#dc143c"],
		["Salmon", "#fa8072"], ["Gold", "#ffd700"], ["Orange", "#ffa500"],
		["Khaki", "#f0e68c"], ["Olive", "#808000"], ["Lime Green", "#32cd32"],
		["Forest Green", "#228b22"], ["Sea Green", "#2e8b57"], ["Teal", "#008080"],
		["Turquoise", "#40e0d0"], ["Sky Blue", "#87ceeb"], ["Steel Blue", "#4682b4"],
		["Royal Blue", "#4169e1"], ["Navy", "#000080"], ["Slate Blue", "#6a5acd"],
		["Indigo", "#4b0082"], ["Orchid", "#da70d6"], ["Plum", "#dda0dd"],
		["Violet", "#ee82ee"], ["Hot Pink", "#ff69b4"], ["Maroon", "#800000"],
		["Chocolate", "#d2691e"], ["Sienna", "#a0522d"], ["Tan", "#d2b48c"],
		["Peru", "#cd853f"], ["Goldenrod", "#daa520"], ["Chartreuse", "#7fff00"],
		["Aquamarine", "#7fffd4"], ["Cadet Blue", "#5f9ea0"], ["Lavender", "#e6e6fa"],
		["Thistle", "#d8bfd8"], ["Slate Gray", "#708090"], ["Dark Olive Green", "#556b2f"],
		["Rosy Brown", "#bc8f8f"], ["Medium Purple", "#9370db"], ["Dodger Blue", "#1e90ff"],
		["Firebrick", "#b22222"],
	],
	"Pastel": [
		["Baby Pink", "#f4c2c2"], ["Blush", "#ffd1dc"], ["Peach", "#ffe5b4"],
		["Apricot", "#fbceb1"], ["Butter", "#fff1a8"], ["Lemon Chiffon", "#fffacd"],
		["Mint", "#aaf0d1"], ["Celadon", "#ace1af"], ["Seafoam", "#c3fbd8"],
		["Baby Blue", "#a7c7e7"], ["Powder Blue", "#b0e0e6"], ["Periwinkle", "#ccccff"],
		["Lilac", "#c8a2c8"], ["Mauve", "#e0b0ff"], ["Pale Rose", "#f6d6de"],
		["Pistachio", "#c5e1a5"], ["Cream", "#fffdd0"], ["Light Coral", "#f6a5a5"],
	],
	"Vivid": [
		["Red", "#f44336"], ["Pink", "#e91e63"], ["Purple", "#9c27b0"],
		["Deep Purple", "#673ab7"], ["Indigo", "#3f51b5"], ["Blue", "#2196f3"],
		["Light Blue", "#03a9f4"], ["Cyan", "#00bcd4"], ["Teal", "#009688"],
		["Green", "#4caf50"], ["Light Green", "#8bc34a"], ["Lime", "#cddc39"],
		["Yellow", "#ffeb3b"], ["Amber", "#ffc107"], ["Orange", "#ff9800"],
		["Deep Orange", "#ff5722"], ["Brown", "#795548"], ["Blue Grey", "#607d8b"],
	],
	"Earth": [
		["Terracotta", "#e2725b"], ["Clay", "#b66a50"], ["Sand", "#c2b280"],
		["Ochre", "#cc7722"], ["Moss", "#8a9a5b"], ["Olive Drab", "#6b8e23"],
		["Sage", "#9caf88"], ["Umber", "#635147"], ["Rust", "#b7410e"],
		["Burnt Sienna", "#882d17"], ["Driftwood", "#af8f6f"], ["Fern", "#4f7942"],
		["Desert", "#edc9af"], ["Mahogany", "#c04000"], ["Pine", "#01796f"],
		["Stone", "#8b8680"],
	],
}
const CHANNELS := ["R", "G", "B"]
const MAX_DIST := 441.6729559300637 # sqrt(3) * 255: black vs white
const START_LIVES := 3


## 100 = identical, 0 = black vs white. Rounded to one decimal so the shown
## value is exactly the one that is compared against the requirement.
static func accuracy(a: Array, b: Array) -> float:
	var d2 := 0.0
	for i in 3:
		var d: float = a[i] - b[i]
		d2 += d * d
	return snappedf(100.0 * (1.0 - sqrt(d2) / MAX_DIST), 0.1)


## 50 points for a match, up to +100 more the closer you are, then scaled by
## difficulty, remaining time (up to +50%) and streak (up to x2).
static func points(acc: float, difficulty: int, time_frac: float, streak: int) -> int:
	var need: float = DIFFICULTIES[difficulty]["need"]
	var closeness := clampf((acc - need) / (100.0 - need), 0.0, 1.0)
	var pts := (50.0 + 100.0 * closeness) * float(DIFFICULTIES[difficulty]["mult"])
	if time_frac >= 0.0:
		pts *= 1.0 + 0.5 * time_frac
	return roundi(pts * streak_mult(streak))


static func streak_mult(streak: int) -> float:
	return 1.0 + 0.1 * clampi(streak - 1, 0, 10)


static func to_color(a: Array) -> Color:
	return Color(a[0] / 255.0, a[1] / 255.0, a[2] / 255.0)


static func hex(a: Array) -> String:
	return "#%02X%02X%02X   %d  %d  %d" % [a[0], a[1], a[2], a[0], a[1], a[2]]


static func fmt(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out
