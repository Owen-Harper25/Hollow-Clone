extends Control

@export var PauseMenu : PanelContainer
@export var Settings : PanelContainer

func _ready() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _process(_delta: float) -> void:
	escapeTest()

func resume():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	hide()
	$AnimationPlayer.play_backwards("blur")
	Global.emit_signal("game_resumed")

func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	$AnimationPlayer.play("blur")
	$PanelContainer/MarginContainer/VBoxContainer/Resume.grab_focus()

func toggle_visibility(object):
	if object.visible:
		object.visible = false
	else:
		object.visible = true

func escapeTest():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()

func _on_resume_button_down() -> void:
	resume()
	SoundLibrary.play_random_death()

func _on_settings_button_down() -> void:
	SoundLibrary.play_random_death()


func _on_quit_button_down() -> void:
	SoundLibrary.play_random_death()
	get_tree().quit()
