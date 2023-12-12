extends "res://Character/CharacterController.gd"

# icon from https://www.reddit.com/r/godot/comments/icagss/i_made_a_claylike_3d_desktop_icon_for_godot_ico/

const INPUT_MOVE: int = 10


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_released("fire"):
			_fire_event.rpc()


func _physics_process(delta):
	var new_target = position

	if Input.is_action_pressed("move_right"):
		new_target.x += INPUT_MOVE
	if Input.is_action_pressed("move_left"):
		new_target.x -= INPUT_MOVE
	if Input.is_action_pressed("move_down"):
		new_target.y += INPUT_MOVE
	if Input.is_action_pressed("move_up"):
		new_target.y -= INPUT_MOVE

	if (new_target.distance_to(position) > INPUT_MOVE - 5):
		_move_event.rpc(new_target)

	if Input.is_action_pressed("rotate_right"):
		_rotate_event.rpc(-1.5 * delta)
	if Input.is_action_pressed("rotate_left"):
		_rotate_event.rpc(1.5 * delta)

	super(delta)

