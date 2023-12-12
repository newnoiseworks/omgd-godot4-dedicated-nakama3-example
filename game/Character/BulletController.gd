extends Area2D

const BULLET_SPEED = 200
const BULLET_EXPIRY_DISTANCE = 1000

@export var is_firing: bool = true

var fired_from: int
var fire_dir: Vector2

var _initial_position: Vector2


func _ready():
	_initial_position = position
	rotation = fire_dir.angle()


func _physics_process(delta):
	if is_firing:
		position += fire_dir * BULLET_SPEED * delta

		if position.distance_to(_initial_position) > BULLET_EXPIRY_DISTANCE:
			queue_free()


func _on_bullet_body_entered(body: Character):
	if body.visible && body.name != str(fired_from):
		body.take_damage()
		queue_free()


