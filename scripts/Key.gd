extends Sprite2D

@export var key_sprite : Sprite2D

var collected : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("level_start", _on_level_start)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_level_start():
	collected = false
	key_sprite.visible = true

func _on_static_body_2d_body_entered(_body):
	if collected: return
	key_sprite.visible = false
	collected = true
	EventBus.key_found.emit()
	Audio.play_sound(Sounds.snd_powerUp_3, .5)
	pass # Replace with function body.
