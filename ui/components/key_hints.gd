@tool
class_name KeyHints
extends HBoxContainer
## A row of keyboard hints such as [Enter] match.
## Each entry is "keys:label"; keys are separated by spaces and
## @up/@down/@left/@right are drawn as arrow keys.

const ARROWS := {"@up": Vector2.UP, "@down": Vector2.DOWN, "@left": Vector2.LEFT, "@right": Vector2.RIGHT}

@export var hints := PackedStringArray():
	set(v):
		hints = v
		if is_node_ready():
			_rebuild()


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	for h in hints:
		var parts := h.split(":", true, 1)
		var group := HBoxContainer.new()
		group.add_theme_constant_override("separation", 4)
		group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for k in parts[0].split(" ", false):
			group.add_child(_make_cap(k))
		group.add_child(Control.new()) # extra gap before the label
		var label := Label.new()
		label.text = parts[1] if parts.size() > 1 else ""
		label.theme_type_variation = &"HintLabel"
		group.add_child(label)
		add_child(group)


func _make_cap(key: String) -> Control:
	var cap := PanelContainer.new()
	cap.theme_type_variation = &"KeyCap"
	cap.custom_minimum_size = Vector2(24, 24)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ARROWS.has(key):
		var t := Triangle.new()
		t.direction = ARROWS[key]
		t.radius = 4.5
		t.color = UIColors.TEXT_DIM
		t.custom_minimum_size = Vector2(8, 18)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cap.add_child(t)
	else:
		var l := Label.new()
		l.text = key
		l.theme_type_variation = &"KeyCapLabel"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cap.add_child(l)
	return cap
