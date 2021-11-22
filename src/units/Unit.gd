extends Node2D

onready var selector = $Selector
onready var movement_sound = $MovementSound

# state
enum State { IDLE, EXPLORE }
var current_state: int = State.IDLE

# warfare
export var shield: int = 0
export var weapon: int = 0
export var stealth: bool = false

# freight
export var capacity: int = 0

# actions
export var can_found_city: bool = false

# value
export var build_cost: int = 0
export var support_cost: int = 0
export var build_cycle: int = 0

# movement
export var max_travel: int = 0
export var over_land: bool = false
export var over_water: bool = false
export var visibility: int = 0

onready var timer: Timer = $Timer

var current_mapv = Vector2.ZERO

var can_move: bool = true
var current_travel: int = 0

var active: bool = false

var worldmap: WorldMap

####################################################################################################
## Unit

func _on_Timer_timeout():
	match current_state:
		
		State.EXPLORE:
			explore_movement()

func activate():
	if can_move:
		selector.visible = true
		selector.playing = true
		active = true

func deactivate():
	selector.visible = false
	selector.playing = false
	active = false
	


####################################################################################################
## Turn

func turn_over():
	deactivate()
	can_move = false
	timer.stop()

func new_turn():
	can_move = true
	current_travel = 0
	
	if current_state == State.EXPLORE:
		timer.start()
		explore_movement()


####################################################################################################
## Movement

func explore_movement() -> void:
	
	for n in WorldMap.NEIGHBOURS:
		
		if not can_move:
			return

		var neighbour_mapv = worldmap.wrap(current_mapv + n)
		
		# skip if mapv doesn't exist
		if not worldmap.data.has(neighbour_mapv):
			continue
		
		# skip if cant move to tile
		if not can_move_to_mapv(neighbour_mapv):
			continue
		
		# skip if explored
		if worldmap.data[neighbour_mapv].explored:
			continue
		
		# end if movement successfuk
		if move_to_mapv(neighbour_mapv):
			return
	
	# cant move anyway
	current_state = State.IDLE
	

func move_by_direction(direction: Vector2) -> bool:
	
	if not can_move:
		return false
		
	var dest_mapv = worldmap.wrap(current_mapv + direction)
	
	return move_to_mapv(dest_mapv)

func can_move_to_mapv(dest_mapv) -> bool:
	return worldmap.data[dest_mapv].is_land == over_land or worldmap.data[dest_mapv].is_water == over_water

func move_to_mapv(new_mapv: Vector2) -> bool:

	# deactivate if turn over
	if current_travel >= max_travel:
		turn_over()
		print("no more travel")
		return false
		
	if not can_move_to_mapv(new_mapv):
		return false

	var old_mapv: Vector2 = current_mapv
	var old_mapd: Dictionary = worldmap.data[old_mapv]

	# remove from group
	remove_from_group("mapv_" + str(old_mapv))
	old_mapd.units.erase(self)

	# update travel (cost of leaving the tile)
	current_travel += old_mapd.travel_cost

	# position unit
	put_at_mapv(new_mapv)

	# play sfx
	if movement_sound:
		movement_sound.play()

	return true

func put_at_mapv(mapv: Vector2) -> void:
	
	# wrap if outside map boundary
	mapv = worldmap.wrap(mapv)
	
	# set position of unit
	current_mapv = mapv
	draw_unit()
	
	# update map if newly explored
	if not worldmap.data[mapv].explored:
		
		# this mapv is explored
		worldmap.data[mapv].explored = true
		
		# these mapvs are now visible but not explored
		for x in range(mapv.x - visibility, mapv.x + visibility + 1):
			for y in range(mapv.y - visibility, mapv.y + visibility + 1):
				var wrapv = worldmap.wrap(Vector2(x, y))
				if worldmap.data.has(wrapv):
					worldmap.data[wrapv].visible = true
		
		# redraw map
		Events.emit_signal("map_updated")

	# add to group
	add_to_group("mapv_" + str(mapv))
	worldmap.data[mapv].units.append(self)
	
func draw_unit() -> void:
	position = worldmap.data[current_mapv].worldv
