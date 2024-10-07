extends "rival_template.gd"

@export var _square : PackedScene
@export var _triangle : PackedScene
@export var _pentagon : PackedScene
@export var _hexagon : PackedScene
@export var _octagon : PackedScene

@onready var _square_cost = _square.instantiate().COST
@onready var _triangle_cost = _triangle.instantiate().COST
@onready var _pentagon_cost = _pentagon.instantiate().COST
@onready var _hexagon_cost = _hexagon.instantiate().COST
@onready var _octagon_cost = _octagon.instantiate().COST

var _octagon_summoned = false

var _distance_to_panic = 200
var _panic_placement_variation = 20

var _placement_variation = 50
@onready var _top = get_viewport_rect().size.y / 6
@onready var _bottom = get_viewport_rect().size.y - _top

var _swarm_type = 0
var _spawning = false

var _wait_time_pent = 45
var _wait_time_square = 0
var _time = 0
var _min_pent = 3
var _max_pent = 6
var _min_square = 6
var _max_square = 12

var _melee_unit_count = 0

var _side = 0

func _ready():
	modulate = TEAM_COLOR
	_roll_swarm()

func _on_ai_timer_timeout():
	player_summons_list.sort_custom(_dist_sort)
	
	if !_octagon_summoned and ink > 10:
		summon(_octagon, get_viewport_rect().size.y / 2)
		_octagon_summoned = true
		return
	
	if !player_summons_list.is_empty() and global_position.distance_to(player_summons_list[0].global_position) < _distance_to_panic:
		if ink > _pentagon_cost:
			ink -= _pentagon_cost
			summon(_pentagon, player_summons_list[0].global_position.y + randf_range(-_panic_placement_variation, _panic_placement_variation))
		if ink > _hexagon_cost:
			ink -= _hexagon_cost
			summon(_hexagon, player_summons_list[0].global_position.y + randf_range(-_panic_placement_variation, _panic_placement_variation))
		if ink > _square_cost:
			ink -= _square_cost
			summon(_square, player_summons_list[0].global_position.y + randf_range(-_panic_placement_variation, _panic_placement_variation))
		return
	
	if ink > max_ink - 1:
		_spawning = true
	
	if _spawning and _swarm_type == 0:
		if ink >= _hexagon_cost:
			ink -= _hexagon_cost
			_side_summon(_hexagon)
		else:
			_roll_swarm()
	elif _spawning and _swarm_type == 1:
		if ink >= _pentagon_cost and _melee_unit_count > 0:
			_melee_unit_count -= 1
			ink -= _pentagon_cost
			_side_summon(_pentagon)
		elif ink >= _triangle_cost and _time > _wait_time_pent:
			ink -= _triangle_cost
			_side_summon(_triangle)
		elif ink >= _triangle_cost and _time <= _wait_time_pent:
			_time += 1
		else:
			_roll_swarm()
	elif _spawning and _swarm_type == 2:
		if ink >= _square_cost and _melee_unit_count > 0:
			_melee_unit_count -= 1
			ink -= _square_cost
			_side_summon(_square)
		elif ink >= _triangle_cost and _time > _wait_time_square:
			ink -= _triangle_cost
			_side_summon(_triangle)
		elif ink >= _triangle_cost and _time <= _wait_time_square:
			_time += 1
		else:
			_roll_swarm()


func _side_summon(shape):
	if _side:
		summon(shape, _top + randf_range(-_placement_variation, _placement_variation))
	else:
		summon(shape, _bottom + randf_range(-_placement_variation, _placement_variation))

func _roll_swarm():
	_time = 0
	_swarm_type = randi_range(0, 2)
	_spawning = false
	_side = randi_range(0, 1)
	
	
	if _swarm_type == 1:
		_melee_unit_count = randi_range(_min_pent, _max_pent)
	elif _swarm_type == 2:
		_melee_unit_count = randi_range(_min_square, _max_square)

func _dist_sort(a, b):
	var dist_a = a.global_position.distance_to(global_position)
	var dist_b = b.global_position.distance_to(global_position)
	return dist_a < dist_b
