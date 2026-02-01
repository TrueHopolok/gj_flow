class_name GameManager
extends Node2D


signal health_changed(new_health: int)
signal score_changed(new_score: int)

## Time between note spawn and getting in click range 
const NOTE_SPAWN_OFFSET: float = 2.0 # sec

## Absolute error of player's clicking the note
const TIMING_WINDOW: float = 0.25 # sec

const TIMING_PERFECT: float = 0.05 # sec
const TIMING_MAX_SCORE: int = 100

@export_group('Section')
@export var sections: Array[LevelSection]

@export_group('Spawners')
@export var note_spawner_ll: NotePath = null
@export var note_spawner_tl: NotePath = null
@export var note_spawner_tr: NotePath = null
@export var note_spawner_lr: NotePath = null

## Current state

var section_idx: int
var section: LevelSection

var notes: Array[LevelNote]
var next_spawn_idx: int
var next_destroy_idx: int

var health: int = 100
var score: int = 0

@onready var music_player: PartialAudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	music_player.fully_finished.connect(next_section)
	start_game()


func set_health(h: int) -> void:
	health = h
	health_changed.emit(health)


func set_score(s: int) -> void:
	score = s
	score_changed.emit(s)


## Yes, this method is necessary, don't question it.
func add_score(delta: int) -> void:
	set_score(score + delta)


func beat_to_sec(beat: float, bpm: float) -> float:
	assert(bpm > 0, "WTF BPM IS NEGATIVE OR ZERO, btw Rich's fault")
	return beat * 60 / bpm


func sec_to_beat(sec: float, bpm: float) -> float:
	assert(bpm > 0, "WTF BPM IS NEGATIVE OR ZERO, btw Rich's fault")
	return sec / 60 * bpm


func start_game() -> void:
	assert(len(sections) > 0, "FAILED TO FIND ANY SECTIONS")
	set_health(LevelDamage.MAX_HEALTH)
	set_score(0)
	section_idx = -1
	next_section()


func next_section() -> void:
	if len(sections) - 1 > section_idx:
		section_idx += 1

	section = sections[section_idx].duplicate(true)
	section.parts.shuffle()
	assert(section.bpm > 0, "ALLO BROTHA")

	# construct sections
	notes.clear()
	music_player.stream_queue.clear()

	var offset: float = 0.0
	if section.intro_stream != null:
		music_player.stream_queue.append(section.intro_stream)
		offset = section.intro_stream.get_length()

	for part: LevelPart in section.parts:
		if part.stream != null:
			for note: LevelNote in part.notes:
				notes.append(note)
				note.timing += sec_to_beat(offset, section.bpm)
			music_player.stream_queue.append(part.stream)
			offset += part.stream.get_length()

	next_spawn_idx = 0
	next_destroy_idx = 0

	# maybe play some animation that next section starts
	music_player.restart()


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
		set_health(min(LevelDamage.MAX_HEALTH, health + hp_change))
		return
	var min_health: int = 1 if health >= LevelDamage.SAVING_HEALTH_THRESHOLD else 0
	set_health(max(min_health, health + hp_change))
	if health == 0:
		print("DEAD")
		get_tree().quit(1)


## handle_score should only be called with notes that were successfully hit, it always adds some points.
func handle_score(note: LevelNote, current_time_sec: float) -> void:
	var delta := absf(beat_to_sec(note.timing, section.bpm) - current_time_sec)
	var score_delta := ceili(clampf(remap(delta, TIMING_PERFECT, TIMING_WINDOW, TIMING_MAX_SCORE, 0), 1, 100))
	add_score(score_delta)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return

	if not (event.is_action_pressed(LevelNote.LOW_LEFT) or event.is_action_pressed(LevelNote.LOW_RIGHT) or event.is_action_pressed(LevelNote.TOP_LEFT) or event.is_action_pressed(LevelNote.TOP_RIGHT)):
		return

	get_viewport().set_input_as_handled()
	var now := music_player.get_song_pos()

	var idx := next_destroy_idx
	var note_hit := false
	while idx < notes.size() and beat_to_sec(notes[idx].timing, section.bpm) - TIMING_WINDOW < now:
		if notes[idx].hittable and event.is_action_pressed(notes[idx].direction):
			notes[idx].hittable = false
			note_hit = true
			handle_score(notes[idx], now)
			break
		idx += 1
	
	if note_hit:
		damage(LevelDamage.HEAL_PER_HIT)
	else:
		damage(LevelDamage.DAMAGE_PER_MISCLICK)


# FIXME: second section loop does not work
func _physics_process(_delta: float) -> void:
	# TODO: remove debug print
	$Tlabel.text = str(sec_to_beat(music_player.get_song_pos(), section.bpm)) + " beats"

	var now := music_player.get_song_pos()

	# Spawn new notes (in advance)
	while next_spawn_idx < notes.size() and beat_to_sec(notes[next_spawn_idx].timing, section.bpm) - NOTE_SPAWN_OFFSET < now:
		spawn_note(notes[next_spawn_idx])
		next_spawn_idx += 1
	
	# Destroy overdue notes, possibly damaging the player
	while next_destroy_idx < next_spawn_idx and beat_to_sec(notes[next_destroy_idx].timing, section.bpm) + TIMING_WINDOW < now:
		if notes[next_destroy_idx].hittable: # player did not hit it
			damage(LevelDamage.DAMAGE_PER_MISS[notes[next_destroy_idx].type])
		next_destroy_idx += 1
