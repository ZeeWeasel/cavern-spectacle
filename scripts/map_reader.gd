extends Node
class_name MapReader

var _image_loaded : Image
var _player_start : Vector2i = Vector2i(0,0)
var _exit : Vector2i  = Vector2i(0,0)
var _key : Vector2i  = Vector2i(0,0)

func load_map(map_path : String):
	print(map_path)
	
	_image_loaded = Image.new()
	_image_loaded = load(map_path)#.load(map_path)
	_load_values()
	# Failed
	
func _load_values():
	for x in range(_image_loaded.get_width()):
		for y in range(_image_loaded.get_height()):
			if get_value(Vector2i(x,y)) == 2:
				_player_start = Vector2i(x,y)
			elif get_value(Vector2i(x,y)) == 3:
				print("Found Exit")
				_exit = Vector2i(x,y)
			elif get_value(Vector2i(x,y)) == 4:
				print("Found Key")
				_key = Vector2i(x,y)

func get_map_size() -> Vector2i:
	if _image_loaded:
		return Vector2i(_image_loaded.get_width(), _image_loaded.get_height())
	else:
		print("Error: Image not loaded")
		return Vector2i(10,10)
		
func get_player_start() -> Vector2i:
	return _player_start
	
func get_exit() -> Vector2i:
	return _exit
	
func get_key() -> Vector2i:
	return _key
	
func get_value(pos : Vector2i) -> int:
	if _image_loaded:
		var color = _image_loaded.get_pixel(pos.x, pos.y)
		
		if color == Color(0,0,0):
			return 0 # Removed Walls
		elif color == Color(1,1,1):
			return 1 # Soil (Not used)
		elif color == Color8(0,255,0):
			return 2 # Player Start
		elif color == Color8(0,0,255):
			return 3 # Exit
		elif color == Color8(255,255,0):
			return 4 # Key
		elif color == Color8(53,105,49):
			return 5 # Gun
		elif color == Color8(255,0,255):
			return 6 # Turret
		elif color == Color8(255,0,0):
			return 9 # Bat
		elif color == Color8(25,225,225):
			return 10 # Diamond
			
		print ("Error: Do not recognize color:" + str(color))	
		return 0
	else:
		print("Error: Image not loaded")
		return 0
			
