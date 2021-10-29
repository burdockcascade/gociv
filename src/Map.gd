extends Node2D

signal tile_selected(mapv)
signal world_scrolled(direction)

onready var terrain = $Terrain
onready var terrain2 = $Terrain2
onready var resources = $Resources

####################################################################################################
## MAP DATA

var mapdata: Dictionary = {}
var landnav: AStar2D = AStar2D.new()
var waternav: AStar2D = AStar2D.new()

enum TILE {

	SHALLOW_OCEAN,
	DEEP_OCEAN,
	DESERT,
	PLAINS,
	GRASSLAND,
	FOREST,
	HILLS,
	MOUNTAINS,
	TUNDRA,
	ARCTIC,
	SWAMP,
	JUNGLE,

}

enum TERRAIN2 {

	SMALL_FOREST = 49
	MEDIUM_FOREST
	LARGE_FOREST

}

enum RESOURCE {

	OASIS,
	OIL,
	OILRIG
	BUFFALO,
	WHEAT,
	IRIGATION,
	PHEASENT,
	SILK,
	FARMLAND,
	COAL,
	WINE,
	MINING,
	GOLD,
	IRON,
	POLLUTION,
	TUNDRA_GAME,
	FURS,
	VILLAGE,
	IVORY,
	ARCTIC_OIL,
	FALLOUT,
	PEAT,
	SPICE,
	OIL_PLATFORM,
	GEMS,
	FRUIT,
	FISH,
	WHALES,
	SEALS,
	FOREST_GAME,
	HORSES,
	SHEILD

}

var mapsize
var mapwindow_startx = 0
var mapwindow_endx = 0

var map_offset = Vector2.ZERO

func _ready():

	rng.randomize()

func new_map(size):

	self.mapsize = size
	mapwindow_endx = mapsize.x-1

	# generate map
	generate_terrain(size)

	draw_map()

	# all done
	return mapdata


func _unhandled_input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_click"):

		var mapv: Vector2 = terrain.world_to_map(get_global_mouse_position())
		emit_signal("tile_selected", mapv)

	if event.is_action_pressed("ui_left"):
		slide_map_left()

	if event.is_action_pressed("ui_right"):
		slide_map_right()

####################################################################################################
## DRAW WORLD

var ptr = 0

func slide_map_left():

	var mx = mapsize.x - 1

	for mapd in mapdata.values():

		if mapd.cellv.x == 0:
			mapd.cellv.x = mx
		else:
			mapd.cellv.x -= 1

	draw_map()
	emit_signal("world_scrolled", Vector2.LEFT)


func slide_map_right():

	var mx = mapsize.x - 1

	for mapd in mapdata.values():

		if mapd.cellv.x == mx:
			mapd.cellv.x = 0
		else:
			mapd.cellv.x += 1

	draw_map()
	emit_signal("world_scrolled", Vector2.RIGHT)

func draw_map():

	# paint map
	for mapv in mapdata:

		var mapd = mapdata[mapv]
		var cellv = mapd.cellv

		# update world position for mapv
		mapd.worldv = terrain.map_to_world(cellv)

		# paint terrain
		terrain.set_cellv(cellv, mapd.tile)

		# paint upper terrain
		terrain2.set_cellv(cellv, mapd.terrain2)

		# paint resources
		resources.set_cellv(cellv, mapd.resource)

		# paint settlements

		# paint units

		# paint fog



func clear_cellv(mapv):

	var cd = mapdata[mapv]
	var cellv = cd.cellv

	terrain.set_cellv(cellv, -1)
	terrain2.set_cellv(cellv, -1)
	resources.set_cellv(cellv, -1)


####################################################################################################
## MAP GENERATOR

var tile_height = {
	0 : TILE.SHALLOW_OCEAN,
	1 : TILE.SHALLOW_OCEAN,
	2 : TILE.GRASSLAND,
	3 : TILE.HILLS,
	4 : TILE.MOUNTAINS
}

var rng = RandomNumberGenerator.new()

func generate_terrain(dim):

	var noise = OpenSimplexNoise.new()
	randomize()

	# Noise Configure
	noise.seed = randi()
	noise.octaves = 0.5
	noise.period = 20.0
	noise.persistence = 0.5

	# set terrain
	for x in dim.x:
		for y in dim.y:

			var v = Vector2(x, y)
			mapdata[v] = {
				cellv = v,
				worldv = terrain.map_to_world(v),
				units = [],
				tile = -1,
				terrain2 = -1,
				resource = -1
			}


			var cd = mapdata[v]

			# noise per tile
			var n = int(abs(4 * noise.get_noise_2dv(v)))
			cd.tile = tile_height.get(n)

			if n == 2:
				cd.tile = select_random_green_tile(v)

			# Set Terrain Wrap
#			if (x == 0 or x == dim.x-1) and n > 1:
#				t = TILE.SHALLOW_OCEAN

			# set tundra
#			if (y < 3 or y > dim.x-3):
#				cd.tile = TILE.TUNDRA

			# set ice caps
			if y == 0 or y == dim.y-1:
				cd.tile = TILE.ARCTIC


			# set hills & mountains
			if n == 3 and cd.tile != TILE.ARCTIC:
				cd.terrain2 = 0
			elif n == 4 and cd.tile != TILE.ARCTIC:
				cd.terrain2 = 16
			elif cd.tile == TILE.FOREST:
				cd.terrain2 = add_random_trees(v)


			# resources
			add_random_resource(v, cd.tile)


func select_random_green_tile(v):

	var t = TILE.GRASSLAND

	# random tile assignment
	match rng.randi_range(1, 12):
		1,2,3: t = TILE.PLAINS
		4,5,6: t = TILE.FOREST
		8: t = TILE.JUNGLE
		9: if tile_has_sea_access(v): t = TILE.SWAMP
		10: if tile_in_middle_third(v): t = TILE.DESERT

	return t

func add_random_trees(v):

	var t = -1

	match rng.randi_range(1, 3):
		1: t = TERRAIN2.SMALL_FOREST
		2: t = TERRAIN2.MEDIUM_FOREST
		3: t = TERRAIN2.LARGE_FOREST

	return t


func add_random_resource(v, t):

	var r = -1

	# set resources
	match t:

		TILE.TUNDRA:
			match rng.randi_range(1, 100):
				1: r = RESOURCE.TUNDRA_GAME
				2: r = RESOURCE.ARCTIC_OIL
				3: r = RESOURCE.SEALS
				4: r = RESOURCE.IVORY
				5: r = RESOURCE.FURS

		TILE.PLAINS, TILE.GRASSLAND:
			match rng.randi_range(1, 80):
				1: r = RESOURCE.HORSES
				2: r = RESOURCE.BUFFALO
				3: r = RESOURCE.WHEAT
				4: r = RESOURCE.SHEILD
				5: r = RESOURCE.VILLAGE

		TILE.FOREST:
			match rng.randi_range(1, 30):
				1: r = RESOURCE.SILK
				2: r = RESOURCE.VILLAGE

		TILE.DESERT:
			match rng.randi_range(1, 30):
				1: r = RESOURCE.OIL
				2: r = RESOURCE.OASIS

		TILE.HILLS:
			match rng.randi_range(1, 25):
				1: r = RESOURCE.GOLD
				2: r = RESOURCE.IRON
				3: r = RESOURCE.COAL
				4: r = RESOURCE.WINE
				5: r = RESOURCE.GEMS

		TILE.MOUNTAINS:
			match rng.randi_range(1, 30):
				1: r = RESOURCE.GOLD
				2: r = RESOURCE.IRON
				3: r = RESOURCE.COAL
				4: r = RESOURCE.GEMS

		TILE.SHALLOW_OCEAN:
			match rng.randi_range(1, 100):
				1:  r = RESOURCE.FISH
				2:  r = RESOURCE.WHALES

		TILE.JUNGLE:
			match rng.randi_range(1, 10):
				1: r = RESOURCE.SPICE

		TILE.SWAMP:
			match rng.randi_range(1, 10):
				1: r = RESOURCE.PEAT

	resources.set_cellv(v, r)
	mapdata[v].resource = r

####################################################################################################
## TILE HELPER FUNCTIONS

const neighbours = [
	Vector2.UP,
	Vector2.UP + Vector2.RIGHT,
	Vector2.RIGHT,
	Vector2.DOWN + Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.LEFT,
	Vector2.UP + Vector2.LEFT
]

func tile_is_sea(v) -> bool:
	return terrain.get_cellv(v) == TILE.DEEP_OCEAN or terrain.get_cellv(v) == TILE.SHALLOW_OCEAN

func tile_is_land(v) -> bool:
	return !tile_is_sea(v)

func tile_has_land_access(v) -> bool:
	for n in neighbours:
		if tile_is_land(v + n):
			return true

	return false

func tile_has_sea_access(v) -> bool:
	for n in neighbours:
		if tile_is_sea(v + n):
			return true

	return false

func tile_in_top_third(v) -> bool:
	return v.y < mapsize.y/3

func tile_in_lower_third(v) -> bool:
	return v.y > (mapsize.y/3) * 2

func tile_in_middle_third(v) -> bool:
	return !tile_in_top_third(v) and !tile_in_lower_third(v)

####################################################################################################
## PUBLIC FUNCTIONS

func any_random_tile():
	return _find_random_tile(true, true)

func random_land_tile():
	return _find_random_tile(true, false)

func random_sea_tile():
	return _find_random_tile(false, true)

func _find_random_tile(land, water):
	while true:
		var v = Vector2(rng.randi_range(0, mapsize.x-1), rng.randi_range(0, mapsize.y-1))
		if tile_is_land(v) == land and tile_is_sea(v) == water:
			return v

