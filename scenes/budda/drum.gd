class_name Drum
extends AnimatedSprite2D


func _ready() -> void:
	animation_finished.connect(func () -> void:
		var s := animation
		if s == "hit":
			play("idle")
	)


func hit() -> void:
	play("hit")
