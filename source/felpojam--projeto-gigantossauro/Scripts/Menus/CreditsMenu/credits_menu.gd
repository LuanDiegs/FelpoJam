extends Control

#Função que executa ao  pressionar o botão de voltar
func _on_return_button_pressed() -> void:
	#Volta ao menu principal
	get_tree().change_scene_to_file(Global.start_menu)
