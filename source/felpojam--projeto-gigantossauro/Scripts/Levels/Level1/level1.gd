extends Node2D
class_name Leve1

@onready var spawn_npc_spawner: Timer = $SpawnNpcSpawner
@onready var chao_collision: CollisionShape2D = $Chao/ChaoCollision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spawn_npc_spawner.timeout.connect(_spawn_npc)
	pass # Replace with function body.


func _spawn_npc():
	var npc = (preload("res://Cenas/NPCs/StampNpc/stamp_npc.tscn")).instantiate() as StampNpc
	var player = get_tree().get_nodes_in_group("Player")[0] as Player
	
	# Direcao do spawn (direita, esquerda)
	var direction_spawn = true if randf() < 0.5 else false
	
	var offset_min = 1000
	var offset_max = 1500
	
	# Minimo 750 de distancia do jogador
	# Maximo 1500 de distancia do jogador
	var min_distance_player = player.global_position.x + offset_min if direction_spawn else player.global_position.x - offset_min
	var max_distance_player = player.global_position.x + offset_max if direction_spawn else player.global_position.x - offset_max
	var spawn_area_gap = randi_range(min_distance_player, max_distance_player)
	var x_position_npc =  spawn_area_gap
	
	# Se for negativo, colocamos como positivo
	if x_position_npc < 0:
		x_position_npc = x_position_npc * -1
	
	npc.position = Vector2(x_position_npc, Global.NPC_Spawn_y)
	
	add_child(npc)
