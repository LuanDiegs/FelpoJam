extends Node2D
class_name NPCs

#Exports
@export var npc_name: String = "NPC"

#Label
@onready var interactive_label: Label = $InteractiveLabel
var interactive_text: String = "Pressione '%s' para interagir"

#Area
@onready var area_interativa: Area2D = $AreaInterativa

#Dialogo
var isDialogOpen: bool = false


func _ready() -> void:
	# Pegamos a tecla que faz a açao de interaçao
	var interactKey = Global.get_action_key("interact")
	
	#Colocamos a tecla no texto e deixamos o label com escala 0
	interactive_label.text = interactive_text % interactKey
	interactive_label.scale = Vector2.ZERO
	
	#Conectamos o body_entered
	area_interativa.body_entered.connect(_on_body_entered_area_interativa)
	
	#Conectamos o body_exited
	area_interativa.body_exited.connect(_on_body_exited_area_interativa)

	#Dialog
	Global.DialogOpen.connect(Global.open_dialog_modal)
	Global.DialogClosed.connect(_reset_state_npc)


func _reset_state_npc():
	await _animate_label(true)
	isDialogOpen = false
	

func _animate_label(labelVisible: bool):
	var inicialPositionLabel := interactive_label.position
	var tweenScale = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	if labelVisible:
		# Animamos a escala
		interactive_label.scale = Vector2.ZERO
		tweenScale.tween_property(interactive_label, "scale", Vector2(1, 1), 0.4)
	else:
		tweenScale.tween_property(interactive_label, "scale", Vector2.ZERO, 0.4)
		await tweenScale.finished
		return
		
	# Animamos a posicao do label
	var tweenPosicao = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tweenPosicao.tween_property(interactive_label, "position", inicialPositionLabel + Vector2(0, 15), 0.4)
	tweenPosicao.tween_property(interactive_label, "position", inicialPositionLabel, 0.4)
	
	tweenPosicao.set_loops()


func _on_body_entered_area_interativa(body: Node2D):
	if body.is_in_group("Player"):
		_animate_label(true)


func _on_body_exited_area_interativa(body: Node2D):
	if body.is_in_group("Player"):
		_animate_label(false)
		
		
func _input(event: InputEvent) -> void:
	var overlapBodies := area_interativa.get_overlapping_bodies()

	# Se apertou o botao de interagir e um dos corpos em volta é um jogador, habilita o dialogo
	if event.is_action_pressed("interact") and overlapBodies.any(func(body): return body is Player) and !isDialogOpen:
		Global.DialogOpen.emit(self, Global.current_phase, npc_name)
		isDialogOpen = true
		_animate_label(false)
