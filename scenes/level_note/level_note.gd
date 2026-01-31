class_name LevelNote
extends Resource


const LOW_LEFT: String = 'low_left'
const TOP_LEFT: String = 'top_left'
const TOP_RIGHT: String = 'top_right'
const LOW_RIGHT: String = 'low_right'


@export var type: NoteType
@export var timing: float ## 1 unit == tact
@export var direction: String
var hittable: bool = true


enum NoteType {
	REGULAR,
	ENEMY,
}
