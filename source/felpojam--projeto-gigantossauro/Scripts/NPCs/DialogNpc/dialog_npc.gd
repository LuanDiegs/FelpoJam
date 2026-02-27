@tool
extends BaseNpc
class_name DialogNpc

#Label
@onready var interactive_label: Label = $InteractiveLabel
var interactive_text: String = "Pressione '%s' para interagir"

#Sprite
@export var flip_h_sprite: bool = false:
	set(value):
		flip_h_sprite = value
		_update_sprite_viewport()
@export var texture: Texture2D = null:
	set(value):
		texture = value
		_update_sprite_viewport()
@onready var sprite: Sprite2D = $Sprite
	
	
func _ready() -> void:
	#Tool
	_update_sprite_viewport()
	if not Engine.is_editor_hint():
		if sprite:
			sprite.texture = texture if texture != null else sprite.texture
			sprite.flip_h = flip_h_sprite
	else:
		return
		
	# Pegamos a tecla que faz a açao de interaçao
	var interactKey = Global.get_action_key("interact")
	
	#Colocamos a tecla no texto e deixamos o label com escala 0
	interactive_label.text = interactive_text % interactKey
	interactive_label.scale = Vector2.ZERO
	
	_connect_signals()
	_configure_label()
	
	#Signals proprios
	Global.DialogClosed.connect(_reset_state_npc)
	area_interativa.body_entered.connect(_on_body_entered_area_interativa)
	area_interativa.body_exited.connect(_on_body_exited_area_interativa)


func _open_dialog_npc():
	Global.DialogOpen.emit(self, GameProgress.current_world, npc_name)
	isPopUpOpen = true
	_animate_label(false)


func _on_body_entered_area_interativa(body: Node2D):
	if body.is_in_group("Player"):
		if !open_dialog_when_player_pass:
			_animate_label(true)
		else:
			_open_dialog_npc()
		

func _on_body_exited_area_interativa(body: Node2D):
	if body.is_in_group("Player"):
		if !open_dialog_when_player_pass:
			_animate_label(false)
		
		Global.DialogClosed.emit()


func _update_sprite_viewport() -> void:
	if Engine.is_editor_hint():
		if sprite and texture:
			sprite.texture = texture
			
			
func _input(event: InputEvent) -> void:
	# Se apertou o botao de interagir e um dos corpos em volta é um jogador, habilita o dialogo
	if event.is_action_pressed("interact") and _player_is_in_area() and !isPopUpOpen and !open_dialog_when_player_pass:
		_open_dialog_npc()
