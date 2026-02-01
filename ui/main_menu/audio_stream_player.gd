extends AudioStreamPlayer


@onready var LOOP_STREAM: AudioStream = preload('res://audio/music/main_menu/main menu_loop.wav')

func _ready() -> void:
	finished.connect(func() -> void:
		stream = LOOP_STREAM
		play()
	)
