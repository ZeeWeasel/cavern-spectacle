extends Camera2D

# Camera shake parameters
var shake_intensity := 0.0
var shake_intensity_max = 4
var shake_decay
var shake_decay_time = 0.25

var original_offset : Vector2

@onready var player : CharacterBody2D = $".."

var smooth_speed_max = 5
var smooth_speed_min = 2
var player_speed_max = 500
var player_speed_min = 200
var transition_speed = 0.5

var current_position_smoothing_speed: float
var target_position_smoothing_speed: float

# Called when the node enters the scene tree for the first time.
func _ready():
	shake_decay = 4/0.25
	original_offset = offset
	EventBus.connect("block_destroyed", _on_block_destroyed)
	EventBus.connect("enemy_hit", _on_enemy_hit)
	EventBus.connect("shot_fired", _on_shot_fired)
	EventBus.connect("border_hit", _on_border_hit)
	pass # Replace with function body.

func calculate_position_smoothing(delta):

	var normalized_speed = (player.velocity.length() - player_speed_min) / (player_speed_max - player_speed_min)
	normalized_speed = clamp(normalized_speed, 0, 1)  # Ensure it stays between 0 and 1
	
	position_smoothing_speed = smooth_speed_min + normalized_speed * (smooth_speed_max - smooth_speed_min)
	
	target_position_smoothing_speed = smooth_speed_min + normalized_speed * (smooth_speed_max - smooth_speed_min)

	var lerp_factor = delta * 0.5  
	current_position_smoothing_speed = lerp(current_position_smoothing_speed, target_position_smoothing_speed, lerp_factor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	calculate_position_smoothing(delta)
	
	if shake_intensity > 0:
		# Randomly move the camera
		offset += Vector2(randf() * 2 - 1, randf() * 2 - 1) * shake_intensity
		# Reduce the shake intensity over time
		shake_intensity -= shake_decay * delta
		offset = offset.lerp(original_offset, .25)
	else:
		# Ensure camera returns to its original position
		offset = original_offset
 

func _on_shot_fired():
	if(shake_intensity<shake_intensity_max):
		shake_intensity += .2
		
func _on_border_hit():
	if(shake_intensity<shake_intensity_max):
		shake_intensity += 1.5
		
func _on_block_destroyed():
	if(shake_intensity<shake_intensity_max):
		shake_intensity += 2
		
func _on_enemy_hit():
	if(shake_intensity<shake_intensity_max):
		shake_intensity += 1
