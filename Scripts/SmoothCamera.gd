extends Camera2D

func _process(delta: float) -> void:
	position = position.lerp($"../Player".position, delta * 5)
