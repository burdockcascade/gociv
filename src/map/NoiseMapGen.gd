class_name NoiseMapGen

enum HEIGHT {
	DEEP_SEA,
	SHALLOW_OCEAN,
	FLATLAND,
	HILL,
	MOUNTAIN
}

var tile_height: Dictionary = {
	HEIGHT.DEEP_SEA : WorldMap.TILE.SHALLOW_OCEAN,
	HEIGHT.SHALLOW_OCEAN : WorldMap.TILE.SHALLOW_OCEAN,
	HEIGHT.FLATLAND : WorldMap.TILE.GRASSLAND,
	HEIGHT.HILL : WorldMap.TILE.HILLS,
	HEIGHT.MOUNTAIN : WorldMap.TILE.MOUNTAINS
}

var worldmap: WorldMap

####################################################################################################
## MAP GENERATOR

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var noise: OpenSimplexNoise = OpenSimplexNoise.new()

func generate(dim: Vector2) -> WorldMap:
	
	worldmap = WorldMap.new()
	
	worldmap.dimension = dim
	
	randomize()
	
	rng.randomize()

	# Noise Configure
	noise.seed = randi()
	noise.octaves = 0.3
	noise.period = 20.0
	noise.persistence = 0.5

	# set terrain
	for x in dim.x:
		for y in dim.y:

			var v: Vector2 = Vector2(x, y)

			var mapd: Dictionary = {
				
				# positional
				cellv = v,
				worldv = -1,
				
				# units
				units = [],
				
				# tiles
				tile = -1,
				terrain2 = -1,
				resource = -1,
				
				# terrain
				height = 0,
				is_water = false,
				is_land = false,
				travel_cost = 1,
				
				# exploration
				explored = false,
				visible = false,
				fog = true
			}

			# noise per tile
			mapd.height = int(abs(5 * noise.get_noise_2dv(v)))
			mapd.tile = tile_height.get(mapd.height)

			if mapd.height == HEIGHT.FLATLAND:
				mapd.tile = select_random_green_tile(v)

			# set tundra
#			if (y < 3 or y > dim.x-3):
#				cd.tile = WorldMap.TILE.TUNDRA

			# set ice caps
			if y == 0 or y == dim.y-1:
				mapd.tile = WorldMap.TILE.ARCTIC


			# set hills & mountains
			if mapd.height == HEIGHT.HILL and mapd.tile != WorldMap.TILE.ARCTIC:
				mapd.terrain2 = 0
				mapd.travel_cost = 1
			elif mapd.height == HEIGHT.MOUNTAIN and mapd.tile != WorldMap.TILE.ARCTIC:
				mapd.terrain2 = WorldMap.RESOURCE.TUNDRA_GAME
			elif mapd.tile == WorldMap.TILE.FOREST:
				mapd.terrain2 = add_random_trees(v)

			# is water tile
			mapd.is_water = (mapd.tile == WorldMap.TILE.DEEP_OCEAN) or (mapd.tile == WorldMap.TILE.SHALLOW_OCEAN)

			# is land tile
			mapd.is_land = !mapd.is_water

			# resources
			mapd.resource = add_random_resource(v, mapd.tile)

			worldmap.data[v] = mapd
			
	return worldmap


func select_random_green_tile(v: Vector2) -> int:

	var t: int = WorldMap.TILE.GRASSLAND

	# random tile assignment
	match rng.randi_range(1, 12):
		1,2,3: t = WorldMap.TILE.PLAINS
		4,5,6: t = WorldMap.TILE.FOREST
		8: t = WorldMap.TILE.JUNGLE
		9: if worldmap.tile_has_sea_access(v): t = WorldMap.TILE.SWAMP
		10: if worldmap.tile_in_middle_third(v): t = WorldMap.TILE.DESERT

	return t

func add_random_trees(_v: Vector2) -> int:

	var t: int = -1

	match rng.randi_range(1, 3):
		1: t = WorldMap.TERRAIN2.SMALL_FOREST
		2: t = WorldMap.TERRAIN2.MEDIUM_FOREST
		3: t = WorldMap.TERRAIN2.LARGE_FOREST

	return t


func add_random_resource(v: Vector2, t: int) -> int:

	var r: int = -1

	# set resources
	match t:

		WorldMap.TILE.TUNDRA:
			match rng.randi_range(1, 100):
				1: r = WorldMap.RESOURCE.TUNDRA_GAME
				2: r = WorldMap.RESOURCE.ARCTIC_OIL
				3: r = WorldMap.RESOURCE.SEALS
				4: r = WorldMap.RESOURCE.IVORY
				5: r = WorldMap.RESOURCE.FURS

		WorldMap.TILE.PLAINS, WorldMap.TILE.GRASSLAND:
			match rng.randi_range(1, 80):
				1: r = WorldMap.RESOURCE.HORSES
				2: r = WorldMap.RESOURCE.BUFFALO
				3: r = WorldMap.RESOURCE.WHEAT
				4: r = WorldMap.RESOURCE.SHEILD
				5: r = WorldMap.RESOURCE.VILLAGE

		WorldMap.TILE.FOREST:
			match rng.randi_range(1, 30):
				1: r = WorldMap.RESOURCE.SILK
				2: r = WorldMap.RESOURCE.VILLAGE

		WorldMap.TILE.DESERT:
			match rng.randi_range(1, 30):
				1: r = WorldMap.RESOURCE.OIL
				2: r = WorldMap.RESOURCE.OASIS

		WorldMap.TILE.HILLS:
			match rng.randi_range(1, 20):
				3: r = WorldMap.RESOURCE.COAL
				4: r = WorldMap.RESOURCE.WINE

		WorldMap.TILE.MOUNTAINS:
			match rng.randi_range(1, 10):
				1: r = WorldMap.RESOURCE.GOLD
				2: r = WorldMap.RESOURCE.IRON
				3: r = WorldMap.RESOURCE.COAL
				4: r = WorldMap.RESOURCE.GEMS

		WorldMap.TILE.SHALLOW_OCEAN:
			match rng.randi_range(1, 100):
				1:  r = WorldMap.RESOURCE.FISH
				2:  r = WorldMap.RESOURCE.WHALES

		WorldMap.TILE.JUNGLE:
			match rng.randi_range(1, 10):
				1: r = WorldMap.RESOURCE.SPICE

		WorldMap.TILE.SWAMP:
			match rng.randi_range(1, 10):
				1: r = WorldMap.RESOURCE.PEAT

	return r
