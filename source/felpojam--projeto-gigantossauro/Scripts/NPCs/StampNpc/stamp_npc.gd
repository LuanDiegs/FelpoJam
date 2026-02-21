extends BaseNpc
class_name StampNpc

#Label Key to click
@onready var key_to_click: Label = $StampLabel/Dick

#Npc stampStatus
var stamped: bool = false
@onready var stampSprite: Sprite2D = $StampLabel/Stamp


func _ready() -> void:
	# Pegamos a tecla que faz a açao de interaçao
	var interactKey = Global.get_action_key("interact")
	
	#Colocamos a tecla no texto e deixamos o label com escala 0
	key_to_click.text = interactKey
	
	#Ajustamos o label
	label.scale = Vector2.ZERO
	
	_connect_signals()
	_configure_label()
	
	#Nos npc que precisam ser carimbados o label sempre vai ser visibel
	_animate_label(true)


func _stamp_animation():
	var tweenStamp = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	stampSprite.visible = true
	tweenStamp.tween_property(stampSprite, "scale", stampSprite.scale + Vector2(1,1), 0.2)
	tweenStamp.tween_property(stampSprite, "scale", Vector2(1,1), 0.1)
	
	await tweenStamp.finished


func _npc_go_away_animation():
	var direction = -1 if randf() < 0.5 else 1
	
	#Tween do movimento
	var tweenNpc = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tweenNpc.tween_property(self, "position", self.position + Vector2((self.position.x + 10000) * direction, 0), 0.5)
	await tweenNpc.finished
	
	#Tween da scala
	var tweenScale = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tweenScale.tween_property(self, "scale", Vector2.ZERO, 0.5)
	await tweenScale.finished
	
	queue_free()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	# Se apertou o botao de interagir e um dos corpos em volta é um jogador, habilita o dialogo
	if event.is_action_pressed("interact") and _player_is_in_area() and !stamped:
		#Emite o signal de carimbado
		Global.NpcStamped.emit()
		
		#Controle de animaçoes		
		stamped = true
		await _stamp_animation()
		_animate_label(false)
		await _npc_go_away_animation()
