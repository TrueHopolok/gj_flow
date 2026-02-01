class_name PartialAudioStreamPlayer
extends AudioStreamPlayer


signal fully_finished


var stream_id: int
var stream_queue: Array[Variant]
var current_offset: float


func _ready() -> void:
	finished.connect(_switch)


func restart() -> void:
	stream_id = -1
	current_offset = 0
	_switch()


func get_song_pos() -> float:
	return current_offset + get_playback_position() 


func _switch() -> void:
	if stream_id >= 0: current_offset += stream.get_length()
	stop()
	stream_id += 1
	while stream_id < len(stream_queue):
		if is_instance_of(stream_queue[stream_id], AudioStream): break;
		stream_id += 1
	if (stream_id >= len(stream_queue)):
		fully_finished.emit()
	else:
		stream = stream_queue[stream_id]
		play()
