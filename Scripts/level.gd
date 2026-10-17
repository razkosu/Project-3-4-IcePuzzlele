class_name Level
extends TileMapLayer

@export var level_name := "Untitled"
@export_multiline var hint := ""

func get_tiles() -> Dictionary:
	var tiles := {}
	for cell in get_used_cells():
		var data := get_cell_tile_data(cell)
		if data:
			tiles[cell] = String(data.get_custom_data("tile_type"))
		else:
			tiles[cell] = IceRules.WALL
	return tiles
			
func get_start_cell() -> Vector2i:
	return local_to_map($Start.position)
	
func get_goal_cell() -> Vector2i:
	return local_to_map($Goal.position)
