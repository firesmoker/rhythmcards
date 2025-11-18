extends Control
@onready var song_grid: GridContainer = $SongScroller/SongGrid

var song_button_template: PackedScene = preload("res://scenes/song_button.tscn")

func _ready() -> void:
	create_song_buttons_from_song_library()

func create_song_buttons_from_song_library() -> void:
	var songs_list: Array = SongLibrary.get_all_songs()
	for song in songs_list:
		var new_song_button: SongButton = song_button_template.instantiate()
		new_song_button.song = song
		song_grid.add_child(new_song_button)
		#song_grid.add_child()
		#new_song_button: SongButton = song_button_template.
