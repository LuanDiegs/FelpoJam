extends Node2D
class_name BaseNpc

#Exports
@export var npc_name: String = "NPC"
@export var label: Node = null
@export var open_dialog_when_player_pass: bool = false

#Area
@onready var area_interativa: Area2D = $AreaInterativa

#Dialogo
var isPopUpOpen: bool = false

#Label
var inicialPositionLabel: Vector2

func _ready() -> void:
	_connect_signals()
	_configure_label()


func _reset_state_npc():
	await _animate_label(_player_is_in_area() and !open_dialog_when_player_pass)	
	isPopUpOpen = false
	

func _animate_label(labelVisible: bool):
	var tweenScale = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if labelVisible:	
		# Animamos a escala
		label.scale = Vector2.ZERO
		tweenScale.tween_property(label, "scale", Vector2(1, 1), 0.4)
	else:
		tweenScale.tween_property(label, "scale", Vector2.ZERO, 0.4)
		await tweenScale.finished
		return
		
	# Animamos a posicao do label
	var tweenPosicao = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tweenPosicao.tween_property(label, "position", inicialPositionLabel + Vector2(0, 15), 0.4)
	tweenPosicao.tween_property(label, "position", inicialPositionLabel, 0.4)
	
	tweenPosicao.set_loops()


func _connect_signals():
	pass


func _configure_label():
	inicialPositionLabel = label.position


func _on_body_entered_area_interativa(body: Node2D):
	if body.is_in_group("Player") and !open_dialog_when_player_pass:
		_animate_label(true)


func _on_body_exited_area_interativa(body: Node2D):
	if body.is_in_group("Player") and !open_dialog_when_player_pass:
		_animate_label(false)


func _player_is_in_area() -> bool:
	var overlapBodies = area_interativa.get_overlapping_bodies()
	
	return overlapBodies.any(func(body): return body is Player)
