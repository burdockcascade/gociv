extends Node2D

onready var selector = $Selector

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
export var max_movement: int = 0
export var over_land: bool = false
export var over_water: bool = false
export var visibility: int = 0

onready var movement_sound = $MovementSound

var current_mapv = Vector2.ZERO

####################################################################################################
## Selector

func activate():
	selector.visible = true
	selector.playing = true

func deactivate_selector():
	selector.visible = false
	selector.playing = false


####################################################################################################
## Sounds

func play_sound():

	# play sound
	if movement_sound:
		movement_sound.play()
