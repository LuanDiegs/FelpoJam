extends CanvasLayer
class_name Intermission_Base

@export var intermission_number: int = 1
@export var scene_to_change_uid: String

const default_text: Dictionary = { "lore_1": "Eita"}

#Textos
var count_lore_sentences: int
var current_lore_sentence: int = 1
var dic_sentences: Dictionary = {}
var lore_finished: bool = false

#Labels de texto
@onready var label_sentence: RichTextLabel = $PanelContainer/RichTextLabel
var tween_text_ratio: Tween

#Press to continue
@onready var press_to_continue: RichTextLabel = $PressToContinue


func _ready() -> void:
	dic_sentences = _get_json_file_and_return_dic()
	count_lore_sentences = dic_sentences.size()
	_set_sentence()
	

func _set_sentence():
	var key = "lore_" + str(current_lore_sentence)
	var sentence = dic_sentences.get(key)
	
	if !sentence:
		return
	
	label_sentence.text = sentence
	
	#Animate sentence
	_animate_visible_ratio()
	
	if current_lore_sentence == count_lore_sentences:
		var tween_modulate_continue = create_tween()
		tween_modulate_continue.tween_property(press_to_continue, "modulate:a", 1, 2)
		
		
		var tween_down = create_tween().set_ease(Tween.EASE_OUT_IN)
		tween_down.parallel().tween_property(press_to_continue, "position:y", press_to_continue.position.y + 10, 1.5)
		tween_down.tween_property(press_to_continue, "position:y", press_to_continue.position.y, 1.5)
		tween_down.set_loops()
	
	current_lore_sentence += 1


func _animate_visible_ratio():
	if tween_text_ratio == null:
		tween_text_ratio = create_tween()
	
	# Inserimos o ratio como 0
	label_sentence.visible_ratio = 0
	
	#Animamos
	tween_text_ratio.tween_property(label_sentence, "visible_ratio", 1, 3)
	
	
func _get_json_file_and_return_dic() -> Dictionary:
	var file = FileAccess.open(Global.lore_json, FileAccess.READ)
	
	# Se arquivo nao existe, retornamos default
	if file == null:
		return default_text
	
	#Se o texto ta vazio ou nao existe, retornamos default
	var json_text = file.get_as_text()
	if json_text == null or json_text == "":
		return default_text
	
	#Se o parse der erro, retornamos default
	var json_parsed = JSON.parse_string(file.get_as_text())
	if json_parsed == null or json_parsed == {} or json_parsed is not Dictionary:
		return default_text
	
	json_parsed = json_parsed as Dictionary
	var scene_name := "scene_" + str(intermission_number)
	
	# Se o nome da fase não existir, retorna
	if !json_parsed.has(scene_name):
		return default_text

	return json_parsed[scene_name]


func _input(event: InputEvent) -> void:
	#Troca a cena pro tutorial
	if lore_finished:
		Transition.change_to_scene(scene_to_change_uid)
		return
		
	# Se apertar qualquer tecla
	if ((event is InputEventKey and event.is_released()) or event.is_action_released("interact")) \
	and current_lore_sentence <= count_lore_sentences + 1:
		if !tween_text_ratio:
			return
		
		# Se nao tiver terminado colocamos o ratio inteiro
		if tween_text_ratio and tween_text_ratio.is_running():
			label_sentence.visible_ratio = 1
			tween_text_ratio.stop()
			return
		
		#Reset tween
		tween_text_ratio.stop()
		tween_text_ratio = null
		
		#Ajusta sentença
		_set_sentence()
		
		if current_lore_sentence >= count_lore_sentences + 1 and !tween_text_ratio:
			lore_finished = true
		
