extends CharacterBody2D

@onready var Interactable: Area2D = $Interactable
const START_DIALOGUE = preload("res://Dialogue/Goblin_Girl.dialogue")


func _ready() -> void:
	Interactable.interact = _on_interact
			
func _on_interact() -> void:
	Global.talking = true
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/Goblin_Girl.dialogue"), "start")
	return
