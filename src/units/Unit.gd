extends Node2D

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


var at_mapv = Vector2.INF

