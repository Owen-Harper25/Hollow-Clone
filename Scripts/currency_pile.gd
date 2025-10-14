extends Area2D

var taking_break_dmg: bool = false
var broken: bool = false
@export var object_health: int = 0
var minimum_object_health: int = 0
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var coin = preload("res://Scenes/Enviromentals/coin.tscn")


func break_dmg(attack: Attack):
	if object_health > minimum_object_health and sprite_2d.frame == 1:
		taking_break_dmg = true
		object_health -= attack.attack_dmg
		print(object_health)
		sprite_2d.frame += 1
		print("Spawn Currency")
		var instance = coin.instantiate()
		instance.position = position
		get_tree().current_scene.call_deferred("add_child", instance)
	elif object_health > minimum_object_health and sprite_2d.frame == 2:
		taking_break_dmg = true
		object_health -= attack.attack_dmg
		print(object_health)
		sprite_2d.frame += 1
		print("Spawn Currency")
		var instance = coin.instantiate()
		instance.position = position
		get_tree().current_scene.call_deferred("add_child", instance)
	elif object_health <= minimum_object_health:
		broken = true
	#elif object_health <= minimum_object_health:
		#object_health = minimum_object_health
		#broken = true
		#$AnimatedSprite2D.play("Break")
		#SoundLibrary.play_random_break()
		#await $AnimatedSprite2D.animation_finished
		#queue_free()
