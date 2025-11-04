class_name Game extends Control
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var one_beat_duration: float = 1
var one_beat_value: float = 0.25
var one_beat_duration_counter: float = 0

var pre_beat_duration_counter: float = 0
#var pre_beat_num: int = 1
var last_note_card_finished: int = 0
@export var stage_note_arrays: Array[Array]
var beat_num: int = 1
var time_signature: int = 4
var number_of_bars: int = 1
var number_of_beats_in_round: int
var tempo: float = 135
var round_duration: float
var elapsed_round_time: float = 0
var round_num: float:
	set(value):
		round_num = value
		if not music_player.playing and round_num >= 0:
			music_player.play(round_num*round_duration)
#@export var note_cards: Array[Panel]
#@onready var note_card_1: Panel = $CanvasLayer/NoteCard1
signal beat_signal
signal play_signal
signal activate_signal
signal round_changed


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("play"):
		sfx_player.play()
		emit_signal("play_signal",elapsed_round_time)

func construct_dummy_level() -> void:
	var number_of_stages: int = 10
	var odd_array: Array = [0.25,0.25,0.125,0.125,0.125,0.125,]
	var even_array: Array = [0.125,0.125,0.125,0.125,0.25,0.25]
	for i in range(number_of_stages):
		if i % 2 == 1:
			print("odd")
			stage_note_arrays.append(odd_array.duplicate())
		else:
			print("even")
			stage_note_arrays.append(even_array.duplicate())
	#print(stage_note_arrays)

func _ready() -> void:
	construct_dummy_level()
	one_beat_duration = 60 / tempo
	#print(one_beat_duration)
	number_of_beats_in_round = time_signature * number_of_bars
	round_duration = number_of_beats_in_round * one_beat_duration
	round_num = -1
	emit_signal("round_changed",0)
	emit_signal("beat_signal",beat_num)

func _process(delta: float) -> void:
	elapsed_round_time += delta
	#print(elapsed_round_time)
	#pre_beat_counter(delta)
	beat_counter(delta)
	if last_note_card_finished == beat_num:
		#print("ready to pass to next card: " + str(last_note_card_finished + 1))
		emit_signal("activate_signal",last_note_card_finished + 1,false)

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
	print(beat_num)

func _on_round_changed(round: int) -> void:
	round_num += 1
