extends Node2D

onready var map: Node2D = $Map

const MAPSIZE_LARGE: Vector2 = Vector2(128, 128)
const MAPSIZE_MEDIUM: Vector2 = Vector2(64, 64)
const MAPSIZE_TEST: Vector2 = Vector2(32, 32)

####################################################################################################
## READY

func _ready() -> void:

	# generate map
	map.new_map(MAPSIZE_TEST)

	# add unit to map
	map.add_unit("caravan", map.random_land_tile())
	map.add_unit("transporter", map.random_sea_tile())
	map.add_unit("explorer", map.random_land_tile())

	


func _on_Button_pressed():
	
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.new_turn()
