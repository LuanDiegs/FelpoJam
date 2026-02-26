@tool
extends CanvasLayer
class_name StampPhaseTimerUI

@export var max_stamp_time_to_die: float = 10
@export var stop_time_debug: bool

@onready var timer: Timer = $Timer
@onready var number_label: RichTextLabel = $ContainerTimer/ContainerHeight/LabelsTempo/Panel/NumberLabel
var time_passed: float = 0
var time_passed_in_world: float = 0
var timer_stopped: bool = stop_time_debug
var phase_finished: bool = false

#Phase containers
@onready var phases_container: HBoxContainer = $ContainerTimer/ContainerHeight/PhasesContainer
@export var level: LevelBase

#Sempre que tiver timer tem que ter esse modulo
@export var stamps_left_module: StampsLeftUI:
	get:
		return stamps_left_module
	set(value):
		stamps_left_module = value
		if Engine.is_editor_hint():
			update_configuration_warnings()


func _process(delta: float) -> void:
	#Se esta no editor nao irá compilar o codigo do jogo
	if Engine.is_editor_hint() or stop_time_debug:
		return
		
	if !timer_stopped:
		_update_timer(delta)
	
	if time_passed >= max_stamp_time_to_die and !Global.phase_finished:
		#Paramos o timer e emitimos o sinal
		timer_stopped = true
		Global.PlayerDied.emit()


func _ready() -> void:
	#Se esta no editor nao irá compilar o codigo do jogo
	if Engine.is_editor_hint() or stop_time_debug:
		return
	
	#Conecta o signal de aumentar timer
	Global.NpcStamped.connect(_on_npc_stamped)
	
	#Conecta o signal de parar e resumir o timer
	Global.DialogOpen.connect(func(_node, _phase, _npc): _set_timer_stopped(true))
	Global.DialogClosed.connect(_set_timer_stopped.bind(false))
	Global.PhaseChanged.connect(func(_phaseNumber): _reset_timer())
	stamps_left_module.AllNpcStamped.connect(_on_all_npc_stamped)
	
	_update_timer(0)
	
	#Criar a UI dependendo das fases do leveis
	_create_containers_levels_completed()


func _create_containers_levels_completed():
	var phases_count: int = level.phases_count
	for phase in range(phases_count):
		var phase_container_instance = (preload("uid://bny518f180mg5")).instantiate() as PhaseCompletedContainer
		#+1 pois o for começa do 0
		phase_container_instance.phase_number = phase + 1 
		phases_container.add_child(phase_container_instance)
	

func _update_timer(time: float):
	# Aumenta o tempo passado
	time_passed += time
	
	_update_display()
	
	
func _update_display():
	var remaining = max_stamp_time_to_die - time_passed
	
	number_label.text = "%0.3f" % remaining
	
	
func _set_timer_stopped(value: bool):
	if phase_finished: 
		return
		
	timer_stopped = value


func _reset_timer():
	# Colocamos que o tempo passado foi 0 e o timer não está pausado e que a fase não esta mais terminada
	time_passed = 0
	timer_stopped = false
	phase_finished = false


func _on_all_npc_stamped():
	_set_timer_stopped(true)
	phase_finished = true
	
	# Colocamos o tempo que demorou para correr as fases
	time_passed_in_world += time_passed
	
	
func _on_npc_stamped():
	_update_timer(-0.25)


func _get_configuration_warnings() -> PackedStringArray:
	if stamps_left_module == null:
		return ["O timer sempre vai precisar do modulo de carimbos faltantes"]
	if level == null:
		return ["O timer precisa do level para pegar as fases"]
		
	return []
