extends Node2D

onready var selector = $Selector
onready var movement_sound = $MovementSound

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

var current_mapv = Vector2.ZERO

var can_move: bool = true
var current_travel: int = 0

####################################################################################################
## Selector

func turn_over():
	deactivate()
	can_move = false

func new_turn():
	can_move = true
	current_travel = 0


####################################################################################################
## Selector

func activate():
	if can_move:
		selector.visible = true
		selector.playing = true

func deactivate():
	selector.visible = false
	selector.playing = false
