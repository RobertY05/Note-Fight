extends CharacterBody2D

signal just_attacked

@export var DEAD_SPRITE : Texture2D

@export_group("Stats")
@export var SPEED : int
@export var MAX_HEALTH : int
@export var FIRE_RATE : float
@export var RANGE : int
@export var DAMAGE : int
@export var COST : int
@export var KNOCKBACK : float
@export var KNOCKBACK_MULTIPLIER : float


@onready var _nav = $NavigationAgent2D
@onready var _fire_rate_timer = $FireRateTimer
@onready var _aggro_radius = $AggroRange
@onready var _sprite = $Sprite2D
@onready var _raycast = $RayCast2D
@onready var _death_timer = $DeathTimer

@onready var radius = $CollisionShape2D.shape.radius

var current_enemy = null

var left_side = null
var first_dest = null
var final_dest = null
var team_color = null

var _enemy_list = []
var _visible_enemy_list = []
var _health
var _is_final_dest = false
var _damage_color = Color.BLACK
var _color_change_speed = 0.2
var _acceleration = 0.1
var _death_knockback_multiplier = 1.5

func hurt(enemy_shape):
	_sprite.modulate = _damage_color
	_health -= enemy_shape.DAMAGE
	if _health <= 0:
		queue_death()
	velocity += (global_position - enemy_shape.global_position).normalized() * enemy_shape.KNOCKBACK * KNOCKBACK_MULTIPLIER

func queue_death():
	_health = 0
	_death_timer.start()
	_sprite.texture = DEAD_SPRITE
	KNOCKBACK_MULTIPLIER = _death_knockback_multiplier
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)

func _ready():
	_fire_rate_timer.wait_time = FIRE_RATE
	_health = MAX_HEALTH
	
	if left_side == null:
		printerr("DID NOT DECLARE WHICH SIDE")
	if first_dest == null:
		printerr("DID NOT DECLARE FIRST DESTINATION")
	if final_dest == null:
		printerr("DID NOT DECLARE FINAL DESTINATION")
	if team_color == null:
		printerr("DID NOT DECLARE TEAM COLOR")
		
	if left_side:
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		_aggro_radius.set_collision_mask_value(1, false)
		_aggro_radius.set_collision_mask_value(2, true)
	else:
		_sprite.flip_h = true
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, true)
		_aggro_radius.set_collision_mask_value(1, true)
		_aggro_radius.set_collision_mask_value(2, false)
		
	_sprite.modulate = team_color
	_nav.target_position = first_dest

func _physics_process(delta):
	var direction = Vector2.ZERO
	_visible_enemy_list = _get_visible_enemies()
	
	if _nav.is_navigation_finished() and !_is_final_dest:
		_is_final_dest = true
		_nav.target_position = final_dest.global_position
	
	#checking for enemies
	if !_visible_enemy_list.is_empty() and _visible_enemy_list[0].global_position.distance_to(global_position) <= RANGE + _visible_enemy_list[0].radius + radius and _health > 0:
		if current_enemy == null or current_enemy.global_position.distance_to(global_position) > RANGE + current_enemy.radius + radius:
			current_enemy = _visible_enemy_list[0]
		if _fire_rate_timer.is_stopped():
			_fire_rate_timer.start()
			current_enemy.hurt(self)
			just_attacked.emit()
	else:
		if _visible_enemy_list.is_empty():
			current_enemy = null
		direction = to_local(_nav.get_next_path_position()).normalized()
	
	var target_velocity = direction * SPEED
	if _health <= 0:
		target_velocity = Vector2.ZERO
	
	velocity = target_velocity * _acceleration + velocity * (1 - _acceleration)
	_sprite.modulate = (_sprite.modulate * (1 - _color_change_speed)) + (team_color * _color_change_speed)
	
	if velocity.length() < 1 and _health <= 0:
		queue_free()
		
	move_and_slide()

func _on_aggro_range_body_entered(body):
	_enemy_list.append(body)

func _on_aggro_range_body_exited(body):
	_enemy_list.erase(body)

func _dist_sort(a, b):
	var dist_a = a.global_position.distance_to(global_position)
	var dist_b = b.global_position.distance_to(global_position)
	return dist_a < dist_b
	
func _get_visible_enemies():
	_enemy_list.sort_custom(_dist_sort)
	var _visible_enemy_list = []
	_raycast.global_position = global_position
	for enemy in _enemy_list:
		_raycast.set_target_position(_raycast.to_local(enemy.global_position))
		_raycast.force_raycast_update()
		if !_raycast.is_colliding():
			_visible_enemy_list.append(enemy)
	return _visible_enemy_list

func _on_navigation_timer_timeout():
	_visible_enemy_list = _get_visible_enemies()
	
	if global_position.x > first_dest.x:
		_is_final_dest = true
	
	if !_visible_enemy_list.is_empty():
		_nav.target_position = _visible_enemy_list[0].global_position
	elif _is_final_dest:
		_nav.target_position = final_dest.global_position
	else:
		_nav.target_position = first_dest


func _on_death_timer_timeout():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
