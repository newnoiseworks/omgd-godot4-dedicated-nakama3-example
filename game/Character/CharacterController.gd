extends CharacterBody2D

class_name Character

const SPEED: int = 250
const DAMAGE_PER_BULLET: int = 10
const STARTING_HEALTH: int = 50

@onready var icon = find_child("Godot_icon")
@onready var chamber = find_child("Chamber")

@export var bullet_scene: PackedScene

var user_id: String

var health: int = STARTING_HEALTH
var target: Vector2


func _ready():
	var label: Label = find_child("UsernameLabel")
	label.text = user_id
	target = position


func _physics_process(_delta):
	velocity = position.direction_to(target) * SPEED

	if position.distance_to(target) > 5:
		move_and_slide()


@rpc("any_peer", "call_local", "unreliable")
func _move_event(args):
	target = args


@rpc("any_peer", "call_local", "unreliable")
func _rotate_event(args):
	icon.rotation += args


@rpc("any_peer", "call_local", "reliable")
func _fire_event():
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.fire_dir = Vector2(0, 1).rotated(icon.rotation)
	bullet.position = position
	bullet.fired_from = get_multiplayer_authority()

	print_debug("bullet fired from ", bullet.fired_from)

	get_parent().call_deferred("add_child", bullet)


func take_damage():
	health -= DAMAGE_PER_BULLET
	print_debug("player ", name, " has been hit")

	if ServerManager.is_server() && health <= 0:
		print_debug("player ", name, " killed on server")
		_player_killed.rpc()


# TODO: This should disappear the player temporarily, turn off collisions as well, all on a timer
@rpc("any_peer", "call_local", "reliable")
func _player_killed():
	visible = false
	await get_tree().create_timer(3.0).timeout
	health = STARTING_HEALTH
	visible = true


