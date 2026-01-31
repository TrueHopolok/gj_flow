class_name LevelPart
extends Resource


@export var music: AudioStream
@export var notes: Array[Note]


enum NoteType {
	NOTE_LEFT,
	NOTE_TOP_LEFT,
	NOTE_TOP_RIGHT,
	NOTE_RIGHT,
}


class Note extends Resource:
	@export	var direction: NoteType
	@export	var timing: float ## 1 unit == tact
