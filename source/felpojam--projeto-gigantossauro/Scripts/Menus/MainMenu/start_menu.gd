extends Control
class_name StartMenu

#Eunção que executa quando o botão das configs é presionado
func _on_settings_button_pressed() -> void:
	#Muda para a cena das opções
	Global.fade_to_scene(Global.settings_menu, 1)

#Eunção que executa quando o botão de exit é presionado
func _on_exit_button_pressed() -> void:
	#Fecha o jogo
	get_tree().quit()

#Função que executa quando o botão de creditos é pressionado
func _on_credits_button_pressed() -> void:
	#Muda para a cena do menu de creditos
	Global.fade_to_scene(Global.credits_menu, 1)
