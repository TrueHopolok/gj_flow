class_name GameManager
extends Node2D


## Directory of all level sections
const LEVEL_SECTION_DIR: String = ""

## Time between note spawn and getting in click range 
const NOTE_SPAWN_OFFSET: float = 2.0 # sec

## Absolute error of player's clicking the note
const TIMING_WINDOW: float = 0.25 # sec

@export var note_spawner_ll: NotePath = null
@export var note_spawner_tl: NotePath = null
@export var note_spawner_tr: NotePath = null
@export var note_spawner_lr: NotePath = null

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var sections: Array[LevelSection]


## Current state

var section_id: int
var section: LevelSection
var notes: Array[LevelNote]
var note_spawn_id: int
var note_active_id: int


func _ready() -> void:
	var dir = DirAccess.open(LEVEL_SECTION_DIR)
	assert(dir, "FAILED OPENING LEVEL SECTION DIRECTORY")
	var files: PackedStringArray = dir.get_files()
	for filename in files:
		sections.append(load(filename) as LevelSection)
	music_player.finished.connect(next_section)


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
	note_spawn_id = 0
	note_active_id = 0

	music_player.stream = section.stream
	# maybe play some animation that next section starts

	music_player.play()


func get_song_pos() -> float:
	return music_player.get_playback_position()


func spawn_note(note: LevelNote) -> void:
	var spawner: NotePath
	match note.type:
		LevelNote.NoteType.REGULAR:
			match note.direction:
				LevelNote.LOW_LEFT:
					spawner = note_spawner_ll
				LevelNote.TOP_LEFT:
					spawner = note_spawner_tl
				LevelNote.TOP_RIGHT:
					spawner = note_spawner_tr
				LevelNote.LOW_RIGHT:
					spawner = note_spawner_lr
				_:
					printerr("Trying to spawn regular note in unknown direction: %s" % note.type)
		_: 
			printerr("Trying to spawn unknown note type: %s" % LevelNote.NoteType.keys()[note.type])
			return

	if spawner == null:
		printerr("Trying to spawn node on unknown node path")
		return

	spawner.spawn_note(NOTE_SPAWN_OFFSET)


## Gurantee constant damage - misclick
func damage_early() -> void:
	pass


## Damage scales based on note type - missed completly
func damage_late(_note_type: LevelNote.NoteType) -> void:
	pass


func _input(event: InputEvent) -> void:
	var note_id: int = note_active_id
	var pressed_amount: int = 0
	while note_id < len(notes) && get_song_pos() + TIMING_WINDOW > notes[note_id].timing:
		if !notes[note_id].activated: 
			note_id += 1
			continue
		if event.as_text() == notes[note_id].direction:
			notes[note_id].activated = false
			pressed_amount += 1
	if pressed_amount == 0:
		damage_early()


func _process(_delta: float) -> void:
	while note_spawn_id < len(notes) && get_song_pos() + NOTE_SPAWN_OFFSET > notes[note_spawn_id].timing:
		spawn_note(notes[note_spawn_id])
		note_spawn_id += 1

	while note_active_id < len(notes) && get_song_pos() - TIMING_WINDOW > notes[note_active_id].timing:
		if notes[note_active_id].active:
			damage_late(notes[note_active_id].type)
		note_active_id += 1
