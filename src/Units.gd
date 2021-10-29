extends TileMap

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn",
		max_move = 5,
		land = false,
		water = true,
	}

}

var mapdata

func add_unit(unit, mapv):

	var u = load(unit.scene).instance()
	u.position = mapdata[mapv].worldv
	u.at_mapv = mapv
	u.add_to_group("unit")
	u.add_to_group("mapv_" + str(mapv))


	add_child(u)


func get_units_at_cellv(cellv):
	return get_tree().get_nodes_in_group("mapv_" + str(cellv))

func wrap_units(cellv):
	var units = get_units_at_cellv(cellv)

	for unit in units:
		pass


func _on_Map_world_scrolled(direction):
	for unit in get_children():
		unit.position = mapdata[unit.at_mapv].worldv
