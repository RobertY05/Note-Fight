extends "shape.gd"

@onready var _bullet_trail = $BulletTrail
@onready var _return_timer = $ReturnTimer

@export var BULLET_TRAIL_FADE_SPEED = 0.2
@export var ROTATION_SPEED = 0.1
@export var TIP_MARGIN = 7

var _returning = false

func _ready():
	super._ready()
	_bullet_trail.default_color = team_color * Color(1, 1, 1, 0)

func _physics_process(delta):
	super._physics_process(delta)
		
	if _health > 0:
		if is_instance_valid(current_enemy):
			_returning = false
			if left_side:
				_sprite.rotation = global_position.angle_to_point(current_enemy.global_position)
			else:
				_sprite.rotation = global_position.angle_to_point(current_enemy.global_position) + PI
		elif _returning:
			if _sprite.rotation > PI:
				_sprite.rotation = 2 * PI * ROTATION_SPEED + _sprite.rotation * (1 - ROTATION_SPEED)
			else:
				_sprite.rotation = _sprite.rotation * (1 - ROTATION_SPEED)
				
		elif _return_timer.is_stopped():
			_return_timer.start()
			
	_bullet_trail.default_color.a = _bullet_trail.default_color.a * (1 - BULLET_TRAIL_FADE_SPEED)
	


func _on_just_attacked():
	_bullet_trail.default_color.a = 1
	_bullet_trail.set_point_position(0, (current_enemy.global_position - global_position).normalized() * TIP_MARGIN)
	_bullet_trail.set_point_position(1, to_local(current_enemy.global_position))


func _on_return_timer_timeout():
	_returning = true
