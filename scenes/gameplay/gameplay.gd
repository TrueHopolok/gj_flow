extends Node2D


@onready var sun: Sun = $Visuals/Sun
@onready var game_manager: GameManager = %GameManager


func _ready() -> void:
	# Animate the sun
	game_manager.health_changed.connect(func (h: int) -> void:
		sun.set_health(float(h) / float(LevelDamage.MAX_HEALTH))
	)
