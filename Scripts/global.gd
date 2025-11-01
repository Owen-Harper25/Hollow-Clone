extends Node

var gameStarted: bool
var playerBody: CharacterBody2D
var playerWeaponEquip: bool
var playerAlive: bool
var pausedGame: bool

var controller_connected: bool = false
	#set(value):
		#if value != controller_connected:  # Check if the value actually changed
			#controller_connected = value
			#if value:
				#Focus_button.grab_focus()
			#else:
				#get_viewport().gui_release_focus()


#NPC Dialogue Variables
var test_status: String = ""
var buffer_inputs: bool = false
var talking: bool = false

signal talking_done
signal game_resumed
signal pogo_now

const level_1 = preload("res://Scenes/Levels/level_1.tscn")
const level_2 = preload("res://Scenes/Levels/level_2.tscn")
const level_3 = preload("res://Scenes/Levels/level_3.tscn")

var current_level: Node
var spawn_door_tag: String
var game_manager: Node

func _ready() -> void:
	print(game_resumed)
	print(pogo_now)
	print(talking_done)


func load_level(level_tag: String, spawn_tag: String) -> void:
	var scene_to_load: PackedScene = null

	match level_tag:
		"level_1": scene_to_load = level_1
		"level_2": scene_to_load = level_2
		"level_3": scene_to_load = level_3
		_: 
			push_error("Unknown level tag: " + level_tag)
			return

	if scene_to_load == null:
		push_error("Scene for " + level_tag + " not found")
		return

	var transition_layer: CanvasLayer = game_manager.get_node_or_null("SceneTransition") if game_manager else null
	var anim_player: AnimationPlayer = null
	if transition_layer:
		anim_player = transition_layer.get_node_or_null("AnimationPlayer")

	#Freeze player
	if playerBody:
		playerBody.set_process(false)
		#playerBody.set_physics_process(false)
		#playerBody.velocity = Vector2.ZERO

	#Fade OUT
	if anim_player:
		anim_player.play("Fade")
		await anim_player.animation_finished

	#Remove old level while screen is black
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		await get_tree().process_frame

	current_level = scene_to_load.instantiate()

	if game_manager:
		game_manager.add_child(current_level)
	else:
		push_warning("No GameManager assigned — level added to root")
		get_tree().root.add_child(current_level)

	await get_tree().process_frame

	#Find door and marker
	var spawn_door: Node = current_level.get_node_or_null(spawn_tag)
	if not spawn_door:
		spawn_door = current_level.find_child(spawn_tag, true, false)

	if not spawn_door:
		push_warning("Spawn door '%s' not found in %s" % [spawn_tag, level_tag])
		return

	var spawn_marker: Node2D = spawn_door.get_node_or_null("Spawn")

	if spawn_marker and playerBody:
		playerBody.global_position = spawn_marker.global_position
	elif playerBody:
		playerBody.global_position = spawn_door.global_position

	if game_manager:
		var camera = game_manager.get_node_or_null("Camera2D")
		if camera:
			camera.player = playerBody
			camera.snap_to_player()

	# Fade IN
	if anim_player:
		anim_player.play_backwards("Fade")
		await anim_player.animation_finished

	#Unfreeze player after fade
	if playerBody:
		playerBody.set_process(true)
		playerBody.set_physics_process(true)
