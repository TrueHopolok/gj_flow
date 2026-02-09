extends Node2D


const BPM: float = 120
const WANT_SAMPLES: int = 20

var offset_sum: float = 0
var hit_count: int = 0

@onready var reference_player: AudioStreamPlayer = $ReferencePlayer
@onready var snare_player: AudioStreamPlayer = $SnarePlayer
@onready var player: Player = %Player
@onready var offset_label: Label = %OffsetLabel


func _ready() -> void:
	reference_player.play()
	reference_player.finished.connect(func() -> void:
		reference_player.play())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("calibration_reset"):
		get_viewport().set_input_as_handled()
		hit_count = 0
		offset_sum = 0
		offset_label.text = ""
		return
	elif event.is_action_pressed("exit_menu"):
		get_viewport().set_input_as_handled()
		exit_calibration()

	if not event.is_action_pressed("top_left"):
		return

	get_viewport().set_input_as_handled()

	player.hit_snare_l()
	snare_player.play()

	var pos: float = reference_player.get_playback_position()
	var perfect: float = snappedf(pos, 60.0 / BPM)

	# offset from perfect to pos

	var sample: float = pos - perfect
	offset_sum += sample
	hit_count += 1

	offset_label.text = format_duration(offset_sum / float(hit_count))


func exit_calibration() -> void:
	if hit_count > 0:
		var val := offset_sum / float(hit_count)
		SettingsCfg.config.set_value("calibration", "offset", val)
		SettingsCfg.config.save(SettingsCfg.CFG_PATH)

	Transition.change_scene_path("res://ui/main_menu/main_menu.tscn")


func format_duration(d: float) -> String:
	return "%.2+fms" % (d * 1e3)
