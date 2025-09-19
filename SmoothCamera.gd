extends Camera2D

#var actual_cam_pos : Vector2

func _process(delta: float) -> void:
	position = position.lerp($"../Player".position, delta * 5)

	#var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
#
	#get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	#
	#global_position = actual_cam_pos.round()
