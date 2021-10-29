extends Node2D

onready var map = $Map
onready var wobjects = $WorldObjects

var mapdata

func _ready():

	# generate map
	mapdata = map.new_map(Vector2(32, 32))
	wobjects.mapdata = mapdata

	# add unit to map
	wobjects.add_unit(wobjects.unit.transporter, map.random_sea_tile())


