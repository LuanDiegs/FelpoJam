extends Camera2D
class_name CameraPrincipal

@export var player: Player

func _ready() -> void:
	if player == null:
		player = get_tree().get_nodes_in_group("Player")[0] as Player
