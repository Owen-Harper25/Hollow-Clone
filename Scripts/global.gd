extends Node

var gameStarted: bool

var playerBody: CharacterBody2D

var playerWeaponEquip: bool

var playerAlive: bool

var pausedGame: bool

@export var maxHealth = 5
@onready var currentHealth: int = maxHealth

signal game_resumed

func _ready() -> void:
	print(game_resumed)
