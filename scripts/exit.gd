extends Node2D
class_name Exit

var locked : bool
@export var lock : Sprite2D

func _ready():
	EventBus.connect("key_found", _on_key_found)
	EventBus.connect("level_start", _on_level_start)

var _entered : bool = false # To avoid playing sounds / effects double when player jumps on exit

func _on_door_area_2d_body_entered(body):
	
	if body is CharacterBody2D:
		print("Player entered exit")
		if !locked && !_entered:
			Audio.play_sound(Sounds.snd_level_exit, 0.5)
			_entered = true
			Globals.exiting = false
		else:
			Audio.play_sound(Sounds.snd_level_exit_false, 0.25)
		EventBus.player_entered_exit.emit(locked)

func _on_key_found():
	locked = false
	lock.visible = false
	
func _on_level_start():
	locked = true
	lock.visible = true
