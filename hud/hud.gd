extends Node2D

var _player_ref
var _rival_ref
var summons = []

@onready var _win_message = $WinMessage
@onready var _lose_message = $LoseMessage
@onready var _completion_message = $CompletionMessage
var _message_position = Vector2(640, 150)

func custom_setup(player_ref, rival_ref):
	_player_ref = player_ref
	_rival_ref = rival_ref
	
	var cards = [$Card1, $Card2, $Card3, $Card4]
	for i in range(summons.size()):
		cards[i].summon = summons[i]
		
	for i in get_children():
		i.custom_setup(player_ref)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for i in range(1, 5):
		if Input.is_action_just_pressed(str(i)) and summons.size() >= i:
			_player_ref.current_summon = summons[i - 1]
		
	if _player_ref.dead:
		_lose_message.target_position = _message_position
		_lose_message.visible = true
	if _rival_ref.dead:
		if _rival_ref.last_rival:
			_completion_message.target_position = _message_position
			_completion_message.visible = true
		else:
			_win_message.target_position = _message_position
			_win_message.visible = true
