extends BaseNpc
class_name DialogNpc

#Label
@onready var interactive_label: Label = $InteractiveLabel
var interactive_text: String = "Pressione '%s' para interagir"

func _ready() -> void:
	# Pegamos a tecla que faz a açao de interaçao
	var interactKey = Global.get_action_key("interact")
	
	#Colocamos a tecla no texto e deixamos o label com escala 0
	interactive_label.text = interactive_text % interactKey
	interactive_label.scale = Vector2.ZERO
	
	_connect_signals()
	_configure_label()
	
	#Signals proprios
	Global.DialogClosed.connect(_reset_state_npc)
	area_interativa.body_entered.connect(_on_body_entered_area_interativa)
	area_interativa.body_exited.connect(_on_body_exited_area_interativa)


func _on_body_exited_area_interativa(body: Node2D):
	if body.is_in_group("Player"):
		_animate_label(false)
		Global.DialogClosed.emit()
		

func _input(event: InputEvent) -> void:
	# Se apertou o botao de interagir e um dos corpos em volta é um jogador, habilita o dialogo
	if event.is_action_pressed("interact") and _player_is_in_area() and !isPopUpOpen:
		Global.DialogOpen.emit(self, Global.current_phase, npc_name)
		isPopUpOpen = true
		_animate_label(false)
