@tool
extends Node2D
class_name StartNewPhaseOrWorldArea

#constantes
const world_uids = {
	"Intermission1": "uid://bxgq6p58qxcx3",
	"Tutorial": "uid://4w463o650n0",
	"Intermission2": "uid://cvay0ta05kj2j",
	"Level1": "uid://dyxdcldko83lw",
	"Intermission3": "uid://ddkqfw2c6h8od",
	"Level2": "uid://c0im24hxkqyck",
	"Intermission4": "uid://hevhp04vosoy",
	"Level3": "uid://ba6ej8rybb413",
	"Intermission5": "uid://d0ikofaip68oa",
}

@export var phase: Global.GAME_PHASES = Global.GAME_PHASES.phase1
@export var world: Global.GAME_WORLDS = Global.GAME_WORLDS.tutorial
@export var go_to_next_world: bool = false

#Exportar as cenas
@export_enum("Intermission1", "Tutorial", 
"Intermission2", "Level1", 
"Intermission3", "Level2", 
"Intermission4", "Level3", 
"Intermission5") 
var next_world_name: String = "Intermission0":
	set(value):
		next_world_name = value
		next_world_uid = world_uids.get(value, "")	
var next_world_uid: String = ""

#Area
@onready var area: Area2D = $Area


#Passed
var passed: bool = false


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body: Node):
	#Editor do tool
	if not Engine.is_editor_hint():
		next_world_uid = world_uids.get(next_world_name, "")
	
	#Se ja passou ou se o body não for jogador retornamos
	if (passed) or (!body and !body.is_in_group("Player")):
		return
	
	#Colocamos que o jogador já passou, ou seja, não pode mais
	passed = true
	
	# Setamos o progesso do jogo
	GameProgress.set_current_phase(phase)
	GameProgress.set_current_world(world)
	
	# Se for para o proximo mundo faz a transiçao
	#TODO: Colocar uma confirmacao depois
	if go_to_next_world and next_world_uid:
		Transition.change_to_scene(next_world_uid)
	
	Global.PhaseChanged.emit(phase)
