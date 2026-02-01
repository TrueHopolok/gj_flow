class_name LevelPart
extends Resource


@export var stream: AudioStream
@export var notes: Array[LevelNote]


func our_deep_clone() -> LevelPart:
	var res := LevelPart.new()
	res.stream = stream

	var res_notes: Array[LevelNote] = []
	for note: LevelNote in notes:
		var ln := LevelNote.new()
		ln.type = note.type
		ln.direction = note.direction
		ln.timing = note.timing
		res_notes.push_back(ln)

	res.notes = res_notes

	return res
