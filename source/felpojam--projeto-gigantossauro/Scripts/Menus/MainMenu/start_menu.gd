extends Control
class_name StartMenu

@onready var node_character: Node2D = $Boneco
var _initial_position_character: Vector2
var _final_position_character: Vector2 = Vector2(320.0, 364.0)

@onready var buttons_container: MarginContainer = $MarginButtons
@onready var panel_press_button: PanelContainer = $PanelPressButton
var is_start_menu: bool = false

func _ready() -> void:
	buttons_container.visible = false
	_initial_position_character = node_character.global_position
	
	#Inicia a musica
	MusicManager.trocar_musica("main_menu")
	
	#Falamos que a fase nao terminou
	Global.phase_finished = false


func _animate_start_(start_menu: bool):
	var tween_position = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var position_character = _final_position_character if start_menu else _initial_position_character
	tween_position.tween_property(node_character, "global_position", position_character, 1)	
	
	var tween_modulate_label_press_button = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var modulate_panel = 0 if start_menu else 1
	tween_modulate_label_press_button.tween_property(panel_press_button, "modulate:a", modulate_panel, 1)
	
	var tween_modulate_buttons_container = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)	
	if start_menu:	
		buttons_container.visible = start_menu
		tween_modulate_buttons_container.tween_property(buttons_container, "modulate:a", 1, 1)
	else:
		tween_modulate_buttons_container.tween_property(buttons_container, "modulate:a", 0, 1)
		await tween_modulate_buttons_container.finished
		buttons_container.visible = start_menu
	
	is_start_menu = start_menu
	

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


func _input(event: InputEvent) -> void:
	if ((event is InputEventKey and event.is_pressed() and !event.is_action_pressed("ui_cancel")) \
	or event is InputEventMouseButton) and !is_start_menu :
		_animate_start_(true)
	
	if event.is_action_pressed("ui_cancel") and is_start_menu:
		_animate_start_(false)
