@tool
extends BaseNpc
class_name StampNpc

#Label Key to click
@onready var key_to_click: Label = $StampLabel/Dick

#Npc stampStatus
var stamped: bool = false
@onready var stampSprite: Sprite2D = $StampLabel/Stamp

#Define a qual phase ele pertence
@export var npc_phase: int = 1

#Audio
@onready var stream_player: AudioStreamPlayer2D = $StreamPlayer
var stamp_sound_effects: Array[AudioStream] = [preload("uid://c6koct83gx0g8"), preload("uid://c6gd0o1dl3psc"), preload("uid://q1nqhkt1wj23"), preload("uid://cuuw7dpe27erp"), preload("uid://db7sssq16vimy"), preload("uid://b1m1lfpjiy7di")]

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
	key_to_click.text = interactKey
	
	#Ajustamos o label
	label.scale = Vector2.ZERO
	
	_connect_signals()
	_configure_label()
	
	#Nos npc que precisam ser carimbados o label sempre vai ser visibel
	_animate_label(true)


func _stamp_animation():
	var tweenStamp = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	stampSprite.visible = true
	tweenStamp.tween_property(stampSprite, "scale", stampSprite.scale + Vector2(0.1,0.1), 0.2)
	tweenStamp.tween_property(stampSprite, "scale", Vector2(0.1,0.1), 0.1)
	
	await tweenStamp.finished
	
	#Sound effect
	_stamp_sound_effect()


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


func _stamp_sound_effect():
	var sound_effect = stamp_sound_effects.pick_random()
	Global.play_sound_effect(stream_player, sound_effect)


func _update_sprite_viewport() -> void:
	if Engine.is_editor_hint():
		if sprite and texture:
			sprite.texture = texture
			sprite.flip_h = flip_h_sprite
