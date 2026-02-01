extends Node2D


func _ready() -> void:
	var nodes: Array = get_tree().get_nodes_in_group("Wave")
	nodes.sort_custom(func (lhs: AnimatedSprite2D, rhs: AnimatedSprite2D) -> bool:
		return lhs.global_position.x < rhs.global_position.x
	)
	
	for i: int in nodes.size():
		nodes[i].frame = i % 6
		nodes[i].play()
