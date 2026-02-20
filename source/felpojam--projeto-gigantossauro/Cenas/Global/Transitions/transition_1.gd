extends CanvasLayer

signal _transition_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)


func transition():
	color_rect.visible = true
	animation_player.play("fade_out")


func _on_animation_finished(anim_name: String):
	if anim_name == "fade_out":
		_transition_finished.emit()
		animation_player.play("fade_in")
	else:
		color_rect.visible = false


func change_to_scene(scene: PackedScene):
	Transition.transition()
	await Transition._transition_finished
	get_tree().change_scene_to_packed(scene)
