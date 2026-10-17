class_name Player
extends CharacterBody2D
## The sliding character. It reads keys and animates slides; it knows no rules.

## Emitted when a direction key is pressed and the player can move.
signal move_requested(direction: Vector2i)
## Emitted when a slide animation has finished.
signal slide_finished

const SLIDE_SPEED := 240.0  # pixels per second
const TILE_SIZE := 16.0

## world.gd turns this off while a menu is open or a level is solved.
var input_enabled := false
var is_sliding := false

var _tween: Tween


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled or is_sliding:
		return

	var direction := Vector2i.ZERO
	if event.is_action_pressed("up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("right"):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		move_requested.emit(direction)


## Instantly puts the player somewhere and cancels any slide in progress.
func place_at(world_position: Vector2) -> void:
	if _tween:
		_tween.kill()
	is_sliding = false
	global_position = world_position


## Slides through a list of world positions, one tile after another.
func slide_along(points: Array[Vector2]) -> void:
	is_sliding = true
	_tween = create_tween()
	for point in points:
		_tween.tween_property(self, "global_position", point, TILE_SIZE / SLIDE_SPEED)
	_tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	is_sliding = false
	slide_finished.emit()
