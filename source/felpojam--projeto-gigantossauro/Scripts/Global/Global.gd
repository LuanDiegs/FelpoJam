extends Node

#Cenas
var start_menu = "res://Cenas/Menus/MainMenu/start_menu.tscn"
var settings_menu = "res://Cenas/Menus/SettingsMenu/settings_menu.tscn"
var credits_menu = "res://Cenas/Menus/CreditsMenu/credits_menu.tscn"
var transition_scene = preload("res://Cenas/ScenteTransition/scene_transition.tscn")
var dialogs_json = "res://Utils/Dialogs/dialogs.json"

#Variaveis gerais
var player_lifes = 5
var current_phase: int = 1
var transition_instance : CanvasLayer 

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

#Signals importantes
signal DialogOpen(node: Node, phase: int, npc: String)
signal DialogClosed

#Constantes
var NPC_Spawn_y = 540.0

func get_action_key(action_name: String):
	# Pega o nome do evento que foi passado
	var button_events_name = str(InputMap.action_get_events(action_name)[0])
	return button_events_name.get_slice(":",1).get_slice(",",0).get_slice("(",1).get_slice(")",0)

func open_dialog_modal(node: Node, level: int, npc_name: String):
	var dialogNode = (preload("res://Cenas/TextBoxes/DialogBoxes/dialog_box.tscn")).instantiate() as DialogBox
	
	# Sistema para pegar as frases dos NPCs no JSON
	var phrases = _get_json_file_and_return_dic(level, npc_name)
	
	dialogNode.npc_phrases = phrases
	dialogNode.reference_node = node
	
	node.add_child(dialogNode)

func _get_json_file_and_return_dic(level: int, npc_name: String) -> Dictionary:
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
	var phase = "phase" + str(level)
	if !json_parsed.has(phase):
		return _randomize_default_text()
	
	var npcName = npc_name.to_lower()	
	if !json_parsed[phase].has(npcName):
		return _randomize_default_text()

	return json_parsed[phase][npcName]
	
	
func _randomize_default_text() -> Dictionary:
	var defaultCount = defaultTexts.size()
	var randomDefault = randi_range(1, defaultCount)
	var key = "default" + str(randomDefault)
	
	return defaultTexts[key]
#endregion

#region Função de Transição de Cenas
#Função de fade da cena
func fade_to_scene(scene_path : String, duration : float = 0.5):
	
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
