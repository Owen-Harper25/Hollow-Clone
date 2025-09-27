extends HBoxContainer

@onready var HeartGUIClass = preload("res://Scenes/GUI/heart_gui.tscn")

func setMaxHearts(max2: int):
	for i in range(max2):
		var heart = HeartGUIClass.instantiate()
		add_child(heart)
		
func updateHearts(currentHealth: int):
	var hearts = get_children()
	
	for i in range(currentHealth):
		hearts[i].update(true)
		
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)
