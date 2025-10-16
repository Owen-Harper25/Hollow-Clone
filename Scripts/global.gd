extends Node

var gameStarted: bool

var playerBody: CharacterBody2D

var playerWeaponEquip: bool

var playerAlive: bool

var pausedGame: bool

signal game_resumed

signal pogo_now

func _ready() -> void:
	print(game_resumed)
	print(pogo_now)
