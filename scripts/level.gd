extends Node2D
class_name Level

@onready var tile_map : TileMap = $TileMap
@export var map : MapReader
@export var exit : Node2D
@export var key : Node2D

@export var ground_piece : PackedScene

@export var enemy_bats : PackedScene
@export var enemy_turret : PackedScene
@export var diamond : PackedScene

var layer_walls : int = 0
var layer_border : int = 1

enum TS {
	CORNER_OUT_UP_LEFT,
	CORNER_OUT_UP_RIGHT,
	CORNER_OUT_DOWN_RIGHT,
	CORNER_OUT_DOWN_LEFT,
	
	OUT_UP,
	OUT_DOWN,
	OUT_LEFT,
	OUT_RIGHT,
	
	CORNER_IN_UP_LEFT,
	CORNER_IN_UP_RIGHT,
	CORNER_IN_DOWN_RIGHT,
	CORNER_IN_DOWN_LEFT,
	
	IN_UP,
	IN_DOWN,
	IN_LEFT,
	IN_RIGHT,
	
	CENTER
}

enum R {
	UP_LEFT,
	UP,
	UP_RIGHT,
	LEFT,
	RIGHT,
	DOWN_LEFT,
	DOWN,
	DOWN_RIGHT
}

var rel = {
	R.UP_LEFT: Vector2i(-1,-1),
	R.UP: Vector2i(0,-1),
	R.UP_RIGHT: Vector2i(1,-1),
	R.LEFT: Vector2i(-1,0),
	R.RIGHT: Vector2i(1,0),
	R.DOWN_LEFT: Vector2i(-1,1),
	R.DOWN: Vector2i(0,1),
	R.DOWN_RIGHT: Vector2i(1,1)
}

var border_dict = {
	TS.CORNER_IN_UP_LEFT: Vector2i(0,0),
	TS.CORNER_IN_UP_RIGHT: Vector2i(2,0),
	TS.CORNER_IN_DOWN_RIGHT: Vector2i(2,2),
	TS.CORNER_IN_DOWN_LEFT: Vector2i(0,2),
	
	TS.IN_LEFT: Vector2i(0,1),
	TS.IN_RIGHT: Vector2i(2,1),
	TS.IN_UP: Vector2i(1,0),
	TS.IN_DOWN: Vector2i(1,2),
	
	TS.CENTER: Vector2i(1,1)
}

var wall_dict = {
	TS.CORNER_OUT_UP_LEFT: Vector2i(0,0),
	TS.CORNER_OUT_UP_RIGHT: Vector2i(2,0),
	TS.CORNER_OUT_DOWN_RIGHT: Vector2i(0,2),
	TS.CORNER_OUT_DOWN_LEFT: Vector2i(2,2),
	
	TS.OUT_LEFT: Vector2i(0,1),
	TS.OUT_RIGHT: Vector2i(2,1),
	TS.OUT_UP: Vector2i(1,0),
	TS.OUT_DOWN: Vector2i(1,2),
	
	TS.CORNER_IN_UP_LEFT: Vector2i(3,0),
	TS.CORNER_IN_UP_RIGHT: Vector2i(5,0),
	TS.CORNER_IN_DOWN_RIGHT: Vector2i(5,2),
	TS.CORNER_IN_DOWN_LEFT: Vector2i(3,2),
	
	TS.IN_LEFT: Vector2i(3,1),
	TS.IN_RIGHT: Vector2i(5,1),
	TS.IN_UP: Vector2i(4,0),
	TS.IN_DOWN: Vector2i(4,2),
	
	TS.CENTER: Vector2i(1,1)
	}

var ground_pieces_queue = []
@export var max_debris = 200
@export var ground_piece_spawn_count = 5

@export var bats_per_pixel : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.level = self
	EventBus.connect("shot_impact", _shot_impact)
	EventBus.connect("player_entered_exit", _on_entered_exit)
	EventBus.connect("restart_level", _on_restart_level)
	
func _on_restart_level():
	for debris in ground_pieces_queue:
		debris.queue_free()
	ground_pieces_queue.clear()
	
func _on_entered_exit(locked):
	if !locked:
		for debris in ground_pieces_queue:
			debris.queue_free()
			
		ground_pieces_queue.clear()
			
	
func get_global_position_tile(coords : Vector2i) -> Vector2:
	return to_global(tile_map.map_to_local(coords))
	
func get_player_start():
	return map.get_player_start()

func get_player_distance(tile : Vector2i) -> float:
	var _distance_to_player = get_global_position_tile(tile).distance_to(Globals.player.global_position)
	return _distance_to_player

var bat_positions = []
var diamond_positions = []
var turret_positions = []

func spawn_bats():
	for n in bat_positions:
		#print("Spawning Bat")
		var instance = enemy_bats.instantiate()
		get_parent().add_child(instance)
		instance.global_position = get_global_position_tile(n)
	bat_positions.clear()
	
func spawn_turrets():
	for n in turret_positions:
		#print("Spawning Turret")
		var instance = enemy_turret.instantiate()
		get_parent().add_child(instance)
		instance.global_position = get_global_position_tile(n)
	turret_positions.clear()
	
func spawn_diamonds():
	for n in diamond_positions:
		#print("Spawning Diamond")
		var instance = diamond.instantiate()
		get_parent().add_child(instance)
		instance.global_position = get_global_position_tile(n)
	diamond_positions.clear()

var map_size : Vector2i
	
func generate_level(fill, start : Vector2i, map_path : String):
	map.load_map(map_path)
	
	map_size = map.get_map_size()
	var size = map_size
	
	print("Calculating level with " + str(size.x*size.y) + " cells...")
	
	var time_start = Time.get_ticks_msec()
	
	generate_border(fill, size, start)
	
	# Filling map with ground tiles (1)
	for x in range(start.x-1, start.x+size.x+1, 1):
		for y in range(start.y-1, start.y+size.y+1, 1):
			set_wall(Vector2i(x,y), wall_dict[TS.CENTER])
	
	# Adding rooms, enemies, items by removing blocks
	for x in range(size.x):
		for y in range(size.y):
			var coords = Vector2i(x,y)
			if map.get_value(coords) != 1: #Removing Block
				remove_wall(coords)
			if map.get_value(coords) == 5: #Gun
				remove_wall(coords)
				print("Gun Pixel Found at " + str(coords))
				EventBus.place_gun.emit(get_global_position_tile(coords))
			if map.get_value(coords) == 6: #Turret
				remove_wall(coords)
				turret_positions.append(coords)
			if map.get_value(coords) == 9: #Bart
				remove_wall(coords)
				for bat in (bats_per_pixel*Upgrades.bat_multiplier()):
					bat_positions.append(coords)
			if map.get_value(coords) == 10: #Diamond
				remove_wall(coords)
				diamond_positions.append(coords)	
	
	print ("Exit at " + str(map.get_exit()))
	exit.global_position = get_global_position_tile(map.get_exit())
	
	print ("Key at " + str(map.get_key()))
	key.global_position = get_global_position_tile(map.get_key())
	
			
	var time_done = Time.get_ticks_msec()
	var time_spent_level = time_done-time_start
	
	print ("Level generation took " + str(time_spent_level) + "ms")
	
	spawn_bats()
	spawn_turrets()
	spawn_diamonds()
		
	time_done = Time.get_ticks_msec()
	var time_spent_enemies = time_done-time_spent_level
	
	print ("Enemy spawn took " + str(time_spent_enemies) + "ms")
	
	#setup_astar()
	
func generate_border(fill, size, start):
	#Top Row
	for n in range(0,size.x+1,1):
		var pos = Vector2(start.x+n,start.y)
		set_border(pos, border_dict[TS.IN_UP])
	
	#Left Column
	for n in range(0,size.y+1,1):
		var pos = Vector2(start.x,start.y+n)
		set_border(pos, border_dict[TS.IN_LEFT])
		
	#Right Column
	for n in range(0,size.y+1,1):
		var pos = Vector2(start.x+size.x,start.y+n)
		set_border(pos, border_dict[TS.IN_RIGHT])
	
	#Bottom Row
	for n in range(0,size.x+1,1):
		var pos = Vector2(start.x+n,size.y+start.y)
		set_border(pos, border_dict[TS.IN_DOWN])
		
	#Set Corners
	set_border(Vector2(start.x,start.y), border_dict[TS.CORNER_IN_UP_LEFT])
	set_border(Vector2(start.x+size.x, start.y), border_dict[TS.CORNER_IN_UP_RIGHT])
	set_border(Vector2(start.x,start.y+size.y), border_dict[TS.CORNER_IN_DOWN_LEFT])
	set_border(Vector2(start.x+size.x,start.y+size.y), border_dict[TS.CORNER_IN_DOWN_RIGHT])
	
	for x in range(-fill.x,size.x+fill.x+1,1):
		#Fill Outside Top
		for y in range(start.y-1,start.y-fill.y,-1):
			var pos = Vector2(start.x+x,y)
			set_border(pos, border_dict[TS.CENTER])
		
		#Fill Outside Bottom
		for y in range(start.y+size.y+1,start.y+size.y+fill.y,1):
			var pos = Vector2(start.x+x,y)
			set_border(pos, border_dict[TS.CENTER])

	for y in range(-fill.y,size.y+fill.y+1,1):
		# Left
		for x in range(-1,-fill.x,-1):
			var pos = Vector2(start.x+x,y)
			set_border(pos, border_dict[TS.CENTER])
			
		# Right
		for x in range(1,fill.x, 1):
			var pos = Vector2(start.x+size.x+x,y)
			set_border(pos, border_dict[TS.CENTER])
			
	pass
	
# Returns an array containing all the surrounding tiles
func tiles_surrounding(tile : Vector2i, include_self : bool = false) -> Array[Vector2i]:
	var tile_check_array : Array[Vector2i] = [
		tile+rel[R.DOWN],
		tile+rel[R.UP],
		tile+rel[R.LEFT],
		tile+rel[R.RIGHT],
		tile+rel[R.UP_LEFT],
		tile+rel[R.UP_RIGHT],
		tile+rel[R.DOWN_LEFT],
		tile+rel[R.DOWN_RIGHT],
	]
	
	if include_self: tile_check_array.append(tile)
	
	return tile_check_array

func _spawn_ground_piece(amount : int, tile : Vector2i):
	for i in range(amount):
		var instance : RigidBody2D = ground_piece.instantiate()
		get_parent().add_child(instance)
		instance.global_position = get_global_position_tile(tile)

		# Add the new instance to the queue
		ground_pieces_queue.push_back(instance)
		
		var rnd_rad = deg_to_rad(randi() % 361)
		var rnd_speed = randi_range(100,250)
		
		instance.linear_velocity = Vector2(cos(rnd_rad), sin(deg_to_rad(rnd_rad))) * rnd_speed

		# Check if the queue size exceeds the maximum limit
		if ground_pieces_queue.size() > max_debris:
				# Remove the oldest instance (FIFO) and free it
			var old_instance = ground_pieces_queue.pop_front()
			old_instance.queue_free()

func _shot_impact(impact_pos, body):
	
	if not body is TileMap:
		return
	
	var tile : Vector2i = tile_map.local_to_map(to_local(impact_pos))
	
	# Check if tile is a wall, if not -> Find the nearest tile adjacent to position
	if(tile_map.get_cell_tile_data(layer_walls, tile)):
		EventBus.block_destroyed.emit()
		# Spawn Ground Pieces
		call_deferred("_spawn_ground_piece", ground_piece_spawn_count, tile)
		remove_wall(tile)
		Audio.play_sound_random(Sounds.list_ground_break, .1)
	elif(tile_map.get_cell_tile_data(layer_border, tile)):
		EventBus.border_hit.emit()
		Audio.play_sound_random(Sounds.list_ground_break, .05)
		return
	else: # Find closest wall to remove
		var distance : float = 1000.0
		var tile_nearest : Vector2i
		
		for tile_check in tiles_surrounding(tile):
			if tile_map.get_cell_tile_data(layer_walls, tile_check): 
				var tile_pos = to_global(tile_map.map_to_local(tile_check))
				var check_distance : float = tile_pos.distance_to(impact_pos)
				if check_distance < distance: 
					distance = check_distance
					tile_nearest = tile_check
					
				
		if(tile_map.get_cell_tile_data(layer_walls, tile_nearest)):
			call_deferred("_deferred_remove_wall", tile_nearest)
			
			
func _deferred_remove_wall(tile_nearest : Vector2i):		
	remove_wall(tile_nearest)

func is_wall(tile : Vector2i):
	return tile_map.get_cell_tile_data(layer_walls, tile)
	
func is_partial_wall(tile : Vector2i) -> bool:
	if !tile_map.get_cell_tile_data(layer_walls, tile):
		return false
		
	var coords = tile_map.get_cell_atlas_coords(layer_walls, tile)
	
	if coords != Vector2i(1,1):
		return true
	return false
	
func remove_wall(tile : Vector2i):
	#print("Removing " + str(tile))
	tile_map.erase_cell(layer_walls, tile)
	fix_nearby_walls(tile)
	pass
	
func fix_nearby_walls(tile : Vector2i):
	for tile_check in tiles_surrounding(tile, true):
		if tile_map.get_cell_tile_data(layer_walls, tile_check): #Only check existing tiles
			if exposed_edges(tile_check)>=3: remove_wall(Vector2i(tile_check.x,tile_check.y))
			fix_wall_tile(tile_check)
	pass
	
func set_wall(tile_map_position : Vector2i, tileset_coordinates : Vector2i):
	if(exposed_edges(tile_map_position)>3): return
	#void set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	tile_map.set_cell(layer_walls, tile_map_position, 0, tileset_coordinates)
	
func set_border(tile_map_position: Vector2i, tileset_coordinates: Vector2i):
	tile_map.set_cell(layer_border, tile_map_position, 1, tileset_coordinates)
	
func exposed_edges(tile : Vector2i) -> int:
	var edges = 0
	if !is_wall(tile+rel[R.UP]): edges += 1
	if !is_wall(tile+rel[R.DOWN]): edges += 1
	if !is_wall(tile+rel[R.LEFT]): edges += 1
	if !is_wall(tile+rel[R.RIGHT]): edges += 1
	return edges
	
func occupied_tiles_array(tiles : Array[Vector2i]) -> int:
	var occupied : int = 0
	for tile in tiles:
		if tile_map.get_cell_tile_data(layer_walls, tile): 
			occupied += 1
	return occupied
	
func fix_wall_tile(tile : Vector2i):
	
	#CORNER_OUT_UP_LEFT 0,0
	if( !is_wall(tile+rel[R.UP]) 
	and !is_wall(tile+rel[R.LEFT])
	and is_wall(tile+rel[R.RIGHT])
	and is_wall(tile+rel[R.DOWN])
		): 
			set_wall(tile, wall_dict[TS.CORNER_OUT_UP_LEFT])
			return
		
	#CORNER_OUT_UP_RIGHT 0,2
	if( !is_wall(tile+rel[R.UP]) 
	and !is_wall(tile+rel[R.RIGHT])
	and is_wall(tile+rel[R.LEFT])
	and is_wall(tile+rel[R.DOWN])
		): 
			set_wall(tile, wall_dict[TS.CORNER_OUT_UP_RIGHT])
			return
		
	#CORNER_OUT_DOWN_RIGHT 2,2
	if( !is_wall(tile+rel[R.DOWN]) 
	and !is_wall(tile+rel[R.LEFT])
	and is_wall(tile+rel[R.RIGHT])
	and is_wall(tile+rel[R.UP])
		): 
			set_wall(tile, wall_dict[TS.CORNER_OUT_DOWN_RIGHT])
			return
		
	#CORNER_OUT_DOWN_LEFT 0,2
	if( !is_wall(tile+rel[R.DOWN]) 
	and !is_wall(tile+rel[R.RIGHT])
	and is_wall(tile+rel[R.LEFT])
	and is_wall(tile+rel[R.UP])
		): 
			set_wall(tile, wall_dict[TS.CORNER_OUT_DOWN_LEFT])
			return
		
	#OUT_UP 1,0
	if( !is_wall(tile+rel[R.UP]) 
	and is_wall(tile+rel[R.DOWN])
	and is_wall(tile+rel[R.LEFT])
	and is_wall(tile+rel[R.RIGHT])
		): 
			set_wall(tile, wall_dict[TS.OUT_UP])
			return
		
	#OUT_DOWN 1,2
	if( !is_wall(tile+rel[R.DOWN]) 
	and is_wall(tile+rel[R.UP])
	and is_wall(tile+rel[R.LEFT])
	and is_wall(tile+rel[R.RIGHT])
		): 
			set_wall(tile, wall_dict[TS.OUT_DOWN])
			return
		
	#OUT_LEFT 0,1
	if( !is_wall(tile+rel[R.LEFT]) 
	and is_wall(tile+rel[R.UP])
	and is_wall(tile+rel[R.DOWN])
	and is_wall(tile+rel[R.RIGHT])
		): 
			set_wall(tile, wall_dict[TS.OUT_LEFT])
			return
			
				
	#OUT_RIGHT 2,1
	if( !is_wall(tile+rel[R.RIGHT]) 
	and is_wall(tile+rel[R.UP])
	and is_wall(tile+rel[R.DOWN])
	and is_wall(tile+rel[R.LEFT])
		): 
			set_wall(tile, wall_dict[TS.OUT_RIGHT])
			return
	
	# INNER TILES
	if( is_wall(tile+rel[R.LEFT]) 
	and is_wall(tile+rel[R.UP])
	and is_wall(tile+rel[R.RIGHT])
	and is_wall(tile+rel[R.DOWN])):
		
	#CORNER_IN_UP_LEFT 3,0
		if !is_wall(tile+rel[R.DOWN_RIGHT]): 
			set_wall(tile, wall_dict[TS.CORNER_IN_UP_LEFT])
			return
						
	#CORNER_IN_UP_RIGHT 5,0
		if !is_wall(tile+rel[R.DOWN_LEFT]):
			set_wall(tile, wall_dict[TS.CORNER_IN_UP_RIGHT])
			return
		
	#CORNER_IN_DOWN_RIGHT 3,2
		if !is_wall(tile+rel[R.UP_LEFT]):
			set_wall(tile, wall_dict[TS.CORNER_IN_DOWN_RIGHT])
			return
		
	#CORNER_IN_DOWN_LEFT 5,2
		if !is_wall(tile+rel[R.UP_RIGHT]):
			set_wall(tile, wall_dict[TS.CORNER_IN_DOWN_LEFT])
			return
			
	# IN LEFT, UP, DOWN, RIGHT ARE THE SAME AS OUT
	
	pass
