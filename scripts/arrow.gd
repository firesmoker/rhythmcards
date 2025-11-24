extends TextureRect

var original_scale: Vector2
var game: Game
var arrow_location1: Vector2 = Vector2(290,236)
var arrow_location2: Vector2 = Vector2(290,452)
var scrolling_to_location1: bool = false
var scrolling_to_location2: bool = false
var time_scrolling: float = 0

func _ready() -> void:
	original_scale = scale
	game = find_parent("Game")
	if game != null:
		game.beat_signal.connect(pulse)
		game.beat_signal.connect(position_according_to_beat)

func _process(delta: float) -> void:
	return_to_normal_scale(delta)
	if scrolling_to_location1:
		scroll_to_location1(delta,game.note_card_scroll_speed * 0.75, 365.0)
	elif scrolling_to_location2:
		scroll_to_location2(delta,game.note_card_scroll_speed * 0.75, 365.0)
	else:
		time_scrolling = 0
	
func pulse(beat_num: int) -> void:
	scale = original_scale * 1.8

func position_according_to_beat(beat_num: int) -> void:
	if beat_num == 1:
		position = arrow_location1
		scrolling_to_location1 = false
	elif beat_num == 4:
		scrolling_to_location2 = true
	elif beat_num == 5:
		scrolling_to_location2 = false
		position = arrow_location2
	elif beat_num == 8:
		scrolling_to_location1 = true

func scroll_to_location1(delta: float, time_to_scroll: float, distance: float) -> void:
	time_scrolling += delta
	var weight: float = clamp(time_scrolling / time_to_scroll,0,1)
	var target_position: Vector2 = arrow_location1
	position = lerp(arrow_location2,target_position,weight)
	print("scrolling to location 1")

func scroll_to_location2(delta: float, time_to_scroll: float, distance: float) -> void:
	time_scrolling += delta
	var weight: float = clamp(time_scrolling / time_to_scroll,0,1)
	var target_position: Vector2 = arrow_location2
	position = lerp(arrow_location1,target_position,weight)
	print("scrolling to location 1")

func return_to_normal_scale(delta: float) -> void:
	scale *= 1 - delta * 2
	if scale < original_scale:
		scale = original_scale
