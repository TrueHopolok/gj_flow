class_name Player
extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var kick: Drum = $Kick
@onready var hat: Drum = $Hat
@onready var snare_left: Drum = $SnareLeft
@onready var snare_right: Drum = $SnareRight


func _ready() -> void:
	animation_player.play("idle")
	animation_player.animation_finished.connect(func (anim: StringName) -> void:
		if anim != &"idle":
			animation_player.play(&"idle")
	)


func take_damage() -> void:
	animation_player.play("damage")
	animation_player.seek(0)


func hit_snare_l() -> void:
	snare_left.hit()
	animation_player.play("snare_left")
	animation_player.seek(0)


func hit_snare_r() -> void:
	snare_right.hit()
	animation_player.play("snare_right")
	animation_player.seek(0)


func hit_kick() -> void:
	kick.hit()
	animation_player.play("kick")
	animation_player.seek(0)


func hit_hi_hat() -> void:
	hat.hit()
	animation_player.play("hit_hat")
	animation_player.seek(0)
