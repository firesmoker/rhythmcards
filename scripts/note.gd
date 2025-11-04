class_name Note extends TextureRect

@export var quarter_image: Texture2D
@export var first_eigth_image: Texture2D
@export var second_eigth_image: Texture2D
@export var single_eigth_image: Texture2D
@export var quarter_rest_image: Texture2D
@export var eigth_rest_image: Texture2D

@export_enum("note","rest") var type: String = "note"
@export_enum("quarter","eigth-single","eigth-first","eigth-second",) var duration: String = "quarter"

func _ready() -> void:
	set_note()

func set_note(note_duration: String = duration, note_type: String = type) -> void:
	type = note_type
	duration = note_duration
	set_visual()

func set_visual(note_type: String = type, note_duration: String = duration) -> void:
	if note_type == "note":
		match duration:
			"quarter":
				texture = quarter_image
			"eigth-single":
				texture = single_eigth_image
			"eigth-first":
				texture = first_eigth_image
			"eigth-second":
				texture = second_eigth_image
	else:
		match duration:
			"eigth-single":
				texture = eigth_rest_image
			"eigth-first":
				texture = eigth_rest_image
			"eigth-second":
				texture = eigth_rest_image
			_:
				texture = quarter_rest_image

func pulse(time: float = 0.2) -> void:
	scale = scale*1.15
	await get_tree().create_timer(time).timeout
	scale = scale*1/1.15
