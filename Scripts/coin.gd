extends RigidBody2D

var player: CharacterBody2D
@onready var in_range: bool = false
@export var speed: float = 20.00
var dir: Vector2

func _process(_delta: float) -> void:
	player = Global.playerBody
	if in_range == true:
		move()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("In range")
		in_range = true

		
func move():
	var dir_to_player = global_position.direction_to(player.position) * speed
	linear_velocity = dir_to_player
	dir = abs(linear_velocity) / linear_velocity


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Out of range")
		in_range = false


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Picked Up")
		queue_free()
