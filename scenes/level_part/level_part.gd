class_name LevelPart
extends Resource


@export var notes: Array[Note]
var length: float ## 1 unit == tact


enum NoteType {
	NOTE_LEFT,
	NOTE_TOP_LEFT,
	NOTE_TOP_RIGHT,
	NOTE_RIGHT,
}


class Note extends Resource:
	@export var direction: NoteType
	@export var timing: float ## 1 unit == tact
