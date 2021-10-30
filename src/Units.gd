extends Node2D

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn",
		max_move = 5,
		land = false,
		water = true,
	},
	caravan = {
		scene = "res://src/units/Caravan.tscn",
		max_move = 3,
		land = true,
		water = false,
	}

}

var mapdata: Dictionary
var active_unit

####################################################################################################
## Unit Creation

func add_unit(unit: Dictionary, mapv: Vector2) -> Node2D:

	var u: Node2D = load(unit.scene).instance()

	u.mapdata = mapdata
	u.set_mapv(mapv)

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
		unit.position = mapdata[unit.mapv].worldv


func tile_selected(mapv: Vector2) -> void:

	var units = mapdata[mapv].units

	if units.size() > 1:
		print('toomany')
	elif units.size() == 1:
		print("found one unit")
		units[0].activate()
		active_unit = units[0]

func move_active_unit(direction):
	active_unit.move_by_direction(direction)

