extends PanelContainer
class_name DialogBox

#Label
@onready var label: Label = $MarginContainer/Text
@onready var max_width := 1000


#Dicionário das frases
var npc_phrases: Dictionary = {}
var current_phrase: int = 1
var phrases_count: int


#Node de referencia
var reference_node: Node = null


func _ready() -> void:
	change_phrase()
	phrases_count = npc_phrases.size()
	
	# Ajustamos a posicao para ele ficar em cima da cabeca do node
	self.global_position.y = reference_node.position.y - 300


func dialog_closed():
	var tweenScale = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tweenScale.tween_property(self, "scale", self.scale + Vector2(0.2, 0.2), 0.15)
	tweenScale.tween_property(self, "scale", Vector2.ZERO, 0.25)
	
	await tweenScale.finished
	queue_free()


func change_phrase():
	var phrase = npc_phrases["phrase" + str(current_phrase)]
	label.text = phrase
	
	#Incrementamos a frase
	current_phrase += 1	
	
	#Esperamos ele fazer o resized
	await resized
	
	#Ajustamos o size
	adjust_size()
	
	#Ajustamos o pivot
	adjust_pivot_and_position()
	

func adjust_size():
	# Reseta o tamanho do label
	label.reset_size()
	
	# Insere o tamanho minimo do container como sendo do label
	custom_minimum_size.x = min(label.size.x, max_width)
	
	# Se o tamanho do label for maior que o tamanho maximo, fazemos wrap do texto		
	if(self.size.x > max_width):
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = custom_minimum_size.y
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
	

func adjust_pivot_and_position():
	var nodeSize = self.size
	self.pivot_offset = nodeSize / 2.0	
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"): 
		if current_phrase > phrases_count:
			await dialog_closed()
			Global.DialogClosed.emit()
		else:
			change_phrase()
