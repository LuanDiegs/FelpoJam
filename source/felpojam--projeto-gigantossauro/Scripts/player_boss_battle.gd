extends CharacterBody2D

#variaveis
var gravity = 1200

@export var speed : float = 2400
@export var acelleration : float = 400
@export var turn_acelleration : float = 1800
@export var friction : float = 1600
@export var jump_force : float = -800
@onready var ray_jump = $RayJump

@onready var collision_shape = $Collision
@onready var hurtbox = $Hurtbox
@onready var hurtbox_shape = $Hurtbox/Collision
var original_collision_height: float
var original_collision_width: float
var original_hurtbox_height: float
var original_hurtbox_width: float
var original_collision_pos: Vector2
var original_hurtbox_pos: Vector2
@export var slide_height_ratio := 0.5
@export var slide_width_ratio := 1.5

#Função que checa se está no chão
func in_floor() -> bool:
	#Retrona o valor de colisão do raycast
	return ray_jump.is_colliding()

func set_slide(sliding: bool):
	
	#Salva o formato  da colião um retangulo 2D
	var col_shape = collision_shape.shape as RectangleShape2D
	#Checa se é uma forma valida
	if col_shape:
		#Checa se sliding é verdadeiro
		if sliding:
			#define o tamanho da altura e largura com base no multiplicador de area
			col_shape.size.x = original_collision_width * slide_width_ratio
			col_shape.size.y = original_collision_height * slide_height_ratio
			#Desloca a colisão pra baixo para manter a base no chão
			collision_shape.position.y = original_collision_pos.y + (original_collision_height - col_shape.size.y) / 2.0
		else: #caso contrario
			#Volta a colisão pro seu tamanho e posição original
			col_shape.size.x = original_collision_width
			col_shape.size.y = original_collision_height
			collision_shape.position.y = original_collision_pos.y
	
	#Salva o formato da hurtbox como um retangulo 2D
	var hurt_shape = hurtbox_shape.shape as RectangleShape2D
	#Checa se é um formato valido
	if hurt_shape:
		#Checa se sliding é verdadeiro
		if sliding:
			#Define o tamanho da altura e largura com base no multiplicador da area
			hurt_shape.size.x = original_hurtbox_width * slide_width_ratio
			hurt_shape.size.y = original_hurtbox_height * slide_height_ratio
			#Desloca a colisão pra baixo para manter a base no chão
			hurtbox_shape.position.y = original_hurtbox_pos.y + (original_hurtbox_height - hurt_shape.size.y) / 2.0
		else: #Caso contrario
			#Volta a hurtbox pro seu tamanho e posição original
			hurt_shape.size.x = original_hurtbox_width
			hurt_shape.size.y = original_hurtbox_height
			hurtbox_shape.position.y = original_hurtbox_pos.y

#Função que roda ao iniciar onó/cena
func _ready() -> void:
	
	#Salva que o formato da colisão é um retangulo 2D
	var col_shape = collision_shape.shape as RectangleShape2D
	#Caso se é valido
	if col_shape:
		#Salva a largura da colisão
		original_collision_width = col_shape.size.x
		#Salva a altura da colisão
		original_collision_height = col_shape.size.y
		#Salva a posição da colisão
		original_collision_pos = collision_shape.position
	
	#Salva que o formato do hurtbox é um retangulo 2D
	var hurt_shape = hurtbox_shape.shape as RectangleShape2D
	#Checa se á valido
	if hurt_shape:
		#Salva o largura do hurtbox
		original_hurtbox_width = hurt_shape.size.x
		#Salva a altura do hurtbox
		original_hurtbox_height = hurt_shape.size.y
		#Salv a posição do hurtbox
		original_hurtbox_pos = hurtbox_shape.position

#Função de processamento de fisica
func _physics_process(delta: float) -> void:
	
	#checa se não está no chão
	if !in_floor():
		#Aplica a gravidade
		velocity.y += gravity * delta
	else: #caso contrario
		#Zera a velocidade y
		velocity.y = 0
	
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
	
	#checa se a tecla de slide está sendo pressionada e se a velocidade x é maior que speed / 2.5
	if Input.is_action_pressed("slide") and abs(velocity.x) > speed / 2.5 :
		set_slide(true) #Faz o slide
	else: #Caso o contrario
		set_slide(false) #Não faz o slide
	
	#Checa se o botão de pular foi pressionado
	if Input.is_action_just_pressed("jump") and in_floor():
		#Aplica a força do pulo
		velocity.y = jump_force
	
	#Aplica a vomimentação com base no velocity multiplicado pelo o delta
	move_and_collide(velocity * delta)
	#Arredonda a posição do objeto (evita travadinhas na movimentação)
	position = position.round()
