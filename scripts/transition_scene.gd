extends Control
class_name TransitionScene

func _on_next_level_button_up():
	Audio.play_sound_2d(Sounds.snd_click)
	print("Button Next Level")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
