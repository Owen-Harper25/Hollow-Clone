extends Node2D

@onready var interact_label: Label = $InteractLabel
var current_interactions := []
var can_interact := true
var interact_cooldown := 0.4  # seconds between interactions
var interact_buffer := false  # prevents spam when holding stick
var joystick_threshold := -0.9  # how far up you need to tilt to trigger

func _process(_delta: float) -> void:
	# Handle joystick-based interact (like Hollow Knight)
	var joy_y = Input.get_action_strength("up") - Input.get_action_strength("down")

	if joy_y < joystick_threshold and !interact_buffer and can_interact:
		_interact_action()
		interact_buffer = true
	elif joy_y > -0.2:
		# Reset buffer when stick returns to neutral
		interact_buffer = false

	# Label handling
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable:
			interact_label.text = current_interactions[0].interact_name
			interact_label.show()
	else:
		interact_label.hide()

func _input(event: InputEvent) -> void:
	if Global.buffer_inputs:
		return
	if event.is_action_pressed("Interact") and can_interact:
		_interact_action()

func _sort_by_nearest(area1, area2):
	var area1_dis = global_position.distance_to(area1.global_position)
	var area2_dis = global_position.distance_to(area2.global_position)
	return area1_dis < area2_dis

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)

func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)

# ---- Interaction logic ----
func _interact_action() -> void:
	if not current_interactions or not can_interact:
		return

	can_interact = false
	interact_label.hide()

	await current_interactions[0].interact.call()

	# Cooldown before allowing another interaction
	await get_tree().create_timer(interact_cooldown).timeout
	can_interact = true
