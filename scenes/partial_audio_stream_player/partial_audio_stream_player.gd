class_name PartialAudioStreamPlayer
extends AudioStreamPlayer


signal fully_finished


var stream_id: int
var stream_queue: Array[AudioStream]
var current_offset: float


func _ready() -> void:
	finished.connect(switch)


func restart() -> void:
	stream_id = 0
	current_offset = 0
	stream = stream_queue[0]
	play()


func get_song_pos() -> float:
	return current_offset + get_playback_position() 


func switch() -> void:
	current_offset += stream.get_length()
	stop()
	stream_id += 1
	if (stream_id >= len(stream_queue)):
		fully_finished.emit()
	else:
		stream = stream_queue[stream_id]
		play()
