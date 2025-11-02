class_name NoteCard extends Panel
@onready var note_1: TextureRect = $Note1
@onready var note_2: TextureRect = $Note2
@onready var deactivate_timer: Timer = $DeactivateTimer

@export var notes: Array[float]
@export var next_notes: Array[float]
var notes_dictionary: Dictionary
enum note_status_types {ACTIVE,MISSED,PLAYED,PLAYED_BAD,INACTIVE}
#var note_timings: Array[float]
#var notes_triggered: Array[bool]
@export var note_activation_allowed: bool = true
var active: bool:
	set(value):
		active = value
		toggle_highlight(value)
@export var beat_num: int = 1
var game: Game

func set_notes_visibility() -> void:
	note_1.visible = false
	note_2.visible = false
	for note in notes_dictionary:
		if notes_dictionary[note]["game_object"] != null:
			notes_dictionary[note]["game_object"].visible = true
			

func round_changed_effects(stage_index: int) -> void:
	construct_notes_dictionary(extract_beat_notes_from_full_round(game.stage_note_arrays[stage_index]))
	set_notes_visibility()
	disable_deactivation_timer()

func disable_deactivation_timer() -> void:
	deactivate_timer.stop()

func extract_beat_notes_from_full_round(notes_array: Array) -> Array:
	var new_notes_array: Array
	var previous_beats_duration: float = game.one_beat_value * (beat_num -1)
	var previous_beats_duration_counter: float = 0
	var current_beat_duration_counter: float = 0
	for note: float in notes_array:
		print(note)
		if previous_beats_duration_counter < previous_beats_duration:
			previous_beats_duration_counter += note
		elif current_beat_duration_counter < game.one_beat_value:
			new_notes_array.append(note)
			current_beat_duration_counter += note
		else:
			break
	print("new note array is: " + str(new_notes_array))
	return new_notes_array
	

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
		else:
			notes_dictionary[index]["game_object"] = note_2
		index += 1
		
	print("note_dictionary is: " + str(notes_dictionary))
	calculate_note_timings()
	clear_note_visuals()
	update_note_visuals()
	#print("note_card: " + name + str(notes_dictionary))

func clear_note_visuals() -> void:
	note_1.modulate =  Color.BLACK
	note_2.modulate =  Color.BLACK

func update_note_visuals() -> void:
	for i in notes_dictionary.size():
		match notes_dictionary[i]["status"]:
			#note_status_types.INACTIVE: ## DEBUG
				#notes_dictionary[i]["game_object"].modulate =  Color.RED
			note_status_types.MISSED:
				notes_dictionary[i]["game_object"].modulate =  Color.ORANGE
			#note_status_types.ACTIVE: ## DEBUG
				#notes_dictionary[i]["game_object"].modulate =  Color.BLUE	
			note_status_types.PLAYED:
				notes_dictionary[i]["game_object"].modulate =  Color.GREEN
			note_status_types.PLAYED_BAD:
				notes_dictionary[i]["game_object"].modulate =  Color.GREEN_YELLOW
			

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
	#next_notes = notes.duplicate()
	active = false
	pivot_offset.x = 0 + size.x / 2
	pivot_offset.y = 0 + size.y / 2
	game = find_parent("Game")
	if game != null:
		game.beat_signal.connect(beat_signal_effects)
		game.play_signal.connect(play)
		#game.round_changed.connect(set_note_timings.bind(notes))
		game.round_changed.connect(round_changed_effects)
		#game.round_changed.connect(construct_notes_dictionary.bind(notes))
		#game.round_changed.connect(disable_deactivation_timer)
		#game.beat_signal.connect(allow_note_activation)
		game.activate_signal.connect(toggle_by_beat)
		game.activate_signal.connect(activate_signal_effects)
	#construct_notes_dictionary(notes)
	#construct_notes_dictionary(extract_beat_notes_from_full_round(game.stage_note_arrays[0]))

func start_deactivation_timer(round_beat: int,time: float) -> void:
	if beat_num == round_beat:
		deactivate_timer.start(time)
		await deactivate_timer.timeout
		deactivate()

func deactivate() -> void:
	for note in notes_dictionary:
		match notes_dictionary[note]["status"]:
			note_status_types.PLAYED:
				pass
			note_status_types.PLAYED_BAD:
				pass
			_:
				notes_dictionary[note]["status"] = note_status_types.MISSED
	update_note_visuals()
	active = false

func beat_signal_effects(round_beat: int, verify: bool = true) -> void:
	pulse(round_beat)
	start_deactivation_timer(round_beat, game.one_beat_duration)
	toggle_by_beat(round_beat, true)

func activate_signal_effects(round_beat: int, verify: bool = true) -> void:
	if round_beat == beat_num:
		print(str(beat_num) + " card activated")


func play(time: float) -> void:
	if active:
		for i in range(notes_dictionary.size()):
			if notes_dictionary[i]["status"] == note_status_types.ACTIVE:
				if time >= notes_dictionary[i]["timing"] + notes_dictionary[i]["duration"] / 2:
					play_note_by_index(i,true)
				elif time >= notes_dictionary[i]["timing"]:
					play_note_by_index(i)
				elif time < notes_dictionary[i]["timing"] and time > notes_dictionary[i]["timing"] - notes_dictionary[i]["duration"] / 2:
					play_note_by_index(i)
				elif time > notes_dictionary[i]["timing"] - notes_dictionary[i]["duration"]:
					play_note_by_index(i, true)
				else:
					miss_note_by_index(i )
				return
		update_note_visuals()

func miss_note_by_index(note_index: int) -> void:
	if note_index in notes_dictionary:
		
		notes_dictionary[note_index]["status"] = note_status_types.MISSED
		if note_index + 1 in notes_dictionary:
			notes_dictionary[note_index + 1]["status"] = note_status_types.ACTIVE

func play_note_by_index(note_index: int, bad_play: bool = false) -> void:
	if note_index in notes_dictionary:
		if notes_dictionary[note_index]["status"] == note_status_types.ACTIVE:
			if bad_play:
				notes_dictionary[note_index]["status"] = note_status_types.PLAYED_BAD
			else:
				notes_dictionary[note_index]["status"] = note_status_types.PLAYED
		if note_index + 1 in notes_dictionary:
			notes_dictionary[note_index + 1]["status"] = note_status_types.ACTIVE

func _process(delta: float) -> void:
	if active:
		#autoplay(game.elapsed_round_time)
		#play(game.elapsed_round_time)
		handle_deactivate_and_allow_next_card()
	update_note_visuals()


func toggle_by_beat(round_beat: int, verify: bool = true) -> void:
	if verify:
		if game.beat_num != round_beat:
			#print("for card " + str(beat_num) + " game.beat_num is " + str(game.beat_num) + "and round_beat is: " + str(round_beat))
			return
	if round_beat == beat_num:
		active = true
		activate_note_by_index(0)
	else:
		#print("for card " + str(beat_num) + " beat_num is " + str(beat_num) + "and round_beat is: " + str(round_beat))
		active = false

func handle_deactivate_and_allow_next_card() -> void:
	update_when_all_notes_finished()

func update_when_all_notes_finished() -> void:
	for note in notes_dictionary:
		match notes_dictionary[note]["status"]:
			note_status_types.INACTIVE:
				return
			note_status_types.ACTIVE:
				return
	game.last_note_card_finished = beat_num
	#print("last note card finished in game: " + str(game.last_note_card_finished))

func activate_note_by_index(index: int) -> void:
	#print("activate_note_by_index triggered for " + str(beat_num))
	if index in notes_dictionary and note_activation_allowed:
		if notes_dictionary[index]["status"] == note_status_types.INACTIVE:
			notes_dictionary[index]["status"] = note_status_types.ACTIVE

func toggle_highlight(toggle: bool) -> void:
	if toggle:
		modulate = Color.WHITE
	else:
		modulate = Color.GRAY

func pulse(round_beat: int,time: float = 0.2) -> void:
	if round_beat == beat_num:
		scale = scale*1.15
		await get_tree().create_timer(time).timeout
		scale = scale*1/1.15

func allow_note_activation(beat_input: int) -> void:
	if beat_input == beat_num:
		note_activation_allowed = true
