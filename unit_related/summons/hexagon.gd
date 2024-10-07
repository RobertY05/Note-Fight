extends "shape.gd"

@export var SPIN_MAX_SPEED = 20
@export var SPIN_ACCELERATION = 0.07
@export var SPIN_DECELERATION = 0.1

var _spin_velocity = 0

@onready var _spin_timer = $SpinTimer

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	if _health > 0 and !_spin_timer.is_stopped():
		_spin_velocity = _spin_velocity * (1 - SPIN_ACCELERATION) + SPIN_MAX_SPEED * SPIN_ACCELERATION
	else:
		_spin_velocity = _spin_velocity * (1 - SPIN_DECELERATION)
	
	_sprite.rotate(deg_to_rad(_spin_velocity))

func _on_just_attacked():
	_spin_timer.start()
