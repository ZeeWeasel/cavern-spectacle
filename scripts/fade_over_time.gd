extends Sprite2D

var fade_speed = 3.0

func _ready():
	pass

func _process(delta):
	modulate.a -= fade_speed * delta
	if modulate.a <= 0:
		queue_free()
