extends CanvasLayer
class_name StampsLeftUI

var stamps_npcs_count: int = 0
var phase_stamped_npcs: int = 0
var world_stamped_npcs: int = 0

@onready var stamped_npcs_label: Label = $StampedNpcPanel/StampedNpcsLabel

signal AllNpcStamped


func _ready() -> void:
	#Inserimos o texto padrao 0/0
	stamped_npcs_label.text = str(0)
	Global.PhaseChanged.connect(_reset_stamps_left)
	
	# Conecta o signal quando um npc for carimbado
	Global.NpcStamped.connect(_on_npc_stamped)
	
	
func _reset_stamps_left(phase_number: int):
	# Vemos os NPCs que podem ser carimbados e colocamos na variabel
	var stamped_npcs_array = get_tree().get_nodes_in_group("StampNPCs") as Array[StampNpc]
	if stamped_npcs_array:
		var npc_phase = stamped_npcs_array.filter(func(x: StampNpc):  return x.npc_phase == phase_number)
		
		stamps_npcs_count = npc_phase.size()
		world_stamped_npcs += stamps_npcs_count
		phase_stamped_npcs = 0
		
	#Atualiza a UI
	_update_UI()


func _update_UI():
	stamped_npcs_label.text = str(stamps_npcs_count - phase_stamped_npcs)


func _on_npc_stamped():
	phase_stamped_npcs += 1
	_update_UI()
	
	if phase_stamped_npcs == stamps_npcs_count:
		AllNpcStamped.emit()
		
		# Resetamos o count de carimbados
		phase_stamped_npcs = 0
