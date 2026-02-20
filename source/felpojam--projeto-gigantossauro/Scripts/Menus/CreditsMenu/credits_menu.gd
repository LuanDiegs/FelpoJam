extends Control

@onready var return_to_menu_button: Button = $ReturnToMenuButton

func _ready() -> void:
	return_to_menu_button.pressed.connect(_on_return_to_menu_button_pressed)
	
	
#Função que executa ao  pressionar o botão de voltar
func _on_return_to_menu_button_pressed() -> void:
	#Volta ao menu principal
	get_tree().change_scene_to_file(Global.start_menu)
