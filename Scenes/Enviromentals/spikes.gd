extends Area2D
class_name Spike

@export var damage_amount: int = 1
@export var knockback_force: float = 100.0
@export var knockback_duration: float = 0.2

func _on_body_entered(body: Node2D) -> void:
	if body is PlatformerController and body.alive and not body.invincibility:
		var is_pogoing = (body.facing_direction == Vector2.DOWN and not body.is_on_floor() and Input.is_action_pressed("attack"))
		
		if is_pogoing:
			Global.emit_signal("pogo_now")
			return
			
		body.damage()
		
		var knockback_dir = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_dir, knockback_force, knockback_duration)
