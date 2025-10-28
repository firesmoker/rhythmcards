class_name NoteCard extends Panel

@export var notes: Array[float]
var note_timings: Array[float]
var notes_triggered: Array[bool]
var active_note_num: int = -1
var active: bool:
	set(value):
		active = value
		toggle_highlight(value)
@export var beat_num: int = 1
var game: Game

func _ready() -> void:
	game = find_parent("Game")
	if game != null:
		game.beat_signal.connect(toggle_by_beat)
		game.round_changed.connect(set_note_timings.bind(notes))
	#reset_note_triggers()
	#for note in notes:
		#notes_triggered.append(false)

func automatic_note_play(time: float) -> void:
	var count: int = 0
	for note_timing: float in note_timings:
		if not notes_triggered[count]:
			if time >= note_timing:
				print("triggerd " + str(note_timing))
				notes_triggered[count] = true
		count += 1

func _process(delta: float) -> void:
	if active:
		automatic_note_play(game.elapsed_round_time)

func set_note_timings(notes_array: Array = notes) -> void:
	note_timings.clear()
	var time_before_card_starts: float = game.one_beat_duration * (beat_num-1)
	var count: int = 0
	for note in notes_array:
		var current_note_duration: float = note * game.one_beat_duration / game.one_beat_value
		var previous_note_timing: float = 0
		if count == 0:
			note_timings.append(time_before_card_starts)
		elif count > 0:
			previous_note_timing = note_timings[count - 1]
			note_timings.append(previous_note_timing + current_note_duration)
		count += 1
		print("for card " + str(name) + " note " + str(count) + " timing is " + str(note_timings[count - 1]))
	reset_note_triggers()

func toggle_by_beat(round_beat: int) -> void:
	if round_beat == beat_num:
		active = true
	else:
		active = false

func reset_note_triggers() -> void:
	notes_triggered.clear()
	for note in notes:
		notes_triggered.append(false)

func toggle_highlight(toggle: bool) -> void:
	if toggle:
		modulate = Color.BLACK
	else:
		modulate = Color.WHITE
