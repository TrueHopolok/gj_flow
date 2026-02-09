@tool
extends Node2D


@onready var start: Node2D = $RopeStart
@export var end: Node2D
@export var color := Color.WHITE


func _draw() -> void:
	draw_line(to_local(start.global_position), to_local(end.global_position), color)


func _process(_delta: float) -> void:
	if start != null and end != null:
		queue_redraw()
