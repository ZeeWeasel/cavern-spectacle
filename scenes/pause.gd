extends Node2D

var paused : bool = false

func _ready():
	$"Pause Overlay".visible = false
	pass

func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		if paused:
			resume_game()
		else: 
			pause_game()

func pause_game():
	paused = true
	get_tree().paused = true
	$"Pause Overlay".visible = true
	
func resume_game():
	paused = false
	$"Pause Overlay".visible = false
	get_tree().paused = false
	
func _on_button_restart_pressed():
	resume_game()
	EventBus.restart_level.emit()

func _on_button_resume_pressed():
	resume_game()
	
func _on_button_twitch_pressed():
	OS.shell_open("http://live.weaseldev.com")
