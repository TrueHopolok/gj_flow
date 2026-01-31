class_name GameManager
extends Node2D


const LEVEL_SECTION_DIR: String = ""
const NOTE_SPAWN_OFFSET: float = 2.0 ## Seconds

@export var note_spawner_l: NotePath = null
@export var note_spawner_tl: NotePath = null
@export var note_spawner_tr: NotePath = null
@export var note_spawner_r: NotePath = null

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var sections: Array[LevelSection]

# State
var section_id: int
var section: LevelSection
var notes: Array[LevelPart.Note]
var notes_spawning: bool
var note_spawn_id: int
var note_click_id: int


func _ready() -> void:
	var dir = DirAccess.open(LEVEL_SECTION_DIR)
	assert(dir, "FAILED OPENING LEVEL SECTION DIRECTORY")
	var files: PackedStringArray = dir.get_files()
	for filename in files:
		sections.append(load(filename) as LevelSection)


func start_game() -> void:
	assert(len(sections) > 0, "FAILED TO FIND ANY SECTIONS")
	section_id = -1
	next_section()


func next_section() -> void:
	music_player.stop()

	if len(sections) - 1 > section_id:
		section_id += 1
	section = sections[section_id]
	section.parts.shuffle()

	notes.clear()
	var offset: float = section.intro_length
	for part in section.parts:
		for note in part.notes:
			notes.append(note)
			notes[-1].timing += offset
		offset += part.length
	notes_spawning = true
	note_spawn_id = 0
	note_click_id = 0

	music_player.stream = section.stream
	# maybe play some animation that next section starts

	music_player.play()


func get_song_pos() -> float:
	return music_player.get_playback_position()


func spawn_note(note: LevelPart.Note) -> void:
	var spawner: NotePath
	match note.direction:
		LevelPart.NoteType.NOTE_LEFT:
			spawner = note_spawner_l
		LevelPart.NoteType.NOTE_RIGHT:
			spawner = note_spawner_r
		LevelPart.NoteType.NOTE_TOP_LEFT:
			spawner = note_spawner_tl
		LevelPart.NoteType.NOTE_TOP_RIGHT:
			spawner = note_spawner_tr
		_: 
			printerr("Trying to spawn unknown note type: %s" % LevelPart.NoteType.keys()[note.direction])
			return

	if spawner == null:
		printerr("Trying to spawn node on unknown node path")
		return
	
	spawner.spawn_note(NOTE_SPAWN_OFFSET)

func _process(_delta: float) -> void:
	if notes_spawning:
		while note_spawn_id < len(notes) && get_song_pos() + NOTE_SPAWN_OFFSET > notes[note_spawn_id].timing:
			spawn_note(notes[note_spawn_id])
			note_spawn_id += 1
		notes_spawning = note_spawn_id < len(notes)
