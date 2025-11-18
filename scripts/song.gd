# song.gd
class_name Song
extends Resource

var song_id: String
var melody_filename: String
var tempo: float
var bgm_filename: String
var image_filename: String

func _init(data: Dictionary = {}) -> void:
	var allowed = ["song_id", "melody_filename", "tempo", "bgm_filename", "image_filename"]

	for key in data.keys():
		if key not in allowed:
			push_warning("Unknown Song property: %s" % key)

	song_id = data.get("song_id", "")
	melody_filename = data.get("melody_filename", "")
	tempo = data.get("tempo", 120.0)
	bgm_filename = data.get("bgm_filename", "")
	image_filename = data.get("image_filename", "")
	print("initializing song with the following details:")
	print_details()

func print_details() -> void:
	print(song_id)
	print(melody_filename)
	print(tempo)
	print(bgm_filename)
	print(image_filename)
