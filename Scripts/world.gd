extends Node2D
## Game flow: owns the level list, loads levels, runs the rules, and moves between
## the level select screen, playing, and the solved state.

## Levels in play order.
const LEVEL_PATHS: Array[String] = [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
	"res://levels/level_03.tscn",
	"res://levels/level_04.tscn",
	"res://levels/level_05.tscn",
	"res://levels/level_06.tscn",
]

const TILE_SIZE := 16
const SCREEN_MARGIN := 70.0  # screen pixels kept free above and below the level for text
const SAVE_PATH := "user://progress.cfg"

enum State { MENU, PLAYING, SOLVED }

@onready var _level_holder: Node2D = $LevelHolder
@onready var _player: Player = $Player
@onready var _camera: Camera2D = $Camera2D

var _hud: Hud
var _menu: LevelSelect

var _scenes: Array[PackedScene] = []
var _names: Array[String] = []
var _completed: Array[bool] = []

var _state := State.MENU
var _level: Level
var _level_index := -1
var _tiles := {}  # cell -> tile type, read from the current level
var _player_cell := Vector2i.ZERO
var _goal_cell := Vector2i.ZERO


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.10, 0.11, 0.15))

	# Load every level once so the menu can show their names.
	for path in LEVEL_PATHS:
		var scene := load(path) as PackedScene
		_scenes.append(scene)
		var preview := scene.instantiate() as Level
		_names.append(preview.level_name)
		preview.free()
	_load_progress()

	_hud = Hud.new()
	add_child(_hud)
	_menu = LevelSelect.new()
	add_child(_menu)

	_menu.level_chosen.connect(_start_level)
	_player.move_requested.connect(_on_player_move_requested)
	_player.slide_finished.connect(_on_player_slide_finished)
	get_viewport().size_changed.connect(_fit_camera)

	_open_menu()


func _unhandled_input(event: InputEvent) -> void:
	# Number keys jump straight to a level
	if event is InputEventKey and event.pressed and not event.echo:
		var number: int = event.keycode - KEY_1
		if number >= 0 and number < _scenes.size():
			_start_level(number)
			return

	if _state == State.MENU:
		return

	if event.is_action_pressed("restart"):
		_restart_level()
	elif event.is_action_pressed("ui_cancel"):
		_open_menu()
	elif event.is_action_pressed("ui_accept") and _state == State.SOLVED:
		if _level_index + 1 < _scenes.size():
			_start_level(_level_index + 1)
		else:
			_open_menu()

func _open_menu() -> void:
	_state = State.MENU
	_player.input_enabled = false
	_hud.visible = false
	_menu.populate(_names, _completed)
	_menu.open()


func _start_level(index: int) -> void:
	_menu.close()
	if _level:
		_level_holder.remove_child(_level)
		_level.queue_free()

	_level_index = index
	_level = _scenes[index].instantiate() as Level
	_level_holder.add_child(_level)
	_tiles = _level.get_tiles()
	_goal_cell = _level.get_goal_cell()

	_hud.visible = true
	_hud.set_hint(_level.hint)
	_fit_camera()
	_restart_level()


func _restart_level() -> void:
	_player_cell = _level.get_start_cell()
	_player.place_at(_cell_to_world(_player_cell))
	_player.input_enabled = true
	_hud.hide_solved()
	_state = State.PLAYING


func _on_solved() -> void:
	_state = State.SOLVED
	_player.input_enabled = false
	_completed[_level_index] = true
	_save_progress()
	if _level_index + 1 < _scenes.size():
		_hud.show_solved("Solved!   Enter: next level")
	else:
		_hud.show_solved("Solved! That was the last level.   Enter: level select")


# --- Player events ---

func _on_player_move_requested(direction: Vector2i) -> void:
	if _state != State.PLAYING:
		return
	var path := IceRules.slide(_tiles, _player_cell, direction)
	if path.is_empty():
		return  # blocked: no move

	_player_cell = path[-1]
	var points: Array[Vector2] = []
	for cell in path:
		points.append(_cell_to_world(cell))
	_player.slide_along(points)


func _on_player_slide_finished() -> void:
	if _state == State.PLAYING and _player_cell == _goal_cell:
		_on_solved()


# --- Helpers ---

func _cell_to_world(cell: Vector2i) -> Vector2:
	return _level.to_global(_level.map_to_local(cell))


## Zooms and centres the camera so the whole level fits on screen.
func _fit_camera() -> void:
	if _level == null:
		return
	var used := _level.get_used_rect()
	var level_size := Vector2(used.size) * TILE_SIZE
	var level_center := Vector2(used.position) * TILE_SIZE + level_size / 2.0
	var view := get_viewport_rect().size
	var fit := minf(view.x / level_size.x, (view.y - SCREEN_MARGIN * 2.0) / level_size.y) * 0.96
	_camera.zoom = Vector2(fit, fit)
	_camera.position = level_center



func _load_progress() -> void:
	_completed.resize(LEVEL_PATHS.size())
	_completed.fill(false)
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	var saved: Array = config.get_value("progress", "completed", [])
	for i in mini(saved.size(), _completed.size()):
		_completed[i] = bool(saved[i])


func _save_progress() -> void:
	var saved: Array = []
	saved.assign(_completed)
	var config := ConfigFile.new()
	config.set_value("progress", "completed", saved)
	config.save(SAVE_PATH)
