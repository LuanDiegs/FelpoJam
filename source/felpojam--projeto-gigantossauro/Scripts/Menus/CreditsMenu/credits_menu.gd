extends Control

@onready var return_to_menu_button: Button = $ReturnToMenuButton

func _ready() -> void:
	return_to_menu_button.pressed.connect(_on_return_to_menu_button_pressed)
	
	
func _on_return_to_menu_button_pressed() -> void:
	#Volta ao menu principal
	Transition.change_to_scene(Global.start_menu)
