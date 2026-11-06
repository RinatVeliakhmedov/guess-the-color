class_name UIColors
extends RefCounted
## Colors that scripts need at runtime (state colors, slider tints, ...).
## Static styling lives in ui/theme.tres; keep the shared values in sync.
## Neutral greys on purpose: a tinted background would bias color perception.

const BG := Color("1e1f22")
const PANEL := Color("27282c")
const PANEL_HI := Color("313237")
const LINE := Color("3c3d43")
const TEXT := Color("e6e6e8")
const TEXT_DIM := Color("9a9ca3")
const TEXT_FAINT := Color("63656c")
const GOOD := Color("7fcfa3")
const BAD := Color("e8968f")
const WARN := Color("e8c47e")
const ACCENT := Color("a9b8f5")
const ON_ACCENT := Color("1b1c22")
const CHANNEL_TINT := [Color("e8968f"), Color("8fd6a6"), Color("8fb0ee")]


## Readable text color on top of an arbitrary swatch.
static func ink_on(c: Color) -> Color:
	var l := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
	return Color(0, 0, 0, 0.6) if l > 0.5 else Color(1, 1, 1, 0.72)
