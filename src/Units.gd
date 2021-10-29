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

func add_unit(unit: Dictionary, mapv: Vector2) -> void:

	var mapd = mapdata[mapv]
	var u = load(unit.scene).instance()

	# set position of unit
	u.position = mapd.worldv
	u.at_mapv = mapv

	# assign to groups
	u.add_to_group("unit")
	u.add_to_group("mapv_" + str(mapv))

	# add
	mapd.units.append(u)
	add_child(u)


func get_units_at_cellv(cellv: Vector2) -> Array:
	return get_tree().get_nodes_in_group("mapv_" + str(cellv))


func _on_Map_world_scrolled(direction: Vector2) -> void:
	for unit in get_children():
		unit.position = mapdata[unit.at_mapv].worldv


func _on_Map_tile_selected(mapv: Vector2) -> void:

	var units = mapdata[mapv].units

	if units.size() > 1:
		print('toomany')
	elif units.size() == 1:
		units[0].activate()

