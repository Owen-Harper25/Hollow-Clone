extends Node2D

var hit_sounds = []
var death_sounds = []
var dash_sounds = []
var item_short = []
var item_long = []
var potion = []
var object_break = []

@onready var dash_1: AudioStreamPlayer2D = $Dash_Sounds/Dash1

func _ready() -> void:
	hit_sounds = $Hit_Sounds.get_children()
	death_sounds = $Death_Sounds.get_children()
	dash_sounds = $Dash_Sounds.get_children()
	item_short = $"Secret_Sounds/Secret Found Short".get_children()
	item_long = $"Secret_Sounds/Secret Found Long".get_children()
	potion = $Potion_Sounds.get_children()
	object_break = $Break_Sounds.get_children()

func play_random_hit():
	var random_sound = hit_sounds[randi() % hit_sounds.size()]
	random_sound.play()

func play_random_dash():
	var random_sound = dash_sounds[randi() % dash_sounds.size()]
	random_sound.play()

func play_random_death():
	var random_sound = death_sounds[randi() % death_sounds.size()]
	random_sound.play()

func play_random_pickup():
	$"Secret_Sounds/Secret Found Short".play()

func play_potion():
	potion[0].play()

func play_random_break():
	var random_sound = object_break[randi() % object_break.size()]
	random_sound.play()
