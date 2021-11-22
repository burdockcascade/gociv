extends Node2D

onready var camera: Camera2D = $MainCamera
onready var map: Node2D = $Map

const MAPSIZE_LARGE: Vector2 = Vector2(128, 128)
const MAPSIZE_MEDIUM: Vector2 = Vector2(64, 64)
const MAPSIZE_TEST: Vector2 = Vector2(32, 32)

####################################################################################################
## READY

func _ready() -> void:

	# generate map
	map.new_map(MAPSIZE_TEST)
	
	# start position for player
	var startpos = map.get_player_start_location()
	
	# add unit to map
	var unit = map.add_unit("explorer", startpos)
	
	camera.position = unit.position
	
	

	


func _on_Button_pressed():
	
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.new_turn()
