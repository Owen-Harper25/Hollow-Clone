extends Camera2D

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if player and is_instance_valid(player):
		position = position.lerp(player.global_position, delta * 5)

func snap_to_player() -> void:
	if player and is_instance_valid(player):
		position = player.global_position
