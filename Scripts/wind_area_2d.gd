extends Area2D
class_name WindArea2D

@export var speed: Vector2 = Vector2.UP

var wind_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_object_entered)
	body_exited.connect(_object_exited)

func _object_entered(object:Node2D):
	if "wind_velocity" in object:
		if speed.y < 0.0:
			object.velocity.y = speed.y
		object.wind_velocity += speed

func _object_exited(object:Node2D):
	if "wind_velocity" in object:
		object.wind_velocity -= speed
