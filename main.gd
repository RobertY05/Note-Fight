extends Node2D

@export var TRANSITION_SPEED = 0.1
@export var game_template : PackedScene
@export var PRE_UP_POSITION = Vector2(0, -100)

@onready var _main_menu = $MainMenu
@onready var _delayed_free_timer = $DelayedFreeTimer
@onready var _next_timer = $NextTimer
@onready var _music_loop = $MusicLoop
@onready var _music_intro = $MusicIntro
var _on_menu = true
var _game_ref
var _delayed_free_obj
var _delayed_start_obj

# Rivals hardcoded hack list
@export_group("Rivals")
@export var square_rival : PackedScene
@export var pentagon_rival : PackedScene
@export var hexagon_rival : PackedScene
@export var octagon_rival : PackedScene

# Summons hardcoded hack list
@export_group("Summons")
@export var square_summon : PackedScene
@export var triangle_summon : PackedScene
@export var pentagon_summon : PackedScene
@export var hexagon_summon : PackedScene
@export var octagon_summon : PackedScene

# Levels hardcoded hack list
@export_group("Levels")
@export var level_square : PackedScene
@export var level_pentagon : PackedScene
@export var level_hexagon : PackedScene
@export var level_octagon : PackedScene

var _levels
var _player_ink_rate
var _ai_ink_rate
var _rival
var _player_summons
var _player_max_ink
var _ai_max_ink

var _cur_level = 0

func _ready():
	_levels = [
		level_square,
		level_pentagon,
		level_hexagon,
		level_octagon
	]

	_player_ink_rate = [
		0.2,
		0.3,
		0.4,
		0.5
	]

	_ai_ink_rate = [
		0.12,
		0.2,
		0.3,
		0.4
	]
	
	_player_max_ink = [
		20,
		25,
		25,
		30
	]
	
	_ai_max_ink = [
		10,
		25,
		30,
		30
	]

	_rival = [
		square_rival,
		pentagon_rival,
		hexagon_rival,
		octagon_rival
	]

	_player_summons = [
		[triangle_summon],
		[triangle_summon, square_summon],
		[triangle_summon, square_summon, pentagon_summon],
		[triangle_summon, square_summon, pentagon_summon, hexagon_summon]
	]
	
func _physics_process(delta):
	if Input.is_action_just_released("left_click"):
		if _on_menu:
			_main_menu.target_position = Vector2.ZERO
		else:
			_game_ref.target_position = Vector2.ZERO
		_next_timer.stop()
	
	if _on_menu and Input.is_action_just_pressed("left_click"):
		_next_timer.start()
		_main_menu.target_position = PRE_UP_POSITION
		
	if _game_ref != null:
		if Input.is_action_just_pressed("left_click") and (_game_ref.rival_ref.dead or _game_ref.player.dead):
			_next_timer.start()
			_game_ref.target_position = PRE_UP_POSITION
		_game_ref.global_position = _game_ref.target_position * TRANSITION_SPEED + _game_ref.global_position * (1 - TRANSITION_SPEED)
		
		
		
	if _delayed_free_obj != null:
		_delayed_free_obj.global_position = _delayed_free_obj.target_position * TRANSITION_SPEED + _delayed_free_obj.global_position * (1 - TRANSITION_SPEED)
		
	if Input.is_action_just_pressed("e"):
		if !_on_menu:
			_cur_level += 1
		_load_level()
	
func _delayed_free(obj):
	if _delayed_free_obj != null:
		_delayed_free_obj.queue_free()
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	_delayed_free_obj = obj
	_delayed_free_timer.start()
	
func _on_delayed_free_timer_timeout():
	_delayed_free_obj.queue_free()
	_delayed_free_obj = null
	
func _on_music_intro_finished():
	_music_loop.play()
	
func _on_next_timer_timeout():
	if _game_ref != null and _game_ref.rival_ref.dead:
		_cur_level += 1
		_load_level()
	_load_level()

func _load_level():
	#force set player and ai max ink to 15 - 30
	var max_ink = 20
	var up_position = Vector2(0, -get_viewport_rect().size.y * 1.5)
	var down_position = Vector2(0, get_viewport_rect().size.y * 1.5)
	
	if _on_menu:
		_on_menu = false
		_main_menu.target_position = up_position
		
		if !_music_intro.playing and !_music_loop.playing:
			_music_intro.play()
		
	else:
		_game_ref.target_position = up_position
		_delayed_free(_game_ref)
		
	if _cur_level == _levels.size():
		_cur_level = 0
		_main_menu.global_position = down_position
		_main_menu.target_position = Vector2.ZERO
		_on_menu = true
		return
	
	_game_ref = game_template.instantiate()
	
	_game_ref.target_position = Vector2.ZERO
	_game_ref.player_max_ink = _player_max_ink[_cur_level]
	_game_ref.ai_max_ink = _ai_max_ink[_cur_level]
	
	_game_ref.level = _levels[_cur_level]
	_game_ref.player_ink_rate = _player_ink_rate[_cur_level]
	_game_ref.ai_ink_rate = _ai_ink_rate[_cur_level]
	_game_ref.player_summons = _player_summons[_cur_level]
	_game_ref.rival_template = _rival[_cur_level]
	
	if _cur_level == _levels.size() - 1:
		_game_ref.last_game = true
	
	add_child(_game_ref)
	_game_ref.global_position = down_position

func _on_music_loop_finished():
	_music_loop.play()
