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

## Returns every cell passed through, in order. The last one is where you stop.
## An empty array means nothing happens.
static func slide(tiles: Dictionary, from: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cell := from
	var dir := direction  # arrows change this, so work on a copy
	var visited := {}  # (cell, direction) states already seen, to catch arrow loops

	while true:
		var next := cell + dir
		var kind: String = tiles.get(next, WALL)
		if kind == WALL:
			break

		if ARROWS.has(kind):
			dir = ARROWS[kind]

		cell = next
		path.append(cell)

		var state := Vector4i(cell.x, cell.y, dir.x, dir.y)
		if visited.has(state):
			path.clear()  # arrows are pushing the player in a circle forever
			break
		visited[state] = true

	return path
