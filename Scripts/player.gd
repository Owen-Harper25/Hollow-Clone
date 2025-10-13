class_name PlatformerController
extends CharacterBody2D
## An extendable character for platforming games including features like coyote time,
## jump buffering, jump cancelling, sprinting, and wall jumping.  
##
## Each mechanic and section
## of logic is broken up into different functions, allowing you to easilly extend this class
## and override the functions you want to change while keeping the remaining logic in place.[br][br]
## 
## All default values were found through tests and tweaking to find a solid default state, but they can all
## be adjusted to fit your specific needs

## The four possible character states and the character's current state

signal healthChanged

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

enum {IDLE, SPRINT, WALK, JUMP, FALL, WALL_SLIDE}

## The values for the jump direction, default is UP or -1
enum JUMP_DIRECTIONS {UP = -1, DOWN = 1}

#Movement Variables
var canSpawnParticle = true
var DUST_PARTICLE = preload("res://Scenes/PlayerScenes/DustParticle.tscn")
var DASH_PARTICLE = preload("res://Scenes/PlayerScenes/DashParticle.tscn")
var paused: bool = false

@onready var feet: Marker2D = $Feet
@export var allow_diagonal: bool = true  # Set false to restrict diagonal movement


#Attack Variables
var invincibility: bool = false
var can_attack: bool = true
var facing_direction: Vector2 = Vector2.RIGHT  # default facing right
@export var attack_cooldown: float = 1.0  # Attack cooldown time
@onready var attack_timer: Timer = $"Timers/Attack Timer"  # Timer to control attack duration
@onready var hit_flash_animation_player: AnimationPlayer = $HitFlashAnimationPlayer
@onready var AttackParent: Node2D = $Attack
@onready var AttackSprite: Sprite2D = $Attack/Sprite2D
@onready var AttackArea2D: Area2D = $Attack/Sprite2D/AttackArea2D
var attack_distance: float = 10.0
var TotalAttackDuration: float = 0.26
var attack_duration_timer: float = 0.0
var look_dir: Vector2 = Vector2.RIGHT
@export var attack_dmg: int = 1  # damage
@export var breakable_dmg: int = 1 # damage delt to objects that are breakable
var pogo_power = -300

#Health Variables
@export var maxHealth = 5
var currentHealth: int = maxHealth
@onready var invincibility_timer: Timer = $Timers/InvincibilityTimer
var health_min = 0
var alive: bool = true


#Dashing Variables
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_immunity: bool = false  # If the player is immune to damage during the dash
var dash_direction: Vector2 = Vector2.ZERO  # Direction of the dash
@export var dash_speed: float = 400.0  # Dash speed
@export var dash_duration: float = 0.2  # How long the dash lasts
@export var dash_cooldown: float = 1.0  # Cooldown between dashes
@onready var dash_cooldown_timer: Timer = $"Timers/Dash Timer"
@onready var resume_timer: Timer = $"Timers/Resume Timer"


## The path to the character's [Sprite2D] node.  If no node path is provided the [param PLAYER_SPRITE] will be set to [param $Sprite2D] if it exists.
@export_node_path("Sprite2D") var PLAYER_SPRITE_PATH: NodePath
@onready var PLAYER_SPRITE: Sprite2D = get_node(PLAYER_SPRITE_PATH) if PLAYER_SPRITE_PATH else $Sprite2D ## The [Sprite2D] of the player character

## The path to the character's [AnimationPlayer] node. If no node path is provided the [param ANIMATION_PLAYER] will be set to [param $AnimationPlayer] if it exists.
@export_node_path("AnimationPlayer") var ANIMATION_PLAYER_PATH: NodePath
@onready var ANIMATION_PLAYER: AnimationPlayer = get_node(ANIMATION_PLAYER_PATH) if ANIMATION_PLAYER_PATH else $AnimationPlayer ## The [AnimationPlayer] of the player character

## Enables/Disables hard movement when using a joystick.  When enabled, slightly moving the joystick
## will only move the character at a percentage of the maximum acceleration and speed instead of the maximum.
@export var JOYSTICK_MOVEMENT := false

## Enable/Disable sprinting
@export var ENABLE_SPRINT := true
## Enable/Disable Wall Jumping
@export var ENABLE_WALL_JUMPING := true

@export_group("Input Map Actions")
# Input Map actions related to each movement direction, jumping, and sprinting.  Set each to their related
# action's name in your Input Mapping or create actions with the default names.
@export var ACTION_UP := "up" ## The input mapping for up
@export var ACTION_DOWN := "down" ## The input mapping for down
@export var ACTION_LEFT := "left" ## The input mapping for left
@export var ACTION_RIGHT := "right" ## The input mapping for right
@export var ACTION_JUMP := "jump" ## The input mapping for jump
@export var ACTION_SPRINT := "sprint" ## The input mapping for sprint


@export_group("Movement Values")
# The following float values are in px/sec when used in movement calculations with 'delta'
## How fast the character gets to the [param MAX_SPEED] value
@export_range(0, 1000, 0.1) var ACCELERATION: float = 500.0
## The overall cap on the character's speed
@export_range(0, 1000, 0.1) var MAX_SPEED: float = 100.0
## Sprint multiplier, multiplies the [param MAX_SPEED] by this value when sprinting
@export_range(0, 10, 0.1) var SPRINT_MULTIPLIER: float = 1.5
## How fast the character's speed goes back to zero when not moving on the ground
@export_range(0, 1000, 0.1) var FRICTION: float = 500.0
## How fast the character's speed goes back to zero when not moving in the air
@export_range(0, 1000, 0.1) var AIR_RESISTENCE: float = 200.0
## The speed of gravity applied to the character
@export_range(0, 1000, 0.1) var GRAVITY: float = 500.0
## The speed of the jump when leaving the ground
@export_range(0, 1000, 0.1) var JUMP_FORCE: float = 200.0
## How fast the character's vertical speed goes back to zero when cancelling a jump
@export_range(0, 1000, 0.1) var JUMP_CANCEL_FORCE: float = 800.0
## The speed the character falls while sliding on a wall. Currently this is only active if wall jumping is active as well.
@export_range(0, 1000, 0.1) var WALL_SLIDE_SPEED: float = 50.0
## How long in seconds after walking off a platform the character can still jump, set this to zero to disable it
@export_range(0, 1, 0.01) var COYOTE_TIMER: float = 0.08
## How long in seconds before landing should the game still accept the jump command, set this to zero to disable it
@export_range(0, 1, 0.01) var JUMP_BUFFER_TIMER: float = 0.1


## The players current state
var state: int = IDLE
## The player is sprinting when [param sprinting] is true
var sprinting := false
## The player can jump when [param can_jump] is true
var can_jump := false
var pause_jump := false
## The player should jump when landing if [param should_jump] is true, this is used for the [param jump_buffering]
var should_jump := false
## The player will execute a wall jump if [param can_wall_jump] is true and the last call of move_and_slide was only colliding with a wall.
var wall_jump := false
## The player is jumping when [param jumping] is true
var jumping := false

## The player can sprint when [param can_sprint] is true
@onready var can_sprint: bool = ENABLE_SPRINT
## The player can wall jump when [param can_wall_jump] is true
@onready var can_wall_jump: bool = ENABLE_WALL_JUMPING

func _ready() -> void:
	Global.playerBody = self
	Global.game_resumed.connect(_on_game_resumed)
	AttackSprite.modulate.a = 0.0
	AttackArea2D.get_node("CollisionShape2D").disabled = true

func _on_game_resumed():
	$"Timers/Resume Timer".start()
	pause_jump = true
	

func _physics_process(delta: float) -> void:
	physics_tick(delta)

func _process(_delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO

	if Input.is_action_pressed(ACTION_RIGHT):
		input_dir.x += 1
	if Input.is_action_pressed(ACTION_LEFT):
		input_dir.x -= 1
	if Input.is_action_pressed(ACTION_DOWN):
		input_dir.y += 1
	if Input.is_action_pressed(ACTION_UP):
		input_dir.y -= 1

# only update if we actually pressed a direction
	if input_dir != Vector2.ZERO:
		facing_direction = get_cardinal_direction(input_dir)
	
	#Dashing Code
	if Input.is_action_just_pressed("dash") and !is_dashing and can_dash and pause_jump == false:
		var dash_input := get_input_direction()
		if dash_input == Vector2.ZERO:
			dash_input = Vector2.RIGHT if PLAYER_SPRITE.flip_h == false else Vector2.LEFT
		start_dash(dash_input)
		SoundLibrary.play_random_dash()
		can_dash = false
		dash_cooldown_timer.start()

		
func start_dash(direction: Vector2) -> void:
	direction.y = 0
	$AnimationPlayer.play("dash")
	var particle = DASH_PARTICLE.instantiate()
	particle.emitting = true
	particle.global_position = $Feet.global_position
	get_parent().add_child(particle)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT if PLAYER_SPRITE.flip_h == false else Vector2.LEFT
		
	dash_direction = direction.normalized()
	
	is_dashing = true
	dash_immunity = true
	dash_timer = dash_duration
	velocity.x = dash_direction.x * dash_speed
	set_collision_mask_value(2, false)
	
func get_cardinal_direction(dir: Vector2) -> Vector2:
	var deadzone := 0.2
	var compliance := 1.1 if is_on_floor() else 1.0
	if dir.length() < deadzone:
		return facing_direction
	
	if abs(dir.x) * compliance > abs(dir.y):
		return Vector2(sign(dir.x), 0)  # prefer left/right
	else:
		return Vector2(0, sign(dir.y))  # only switch if clearly vertical

## Overrideable physics process used by the controller that calls whatever functions should be called
## and any logic that needs to be done on the [param _physics_process] tick
func physics_tick(delta: float) -> void:
	if is_dashing:
		# Dash overrides normal movement
		set_collision_layer_value(2, false)
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			dash_immunity = false
			set_collision_layer_value(2, true)
			velocity.x = dash_direction.x * MAX_SPEED
			damage_check()
		
		move_and_slide()
		return  # skip normal physics while dashing
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
		else:
			move_and_slide()
	var inputs: Dictionary = get_inputs()
	handle_jump(delta, inputs.input_direction, inputs.jump_strength, inputs.jump_pressed, inputs.jump_released)
	handle_sprint(inputs.sprint_strength)
	handle_velocity(delta, inputs.input_direction)

	manage_animations()
	manage_state()
	_attack_logic(delta)
	# We have to handle the gravity after the state
	handle_gravity(delta) 

	move_and_slide()

func damage_check():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = $hurtBox/CollisionShape2D.shape
	query.transform = $hurtBox/CollisionShape2D.global_transform
	query.collide_with_areas = true
	query.collision_mask = 2  # enemy hitboxes layer
	var results = space_state.intersect_shape(query)
	for result in results:
		var area = result.collider
		if area.is_in_group("Enemy"):
			#_on_hurt_box_area_entered(area)
			damage()

func _attack_logic(delta: float) -> void:
	if can_attack:
		if Input.is_action_just_pressed("attack"):
			SoundLibrary.play_random_dash()
			can_attack = false
			attack_timer.start()
			
			if facing_direction == Vector2.RIGHT:
				AttackParent.rotation_degrees = 0
			elif facing_direction == Vector2.LEFT:
				AttackParent.rotation_degrees = 180
			elif facing_direction == Vector2.UP:
				AttackParent.rotation_degrees = -90
			elif facing_direction == Vector2.DOWN:
				if not is_on_floor():  # only allow down slash in air
					AttackParent.rotation_degrees = 90
			else:
				# force into horizontal slash instead
				if PLAYER_SPRITE.flip_h:
					AttackParent.rotation_degrees = 180   # face left
				else:
					AttackParent.rotation_degrees = 0   # face right2

			AttackArea2D.get_node("CollisionShape2D").disabled = false
			attack_duration_timer = TotalAttackDuration
			AttackSprite.position.x = 0.0
			
			#var attack_pos_tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			#attack_pos_tween.tween_property(AttackParent, "position", facing_direction * attack_distance, TotalAttackDuration)
			var attack_modulate_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			attack_modulate_tween.tween_property(AttackSprite, "modulate:a", 1.0, TotalAttackDuration*0.1)
			attack_modulate_tween.chain().tween_property(AttackSprite, "modulate:a", 0.0, TotalAttackDuration*0.9)
		
		else:
			attack_duration_timer = max(0.0, attack_duration_timer - delta)
			if attack_duration_timer == 0.0:
				AttackArea2D.get_node("CollisionShape2D").disabled = true

## Manages the character's current state based on the current velocity vector
func manage_state() -> void:
	if velocity.y == 0:
		run_particles()
		if velocity.x == 0:
			state = IDLE
		elif velocity.x == 150 or velocity.x == -150:
			state = SPRINT
		else:
			state = WALK
	elif velocity.y < 0:
		state = JUMP
	else:
		if can_wall_jump and is_on_wall_only() and get_input_direction().x != 0:
			state = WALL_SLIDE
		else:
			state = FALL

## Manages the character's animations based on the current state and [param PLAYER_SPRITE] direction based on
## the current horizontal velocity. The expected default animations are [param Idle], [param Walk], [param Jump], and [param Fall]
func manage_animations() -> void:
	if velocity.x > 0:
		PLAYER_SPRITE.flip_h = false
	elif velocity.x < 0:
		PLAYER_SPRITE.flip_h = true
	match state:
		IDLE:
			ANIMATION_PLAYER.play("Idle")
		WALK:
			ANIMATION_PLAYER.play("Walk")
		JUMP:
			ANIMATION_PLAYER.play("Jump")
		FALL:
			ANIMATION_PLAYER.play("Fall")
		WALL_SLIDE:
			ANIMATION_PLAYER.play("Fall")
		SPRINT:
			ANIMATION_PLAYER.play("Sprint")

## Gets the strength and status of the mapped actions
func get_inputs() -> Dictionary:
	return {
		input_direction = get_input_direction(),
		jump_strength = Input.get_action_strength(ACTION_JUMP),
		jump_pressed = Input.is_action_just_pressed(ACTION_JUMP),
		jump_released = Input.is_action_just_released(ACTION_JUMP),
		sprint_strength = Input.get_action_strength(ACTION_SPRINT) if ENABLE_SPRINT else 0.0,
	}

## Gets the X/Y axis movement direction using the input mappings assigned to the ACTION UP/DOWN/LEFT/RIGHT variables
func get_input_direction() -> Vector2:
	var x_dir: float = Input.get_action_strength(ACTION_RIGHT) - Input.get_action_strength(ACTION_LEFT)
	var y_dir: float = Input.get_action_strength(ACTION_DOWN) - Input.get_action_strength(ACTION_UP)

	return Vector2(x_dir if JOYSTICK_MOVEMENT else sign(x_dir), y_dir if JOYSTICK_MOVEMENT else sign(y_dir))

# ------------------ Movement Logic ---------------------------------
## Takes the delta and applies gravity to the player depending on their state.  This has
## to be handled after the state and animations in the default behaviour to make sure the 
## animations are handled correctly.
func handle_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	if can_wall_jump and state == WALL_SLIDE and not jumping:
		velocity.y = clampf(velocity.y, 0.0, WALL_SLIDE_SPEED)
	
	if not is_on_floor() and can_jump:
		coyote_time()

## Takes delta and the current input direction and either applies the movement or applies friction
func handle_velocity(delta: float, input_direction: Vector2 = Vector2.ZERO) -> void:
	if input_direction.x != 0:
		apply_velocity(delta, input_direction)
	else:
		apply_friction(delta)

## Applies velocity in the current input direction using the [param ACCELERATION], [param MAX_SPEED], and [param SPRINT_MULTIPLIER]
func apply_velocity(delta: float, move_direction: Vector2) -> void:
	var sprint_strength: float = SPRINT_MULTIPLIER if sprinting else 1.0
	velocity.x += move_direction.x * ACCELERATION * delta * (sprint_strength if is_on_floor() else 1.0)
	velocity.x = clamp(velocity.x, -MAX_SPEED * abs(move_direction.x) * sprint_strength, MAX_SPEED * abs(move_direction.x) * sprint_strength)

## Applies friction to the horizontal axis when not moving using the [param FRICTION] and [param AIR_RESISTENCE] values
func apply_friction(delta: float) -> void:
	var fric: float = FRICTION * delta * sign(velocity.x) * -1 if is_on_floor() else AIR_RESISTENCE * delta * sign(velocity.x) * -1
	if abs(velocity.x) <= abs(fric):
		velocity.x = 0
	else:
		velocity.x += fric

## Sets the sprinting variable according to the strength of the sprint input action
func handle_sprint(sprint_strength: float) -> void:
	if sprint_strength != 0 and can_sprint:
		sprinting = true
	else:
		sprinting = false

# ------------------ Jumping Logic ---------------------------------
## Takes delta and the jump action status and strength and handles the jumping logic
func handle_jump(delta: float, move_direction: Vector2, jump_strength: float = 0.0, jump_pressed: bool = false, _jump_released: bool = false) -> void:
	if (jump_pressed or should_jump) and can_jump and pause_jump == false:
		apply_jump(move_direction)
	elif jump_pressed:
		buffer_jump()
	elif jump_strength == 0 and velocity.y < 0:
		cancel_jump(delta)
	elif can_wall_jump and not is_on_floor() and is_on_wall_only():
		can_jump = true
		wall_jump = true
		jumping = false

	if is_on_floor() and velocity.y >= 0:
		can_jump = true
		wall_jump = false
		jumping = false

func run_particles():
	if is_on_floor() and state == 1 and canSpawnParticle:
		canSpawnParticle = false
		$Timers/ParticleTimer.start()
		var particle = DUST_PARTICLE.instantiate()
		particle.emitting = true
		particle.global_position = $Feet.global_position
		get_parent().add_child(particle)

## Applies a jump force to the character in the specified direction, defaults to [param JUMP_FORCE] and [param JUMP_DIRECTIONS.UP]
## but can be passed a new force and direction
func apply_jump(move_direction: Vector2, jump_force: float = JUMP_FORCE, jump_direction: int = JUMP_DIRECTIONS.UP) -> void:
	can_jump = false
	should_jump = false
	jumping = true

	if (wall_jump):
		# Jump away from the direction the character is currently facing
		velocity.x += jump_force * -move_direction.x
		wall_jump = false
		velocity.y = 0

	velocity.y += jump_force * jump_direction

## If jump is released before reaching the top of the jump, the jump is cancelled using the [param JUMP_CANCEL_FORCE] and delta
func cancel_jump(delta: float) -> void:
	jumping = false
	velocity.y -= JUMP_CANCEL_FORCE * sign(velocity.y) * delta

## If jump is pressed before hitting the ground, it's buffered using the [param JUMP_BUFFER_TIMER] value and the jump is applied
## if the character lands before the timer ends
func buffer_jump() -> void:
	should_jump = true
	await get_tree().create_timer(JUMP_BUFFER_TIMER).timeout
	should_jump = false

## If the character steps off of a platform, they are given an amount of time in the air to still jump using the [param COYOTE_TIMER] value
func coyote_time() -> void:
	await get_tree().create_timer(COYOTE_TIMER).timeout
	can_jump = false

#connections

func _on_particle_timer_timeout() -> void:
	canSpawnParticle = true

func _on_attack_timer_timeout() -> void:
	can_attack = true
	damage_check()

func _on_dash_timer_timeout() -> void:
	can_dash = true

func _on_hurt_box_area_entered(_area):
	#if area.name == "hitBox" and dash_immunity == false and invincibility == false:
		#damage()
	pass

func _on_invincibility_timer_timeout() -> void:
	invincibility = false
	set_collision_mask_value(2, true)
	set_collision_layer_value(2, true)
	damage_check()

func damage():
	currentHealth -= 1
	SoundLibrary.play_random_hit()
	hit_flash_animation_player.play("hit_flash")
	healthChanged.emit(currentHealth)
	if currentHealth > 0:
		invincibility_timer.start()
		invincibility = true
		set_collision_mask_value(2, false)
		set_collision_layer_value(2, false)
		
	if currentHealth <= 0:
		SoundLibrary.play_random_death()
		currentHealth = maxHealth
		print("Dead")
	

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
	
func _on_resume_timer_timeout() -> void:
	pause_jump = false

func _on_attack_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return
	
	if body.is_in_group("Enemy") and body.has_method("take_damage") and body.is_in_group("can_pogo") and facing_direction == Vector2.DOWN:
		var knockback_direction = (body.global_position - global_position).normalized()
		attack_duration_timer = 0.1
		var attack = Attack.new()
		attack.attack_dmg = attack_dmg
		body.take_damage(attack)
		velocity.y = pogo_power
		body.apply_knockback(knockback_direction, 50, 0.08)
		
	elif body.is_in_group("Enemy") and body.has_method("take_damage"):
		var knockback_direction = (body.global_position - global_position).normalized()
		var attack = Attack.new()
		attack.attack_dmg = attack_dmg
		body.take_damage(attack)
		body.apply_knockback(knockback_direction, 50, 0.08)

func _on_attack_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Breakable") and area.has_method("break_dmg"):
		var attack = Attack.new()
		attack.attack_dmg = attack_dmg
		area.break_dmg(attack)
