extends Control

@onready var MainPauseMenu = $MainPauseMenu
@onready var Settings = $Settings
@onready var BlurAnimationPlayer = $AnimationPlayer
@onready var Focus_button = $MainPauseMenu/PauseMenu_Box/Button_List/Resume

var controller_connected: bool = false:
	set(value):
		if value != controller_connected:  # Check if the value actually changed
			controller_connected = value
			if value:
				Focus_button.grab_focus()
			else:
				get_viewport().gui_release_focus()

func _ready() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	escapeTest()
	controller_connected = Global.controller_connected
	if Input.get_connected_joypads().count(0):
		controller_connected = true
	else:
		controller_connected = false
	

func resume():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hide()
	BlurAnimationPlayer.play_backwards("Blur")
	Global.emit_signal("game_resumed")

func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	BlurAnimationPlayer.play("Blur")


func escapeTest():
	if Input.is_action_just_pressed("escape") and !get_tree().paused and !Global.talking:
		pause()
	elif Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		if Settings.visible:
			Settings.visible = false
			MainPauseMenu.visible = true
		else:
			resume()

func _on_resume_button_down() -> void:
	resume()

func _on_settings_button_down() -> void:
	if MainPauseMenu.visible:
		MainPauseMenu.visible = false
	Settings.visible = true

func _on_quit_button_down() -> void:
	get_tree().quit()
