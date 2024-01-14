extends Node2D

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		print("Gun collected")
		Audio.play_sound(Sounds.snd_powerUp_1, .4)
		EventBus.gun_collected.emit()
		queue_free()
