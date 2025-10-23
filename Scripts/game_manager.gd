extends Node2D

@onready var heartsContainer = $CanvasLayer/heartsContainer
@onready var player = $Player


func _ready() -> void:
	heartsContainer.setMaxHearts(player.maxHealth)
	heartsContainer.updateHearts(player.currentHealth)
	player.healthChanged.connect(heartsContainer.updateHearts)
	$CanvasLayer.visible = true
