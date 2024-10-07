extends "rival_template.gd"

var _spawning = false
var _group_origin = 0

var _percent_spawning = 0.2
var _min_percent = 0.2
var _max_percent = 0.99

var _offset = 100

@export var _triangle : PackedScene
@export var _pentagon : PackedScene

@onready var _triangle_cost = _triangle.instantiate().COST
@onready var _pentagon_cost = _pentagon.instantiate().COST

var _triangle_chance = 0.35

func _ready():
	modulate = TEAM_COLOR

func _on_ai_timer_timeout():
	
	if ink / max_ink >= _percent_spawning and !_spawning:
		_spawning = true
	
	if _spawning:
		if randf() <= _triangle_chance and ink >= _triangle_cost:
			ink -= _triangle_cost
			_summon_offset(_triangle, _group_origin)
		elif ink >= _pentagon_cost:
			ink -= _pentagon_cost
			_summon_offset(_pentagon, _group_origin)
		else:
			_spawning = false
			_group_origin = randf_range(min_y(), max_y())
			_percent_spawning = randf_range(_min_percent, _max_percent)
	

func _summon_offset(shape, position):
	summon(shape, position + randf_range(-_offset, _offset))
