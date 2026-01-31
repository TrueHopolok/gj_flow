class_name GameManager
extends Node2D


## Time between note spawn and getting in click range 
const NOTE_SPAWN_OFFSET: float = 2.0 # sec

## Absolute error of player's clicking the note
const TIMING_WINDOW: float = 0.25 # sec

@export_group('Section')
@export var sections: Array[LevelSection]

@export_group('Spawners')
@export var note_spawner_ll: NotePath = null
@export var note_spawner_tl: NotePath = null
@export var note_spawner_tr: NotePath = null
@export var note_spawner_lr: NotePath = null

@onready var music_player: PartialAudioStreamPlayer = $MusicPlayer



## Current state

var section_id: int
var section: LevelSection
var notes: Array[LevelNote]
var note_spawn_id: int
var note_active_id: int
var health: int = 100


func _ready() -> void:
	music_player.fully_finished.connect(next_section)
	start_game()


func start_game() -> void:
	assert(len(sections) > 0, "FAILED TO FIND ANY SECTIONS")
	health = LevelDamage.MAX_HEALTH
	section_id = -1
	next_section()


func next_section() -> void:
	if len(sections) - 1 > section_id:
		section_id += 1
	section = sections[section_id]
	section.parts.shuffle()

	notes.clear()
	music_player.stream_queue.clear()
	var offset: float = section.intro_stream.get_length() if is_instance_of(section.intro_stream, AudioStreamPlayer) else 0.0
	for part in section.parts:
		for note in part.notes:
			notes.append(note)
			notes[-1].timing += offset
		music_player.stream_queue.append(part.stream)
		offset += part.stream.get_length()
	note_spawn_id = 0
	note_active_id = 0

	# maybe play some animation that next section starts
	music_player.restart()


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

	match note.type:
		LevelNote.NoteType.ENEMY:
			spawner.spawn_enemy(NOTE_SPAWN_OFFSET)
		_:
			spawner.spawn_note(NOTE_SPAWN_OFFSET)


func damage(hp_change: int) -> void:
	if hp_change >= 0:
		health = min(LevelDamage.MAX_HEALTH, health + hp_change)
		return
	var min_health: int = 1 if health >= LevelDamage.SAVING_HEALTH_THRESHOLD else 0
	health = max(min_health, health + hp_change)
	if health == 0:
		print("DEAD")
		get_tree().quit(1)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&'low_left') || event.is_action_pressed(&'low_right') || event.is_action_pressed(&'top_left') || event.is_action_pressed(&'top_right'):
		var note_id: int = note_active_id
		var pressed_amount: int = 0
		while note_id < len(notes) && get_song_pos() + TIMING_WINDOW > notes[note_id].timing:
			if !notes[note_id].activated:
				note_id += 1
				continue
			if event.as_text() == notes[note_id].direction:
				notes[note_id].activated = false
				pressed_amount += 1
		if pressed_amount == 0: damage(LevelDamage.DAMAGE_PER_MISCLICK)
		else: damage(LevelDamage.HEAL_PER_HIT)


func _physics_process(_delta: float) -> void:
	while note_spawn_id < len(notes) && get_song_pos() + NOTE_SPAWN_OFFSET > notes[note_spawn_id].timing:
		spawn_note(notes[note_spawn_id])
		note_spawn_id += 1

	while note_active_id < len(notes) && get_song_pos() - TIMING_WINDOW > notes[note_active_id].timing:
		if notes[note_active_id].activated: damage(LevelDamage.DAMAGE_PER_MISS[notes[note_active_id].type])
		note_active_id += 1
