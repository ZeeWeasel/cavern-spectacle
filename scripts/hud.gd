extends CanvasLayer

@export var label_coins : Label
@export var juice_coin_scene : PackedScene
@export var player_heart_rect : PackedScene
@export var heart_container : HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_hearts()
	EventBus.connect("coin_collected", _on_coin_collected)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	label_coins.text = str(Globals.coins)
	set_hearts()
	
func set_hearts():
	if(heart_container.get_child_count()<Globals.hit_points_player):
		var heart = player_heart_rect.instantiate()
		heart_container.add_child(heart)
	if(heart_container.get_child_count()>Globals.hit_points_player):
		if(heart_container.get_children().size()>0):
			var hearts : Array[Node] = heart_container.get_children()
			if hearts[0]:
				hearts[0].queue_free()
	pass
	
func clear_hearts():
	var hearts : Array[Node] = heart_container.get_children()
	for heart in hearts:
		heart.queue_free()

func spawn_coin():
	var coin_instance = juice_coin_scene.instantiate()
	add_child(coin_instance)
	
func _on_coin_collected():
	spawn_coin()
