extends Node2D

@export var attack_dmg: int = 1  # damage
@export var knockback: float = 40.00
@export var breakable_dmg: int = 1 # damage delt to objects that are breakable
@onready var timer: Timer = $Timer  # Reference to the timer

func _ready():
	timer.start()  # Start lifespan timer

func _on_timer_timeout() -> void:
	queue_free()

func _on_attack_arc_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		var attack = Attack.new()
		attack.attack_dmg = attack_dmg
		attack.knockback = knockback
		body.take_damage(attack)


func _on_attack_arc_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Breakable") and area.has_method("break_dmg"):
		var attack = Attack.new()
		attack.attack_dmg = attack_dmg
		area.break_dmg(attack)
