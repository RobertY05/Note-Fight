extends "shape.gd"

@export var STRAIGHTEN_SPEED = 0.1
@export var ATTACK_SKEW = 0.5

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	if _health >= 0:
		_sprite.skew *= (1 - STRAIGHTEN_SPEED)

func _on_just_attacked():
	if current_enemy.global_position.x > global_position.x:
		_sprite.skew = ATTACK_SKEW
	else:
		_sprite.skew = -ATTACK_SKEW
