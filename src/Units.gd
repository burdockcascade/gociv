extends TileMap

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn",
		max_move = 5,
		land = false,
		water = true,
	}

}

var celldata

func add_unit(unit, cellv):

	var u = load(unit.scene).instance()
	u.position = celldata[cellv].worldv
	u.add_to_group("unit")
	u.add_to_group("cellv_" + str(cellv))

	print("cellv_" + str(cellv))

	add_child(u)


func get_units_at_cellv(cellv):
	return get_tree().get_nodes_in_group("cellv_" + str(cellv))

func wrap_units(cellv):
	var units = get_units_at_cellv(cellv)

	for unit in units:
		pass
