class_name IceRules
extends RefCounted
## The rules of the ice puzzle. No nodes, no visuals.
## A level is a Dictionary: cell (Vector2i) -> tile type (String).
## A cell that is missing from the Dictionary counts as a wall.

const WALL := "wall"
const DIRECTIONS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
const ARROWS := {
	"arrow_up": Vector2i.UP,
	"arrow_down": Vector2i.DOWN,
	"arrow_left": Vector2i.LEFT,
	"arrow_right": Vector2i.RIGHT,
}
const CURVES := {
	"curve_up_right": [Vector2i.UP, Vector2i.RIGHT],
	"curve_right_down": [Vector2i.RIGHT, Vector2i.DOWN],
	"curve_down_left": [Vector2i.DOWN, Vector2i.LEFT],
	"curve_left_up": [Vector2i.LEFT, Vector2i.UP],
}

static func slide(tiles: Dictionary, from: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []

	# Resting inside a bend: the only way out is through one of its openings.
	var here: String = tiles.get(from, WALL)
	if CURVES.has(here) and not (direction in CURVES[here]):
		return path

	var cell := from
	var dir := direction
	var visited := {}  # (cell, direction) states already seen, to catch arrow loops

	while true:
		var next := cell + dir
		var kind: String = tiles.get(next, WALL)
		if kind == WALL:
			break

		if CURVES.has(kind):
			var openings: Array = CURVES[kind]
			var entry_side: Vector2i = -dir
			if not (entry_side in openings):
				break  # a closed side of the bend: it blocks like a wall
			var exit_dir: Vector2i = openings[1] if openings[0] == entry_side else openings[0]
			dir = exit_dir
		elif ARROWS.has(kind):
			dir = ARROWS[kind]

		cell = next
		path.append(cell)

		var state := Vector4i(cell.x, cell.y, dir.x, dir.y)
		if visited.has(state):
			path.clear()  # arrows are pushing the player in a circle forever
			break
		visited[state] = true

	return path
