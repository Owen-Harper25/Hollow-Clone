extends Node2D

var hit_sounds = []
var death_sounds = []
var dash_sounds = []
var item_short = []
var item_long = []
var potion = []

@onready var dash_1: AudioStreamPlayer2D = $Dash1

func _ready() -> void:
	hit_sounds = [$Hit1, $Hit2, $Hit3, $Hit4]
	death_sounds = [$Death1, $Death2, $Death3]
	dash_sounds = [$Dash1, $Dash2, $Dash3]
	item_short = [$"Secret Found Short"]
	item_long = [$"Secret Found Long"]
	potion = [$Potion1]

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
	item_short[0].play()

func play_potion():
	potion[0].play()
