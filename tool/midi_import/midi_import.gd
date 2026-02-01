@tool
extends EditorScript


# C2 - kick
# C#2 - snare
# F#2 - hi hat
# D2 - clap/snare

const NOTE_DIRS: Dictionary[String, String] = {
	"C2": LevelNote.LOW_RIGHT,
	"C#2": LevelNote.TOP_RIGHT,
	"F#2": LevelNote.TOP_LEFT,
	"D2": LevelNote.LOW_LEFT,
}

const DEFAULT_NOTE_TYPE := LevelNote.NoteType.REGULAR
const NOTE_TYPES: Dictionary[String, LevelNote.NoteType] = {
	"C2": LevelNote.NoteType.REGULAR,
	"C#2": LevelNote.NoteType.REGULAR,
	"F#2": LevelNote.NoteType.REGULAR,
	"D2": LevelNote.NoteType.REGULAR,
}

const INPUT_DIR: String = "res://assets/midi"
const OUTPUT_DIR: String = "res://assets/parts"

func _run() -> void:
	print(" ===== RUNNING  : midi_import.gd ===== ")
	convert_to_levelparts()
	print(" ===== FINISHED : midi_import.gd ===== ")

func convert_to_levelparts(path: String = INPUT_DIR, output_path: String = OUTPUT_DIR, level: int = 0) -> void:
	print("[DIR] %s" % path)

	var err: Error

	var dir := DirAccess.open(path)
	if !dir:
		err = DirAccess.get_open_error()
		printerr("Failed to open %s: %s" % [path, error_string(err)])
		return

	err = dir.list_dir_begin()
	if err != Error.OK:
		printerr("Failed to open %s: %s" % [path, error_string(err)])
		return

	while true:
		var file_name := dir.get_next()
		if file_name == "": break
		if file_name == "." or file_name == "..": continue
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			if level < 2: 
				DirAccess.make_dir_absolute(output_path.path_join(file_name))
				convert_to_levelparts(full_path, output_path.path_join(file_name), level + 1)
			continue
		if file_name.get_extension() != 'json':
			continue
		print("[read] %s" % file_name)

		var content := FileAccess.get_file_as_string(full_path)
		if content == "":
			err = FileAccess.get_open_error()
			printerr("Failed to read %s: %s" % [full_path, error_string(err)])
			continue

		var full := JSON.parse_string(content) as Dictionary
		var tracks := full.tracks as Array
		if tracks.size() != 1:
			printerr("Failed tracks: %d, want 1" % tracks.size())
			continue
		var bpm: float = full.header.bpm

		var notes: Array[LevelNote] = []
		for note in tracks[0].notes:
			var note_dir: Variant = NOTE_DIRS.get(note.name, null)
			if note_dir == null:
				printerr("Unknown note: %s" % note.name)
				continue
			var ln := LevelNote.new()
			ln.type = NOTE_TYPES.get(note.name, DEFAULT_NOTE_TYPE)
			ln.timing = note.time / 60.0 * bpm
			ln.direction = note_dir
			notes.append(ln)

		var lp := LevelPart.new()
		lp.notes = notes.duplicate(true)
		for note in lp.notes:
			print(note.timing)
		err = ResourceSaver.save(lp, output_path.path_join(file_name.get_basename() + '.tres'))
		if err == Error.OK:
			print("[save] %s" % output_path.path_join(file_name.get_basename() + '.tres'))
		else:
			printerr("Failed saving %s: %s" % [output_path.path_join(file_name.get_basename() + '.tres'), error_string(err)])

	dir.list_dir_end()
