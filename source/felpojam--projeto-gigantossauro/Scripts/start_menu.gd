extends Control
class_name StartMenu

#Eunção que executa quando o botão das configs é presionado
func _on_settings_button_pressed() -> void:
	#Muda para a cena das opções
	get_tree().change_scene_to_file(Global.settings_menu)


#Eunção que executa quando o botão de exit é presionado
func _on_exit_button_pressed() -> void:
	#Fecha o jogo
	get_tree().quit()
