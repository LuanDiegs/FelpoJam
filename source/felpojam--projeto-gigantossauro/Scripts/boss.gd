extends Node2D

#Variaveis
enum State { WALKING, ATTACK, ATTACK2 }

var actual_state := State.WALKING
var direction : int = 1
var attack_timer : float = 0
var can_instantiate : bool = true

var boss_life: int = 5

@export var speed : float = 600
@export var left_limit : float = -200
@export var right_limit : float = 200
@export var attack_chance : float = 0.005 #Chance por frame
@export var attack_time : float = 1 #Segundos
@export var attack_time_transition : float = 1 #Segundos
@export var camera : Camera2D

var obstacle = preload("res://Cenas/Placeholders/obstacle_placeholder.tscn")
var bullets = null

#Função que executa o estado de caminhada
func execute_walking(delta):
	
	#Incrementa a posição no valor de speed com base na direção vezes o delta
	position.x += (direction * speed) * delta
	#arredonda a posição
	position.round()
	#Checa se a posição x é maior ou igual que o limite da direita
	if position.x >= right_limit:
		position.x = right_limit #Limita a posição x no limite da direita
		direction = -1 #Alterna a direção (vai pra esquerda)
	#Checa se a posição x é menor ou igual que o limite da esquerda
	elif position.x <= left_limit:
		position.x = left_limit #Limita a posição x no limite da esquerda
		direction = 1 #Altera a direção (vai pra direita)
	
	#Checa um valor flutuativo aleatorio de 0 a 1 a todo frame
	if randf() < attack_chance:
		can_instantiate = true #define que pode instanciar
		actual_state = [State.ATTACK, State.ATTACK2].pick_random() #Pega aleatoriamente um desses estados
		attack_timer = 1 #SEta o timer do ataque para 1 segundo
		attack_time_transition = 1 #Seta o timer de espera para a transição deestado depois do ataque para 1 segundo

#Função que executa os ataques
func execute_attack(stt, delta):
	
	#Verifica se o stt tem um valor especifico
	match stt:
		
		#Se o valor de stt for state.attack
		State.ATTACK:
			#Diminui o timer pro ataque
			attack_timer -= delta
			#Se o timer for menor ou igual a 0
			if attack_timer <= 0:
				#Checa se pode instanciar
				if can_instantiate:
					#Intancia o obstaculo
					var instance = obstacle.instantiate()
					#Pega a camada onde se deve criar o objeto
					var layer = get_parent()
					#Define a posição inicial da instancia na posição x e y atual
					instance.position = Vector2(position.x, position.y)
					#Adiciona a intancia na layr correta
					layer.add_child(instance)
					#Define que não pode mais instanciar
					can_instantiate = false
				else: #Caso não possa
					#Diminui o timer de transição do ataque
					attack_time_transition -= delta
					#Checa se o timer de ataque é menor ou igual a zero
					if attack_time_transition <= 0:
						#Mudando para o estado de andando
						actual_state = State.WALKING
		
		#Se o valor de stt for state.attack2
		State.ATTACK2:
			#Diminui o timer pro ataque
			attack_timer -= delta
			#Checa se o timer do ataque é igual ou menor que 0
			if attack_timer <= 0:
				#Checa se pode instanciar
				if can_instantiate:
					#Cria um loop que roda 3 vezes o codigo
					for i in range(3):
						#Instancia o obstaculo
						var instance = obstacle.instantiate()
						#Pega a camada onde se deve criar o objeto
						var layer = get_parent()
						#Define um y inicial para o intem instanciado
						var initial_y = camera.global_position.y - 128
						#Define uma posição aleatoria enteo limite esquerdo e direito
						var min_limit = randf_range(left_limit, initial_y)
						#Define a posição inicial da instancia no eixo x e y
						instance.position = Vector2(min_limit, initial_y)
						#Adiciona a intancia na layr correta
						layer.add_child(instance)
					#Define que não pode mais instanciar
					can_instantiate = false
				#Caso não possa
				else:
					#Diminui o timer de transição do ataque
					attack_time_transition -= delta
					#Checa se o timer de ataque é menor ou igual a zero
					if attack_time_transition <= 0:
						#Mudando para o estado de andando
						actual_state = State.WALKING

#função de pprocessamento a cada quadro
func _process(delta: float) -> void:
	
	#Checa se a vida é maior a 2
	if boss_life > 2:
		#Verifica se o actual_state tem um valor especifico
		match actual_state:	
			#Se o valor de actual_state for state.walking
			State.WALKING:
				#Executa a função da caminhada
				execute_walking(delta)
			
			#Se o valor de actual_state for state.attack
			State.ATTACK:
				#xecuta a função de ataque (ataque 1)
				execute_attack(actual_state, delta)
			
			#Se o valor de actual_state for state.attack2
			State.ATTACK2:
				#xecuta a função de ataque (ataque 2)
				execute_attack(actual_state, delta)
				
	
	#Caso o contrario (a vida é igual o menor que 2)
	else:
		pass #ainda não faz nada
