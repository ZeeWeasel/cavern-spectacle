extends CanvasLayer
class_name Juice_Coin

@onready var animation_player : AnimationPlayer = $TextureRect/AnimationPlayer

func _ready():
	animation_player.play("collect")
