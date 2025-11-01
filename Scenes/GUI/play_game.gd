extends Button

func _ready() -> void:
	if Global.controllerPlayer:
		grab_focus()
