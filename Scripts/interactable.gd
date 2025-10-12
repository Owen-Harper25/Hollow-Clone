extends Area2D

@export var interact_name: String = ""
@export var is_interactable: bool = true
@onready var player = get_tree().get_root().find_child("Player", true, false)


var interact: Callable = func():
	pass
