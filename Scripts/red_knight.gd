extends CharacterBody2D

class_name Red_Knight
@onready var hit_flash_animation_player: AnimationPlayer = $HitFlashAnimationPlayer
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_dissolve_animation_player: AnimationPlayer = $AnimationPlayer
@export var damage_to_deal = 1
@export var health: int = 5
@export var speed: float = 20.00
@export var knockback_resistence: float = 1.00 # 1 is 0% knockback resistence and 0 is 100% knockback resistence so 0.5 would be 50% resistence
var health_min: int = 0

var dir: Vector2
var player: CharacterBody2D
const gravity = 300

var dead: bool = false
var is_dealing_damage: bool = false
var taking_damage: bool = false
var player_in_area: bool = false
var is_redknight_chase: bool = false
var is_roaming: bool = true

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	player = Global.playerBody
	
	move(delta)
	handle_animation()
	move_and_slide()
	
func take_damage(attack: Attack):
	if health > 0:
		taking_damage = true
		health -= attack.attack_dmg
		hit_flash_animation_player.play("Hurt")
		SoundLibrary.play_random_hit()
		if health <= health_min:
			health = health_min
			dead = true
		if !dead:
			var knockback_dir = global_position.direction_to(player.position) * (attack.knockback * knockback_resistence) * -1
			velocity.x = knockback_dir.x # We NEED to work on this so its not bad knockback anymore.

func move(delta: float):
	if !dead:
		if !is_redknight_chase:
			velocity += dir * speed * delta
		elif is_redknight_chase and !taking_damage:
			var dir_to_player = global_position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	if !dead and !is_dealing_damage and !taking_damage:
		anim_sprite.play("Walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and !is_dealing_damage and taking_damage:
		await get_tree().create_timer(0.4).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		remove_child($hitBox)
		death_dissolve_animation_player.play("Death Disolve")
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
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

func choose(array):
	array.shuffle()
	return array.front()


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body == player:
		is_redknight_chase = true


func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body == player: 
		is_redknight_chase = false

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body == player and player.is_dashing == false and player.invincibility == false:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, 100, 0.12)
		player.damage()
