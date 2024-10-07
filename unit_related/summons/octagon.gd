extends "shape.gd"

@export var JIGGLE_OFFSET = 10
@export var RECOVERY_SPEED = 0.5

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	if _health > 0:
		_sprite.position = (_sprite.position + Vector2.ZERO) / 2

func _on_just_attacked():
	_sprite.global_position += Vector2(randf_range(-JIGGLE_OFFSET, JIGGLE_OFFSET), randf_range(-JIGGLE_OFFSET, JIGGLE_OFFSET))
