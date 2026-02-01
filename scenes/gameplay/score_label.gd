extends Label


@onready var game_manager: GameManager = %GameManager


func _ready() -> void:
	game_manager.score_changed.connect(func (score: int) -> void:
		text = str(score)
	)
