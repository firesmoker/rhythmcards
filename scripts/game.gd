class_name Game extends Control

#static var level_details: Dictionary
static var current_song: Song
static var hints_on: bool = true
static var vibration_strength: float = 0.1
static var vibration_time: int = 500
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var points_label: Label = $HUD/PointsLabel
@onready var streak_label: Label = $HUD/StreakLabel
var note_card_scroll_speed: float
var streak_label_original_scale: Vector2
var trying_to_scroll : bool = false
var scrolling_allowed: bool = false
var scrolling: bool = false
var delayed_play_allowed: bool = false
var delayed_play_in_progress: bool = false
var one_beat_duration: float = 1
var one_beat_value: float = 0.25
var one_beat_duration_counter: float = 0
var points: int = 0
var pre_beat_duration_counter: float = 0
var streak_counter: int = 0
var combo_counter: int = 1
var last_note_card_finished: int = 0
@export var stage_note_arrays: Array[Array]
var beat_num: int = 1
var time_signature: int = 4
var number_of_bars: int = 2
var number_of_beats_in_round: int
var tempo: float = 65
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
	#sfx_player.stream = preload("res://sfx/wrong4.wav")
	#sfx_player.play()
	reset_streak_counter()

func _input(event: InputEvent) -> void:
	OS.request_permissions()
	if event is InputEventScreenTouch:
		if event.pressed:
			play()
			print(vibration_time)
			print(vibration_strength)
			Input.vibrate_handheld(Game.vibration_time,Game.vibration_strength)
	elif event.is_action_pressed("play"):
		play()

	
		

func play() -> void:
	#play_sound()
	if delayed_play_allowed:
		#play_sound()
		print("calling for delayed play")
		delayed_play_in_progress = true
	else:
		print("play_signal, beat_num is: " + str(beat_num))
		if beat_num < 0:
			pass
		else:
			#play_sound()
			emit_signal("play_signal",elapsed_round_time)

func play_sound() -> void:
	sfx_player.stream = load("res://sfx/clap.wav")
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
			#print("odd")
			stage_note_arrays.append(odd_array.duplicate())
		else:
			#print("even")
			stage_note_arrays.append(even_array.duplicate())
	#print(stage_note_arrays)

#func _init() -> void:
	#if level_details.is_empty():
		#fallback_to_default_level_details()

func _init() -> void:
	if current_song == null:
		fallback_to_default_level_details()

func set_scroll_speed() -> void:
	note_card_scroll_speed = one_beat_duration - one_beat_duration_counter
	#note_card_scroll_speed = one_beat_duration * 0.75

func fallback_to_default_level_details() -> void:
	set_current_song(SongLibrary.get_song_by_id("generic_65bpm"))
	print("current_song is:")
	current_song.print_details()
	print("fallback to default level details")

func _ready() -> void:
	OS.request_permissions()
	streak_label_original_scale = streak_label.scale
	build_level(current_song)
	one_beat_duration = 60 / tempo
	number_of_beats_in_round = time_signature * number_of_bars
	round_duration = number_of_beats_in_round * one_beat_duration
	round_num = -1
	set_scroll_speed()

func _process(delta: float) -> void:
	streak_label_return_to_original_size()
	if music_player.playing:
		elapsed_round_time += delta
		beat_counter(delta)
	if last_note_card_finished == beat_num:
		emit_signal("activate_signal",last_note_card_finished + 1,false)
	if round_num == -1:
		emit_signal("round_changed",0)
		emit_signal("beat_signal",beat_num)
	try_to_initiate_scroll()


func beat_counter(delta: float) -> void:
	if beat_num == 1:
		if delayed_play_in_progress:
			print("executing delayed play")
			emit_signal("play_signal",0)
		if delayed_play_allowed:
			allow_delayed_play(false)
	one_beat_duration_counter += delta
	if one_beat_duration_counter >= one_beat_duration:
		beat_num += 1
		one_beat_duration_counter -= one_beat_duration
		if beat_num == number_of_beats_in_round and last_note_card_finished == number_of_beats_in_round:
			allow_delayed_play()
		if beat_num > number_of_beats_in_round:
			beat_num = 1
			elapsed_round_time = 0
			emit_signal("round_changed",round_num)
			last_note_card_finished = -1
		emit_signal("beat_signal",beat_num)
	
func _on_beat_signal(beat_num_index: int) -> void:
	if beat_num_index == number_of_beats_in_round:
		trying_to_scroll = true

func allow_delayed_play(toggle: bool = true) -> void:
	print("delayed play allowed?: " + str(toggle))
	delayed_play_allowed = toggle
	if toggle == false:
		delayed_play_in_progress = false

func _on_round_changed(_round_index: int) -> void:
	one_beat_duration_counter = 0
	scrolling = false
	trying_to_scroll = false
	scrolling_allowed = false
	
	round_num += 1
	#emit_signal("play_signal",0)
	if round_num >= stage_note_arrays.size():
		return_to_song_selection()

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
	#print(result)
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
		#var typ: String = entry[1]
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
	#print(stages)
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

func build_level(song: Song) -> void:
	stage_note_arrays = group_into_stages(parse_notes_text(read_text_file(song.melody_filename)))
	music_player.stream = load(song.bgm_filename)
	tempo = song.tempo




func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("Game lost focus — pausing audio")
		get_tree().paused = true

	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		print("Game gained focus — resuming audio")
		get_tree().paused = false

func scroll_cards_up() -> void:
	if not scrolling:
		scrolling = true
		set_scroll_speed()
		emit_signal("scroll")

func try_to_initiate_scroll() -> void:
	if trying_to_scroll:
		if last_note_card_finished == number_of_beats_in_round:
			scrolling_allowed = true
	if scrolling_allowed:
		scroll_cards_up()
			

func update_score(points_change: float) -> void:
	points += points_change * combo_counter
	points_label.text = "Score " + str(points)

func update_streak_counter(num: int = 1) -> void:
	streak_counter += num
	if streak_counter % 4 == 0:
		combo_counter += 1
		streak_label.text = "Combo x" + str(combo_counter)
		streak_label_size_pulse()

func reset_streak_counter() -> void:
	streak_counter = 0
	combo_counter = 1
	streak_label.text = "Combo x" + str(combo_counter)


func _on_music_player_finished() -> void:
	return_to_song_selection()

static func set_current_song(song: Song) -> void:
	current_song = song

func return_to_song_selection() -> void:
	get_tree().change_scene_to_file("res://scenes/content_selection.tscn")

func streak_label_size_pulse() -> void:
	streak_label.scale *= 2

func streak_label_return_to_original_size() -> void:
	if streak_label.scale > streak_label_original_scale:
		streak_label.scale *= 0.97
	else:
		streak_label.scale = streak_label_original_scale
