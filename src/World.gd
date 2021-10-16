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

			# init celldata for position
			celldata[v] = {}

			# noise per tile
			var n = int(abs(4 * noise.get_noise_2dv(v)))
			var t = tile_height.get(n)

			if n == 2:
				t = select_random_green_tile(v)

			# Set Terrain Wrap
			if (x == 0 or x == dim.x-1) and n > 1:
				t = TILE.SHALLOW_OCEAN

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

	# hot
	if tile_in_middle_third(v):
		match rng.randi_range(1, 12):
			1,2,3: return TILE.PLAINS
			5, 6, 7: return TILE.FOREST
			9: return TILE.JUNGLE
			8: return TILE.SWAMP
			10: return TILE.DESERT
			_: return TILE.GRASSLAND

	# cold
	else:

		match rng.randi_range(1, 12):
			1,2,3,4: return TILE.PLAINS
			7: return TILE.FOREST
			_: return TILE.GRASSLAND

func add_random_trees(v):

	match rng.randi_range(1, 3):
		1: terrain2.set_cellv(v, TERRAIN2.SMALL_FOREST)
		2: terrain2.set_cellv(v, TERRAIN2.MEDIUM_FOREST)
		3: terrain2.set_cellv(v, TERRAIN2.LARGE_FOREST)


func add_random_resource(v, t):

	# set resources
	match t:

		TILE.TUNDRA:
			match rng.randi_range(1, 100):
				1: add_resource_to_tile(v, RESOURCE.TUNDRA_GAME)
				2: add_resource_to_tile(v, RESOURCE.ARCTIC_OIL)
				3: add_resource_to_tile(v, RESOURCE.SEALS)
				4: add_resource_to_tile(v, RESOURCE.IVORY)
				5: add_resource_to_tile(v, RESOURCE.FURS)

		TILE.PLAINS, TILE.GRASSLAND:
			match rng.randi_range(1, 80):
				1: add_resource_to_tile(v, RESOURCE.HORSES)
				2: add_resource_to_tile(v, RESOURCE.BUFFALO)
				3: add_resource_to_tile(v, RESOURCE.WHEAT)
				4: add_resource_to_tile(v, RESOURCE.SHEILD)
				5: add_resource_to_tile(v, RESOURCE.VILLAGE)

		TILE.FOREST:
			match rng.randi_range(1, 30):
				1: add_resource_to_tile(v, RESOURCE.SILK)
				2: add_resource_to_tile(v, RESOURCE.VILLAGE)

		TILE.DESERT:
			match rng.randi_range(1, 30):
				1: add_resource_to_tile(v, RESOURCE.OIL)
				2: add_resource_to_tile(v, RESOURCE.OASIS)

		TILE.HILLS:
			match rng.randi_range(1, 25):
				1: add_resource_to_tile(v, RESOURCE.GOLD)
				2: add_resource_to_tile(v, RESOURCE.IRON)
				3: add_resource_to_tile(v, RESOURCE.COAL)
				4: add_resource_to_tile(v, RESOURCE.WINE)
				5: add_resource_to_tile(v, RESOURCE.GEMS)

		TILE.MOUNTAINS:
			match rng.randi_range(1, 30):
				1: add_resource_to_tile(v, RESOURCE.GOLD)
				2: add_resource_to_tile(v, RESOURCE.IRON)
				3: add_resource_to_tile(v, RESOURCE.COAL)
				4: add_resource_to_tile(v, RESOURCE.GEMS)

		TILE.SHALLOW_OCEAN:
			match rng.randi_range(1, 100):
				1: add_resource_to_tile(v, RESOURCE.FISH)
				2: add_resource_to_tile(v, RESOURCE.WHALES)

		TILE.JUNGLE:
			match rng.randi_range(1, 10):
				1: add_resource_to_tile(v, RESOURCE.SPICE)

		TILE.SWAMP:
			match rng.randi_range(1, 10):
				1: add_resource_to_tile(v, RESOURCE.PEAT)

func add_resource_to_tile(v, r):
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
