extends Control


const TARGET = "autoplay"

var buf: String

@onready var autoplay_label: Label = %Autoplay

func _unhandled_key_input(event: InputEvent) -> void:
	var codepoint := event.unicode as int
	if ord("a") <= codepoint and codepoint <= ord("z"):
		var s := char(codepoint)
		buf += s
		if buf == TARGET:
			buf = ""
			on_secret()
		elif not TARGET.begins_with(buf):
			if TARGET.begins_with(s):
				buf = s
			else:
				buf = ""


func _ready() -> void:
	autoplay_label.visible = get_tree().root.get_meta("autoplay", false)


func on_secret() -> void:
	print("SECRET!")
	var root := get_tree().root
	root.set_meta("autoplay", not root.get_meta("autoplay", false))
	autoplay_label.visible = root.get_meta("autoplay", false)
