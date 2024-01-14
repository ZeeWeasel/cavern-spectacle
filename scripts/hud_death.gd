extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("restart_level", _on_restart_level)
	pass # Replace with function body.
	
func _on_button_restart_level_pressed():
	EventBus.restart_level.emit()
	pass # Replace with function body.
	
func _on_restart_level():
	queue_free()
