class_name FeedbackRenderer
extends Node2D


@export var label_ok: Texture
@export var label_miss: Texture
@export var label_ouch: Texture
@export var label_perfect: Texture


func spawn_feedback(text: String) -> void:
	var texture: Texture
	match text:
		"ok": texture = label_ok
		"miss": texture = label_miss
		"ouch": texture = label_ouch
		"perfect": texture = label_perfect
	
	var inst := Sprite2D.new()
	inst.texture = texture
	add_child(inst)
	var t := inst.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_property(inst, "global_position", global_position + Vector2.UP * 15, 1.5).from(global_position)
	t.parallel().tween_property(inst, "modulate:a", 0.0, 1.5).from(1.0)
	t.chain().tween_callback(inst.queue_free)
