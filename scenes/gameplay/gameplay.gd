extends Node2D


@onready var sun: Sun = $Visuals/Sun
@onready var game_manager: GameManager = %GameManager

@onready var player: Player = %Player
@onready var the_rock: Sprite2D = %TheRock

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
	game_manager.drum_hit.connect(drum_feedback)
	
	game_manager.secret_happened.connect(func() -> void:
		var t := the_rock.create_tween()
		t.tween_property(the_rock, "modulate:a", 0.0, 0.5).from(1.0)
	)



func spawn_feedback(dir: int, text: String) -> void:
	var fr: FeedbackRenderer
	match dir:
		-2: fr = feedback_ll
		-1: fr = feedback_l
		+1: fr = feedback_r
		+2: fr = feedback_rr
	
	if text == "ouch":
		player.take_damage()
	
	fr.spawn_feedback(text)


func drum_feedback(dir: int) -> void:
	match dir:
		-2: player.hit_snare_l()
		-1: player.hit_hi_hat()
		+1: player.hit_snare_r()
		+2: player.hit_kick()
		_: assert(false, "fuck: %d" % dir)
