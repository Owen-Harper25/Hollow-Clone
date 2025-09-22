extends Control

func _on_quit_game_button_down() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_play_game_button_down() -> void:
	SceneTransition.load_scene("res://Scenes/game_manager.tscn")
	#get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")
	pass # Replace with function body.
