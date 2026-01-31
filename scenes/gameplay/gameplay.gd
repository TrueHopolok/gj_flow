extends Node2D


@onready var note_path: NotePath = $NotePathLR


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.call_deferred()


func start() -> void:
	# This is just for testing!
	
	note_path.spawn_note(3.0)
	await get_tree().create_timer(3.0).timeout
	
	note_path.spawn_note(2.0)
	await get_tree().create_timer(2.0).timeout
	
	note_path.spawn_note(1.0)
	await get_tree().create_timer(1.0).timeout
	
	note_path.spawn_note(0.5)
	await get_tree().create_timer(0.5).timeout
	
