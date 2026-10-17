class_name Hud
extends CanvasLayer
## On-screen text while playing: controls, a hint for the level, and the "Solved!" banner.

var _controls_label: Label
var _hint_label: Label
var _solved_label: Label


func _ready() -> void:
	_controls_label = _make_label(18, Color.WHITE)
	_controls_label.text = "R: Reset     Esc: Level select"
	_controls_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_controls_label.position = Vector2(14, 10)

	_hint_label = _make_label(20, Color(0.85, 0.95, 1.0))
	_hint_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_label.offset_top = -52
	_hint_label.offset_bottom = -12
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_solved_label = _make_label(30, Color(1.0, 0.85, 0.2))
	_solved_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_solved_label.offset_top = 30
	_solved_label.offset_bottom = 78
	_solved_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_solved_label.visible = false


func set_hint(text: String) -> void:
	_hint_label.text = text


func show_solved(text: String) -> void:
	_solved_label.text = text
	_solved_label.visible = true


func hide_solved() -> void:
	_solved_label.visible = false


func _make_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 6)
	add_child(label)
	return label
