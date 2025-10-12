extends StaticBody2D

@onready var Interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D



func _ready() -> void:
	Interactable.interact = _on_interact
			
func _on_interact():
	print("Interacted")
	Global.currentHealth = Global.maxHealth
