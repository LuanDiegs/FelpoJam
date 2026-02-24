extends Node
class_name LevelBase

@export var world_name: Global.GAME_WORLDS = Global.GAME_WORLDS.tutorial
@export var phase_name: Global.GAME_PHASES = Global.GAME_PHASES.phase1
@export var phases_count: int = 1


func _ready() -> void:
	GameProgress.set_current_world(world_name)
	GameProgress.set_current_phase(phase_name)


#Pause
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseGame()
	

func pauseGame():
	if Global.paused:	
		Engine.time_scale = 1
		PauseMenu.hide()
	else:
		Engine.time_scale = 0
		PauseMenu.show()
		
	Global.paused = !Global.paused
