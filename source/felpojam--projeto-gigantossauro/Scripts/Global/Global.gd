extends Node

#Cenas
var start_menu = "res://Cenas/start_menu.tscn"
var settings_menu = "res://Cenas/settings_menu.tscn"
var dialogs_json = "res://Utils/Dialogs/dialogs.json"

#Variaveis gerais
var player_lifes = 5
var current_phase: int = 1

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
