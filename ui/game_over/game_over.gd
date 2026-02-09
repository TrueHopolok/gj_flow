extends Control


var score: int


func _ready() -> void:
	$Label.text = "Score\n%d" % score
	$Button.pressed.connect(Transition.change_scene_path.bind("res://ui/main_menu/main_menu.tscn"))
