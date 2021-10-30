extends Node2D

onready var selector = $Selector

# warfare
export var shield: int = 0
export var weapon: int = 0
export var stealth: bool = false

# freight
export var capacity: int = 0

# value
export var build_cost: int = 0
export var support_cost: int = 0
export var build_cycle: int = 0

# movement
export var max_movement: int = 0
export var over_land: bool = false
export var over_water: bool = false
export var visibility: int = 0

onready var movement_sound = $MovementSound

var mapdata: Dictionary

var current_mapv = Vector2.ZERO

####################################################################################################
## Selector

func activate():
	selector.visible = true
	selector.playing = true

func deactivate_selector():
	selector.visible = false
	selector.playing = false


####################################################################################################
## Unit Movement

func move_by_direction(direction: Vector2):
	set_mapv(current_mapv + direction)

	if movement_sound:
		movement_sound.play()

func set_mapv(mapv: Vector2) -> void:

	var mapd: Dictionary = mapdata[mapv]

	# stop movement over land or water
	if mapd.is_land != over_land and mapd.is_water != over_water:
		return

	# remove from group
	remove_from_group("mapv_" + str(current_mapv))
	mapdata[current_mapv].units.erase(self)

	# set position of unit
	position = mapd.worldv
	current_mapv = mapv

	# add to group
	add_to_group("mapv_" + str(current_mapv))
	mapdata[mapv].units.append(self)
