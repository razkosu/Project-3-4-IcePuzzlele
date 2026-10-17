class_name LevelSelect
extends CanvasLayer
## The level select screen: one button per level.

## Emitted with the level's position in world.gd's level list.
signal level_chosen(index: int)

const COLUMNS := 3

var _grid: GridContainer
var _buttons: Array[Button] = []


func _init() -> void:
	layer = 10  # draw above the hud


func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color(0.10, 0.11, 0.15)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 22)
	center.add_child(column)

	column.add_child(_make_label("ICE PUZZLE", 52, Color(0.75, 0.92, 1.0)))
	column.add_child(_make_label("Pick a level: click it, or press its number", 20, Color(0.8, 0.85, 0.9)))

	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	column.add_child(_grid)


## Rebuilds the buttons. names[i] is level i's name, completed[i] says if it was solved.
func populate(names: Array[String], completed: Array[bool]) -> void:
	for button in _buttons:
		button.queue_free()
	_buttons.clear()

	for i in names.size():
		var button := Button.new()
		var tag := "   (solved)" if completed[i] else ""
		button.text = "%d   %s%s" % [i + 1, names[i], tag]
		button.custom_minimum_size = Vector2(230, 64)
		button.add_theme_font_size_override("font_size", 22)
		button.pressed.connect(func() -> void: level_chosen.emit(i))
		_grid.add_child(button)
		_buttons.append(button)


func open() -> void:
	visible = true
	if not _buttons.is_empty():
		_buttons[0].grab_focus.call_deferred()


func close() -> void:
	visible = false


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
