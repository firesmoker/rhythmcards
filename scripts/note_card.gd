class_name NoteCard extends Panel

@export var notes: Array[float]
var note_timings: Array[float]
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
		game.round_changed.connect(set_note_timings)

func check_note_time_triggers(time: float) -> void:
	for note_timing: float in note_timings:
		if time >= note_timing:
			print("triggerd " + str(note_timing))

func _process(delta: float) -> void:
	check_note_time_triggers(game.elapsed_time)

func set_note_timings() -> void:
	note_timings.clear()
	var time_before_card_starts: float = game.one_beat_duration * (beat_num-1)
	var count: int = 0
	for note in notes:
		var current_note_duration: float = note * game.one_beat_duration / game.one_beat_value
		var previous_note_timing: float = 0
		if count == 0:
			note_timings.append(time_before_card_starts)
		elif count > 0:
			previous_note_timing = note_timings[count - 1]
			note_timings.append(previous_note_timing + current_note_duration)
		count += 1
		print("for card " + str(name) + " note " + str(count) + " timing is " + str(note_timings[count - 1]))

func toggle_by_beat(round_beat: int) -> void:
	if round_beat == beat_num:
		active = true
	else:
		active = false

func toggle_highlight(toggle: bool) -> void:
	if toggle:
		modulate = Color.BLACK
	else:
		modulate = Color.WHITE
