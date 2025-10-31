extends PanelContainer

@export var GameplayPopup: MarginContainer
@export var VisualsPopup: MarginContainer
@export var AudioPopup: MarginContainer
@export var InfoPopup: MarginContainer

func toggle_visibility(object):
	if object.visible == false:
		object.visible = true
	else:
		object.visible = false
