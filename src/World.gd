extends Node2D

onready var terrain = $Terrain
onready var resources = $Resources

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

var tile_height = {
	0 : TILE.DEEP_OCEAN,
	1 : TILE.SHALLOW_OCEAN,
	2 : TILE.GRASSLAND,
	3 : TILE.HILLS,
	4 : TILE.MOUNTAINS
}

var noise = OpenSimplexNoise.new()

func _ready():

	randomize()

	# Noise Configure
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 20.0
	noise.persistence = 2

	generate_terrain(Vector2(128, 128))


func generate_terrain(dim):

	# set terrain
	for x in dim.x:
		for y in dim.y:

			# noise per tile
			var n = int(abs(4 * noise.get_noise_2d(x, y)))
			var t = tile_height.get(n)

			# Set Terrain Wrap
			if (x == 0 or x == dim.x-1) and n > 1:
				t = TILE.SHALLOW_OCEAN

			# set tundra
			if (y < 3 or y > dim.x-3) and tile_is_land(t):
				t = TILE.TUNDRA

			# set terrain
			terrain.set_cell(x, y, t)

			# set resources


	# set ice caps
	for x in dim.x:
		terrain.set_cell(x, 0, TILE.ARCTIC)
		terrain.set_cell(x, dim.y, TILE.ARCTIC)

func tile_is_ocean(t) -> bool:
	return t == TILE.DEEP_OCEAN or t == TILE.SHALLOW_OCEAN

func tile_is_land(t) -> bool:
	return !tile_is_ocean(t)
