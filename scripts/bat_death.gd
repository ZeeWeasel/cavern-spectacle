extends Node2D

@onready var cpu_particles_2d : CPUParticles2D = $CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("restart_level", _on_level_restart)
	cpu_particles_2d.emitting = true
	pass # Replace with function body.

func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.

func _on_level_restart():
	queue_free()
