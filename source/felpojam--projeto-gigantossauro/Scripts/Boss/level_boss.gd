extends Node2D

#VAriaveis
@onready var player_life_label : Label = $PlayersLifeCounter
@onready var player : CharacterBody2D = $Player
@onready var boss_life_label : Label = $BossLifeCounter
@onready var boss : Node2D = $Boss

#Função que roda ao iniciar o nó
func _ready() -> void:
	
	#Conecta o sinal do player na função de mudar de vida no label
	player.life_changed.connect(player_life_changed)
	#Adiciona o valor da vida do player no label
	player_life_changed(player.lifes)
	
	#Conecta o sinal do boss na função de mudar a vida do boss no label
	boss.boss_life_changed.connect(boss_life_changed)
	#Adiciona o valor da vida do player no label
	boss_life_changed(boss.boss_lifes)

#Função que muda a vida do player no label
func player_life_changed(new_life : int):
	#Define o texto do label para a nova vida do player
	player_life_label.text = str(new_life) 

func boss_life_changed(new_life : int):
	boss_life_label.text = str(new_life)
