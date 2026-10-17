extends Node

#func _ready() -> void:
	## A 6 x 3 box: walls on the edge, ice inside.
	#var tiles := {}
	#for x in 6:
		#for y in 3:
			#var on_edge := x == 0 or x == 5 or y == 0 or y == 2
			#tiles[Vector2i(x, y)] = "wall" if on_edge else "ice"
	#print(IceRules.slide(tiles, Vector2i(1, 1), Vector2i.RIGHT))
	#print(IceRules.slide(tiles, Vector2i(1, 1), Vector2i.UP))

func _ready() -> void:
	var level := (load("res://levels/level_01.tscn") as PackedScene).instantiate() as Level
	add_child(level)
	var tiles := level.get_tiles()
	print("start ", level.get_start_cell(), " goal ", level.get_goal_cell())
	print(IceRules.slide(tiles, level.get_start_cell(), Vector2i.LEFT))
