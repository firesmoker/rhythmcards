class_name NoteCard extends Panel
@onready var note_1: Panel = $Note1
@onready var note_2: Panel = $Note2

@export var notes: Array[float]
var notes_dictionary: Dictionary
enum note_status_types {ACTIVE,MISSED,PLAYED,PLAYED_BAD,INACTIVE}
var note_timings: Array[float]
var notes_triggered: Array[bool]
var active_note_num: int = -1
var active: bool:
	set(value):
		active = value
		toggle_highlight(value)
@export var beat_num: int = 1
var game: Game

func construct_notes_dictionary(note_durations_array: Array) -> void:
	notes_dictionary.clear()
	var index: int = 0
	for note in note_durations_array:
		notes_dictionary[index] = {}
		notes_dictionary[index]["duration"] = note
		notes_dictionary[index]["status"] = note_status_types.INACTIVE
		if index == 0:
			notes_dictionary[index]["game_object"] = note_1
		elif index == 1:
			notes_dictionary[index]["game_object"] = note_2
		index += 1
	calculate_note_timings()
	update_note_visuals()
	print(notes_dictionary)

func update_note_visuals() -> void:
	for i in notes_dictionary.size():
		match notes_dictionary[i]["status"]:
			note_status_types.INACTIVE:
				notes_dictionary[i]["game_object"].modulate =  Color.RED
			note_status_types.PLAYED:
				notes_dictionary[i]["game_object"].modulate =  Color.GREEN
			

func calculate_note_timings() -> void:
	var time_before_card_starts: float = game.one_beat_duration * (beat_num-1)
	#var index: int = 0
	for i in range(notes_dictionary.size()):
		if i not in notes_dictionary:
			return
		var current_note_duration: float = notes_dictionary[i]["duration"] * game.one_beat_duration / game.one_beat_value
		var previous_note_timing: float = 0
		if i == 0:
			notes_dictionary[i]["timing"] = time_before_card_starts
		elif i > 0:
			previous_note_timing = notes_dictionary[i-1]["timing"]
			notes_dictionary[i]["timing"] = previous_note_timing + current_note_duration
		#index += 1
		#print("for card " + str(name) + " note " + str(i) + " timing is " + str(notes_dictionary[i]["timing"]))

func _ready() -> void:
	game = find_parent("Game")
	if game != null:
		game.beat_signal.connect(toggle_by_beat)
		#game.round_changed.connect(set_note_timings.bind(notes))
		game.round_changed.connect(construct_notes_dictionary.bind(notes))
	construct_notes_dictionary(notes)
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

func autoplay(time: float) -> void:
	for i in range(notes_dictionary.size()):
		if notes_dictionary[i]["status"] == note_status_types.INACTIVE:
			if time >= notes_dictionary[i]["timing"]:
				print("dict triggerd " + str(notes_dictionary[i]["timing"]))
				notes_dictionary[i]["status"] = note_status_types.PLAYED
	update_note_visuals()

func _process(delta: float) -> void:
	if active:
		#automatic_note_play(game.elapsed_round_time)
		autoplay(game.elapsed_round_time)

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

func reset_note_triggers_dictionary() -> void:
	pass

func reset_note_triggers() -> void:
	notes_triggered.clear()
	for note in notes:
		notes_triggered.append(false)

func toggle_highlight(toggle: bool) -> void:
	if toggle:
		modulate = Color.WHITE
	else:
		modulate = Color.GRAY
