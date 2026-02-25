extends Node

var current_world: int = Global.GAME_WORLDS.tutorial
var current_phase: int = Global.GAME_PHASES.phase1
var current_player_lifes: int = 5

var phase_total_stamps: int = 0
var total_stamps: int = 0

func set_current_world(world_name: int):
	print("Mundo atual: ", world_name)
	current_world = world_name
	
	
func set_current_phase(phase_name: int):
	print("Fase atual: ", phase_name)
	current_phase = phase_name
	
	
func set_player_lifes_world(lifes: int):
	current_player_lifes = lifes
	
	
func set_phase_stamps(stamps: int):
	print("Stamps: ", stamps)
	_add_total_stamps()
	phase_total_stamps = stamps
	
	
func _add_total_stamps():
	total_stamps += 1
