extends Control


const DURATION = 0.5


func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($ColorRect, 'color', Color(0, 0, 0, 1), DURATION)
	await tween.finished


func fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($ColorRect, 'color', Color(0, 0, 0, 0), DURATION)


func change_scene_packed(scene: PackedScene) -> void:
	await fade_in()
	get_tree().change_scene_to_packed(scene)
	get_tree().paused = false
	fade_out()


func change_scene_path(path: String) -> void:
	await fade_in()
	get_tree().change_scene_to_file(path)
	get_tree().paused = false
	fade_out()


func change_scene_inst(inst: Node) -> void:
	await fade_in()
	if is_instance_valid(get_tree().current_scene):
		get_tree().current_scene.queue_free()
	get_tree().root.add_child(inst)
	get_tree().current_scene = inst
	get_tree().paused = false
	fade_out()

func reload_scene() -> void:
	await fade_in()
	get_tree().reload_current_scene()
	get_tree().paused = false
	fade_out()
