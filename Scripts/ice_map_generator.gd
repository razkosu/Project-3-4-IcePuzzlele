class_name IceMapGenerator
extends RefCounted

const TILESET := preload("res://Assets/tileset.tres")

## Where each tile lives in tiles_1.png (matches the custom "tile_type" data in tileset.tres).
const SOURCE_ID := 2                    
const ICE_TILE := Vector2i(0, 0)
const WALL_TILE := Vector2i(1, 0)       
const ARROW_TILES := {
	"arrow_up": Vector2i(2, 0),
	"arrow_down": Vector2i(3, 0),
	"arrow_left": Vector2i(4, 0),
	"arrow_right": Vector2i(5, 0),
}
const CURVE_TILES := {
	"curve_up_right": Vector2i(6, 0),
	"curve_right_down": Vector2i(7, 0),
	"curve_down_left": Vector2i(8, 0),
	"curve_left_up": Vector2i(9, 0),
}

const START_COLOR := Color(0.34901962, 0.654902, 1, 1)  
const GOAL_COLOR := Color(1, 0.6862745, 0.25490198, 1)  

# ---- Settings: change these to change how the maps are ----
var width := 12               # max cave size in cells (walls go around this)
var height := 9
var walk_steps := 90          # how far the walker wanders; more = bigger cave
var brush_size := 2           # the walker carves brush_size x brush_size squares; bigger = more open rooms
var rock_density := 0.08      # chance each ice cell becomes a rock
var arrow_density := 0.08     # chance each ice cell becomes an arrow
var curve_density := 0.07     # chance each ice cell becomes a curved tile

var rng := RandomNumberGenerator.new()

var _tiles := {}  # cell (Vector2i) -> tile type (String), same format as Level.get_tiles()


## Makes a new random Level. Pass a seed to get the same map every time
func generate(seed_value: int = -1) -> Level:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()

	_tiles = {}
	_carve_cave()
	_scatter_obstacles()

	var ice_cells := _cells_of_type("ice")
	if ice_cells.size() < 2:
		return null

	# Pick two different ice cells. pop_at() removes the start from the list,
	# so the goal can never land on the same cell.
	var start: Vector2i = ice_cells.pop_at(rng.randi() % ice_cells.size())
	var goal: Vector2i = ice_cells[rng.randi() % ice_cells.size()]

	_add_border_walls()
	return _build_level(start, goal)

## A random walk: step in a random direction over and over, turning the
## cells under the "brush" into ice.
func _carve_cave() -> void:
	var walker := Vector2i(width / 2, height / 2)
	_carve_brush(walker)

	var steps := 0
	while steps < walk_steps:
		var next: Vector2i = walker + IceRules.DIRECTIONS[rng.randi() % IceRules.DIRECTIONS.size()]
		if _inside(next):
			walker = next
			_carve_brush(walker)
			steps += 1


func _carve_brush(cell: Vector2i) -> void:
	for dx in brush_size:
		for dy in brush_size:
			var c := cell + Vector2i(dx, dy)
			if _inside(c):
				_tiles[c] = "ice"


## Keeps the cave inside the width x height box.
func _inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height


## One random roll per ice cell decides what it becomes. The densities stack:
## with rock 0.08, arrow 0.08, curve 0.07 a roll of
##   0.00-0.08 -> rock,  0.08-0.16 -> arrow,  0.16-0.23 -> curve,  else stays ice.
func _scatter_obstacles() -> void:
	for cell in _tiles.keys():
		var roll := rng.randf()
		if roll < rock_density:
			_tiles[cell] = IceRules.WALL  # rocks block exactly like walls
		elif roll < rock_density + arrow_density:
			_tiles[cell] = _random_key(ARROW_TILES)
		elif roll < rock_density + arrow_density + curve_density:
			_tiles[cell] = _random_key(CURVE_TILES)


func _random_key(options: Dictionary) -> String:
	var keys := options.keys()
	return keys[rng.randi() % keys.size()]


func _cells_of_type(kind: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in _tiles:
		if _tiles[cell] == kind:
			result.append(cell)
	return result


## Any empty cell touching the cave (diagonals too) becomes a wall
func _add_border_walls() -> void:
	var cave_cells := _tiles.keys()
	for cell in cave_cells:
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				var neighbour: Vector2i = cell + Vector2i(dx, dy)
				if not _tiles.has(neighbour):
					_tiles[neighbour] = IceRules.WALL


## Builds a Level (TileMapLayer + level.gd) with Start and Goal markers,
## the same structure as level_01.tscn, so world.gd can use it unchanged.
func _build_level(start: Vector2i, goal: Vector2i) -> Level:
	var level := Level.new()
	level.tile_set = TILESET
	level.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	level.level_name = "Random"
	level.hint = "Random puzzle (it might not be solvable yet). Press 7 for a new one."

	for cell in _tiles:
		level.set_cell(cell, SOURCE_ID, _atlas_coords_for(_tiles[cell]))

	level.add_child(_make_marker("Start", level.map_to_local(start), START_COLOR))
	level.add_child(_make_marker("Goal", level.map_to_local(goal), GOAL_COLOR))
	return level


## Turns a tile type name into its spot in tiles_1.png.
func _atlas_coords_for(kind: String) -> Vector2i:
	if kind == "ice":
		return ICE_TILE
	if ARROW_TILES.has(kind):
		return ARROW_TILES[kind]
	if CURVE_TILES.has(kind):
		return CURVE_TILES[kind]
	return WALL_TILE  # border walls and rocks


## A Marker2D with a small coloured square, like the Start/Goal nodes.
func _make_marker(marker_name: String, pos: Vector2, color: Color) -> Marker2D:
	var marker := Marker2D.new()
	marker.name = marker_name  # level.gd finds these with $Start and $Goal
	marker.position = pos
	var square := ColorRect.new()
	square.color = color
	square.size = Vector2(12, 12)
	square.position = Vector2(-6, -6)
	marker.add_child(square)
	return marker
