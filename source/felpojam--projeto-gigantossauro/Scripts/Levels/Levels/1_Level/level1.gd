extends LevelBase
class_name Level

func _ready() -> void:
	var current_scene = get_tree().current_scene.name
	if current_scene == "Level 1 - Phase 1":
		MusicManager.trocar_musica("level1", 2)
	elif current_scene == "Level 2 - Phase 1":
		MusicManager.trocar_musica("level2", 1)
	elif current_scene == "Level 3 - Phase 1":
		MusicManager.trocar_musica("level3", 1)
