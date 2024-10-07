extends Node2D

@onready var player = $Sorted/Player
@onready var _hud = $Hud

@export var summon_height_margin = 50
@export var summon_range = 100
@export var first_dest_margin = 300

var target_position : Vector2

var level : PackedScene
var player_max_ink : int
var player_ink_rate : float
var ai_max_ink : int
var ai_ink_rate : float

var player_summons
var rival_template

var last_game = false

var rival_ref

func _ready():
	var new_level = level.instantiate()
	add_child(new_level)
	rival_ref = rival_template.instantiate()
	$Sorted.add_child(rival_ref)
	
	player.summon_height_margin = summon_height_margin
	player.summon_range = summon_range
	player.max_ink = player_max_ink
	rival_ref.summon_height_margin = summon_height_margin
	rival_ref.summon_range = summon_range
	rival_ref.max_ink = ai_max_ink
	rival_ref.global_position = Vector2(get_viewport_rect().size.x - player.global_position.x, player.global_position.y)
	
	player.first_dest = Vector2(get_viewport_rect().size.x - first_dest_margin, 0)
	player.final_dest = rival_ref
	rival_ref.first_dest = Vector2(first_dest_margin, 0)
	rival_ref.final_dest = player
	if last_game:
		rival_ref.last_rival = true
	
	_hud.summons = player_summons
	_hud.custom_setup(player, rival_ref)


func _on_ink_timer_timeout():
	player.get_ink(player_ink_rate)
	rival_ref.get_ink(ai_ink_rate)

func _on_ai_summon_detector_body_entered(body):
	rival_ref.player_summons_list.append(body)

func _on_ai_summon_detector_body_exited(body):
	rival_ref.player_summons_list.erase(body)
