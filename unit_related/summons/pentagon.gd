extends "shape.gd"

@onready var _original_scale = _sprite.scale
@export var SHRINK_SPEED = 0.1
@export var ATTACK_SCALE = 0.3

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	if _health >= 0:
		_sprite.scale = _sprite.scale * (1 - SHRINK_SPEED) + _original_scale * SHRINK_SPEED

func _on_just_attacked():
	_sprite.scale += Vector2(ATTACK_SCALE, ATTACK_SCALE)
