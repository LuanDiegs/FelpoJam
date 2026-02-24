extends CanvasLayer


@onready var continue_button: Button = $MaginFather/PanelUI/MarginUI/VboxUI/MarginButtons/VboxButtons/ContinueButton
@onready var options_button: Button = $MaginFather/PanelUI/MarginUI/VboxUI/MarginButtons/VboxButtons/OptionsButton
@onready var return_to_menu_button: Button = $MaginFather/PanelUI/MarginUI/VboxUI/MarginButtons/VboxButtons/ReturnToMenuButton

func _ready() -> void:
	continue_button.pressed.connect(_continue_pressed)
	options_button.pressed.connect(_options_button)
	return_to_menu_button.pressed.connect(_return_to_menu_button)


func _continue_pressed():
	_reset_pause_menu()


func _options_button():
	self.hide()
	SettingsPauseMenu.show()
	pass
	
	
func _return_to_menu_button():
	_reset_pause_menu()
	Transition.change_to_scene(Global.start_menu)


func _reset_pause_menu():
	Global.paused = false
	Engine.time_scale = 1
	self.hide()
