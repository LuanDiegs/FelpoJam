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

#Phases and world
@export var phase: Global.GAME_PHASES = Global.GAME_PHASES.phase1
@export var world: Global.GAME_WORLDS = Global.GAME_WORLDS.tutorial

#Area
@onready var area: Area2D = $Area

#Passed
var passed: bool = false


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body: Node):
	#Se ja passou ou se o body não for jogador retornamos
	if (passed) or (!body and !body.is_in_group("Player")):
		return
	
	#Colocamos que o jogador já passou, ou seja, não pode mais
	passed = true
	
	#Emite que trocou de fase
	Global.PhaseChanged.emit(phase)
