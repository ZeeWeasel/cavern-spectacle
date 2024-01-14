extends Node

#var song_1 : AudioStream = preload("res://music/.mp3")
#var song_2 : AudioStream = preload("res://music/.mp3")
#var song_3 : AudioStream = preload("res://music/.mp3")

var volume_music = 1.0
var volume_sounds = 1.0

#var playlist : Array[AudioStream] = [
	#song_1, song_2, song_3
#]

var music_player: AudioStreamPlayer

var playlist_position : int
var playback_position : float

func _process(_delta):
	if music_player:
		if !music_player.playing:
			track_finished()
	pass

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	#playlist_position = 2
	#music_player = play_music(playlist[playlist_position], volume_music)
	#music_player.set_bus("Music")
	#track_finished()
	
func remove_specific_audio_streams(sound_path: String):
	
	print("To be removed: " + sound_path)
	for child in get_children():
		if child is AudioStreamPlayer and child.stream and child.stream.resource_path == sound_path:
			child.free()
	
func switch_music_to_lowpass(enabled: bool):
	if !music_player:
		return
	if enabled:
		music_player.set_bus("Lowpass")
	else: 
		music_player.set_bus("Music")

@onready var tree := get_tree() # Gets the slightest of performance improvements by caching the SceneTree

func _play_music(sound: AudioStream, player, volume, autoplay := true):
	player.process_mode = PROCESS_MODE_ALWAYS
	player.set_volume_db(linear_to_db(volume))
	player.stream = sound
	player.autoplay = autoplay
	player.set_bus("Music")
	player.finished.connect(track_finished)
	self.add_child(player)
	return player
	
func track_finished():
	#print("Track finished")
	#playlist_position += 1
	#if(playlist_position>playlist.size()-1):
		#playlist_position = 0
	#music_player.set_stream(playlist[playlist_position])
	#music_player.play()
	pass

func _play_sound(sound: AudioStream, player, volume, autoplay := true):
	player.process_mode = PROCESS_MODE_ALWAYS
	player.set_volume_db(linear_to_db(volume))
	player.stream = sound
	player.autoplay = autoplay
	player.set_bus("Sounds")
	player.finished.connect(func(): player.queue_free())
	self.add_child(player)
	return player

# Use this for non-diagetic music or UI sounds which have no position
func play_music(sound: AudioStream, volume := 1.0, autoplay := true) -> AudioStreamPlayer:
	return _play_sound(sound, AudioStreamPlayer.new(), volume, autoplay)
	
func play_sound_random(sounds: Array[AudioStream], volume := 1.0, autoplay := true) -> AudioStreamPlayer:
	return _play_sound(sounds[randi_range(0,sounds.size()-1)], AudioStreamPlayer.new(), volume, autoplay)

# Use this for non-diagetic music or UI sounds which have no position
func play_sound(sound: AudioStream, volume := 1.0, autoplay := true) -> AudioStreamPlayer:
	return _play_sound(sound, AudioStreamPlayer.new(), volume, autoplay)

# Use this for 2D gameplay sounds which should fade with distance
# Note: Remember to set the global_position or reparent(new_parent, false)!
func play_sound_2d(sound: AudioStream, volume := 1.0, autoplay := true) -> AudioStreamPlayer2D:
	return _play_sound(sound, AudioStreamPlayer2D.new(), volume, autoplay)

# Use this for 3D gameplay sounds which should fade with distance
# Note: Remember to set the global_position or reparent(new_parent, false)!
func play_sound_3d(sound: AudioStream, volume := 1.0, autoplay := true) -> AudioStreamPlayer3D:
	return _play_sound(sound, AudioStreamPlayer3D.new(), volume, autoplay)
