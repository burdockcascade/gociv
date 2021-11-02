extends Node2D

onready var map: Node2D = $Map
onready var units: Node2D = $Units

var mapdata: Dictionary

const MAPSIZE_LARGE: Vector2 = Vector2(128, 128)
const MAPSIZE_MEDIUM: Vector2 = Vector2(64, 64)
const MAPSIZE_TEST: Vector2 = Vector2(32, 32)

####################################################################################################
## Unit DB

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn"
	},
	caravan = {
		scene = "res://src/units/Caravan.tscn"
	},
	explorer = {
		scene = "res://src/units/Explorer.tscn"
	}

}

####################################################################################################
## READY

func _ready() -> void:

	# generate map
	mapdata = map.new_map(MAPSIZE_MEDIUM)
	units.mapdata = mapdata

	# add unit to map
	units.add_unit(unit.transporter, map.random_sea_tile())
	units.add_unit(unit.caravan, map.random_land_tile())
	units.add_unit(unit.explorer, map.random_land_tile())

####################################################################################################
## UI CONTROLS

func _unhandled_input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_click"):

		var mapv: Vector2 = map.terrain.world_to_map(get_global_mouse_position())
		units.tile_selected(mapv)


	# move map
	if event.is_action_pressed("ui_move_map_left"):
		map.slide_map_left()
	elif event.is_action_pressed("ui_move_map_right"):
		map.slide_map_right()


	# move unit
	if event.is_action_pressed("ui_left"):
		units.move_active_unit(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		units.move_active_unit(Vector2.RIGHT)
	elif event.is_action_pressed("ui_up"):
		units.move_active_unit(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		units.move_active_unit(Vector2.DOWN)
