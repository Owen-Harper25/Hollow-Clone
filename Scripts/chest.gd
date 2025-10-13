extends StaticBody2D

@onready var Interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	Interactable.interact = _on_interact
			
func _on_interact():
	if Interactable.player and sprite_2d.frame == 0:
		Interactable.is_interactable = false
		sprite_2d.frame = 1
		animation_player.play("open_chest")
		SoundLibrary.play_random_pickup()
		print("Chest Opened")
