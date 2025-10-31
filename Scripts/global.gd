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
var game_manager: Node # Reference to the scene container (UI + player)

func _ready() -> void:
	print("Global ready")
	print(game_resumed)
	print(pogo_now)
	
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

	# Remove previous level
	if current_level and is_instance_valid(current_level):
		print("Freeing " + current_level.name)
		current_level.queue_free()
		current_level = null
		await get_tree().process_frame

# Instance and add new level deferred — prevents physics query errors
	call_deferred("_add_new_level", scene_to_load, level_tag, spawn_tag)

	# Ensure it's fully in the tree before searching
	await get_tree().process_frame

	# Try to find the spawn door
	var spawn_door: Node = current_level.get_node_or_null(spawn_tag)
	if not spawn_door:
		# If not a direct child, search recursively
		spawn_door = current_level.find_child(spawn_tag, true, false)

	if spawn_door and playerBody:
		playerBody.global_position = spawn_door.global_position
	else:
		push_warning("Spawn door '%s' not found in %s" % [spawn_tag, level_tag])
		
func _add_new_level(scene_to_load: PackedScene, level_tag: String, spawn_tag: String) -> void:
	current_level = scene_to_load.instantiate()
	
	if game_manager:
		game_manager.add_child(current_level)
	else:
		push_warning("No GameManager assigned — level added to root")
		get_tree().root.add_child(current_level)
	
	await get_tree().process_frame
	
	# Find and move player to spawn
	var spawn_door: Node = current_level.get_node_or_null(spawn_tag)
	if not spawn_door:
		spawn_door = current_level.find_child(spawn_tag, true, false)
	
	if spawn_door and playerBody:
		playerBody.global_position = spawn_door.global_position
	else:
		push_warning("Spawn door '%s' not found in %s" % [spawn_tag, level_tag])
