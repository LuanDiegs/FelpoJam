extends Node
class_name LevelBase

@export var world_name: Global.GAME_WORLDS = Global.GAME_WORLDS.tutorial
@export var phase_name: Global.GAME_PHASES = Global.GAME_PHASES.phase1
@export var phases_count: int = 1


func _ready() -> void:
	GameProgress.set_current_world(world_name)
	GameProgress.set_current_phase(phase_name)
	
	#Signal de morte
	Global.PlayerDied.connect(_show_dead_menu)
	
	#Insere as musicas
	if world_name == Global.GAME_WORLDS.tutorial:
		_verify_and_play_music("tutorial", 2)
	elif world_name == Global.GAME_WORLDS.world1:
		_verify_and_play_music("level1", 2)
	elif world_name == Global.GAME_WORLDS.world2:
		_verify_and_play_music("level2", 2)
	elif world_name == Global.GAME_WORLDS.world3:
		_verify_and_play_music("level3", 2)


func _show_dead_menu():
	var dead_menu = (preload(Global.dead_menu)).instantiate() as DeadMenu
	add_child(dead_menu)


func _verify_and_play_music(music_name: String, fade_duration: int):
	if !MusicManager.verify_if_playing(music_name):
		MusicManager.trocar_musica(music_name, fade_duration)
