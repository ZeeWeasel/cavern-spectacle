extends RigidBody2D

@export var distance_collect : float = 20.0
var amount_coins = 5

func _ready():
	angular_velocity = randf_range(-100,100)
	EventBus.connect("restart_level", _on_restart_level)
	
func _on_restart_level():
	queue_free()
	
func _physics_process(_delta):
	if Globals.player:
		var distance = global_position.distance_to(Globals.player.position)
		if distance_collect>distance:
			EventBus.coin_collected.emit()
			Globals.coins += amount_coins
			Audio.play_sound(Sounds.snd_pickup, .2)
			queue_free()
