extends Node2D
## Game flow, first version: load one level and play it.

const LEVEL_PATH := "res://levels/level_01.tscn"
const TILE_SIZE := 16
const SCREEN_MARGIN := 70.0  # screen pixels kept free above and below the level

@onready var _level_holder: Node2D = $LevelHolder
@onready var _player: Player = $Player
@onready var _camera: Camera2D = $Camera2D

var _level: Level
var _tiles := {}  # cell -> tile type, read from the level
var _player_cell := Vector2i.ZERO
var _goal_cell := Vector2i.ZERO


func _ready() -> void:
	_player.move_requested.connect(_on_player_move_requested)
	_player.slide_finished.connect(_on_player_slide_finished)

	_level = (load(LEVEL_PATH) as PackedScene).instantiate() as Level
	_level_holder.add_child(_level)
	_tiles = _level.get_tiles()
	_goal_cell = _level.get_goal_cell()
	_fit_camera()
	_restart_level()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_restart_level()


func _restart_level() -> void:
	_player_cell = _level.get_start_cell()
	_player.place_at(_cell_to_world(_player_cell))
	_player.input_enabled = true


func _on_player_move_requested(direction: Vector2i) -> void:
	var path := IceRules.slide(_tiles, _player_cell, direction)
	if path.is_empty():
		return  # blocked: no move

	_player_cell = path[-1]
	var points: Array[Vector2] = []
	for cell in path:
		points.append(_cell_to_world(cell))
	_player.slide_along(points)


func _on_player_slide_finished() -> void:
	if _player_cell == _goal_cell:
		print("Solved!")


func _cell_to_world(cell: Vector2i) -> Vector2:
	return _level.to_global(_level.map_to_local(cell))


## Zooms and centres the camera so the whole level fits on screen.
func _fit_camera() -> void:
	var used := _level.get_used_rect()
	var level_size := Vector2(used.size) * TILE_SIZE
	var level_center := Vector2(used.position) * TILE_SIZE + level_size / 2.0
	var view := get_viewport_rect().size
	var fit := minf(view.x / level_size.x, (view.y - SCREEN_MARGIN * 2.0) / level_size.y) * 0.96
	_camera.zoom = Vector2(fit, fit)
	_camera.position = level_center
