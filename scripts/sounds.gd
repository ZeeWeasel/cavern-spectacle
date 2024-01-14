extends Node

var snd_click : AudioStream = load('res://sounds/click.wav')

var snd_hit_bat_1 : AudioStream = load('res://sounds/hit_bat_1.wav')
var snd_hit_bat_2 : AudioStream = load('res://sounds/hit_bat_2.wav')
var snd_hit_bat_3 : AudioStream = load('res://sounds/hit_bat_3.wav')
var snd_hit_bat_4 : AudioStream = load('res://sounds/hit_bat_4.wav')
var snd_hit_bat_5 : AudioStream = load('res://sounds/hit_bat_5.wav')
var snd_hit_bat_6 : AudioStream = load('res://sounds/hit_bat_6.wav')
var snd_hit_bat_7 : AudioStream = load('res://sounds/hit_bat_7.wav')
var list_hit_bats : Array[AudioStream] = [ snd_hit_bat_1,
snd_hit_bat_2 ,snd_hit_bat_3 ,snd_hit_bat_4 ,snd_hit_bat_5 ,snd_hit_bat_6 ,
snd_hit_bat_7]

var snd_explosion_1 : AudioStream = preload('res://sounds/explosion_1.wav')
var snd_explosion_2 : AudioStream = preload('res://sounds/explosion_2.wav')
var snd_explosion_3 : AudioStream = preload('res://sounds/explosion_3.wav')
var list_explosions : Array[AudioStream] = [snd_explosion_1, snd_explosion_2, snd_explosion_3]

var snd_explosion_turret_1 : AudioStream = preload('res://sounds/explosion_turret_1.wav')
var snd_explosion_turret_2 : AudioStream = preload('res://sounds/explosion_turret_2.wav')
var snd_explosion_turret_3 : AudioStream = preload('res://sounds/explosion_turret_3.wav')
var list_explosions_turret : Array[AudioStream] = [snd_explosion_turret_1, 
snd_explosion_turret_2, snd_explosion_turret_3]

var snd_hitHurt_1 : AudioStream = preload('res://sounds/hitHurt_1.wav')
var snd_hitHurt_2 : AudioStream = preload('res://sounds/hitHurt_2.wav')
var snd_hitHurt_3 : AudioStream = preload('res://sounds/hitHurt_3.wav')
var snd_hitHurt_4 : AudioStream = preload('res://sounds/hitHurt_4.wav')
var list_hurt : Array[AudioStream] = [snd_hitHurt_1, snd_hitHurt_2, snd_hitHurt_3,
snd_hitHurt_4]

var snd_jump : AudioStream = preload('res://sounds/jump.wav')
var snd_jump_2 : AudioStream = preload('res://sounds/jump_2.wav')
var snd_jump_3 : AudioStream = preload('res://sounds/jump_3.wav')

var snd_turret_shot : AudioStream = preload('res://sounds/turret_shot.wav')

var list_jump : Array[AudioStream] = [snd_jump, snd_jump_2, snd_jump_3]

var snd_pickup : AudioStream = preload('res://sounds/pickup.wav')

var snd_powerUp_1 : AudioStream = preload('res://sounds/powerUp.wav')
var snd_powerUp_2 : AudioStream = preload('res://sounds/powerUp_2.wav')
var snd_powerUp_3 : AudioStream = preload('res://sounds/powerUp_3.wav')
var list_powerups : Array[AudioStream] = [snd_powerUp_1, snd_powerUp_2, snd_powerUp_3]

var snd_shoot_1 : AudioStream = preload('res://sounds/shoot_1.wav')
var snd_shoot_2 : AudioStream = preload('res://sounds/shoot_2.wav')
var snd_shoot_3 : AudioStream = preload('res://sounds/shoot_3.wav')
var list_shots : Array[AudioStream] = [snd_shoot_1, snd_shoot_2, snd_shoot_3]

var snd_player_death : AudioStream = preload('res://sounds/player_death.wav')

var snd_level_exit : AudioStream = preload('res://sounds/exit_level.wav')
var snd_level_exit_false : AudioStream = preload('res://sounds/level_exit_false.wav')

var snd_ground_break_1 : AudioStream = preload('res://sounds/ground_break_1.wav')
var snd_ground_break_2 : AudioStream = preload('res://sounds/ground_break_2.wav')
var list_ground_break : Array[AudioStream] = [snd_ground_break_1,snd_ground_break_2]
