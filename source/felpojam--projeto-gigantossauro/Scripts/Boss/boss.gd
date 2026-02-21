extends Node2D

#Variaveis
enum State {WALKING, ATTACK, ATTACK2, ATTACK3, ATTACK4, ATTACK5}

var actual_state := State.WALKING
var direction : int = 1
var can_instantiate : bool = true
var boss_lifes: int = 5
var is_dead : bool = false

@export var speed : float = 600
@export var speed_running : float = 1200
@export var left_limit : float = -200
@export var right_limit : float = 200
@export var attack_chance : float = 0.005 #Chance por frame
@export var attack_timer : float = 1 #Segundos
@export var attack_time_transition : float = 1 #Segundos
@export var camera : Camera2D = null

var obstacle = preload("res://Cenas/Placeholders/obstacle_placeholder.tscn")
var bullet = preload("res://Cenas/Boss/boss_bullet.tscn")

signal boss_life_changed(new_life)
signal boss_is_dead

#Função de tomar dano
func take_damage():
	#Checa se a vida é maior que 0
	if boss_lifes > 0 and !is_dead:
		print("tomou")
		#Diminui a vida do boss
		boss_lifes -= 1
		#Emite o sinal de mudança de vida do boss
		boss_life_changed.emit(boss_lifes)
		#Removendo todos os obstaculos da cena
		get_tree().call_group("Obstacles", "queue_free")

#Função que executa o estado de caminhada
func execute_walking(vel, time, time_transition, chance, delta):
	#Attack_chance é igual a chance
	attack_chance = chance
	
	#Incrementa a posição no valor de speed com base na direção vezes o delta
	global_position.x += (direction * vel) * delta
	#arredonda a posição
	global_position.round()
	#Checa se a posição x é maior ou igual que o limite da direita
	if global_position.x >= right_limit:
		global_position.x = right_limit #Limita a posição x no limite da direita
		direction = -1 #Alterna a direção (vai pra esquerda)
	#Checa se a posição x é menor ou igual que o limite da esquerda
	elif global_position.x <= left_limit:
		global_position.x = left_limit #Limita a posição x no limite da esquerda
		direction = 1 #Altera a direção (vai pra direita)
	#Checa um valor flutuativo aleatorio de 0 a 1 a todo frame
	if randf() < attack_chance:
		can_instantiate = true #define que pode instanciar
		if boss_lifes > 3:
			actual_state = [State.ATTACK, State.ATTACK2].pick_random() #Pega aleatoriamente um desses estados
		else: #caso contrario
			actual_state = [State.ATTACK, State.ATTACK3, State.ATTACK, State.ATTACK4, State.ATTACK, State.ATTACK5, State.ATTACK].pick_random() #Pega aleatoriamente um desses estados
		attack_timer = time #SEta o timer do ataque para 1 segundo
		attack_time_transition = time_transition #Seta o timer de espera para a transição deestado depois do ataque para 1 segundo

#Função de spawndar obstaculos
func spawn_obstacles():
	
	#Intancia o obstaculo
	var instance = obstacle.instantiate()
	#Pega a camada onde se deve criar o objeto
	var layer = get_parent()
	#Define a posição inicial da instancia na posição x e y atual
	instance.global_position = Vector2(position.x, position.y - 128)
	#Adiciona a intancia na layr correta
	layer.add_child(instance)

func spawn_bullet(dir):
	
	#Instancia o tiro
	var instance = bullet.instantiate()
	#Salva em qual layer deve ser instanciada
	var layer = get_parent()
	#Define a posição inicial do tito
	instance.global_position = global_position
	#Define a direção com base na posição do player
	instance.direction = dir
	#Adiciona a instancia na camada correta
	layer.add_child(instance)

#Função para spawnar varias bullts de uma vez
func spawn_multiply_bullets(quantity : int, dir):
	
	#Distancia minima entre eles
	var min_distance = 48
	#Lista para amarzenar as posições x já sorteadas
	var used_x = []
	#Cria um loop que roda 3 vezes o codigo
	for i in range(quantity):
		#numero de temtativas
		var attemps = 0
		#maximo de tentativas (evitar loops infinitos)
		var max_attemps = 100
		#Valor x que será escolhido
		var new_x : float 
		#Flag de indicação se conseguiu um valor valido
		var valid := false 
		#Tanta sortear um x que respeite a distancia minimaem relaçãoa todos os outros
		#x já usados
		while !valid and attemps < max_attemps:
			#Sorteia um valor x dentro dos limites pré-estabelecidos
			new_x = randf_range(left_limit, right_limit)
			#Assume que a posiçãoé valida (por enquanto)
			valid = true
			#Corre por todas as posições já usadas
			for x in used_x:
				#Calcula a distancia absoluta ente o novo x e o x já usado
				if abs(new_x - x) < min_distance:
					#Não é valida se for menor que a distancia minima
					valid = false
					break #interrompe a verificação
			#Incrementa o contador de tentativas
			attemps += 1
		#Caso não seja valido
		if !valid:
			#Define um novo x com base em um espaçamento proporcional da largura total
			#Coloca os projeteis em uma largura ok (mas ainda pode haver erros)
			new_x = left_limit + (right_limit - left_limit) * (i / 2)
		#Adiciona o x escolhida na lista de posições usadas
		used_x.append(new_x)
		#Instancia o obstaculo
		var instance = bullet.instantiate()
		#Pega a camada onde se deve criar o objeto
		var layer = get_parent()
		#Define um y inicial para o item instanciado
		var initial_y
		if camera != null: #Caso camera não for null
			#pega o y da camera e diminui 128 ouxeks
			initial_y = camera.global_position.y - 128 
		else: #Caso contrario (seja null, não tenha uma camera)
			initial_y = -843 #0 y inicial é -843
			#Printa no debug
			print("Camera não encontrada")
		#Define a posição inicial da instancia no eixo x e y
		instance.global_position = Vector2(new_x, initial_y)
		#Define a direção para baixo
		instance.direction = dir
		#Adiciona a intancia na layr correta
		layer.add_child(instance)

#Função de transição do ataque
func attack_transition(delta):
	#Diminui o timer de transição do ataque
	attack_time_transition -= delta
	#Checa se o timer de ataque é menor ou igual a zero
	if attack_time_transition <= 0:
		#Mudando para o estado de andando
		actual_state = State.WALKING

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
					#Spawna os obstaculos
					spawn_obstacles()
					#Define que não pode mais instanciar
					can_instantiate = false
				else: #Caso não possa
					#Executa a trasinção do ataque
					attack_transition(delta)
		
		#Se o valor de stt for state.attack2
		State.ATTACK2:
			#Diminui o timer pro ataque
			attack_timer -= delta
			#Checa se o timer do ataque é igual ou menor que 0
			if attack_timer <= 0:
				#Checa se pode instanciar
				if can_instantiate:
					#Spawna de 1 a 3 balas
					spawn_multiply_bullets(randi_range(1, 3), Vector2.DOWN)
					#Define que não pode mais instanciar
					can_instantiate = false
				#Caso não possa
				else:
					#executa a transição do ataque
					attack_transition(delta)
		#Se o valor de stt for state.attack3
		State.ATTACK3:
			#Diminui o timer pro ataque
			attack_timer -= delta
			#Pega o player
			var player = get_tree().get_first_node_in_group("Player")
			#Pega a posição do player (antes de parar para atacar, pra dar tempo do player fugir)
			var player_position = player.global_position
			#Checa se o timer é menor ou igual a0
			if attack_timer <= 0:
				#Checa se pode instanciar
				if can_instantiate:
					#Spawna uma bala que vai em direção ao player
					spawn_bullet((player.global_position - global_position).normalized())
					#Diz que não pode mais instanciar
					can_instantiate = false
				else: #caso contrario
					#Executa a transição do ataque
					attack_transition(delta)
		#Se o valor de stt for state.attack4
		State.ATTACK4:
			#Diminui o timer pro ataque
			attack_timer -= delta
			#Checa se o timer é menor ou igual a0
			if attack_timer <= 0:
				#Checa se pode instanciar
				if can_instantiate:
					##Spawna de 3 a 6 balas
					spawn_multiply_bullets(randi_range(3, 6), Vector2.DOWN)
					#Diz que não pode mais instanciar
					can_instantiate = false
				else: #caso contrario
					#Executa a transição do ataque
					attack_transition(delta)
		
		#Se o valor de stt for state.attack3
		State.ATTACK5:
			#Diminui o timer pro ataque
			attack_timer -= delta
			#Pega o player
			var player = get_tree().get_first_node_in_group("Player")
			#Pega a posição do player (antes de parar para atacar, pra dar tempo do player fugir)
			var player_position = player.global_position
			#Checa se o timer é menor ou igual a0
			if attack_timer <= 0:
				#Checa se pode instanciar
				if can_instantiate:
					#Spawna de 1 a 3 balas
					spawn_multiply_bullets(randi_range(1, 3), Vector2.DOWN)
					#Spawna uma bala que vai em direção ao player
					spawn_bullet((player.global_position - global_position).normalized())
					#Diz que não pode mais instanciar
					can_instantiate = false
				else: #caso contrario
					#Executa a transição do ataque
					attack_transition(delta)


func _ready() -> void:
	
	await get_tree().create_timer(2).timeout
	
	take_damage()

#função de pprocessamento a cada quadro
func _process(delta: float) -> void:
	
	#Checa se a vida é maior a 2
	if boss_lifes > 3:
		#Verifica se o actual_state tem um valor especifico
		match actual_state:	
			#Se o valor de actual_state for state.walking
			State.WALKING:
				#Executa a função da caminhada
				execute_walking(speed, 1, 1, 0.005, delta)
			
			#Se o valor de actual_state for state.attack
			State.ATTACK:
				#xecuta a função de ataque (ataque 1)
				execute_attack(actual_state, delta)
			
			#Se o valor de actual_state for state.attack2
			State.ATTACK2:
				#xecuta a função de ataque (ataque 2)
				execute_attack(actual_state, delta)
	#Caso o contrario (a vida é igual o menor que 2)
	elif boss_lifes >= 1:
		
		match actual_state:
			
			#Se o valor de actual_state for state.walkin
			State.WALKING:
				#Executa a função da caminhada
				execute_walking(speed_running, .5, 1, 0.010, delta)
			
			#Se o valor de actual_state for state.attack
			State.ATTACK:
				#xecuta a função de ataque (ataque 1)
				execute_attack(actual_state, delta)
			
			#Se o valor de actual_state for state.attack3
			State.ATTACK3:
				#xecuta a função de ataque (ataque 3)
				execute_attack(actual_state, delta)
			
			#Se o valor de actual_state for state.attack4
			State.ATTACK4:
				#xecuta a função de ataque (ataque 4)
				execute_attack(actual_state, delta)
			
			#Se o valor de actual_state for state.attack5
			State.ATTACK5:
				#xecuta a função de ataque (ataque 5)
				execute_attack(actual_state, delta)
	#Caso seja 0
	else:
		#Checa se is_dead é falso
		if !is_dead:
			#Emite o sinal que morreu
			boss_is_dead.emit()
			#Is_dead é verdadeiro (morreu)
			is_dead = true

#Função que checa a entrade de corpos no hurtbox
func _on_hurtbox_body_entered(body: Node2D) -> void:
	#Checa se o corpor está no grupo de obstaculos e é um rigid body
	if body.is_in_group("Obstacles") and body is RigidBody2D:
		
		#Checa se a velocidade linear y é maior que 0
		if body.linear_velocity.y > 0:
			#Executa a função de tomar dano
			take_damage()
