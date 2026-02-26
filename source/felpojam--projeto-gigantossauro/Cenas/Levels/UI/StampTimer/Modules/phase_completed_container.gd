extends PanelContainer
class_name PhaseCompletedContainer

@export var phase_number: int 

#Themes
const PHASE_NOT_COMPLETED := preload("uid://b5wbd7b2tqaxf")
const PHASE_COMPLETED := preload("uid://dix1hl6bcqsmp")


func _ready() -> void:
	Global.PhaseChanged.connect(_fill_phase_container)


func _fill_phase_container(phase: Global.GAME_PHASES):
	#Se não for a fase, só retorna
	if phase_number > phase:	
		return
	
	self.add_theme_stylebox_override("panel", PHASE_COMPLETED)
