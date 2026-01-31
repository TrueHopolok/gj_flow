extends Label


@onready var game_manager: GameManager = %GameManager


func _ready() -> void:
	game_manager.health_changed.connect(func (health: int) -> void:
		text = "Health: %s%%" % health
	)
