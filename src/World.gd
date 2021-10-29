extends Node2D

onready var map: Node2D = $Map
onready var units: TileMap = $Units

var mapdata: Dictionary

const MAPSIZE_LARGE: Vector2 = Vector2(128, 128)
const MAPSIZE_SMALL: Vector2 = Vector2(32, 32)

func _ready() -> void:

	print("Start new world")

	# generate map
	mapdata = map.new_map(MAPSIZE_LARGE)
	units.mapdata = mapdata

	# add unit to map
#	units.add_unit(units.unit.transporter, map.random_sea_tile())


