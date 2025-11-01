extends Control

@onready var Focus_button = $Buttons/VBoxContainer/PlayGame

func _ready() -> void:
	if Global.controller_connected:
		Focus_button.grab_focus()

var controller_connected: bool = false:
	set(value):
		if value != controller_connected:  # Check if the value actually changed
			controller_connected = value
			if value:
				Focus_button.grab_focus()
				print("Variable changed to ", value)
			else:
				get_viewport().gui_release_focus()

func _process(_delta: float) -> void:
	Global.controller_connected = controller_connected
	if Input.get_connected_joypads().count(0):
		controller_connected = true
	else:
		controller_connected = false

func _on_quit_game_button_down() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_play_game_button_down() -> void:
	SoundLibrary.play_random_death()
	SceneTransition.load_scene("res://Scenes/game_manager.tscn")
	#get_tree().change_scene_to_file("res://Scenes/game_manager.tscn")
	pass # Replace with function body.
