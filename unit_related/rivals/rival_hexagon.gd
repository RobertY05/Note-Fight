extends "rival_template.gd"

@export var _square : PackedScene
@export var _triangle : PackedScene
@export var _pentagon : PackedScene
@export var _hexagon : PackedScene

@onready var _square_cost = _square.instantiate().COST
@onready var _triangle_cost = _triangle.instantiate().COST
@onready var _pentagon_cost = _pentagon.instantiate().COST
@onready var _hexagon_cost = _hexagon.instantiate().COST

var _panicked = false
var _distance_to_panic = 350
var _panic_placement_variation = 300
var _normal_placement_variation = 200
var _offset = 200

var _spawning = false
var _spawned_shapes
var _spawned_cost
var _discount = 1.0

var _percent_spawning = 0.2
var _min_percent = 0.2
var _max_percent = 0.99

func _ready():
	modulate = TEAM_COLOR

func _on_ai_timer_timeout():
	player_summons_list.sort_custom(_dist_sort)
	
	if !player_summons_list.is_empty() and global_position.distance_to(player_summons_list[0].global_position) < _distance_to_panic and !_spawning:
		_spawning = true
		if _panicked:
			_spawned_shapes = [_square, _hexagon, _triangle, _pentagon]
			_spawned_cost = [_square_cost, _hexagon_cost, _triangle_cost, _pentagon_cost]
		else:
			_panicked = true
			_spawned_shapes = [_hexagon]
			_spawned_cost = [_hexagon_cost]
			ink = max_ink
			_discount = 0.3
			_offset = _panic_placement_variation
	
	if ink / max_ink >= _percent_spawning and !_spawning:
		_spawning = true
		if _panicked:
			_spawned_shapes = [_square, _hexagon, _triangle, _pentagon]
			_spawned_cost = [_square_cost, _hexagon_cost, _triangle_cost, _pentagon_cost]
		else:
			_spawned_shapes = [_square, _triangle, _pentagon]
			_spawned_cost = [_square_cost, _triangle_cost, _pentagon_cost]
		
		_percent_spawning = randf_range(_min_percent, _max_percent)
	
	if _spawning and _spawned_shapes.size() > 0:
		var next_shape_idx = randi_range(0, _spawned_shapes.size() - 1)
		if ink >= _spawned_cost[next_shape_idx] * _discount:
			ink -= _spawned_cost[next_shape_idx] * _discount
			_summon_offset(_spawned_shapes[next_shape_idx], player_summons_list[0].global_position.y, _offset)
		else:
			_discount = 1
			_spawning = false
			_offset = _normal_placement_variation

func _summon_offset(shape, position, variation):
	summon(shape, position + randf_range(-variation, variation))
	
func _dist_sort(a, b):
	var dist_a = a.global_position.distance_to(global_position)
	var dist_b = b.global_position.distance_to(global_position)
	return dist_a < dist_b
