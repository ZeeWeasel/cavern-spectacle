extends Node2D
class_name Gun

@export var bullet : PackedScene

@export var shot_spawn : Marker2D
@export var shot_spawn_left : Marker2D

@export var shot_spawn_2 : Marker2D
@export var shot_spawn_left_2 : Marker2D

@export var shot_spawn_3 : Marker2D
@export var shot_spawn_left_3 : Marker2D

var _timer_shot : float = 0.0
@export var time_between_shots : float = 0.2
@export var shot_speed = 600.0
var shot_ready : bool

@export var gun_sprite : Sprite2D
@export var gun_sprite_left : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(delta):	
	
	if !Globals.gun_collected: 
		visible = false
		return
	else :
		visible = true
	
	if Globals.hit_points_player<=0 : return
	
	look_at(get_global_mouse_position())
	
	isFacingLeft = get_global_mouse_position().x < global_position.x
	
	gun_sprite_left.visible = isFacingLeft
	gun_sprite.visible = !isFacingLeft
	
	if shot_ready:
		if Input.is_action_pressed("shoot"):
			_timer_shot = 0.0
			shot_ready = false
			shoot()
			pass
	else:
		_timer_shot += delta
		if _timer_shot >= time_between_shots + Upgrades.shot_speed_bonus_total():
			shot_ready = true
			
var amount_bullets : int = 1			
		
func shoot():
	for n in amount_bullets+Upgrades.extra_shots():
		var instance : RigidBody2D = bullet.instantiate()
		get_parent().get_parent().add_child(instance)
		EventBus.shot_fired.emit()
		
		if n == 0:
			if isFacingLeft: instance.global_position = shot_spawn_left.global_position
			else: instance.global_position = shot_spawn.global_position
		
		if n == 1:
			if isFacingLeft: instance.global_position = shot_spawn_left_2.global_position
			else: instance.global_position = shot_spawn_2.global_position
			
		if n == 2:
			if isFacingLeft: instance.global_position = shot_spawn_left_3.global_position
			else: instance.global_position = shot_spawn_3.global_position
			
		var volume_shots = 0.3
		Audio.play_sound_random(Sounds.list_shots, volume_shots)
				
		instance.global_rotation = global_rotation
		instance.set_linear_velocity(Vector2(1, 0).rotated(rotation) * shot_speed)

var isFacingLeft : bool = false

