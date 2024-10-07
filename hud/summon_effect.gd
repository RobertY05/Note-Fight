extends Line2D

@export var FADE_SPEED = 0.2
@export var MAX_OPAQUENESS = 1
@export var BOTTOM_MARGIN = 20

func zap(shape):
	set_point_position(0, to_local(Vector2(shape.global_position.x, 0)))
	set_point_position(1, to_local(shape.global_position) + Vector2(0, shape.radius * 0.3 + BOTTOM_MARGIN))
	
	default_color.a = MAX_OPAQUENESS
	width = shape.radius + BOTTOM_MARGIN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	default_color.a = default_color.a * (1 - FADE_SPEED)
