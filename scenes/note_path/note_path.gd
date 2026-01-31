## NotePath is a path that allows spawning nodes, visual only.
class_name NotePath
extends Node2D


const NOTE := preload("res://scenes/note/note.tscn")


@onready var begin_node: Node2D = $Begin
@onready var end_node: Node2D = $End


func spawn_note(delay_s: float) -> void:
	var inst := NOTE.instantiate()
	add_child(inst)

	var t := inst.create_tween()
	t.tween_property(inst, "global_position", end_node.global_position, delay_s).from(begin_node.global_position)
	t.chain().tween_callback(inst.queue_free)
