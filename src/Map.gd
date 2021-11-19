extends Node2D

onready var terrain: TileMap = $Terrain
onready var terrain2: TileMap = $Terrain2
onready var resources: TileMap = $Resources

####################################################################################################
## MAP DATA

# order is important
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

# order is important
enum TERRAIN2 {

	SMALL_FOREST = 49
	MEDIUM_FOREST
	LARGE_FOREST

}

# order is important
enum RESOURCE {

	OASIS, # 0
	OIL,
	OILRIG
	BUFFALO,
	WHEAT,
	IRIGATION,
	PHEASENT,
	SILK,
	FARMLAND,
	COAL,
	WINE, # 10
	MINING,
	GOLD,
	IRON,
	POLLUTION,
	TUNDRA_GAME,
	FURS,
	VILLAGE,
	IVORY,
	ARCTIC_OIL,
	FALLOUT, # 20
	PEAT,
	SPICE,
	OIL_PLATFORM,
	GEMS,
	FRUIT,
	FISH,
	WHALES,
	SEALS,
	FOREST_GAME,
	HORSES, # 30
	SHEILD

}

####################################################################################################
## Ready

func _ready() -> void:

	rng.randomize()
	
	Events.connect("map_updated", self, "draw_map")

####################################################################################################
## UI CONTROLS

func _unhandled_input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_click"):
		var mapv: Vector2 = terrain.world_to_map(get_global_mouse_position())
		
		for unit in get_tree().get_nodes_in_group("mapv_" + str(mapv)):
			unit.activate()

	# move map
	if event.is_action_pressed("ui_move_map_left"):
		on_map_scrolled(Vector2.LEFT)
	elif event.is_action_pressed("ui_move_map_right"):
		on_map_scrolled(Vector2.RIGHT)

####################################################################################################
## DRAW WORLD

func on_map_scrolled(direction: Vector2) -> void:
	
	# update mapv with new cellv
	for mapd in Game.mapdata.values():
		mapd.cellv.x = wrapi(mapd.cellv.x + direction.x, 0, Game.mapsize.x)
	
	# update tiles with new position
	draw_map()
	
	# shift units
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.draw_unit()

func draw_map() -> void:
	
	terrain.clear()
	terrain2.clear()
	resources.clear()

	# paint map
	for mapv in Game.mapdata:

		var mapd: Dictionary = Game.mapdata[mapv]
		var cellv: Vector2 = mapd.cellv

		# update world position for mapv
		mapd.worldv = terrain.map_to_world(cellv)

		if mapd.visible:

			# paint terrain
			terrain.set_cellv(cellv, mapd.tile)

			# paint upper terrain
			terrain2.set_cellv(cellv, mapd.terrain2)

			# paint resources
			resources.set_cellv(cellv, mapd.resource)

			# paint settlements

		# paint fog
	

####################################################################################################
## MAP GENERATOR

enum HEIGHT {
	DEEP_SEA,
	SHALLOW_OCEAN,
	FLATLAND,
	HILL,
	MOUNTAIN
}

var tile_height: Dictionary = {
	HEIGHT.DEEP_SEA : TILE.SHALLOW_OCEAN,
	HEIGHT.SHALLOW_OCEAN : TILE.SHALLOW_OCEAN,
	HEIGHT.FLATLAND : TILE.GRASSLAND,
	HEIGHT.HILL : TILE.HILLS,
	HEIGHT.MOUNTAIN : TILE.MOUNTAINS
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func new_map(size: Vector2) -> void:

	Game.mapsize = size

	# generate map
	generate_terrain(size)

	draw_map()


func generate_terrain(dim: Vector2) -> void:

	var noise: OpenSimplexNoise = OpenSimplexNoise.new()
	randomize()

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
				worldv = terrain.map_to_world(v),
				
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
#				cd.tile = TILE.TUNDRA

			# set ice caps
			if y == 0 or y == dim.y-1:
				mapd.tile = TILE.ARCTIC


			# set hills & mountains
			if mapd.height == HEIGHT.HILL and mapd.tile != TILE.ARCTIC:
				mapd.terrain2 = 0
				mapd.travel_cost = 1
			elif mapd.height == HEIGHT.MOUNTAIN and mapd.tile != TILE.ARCTIC:
				mapd.terrain2 = RESOURCE.TUNDRA_GAME
			elif mapd.tile == TILE.FOREST:
				mapd.terrain2 = add_random_trees(v)

			# is water tile
			mapd.is_water = (mapd.tile == TILE.DEEP_OCEAN) or (mapd.tile == TILE.SHALLOW_OCEAN)

			# is land tile
			mapd.is_land = !mapd.is_water

			# resources
			mapd.resource = add_random_resource(v, mapd.tile)

			Game.mapdata[v] = mapd


func select_random_green_tile(v: Vector2) -> int:

	var t: int = TILE.GRASSLAND

	# random tile assignment
	match rng.randi_range(1, 12):
		1,2,3: t = TILE.PLAINS
		4,5,6: t = TILE.FOREST
		8: t = TILE.JUNGLE
		9: if tile_has_sea_access(v): t = TILE.SWAMP
		10: if tile_in_middle_third(v): t = TILE.DESERT

	return t

func add_random_trees(_v: Vector2) -> int:

	var t: int = -1

	match rng.randi_range(1, 3):
		1: t = TERRAIN2.SMALL_FOREST
		2: t = TERRAIN2.MEDIUM_FOREST
		3: t = TERRAIN2.LARGE_FOREST

	return t


func add_random_resource(v: Vector2, t: int) -> int:

	var r: int = -1

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
			match rng.randi_range(1, 20):
				3: r = RESOURCE.COAL
				4: r = RESOURCE.WINE

		TILE.MOUNTAINS:
			match rng.randi_range(1, 10):
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

	return r

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


func tile_has_land_access(v: Vector2) -> bool:
	for n in neighbours:
		if Game.mapdata.has(v + n) and Game.mapdata[v + n].is_land:
			return true

	return false

func tile_has_sea_access(v: Vector2) -> bool:
	for n in neighbours:
		if Game.mapdata.has(v + n) and Game.mapdata[v + n].is_water:
			return true

	return false

func tile_in_top_third(v: Vector2) -> bool:
	return v.y < Game.mapsize.y/3

func tile_in_lower_third(v) -> bool:
	return v.y > (Game.mapsize.y/3) * 2

func tile_in_middle_third(v) -> bool:
	return !tile_in_top_third(v) and !tile_in_lower_third(v)

####################################################################################################
## PUBLIC FUNCTIONS

func any_random_tile() -> Vector2:
	return _find_random_tile(true, true)

func random_land_tile() -> Vector2:
	return _find_random_tile(true, false)

func random_sea_tile() -> Vector2:
	return _find_random_tile(false, true)

func _find_random_tile(land: bool, water: bool) -> Vector2:
	while true:
		var v = Vector2(rng.randi_range(0, Game.mapsize.x-1), rng.randi_range(0, Game.mapsize.y-1))
		if Game.mapdata[v].is_land == land and Game.mapdata[v].is_water == water:
			return v

	return Vector2.ONE

