class_name GameManager
extends Node2D


signal switched_section(section_idx: int)

signal secret_happened

signal health_changed(new_health: int)
signal score_changed(new_score: int)

# dir: -2, -1, 1, 2
# val: "flow", "ok", "miss", "ouch"
signal feedback(dir: int, val: String)
signal drum_hit(dir: int)

const TIMING_MAX_SCORE: int = 100

## Absolute error of player's clicking the note
const TIMING_WINDOW: float = 0.15 # sec
const TIMING_PERFECT: float = 0.10 # sec

## Time between note spawn and getting in click range
var NOTE_SPAWN_OFFSET: float = 2.0 # sec

@export_group('Section')
@export var sections: Array[LevelSection]

@export_group('Spawners')
@export var note_spawner_ll: NoteSpawner = null
@export var note_spawner_tl: NoteSpawner = null
@export var note_spawner_tr: NoteSpawner = null
@export var note_spawner_lr: NoteSpawner = null

## Current state

var section_idx: int
var section: LevelSection

var notes: Array[LevelNote]
var next_spawn_idx: int
var next_destroy_idx: int

var health: int = 100
var score: int = 0

var rep_factor: float = 1.0

@onready var music_player: PartialAudioStreamPlayer = $MusicPlayer

@onready var kick_player: AudioStreamPlayer = $Kick
@onready var snare_player: AudioStreamPlayer = $Snare
@onready var clap_player: AudioStreamPlayer = $Clap
@onready var hi_hat_player: AudioStreamPlayer = $HiHat
@onready var funny_player: AudioStreamPlayer = $Funny


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
	return beat * 60 / (bpm * rep_factor)


func sec_to_beat(sec: float, bpm: float) -> float:
	assert(bpm > 0, "WTF BPM IS NEGATIVE OR ZERO, btw Rich's fault")
	return sec / 60 * (bpm * rep_factor)


func start_game() -> void:
	assert(len(sections) > 0, "FAILED TO FIND ANY SECTIONS")
	set_health(LevelDamage.MAX_HEALTH)
	set_score(0)
	section_idx = clampi(Persistance.cur_section, -1, len(sections)-1)
	next_section()


func next_section() -> void:
	if sections.size() - 1 == section_idx:
		rep_factor *= 1.2
	elif len(sections) - 1 > section_idx:
		Persistance.set_completed(section_idx)
		section_idx += 1
	switched_section.emit(section_idx)

	section = sections[section_idx].our_deep_clone()
	assert(section.bpm > 0, "ALLO BROTHA")
	NOTE_SPAWN_OFFSET = 120.0 / section.bpm
	section.parts.shuffle()
	if section.intro_part != null: section.parts.push_front(section.intro_part)
	if section.outro_part != null: section.parts.push_back(section.outro_part)

	# construct sections
	notes.clear()
	music_player.stream_queue.clear()

	var offset: float = 0.0
	for part: LevelPart in section.parts:
		assert(part.stream != null, "WTF")
		for note: LevelNote in part.notes:
			note.timing += sec_to_beat(offset, section.bpm)
			notes.append(note)
		music_player.stream_queue.append(part.stream)
		offset += part.stream.get_length() / rep_factor

	notes.sort_custom(func(ln: LevelNote, rn: LevelNote) -> bool:
		return ln.timing < rn.timing
	)
	next_spawn_idx = 0
	next_destroy_idx = 0

	# maybe play some animation that next section starts
	music_player.restart(rep_factor)


func spawn_note(note: LevelNote) -> void:
	var spawner: NoteSpawner
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
			printerr("Trying to spawn note in unknown direction: %s" % note.direction)

	if spawner == null:
		printerr("Trying to spawn node on unknown node path")
		return

	var hook: Callable
	if randf() <= section.enemy_chance:
		hook = spawner.spawn_enemy(NOTE_SPAWN_OFFSET)
	else:
		hook = spawner.spawn_note(NOTE_SPAWN_OFFSET)
	note.delete_hook = hook


func damage(hp_change: int) -> void:
	if hp_change >= 0:
		set_health(min(LevelDamage.MAX_HEALTH, health + hp_change))
		return

	if OS.has_feature("invincible"):
		return

	var min_health: int = 1 if health >= LevelDamage.SAVING_HEALTH_THRESHOLD else 0
	set_health(max(min_health, health + hp_change))
	if health == 0:
		ded()


func ded() -> void:
	get_parent().queue_free()
	var inst := preload("res://ui/game_over/game_over.tscn").instantiate()
	inst.score = score
	Transition.change_scene_inst(inst)


## handle_score should only be called with notes that were successfully hit, it always adds some points.
func handle_score(note: LevelNote, current_time_sec: float) -> bool:
	var delta := absf(beat_to_sec(note.timing, section.bpm) - current_time_sec)
	var score_delta := ceili(clampf(remap(delta, TIMING_PERFECT, TIMING_WINDOW, TIMING_MAX_SCORE, 0), 1, 100))
	add_score(score_delta)
	return score_delta == 100


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return

	if event.is_action_pressed("the_rock"):
		funny_player.play()
		secret_happened.emit()


	if not (event.is_action_pressed(LevelNote.LOW_LEFT) or event.is_action_pressed(LevelNote.LOW_RIGHT) or event.is_action_pressed(LevelNote.TOP_LEFT) or event.is_action_pressed(LevelNote.TOP_RIGHT)):
		return

	var dir_int := 1
	if event.is_action_pressed(LevelNote.LOW_LEFT):
		clap_player.play()
		dir_int = -2
		drum_hit.emit(-2)
	elif event.is_action_pressed(LevelNote.LOW_RIGHT):
		var chance := 0.001
		if OS.has_feature("rock"):
			chance = 0.5
		if randf() < chance:
			funny_player.play()
			secret_happened.emit()
		else:
			kick_player.play()
		dir_int = +2
		drum_hit.emit(+2)
	elif event.is_action_pressed(LevelNote.TOP_LEFT):
		hi_hat_player.play()
		dir_int = -1
		drum_hit.emit(-1)
	elif event.is_action_pressed(LevelNote.TOP_RIGHT):
		snare_player.play()
		dir_int = +1
		drum_hit.emit(+1)

	get_viewport().set_input_as_handled()
	var now := music_player.get_song_pos()

	var idx := next_destroy_idx
	var note_hit := false
	var is_perfect := false
	while idx < notes.size() and beat_to_sec(notes[idx].timing, section.bpm) - TIMING_WINDOW < now:
		if notes[idx].hittable and event.is_action_pressed(notes[idx].direction):
			notes[idx].hittable = false
			note_hit = true
			is_perfect = handle_score(notes[idx], now)
			if notes[idx].delete_hook.is_valid():
				notes[idx].delete_hook.call()
			break
		idx += 1

	if note_hit:
		if is_perfect:
			feedback.emit(dir_int, "perfect")
		else:
			feedback.emit(dir_int, "ok")
		damage(LevelDamage.HEAL_PER_HIT)
	else:
		damage(LevelDamage.DAMAGE_PER_MISCLICK)
		feedback.emit(dir_int, "miss")


func _physics_process(_delta: float) -> void:
	var now := music_player.get_song_pos()

	# Spawn new notes (in advance)
	while next_spawn_idx < notes.size() and beat_to_sec(notes[next_spawn_idx].timing, section.bpm) - NOTE_SPAWN_OFFSET < now:
		spawn_note(notes[next_spawn_idx])
		next_spawn_idx += 1

	# Destroy overdue notes, possibly damaging the player
	while next_destroy_idx < next_spawn_idx and beat_to_sec(notes[next_destroy_idx].timing, section.bpm) + TIMING_WINDOW < now:
		if notes[next_destroy_idx].hittable: # player did not hit it
			feedback.emit(_direction_to_int(notes[next_destroy_idx].direction), "ouch")
			damage(LevelDamage.DAMAGE_PER_MISS[notes[next_destroy_idx].type])
		next_destroy_idx += 1



func _direction_to_int(d: String) -> int:
	match d:
		LevelNote.LOW_LEFT:
			return -2
		LevelNote.TOP_LEFT:
			return -1
		LevelNote.TOP_RIGHT:
			return +1
		LevelNote.LOW_RIGHT:
			return +2
		_:
			assert(false)
			return -1
