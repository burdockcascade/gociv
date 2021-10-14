extends Node2D

onready var terrain = $Terrain
onready var resources = $Resources

enum TILE {

	DESERT,
	BLACK,
	GRASSLAND,
	PLAINS,
	MOUNTAINS,
	SHALLOW_OCEAN,
	HILLS,
	TUNDRA,
	ARCTIC,
	SWAMP,
	DEEP_OCEAN,
	JUNGLE,
	FOREST,

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
	noise.period = 15.0
	noise.persistence = 2

	generate_terrain(Vector2(128, 128))


func generate_terrain(dim):

	# set ocean
	for x in dim.x:
		for y in dim.y:

			# noise per tile
			var n = int(abs(4 * noise.get_noise_2d(x, y)))
			var t = tile_height.get(n)

			if (x < 2 or x > dim.x-2) and n > 1:
				t = TILE.SHALLOW_OCEAN

			# set tile
			terrain.set_cell(x, y, t)


	# set ice caps
	for x in dim.x:
		terrain.set_cell(x, 0, TILE.ARCTIC)
		terrain.set_cell(x, dim.y, TILE.ARCTIC)
