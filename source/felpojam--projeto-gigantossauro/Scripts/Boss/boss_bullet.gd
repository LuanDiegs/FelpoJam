extends Area2D

#variaveis
var speed = 1200
var direction = Vector2.RIGHT

#Função que roda a cada frame
func _physics_process(delta: float) -> void:
	#Incrementa posição com base na direção vezes a velocidade vezes delta
	global_position += (direction * speed) * delta
	#Rotaciona para a direção que está indo
	rotation = direction.angle()
	#Checa se o y é maior ou igual que 1080
	if global_position.y >= 1080:
		#Apaga da memoria
		queue_free()

#Checa se um corpo entro em colisão
func _on_body_entered(_body: Node2D) -> void:
	#Apaga da memoria
	queue_free()

#Checa se uma area 2D entrou na colisão
func _on_area_entered(area: Area2D) -> void:
	#Pega o corpo dessa area
	var body = area.get_parent()
	#Checa se o corpo está no grupo player e tem o metodo take_damage
	if body.is_in_group("Player") and body.has_method("take_damage"):
			#Executa o metodo take_damage
			body.take_damage(1)
			#Limpa da memoria
			queue_free()
