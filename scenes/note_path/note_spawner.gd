## NoteSpawner is a path that allows spawning nodes, visual only.
class_name NoteSpawner
extends Node2D


const NOTE := preload("res://scenes/note/note.tscn")
const ENEMY_FROG := preload("res://scenes/enemies/frog/frog.tscn")
const ENEMY_DRAGON := preload("res://scenes/enemies/dragon/dragon.tscn")


@export_enum(LevelNote.LOW_LEFT, LevelNote.TOP_LEFT, LevelNote.TOP_RIGHT, LevelNote.LOW_RIGHT)
var direction: String

@export var enemy_flip_h: bool = false
@export var enemy_flip_v: bool = false

@onready var begin_node: Node2D = $Begin
@onready var end_node: Node2D = $End

@onready var frog_path: Path2D = get_node_or_null(^"FrogPath")


## Returns destroy hook.
func spawn_note(delay_s: float) -> Callable:
	# TODO: depending on position spawn different note
	return _spawn_internal(delay_s, NOTE.instantiate())


## Returns destroy hook.
func spawn_enemy(delay_s: float) -> Callable:
	if direction == LevelNote.TOP_LEFT or direction == LevelNote.TOP_RIGHT:
		var inst := ENEMY_DRAGON.instantiate() as Sprite2D
		inst.flip_h = enemy_flip_h
		inst.flip_v = enemy_flip_v
		return _spawn_delayed(delay_s / 2, delay_s / 2, inst)
	else:
		var inst := ENEMY_FROG.instantiate() as Sprite2D
		inst.flip_h = enemy_flip_h
		inst.flip_v = enemy_flip_v
		return _spawn_on_path(delay_s, inst)


func _spawn_delayed(wait_s: float, delay_s: float, node: Node2D) -> Callable:
	if wait_s <= 0: return _spawn_internal(delay_s, node)
	add_child(node)
	node.global_rotation = 0
	node.global_position = begin_node.global_position
	delay_s += delay_s / 9
	get_tree().create_timer(wait_s).timeout.connect(
		func() -> void:
			if is_instance_valid(node):
				var t := node.create_tween()
				t.tween_property(node, "global_position", end_node.global_position, delay_s).from(begin_node.global_position)
				t.chain().tween_callback(node.queue_free)
	)
	return node.queue_free


func _spawn_internal(delay_s: float, node: Node2D) -> Callable:
	delay_s += delay_s / 9
	add_child(node)
	node.global_rotation = 0
	var t := node.create_tween()
	t.tween_property(node, "global_position", end_node.global_position, delay_s).from(begin_node.global_position)
	t.chain().tween_callback(node.queue_free)
	return node.queue_free


func _spawn_on_path(delay_s: float, node: Node2D) -> Callable:
	assert(frog_path != null, "Frog path must be set to spawn frogs")
	var follower := PathFollow2D.new()
	frog_path.add_child(follower)
	follower.add_child(node)

	var t := follower.create_tween()
	t.tween_property(follower, "progress_ratio", 1.0, delay_s).from(0.0)
	t.chain().tween_callback(follower.queue_free)

	return follower.queue_free
