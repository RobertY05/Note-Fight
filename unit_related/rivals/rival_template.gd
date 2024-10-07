extends CharacterBody2D

var player_summons_list = []
var ink = 0
var max_ink

var summon_height_margin
var summon_range

var first_dest
var final_dest

var dead = false

var last_rival = false

@export var TEAM_COLOR : Color
@export var DEAD_SPRITE : Texture2D

@onready var _summons = $Summons
@onready var _sprite = $Sprite2D
@onready var _jiggle_timer = $JiggleTimer
@onready var radius = $CollisionShape2D.shape.radius
@onready var _summon_effect = $SummonEffect

var _acceleration = 0.1

func hurt(enemy_shape):
	if !dead:
		for summon in _summons.get_children():
			summon.queue_death()
		_sprite.texture = DEAD_SPRITE
	dead = true
	_jiggle_timer.start()
	velocity += (global_position - enemy_shape.global_position).normalized() * enemy_shape.KNOCKBACK * 0.1
	
	
func get_ink(x):
	ink += x
	ink = min(max_ink, ink)
	
func summon(entity, y):
	if !dead:
		var new_summon = entity.instantiate()
		new_summon.left_side = false
		new_summon.first_dest = Vector2(first_dest.x, _valid_y(y))
		new_summon.final_dest = final_dest
		new_summon.team_color = TEAM_COLOR
		_summons.add_child(new_summon)
		new_summon.global_position = Vector2(global_position.x - summon_range, _valid_y(y))
		_summon_effect.zap(new_summon)

func _ready():
	_summon_effect.default_color = TEAM_COLOR
	_summon_effect.default_color.a = 0

func _physics_process(delta):
	velocity = Vector2.ZERO * _acceleration + velocity * (1 - _acceleration)
	_sprite.position = (_sprite.position + Vector2.ZERO) / 2
	move_and_slide()

func _valid_y(y):
	return clamp(y, summon_height_margin, get_viewport_rect().size.y - summon_height_margin)

func max_y():
	return _valid_y(999999999)

func min_y():
	return _valid_y(0)

func _on_ai_timer_timeout():
	printerr("NO AI DEFINED")
	
var _jiggle = 10
func _on_jiggle_timer_timeout():
	_sprite.global_position += Vector2(randf_range(-_jiggle, _jiggle), randf_range(-_jiggle, _jiggle))
