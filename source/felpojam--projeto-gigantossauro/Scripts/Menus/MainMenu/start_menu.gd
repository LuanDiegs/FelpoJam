extends Control
class_name StartMenu

#Eunção que executa quando o botão das configs é presionado
func _on_settings_button_pressed() -> void:
	#Muda para a cena das opções
	Transition.change_to_scene(Global.settings_menu)


#Função que executa quando o botão de exit é presionado
func _on_exit_button_pressed() -> void:
	#Fecha o jogo
	get_tree().quit()

#Função que executa quando o botão de creditos é pressionado
func _on_credits_button_pressed() -> void:
	#Muda para a cena do menu de creditos
	Transition.change_to_scene(Global.credits_menu)


func _on_play_button_pressed() -> void:
	Transition.change_to_scene(Global.intermission_1)
