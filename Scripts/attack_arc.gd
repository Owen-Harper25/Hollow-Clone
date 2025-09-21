extends Node2D

@export var damage: int = 1  # damage
@onready var timer: Timer = $Timer  # Reference to the timer

func _ready():
	timer.start()  # Start lifespan timer


func _on_timer_timeout() -> void:
	queue_free()

func _on_attack_arc_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
