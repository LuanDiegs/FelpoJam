extends Control
class_name StartMenu

#Eunção que executa quando o botão das configs é presionado
func _on_settings_button_pressed() -> void:
	#Muda para a cena das opções
	get_tree().change_scene_to_packed(Global.settings_menu)


#Eunção que executa quando o botão de exit é presionado
func _on_exit_button_pressed() -> void:
	#Fecha o jogo
	get_tree().quit()


func _on_play_button_pressed() -> void:
	Transition.change_to_scene(Global.intermission_1)
	pass # Replace with function body.
