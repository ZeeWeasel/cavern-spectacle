extends RigidBody2D
class_name Bullet
	
# Trail Variables
var trails : Array[Sprite2D] = []
# TODO: Option To Disable
@export var num_trail_sprites = 8
@export var trail_spacing = 3.0  # Adjust the spacing between trail sprites
@export var fade_start = 0.25
var _ignore : int = 0
var to_ignore : int = num_trail_sprites*3

@export var damage : int = 1

@onready var bullet_sprite : Sprite2D = $Sprite2D

var particles = preload("res://scenes/particles_impact.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	motion_blur(delta)
	check_despawn(delta)
	
var _timer_despawn = 0.0	
var velocity_treshold = 200
	
func check_despawn(delta):
	if linear_velocity.y < velocity_treshold and linear_velocity.y > -velocity_treshold:
		if linear_velocity.x < velocity_treshold and linear_velocity.x > -velocity_treshold:
			_timer_despawn += delta
			if(_timer_despawn>0.1):
				queue_free()
	
func hit_enemy() -> int:
	queue_free()
	return damage

func motion_blur(_delta):
	var velocity = linear_velocity
	var direction = velocity.normalized()

	for i in range(num_trail_sprites):
		if _ignore < to_ignore:
			_ignore += 1
			continue
			
		var trail_sprite = Sprite2D.new()
		trail_sprite.texture = bullet_sprite.texture # Assuming bullet_sprite is your bullet's sprite
		trail_sprite.global_position = global_position - direction * i * trail_spacing
		trail_sprite.modulate.a = fade_start
		trail_sprite.set_script(preload("res://scripts/fade_over_time.gd"))
		get_parent().add_child(trail_sprite)
		
func _on_body_entered(body):
	EventBus.shot_impact.emit(position, body)
	if body is Player:
		print("Enemy Bullet hits player for " + str(damage) + "damage")
		EventBus.damage_player.emit(damage)
	spawn_particles()
	
func spawn_particles():
	var impact = particles.instantiate()
	
	get_parent().add_child(impact)
	
	impact.global_position = global_position
	impact.global_rotation = global_rotation
	impact.one_shot = true
	impact.emitting = true
	
	queue_free()
