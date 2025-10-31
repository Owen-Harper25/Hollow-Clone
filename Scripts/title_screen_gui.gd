extends Control

var my_bool: bool = true:
	set(value):
		if value != my_bool:  # Check if the value actually changed
			my_bool = value
			# Code to run when the bool changes
			print("Boolean has changed to:", value)
			if value:
				$Buttons/VBoxContainer/PlayGame.grab_focus()
			else:
				get_viewport().gui_release_focus()

func _process(_delta: float) -> void:
	my_bool = Global.controllerPlayer
	if Input.get_connected_joypads().count(0):
		Global.controllerPlayer = true
	else:
		Global.controllerPlayer = false

func _on_quit_game_button_down() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_play_game_button_down() -> void:
	SoundLibrary.play_random_death()
	SceneTransition.load_scene("res://Scenes/game_manager.tscn")
	#get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")
	pass # Replace with function body.
