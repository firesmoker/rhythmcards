# AUTOLOAD THIS
extends Node

#const Song = preload("res://scripts/song.gd")

func get_song_by_id(id: String) -> Song:
	for s in songs:
		if s.song_id == id:
			print("returning song: " + str(s))
			return s
	print("returning NULL song")
	return null

func get_all_songs() -> Array[Song]:
	return songs.duplicate()

var songs: Array[Song] = [
	Song.new({
		"song_id": "generic_65bpm",
		"melody_filename": "res://levels/65bpm.txt",
		"tempo": 65.0,
		"bgm_filename": "res://music/65bpm.wav",
		"image_filename": "",
	}),

	Song.new({
		"song_id": "generic_98bpm",
		"melody_filename": "res://levels/98bpm.txt",
		"tempo": 98.0,
		"bgm_filename": "res://music/98bpm.wav",
		"image_filename": ""
	}),
	
		Song.new({
		"song_id": "generic_98bpm_86SLOW",
		"melody_filename": "res://levels/98bpm_86.txt",
		"tempo": 86.0,
		"bgm_filename": "res://music/98bpm_86.wav",
		"image_filename": ""
	}),
	
	Song.new({
		"song_id": "generic_95bpm",
		"melody_filename": "res://levels/95bpm.txt",
		"tempo": 95.0,
		"bgm_filename": "res://music/95bpm.wav",
		"image_filename": ""
	}),
	
	Song.new({
		"song_id": "generic_97bpm",
		"melody_filename": "res://levels/97bpm.txt",
		"tempo": 97.0,
		"bgm_filename": "res://music/97bpm.wav",
		"image_filename": ""
	}),
]
