class_name NoteCard extends Panel
@onready var note_1: Note = $Note1
@onready var note_2: Note = $Note2
@onready var early_note_1: Note = $EarlyNote1
@onready var late_note_1: Note = $LateNote1
@onready var early_note_2: Note = $EarlyNote2
@onready var late_note_2: Note = $LateNote2

@onready var display_note_1: Note = $NoteCardDisplay/DisplayNote1
@onready var display_note_2: Note = $NoteCardDisplay/DisplayNote2
var scrolling: bool = false
@onready var deactivate_timer: Timer = $DeactivateTimer
#@export var display_card: bool = false
@export var notes: Array[float]
@export var next_notes: Array[float]
var notes_dictionary: Dictionary
#@onready var display_timer: Timer = $NoteCardDisplay/DisplayTimer
var next_notes_dictionary: Dictionary
var original_position: Vector2
@onready var _3d_panel: Panel = $"3DPanel"
@onready var note_card_display_2: Panel = $NoteCardDisplay2

var time_scrolling: float = 0.01
enum note_status_types {ACTIVE,MISSED,PLAYED,PLAYED_BAD,INACTIVE}
#var note_timings: Array[float]
#var notes_triggered: Array[bool]
@onready var note_card_display: Panel = $NoteCardDisplay

@export var note_activation_allowed: bool = true
var active: bool:
	set(value):
		active = value
		#if value == false:
			#start_display_timer()
		#toggle_highlight(value)
@export var beat_num: int = 1
var game: Game
@onready var selection_panel: Panel = $SelectionPanel

func set_notes_visibility() -> void:
	note_1.visible = false
	note_2.visible = false
	var index: int = 0
	for note in notes_dictionary:
		if notes_dictionary[note]["game_object"] != null:
			notes_dictionary[note]["game_object"].visible = true
			var note_duration: String
			match notes_dictionary[note]["duration"]:
				0.25:
					note_duration = "quarter"
				0.125:
					match decide_eigths_type():
						"single": 
							note_duration = "eigth-single"
						"double":
							if index == 0:
								note_duration = "eigth-first"
							else:
								note_duration = "eigth-second"
			notes_dictionary[note]["game_object"].set_note(note_duration,notes_dictionary[note]["type"])
		index += 1

func decide_eigths_type(dictionary: Dictionary = notes_dictionary) -> String:
	var eighth_type: String = "single" # decide if this or double_eigth
	var eigth_counter: int = 0
	for note in dictionary:
		if dictionary[note]["game_object"] != null:
			var note_duration: String
			if dictionary[note]["type"] == "note":
				match dictionary[note]["duration"]:
					0.125:
						eigth_counter += 1
			#dictionary[note]["game_object"].set_note(note_duration)
	if eigth_counter == 2:
		eighth_type = "double"
	return eighth_type

func round_changed_effects(stage_index: int) -> void:
	print("Note Card: " + name + " round changed!")
	reset_early_late_notes_visibility()
	reset_position()
	reset_next_notes_alpha()
	reset_main_card_alpha()
	reset_dummy_card_alpha()
	#display_timer.stop()
	#note_card_display.visible = true
	if stage_index < game.stage_note_arrays.size():
		#if active:
			#deactivate()
		construct_notes_dictionary(extract_beat_notes_from_full_round(game.stage_note_arrays[stage_index]))
		if stage_index + 1 < game.stage_note_arrays.size():
			construct_notes_dictionary(extract_beat_notes_from_full_round(game.stage_note_arrays[stage_index + 1]),true)
	set_notes_visibility()
	transition_to_next_card_visual()
	clear_note_visuals()
	disable_deactivation_timer()	
	

func disable_deactivation_timer() -> void:
	deactivate_timer.stop()

func extract_beat_notes_from_full_round(notes_array: Array) -> Array:
	var new_notes_array: Array
	var previous_beats_duration: float = game.one_beat_value * (beat_num -1)
	var previous_beats_duration_counter: float = 0
	var current_beat_duration_counter: float = 0
	for note: Array in notes_array:
		#print(note)
		if previous_beats_duration_counter < previous_beats_duration:
			previous_beats_duration_counter += note[0]
		elif current_beat_duration_counter < game.one_beat_value:
			new_notes_array.append(note)
			current_beat_duration_counter += note[0]
		else:
			break
	#print("new note array is: " + str(new_notes_array))
	return new_notes_array

func construct_notes_dictionary(note_durations_array: Array, next: bool = false) -> void:
	var index: int = 0
	if not next:
		notes_dictionary.clear()
		for note in note_durations_array:
			notes_dictionary[index] = {}
			notes_dictionary[index]["duration"] = note[0]
			notes_dictionary[index]["type"] = note[1]
			notes_dictionary[index]["status"] = note_status_types.INACTIVE
			if index == 0:
				notes_dictionary[index]["game_object"] = note_1
			elif index == 1:
				notes_dictionary[index]["game_object"] = note_2
			else:
				notes_dictionary[index]["game_object"] = note_2
			index += 1
			
		#print("note_dictionary is: " + str(notes_dictionary))
		calculate_note_timings()
		#clear_note_visuals()
		update_note_visuals()
	else:
		next_notes_dictionary.clear()
		for note in note_durations_array:
			next_notes_dictionary[index] = {}
			next_notes_dictionary[index]["duration"] = note[0]
			next_notes_dictionary[index]["status"] = note_status_types.INACTIVE
			next_notes_dictionary[index]["type"] = note[1]
			if index == 0:
				next_notes_dictionary[index]["game_object"] = display_note_1
			elif index == 1:
				next_notes_dictionary[index]["game_object"] = display_note_2
			else:
				next_notes_dictionary[index]["game_object"] = display_note_2
			index += 1
			
		#print("note_dictionary is: " + str(notes_dictionary))
		#calculate_note_timings()
		#clear_note_visuals()
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
				notes_dictionary[i]["game_object"].modulate =  Color.FIREBRICK
			#note_status_types.ACTIVE: ## DEBUG
				#notes_dictionary[i]["game_object"].modulate =  Color.BLUE	
			note_status_types.PLAYED:
				notes_dictionary[i]["game_object"].modulate =  Color(0.112, 0.835, 0.835)
			note_status_types.PLAYED_BAD:
				notes_dictionary[i]["game_object"].modulate =  Color.CORAL

func show_early_late_note(note_num: int, mistake_type: String) -> void:
	if note_num == 0:
		if mistake_type == "early":
			early_note_1.visible = true
		elif mistake_type == "late":
			late_note_1.visible = true
	elif note_num == 1:
		if mistake_type == "early":
			early_note_2.visible = true
		elif mistake_type == "late":
			late_note_2.visible = true

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
	note_card_display.visible = true
	original_position = position
	selection_panel.visible = true
	#next_notes = notes.duplicate()
	active = false
	pivot_offset.x = 0 + size.x / 2
	pivot_offset.y = 0 + size.y / 2
	game = find_parent("Game")
	if game != null:
		game.beat_signal.connect(beat_signal_effects)
		game.play_signal.connect(play)
		game.round_changed.connect(round_changed_effects)
		game.activate_signal.connect(toggle_by_beat)
		game.activate_signal.connect(activate_signal_effects)
		game.scroll.connect(start_scrolling)

func start_deactivation_timer(round_beat: int,time: float) -> void:
	if beat_num == round_beat:
		deactivate_timer.start(time)
		await deactivate_timer.timeout
		deactivate()

#func start_display_timer(time: float = game.one_beat_duration) -> void:
	#display_timer.start(time)

func deactivate() -> void:
	for note in notes_dictionary:
		match notes_dictionary[note]["status"]:
			note_status_types.PLAYED:
				pass
			note_status_types.PLAYED_BAD:
				pass
			_:
				notes_dictionary[note]["status"] = note_status_types.MISSED
				if notes_dictionary[note]["type"] == "note":
					game.reset_streak_counter()
	update_note_visuals()
	active = false

func beat_signal_effects(round_beat: int, verify: bool = true) -> void:
	if game.hints_on:
		selection_pulse(round_beat)
	start_deactivation_timer(round_beat, game.one_beat_duration)
	toggle_by_beat(round_beat, true)
	#if round_beat == beat_num:
		#transition_to_next_card_visual()
		#start_display_timer(0.5)

func activate_signal_effects(round_beat: int, verify: bool = true) -> void:
	if round_beat == beat_num:
		pass
		#print(str(beat_num) + " card activated")


func play(time: float) -> void:
	if active:
		show_where_i_played(time)
		for i in range(notes_dictionary.size()):
			if notes_dictionary[i]["type"] == "rest" and i + 1 in notes_dictionary:
					notes_dictionary[i + 1]["status"] = note_status_types.ACTIVE
					i = i + 1
			var d: float = notes_dictionary[i]["duration"]
			var t: float = notes_dictionary[i]["timing"]
			if notes_dictionary[i]["status"] == note_status_types.ACTIVE:
				if time >= t + d * (1-d):
					play_note_by_index(i,true)
					show_early_late_note(i,"late")
				elif time >= t:
					play_note_by_index(i)
				elif time < t and time > t - d:
					play_note_by_index(i)
				elif time > t - d * (1-d):
					play_note_by_index(i, true)
					show_early_late_note(i,"early")
				else:
					miss_note_by_index(i )
				if notes_dictionary[i]["type"] == "note":
					pass
				elif notes_dictionary[i]["type"] == "rest":
					game.played_on_rest()
				return
		update_note_visuals()

func miss_note_by_index(note_index: int) -> void:
	if note_index in notes_dictionary:
		game.reset_streak_counter()
		notes_dictionary[note_index]["status"] = note_status_types.MISSED
		if note_index + 1 in notes_dictionary:
			notes_dictionary[note_index + 1]["status"] = note_status_types.ACTIVE

func play_note_by_index(note_index: int, bad_play: bool = false) -> void:
	if note_index in notes_dictionary:
		if notes_dictionary[note_index]["status"] == note_status_types.ACTIVE and notes_dictionary[note_index]["type"] == "note":
			if bad_play:
				game.update_score(5)
				game.update_streak_counter()
				notes_dictionary[note_index]["status"] = note_status_types.PLAYED_BAD
			else:
				game.update_score(10)
				game.update_streak_counter()
				notes_dictionary[note_index]["status"] = note_status_types.PLAYED
		if note_index + 1 in notes_dictionary:
			notes_dictionary[note_index + 1]["status"] = note_status_types.ACTIVE

func _process(delta: float) -> void:
	#print(delta)
	fade_next_card_notes_in()
	if scrolling:
		fade_main_card_out(0.06)
		dummy_card_fade_in(0.03)
		scroll_up(delta,game.note_card_scroll_speed * 0.75, 365.0)
	display_card_fade_in(delta, game.one_beat_duration)
	selection_panel.self_modulate.a -= 0.015
	if active:
		#autoplay(game.elapsed_round_time)
		#play(game.elapsed_round_time)
		update_when_all_notes_finished()
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

#func handle_deactivate_and_allow_next_card() -> void:
	#update_when_all_notes_finished()

func update_when_all_notes_finished() -> void:
	for note in notes_dictionary:
		if notes_dictionary[note]["type"] == "note":
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

func selection_pulse(round_beat: int,time: float = 0.2) -> void:
	if round_beat == beat_num:
		selection_panel.self_modulate.a = 1
		#if beat_num == 1 or beat_num == 5:
			#selection_panel.self_modulate.a = 1

func pulse(round_beat: int,time: float = 0.2) -> void:
	if round_beat == beat_num:
		scale = scale*1.15
		await get_tree().create_timer(time).timeout
		scale = scale*1/1.15

func allow_note_activation(beat_input: int) -> void:
	if beat_input == beat_num:
		note_activation_allowed = true

func set_next_display_notes_visibility() -> void:
	display_note_1.visible = false
	display_note_2.visible = false
	var index: int = 0
	for note in next_notes_dictionary:
		if next_notes_dictionary[note]["game_object"] != null:
			next_notes_dictionary[note]["game_object"].visible = true
			var note_duration: String
			match next_notes_dictionary[note]["duration"]:
				0.25:
					note_duration = "quarter"
				0.125:
					match decide_eigths_type(next_notes_dictionary):
						"single": 
							note_duration = "eigth-single"
						"double":
							if index == 0:
								note_duration = "eigth-first"
							else:
								note_duration = "eigth-second"
				_:
					print("next dic note dur is: " + str(next_notes_dictionary[note]["duration"]))
			next_notes_dictionary[note]["game_object"].set_note(note_duration,next_notes_dictionary[note]["type"])
		else:
			print("next dict object is null")
		index += 1

func display_card_fade_in(delta: float, time: float) -> void:
	note_card_display.modulate.a += delta / time

func transition_to_next_card_visual() -> void:
	set_next_display_notes_visibility()
	#note_card_display.modulate.a = 1
	#note_card_display.visible = true

#func _on_display_timer_timeout() -> void:
	#set_next_display_notes_visibility()
	#note_card_display.modulate.a = 1
	#note_card_display.visible = true

func scroll_up(delta: float, time_to_scroll: float, distance: float) -> void:
	time_scrolling += delta
	var weight: float = clamp(time_scrolling / time_to_scroll,0,1)
	#print(weight)
	var target_position: Vector2 = Vector2(original_position.x,original_position.y - distance)
	position = lerp(original_position,target_position,weight)
	#if weight >= 1:
		#reset_position()

func start_scrolling() -> void:
	#await get_tree().create_timer(game.one_beat_duration * 0.15).timeout
	scrolling = true

func reset_position() -> void:
	note_card_display.modulate.a = 0.01
	scrolling = false
	time_scrolling = 0
	position = original_position

func reset_main_card_alpha() -> void:
	self_modulate.a = 1
	note_1.self_modulate.a  = 1
	note_2.self_modulate.a  = 1
	#selection_panel.self_modulate.a = 1
	_3d_panel.self_modulate.a = 1

func dummy_card_fade_in(rate: float = 0.01) -> void:
	note_card_display_2.modulate.a += rate

func reset_dummy_card_alpha() -> void:
	note_card_display_2.modulate.a = 0
	
func reset_next_notes_alpha() -> void:
	display_note_1.modulate.a = 0
	display_note_2.modulate.a = 0

func fade_main_card_out(rate: float = 0.01) -> void:
	self_modulate.a -= rate
	note_1.self_modulate.a -= rate
	note_2.self_modulate.a -= rate
	selection_panel.self_modulate.a -= rate
	_3d_panel.self_modulate.a -= rate

func fade_next_card_notes_in(rate: float = 0.01) -> void:
	display_note_1.modulate.a += rate
	display_note_2.modulate.a += rate

func reset_early_late_notes_visibility() -> void:
	late_note_1.visible = false
	early_note_1.visible = false
	late_note_2.visible = false
	early_note_2.visible = false
	
func show_where_i_played(time: float) -> void:
	var mark_x_position: float = size.x * (time / game.one_beat_duration)
