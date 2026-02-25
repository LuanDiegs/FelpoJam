extends CanvasLayer
class_name DeadMenu

@onready var phase: Label = $Control/PanelUI/MarginUI/VboxUI/MarginItens/VboxItems/Phase
@onready var label_stamps: Label = $Control/PanelUI/MarginUI/VboxUI/MarginItens/VboxItems/HboxStamps/LabelStamps
@onready var restart: Button = $Control/PanelUI/MarginUI/VboxUI/MarginItens/VboxItems/HboxBotoes/Restart
@onready var back_to_menu: Button = $Control/PanelUI/MarginUI/VboxUI/MarginItens/VboxItems/HboxBotoes/BackToMenu

var current_phase: int = 0
var phase_stamps: int = 0

const PHASE_TEMPLATE: String = "Fase %s"
const STAMPS_TEMPLATE: String = "%s carimbos \n coletados"


func _ready() -> void:
	_player_died()
	
	#Sinal de botoes
	restart.pressed.connect(_reset_scene)
	back_to_menu.pressed.connect(_return_to_menu)


func _player_died():
	#Coloca que o "jogo" teminou
	Global.phase_finished = true
	
	#Coloca as variaveis
	current_phase = GameProgress.current_phase
	phase_stamps = GameProgress.phase_total_stamps
	
	#Seta as labels
	_set_labels()
	
	#Aparece
	self.show()


func _set_labels():
	label_stamps.text = STAMPS_TEMPLATE % phase_stamps
	phase.text = PHASE_TEMPLATE % current_phase


func _reset_scene():
	#Esconde e coloca que a fase ainda nao terminou
	self.hide()
	Global.phase_finished = false
	
	#Faz reload da cena
	get_tree().reload_current_scene()
	
	queue_free()


func _return_to_menu():
	#Esconde e coloca que a fase ainda nao terminou
	self.hide()
	Global.phase_finished = false
	
	#Vai para o menu de start
	Transition.change_to_scene(Global.start_menu)
	
	queue_free()
