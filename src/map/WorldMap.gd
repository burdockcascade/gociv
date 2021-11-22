class_name WorldMap

####################################################################################################
## Enums

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

const NEIGHBOURS = [
	Vector2.UP,
	Vector2.UP + Vector2.RIGHT,
	Vector2.RIGHT,
	Vector2.DOWN + Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.LEFT,
	Vector2.UP + Vector2.LEFT
]

####################################################################################################
## Map variables

var dimension: Vector2 = Vector2.ZERO
var data: Dictionary = {}

####################################################################################################
## Public Functions

func any_random_tile() -> Vector2:
	return _find_random_tile(true, true)

func random_land_tile() -> Vector2:
	return _find_random_tile(true, false)

func random_sea_tile() -> Vector2:
	return _find_random_tile(false, true)

func _find_random_tile(land: bool, water: bool) -> Vector2:
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	while true:
		var v = Vector2(rng.randi_range(0, dimension.x-1), rng.randi_range(1, dimension.y-2))
		if data[v].is_land == land and data[v].is_water == water:
			return v

	return Vector2.ONE

func wrap(pos: Vector2) -> Vector2:
	return Vector2(wrapi(pos.x, 0, dimension.x), clamp(pos.y, 0, dimension.y))


func tile_has_land_access(v: Vector2) -> bool:
	for n in NEIGHBOURS:
		if data.has(v + n) and data[v + n].is_land:
			return true

	return false

func tile_has_sea_access(v: Vector2) -> bool:
	for n in NEIGHBOURS:
		if data.has(v + n) and data[v + n].is_water:
			return true

	return false

func tile_in_top_third(v: Vector2) -> bool:
	return v.y < dimension.y/3

func tile_in_lower_third(v: Vector2) -> bool:
	return v.y > (dimension.y/3) * 2

func tile_in_middle_third(v: Vector2) -> bool:
	return !tile_in_top_third(v) and !tile_in_lower_third(v)
