extends Control

@onready var MainPauseMenu = $MainPauseMenu
@onready var Settings = $Settings
@onready var BlurAnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	escapeTest()

func resume():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hide()
	BlurAnimationPlayer.play_backwards("Blur")
	Global.emit_signal("game_resumed")
	if MainPauseMenu.visible == false and Global.controllerPlayer:
		MainPauseMenu.visible = true
		$MainPauseMenu/PauseMenu_Box/Button_List/Resume.grab_focus()

func pause():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	BlurAnimationPlayer.play("Blur")
	if Global.controllerPlayer:
		$MainPauseMenu/PauseMenu_Box/Button_List/Resume.grab_focus()

func escapeTest():
	if Input.is_action_just_pressed("escape") and !get_tree().paused and !Global.talking:
		pause()
	elif Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		if Settings.visible:
			Settings.visible = false
			MainPauseMenu.visible = true
			if Global.controllerPlayer:
				$MainPauseMenu/PauseMenu_Box/Button_List/Resume.grab_focus()
		else:
			resume()

func _on_resume_button_down() -> void:
	resume()

func _on_settings_button_down() -> void:
	if MainPauseMenu.visible:
		MainPauseMenu.visible = false
	Settings.visible = true
	if Global.controllerPlayer:
		$Settings/SettingsMargin/Settings_holder/Settings_panel/Settings_Screen/Settings_buttons/Gameplay.grab_focus()

func _on_quit_button_down() -> void:
	get_tree().quit()
