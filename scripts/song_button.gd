class_name SongButton extends TextureButton

var ready_for_button_up: bool = false
var song: Song
#@export var melody_filename: String = "98bpm"
#var new_level_dictionary: Dictionary

func _on_button_up() -> void:
	if ready_for_button_up:
		#build_level_dictionary()
		#Game.set_level_details(new_level_dictionary)
		#print("switching song")
		Game.set_current_song(song)
		get_tree().change_scene_to_file("res://game.tscn")
	ready_for_button_up = false

func build_level_dictionary() -> void:
	pass
	#new_level_dictionary["melody_filename"] = melody_filename

func _on_button_down() -> void:
	ready_for_button_up = true


func _on_mouse_exited() -> void:
	ready_for_button_up = false
