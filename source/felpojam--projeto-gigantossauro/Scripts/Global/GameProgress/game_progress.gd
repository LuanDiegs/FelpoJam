extends Node


var current_world: int = Global.GAME_WORLDS.tutorial
var current_phase: int = Global.GAME_PHASES.phase1
var current_player_lifes: int = 5


func set_current_world(world_name: int):
	current_world = world_name
	
	
func set_current_phase(phase_name: int):
	current_phase = phase_name
	
	
func set_player_lifes_world(lifes: int):
	current_player_lifes = lifes
