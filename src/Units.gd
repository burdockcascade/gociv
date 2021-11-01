extends Node2D

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn"
	},
	caravan = {
		scene = "res://src/units/Caravan.tscn"
	}

}

onready var map = get_node("../Map")
var mapdata: Dictionary
var active_unit

####################################################################################################
## Unit Creation

func add_unit(unit: Dictionary, mapv: Vector2) -> Node2D:

	var u: Node2D = load(unit.scene).instance()

	move_unit_to_mapv(u, mapv)

	# add
	u.add_to_group("unit")
	add_child(u)

	return u

####################################################################################################
## Find Units

func get_units_at_cellv(cellv: Vector2) -> Array:
	return get_tree().get_nodes_in_group("mapv_" + str(cellv))


func _on_Map_world_scrolled(direction: Vector2) -> void:
	for unit in get_children():
		unit.position = mapdata[unit.current_mapv].worldv


func tile_selected(mapv: Vector2) -> void:

	if active_unit:
		active_unit.deactivate_selector()

	var units = mapdata[mapv].units

	if units.size() > 1:
		print('too many - will show dialog window?')
	elif units.size() == 1:
		print("found one unit")
		units[0].activate()
		active_unit = units[0]


####################################################################################################
## Unit Movement

func move_active_unit(direction: Vector2) -> void:
	if active_unit and move_unit_to_mapv(active_unit, map.wrap_mapv(active_unit.current_mapv + direction)):
		active_unit.play_sound()

func move_unit_to_mapv(unit: Node2D, mapv: Vector2) -> bool:

	var mapd: Dictionary = mapdata[mapv]

	# stop movement over land or water
	if mapd.is_land != unit.over_land and mapd.is_water != unit.over_water:
		return false

	# remove from group
	remove_from_group("mapv_" + str(unit))
	mapdata[unit.current_mapv].units.erase(unit)

	# set position of unit
	unit.position = mapd.worldv
	unit.current_mapv = mapv

	# add to group
	add_to_group("mapv_" + str(unit))
	mapdata[mapv].units.append(unit)

	return true
