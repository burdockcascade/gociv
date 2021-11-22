extends Node

var mapsize: Vector2
var mapdata: Dictionary
var landnav: AStar2D
var waternav: AStar2D 

var settings: Dictionary = {
	show_all_map = true
}

func _ready() -> void:
	reset()

func reset() -> void:
	
	mapdata = {}
	landnav = AStar2D.new()
	waternav = AStar2D.new()


func map_wrap(pos: Vector2):
	return Vector2(wrapi(pos.x, 0, Game.mapsize.x), pos.y)
