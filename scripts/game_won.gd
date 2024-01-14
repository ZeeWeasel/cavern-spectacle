extends Node2D

func _ready():
	Globals.new_game = true

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
