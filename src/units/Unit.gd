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
	print("new turn")
	can_move = true
	current_travel = 0
	
	if current_state == State.EXPLORE:
		timer.start()
		explore_movement()

####################################################################################################
## UI CONTROLS

func _unhandled_input(event: InputEvent) -> void:

	if not active:
		return

	# move unit
	if event.is_action_pressed("ui_left"):
		move_unit_by_direction(Vector2.LEFT)

	elif event.is_action_pressed("ui_right"):
		move_unit_by_direction(Vector2.RIGHT)

	elif event.is_action_pressed("ui_up"):
		move_unit_by_direction(Vector2.UP)

	elif event.is_action_pressed("ui_down"):
		move_unit_by_direction(Vector2.DOWN)

	elif event.is_action_pressed("unit_explore"):
		current_state = State.EXPLORE
		timer.start()
		explore_movement()



####################################################################################################
## Movement

const neighbours: Array = [
	Vector2.UP,
	Vector2.UP + Vector2.RIGHT,
	Vector2.RIGHT,
	Vector2.DOWN + Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.LEFT,
	Vector2.UP + Vector2.LEFT
]

func explore_movement() -> void:
	
	neighbours.shuffle()
	
	for n in neighbours:
		
		if not can_move:
			return

		var neighbour_mapv = current_mapv + n
		
		# wrap
		neighbour_mapv = Vector2(wrapi(neighbour_mapv.x, 0, Game.mapsize.x), neighbour_mapv.y)
		
		# skip if mapv doesn't exist
		if not Game.mapdata.has(neighbour_mapv):
			continue
		
		# skip if cant move to tile
		if not can_move_to_mapv(neighbour_mapv):
			continue
		
		# skip if explored
		if Game.mapdata[neighbour_mapv].explored:
			continue
		
		# end if movement successfuk
		if move_unit_to_mapv(neighbour_mapv):
			return
	
	# cant move anyway
	current_state = State.IDLE
	

func move_unit_by_direction(direction: Vector2) -> bool:
	
	if not can_move:
		return false
		
	var dest_mapv = Vector2(wrapi(current_mapv.x + direction.x, 0, Game.mapsize.x), current_mapv.y + direction.y)
	
	return move_unit_to_mapv(dest_mapv)

func can_move_to_mapv(dest_mapv) -> bool:
	return Game.mapdata[dest_mapv].is_land == over_land or Game.mapdata[dest_mapv].is_water == over_water

func move_unit_to_mapv(new_mapv: Vector2) -> bool:

	# deactivate if turn over
	if current_travel >= max_travel:
		turn_over()
		print("no more travel")
		return false

	if not Game.mapdata.has(new_mapv):
		return false
		
	if not can_move_to_mapv(new_mapv):
		return false

	var old_mapv: Vector2 = current_mapv
	var old_mapd: Dictionary = Game.mapdata[old_mapv]
	var new_mapd: Dictionary = Game.mapdata[new_mapv]

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
	mapv = Game.map_wrap(mapv)
	
	# set position of unit
	current_mapv = mapv
	draw_unit()
	
	# update map if newly explored
	if not Game.mapdata[mapv].explored:
		
		# this mapv is explored
		Game.mapdata[mapv].explored = true
		
		# these mapvs are now visible but not explored
		for x in range(mapv.x - visibility, mapv.x + visibility + 1):
			for y in range(mapv.y - visibility, mapv.y + visibility + 1):
				var wrapv = Game.map_wrap(Vector2(x, y))
				if Game.mapdata.has(wrapv):
					Game.mapdata[wrapv].visible = true
		
		# redraw map
		Events.emit_signal("map_updated")

	# add to group
	add_to_group("mapv_" + str(mapv))
	Game.mapdata[mapv].units.append(self)
	
func draw_unit() -> void:
	position = Game.mapdata[current_mapv].worldv


