extends CharacterBody2D

var max_ink
var ink = 0

@onready var radius = $CollisionShape2D.shape.radius

@onready var _summon_marker = $SummonMarker
@onready var _summons = $Summons
@onready var _sprite = $Sprite2D
@onready var _jiggletimer = $JiggleTimer
@onready var _summon_effect = $SummonEffect

@export var TEAM_COLOR : Color
@export var LEFT_CLICK_MARGIN = 200
@export var DEAD_SPRITE : Texture2D
var summon_height_margin
var summon_range

var current_summon = null
var first_dest : Vector2
var final_dest

#placeholders
@export var build_line : Vector2

var dead = false

var _acceleration = 0.1

func hurt(enemy_shape):
	if !dead:
		for summon in _summons.get_children():
			summon.queue_death()
		_sprite.texture = DEAD_SPRITE
	dead = true
	velocity += (global_position - enemy_shape.global_position).normalized() * enemy_shape.KNOCKBACK * 0.5
	_jiggletimer.start()
	
func get_ink(x):
	ink += x
	ink = min(max_ink, ink)

func _ready():
	_summon_effect.default_color = TEAM_COLOR
	_summon_effect.default_color.a = 0
	modulate = TEAM_COLOR

func _physics_process(delta):
	if Input.is_action_just_pressed("left_click") and get_global_mouse_position().x > LEFT_CLICK_MARGIN and current_summon != null and !dead:
		var new_summon = current_summon.instantiate()
		if ink >= new_summon.COST:
			new_summon.left_side = true
			new_summon.first_dest = Vector2(first_dest.x, _valid_y(get_global_mouse_position().y))
			new_summon.final_dest = final_dest
			new_summon.team_color = TEAM_COLOR
			_summons.add_child(new_summon)
			new_summon.global_position = Vector2(global_position.x + summon_range, _valid_y(get_global_mouse_position().y))
			ink -= new_summon.COST
			_summon_effect.zap(new_summon)
	
	_summon_marker.visible = false
	if get_global_mouse_position().x > LEFT_CLICK_MARGIN and current_summon != null and !dead:
		_summon_marker.visible = true
		_summon_marker.global_position.y = _valid_y(get_global_mouse_position().y)
		
	velocity = Vector2.ZERO * _acceleration + velocity * (1 - _acceleration)
	_sprite.position = (_sprite.position + Vector2.ZERO) / 2
	
	move_and_slide()

func _valid_y(y):
	return clamp(y, summon_height_margin, get_viewport_rect().size.y - summon_height_margin)

var _jiggle = 5
func _on_jiggle_timer_timeout():
	_sprite.global_position += Vector2(randf_range(-_jiggle, _jiggle), randf_range(-_jiggle, _jiggle))
