extends TileMap

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn",
		max_move = 5,
		land = false,
		water = true,
	}

}

var mapdata: Dictionary
var active_unit

####################################################################################################
## Unit Creation

func add_unit(unit: Dictionary, mapv: Vector2) -> Node2D:

	var u = load(unit.scene).instance()

	_set_unit_position(u, mapv)

	# add
	add_child(u)

	return u

####################################################################################################
## Find Units

func get_units_at_cellv(cellv: Vector2) -> Array:
	return get_tree().get_nodes_in_group("mapv_" + str(cellv))


func _on_Map_world_scrolled(direction: Vector2) -> void:
	for unit in get_children():
		unit.position = mapdata[unit.mapv].worldv


func tile_selected(mapv: Vector2) -> void:

	var units = mapdata[mapv].units

	if units.size() > 1:
		print('toomany')
	elif units.size() == 1:
		print("found one unit")
		units[0].activate()
		active_unit = units[0]

####################################################################################################
## Unit Movement

func move_active_unit(direction: Vector2):
	if !active_unit:
		return

	_set_unit_position(active_unit, active_unit.mapv + direction)

func _set_unit_position(u: Node2D, mapv: Vector2) -> void:

	var mapd: Dictionary = mapdata[mapv]

	# stop movement over land or water
	if mapd.is_land != u.over_land and mapd.is_water != u.over_water:
		return

	# set position of unit
	u.position = mapd.worldv
	u.mapv = mapv

	# assign to groups
	u.add_to_group("unit")
	u.add_to_group("mapv_" + str(mapv))

	# append to mapd
	mapd.units.append(u)
