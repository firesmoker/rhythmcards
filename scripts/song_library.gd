# AUTOLOAD THIS
extends Node

const Song = preload("res://scripts/song.gd")

var songs: Array[Song] = [
	Song.new({
		"song_id": "generic_65bpm",
		"melody_filename": "res://levels/65bpm.txt",
		"tempo": 65.0,
		"bgm_filename": "res://music/65bpm.wav",
		"image_filename": ""
	}),

	Song.new({
		"song_id": "generic_98bpm",
		"melody_filename": "res://levels/98bpm.txt",
		"tempo": 98.0,
		"bgm_filename": "res://music/98bpm.wav",
		"image_filename": ""
	}),
]

func get_song_by_id(id: String) -> Song:
	for s in songs:
		if s.song_id == id:
			print("returning song: " + str(s))
			return s
	print("returning NULL song")
	return null

func get_all_songs() -> Array[Song]:
	return songs.duplicate()
