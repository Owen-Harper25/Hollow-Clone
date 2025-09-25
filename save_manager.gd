extends Node

const SAVE_DIR = "user://save/"
const SAVE_FILE_NAME = "save.json"
const SECURITY_KEY = "HL8374rQt32PmBRTT5" # Its important we change the location of this to prevent easy access.

var player_data = PlayerData.new()

func _ready() -> void:
	verify_save_directory(SAVE_DIR)

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)


func save_data(path : String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	var data = {
		"player_data":{
			"health": player_data.health,
			"global_position":{
				"x": player_data.global_position.x,
				"y": player_data.global_position.y
			},
			"coins": player_data.coins
		}
	}
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

func load_data(path : String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
		if file == null:
			print(FileAccess.get_open_error())
			return
			
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannont parse %s as a json_string: (%s)" % [path, content])
			return
			
		
		player_data = PlayerData.new()
		player_data.health = data.player_data.health
		player_data.global_position = Vector2(data.player_data.global_position.x, data.player_data.global_position.y)
		player_data.coins = data.player_data.coins
		
		
	else:
		print("Cannont open non-existent file at %s!" % [path])

func _save():
	save_data(SAVE_DIR + SAVE_FILE_NAME)

func _load():
	load_data(SAVE_DIR + SAVE_FILE_NAME)
