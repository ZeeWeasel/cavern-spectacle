extends RigidBody2D

@export var idle_rotate_speed : float = 50	

@export var bullet : PackedScene
@export var shot_speed : float = 200
	 
@onready var raycast : RayCast2D = $RayCast2D
@onready var barrel : Node2D = $Barrel
@onready var barrelSprite : Sprite2D = $"Barrel/Sprite Barrel"
@onready var barrelMarker : Marker2D = $"Barrel/Sprite Barrel/Marker2D"

@export var turret_death : PackedScene
@export var bullet_turret  : PackedScene
@export var time_until_stop_chasing : float = 1.5

var _timer_attacking : float = 0.0

@export var detection_range : float = 300

var is_attacking : bool = false
var _distance_to_player : float

var hit_points_current : int
@export var hit_points_max : int = 6

var attack_damage : int = 1

@export var coin : PackedScene
@export var coins_per_turret : int = 2

var _timer_idle_rotate = 0.0
@export var interval_rotate = 1.0

@export var shot_interval : float = 0.75
var _shot_timer : float = 0.0

var ammo_max : int = 4
var ammo_current : int = 5


var is_reloading : bool = false	
var _timer_reload : float = 0.0
var reload_per_shot_duration : float = 0.75

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("restart_level", _on_restart_level)
	hit_points_current = hit_points_max
	ammo_current = ammo_max
	ammo_indicator_max = ammo_indicator.texture.get_width()
	
func _on_restart_level():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Globals.player or Globals.hit_points_player<=0:
		idle(delta) # Idle when player dead
	
	reload(delta)
	update_ammo_indicator()
	
	if !is_reloading and is_attacking: 
		if not Globals.player: return
		attack_player(delta)
	else:
		idle(delta)
	
	if check_player_nearby():
		if check_player_visible():
			_timer_attacking = 0.0 
			is_attacking = true
	pass

func reload(delta):
	if is_reloading:
		_timer_reload += delta
		if _timer_reload >= reload_per_shot_duration:
			ammo_current += 1
			_timer_reload = 0.0
			if ammo_current == ammo_max:
				is_reloading = false
		return
	if ammo_current == 0:
		if !is_reloading:
			is_reloading = true
			

@onready var ammo_indicator : Sprite2D = $"Ammo Indicator"
@onready var ammo_animation = $"Ammo Indicator/AnimationPlayer"

var ammo_indicator_max : int

func update_ammo_indicator():
	ammo_animation.play("ammo_state")
	ammo_animation.pause()
	var size : float = (1.0/ammo_max) * ammo_current
	ammo_animation.seek(size)
	if(ammo_current == ammo_max): ammo_animation.seek(0.99)
	pass	
	
@export var deg_treshold_shoot : float = 5	
	
func attack_player(delta):
	rotate_barrel_toward(Globals.player.global_position, delta)
	
	if not check_player_visible():
		_timer_attacking += delta
		if _timer_attacking > time_until_stop_chasing:
			is_attacking = false
			# Not attacking anymore
			# TODO: Spawn Question Mark above Unit
			if randi_range(0,1) == 1: idle_rotate_clockwise = true
			else: idle_rotate_clockwise = false
	else: # Player visible, lets attack
		# Check if the barrel is aiming within 5 degrees of the target
		var angle_diff = abs(barrel.rotation - atan2(Globals.player.global_position.y - global_position.y, Globals.player.global_position.x - global_position.x))
		var angle_threshold = deg_to_rad(deg_treshold_shoot)  # 5 degrees threshold
		
		if angle_diff <= angle_threshold:
			_shot_timer += delta
			if _shot_timer >= shot_interval:
				_shot_timer = 0.0
				shoot()
	
var idle_rotate_clockwise : bool = true	
	
func idle(delta):
	if idle_rotate_clockwise: 
		idle_rotate_speed *= -1
		
	barrel.rotation = barrel.rotation+(deg_to_rad(idle_rotate_speed)*delta)  # Set the rotation of the turret to the calculated angled
	
	_timer_idle_rotate += delta
	if _timer_idle_rotate > interval_rotate :
		_timer_idle_rotate = 0.0

@export var rotation_deg_sec : float = 180

func rotate_barrel_toward(target: Vector2, delta):
	var angle = atan2(target.y - global_position.y, target.x - global_position.x)
	
	var angle_diff = angle - barrel.rotation
	var rotation_speed = deg_to_rad(rotation_deg_sec)
	
	if angle_diff > PI:
		angle_diff -= 2 * PI
	elif angle_diff < -PI:
		angle_diff += 2 * PI
	
	# Calculate the rotation direction based on the sign of angle_difference
	var rotation_direction = sign(angle_diff)
	
	# Calculate the amount to rotate this frame
	var rotation_this_frame = rotation_direction * rotation_speed * delta
	
	# Check if we are close enough to the target angle (within a small threshold)
	if abs(angle_diff) <= abs(rotation_this_frame):
		# If close, directly set the angle to the target angle
		barrel.rotation = angle
	else:
		# Otherwise, apply the calculated rotation for this frame
		barrel.rotation += rotation_this_frame

func shoot():
	if ammo_current == 0: 
		return
	ammo_current -= 1
	var instance : Bullet = bullet.instantiate()
	get_parent().get_parent().add_child(instance)
	# EventBus.shot_fired.emit()
	Audio.play_sound(Sounds.snd_turret_shot,.25)
	instance.global_position = barrelMarker.global_position
	instance.global_rotation = barrel.global_rotation
	instance.damage = attack_damage
	instance.set_linear_velocity(Vector2(1, 0).rotated(barrel.global_rotation) * shot_speed)
	
	# Calculate the distance between this entity and the player
func check_player_nearby() -> bool:
	if !Globals.player: 
		return false
	_distance_to_player = global_position.distance_to(Globals.player.global_position)
	if _distance_to_player < detection_range:
		return true
	return false
	
	# Check if the raycast towards the player is blocked by Tile Map Walls
func check_player_visible() -> bool:
	
	raycast.target_position = raycast.to_local(Globals.player.global_position)
	# Note: Godot sometimes "caches" scenes, 
	# so sometimes it makes sense to reassign them 
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider:
			if collider.name == "Player":
				return true
			else:
				return false
	return false
	
func death():
	spawn_coin(coins_per_turret)
	Audio.play_sound_random(Sounds.list_explosions_turret, 0.5)
	var death_instance = turret_death.instantiate()
	call_deferred("child", death_instance)
	death_instance.global_position = global_position
	call_deferred("free")
	
func spawn_coin(coins):
	for n in coins:
		var coin_instance = coin.instantiate()
		call_deferred("child", coin_instance)
		coin_instance.global_position = global_position
	
func child(instance):
	get_parent().add_child(instance)
	
func free():
	queue_free()
	
func load_textures_normal():
	$"Barrel/Sprite Barrel".texture = load("res://graphics/turret_barrel.png")
	$"Sprite Tank Top".texture = load("res://graphics/turret_tank_top.png")
	$"Sprite Tank Bottom".texture = load("res://graphics/turret_tank_bottom.png")
	pass

@onready var hit_timer = $"Hit Timer"

func load_textures_hit():
	$"Barrel/Sprite Barrel".texture = load("res://graphics/turret_barrel_hit.png")
	$"Sprite Tank Top".texture = load("res://graphics/turret_tank_top_hit.png")
	$"Sprite Tank Bottom".texture = load("res://graphics/turret_tank_bottom_hit.png")
	hit_timer.start()
	
func receive_damage(damage : int):
	hit_points_current -= damage
	if hit_points_current<=0:
		death()
	
func spawn_screws():
	# TODO : Create Particle Effect that spews screw / cogs
	pass

func _on_hitbox_body_entered(body):
	# Player shoots
	if body is Bullet:
		var projectile : Bullet = body
		receive_damage(projectile.hit_enemy())
		spawn_screws()
		EventBus.enemy_hit.emit()
		load_textures_hit()
		Audio.play_sound_random(Sounds.list_explosions, 0.10)

@export var reload_duration = 5

func _on_reload_timer_timeout():
	ammo_current = ammo_max


func _on_hit_timer_timeout():
	load_textures_normal()
	pass # Replace with function body.
