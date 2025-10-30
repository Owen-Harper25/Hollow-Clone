extends Node2D

@onready var heartsContainer = $CanvasLayer/heartsContainer
@onready var player = $Player
@onready var transition_layer: CanvasLayer = $SceneTransition

func _ready() -> void:
	Global.game_manager = self
	Global.playerBody = player

	heartsContainer.setMaxHearts(player.maxHealth)
	heartsContainer.updateHearts(player.currentHealth)
	player.healthChanged.connect(heartsContainer.updateHearts)

	Global.load_level("level_1", "spawn_1")
