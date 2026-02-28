@tool
extends RigidBody2D
class_name Obstacle

@export var sprite: Texture2D = null:
	set(value):
		sprite = value
		_update_sprite_viewport()

@export var collision_shape: Shape2D = null:
	set(value):
		collision_shape = value
		_update_sprite_viewport()
@export var object_mass: float = 1.0

@onready var texture: Sprite2D = $Texture
@onready var collision: CollisionShape2D = $Collision


func _ready() -> void:
	_update_sprite_viewport()
	
	if not Engine.is_editor_hint():
		if mass:
			self.mass = object_mass
		
		if sprite:
			texture.texture = sprite
		
		if collision_shape:
			collision.shape = collision_shape
	
	
#função que roda a todo frame
func  _process(_delta: float) -> void:
	#Checa se a posição global y é maior que 1280
	if global_position.y > 1280:
		queue_free()


func _update_sprite_viewport() -> void:
	if Engine.is_editor_hint():
		if sprite and texture:
			texture.texture = sprite
		if collision_shape and collision:
			collision.shape = collision_shape
