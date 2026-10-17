class_name IceRules
extends RefCounted
## The rules of the ice puzzle. No nodes, no visuals.
## A level is a Dictionary: cell (Vector2i) -> tile type (String).
## A cell that is missing from the Dictionary counts as a wall.

const WALL := "wall"
const DIRECTIONS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


## Returns every cell passed through, in order. The last one is where you stop.
## An empty array means nothing happens.
static func slide(tiles: Dictionary, from: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cell := from
	while true:
		var next := cell + direction
		var kind: String = tiles.get(next, WALL)
		if kind == WALL:
			break
		cell = next
		path.append(cell)
	return path
