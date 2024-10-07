extends Control

var _player_ref = null

@onready var _bar = $Bar
@onready var _label = $Label

func custom_setup(player_ref):
	_player_ref = player_ref
	_bar.max_value = player_ref.max_ink

func _process(delta):
	_bar.value = _player_ref.ink
	_label.text = str(floor(_player_ref.ink))
