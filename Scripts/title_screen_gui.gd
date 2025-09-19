extends Control

func _on_quit_game_button_down() -> void:
	pass # Replace with function body.


func _on_play_game_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")
	pass # Replace with function body.
