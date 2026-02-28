extends Node2D
class_name BaseLevelBoss

#VAriaveis
@onready var player_life_label: Label = $Debug/PlayersLifeCounter
@onready var player: CharacterBody2D = $Player
@onready var boss_life_label: Label = $Debug/BossLifeCounter
@onready var boss: Node2D = $Boss

#Area caldera
@onready var area_caldera: Area2D = $Caldeira/AreaCaldera

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
	
	#Signals
	boss.boss_is_dead.connect(boss_dead_change_scene)
	area_caldera.body_entered.connect(_delete_props)
	Global.PlayerDied.connect(_show_dead_menu)
	
	MusicManager.trocar_musica("boss", 1)


#Função que muda a vida do player no label
func player_life_changed(new_life: int):
	#Define o texto do label para a nova vida do player
	player_life_label.text = str(new_life)
	
	#Morre
	if new_life <= 0:
		Global.PlayerDied.emit()


func boss_life_changed(new_life: int):
	boss_life_label.text = str(new_life)


func boss_dead_change_scene():
	Transition.change_to_scene(Global.intermission_6)


func _delete_props(body: Node):
	#Se um obstaculo for jogado na caldera, ela irá sumir
	if body.is_in_group("Obstacles"):
		body.queue_free()


func _show_dead_menu():
	var dead_menu = (preload(Global.dead_menu)).instantiate() as DeadMenu
	add_child(dead_menu)
