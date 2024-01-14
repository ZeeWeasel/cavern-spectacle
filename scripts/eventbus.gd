extends Node

signal shot_impact(position : Vector2, body)
signal block_destroyed()
signal player_entered_exit(locked : bool)
signal key_found()
signal level_start()
signal coin_collected()
signal enemy_hit()
signal shot_fired()
signal border_hit()
signal restart_level()
signal damage_player(damage : int)
signal player_death()
signal fade_complete()

signal place_gun(position : Vector2)
signal gun_collected()
signal remove_gun()
