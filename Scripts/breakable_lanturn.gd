extends Area2D

var taking_break_dmg: bool = false
var broken: bool = false
@export var object_health: int = 0
var minimum_object_health: int = 0


func break_dmg(breakable_dmg: int):
	if object_health > minimum_object_health:
		taking_break_dmg = true
		object_health -= breakable_dmg
	elif object_health <= minimum_object_health:
		object_health = minimum_object_health
		broken = true
		$AnimatedSprite2D.play("Break")
		SoundLibrary.play_random_break()
		await $AnimatedSprite2D.animation_finished
		queue_free()
