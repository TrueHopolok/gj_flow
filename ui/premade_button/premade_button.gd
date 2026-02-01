extends TextureButton

@export var section_id: int = 0


func _ready() -> void:
	visible = section_id < Persistance.get_unlocked()


func _pressed() -> void:
	Persistance.cur_section = section_id - 1
	Transition.change_scene_path('res://scenes/gameplay/gameplay.tscn')
