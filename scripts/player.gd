extends CharacterBody2D
class_name Player

@export var gun : Gun

@export var player_sprite : Sprite2D

@onready var collision_shape_crouched : CollisionShape2D = $CollisionShapeCrouched
@onready var collision_shape : CollisionShape2D = $CollisionShapeNormal

var sprite_normal : Texture2D
var sprite_crouched : Texture2D 

var SPEED = 250
var speed_crouch = 150
var speed_normal = 250
const JUMP_VELOCITY = -350.0
const JUMP_VELOCITY_REDUCTION = 50.0

var isFacingRight = true  # Default facing direction

const max_jumps = 3
var _jumped : int = 0
var _crouched : bool = false

var freeze : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func set_sprites(modifier : String = ""):
	sprite_crouched = load("res://graphics/character_crouch_facingRight"+modifier+".png")
	sprite_normal =  load("res://graphics/character_facingRight"+modifier+".png")

func _ready():
	set_sprites()
	EventBus.connect("gun_collected", _on_gun_collected)
	EventBus.connect("remove_gun", _on_remove_gun)
	EventBus.connect("player_entered_exit", _on_player_entered_exit)
	EventBus.connect("level_start", _on_level_start)
	EventBus.connect("damage_player", _on_damage_player)
	Globals.player = self

@onready var hit_timer = $"Hit Timer"

func _on_damage_player(_damage):
	if Globals.exiting == true: return
	set_sprites("_hit")
	Audio.play_sound_random(Sounds.list_hurt, .5)
	hit_timer.start()
	
var _dead : bool = false	
	
func death():
	_dead = true
	gun.visible = false
	player_sprite.visible = false
	collision_shape.disabled = true
	collision_shape_crouched.disabled = true
	Audio.play_sound(Sounds.snd_player_death, 0.5)
		
func _physics_process(delta):
	
	if(Globals.hit_points_player<=0): 
		if !_dead: death()
		return
	else:
		gun.visible = true
		player_sprite.visible = true
		if _crouched:
			collision_shape.disabled = true
			collision_shape_crouched.disabled = false
		else: # Standing / Normal
			collision_shape.disabled = false
			collision_shape_crouched.disabled = true
	
	
	if Input.is_action_pressed("crouch") and !freeze:
		_crouched = true
	else:
		_crouched = false
		
	# Add the gravity.
	if not is_on_floor():
		if _crouched:
			velocity.y += gravity*1.75 * delta
		else:
			velocity.y += gravity * delta
	else:
		# Reduce speed when crouched on the floor
		if _crouched:
			SPEED = speed_crouch
		else:
			SPEED = speed_normal
		_jumped = 0

	# Handle ju mp.
	if Input.is_action_just_pressed("jump") and !freeze:
		if _jumped < max_jumps+Upgrades.extra_jumps():
			velocity.y = JUMP_VELOCITY + (JUMP_VELOCITY_REDUCTION*_jumped)
			_jumped += 1
			Audio.play_sound_random(Sounds.list_jump,.45-(_jumped*0.1))
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var direction = Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if freeze:
		velocity.x = 0

	# Determine facing direction based on mouse position
	isFacingRight = get_global_mouse_position().x > global_position.x

	# Update player sprite based on facing direction and crouch status
	if _crouched:
		player_sprite.texture = sprite_crouched
		if isFacingRight: 
			player_sprite.flip_h = false
		else: 
			player_sprite.flip_h = true
	else:
		player_sprite.texture = sprite_normal
		if isFacingRight: 
			player_sprite.flip_h = false
		else: 
			player_sprite.flip_h = true

	move_and_slide()
	
func _on_remove_gun():
	print("Disable Player Gun")
	gun.visible = false
	pass
	
func _on_gun_collected():
	print("Enable Player Gun")
	gun.visible = true
	pass
	
func _on_level_start():
	_dead = false
	freeze = false
	
func _on_player_entered_exit(locked : bool):
	if !locked: 
		freeze_player()
		Globals.exiting = true
	
func freeze_player():
	print("Freezing Player")
	freeze = true
	
func unfreeze_player():
	print("Defrosting Player")
	freeze = false

func _on_hit_timer_timeout():
	set_sprites()
