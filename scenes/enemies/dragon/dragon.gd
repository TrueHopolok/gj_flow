extends Node2D


var flip_h: bool
var flip_v: bool


func _ready() -> void:
	if flip_h:
		scale.x = -1
	if flip_v:
		scale.y = -1
