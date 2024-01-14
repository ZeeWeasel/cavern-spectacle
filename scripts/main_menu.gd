extends Node2D

@export var game_scene : PackedScene

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button_twitch_pressed():
	OS.shell_open("http://live.weaseldev.com")
