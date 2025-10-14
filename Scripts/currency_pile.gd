extends Area2D

var taking_break_dmg: bool = false
var broken: bool = false
@export var object_health: int = 0
var minimum_object_health: int = 0
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var coin_scene = preload("res://Scenes/Enviromentals/coin.tscn")
@export var coins_per_hit: int = 3
@export var coin_spread_angle: float = PI / 3
@export var coin_min_speed: float = 20.0
@export var coin_max_speed: float = 70.0

func break_dmg(attack: Attack):
	if object_health > minimum_object_health and sprite_2d.frame < 3:
		taking_break_dmg = true
		object_health -= attack.attack_dmg
		print(object_health)
		sprite_2d.frame += 1
		
		for i in range(coins_per_hit):
			var instance = coin_scene.instantiate()
			instance.position = global_position
			var angle = randf_range(-coin_spread_angle/2, coin_spread_angle/2)
			var direction = Vector2(cos(angle), sin(angle))
			var speed = randf_range(coin_min_speed, coin_max_speed)
			
			if instance is RigidBody2D:
				instance.linear_velocity = direction * speed
			get_tree().current_scene.call_deferred("add_child", instance)
			
	elif object_health <= minimum_object_health:
		broken = true
