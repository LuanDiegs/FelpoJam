extends Node

var file = ConfigFile.new()
var configfile_path := "user://settings.ini"

const audio_config: Dictionary = {
	audio = "audio",
	master = "Master",
	effects = "Effects",
	music = "Music",
}

const video_config: Dictionary = {
	video = "video",
	window = "window",
	resolution = "resolution",
	vsync = "vsync",
}

func _ready():
	_verify_and_save_settings()
	_apply_saved_settings()
	

func _verify_and_save_settings():
	if !FileAccess.file_exists(configfile_path):
		# Audio
		file.set_value(audio_config.audio, audio_config.master , 1.0)
		file.set_value(audio_config.audio, audio_config.effects, 1.0)
		file.set_value(audio_config.audio, audio_config.music, 1.0)
		
		#Video
		file.set_value(video_config.video, video_config.window, DisplayServer.WINDOW_MODE_FULLSCREEN)
		file.set_value(video_config.video, video_config.resolution, DisplayServer.screen_get_size()) # Primeiro e maior index
		file.set_value(video_config.video, video_config.vsync, DisplayServer.VSYNC_DISABLED)
		
		file.save(configfile_path)
	else:
		file.load(configfile_path)


func _apply_saved_settings():
	# Vsync
	var vsync_mode = file.get_value(video_config.video, video_config.vsync)
	if vsync_mode:
		DisplayServer.window_set_vsync_mode(vsync_mode)
		
	# Window mode
	var window_mode = file.get_value(video_config.video, video_config.window)
	if window_mode:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	# Resolution
	var resolution = file.get_value(video_config.video, video_config.resolution)
	if resolution and window_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_size(resolution)
		Global.center_window()
	
	#Audio master
	var master_volume = file.get_value(audio_config.audio, audio_config.master )
	if master_volume:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

	#Audio effects
	var effects_volume = file.get_value(audio_config.audio, audio_config.effects)
	if effects_volume:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(effects_volume))
	
	#Audio music
	var music_volume = file.get_value(audio_config.audio, audio_config.music)
	if music_volume:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))


func save_video_settings(key: String, value):
	file.set_value(video_config.video, key, value)
	file.save(configfile_path)


func load_video_settings() -> Dictionary:
	var settings = {}
	for key in file.get_section_keys(video_config.video):
		settings[key] = file.get_value(video_config.video, key)
	
	return settings


func save_audio_settings(key: String, value):
	file.set_value(audio_config.audio, key, value)
	file.save(configfile_path)


func load_audio_settings() -> Dictionary:
	var settings = {}
	for key in file.get_section_keys(audio_config.audio):
		settings[key] = file.get_value(audio_config.audio, key)
	
	return settings
