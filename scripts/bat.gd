extends CharacterBody2D
	 
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var raycast : RayCast2D = $RayCast2D
@export var line2d : Line2D

@export var bat_death : PackedScene

@export var chase_speed_min : float = 70
@export var chase_speed_max : float = 120
var chase_speed

@export var chase_speed_after_hit : float = 160

var time_until_stop_chasing : float = 1.5
var _timer_chasing : float = 0.0

var detection_range : float = 300

var is_chasing : bool = false

var _distance_to_player : float

var hit_points : int
var hit_points_max : int = 5

var attack_damage : int = 1

@export var coin : PackedScene
@export var coins_per_bat : int = 1

@export var push_duration : float = 0.075
var _push_timer : float = 0.00
var hit_push : bool
@export var push_speed : float = 300

@export var damage_touch_time : float = .5

var _player_touched_timer : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("restart_level", _on_restart_level)
	
	hit_points = hit_points_max
	chase_speed = randf_range(chase_speed_min, chase_speed_max)
	
	animation.play("flying")
	
func _on_restart_level():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Globals.hit_points_player<=0 : 
		wander(delta)
		return
	
	if on_player:
		_player_touched_timer += delta
		if _player_touched_timer >= damage_touch_time :
			_player_touched_timer = 0.0
			EventBus.damage_player.emit(attack_damage)
	
	if not Globals.player: return
	
	if is_chasing: 
		move_towards_player(delta)
	else:
		wander(delta)
	
	if check_player_nearby():
		if check_player_visible():
			_timer_chasing = 0.0 
			is_chasing = true
	pass
	
var wander_point : Vector2 = Vector2(0,0)
var _timer_wander : float
var interval_wander : float = 1.5
var interval_wander_min = 0.0
var interval_wander_max = 5.0
var stop_moving = false
	
func wander(delta):
	var speed = randf_range(25.0,75.0)
	#generate wander point
	_timer_wander += delta
	if _timer_wander > interval_wander :
		_timer_wander = 0.0
		interval_wander = randf_range(interval_wander_min, interval_wander_max)
		generate_wanderpoint()
		
	var direction : Vector2 = (wander_point - global_position).normalized()
	
	var _distance_to_point = global_position.distance_to(wander_point)
	
	if(_distance_to_point<=5.0): 
		velocity = Vector2.ZERO
	else:
		velocity = direction * speed
			
	move_and_slide()

func generate_wanderpoint():
	_timer_wander = 0.0
	var direction : Vector2
	var distance: Vector2 = Vector2(randf_range(-100.0,100.0),randf_range(-100.0,100.0))
	direction = distance
	
	wander_point = global_position+direction
	
func move_towards_player(delta):
	
	var player_pos = Globals.player.global_position
	var direction : Vector2
	
	if hit_push: 
		direction = (global_position - player_pos).normalized()
		velocity = direction * push_speed
		_push_timer += delta
		if _push_timer >= push_duration:
			hit_push = false
			_push_timer = 0.0
	else:
		direction =  (player_pos - global_position).normalized()
		var speed
		if hit_points<hit_points_max:
			speed = chase_speed_after_hit
		else:
			speed = chase_speed
		velocity = direction * speed
	
	
	if not check_player_visible():
		_timer_chasing += delta
		if _timer_chasing > time_until_stop_chasing:
			is_chasing = false
			velocity = Vector2.ZERO
			
	move_and_slide()


	# Calculate the distance between this entity and the player
func check_player_nearby() -> bool:

	_distance_to_player = global_position.distance_to(Globals.player.global_position)
	if _distance_to_player > detection_range:
		return false
	return true
	
	# Check if the raycast towards the player is blocked by Tile Map Walls
func check_player_visible() -> bool:
	
	raycast.target_position = raycast.to_local(Globals.player.global_position)
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is CharacterBody2D:
			return true
	return false
	
func receive_damage(damage : int):
	# print("Bat hit for " + str(damage) + " damage")	
	hit_points -= damage
	if hit_points<=0:
		death()
		
func death():
	Audio.play_sound_random(Sounds.list_explosions, .25)
	spawn_coin(coins_per_bat)
	var death_instance = bat_death.instantiate()
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
	
var on_wall : bool = false
var on_player : bool = false
	
func _on_hitbox_body_entered(body):
	if body.name == "Player":
		on_player = true
		
	if body is TileMap and !is_chasing:
		on_wall = true
		
	if body is Bullet:
		var bullet : Bullet = body
		receive_damage(bullet.damage)
		spawn_blood()
		load_textures("_hit")
		hit_timer.start()
		hit_push = true
		EventBus.enemy_hit.emit()
		bullet.hit_enemy()
		Audio.play_sound_random(Sounds.list_hit_bats, .25)
		
@onready var bat_wing_left = $BatWingLeft
@onready var bat_wing_right = $BatWingRight
@onready var bat_head = $BatHead
@onready var hit_timer : Timer = $"Hit Timer"

func load_textures(modifier : String = ""):
	bat_wing_left.texture = load("res://graphics/bat_wing_left" + modifier +".png")
	bat_wing_right.texture = load("res://graphics/bat_wing_right" + modifier +".png")
	bat_head.texture = load("res://graphics/bat_head" + modifier +".png")

func spawn_blood():
	var particles = preload("res://scenes/particles_impact_enemy.tscn")
	var impact = particles.instantiate()
	get_parent().get_parent().add_child(impact)
	impact.global_position = global_position
	impact.global_rotation = global_rotation
	impact.one_shot = true
	impact.emitting = true

func _on_hitbox_body_exited(body):
	if body.name == "Player":
		on_player = false
		_player_touched_timer = 0.0
	if body is TileMap:
		on_wall = false

func _on_hit_timer_timeout():
	load_textures()
	pass # Replace with function body.
