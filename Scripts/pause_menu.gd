extends Control

func _ready() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta: float) -> void:
	escapeTest()

func resume():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	$AnimationPlayer.play_backwards("blur")
	Global.emit_signal("game_resumed")
	print("resumed")

func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	$AnimationPlayer.play("blur")
	$PanelContainer/MarginContainer/VBoxContainer/Resume.grab_focus()

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
