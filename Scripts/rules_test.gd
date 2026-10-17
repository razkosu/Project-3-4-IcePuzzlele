extends Node

func _ready() -> void:
	# A 6 x 3 box: walls on the edge, ice inside.
	var tiles := {}
	for x in 6:
		for y in 3:
			var on_edge := x == 0 or x == 5 or y == 0 or y == 2
			tiles[Vector2i(x, y)] = "wall" if on_edge else "ice"
	print(IceRules.slide(tiles, Vector2i(1, 1), Vector2i.RIGHT))
	print(IceRules.slide(tiles, Vector2i(1, 1), Vector2i.UP))
