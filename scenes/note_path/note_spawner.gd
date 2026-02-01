## NoteSpawner is a path that allows spawning nodes, visual only.
class_name NoteSpawner
extends Node2D


const NOTE := preload("res://scenes/note/note.tscn")
const ENEMY_FROG := preload("res://scenes/enemies/frog/frog.tscn")
const ENEMY_DRAGON := preload("res://scenes/enemies/dragon/dragon.tscn")


@export_enum(LevelNote.LOW_LEFT, LevelNote.TOP_LEFT, LevelNote.TOP_RIGHT, LevelNote.LOW_RIGHT) 
var direction: String

@onready var begin_node: Node2D = $Begin
@onready var end_node: Node2D = $End


## Returns destroy hook.
func spawn_note(delay_s: float) -> Callable:
	# TODO: depending on position spawn different note
	return _spawn_internal(delay_s, NOTE.instantiate())


## Returns destroy hook.
func spawn_enemy(delay_s: float) -> Callable:
	if direction == LevelNote.TOP_LEFT or direction == LevelNote.TOP_RIGHT:
		return _spawn_internal(delay_s, ENEMY_DRAGON.instantiate())
	else:
		# TODO: add path EXCLUSIVE FOR FROG
		return _spawn_internal(delay_s, ENEMY_FROG.instantiate())


## Returns destroy hook.
func spawn_dragon(delay_s: float) -> Callable:
	return _spawn_internal(delay_s, ENEMY_DRAGON.instantiate())


func _spawn_internal(delay_s: float, node: Node2D) -> Callable:
	add_child(node)
	var t := node.create_tween()
	t.tween_property(node, "global_position", end_node.global_position, delay_s).from(begin_node.global_position)
	t.chain().tween_callback(node.queue_free)
	return node.queue_free
