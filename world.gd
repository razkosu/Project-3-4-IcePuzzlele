extends Node2D

const TILE := 16

@onready var levels: Array = [$Level1, $Level2]
@onready var player = $Player
@onready var camera: Camera2D = $Player/Camera2D

var goal_marker: ColorRect


func _ready() -> void:
	# Gold square on the goal
	goal_marker = ColorRect.new()
	goal_marker.color = Color(1.0, 0.85, 0.2, 0.9)
	goal_marker.size = Vector2(TILE - 4, TILE - 4)
	goal_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(goal_marker)
	move_child(goal_marker, player.get_index())

	# Controls text
	var layer := CanvasLayer.new()
	add_child(layer)
	var hud := Label.new()
	hud.text = "1: Basic    2: Hard    R: Reset"
	hud.position = Vector2(12, 8)
	hud.add_theme_font_size_override("font_size", 20)
	layer.add_child(hud)

	load_level(0)


func load_level(index: int) -> void:
	for i in levels.size():
		var on: bool = (i == index)
		levels[i].visible = on
		levels[i].enabled = on

	var lvl: TileMapLayer = levels[index]
	player.teleport(lvl.get_node("Start").global_position)
	goal_marker.global_position = lvl.get_node("Goal").global_position - goal_marker.size / 2.0
	_fit_camera(lvl)


func _fit_camera(lvl: TileMapLayer) -> void:
	var used := lvl.get_used_rect()
	var pixel_pos := Vector2(used.position) * TILE
	var pixel_size := Vector2(used.size) * TILE
	var view := get_viewport_rect().size
	camera.top_level = true                          # stop following the player
	camera.global_position = pixel_pos + pixel_size / 2.0
	var z := minf(view.x / pixel_size.x, view.y / pixel_size.y) * 0.9
	camera.zoom = Vector2(z, z)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_1:
			load_level(0)
		KEY_2:
			load_level(1)
