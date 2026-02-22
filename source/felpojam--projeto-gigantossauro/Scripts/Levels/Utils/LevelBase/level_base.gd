extends Node
class_name LevelBase

@export var world_name: Global.GAME_WORLDS = Global.GAME_WORLDS.tutorial
@export var phase_name: Global.GAME_PHASES = Global.GAME_PHASES.phase1
@export var phases_count: int = 1


func _ready() -> void:
	GameProgress.set_current_world(world_name)
	GameProgress.set_current_phase(phase_name)
