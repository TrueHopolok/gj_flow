extends Node2D


@onready var sun: Sun = $Visuals/Sun
@onready var game_manager: GameManager = %GameManager


@export var feedback_ll: FeedbackRenderer
@export var feedback_l: FeedbackRenderer
@export var feedback_r: FeedbackRenderer
@export var feedback_rr: FeedbackRenderer


func _ready() -> void:
	# Animate the sun
	game_manager.health_changed.connect(func (h: int) -> void:
		sun.set_health(float(h) / float(LevelDamage.MAX_HEALTH))
	)
	game_manager.feedback.connect(spawn_feedback)


func spawn_feedback(dir: int, text: String) -> void:
	var fr: FeedbackRenderer
	match dir:
		-2: fr = feedback_ll
		-1: fr = feedback_l
		1: fr = feedback_r
		2: fr = feedback_rr
	
	fr.spawn_feedback(text)
