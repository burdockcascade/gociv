extends TileMap

var celldata = {}

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

	# Configure
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 30.0
	noise.persistence = 0.5

	generate_terrain(Vector2(64, 64))



func generate_terrain(dim):

	# set ocean
	for x in dim.x:
		for y in dim.y:

			var n = int(abs(5 * noise.get_noise_2d(x, y)))

			set_cell(x, y, tile_height.get(n))


	# set ice caps
	for x in dim.x:
		set_cell(x, 0, TILE.ARCTIC)
		set_cell(x, dim.y, TILE.ARCTIC)
