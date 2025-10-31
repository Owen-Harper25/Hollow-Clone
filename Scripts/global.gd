extends Node

var gameStarted: bool
var playerBody: CharacterBody2D
var playerWeaponEquip: bool
var playerAlive: bool
var pausedGame: bool

signal game_resumed
signal pogo_now

const level_1 = preload("res://Scenes/Levels/level_1.tscn")
const level_2 = preload("res://Scenes/Levels/level_2.tscn")
const level_3 = preload("res://Scenes/Levels/level_3.tscn")

var current_level: Node
var spawn_door_tag: String
var game_manager: Node # Reference to GameManager (holds UI, player, transition layer)

func _ready() -> void:
	print("Global ready")


func load_level(level_tag: String, spawn_tag: String) -> void:
	var scene_to_load: PackedScene = null

	match level_tag:
		"level_1":
			scene_to_load = level_1
		"level_2":
			scene_to_load = level_2
		"level_3":
			scene_to_load = level_3
		_:
			push_error("Unknown level tag: " + level_tag)
			return

	if scene_to_load == null:
		push_error("Scene for " + level_tag + " not found")
		return

	# Start fade-out before changing
	var transition_layer: CanvasLayer = null
	if game_manager:
		transition_layer = game_manager.get_node_or_null("SceneTransition")

	if transition_layer:
		var anim_player: AnimationPlayer = transition_layer.get_node("AnimationPlayer")
		anim_player.play("Fade")
		await anim_player.animation_finished

	# Remove previous level
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		await get_tree().process_frame

	# Add new level deferred to avoid physics issues
	call_deferred("_add_new_level", scene_to_load, level_tag, spawn_tag, transition_layer)


func _add_new_level(scene_to_load: PackedScene, level_tag: String, spawn_tag: String, transition_layer: CanvasLayer) -> void:
	current_level = scene_to_load.instantiate()

	# Add under GameManager (keeps UI/player persistent)
	if game_manager:
		game_manager.add_child(current_level)
	else:
		push_warning("No GameManager assigned — level added to root")
		get_tree().root.add_child(current_level)

	await get_tree().process_frame

	# Find the door and its spawn marker
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

	# Fade back in
	if transition_layer:
		var anim_player: AnimationPlayer = transition_layer.get_node("AnimationPlayer")
		anim_player.play_backwards("Fade")
