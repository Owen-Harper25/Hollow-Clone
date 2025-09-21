extends CharacterBody2D

class_name Red_Knight
@onready var hit_flash_animation_player: AnimationPlayer = $HitFlashAnimationPlayer

const speed = 20
var is_redknight_chase : bool = false

@export var health = 5
@export var max_health = 5
var health_min = 0

var dead: bool = false
var taking_damage: bool = false
@export var damage_to_deal = 1
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 300
var knockback_force = -20
var is_roaming: bool = false

var player: CharacterBody2D
var player_in_area = false

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	player = Global.playerBody
	
	if health <= 0:
		dead = true
	
	move(delta)
	handle_animation()
	move_and_slide()
	
func take_damage(damage: int):
	taking_damage = true
	health -= damage
	hit_flash_animation_player.play("Hurt")
	SoundLibrary.play_random_hit()
	if health <= health_min:
		health = health_min
		dead = true

func move(delta):
	if !dead:
		if !is_redknight_chase:
			velocity += dir * speed * delta
		elif is_redknight_chase and !taking_damage:
			var dir_to_player = global_position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = global_position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !is_dealing_damage and !taking_damage:
		anim_sprite.play("Walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and !is_dealing_damage and taking_damage:
		await get_tree().create_timer(0.6).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		remove_child($hitBox)
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		anim_sprite.play("Death")
		SoundLibrary.play_random_death()
		await get_tree().create_timer(2).timeout
		handleDeath()
		
func handleDeath():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_redknight_chase: 
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	pass # Replace with function body.

func choose(array):
	array.shuffle()
	return array.front()
