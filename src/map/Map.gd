extends Node2D
class_name Map

onready var terrain: TileMap = $Terrain
onready var terrain2: TileMap = $Terrain2
onready var resources: TileMap = $Resources
onready var units: Node2D = $Units

var active_unit: Node2D

var worldmap: WorldMap

####################################################################################################
## Ready

func _ready() -> void:
	
	Events.connect("map_updated", self, "draw_map")

func new_map(size: Vector2) -> void:

	# generate map
	var nmg = NoiseMapGen.new()
	worldmap = nmg.generate(size)
	
	draw_map()

####################################################################################################
## UI CONTROLS

func _unhandled_input(event: InputEvent) -> void:

	if active_unit:

		# move unit
		if event.is_action_pressed("ui_left"):
			active_unit.move_by_direction(Vector2.LEFT)

		elif event.is_action_pressed("ui_right"):
			active_unit.move_by_direction(Vector2.RIGHT)

		elif event.is_action_pressed("ui_up"):
			active_unit.move_by_direction(Vector2.UP)

		elif event.is_action_pressed("ui_down"):
			active_unit.move_by_direction(Vector2.DOWN)

		elif event.is_action_pressed("unit_action_explore"):
			active_unit.current_state = active_unit.State.EXPLORE
			active_unit.timer.start()

		elif event.is_action_pressed("unit_action_build") and active_unit.can_found_city:
			print("build!")
			
		elif event.is_action_pressed("unit_action_disbanden"):
			active_unit.queue_free()
			active_unit = null
			
		elif event.is_action_pressed("ui_cancel"):
			active_unit.deactivate()
			active_unit = null
			
			
	elif Input.is_action_just_released("ui_click"):
		var mapv: Vector2 = terrain.world_to_map(get_global_mouse_position())

		# deactive all units
		for unit in get_tree().get_nodes_in_group("unit"):
			unit.deactivate()
		
		# activate unit on this tile
		for unit in get_tree().get_nodes_in_group("mapv_" + str(mapv)):
			active_unit = unit
			unit.activate()

	# move map
	elif event.is_action_pressed("map_scroll_left"):
		scroll_map(Vector2.LEFT)
	elif event.is_action_pressed("map_scroll_right"):
		scroll_map(Vector2.RIGHT)
	elif event.is_action_pressed("cheat_see_all_map"):
		cheat_see_all_map()

####################################################################################################
## CHEATS / DEBUG

func cheat_see_all_map() -> void:
	prints("CHEAT", "Show All Map")
	for mapd in worldmap.data.values():
		mapd.visible = true
		
	draw_map()

####################################################################################################
## DRAW WORLD

func scroll_map(direction: Vector2) -> void:
	
	# update mapv with new cellv
	for mapd in worldmap.data.values():
		mapd.cellv = worldmap.wrap(mapd.cellv + direction)
	
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
	for mapd in worldmap.data.values():

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
## Player

func get_player_start_location() -> Vector2:
	return worldmap.random_land_tile()

####################################################################################################
## Units

const unit = {

	transporter = {
		scene = "res://src/units/Transporter.tscn"
	},
	caravan = {
		scene = "res://src/units/Caravan.tscn"
	},
	explorer = {
		scene = "res://src/units/Explorer.tscn"
	}

}

func add_unit(id: String, mapv: Vector2, is_active: bool = false) -> Node2D:

	var u: Node2D = load(unit[id].scene).instance()

	# set worldmap.data
	u.worldmap = worldmap

	# position
	u.put_at_mapv(mapv)

	# add
	units.add_child(u)
	
	if is_active:
		u.activate()
		active_unit = u

	return u


