extends Label


@export var expected_section_idx: int = 0
@export var start_time: float = 3.0
@export var stay_time: float = 2.0


func _on_game_manager_switched_section(section_idx: int) -> void:
	get_tree().create_timer(start_time).timeout.connect(func() -> void:
		if section_idx != expected_section_idx: return
		modulate = Color(1, 1, 1, 0)
		global_position.y = -20
		var tween: Tween = create_tween()
		tween.parallel().tween_property(self, ^'global_position', Vector2(global_position.x, -3), 1.0)
		tween.parallel().tween_property(self, ^'modulate', Color(1, 1, 1, 1), 1.0)
		tween.finished.connect(func() -> void:
			get_tree().create_timer(stay_time).timeout.connect(func() -> void:
				var tween2: Tween = create_tween()
				tween2.parallel().tween_property(self, ^'global_position', Vector2(global_position.x, -20), 1.0)
				tween2.parallel().tween_property(self, ^'modulate', Color(1, 1, 1, 0), 1.0)
			)
		)
	)
