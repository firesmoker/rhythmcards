extends Control

@onready var song_grid: GridContainer = $SongScroller/SongGrid
@onready var check_button: CheckButton = $CheckButton
@onready var vib_time: TextEdit = $VibTime
@onready var vib_amp: TextEdit = $VibAmp
@onready var change_vib_button: Button = $ChangeVib
@onready var metronome_check: CheckButton = $MetronomeCheck

var song_button_template: PackedScene = preload("res://scenes/song_button.tscn")

func _ready() -> void:
	vib_time.text = str(Game.vibration_time)
	vib_amp.text = str(Game.vibration_strength)
	check_button.button_pressed = Game.hints_on
	metronome_check.button_pressed = Game.metronome_enabled
	create_song_buttons_from_song_library()
	align_library()
	
func align_library() -> void:
	song_grid.columns = song_grid.get_children().size() / 2

func create_song_buttons_from_song_library() -> void:
	var songs_list: Array = SongLibrary.get_all_songs()
	for song in songs_list:
		var new_song_button: SongButton = song_button_template.instantiate()
		new_song_button.song = song
		song_grid.add_child(new_song_button)
		#song_grid.add_child()
		#new_song_button: SongButton = song_button_template.


func _on_check_button_toggled(toggled_on: bool) -> void:
	Game.hints_on = toggled_on


func _on_change_vib_button_up() -> void:
	OS.request_permissions()
	Game.vibration_time = float(vib_time.text)
	Game.vibration_strength = float(vib_amp.text)
	print(Game.vibration_time)
	print(Game.vibration_strength)


func _on_metronome_check_toggled(toggled_on: bool) -> void:
	Game.metronome_enabled = toggled_on
