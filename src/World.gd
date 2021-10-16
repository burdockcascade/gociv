extends Node2D

onready var terrain = $Terrain
onready var terrain2 = $Terrain2
onready var resources = $Resources


####################################################################################################
## MAP DATA

var celldata = {}

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

####################################################################################################
## MAP GENERATOR

var tile_height = {
	0 : TILE.DEEP_OCEAN,
	1 : TILE.SHALLOW_OCEAN,
	2 : TILE.GRASSLAND,
	3 : TILE.HILLS,
	4 : TILE.MOUNTAINS
}

var rng = RandomNumberGenerator.new()
var noise = OpenSimplexNoise.new()
var mapsize = Vector2(128, 128)

func _ready():

	randomize()
	rng.randomize()

	# Noise Configure
	noise.seed = randi()
	noise.octaves = 0.5
	noise.period = 20.0
	noise.persistence = 0.5

	generate_terrain(mapsize)


func generate_terrain(dim):

	# set terrain
	for x in dim.x:
		for y in dim.y:

			var v = Vector2(x, y)
			celldata[v] = {}

			# noise per tile
			var n = int(abs(4 * noise.get_noise_2dv(v)))
			var t = tile_height.get(n)

			if n == 2:
				t = select_random_green_tile(v)

			# Set Terrain Wrap
#			if (x == 0 or x == dim.x-1) and n > 1:
#				t = TILE.SHALLOW_OCEAN

			# set tundra
#			if (y < 3 or y > dim.x-3):
#				t = TILE.TUNDRA

			# set ice caps
			if y == 0 or y == dim.y-1:
				t = TILE	.ARCTIC

			# set terrain
			terrain.set_cellv(v, t)

			# set hills & mountains
			if n == 3 and t != TILE.ARCTIC:
				terrain2.set_cellv(v, 0)
			elif n == 4 and t != TILE.ARCTIC:
				terrain2.set_cellv(v, 16)

			if t == TILE.FOREST:
				add_random_trees(v)

			# resources
			add_random_resource(v, t)


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

	terrain2.set_cellv(v, t)


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
	celldata[v].resource = r

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
