## NotePath is a path that allows spawning nodes, visual only.
class_name NotePath
extends Node2D


const NOTE := preload("res://scenes/note/note.tscn")
const ENEMY := preload("res://scenes/enemy/enemy.tscn")


@onready var begin_node: Node2D = $Begin
@onready var end_node: Node2D = $End


## Returns destroy hook.
func spawn_note(delay_s: float) -> Callable:
	return _spawn_internal(delay_s, NOTE.instantiate())


## Returns destroy hook.
func spawn_enemy(delay_s: float) -> Callable:
	return _spawn_internal(delay_s, ENEMY.instantiate())


func _spawn_internal(delay_s: float, node: Node2D) -> Callable:
	add_child(node)
	var t := node.create_tween()
	t.tween_property(node, "global_position", end_node.global_position, delay_s).from(begin_node.global_position)
	t.chain().tween_callback(node.queue_free)
	return node.queue_free
