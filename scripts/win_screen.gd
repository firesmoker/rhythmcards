extends CanvasLayer


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/content_selection.tscn")
