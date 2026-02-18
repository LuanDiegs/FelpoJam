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

func execute_walking(delta):
	
	position.x += (direction * speed) * delta

	position.round()

	if position.x >= right_limit:
		position.x = right_limit
		direction = -1
	elif position.x <= left_limit:
		position.x = left_limit
		direction = 1

	if randf() < attack_chance:
		can_instantiate = true
		actual_state = [State.ATTACK, State.ATTACK2].pick_random()
		attack_timer = 1
		attack_time_transition = 1

func execute_attack(stt, delta):
	
	match stt:
		
		State.ATTACK:
			
			attack_timer -= delta
			if attack_timer <= 0:
				
				var instance = obstacle.instantiate()
				
				if can_instantiate:
					var layer = get_parent()
					instance.position = Vector2(position.x, position.y)
					layer.add_child(instance)
					can_instantiate = false
				else:
					
					attack_time_transition -= delta
					if attack_time_transition <= 0:
						actual_state = State.WALKING
		
		State.ATTACK2:
			
			attack_timer -= delta
			
			if attack_timer <= 0:
				
				if can_instantiate:
					
					for i in range(3):
						
						var instance = obstacle.instantiate()
						var layer = get_parent()
						var max_limit = camera.global_position.y - 128
						var min_limit = randf_range(left_limit, right_limit)
						instance.position = Vector2(min_limit, max_limit)
						layer.add_child(instance)
					
					can_instantiate = false
					
				else:
					
					attack_time_transition -= delta
					if attack_time_transition <= 0:
						actual_state = State.WALKING

#função de pprocessamento a cada quadro
func _process(delta: float) -> void:
	
	if boss_life > 2:
		
		match actual_state:
			
			State.WALKING:
				
				execute_walking(delta)
				
			State.ATTACK:
				
				execute_attack(actual_state, delta)
				
			State.ATTACK2:
				
				execute_attack(actual_state, delta)
			
	else:
		
		pass
	
	pass
