extends Node2D

#Variaveis
enum State { WALKING, ATTACK }

var actual_state := State.WALKING
var direction : int = 1
var attack_timer : float = 0
var can_instantiate : bool = true

@export var speed : float = 600
@export var left_limit : float = -200
@export var right_limit : float = 200
@export var attack_chance : float = 0.005 #Chance por frame
@export var attack_time : float = 1 #Segundos

var obstacle = preload("res://Cenas/Placeholders/obstacle_placeholder.tscn")


func init_attack():
	
	pass

func _process(delta: float) -> void:
	
	match actual_state:
		
		State.WALKING:
			
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
				actual_state = State.ATTACK
				attack_timer = attack_time
			
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
					
					actual_state = State.WALKING
					
	
	pass
