class_name NoiseMapGen

enum HEIGHT {
	DEEP_SEA,
	SHALLOW_OCEAN,
	FLATLAND,
	HILL,
	MOUNTAIN
}

var tile_height: Dictionary = {
	HEIGHT.DEEP_SEA : MapConstants.TILE.SHALLOW_OCEAN,
	HEIGHT.SHALLOW_OCEAN : MapConstants.TILE.SHALLOW_OCEAN,
	HEIGHT.FLATLAND : MapConstants.TILE.GRASSLAND,
	HEIGHT.HILL : MapConstants.TILE.HILLS,
	HEIGHT.MOUNTAIN : MapConstants.TILE.MOUNTAINS
}

var mapdata: Dictionary = {}
var mapsize: Vector2

####################################################################################################
## MAP GENERATOR

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var noise: OpenSimplexNoise = OpenSimplexNoise.new()

func generate(dim: Vector2) -> Dictionary:
	
	mapsize = dim
	
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
#				cd.tile = MapConstants.TILE.TUNDRA

			# set ice caps
			if y == 0 or y == dim.y-1:
				mapd.tile = MapConstants.TILE.ARCTIC


			# set hills & mountains
			if mapd.height == HEIGHT.HILL and mapd.tile != MapConstants.TILE.ARCTIC:
				mapd.terrain2 = 0
				mapd.travel_cost = 1
			elif mapd.height == HEIGHT.MOUNTAIN and mapd.tile != MapConstants.TILE.ARCTIC:
				mapd.terrain2 = MapConstants.RESOURCE.TUNDRA_GAME
			elif mapd.tile == MapConstants.TILE.FOREST:
				mapd.terrain2 = add_random_trees(v)

			# is water tile
			mapd.is_water = (mapd.tile == MapConstants.TILE.DEEP_OCEAN) or (mapd.tile == MapConstants.TILE.SHALLOW_OCEAN)

			# is land tile
			mapd.is_land = !mapd.is_water

			# resources
			mapd.resource = add_random_resource(v, mapd.tile)

			mapdata[v] = mapd
			
	return mapdata


func select_random_green_tile(v: Vector2) -> int:

	var t: int = MapConstants.TILE.GRASSLAND

	# random tile assignment
	match rng.randi_range(1, 12):
		1,2,3: t = MapConstants.TILE.PLAINS
		4,5,6: t = MapConstants.TILE.FOREST
		8: t = MapConstants.TILE.JUNGLE
		9: if tile_has_sea_access(v): t = MapConstants.TILE.SWAMP
		10: if tile_in_middle_third(v): t = MapConstants.TILE.DESERT

	return t

func add_random_trees(_v: Vector2) -> int:

	var t: int = -1

	match rng.randi_range(1, 3):
		1: t = MapConstants.TERRAIN2.SMALL_FOREST
		2: t = MapConstants.TERRAIN2.MEDIUM_FOREST
		3: t = MapConstants.TERRAIN2.LARGE_FOREST

	return t


func add_random_resource(v: Vector2, t: int) -> int:

	var r: int = -1

	# set resources
	match t:

		MapConstants.TILE.TUNDRA:
			match rng.randi_range(1, 100):
				1: r = MapConstants.RESOURCE.TUNDRA_GAME
				2: r = MapConstants.RESOURCE.ARCTIC_OIL
				3: r = MapConstants.RESOURCE.SEALS
				4: r = MapConstants.RESOURCE.IVORY
				5: r = MapConstants.RESOURCE.FURS

		MapConstants.TILE.PLAINS, MapConstants.TILE.GRASSLAND:
			match rng.randi_range(1, 80):
				1: r = MapConstants.RESOURCE.HORSES
				2: r = MapConstants.RESOURCE.BUFFALO
				3: r = MapConstants.RESOURCE.WHEAT
				4: r = MapConstants.RESOURCE.SHEILD
				5: r = MapConstants.RESOURCE.VILLAGE

		MapConstants.TILE.FOREST:
			match rng.randi_range(1, 30):
				1: r = MapConstants.RESOURCE.SILK
				2: r = MapConstants.RESOURCE.VILLAGE

		MapConstants.TILE.DESERT:
			match rng.randi_range(1, 30):
				1: r = MapConstants.RESOURCE.OIL
				2: r = MapConstants.RESOURCE.OASIS

		MapConstants.TILE.HILLS:
			match rng.randi_range(1, 20):
				3: r = MapConstants.RESOURCE.COAL
				4: r = MapConstants.RESOURCE.WINE

		MapConstants.TILE.MOUNTAINS:
			match rng.randi_range(1, 10):
				1: r = MapConstants.RESOURCE.GOLD
				2: r = MapConstants.RESOURCE.IRON
				3: r = MapConstants.RESOURCE.COAL
				4: r = MapConstants.RESOURCE.GEMS

		MapConstants.TILE.SHALLOW_OCEAN:
			match rng.randi_range(1, 100):
				1:  r = MapConstants.RESOURCE.FISH
				2:  r = MapConstants.RESOURCE.WHALES

		MapConstants.TILE.JUNGLE:
			match rng.randi_range(1, 10):
				1: r = MapConstants.RESOURCE.SPICE

		MapConstants.TILE.SWAMP:
			match rng.randi_range(1, 10):
				1: r = MapConstants.RESOURCE.PEAT

	return r

####################################################################################################
## HELPER FUNCTIONS

func tile_has_land_access(v: Vector2) -> bool:
	for n in MapConstants.NEIGHBOURS:
		if mapdata.has(v + n) and mapdata[v + n].is_land:
			return true

	return false

func tile_has_sea_access(v: Vector2) -> bool:
	for n in MapConstants.NEIGHBOURS:
		if mapdata.has(v + n) and mapdata[v + n].is_water:
			return true

	return false

func tile_in_top_third(v: Vector2) -> bool:
	return v.y < mapsize.y/3

func tile_in_lower_third(v) -> bool:
	return v.y > (mapsize.y/3) * 2

func tile_in_middle_third(v) -> bool:
	return !tile_in_top_third(v) and !tile_in_lower_third(v)
