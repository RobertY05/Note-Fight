extends "rival_template.gd"

@export var _square : PackedScene
var _next_group_size = 1
var _spawning = false
var _group_origin = 0

var _square_cost

func _ready():
	modulate = TEAM_COLOR
	_square_cost = _square.instantiate().COST

func _on_ai_timer_timeout():
	if _spawning:
		var max_spread = 50
		var next_y = _group_origin + randf_range(-max_spread, max_spread)
		summon(_square, next_y)
		_next_group_size -= 1
		if _next_group_size == 0:
			_next_group_size = randi_range(1, floor(max_ink / _square_cost))
			_spawning = false
	
	elif _next_group_size * _square_cost <= ink:
		_spawning = true
		ink -= _next_group_size * _square_cost
		_group_origin = randf_range(min_y(), max_y())
