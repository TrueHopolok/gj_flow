extends Control


var score: int

@onready var label: Label = $Label
@onready var hard: TextureButton = $Hard


func _ready() -> void:
	label.text = "Score\n%d" % score
	
	hard.pressed.connect(Transition.change_scene_path.bind("res://ui/main_menu/main_menu.tscn"))
