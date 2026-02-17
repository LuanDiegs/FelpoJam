extends CharacterBody2D

#variaveis
@export var speed : float = 600
@export var acelleration : float = 400
@export var turn_acelleration : float = 1600
@export var friction : float = 1600

#Função de processamento de fisica
func _physics_process(delta: float) -> void:
	
	#Salva o valor das teclas pressionadas, uma em valor negativo e outra em valor positivo
	var direction = Input.get_axis("move_left", "move_right")
	#Checa se alguma direçãoestá sendo aplicada
	if direction != 0:
		
		#Verifica se está tentando ir na direção oposta da velocidade atual, ou se está "parado"
		if sign(direction) == sign(velocity.x) or velocity.x == 0:
			#Continua com a aceleração normal
			velocity.x = move_toward(velocity.x, direction * speed, acelleration * delta)
		else: #caso contrario (esteja indo para a direção oposta da sua velocidade)
			#Usa a aceleração de virada
			velocity.x = move_toward(velocity.x, direction * speed, turn_acelleration * delta)
		
	else: #Caso o contratio (seja igual a 0, não tem uma direçãop)
		#Aplica a fricção
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	#Aplica a vomimentação com base no velocity multiplicado pelo o delta
	move_and_collide(velocity * delta)
	#Arredonda a posição do objeto (evita travadinhas na movimentação)
	position = position.round()
