extends Node2D

onready var map = $Map
onready var wobjects = $WorldObjects

var celldata

func _on_Map_tile_selected(tile_vector, tile_data):
	prints("clicked on", tile_vector, tile_data)
	print(wobjects.get_units_at_cellv(tile_vector))



func _ready():

	# generate map
	celldata = map.new_map(Vector2(128, 128))

#	wobjects.celldata = celldata

	# add unit to map
#	wobjects.add_unit(wobjects.unit.transporter, map.random_sea_tile())

func _unhandled_input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_click"):

		var cellv: Vector2 = map.terrain.world_to_map(get_global_mouse_position())

		if celldata.has(cellv):
			emit_signal("tile_selected", cellv, celldata[cellv])


