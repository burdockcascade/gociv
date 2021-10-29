extends Node2D

onready var map: Node2D = $Map
onready var units: TileMap = $Units

var mapdata: Dictionary

const MAPSIZE_LARGE: Vector2 = Vector2(128, 128)
const MAPSIZE_TEST: Vector2 = Vector2(32, 32)

func _ready() -> void:

	# generate map
	mapdata = map.new_map(MAPSIZE_TEST)
	units.mapdata = mapdata

	# add unit to map
	var mapv = map.random_sea_tile()
	units.add_unit(units.unit.transporter, mapv)


