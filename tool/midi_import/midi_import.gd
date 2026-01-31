@tool
extends EditorScript


# C2 - kick
# C#2 - snare
# F#2 - hi hat
# D2 - clap/snare

const NOTE_TYPES: Dictionary[String, String] = {
	"C2": LevelNote.LOW_RIGHT,
	"C#2": LevelNote.TOP_RIGHT,
	"F#2": LevelNote.TOP_LEFT,
	"D2": LevelNote.LOW_LEFT,
}

const INPUT_FILE: String = "/home/anpir/jam/midiparser/fuck.json"
const OUTPUT_RESOURCE: String = "res://assets/generated.tres"

func _run() -> void:
	var content := FileAccess.get_file_as_string(INPUT_FILE)
	if content == "":
		var err := FileAccess.get_open_error()
		printerr("Failed to open %s: %s" % [INPUT_FILE, error_string(err)])
		return
	
	var tracks := JSON.parse_string(content).tracks as Array
	if tracks.size() != 1:
		printerr("tracks: %d, want 1" % tracks.size())
		return
	
	var values: Dictionary = {}
	
	var min_time: float = 0.0
	var max_time: float = 0.0
	
	var notes: Array[LevelNote] = []
	
	for note in tracks[0].notes:
		min_time = minf(min_time, note.time)
		max_time = maxf(max_time, note.time)
		
		var tp = NOTE_TYPES.get(note.name, null)
		if tp == null:
			printerr("Unknown note: %s" % note.name)
			continue

		var ln := LevelNote.new()
		ln.type = LevelNote.NoteType.REGULAR
		ln.direction = tp
		ln.timing = note.time
		notes.append(ln)
	
	max_time -= min_time
	for note in notes:
		note.timing -= min_time
	
	var lp := LevelPart.new()
	lp.length = max_time
	lp.notes = notes
	ResourceSaver.save(lp, OUTPUT_RESOURCE)

	print("DONE!")
