extends Control


@onready var main: Control = $Main
@onready var settings: Control = $Settings

@onready var settings_transition: TextureButton = %SettingsTransition
@onready var main_transition: TextureButton = %MainTransition
@onready var calibration: TextureButton = %Calibration


func _ready() -> void:
	settings_transition.pressed.connect(func () -> void:
		main.hide()
		settings.show()
	)
	main_transition.pressed.connect(func () -> void:
		main.show()
		settings.hide()
	)
	calibration.pressed.connect(func () -> void:
		Transition.change_scene_path("res://scenes/calibration/calibration.tscn")
	)
