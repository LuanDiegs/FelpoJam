extends RigidBody2D

#Função de colisão da area 2D dele (Vai ser usada para fazer coisas com o player quando ele colidir)
func _on_area_body_entered(body: Node2D) -> void:
	
	   #Checa se o corpo que colidiu está no grupo "Player
	if body.is_in_group("Player"):
		pass #faz nada ainda	
