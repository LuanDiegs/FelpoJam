extends Node

#Cenas
var credits_menu = "uid://d0be4afyq8exh"
var start_menu := "uid://bqh03fym7is0"
var settings_menu := "uid://bmbjeqofrspuq"
var intermission_1 := "uid://bxgq6p58qxcx3"
var tutorial := "uid://4w463o650n0"
var dialogs_json = "res://Utils/Dialogs/dialogs.json"
var lore_json = "res://Utils/IntermissionLore/intermission_lore.json"

#Transicao de cena
var transition_scene = "uid://5jc7225o6nxi"

#Variaveis gerais
var player_lifes = 5
enum GAME_WORLDS { tutorial = 0, world1 = 1, world2 = 2, world3 = 3, boss = 4}
enum GAME_PHASES { phase1 = 1,	phase2 = 2,	phase3 = 3}

var transition_instance: CanvasLayer

#Signals importantes
signal DialogOpen(node: Node, world: int, npc: String)
signal DialogClosed

#Signal de timer
signal NpcStamped

#Signal de resetar timer e o UI dos personagens 
signal PhaseChanged(phaseNumber: GAME_PHASES)

#Pause
var paused: bool = false


func _ready() -> void:
	#Sinais globais
	Global.DialogOpen.connect(Global.open_dialog_modal)
	
	#Menu de pause ficará fechado ao iniciar o projeto
	PauseMenu.hide()
	SettingsPauseMenu.hide()
	
	
#region Sistema de Dialogos
#Edge cases json (Caso nao ache o file de dialogos)
var defaultTexts: Dictionary = {
	"default1": {
		"phrase1": "Pois não?"
	},
	"default2": {
		"phrase1": "Hoje é um lindo dia, não é?"
	},
	"default3": {
		"phrase1": "Aff, sou tão preguiçoso..."
	},
	"default4": {
		"phrase1": "Queria chegar logo em casa..."
	},
	"default5": {
		"phrase1": "Estou com fome..."
	}
}

func get_action_key(action_name: String):
	# Pega o nome do evento que foi passado
	var button_events_name = str(InputMap.action_get_events(action_name)[0])
	return button_events_name.get_slice(":", 1).get_slice(",", 0).get_slice("(", 1).get_slice(")", 0)

func open_dialog_modal(node: Node, world: int, npc_name: String):
	var dialogNode = (preload("uid://ds3m7ggl5s42s")).instantiate() as DialogBox
	var level = str(world)
	
	# Sistema para pegar as frases dos NPCs no JSON
	var phrases = _get_json_file_and_return_dic(level, npc_name)

	dialogNode.npc_phrases = phrases
	dialogNode.reference_node = node
	
	node.add_child(dialogNode)


func _get_json_file_and_return_dic(level: String, npc_name: String) -> Dictionary:
	var file = FileAccess.open(dialogs_json, FileAccess.READ)
	
	# Se arquivo nao existe, retornamos default
	if file == null:
		return _randomize_default_text()
	
	#Se o texto ta vazio ou nao existe, retornamos default
	var json_text = file.get_as_text()
	if json_text == null or json_text == "":
		return _randomize_default_text()
	
	#Se o parse der erro, retornamos default
	var json_parsed = JSON.parse_string(file.get_as_text())
	if json_parsed == null or json_parsed == {} or json_parsed is not Dictionary:
		return _randomize_default_text()
	
	json_parsed = json_parsed as Dictionary
	
	# Se a fase ou nome do npc n existir, retornamos vazio
	var world = "world" + level.to_lower()
	if !json_parsed.has(world):
		return _randomize_default_text()
	
	var npcName = npc_name.to_lower()
	if !json_parsed[world].has(npcName):
		return _randomize_default_text()

	return json_parsed[world][npcName]
	
	
func _randomize_default_text() -> Dictionary:
	var defaultCount = defaultTexts.size()
	var randomDefault = randi_range(1, defaultCount)
	var key = "default" + str(randomDefault)
	
	return defaultTexts[key]
#endregion

#region Função de Transição de Cenas
#Função de fade da cena
func fade_to_scene(scene_path: String, duration: float = 0.5):
	#Instancia a transição se ainda não existir
	#Checa se a instancia da transição é invalida
	if !transition_instance:
		#Define a instancia da transição como a cena de trancisão e instancia ela
		transition_instance = transition_scene.instantiate()
		#Coloca a instancia como filha do nó principal
		get_tree().root.add_child(transition_instance)
	
	#Pega o node de color rect da cena transição
	var color_rect = transition_instance.get_node("ColorRect")
	#Começa com o alpha da imagem em 0
	color_rect.modulate.a = 0.0
	
	#Tween para o fadein
	#Cria o tween
	var tween = create_tween()
	#Muda as propriedades do tween
	tween.tween_property(color_rect, "modulate:a", 1.0, duration / 2.0)
	#"Finaliza" o tween
	await tween.finished
	
	#Troca de cena
	get_tree().change_scene_to_file(scene_path)
	
	#Twen para fadeout
	#Cria o tween
	tween = create_tween()
	#Muda as propriedades do tween
	tween.tween_property(color_rect, "modulate:a", 0.0, duration / 2.0)
	#"Finaliza" o tween
	await tween.finished
	
	#Removea instância
	#transition_instance.queue_free()
	#transition_instance = null
#endregion

#region Função Gerais
#Função para centralizar a janela
func center_window():
	#Cria um timer de 1 frame para garantir que o posicionamente foi aplicado
	await get_tree().process_frame
	
	#Obtem a area util da tela (desconsidera a barra de tarefas)
	var screen_rect = DisplayServer.screen_get_usable_rect()
	var window_size = DisplayServer.window_get_size() # salva o tamanho da janela

	#Calula a posição centralizada dentro da area util da tela
	var new_pos = Vector2i(
		screen_rect.position.x + (screen_rect.size.x - window_size.x) / 2,
		screen_rect.position.y + (screen_rect.size.y - window_size.y) / 2
	)
	
	#Garante que a posição não seja negativa
	new_pos.x = max(new_pos.x, 0)
	new_pos.y = max(new_pos.y, 0)
	
	#Aplica a nova posição da janela
	DisplayServer.window_set_position(new_pos)

#Configuracoes globais
func set_saved_settings():
	pass
#endregion
