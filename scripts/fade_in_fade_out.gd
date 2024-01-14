extends Control
class_name FadeInFadeOut

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func fade_to_black(duration : float):
	animation_player.play("fade_to_black")
	var animation_duration = animation_player.current_animation_length
	animation_player.speed_scale = animation_duration/duration
	pass
	
func fade_from_black(duration : float):
	animation_player.play("fade_from_black")
	var animation_duration = animation_player.current_animation_length
	animation_player.speed_scale = animation_duration/duration
	pass
	
func fade_complete():
	animation_player.speed_scale = 1
	EventBus.fade_complete.emit()
