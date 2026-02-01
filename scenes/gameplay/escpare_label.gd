extends Label


func _ready() -> void:
	modulate = Color(1, 1, 1, 0)
	var tween: Tween = create_tween()
	tween.parallel().tween_property(self, ^'global_position', Vector2(0, 0), 1.0)
	tween.parallel().tween_property(self, ^'modulate', Color(1, 1, 1, 1), 1.0)
	tween.finished.connect(func() -> void:
		get_tree().create_timer(3.0).timeout.connect(func() -> void:
			var tween2: Tween = create_tween()
			tween2.parallel().tween_property(self, ^'global_position', Vector2(0, -17), 1.0)
			tween2.parallel().tween_property(self, ^'modulate', Color(1, 1, 1, 0), 1.0)
		)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&'exit_menu'):
		Transition.change_scene_path('res://ui/main_menu/main_menu.tscn')
