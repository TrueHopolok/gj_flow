extends Sprite2D


@export var sprites: Array[Texture2D] = []


func _ready() -> void:
	texture = sprites.pick_random()
