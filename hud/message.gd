extends Sprite2D

@onready var target_position = position
@export var TRANSITION_SPEED = 0.2

func custom_setup(player_ref):
	pass

func _physics_process(delta):
	position = target_position * TRANSITION_SPEED + position * (1 - TRANSITION_SPEED)
