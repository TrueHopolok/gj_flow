class_name LevelNote
extends Resource


## Those are based on input map and should match,
## otherwise - Габэла.

const LOW_LEFT: String = 'low_left'
const TOP_LEFT: String = 'low_right'
const TOP_RIGHT: String = 'top_right'
const LOW_RIGHT: String = 'low_right'


@export var type: NoteType
@export var timing: float ## 1 unit == tact
@export var direction: String
var activated: bool = true


enum NoteType {
	REGULAR,
}
