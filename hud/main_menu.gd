extends Sprite2D

var target_position = Vector2.ZERO
@export var TRANSITION_SPEED = 0.1

func _physics_process(delta):
	global_position = target_position * TRANSITION_SPEED + global_position * (1 - TRANSITION_SPEED)
