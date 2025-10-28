class_name Game extends Control
var one_beat_duration: float = 1
var one_beat_value: float = 0.25
var one_beat_duration_counter: float = 0
var beat_num: int = 1
var time_signature: int = 4
var number_of_bars: int = 1
var number_of_beats_in_round: int
var tempo: float = 60
var round_duration: float
var elapsed_round_time: float = 0
@export var note_cards: Array[Panel]
@onready var note_card_1: Panel = $CanvasLayer/NoteCard1
signal beat_signal
signal round_changed

func _ready() -> void:
	one_beat_duration = tempo / 60
	print(one_beat_duration)
	number_of_beats_in_round = time_signature * number_of_bars
	round_duration = number_of_beats_in_round * one_beat_duration
	emit_signal("round_changed")
	emit_signal("beat_signal",beat_num)

func _process(delta: float) -> void:
	elapsed_round_time += delta
	#print(elapsed_round_time)
	beat_counter(delta)

func beat_counter(delta: float) -> void:
	one_beat_duration_counter += delta
	if one_beat_duration_counter >= one_beat_duration:
		beat_num += 1
		one_beat_duration_counter -= one_beat_duration
		if beat_num > number_of_beats_in_round:
			beat_num = 1
			elapsed_round_time = 0
			emit_signal("round_changed")
		emit_signal("beat_signal",beat_num)
		print("beat_signal")
	
func _on_beat_signal(beat_num: int) -> void:
	pass

func clear_cards_visuals() -> void:
	for card in note_cards:
		card.modulate = Color.WHITE

func higlight_card(num: int) -> void:
	note_cards[num].modulate = Color.BLACK

func choose_max_active_card() -> void:
	pass

func enable_card(card_num: int) -> void:
	if card_num in note_cards:
		note_cards[card_num].active = true
	else:
		push_error("no card with num " + str(card_num))
