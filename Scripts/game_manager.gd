extends Node2D

@onready var heartsContainer = $CanvasLayer/heartsContainer
@onready var player = $Player

func _ready() -> void:
	heartsContainer.setMaxHearts(Global.maxHealth)
	heartsContainer.updateHearts(Global.currentHealth)
	player.healthChanged.connect(heartsContainer.updateHearts)
	$CanvasLayer.visible = true
