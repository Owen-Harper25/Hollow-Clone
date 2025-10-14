extends RigidBody2D

var player: CharacterBody2D
@onready var in_range: bool = false
@export var speed: float = 100.0           # attraction speed toward player
@export var attraction_range: float = 120.0
@export var spawn_force: float = 150.0     # initial pop force
@export var torque_force: float = 200.0    # spin force
@export var pickup_delay: float = 0.8      # seconds before coin can be picked up

var collected: bool = false
var can_pickup: bool = false

func _ready():
	player = Global.playerBody
	var random_angle = randf_range(-PI / 3, -2 * PI / 3)
	var direction = Vector2(cos(random_angle), sin(random_angle))
	apply_impulse(direction * spawn_force)
	apply_torque_impulse(randf_range(-torque_force, torque_force))
	can_pickup = false
	$Area2D.monitoring = false
	await get_tree().create_timer(pickup_delay).timeout
	can_pickup = true
	$Area2D.monitoring = true
		
		
func _physics_process(_delta: float) -> void:
	if collected or not player:
		return
	var distance = global_position.distance_to(player.global_position)
	in_range = distance <= attraction_range
	
	if in_range and can_pickup:
		var dir_to_player = (player.global_position - global_position).normalized()
		var pull_strength = clamp(1.0 - (distance / attraction_range), 0.2, 1.0)
		linear_velocity = dir_to_player * speed * pull_strength
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and can_pickup and not collected:
		collected = true
		_pickup_effect()
		
		
func _pickup_effect():
	linear_velocity = Vector2.ZERO
	set_deferred("freeze", true)
	set_physics_process(false)
		
	var sparkle := GPUParticles2D.new()
	sparkle.amount = 5
	sparkle.one_shot = true
	sparkle.lifetime = 0.4
	sparkle.emitting = true
	sparkle.modulate = Color(1.0, 0.9, 0.4, 1.0)
	sparkle.texture = preload("res://Assets/Sprites/Owen Art/plus particle.png")
	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(0, 300, 0)
	mat.initial_velocity_min = 80.0
	mat.initial_velocity_max = 120.0
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 1.2
	sparkle.process_material = mat
	add_child(sparkle)
	sparkle.position = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(func ():queue_free())
	
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = preload("res://Assets/SFX/Secret Found Short.mp3")
	add_child(sfx)
	sfx.play()
	
#extends RigidBody2D
#
#var player: CharacterBody2D
#@onready var in_range: bool = false
#@export var speed: float = 20.0
#var dir: Vector2
#
## --- Spawn animation settings ---
#@export var float_height: float = 16.0    # how high the coin jumps
#@export var float_time: float = 0.4       # how long it floats up
#@export var spin_speed: float = 360.0     # rotation speed during float
#
#var start_y: float
#var has_spawned: bool = false
#
#func _ready():
	#start_y = position.y
	#linear_velocity = Vector2.ZERO
#
	## Disable gravity during spawn animation for consistency
	#gravity_scale = 0
#
	## Play float + spin animation
	#_spawn_float_animation()
#
#
#func _spawn_float_animation():
	#has_spawned = true
	#var tween = create_tween()
	#tween.tween_property(self, "position:y", position.y - float_height, float_time / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#tween.tween_property(self, "position:y", start_y, float_time / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	#tween.parallel().tween_property(self, "rotation_degrees", rotation_degrees + spin_speed, float_time)
#
	#tween.tween_callback(func ():
		#gravity_scale = 1
		#has_spawned = false
	#)
#
#func _process(_delta: float) -> void:
	#player = Global.playerBody
	#if in_range:
		#move()
#
#func move():
	#var dir_to_player = global_position.direction_to(player.position) * speed
	#linear_velocity = dir_to_player
	#dir = abs(linear_velocity) / linear_velocity
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		#in_range = true
#
#func _on_area_2d_body_exited(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		#in_range = false
#
#func _on_area_2d_2_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		#var tween = create_tween()
		#tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		#tween.tween_callback(func ():queue_free())
