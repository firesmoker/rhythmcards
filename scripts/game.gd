class_name Game extends Control

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var points_label: Label = $HUD/PointsLabel
@onready var streak_label: Label = $HUD/StreakLabel

var one_beat_duration: float = 1
var one_beat_value: float = 0.25
var one_beat_duration_counter: float = 0
var points: int = 0
var pre_beat_duration_counter: float = 0
var streak_counter: int = 0
var last_note_card_finished: int = 0
@export var stage_note_arrays: Array[Array]
var beat_num: int = 1
var time_signature: int = 4
var number_of_bars: int = 2
var number_of_beats_in_round: int
var tempo: float = 95
var round_duration: float
var elapsed_round_time: float = 0
var round_num: float:
	set(value):
		round_num = value
		if round_num == 0:
			music_player.play(round_num*round_duration)
#@export var note_cards: Array[Panel]
#@onready var note_card_1: Panel = $CanvasLayer/NoteCard1
signal beat_signal
signal play_signal
signal activate_signal
signal round_changed
signal scroll

func played_on_rest() -> void:
	sfx_player.stream = preload("res://sfx/wrong4.wav")
	sfx_player.play()
	reset_streak_counter()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("play"):
		if beat_num < 0:
			pass
		else:
			#play_sound()
			emit_signal("play_signal",elapsed_round_time)
		

func play_sound() -> void:
	sfx_player.stream = preload("res://sfx/clap.wav")
	sfx_player.play()

func construct_dummy_level() -> void:
	var number_of_stages: int = 10
	var notes_for_odd_array: Array = [0.25,0.25,0.125,0.125,0.125,0.125,]
	var odd_array: Array
	for i in range(notes_for_odd_array.size()):
		if i == 1:
			odd_array.append([notes_for_odd_array[i],"rest"])
		else:
			odd_array.append([notes_for_odd_array[i],"note"])
	var notes_for_even_array: Array = [0.125,0.125,0.125,0.125,0.25,0.25]
	var even_array: Array
	for i in range(notes_for_even_array.size()):
		if i == 1:
			even_array.append([notes_for_even_array[i],"rest"])
		else:
			even_array.append([notes_for_even_array[i],"note"])
	for i in range(number_of_stages):
		if i % 2 == 1:
			print("odd")
			stage_note_arrays.append(odd_array.duplicate())
		else:
			print("even")
			stage_note_arrays.append(even_array.duplicate())
	#print(stage_note_arrays)

func _ready() -> void:
	build_level()
	#construct_dummy_level()
	one_beat_duration = 60 / tempo
	#print(one_beat_duration)
	number_of_beats_in_round = time_signature * number_of_bars
	round_duration = number_of_beats_in_round * one_beat_duration
	round_num = -1
	#emit_signal("round_changed",0)
	#emit_signal("beat_signal",beat_num)

func _process(delta: float) -> void:
	if music_player.playing:
		elapsed_round_time += delta
	#print(elapsed_round_time)
	#pre_beat_counter(delta)
		beat_counter(delta)
	if last_note_card_finished == beat_num:
		#print("ready to pass to next card: " + str(last_note_card_finished + 1))
		emit_signal("activate_signal",last_note_card_finished + 1,false)
	if round_num == -1:
		emit_signal("round_changed",0)
		emit_signal("beat_signal",beat_num)

#func pre_beat_counter(delta: float) -> void:
	#pre_beat_duration_counter += delta
	#if pre_beat_duration_counter >= one_beat_duration/2:
		#pre_beat_num += 1
		#pre_beat_num -= one_beat_duration
		#if pre_beat_num > number_of_beats_in_round:
			#pre_beat_num = 1
			#elapsed_round_time = 0

func beat_counter(delta: float) -> void:
	one_beat_duration_counter += delta
	if one_beat_duration_counter >= one_beat_duration:
		beat_num += 1
		one_beat_duration_counter -= one_beat_duration
		if beat_num > number_of_beats_in_round:
			beat_num = 1
			elapsed_round_time = 0
			emit_signal("round_changed",round_num)
			last_note_card_finished = -1
		emit_signal("beat_signal",beat_num)
		#print("beat_signal")
	
func _on_beat_signal(beat_num: int) -> void:
	#metronome.play()
	if beat_num == number_of_beats_in_round:
		scroll_cards_up()
	print(beat_num)

func _on_round_changed(round: int) -> void:
	print("round changed")
	one_beat_duration_counter = 0
	round_num += 1
	emit_signal("play_signal",0)
	if round_num >= stage_note_arrays.size():
		get_tree().quit()

# Parses a comma-separated line of <symbol>:<duration> items.
# Example input: "-:1/4, C4:1/8, E3:1/2"
# Output: [[0.25, "rest"], [0.125, "note"], [0.5, "note"]]
# Parses a block of musical text into [[duration, "note"|"rest"], ...]
# Ignores extra whitespace, newlines, and symbols like "%4", "%3", etc.
func parse_notes_text(text: String) -> Array:
	var result: Array = []

	# Replace line breaks with spaces and remove '%' markers and trailing digits
	var cleaned := text.replace("\n", " ").replace("\r", "")
	cleaned = cleaned.replace("\t", " ")
	
	# Remove all occurrences of '%<number>'
	var regex := RegEx.new()
	regex.compile("%\\d+")
	cleaned = regex.sub(cleaned, "", true)
	
	# Split the text by spaces and commas into tokens like "C4:1/4" or "-:1"
	for token in cleaned.split(" "):
		var chunk := token.strip_edges()
		if chunk.is_empty():
			continue

		var parts := chunk.split(":")
		if parts.size() != 2:
			continue

		var symbol := parts[0].strip_edges()
		var dur_str := parts[1].strip_edges()

		var dur := _parse_fraction_to_float(dur_str)
		if dur < 0.0:
			continue

		var note_type := "rest" if symbol == "-" else "note"
		result.append([dur, note_type])
	print(result)
	return result


# Converts strings like "1/4" or "0.25" or "1" to float duration.
func _parse_fraction_to_float(s: String) -> float:
	var parts := s.split("/")
	if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		var num := int(parts[0])
		var den := int(parts[1])
		if den != 0:
			return float(num) / float(den)
	if s.is_valid_float():
		return float(s)
	return -1.0

func group_into_stages(parsed_notes: Array) -> Array[Array]:
	var stages: Array[Array] = []
	var current_stage: Array = []
	var accumulated := 0.0

	for entry: Array in parsed_notes:
		var dur: float= entry[0]
		var typ: String = entry[1]
		var stage_limit: float = number_of_bars * time_signature / 4
		# If adding this note exceeds the stage limit (1.0),
		# finalize current stage and start a new one.
		if accumulated + dur > stage_limit:
			stages.append(current_stage.duplicate())
			current_stage.clear()
			accumulated = 0.0

		current_stage.append(entry)
		accumulated += dur

		# If we hit exactly 1.0, finalize the stage
		if abs(accumulated - stage_limit) < 0.0001:
			stages.append(current_stage.duplicate())
			current_stage.clear()
			accumulated = 0.0

	# If anything remains at the end, include it
	if current_stage.size() > 0:
		stages.append(current_stage)
	print(stages)
	return stages

# Reads all text from a given file path and returns it as a String.
# Example: var contents = read_text_file("res://notes.txt")
func read_text_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: %s" % path)
		return ""
	
	var text := file.get_as_text()
	file.close()
	return text

func build_level() -> void:
	stage_note_arrays = group_into_stages(parse_notes_text(read_text_file("res://levels/test8.txt")))


func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("Game lost focus — pausing audio")
		get_tree().paused = true

	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		print("Game gained focus — resuming audio")
		get_tree().paused = false

func scroll_cards_up() -> void:
	emit_signal("scroll")

func update_score(points_change: float) -> void:
	points += points_change
	points_label.text = "Score: " + str(points)

func update_streak_counter(num: int = 1) -> void:
	streak_counter += num
	streak_label.text = "Streak: " + str(streak_counter)

func reset_streak_counter() -> void:
	streak_counter = 0
	streak_label.text = "Streak: " + str(streak_counter)
