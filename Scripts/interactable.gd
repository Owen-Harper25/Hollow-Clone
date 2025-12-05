extends Area2D

@export var interact_name: String = ""
@export var is_interactable: bool = true
@onready var player = get_tree().get_root().find_child("Player", true, false)

var interact: Callable = func(): pass
var sprite: CanvasItem = null

func _ready() -> void:
	sprite = get_parent().get_node_or_null("Sprite2D")

	if sprite == null:
		sprite = get_parent().get_node_or_null("AnimatedSprite2D")

func set_highlighted(state: bool) -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("outline_enabled", state)
