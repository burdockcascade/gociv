extends Node2D

onready var map = get_node("../Map")
var mapdata: Dictionary
var active_unit

####################################################################################################
## Unit Creation

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

func add_unit(id: String, mapv: Vector2) -> Node2D:

	var u: Node2D = load(unit[id].scene).instance()

	move_unit_to_mapv(u, mapv)

	# add
	u.add_to_group("unit")
	u.add_to_group("unit_" + id)
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
		active_unit.deactivate()

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

		# play sfx
		active_unit.movement_sound.play()

		# deactivate if turn over
		if active_unit.current_travel > active_unit.max_travel:
			active_unit.turn_over()
			active_unit = null


func move_unit_to_mapv(unit: Node2D, new_mapv: Vector2) -> bool:

	var old_mapv: Vector2 = unit.current_mapv
	var old_mapd: Dictionary = mapdata[old_mapv]
	var new_mapd: Dictionary = mapdata[new_mapv]

	# stop movement over land or water
	if new_mapd.is_land != unit.over_land and new_mapd.is_water != unit.over_water:
		return false

	# remove from group
	remove_from_group("mapv_" + str(old_mapv))
	old_mapd.units.erase(unit)

	# update travel (cost of leaving the tile)
	unit.current_travel += old_mapd.travel_cost

	# set position of unit
	unit.position = new_mapd.worldv
	unit.current_mapv = new_mapv

	# add to group
	add_to_group("mapv_" + str(new_mapv))
	mapdata[new_mapv].units.append(unit)

	return true
