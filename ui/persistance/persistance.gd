extends Node

const USER_PROGRESS: String = "user://last_completed_section.int8"

var _last_unlocked: int = 0
var cur_section: int


func _ready() -> void:
	var file := FileAccess.open(USER_PROGRESS, FileAccess.READ)
	if file == null: return
	_last_unlocked = file.get_8()
	file.close()


func get_unlocked() -> int:
	return _last_unlocked + 1


func set_completed(section_id) -> void:
	section_id += 1 # set to unlocked_id
	if section_id <= _last_unlocked: return
	_last_unlocked = section_id
	var file := FileAccess.open(USER_PROGRESS, FileAccess.WRITE)
	if file == null: 
		printerr("Failed to save progress: %s" % 
		error_string(FileAccess.get_open_error()))
		return
	file.store_8(_last_unlocked)
	file.close()
