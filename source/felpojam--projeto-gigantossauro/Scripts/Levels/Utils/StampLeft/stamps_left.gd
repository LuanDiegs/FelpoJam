extends CanvasLayer
class_name StampsLeftUI

var stamps_npcs_count: int = 0
var stamped_npcs: int = 0

@onready var label_stamped: RichTextLabel = $Margin/Container/LabelStamped
const TEMPLATE_LABEL: String = "%s / %s"

func _ready() -> void:
	# Vemos os NPCs que podem ser carimbados e colocamos na variabel
	var stamped_npcs_array := get_tree().get_nodes_in_group("StampNPCs")
	if stamped_npcs_array:
		stamps_npcs_count = stamped_npcs_array.size()
	
	# Conecta o signal quando um npc for carimbado
	Global.NpcStamped.connect(_on_npc_stamped)
	
	#Atualiza a UI
	_update_UI()


func _update_UI():
	label_stamped.text = TEMPLATE_LABEL % [stamped_npcs, stamps_npcs_count]


func _on_npc_stamped():
	stamped_npcs += 1
	_update_UI()
