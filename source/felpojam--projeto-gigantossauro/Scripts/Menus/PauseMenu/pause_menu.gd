extends CanvasLayer

@export var continue_button: Button
@export var options_button: Button
@export var return_to_menu_button: Button

var settings_pause_menu: Node = null

func _ready() -> void:
	continue_button.pressed.connect(_continue_pressed)
	options_button.pressed.connect(_options_button)
	return_to_menu_button.pressed.connect(_return_to_menu_button)
	

func pause_despause():
	#Se a fase terminou, nao pausamos
	if Global.phase_finished: 
		return
		
	# Só funciona em LevelBase e BaseLevelBoss
	if not get_tree().current_scene is LevelBase and not get_tree().current_scene is BaseLevelBoss:
		return
	
	#Se existir as settings, deletamos ela
	if settings_pause_menu != null:
		settings_pause_menu.queue_free()
		
		
	get_tree().paused = !get_tree().paused
	
	# Mostra ou esconde
	visible = get_tree().paused


func open_setting_menu():
	self.hide()
	settings_pause_menu = (preload(Global.settings_pause_menu)).instantiate()
	
	#Inserimos o filho
	settings_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(settings_pause_menu)
	
	
func close_setting_menu():
	self.show()
	settings_pause_menu.queue_free()
	
	
func _continue_pressed():
	_reset_pause_menu()


func _options_button():
	open_setting_menu()
	
	
func _return_to_menu_button():
	_reset_pause_menu()
	Transition.change_to_scene(Global.start_menu)


func _reset_pause_menu():
	get_tree().paused = false
	self.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_despause()
