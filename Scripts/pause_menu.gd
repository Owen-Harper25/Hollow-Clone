extends Control

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	escapeTest()

func resume():
	get_tree().paused = false
	hide()
	$AnimationPlayer.play_backwards("blur")
	Global.pausedGame = false
	

func pause():
	get_tree().paused = true
	show()
	$AnimationPlayer.play("blur")
	$PanelContainer/VBoxContainer/Resume.grab_focus()
	Global.pausedGame = true

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
