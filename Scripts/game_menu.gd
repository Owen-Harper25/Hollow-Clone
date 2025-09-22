extends Control

func _process(_delta: float) -> void:
	escapeTest()

func resume():
	get_tree().paused = false

func pause():
	get_tree().paused = true

func escapeTest():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()

func _on_resume_button_down() -> void:
	resume()


func _on_settings_button_down() -> void:
	pass # Replace with function body.


func _on_quit_button_down() -> void:
	get_tree().quit()
