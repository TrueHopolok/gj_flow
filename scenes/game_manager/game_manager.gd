class_name GameManager
extends Node2D


const LEVEL_SECTION_DIR: String = ""
const NOTE_SPAWN_OFFSET: float = 2.0


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
	# maybe play some anitmation that next section starts

	music_player.play()


func get_song_pos() -> float:
	return music_player.get_playback_position()


func spawn_note(_note: LevelPart.Note) -> void:
	pass


func _process(_delta: float) -> void:
	if notes_spawning:
		while note_spawn_id < len(notes) && get_song_pos() > notes[note_spawn_id].timing:
			spawn_note(notes[note_spawn_id])
			note_spawn_id += 1
		notes_spawning = note_spawn_id < len(notes)
