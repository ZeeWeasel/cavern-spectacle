extends Node2D

@onready var level : Level = $Level
@onready var player : Player = $Player

@export var map_list_images : Array[Image]

var map_list : Array[String] = [
	"res://maps/map_0.png",
	"res://maps/map_1.png",
	"res://maps/map_2.png",
	"res://maps/map_3.png",
	"res://maps/map_4.png",
	"res://maps/map_5.png"
	]

@export var transition_scene : PackedScene
@export var game_won_scene : PackedScene

@export var player_max_health: int = 5
@export var player_start_health : int = 5

@export var hud_death : PackedScene
@export var hud : CanvasLayer

@export var fade_in_fade_out : FadeInFadeOut

# Called when the node enters the scene tree for the first time.
func _ready():
	fade_enter = true
	fade_in_fade_out.fade_from_black(0.5)
	
	if !Globals.hit_points_player:
		Globals.hit_points_player = player_start_health
	
	EventBus.connect("player_entered_exit", _on_player_entered_exit)
	EventBus.connect("restart_level", _on_restart_level)
	EventBus.connect("damage_player", _on_damage_player)
	EventBus.connect("fade_complete", _on_fade_complete)
	EventBus.connect("place_gun", _on_place_gun)
	EventBus.connect("gun_collected", _on_gun_collected)
	
	# First Startup
	if Globals.new_game:
		Globals.coins = 0
		Globals.coins_level_start = 0
		Globals.gun_collected = false
		Globals.exiting = false
		start_game()
		Globals.new_game = false
	else: # Next Map
		Globals.exiting = false
		Globals.hit_points_player = player_start_health
		Globals.coins_level_start = Globals.coins
		print("Loading map #" + str(map_list.find(Globals.current_map)+1))
		Globals.current_map = map_list[map_list.find(Globals.current_map)+1]
		setup_level(Globals.current_map)
	
	pass # Replace with function body.
	
	
func start_game():
	Globals.current_map = map_list[0]
	setup_level(Globals.current_map)
	
func player_dies():
	EventBus.player_death.emit()
	var death_overlay = hud_death.instantiate()
	hud.add_child(death_overlay)
	pass
	
func _on_restart_level():
	Globals.exiting = false
	Globals.coins = Globals.coins_level_start
	fade_in_fade_out.fade_from_black(.5)
	Globals.hit_points_player = player_start_health
	print("Restarting map #" + str(map_list.find(Globals.current_map)))
	
	setup_level(Globals.current_map)
	
func setup_level(map : String):
	print("Gun collected: " + str(Globals.gun_collected))
	
	var outward_fill : Vector2i = Vector2i(20,20) # (fixed)
	
	var mem_start : float = float(OS.get_static_memory_usage())/1024.0
	
	var level_spawn_position : Vector2i = Vector2i(0,0) #upper left corner of border
	
	level.generate_level(outward_fill, level_spawn_position, map)
	
	var mem_end : float  = float(OS.get_static_memory_usage())/1024
	
	var mem_used_level = mem_end - mem_start
	
	print("Memory Usage (Level): " + str(mem_used_level))
	
	player.global_position = level.get_global_position_tile(level.get_player_start())
	
	EventBus.level_start.emit()

var fade_exit : bool = false
var fade_enter : bool = false

func _on_player_entered_exit(locked):
	if locked: 
		print("Exit locked.")	
	else:
		print("Exit not locked.")
		fade_in_fade_out.fade_to_black(0.5)
		fade_exit = true
		
		
func _on_damage_player(damage_amount : int):
	Globals.hit_points_player -= damage_amount
	if Globals.hit_points_player==0:
		player_dies()
		
func _on_fade_complete():
	if fade_exit:
		fade_exit = false
		if map_list.find(Globals.current_map)+1 == map_list.size():
			game_won()
		else:
			get_tree().change_scene_to_packed(transition_scene)
	
	if fade_enter:
		fade_enter = false
		print("Fade In Finished")
		
func game_won():
	get_tree().change_scene_to_packed(game_won_scene)
					
@export var gun_item : PackedScene

func _on_place_gun(pos : Vector2):
	Globals.gun_collected = false
	print("Placing Gun At " + str(pos))
	EventBus.remove_gun.emit()
	# Spawn Gun Item
	var gun = gun_item.instantiate()
	add_child(gun)
	gun.global_position = pos
	
func _on_gun_collected():
	Globals.gun_collected = true
	
