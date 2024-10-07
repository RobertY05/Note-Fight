extends Area2D

var summon = null
var _player_ref = null

var _original_pos
var _activated_pos
var _hover_pos
var _hover = false

@export var UNACTIVATED_COLOR : Color 
@export var ACTIVATED_OFFSET : int
@export var HOVER_OFFSET : int

@onready var _sprite = $CardSprite

func custom_setup(player_ref):
	_player_ref = player_ref
	_original_pos = _sprite.position
	_activated_pos = _sprite.position + Vector2(ACTIVATED_OFFSET, 0)
	_hover_pos = _sprite.position + Vector2(HOVER_OFFSET, 0)
	
	if summon != null:
		var temp_summon = summon.instantiate()
		$CardSprite/IconSprite.texture = temp_summon.get_node("Sprite2D").texture
		$CardSprite/IconSprite.modulate = Color.BLACK
		$CardSprite/Label.text = str(temp_summon.COST)
	else:
		$CardSprite/IconSprite.texture = null
		$CardSprite/Label.text = ""
	
	

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and summon != null:
		_player_ref.current_summon = summon

func _physics_process(delta):
	_sprite.modulate = UNACTIVATED_COLOR
	if summon == null:
		return
	if _player_ref.current_summon == summon:
		_sprite.position = (_sprite.position + _activated_pos) / 2
		_sprite.modulate = Color.WHITE
	elif _hover:
		_sprite.position = (_sprite.position + _hover_pos) / 2
	else:
		_sprite.position = (_sprite.position + _original_pos) / 2


func _on_mouse_entered():
	_hover = true
	
func _on_mouse_exited():
	_hover = false
