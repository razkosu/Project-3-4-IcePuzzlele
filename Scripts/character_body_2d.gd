extends CharacterBody2D

const TILE_SIZE := 16
const SLIDE_SPEED := 200.0
const GRID_OFFSET := Vector2(TILE_SIZE, TILE_SIZE) / 2.0

var slide_dir := Vector2.ZERO
var start_position := Vector2.ZERO


func _ready() -> void:
	global_position = _snap(global_position)
	start_position = global_position

func teleport(pos: Vector2) -> void:
	slide_dir = Vector2.ZERO
	global_position = pos
	start_position = pos

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		slide_dir = Vector2.ZERO
		global_position = start_position
		return

	# Waiting for input: one press starts a slide
	if slide_dir == Vector2.ZERO:
		var dir := _read_direction()
		if dir != Vector2.ZERO and not test_move(global_transform, dir * 2.0):
			slide_dir = dir
		return

	# Sliding: keep going until something blocks the player
	var collision := move_and_collide(slide_dir * SLIDE_SPEED * delta)
	if collision:
		slide_dir = Vector2.ZERO
		global_position = _snap(global_position)


func _read_direction() -> Vector2:
	if Input.is_action_just_pressed("up"): return Vector2.UP
	if Input.is_action_just_pressed("down"): return Vector2.DOWN
	if Input.is_action_just_pressed("left"): return Vector2.LEFT
	if Input.is_action_just_pressed("right"): return Vector2.RIGHT
	return Vector2.ZERO


# Snap to the center of the nearest tile
func _snap(pos: Vector2) -> Vector2:
	return (pos - GRID_OFFSET).snapped(Vector2(TILE_SIZE, TILE_SIZE)) + GRID_OFFSET
