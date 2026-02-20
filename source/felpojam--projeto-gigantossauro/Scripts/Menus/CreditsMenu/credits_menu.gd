extends Control

#Função que executa ao  pressionar o botão de voltar
func _on_return_button_pressed() -> void:
	#Volta ao menu principal
	Global.fade_to_scene(Global.start_menu, 1)
