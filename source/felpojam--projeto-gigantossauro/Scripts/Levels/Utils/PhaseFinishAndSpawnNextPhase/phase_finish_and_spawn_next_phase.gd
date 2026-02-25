extends Node2D
class_name PhaseFinishAndSpawnNextPhase

@export var player: Player = null
@export var stamp_npcs_count: StampsLeftUI = null

@onready var phase_finish_area: Area2D = $PhaseFinishArea
@onready var spawn_next_phase: Area2D = $SpawnNextPhase
@onready var panel_warning: Panel = $PanelWarning
@onready var label_warning: Label = $PanelWarning/LabelWarning

func _ready() -> void:
	phase_finish_area.body_entered.connect(_on_body_entered_finish_area)
	phase_finish_area.body_exited.connect(_on_body_exited_finish_area)


func _animate_panel(panel_visible: bool):
	#Creamos o tween
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	if panel_visible:
		panel_warning.visible = panel_visible
		tween.tween_property(panel_warning, "scale", Vector2(1.2, 1.2), 0.2).from(Vector2.ZERO)
		tween.tween_property(panel_warning, "scale", Vector2.ONE, 0.2)
	else:
		tween.tween_property(panel_warning, "scale", Vector2(1.2, 1.2), 0.2).from(Vector2.ONE)
		tween.tween_property(panel_warning, "scale", Vector2.ZERO, 0.2)
		await tween.finished
		panel_warning.visible = panel_visible


func _on_body_entered_finish_area(body: Node):
	_animate_panel(true)
	
	# Pegamos a tecla que faz a açao de interaçao
	var interactKey = Global.get_action_key("interact")

	var all_npc_stamped := stamp_npcs_count.all_npc_stamped
	var stamps_left := stamp_npcs_count.stamps_left
	var message := "Clique no botão '%s' para continuar" % interactKey if all_npc_stamped \
		else "Faltam %s carimbo(s) para você carimbar, corre!" % stamps_left
	
	#Colocamos a mensagem
	if body is Player:
		label_warning.text = message
		
		
func _on_body_exited_finish_area(_body: Node):
	_animate_panel(false)


func _input(event: InputEvent) -> void:
	var all_npc_stamped := stamp_npcs_count.all_npc_stamped
	var player_in_area := _player_is_in_area()
	
	#Se carimbou todos, o jogador estiver na area e pressionar o botao, ira teleportar
	if event.is_action_pressed("interact") and player_in_area and all_npc_stamped:
		print("oiaaa")
		player.global_position = spawn_next_phase.global_position


func _player_is_in_area() -> bool:
	var overlapBodies = phase_finish_area.get_overlapping_bodies()

	return overlapBodies.any(func(body): return body is Player)
