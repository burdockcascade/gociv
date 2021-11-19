extends Node2D

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

	u.put_at_mapv(mapv)

	# add
	add_child(u)

	return u

####################################################################################################
## Find Units

func get_units_at_cellv(cellv: Vector2) -> Array:
	return get_tree().get_nodes_in_group("mapv_" + str(cellv))

func tile_selected(mapv: Vector2) -> void:

	if active_unit:
		active_unit.deactivate()

	var units = Game.mapdata[mapv].units

	if units.size() > 1:
		print('too many - will show dialog window?')
	elif units.size() == 1:
		print("found one unit")
		units[0].activate()
