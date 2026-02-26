extends CharacterBody2D
class_name Player
#variaveis
var gravity = 1200

@export var speed: float = 1200
@export var acelleration: float = 800
@export var turn_acelleration: float = 1600
@export var friction: float = 1600
@export var jump_force: float = -900
var can_move_left := true
var can_move_right := true
var on_ceiling := false

var lifes = Global.player_lifes

@onready var ray_jumps = [$RayJump, $RayJump2, $RayJump3, $RayJump4, $RayJump5, $RayJump6, $RayJump7, $RayJump8, $RayJump9]

@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_ceiling: RayCast2D = $RayCelling

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

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite

signal life_changed(new_life)

#Função que roda ao iniciar onó/cena
func _ready() -> void:
	_set_and_save_player_collision_and_hurtbox()


func _set_and_save_player_collision_and_hurtbox():
	var col_shape = collision_shape.shape as RectangleShape2D
	#Seta e salva as propriedades do jogador
	if col_shape:
		if original_collision_width:
			col_shape.size.x = original_collision_width
		original_collision_width = col_shape.size.x
			
		if original_collision_height:
			col_shape.size.y = original_collision_height
		original_collision_height = col_shape.size.y
			
		if original_collision_pos:
			collision_shape.position = original_collision_pos
		original_collision_pos = collision_shape.position
		
	var hurt_shape = hurtbox_shape.shape as RectangleShape2D
	#Seta e salva as propriedades do jogador (Hurtbox)
	if hurt_shape:
		#Salva o largura do hurtbox
		if original_hurtbox_width:
			hurt_shape.size.x = original_hurtbox_width
		original_hurtbox_width = hurt_shape.size.x
		
		if original_hurtbox_height:
			hurt_shape.size.y = original_hurtbox_height
		original_hurtbox_height = hurt_shape.size.y
		
		if original_hurtbox_pos:
			hurtbox_shape.position = original_hurtbox_pos
		original_hurtbox_pos = hurtbox_shape.position

#Função que checa se está no chão
func in_floor() -> bool:
	#Retrona o valor de colisão do raycast
	return ray_jumps[0].is_colliding() or ray_jumps[1].is_colliding() or ray_jumps[2].is_colliding() or ray_jumps[3].is_colliding() or ray_jumps[4].is_colliding() or ray_jumps[5].is_colliding() or ray_jumps[6].is_colliding() or ray_jumps[7].is_colliding() or ray_jumps[8].is_colliding()

#função de tomar dano
func take_damage(amount: int):
	#Desincrementa a vida do player com base n o amount
	lifes -= amount
	#Emite o sinal d emudança de vida
	life_changed.emit(lifes)

#Função de processamento de fisica
func _physics_process(delta: float) -> void:
	if lifes <= 0:
		await get_tree().create_timer(1).timeout
		
		if get_tree():
			get_tree().reload_current_scene()
	
	#Checa se alguma direção está sendo aplicada
	_verify_direction(delta)
	
	# Move e verifica colisão
	var collision := move_and_collide(velocity * delta)
	_verify_if_colliding(collision)
	
	#Checa se está no chão
	_verify_if_on_floor(delta)
	
	#Verifica slide
	_verify_slide()

func _verify_direction(delta: float):
	# Atualiza permissões de movimento com base na colisão dos raycasts das direções de movimento
	can_move_left = not ray_left.is_colliding()
	can_move_right = not ray_right.is_colliding()
	on_ceiling = ray_ceiling.is_colliding()
	
	# Se estiver no teto, zera velocidade vertical
	if on_ceiling:
		velocity.y = 0
		velocity.y += gravity * delta
	
	#Salva o valor das teclas pressionadas, uma em valor negativo e outra em valor positivo
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0 and !Global.phase_finished:
		#Seta a animaçao
		animation_player.play("run")
		sprite.flip_h = direction == -1
		
		#Verifica se está tentando ir na direção oposta da velocidade atual, ou se está "parado"
		if sign(direction) == sign(velocity.x) or velocity.x == 0:
			#Continua com a aceleração normal
			velocity.x = move_toward(velocity.x, direction * speed, acelleration * delta)
		else: # caso contrario (esteja indo para a direção oposta da sua velocidade)
			#Usa a aceleração de virada
			velocity.x = move_toward(velocity.x, direction * speed, turn_acelleration * delta)
	else: # Caso o contratio (seja igual a 0, não tem uma direçãop)
		#Aplica a fricção
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func _verify_if_colliding(collision):
	#Checa se está colidindo com alguma coisa
	if collision:
		#Pega com quem está colidindo
		var collider = collision.get_collider()
		
		#Checa se o colisor está no grupo dos obstaculos se o colissor é um rigidbody
		if collider.is_in_group("Obstacles") and collider is RigidBody2D:
			#Pega o normal da colisão
			var normal = collision.get_normal()
			
			#Checa se o normal x é maior que o normal y
			if abs(normal.x) > abs(normal.y):
				#Pega a direção inversa do normal
				var push_dir = - normal
				
				#Aplica o empurrão
				collider.apply_central_impulse(push_dir * abs(velocity.x / 2.5))
			else: # caso contrario
				#Se o normal de y for maior que 0
				if normal.y > 0:
					#Aplica o empurrão
					collider.apply_central_impulse(Vector2(0, velocity.y * 5))

func _verify_if_on_floor(delta: float):
	if in_floor():
		#Salva a variavel mais alta (agora é null)
		var more_height_point = null
		
		#Cria um laço de repetição 
		for ray in ray_jumps:
			#Checa se tem um raycast e se ele está colidindo
			if ray and ray.is_colliding():
				#Salva o ponto de collisão do raycast
				var point = ray.get_collision_point()
				
				#Checa se o ponto de colião é igual a nulo ou menor que o ponto y do ponto y maior
				if more_height_point == null or point.y < more_height_point.y:
					#Seta o ponto como o maior ponto y
					more_height_point = point
		
		#Checa se o maior ponto é diferente de null e se a posição global y é maior que o maior ponto y
		if more_height_point != null and global_position.y > more_height_point.y:
			#Define a posição global y como o ponto y mais alto
			global_position.y = more_height_point.y
			
			#Zera a velocidade y
			velocity.y = 0
	else:
		velocity.y += gravity * delta

func _verify_slide():
	#Checa se a tecla de slide está sendo pressionada e se a velocidade x é maior que speed / 2.5
	if Input.is_action_pressed("slide") and abs(velocity.x) > (speed / 2):
		set_slide(true) # Faz o slide
	else: # Caso o contrario
		set_slide(false) # Não faz o slide

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
		else: # caso contrario
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
		else: # Caso contrario
			#Volta a hurtbox pro seu tamanho e posição original
			hurt_shape.size.x = original_hurtbox_width
			hurt_shape.size.y = original_hurtbox_height
			hurtbox_shape.position.y = original_hurtbox_pos.y
	
func _input(event: InputEvent) -> void:
	#Checa se o botão de pular foi pressionado
	if event.is_action_pressed("jump") and in_floor() and !Global.phase_finished:
		#Aplica a força do pulo
		velocity.y = jump_force

func _exit_tree() -> void:
	#Inserimos os valores originais
	#Para evitar que quando recarregue a cena ele estivesse deslizando e o shape ficaria do jeito "slide"
	_set_and_save_player_collision_and_hurtbox()
