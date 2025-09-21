extends CharacterBody2D

class_name Red_Knight

const speed = 10
var is_redknight_chase: bool
	

@export var health = 5
@export var max_health = 5
var health_min = 0

var dead: bool = false
var taking_damage: bool = false
@export var damage_to_deal = 1
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 300
var knockback_force = 200
var is_roaming: bool = false

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	if !dead:
		if !is_redknight_chase:
			velocity += dir * speed * delta
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	pass

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_redknight_chase: 
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	pass # Replace with function body.

func choose(array):
	array.shuffle()
	return array.front()
