extends Sprite2D

var inicial_scale: Vector2

func _ready() -> void:
	inicial_scale = scale
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.set_loops()
	
	tween.tween_property(self, "scale", inicial_scale + Vector2(0.005, 0.005), 2).from(inicial_scale)
	tween.tween_property(self, "scale", inicial_scale, 2)
	
	
func _process(delta: float) -> void:
	position += (get_global_mouse_position()*delta)-position
