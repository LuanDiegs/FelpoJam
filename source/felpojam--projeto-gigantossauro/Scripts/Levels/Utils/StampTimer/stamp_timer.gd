extends Node
class_name StampTimerUI


@export var stamp_time_to_die: float = 10

@onready var timer: Timer = $Timer
@onready var time_progress: ProgressBar = $ContainerTimer/ContainerHeight/TimeProgress
@onready var number_label: RichTextLabel = $ContainerTimer/ContainerHeight/Labels/NumberLabel
var time_passed: float = 0.0
var timer_stopped


func _process(delta: float) -> void:
	if !timer_stopped:
		update_timer(delta)
	
	if time_passed >= stamp_time_to_die:
		get_tree().reload_current_scene()


func _ready() -> void:
	#Conecta o signal de aumentar timer
	Global.NpcStamped.connect(_on_npc_stamped)
	
	#Conecta o signal de parar e resumir o timer
	Global.DialogOpen.connect(_on_timer_opened)
	Global.DialogClosed.connect(_on_timerclosed)
	
	time_progress.max_value = stamp_time_to_die
	time_progress.value = time_progress.max_value
	update_timer(0)


func update_timer(time: float):
	# Aumenta o tempo passado
	time_passed += time
	
	update_display()
	
	
func update_display():
	var remaining = stamp_time_to_die - time_passed
	
	time_progress.value = remaining
	number_label.text = "[b]%0.2f[/b]" % remaining
	
	# Tween do progress bar
	var tween_progress = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween_progress.tween_property(time_progress, "value", remaining, 0.1)


func _on_timer_opened(_node: Node, _phase: String, _npcName: String):
	timer_stopped = true
	
	
func _on_timerclosed():
	timer_stopped = false
	
	
func _on_npc_stamped():
	update_timer(-0.5)
