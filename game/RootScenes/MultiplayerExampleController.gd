extends Node2D

@export var character_scene: PackedScene
@export var player_scene: PackedScene

@onready var environment_items = find_child("EnvironmentItems")

var player: Node2D
var user_ids: Array = []


func _ready():
	ServerManager.setup_network_peer()

	if ServerManager.is_server():
		ServerManager.connect("player_joined", _add_networked_player_to_scene)
		ServerManager.connect("player_left", _remove_networked_player_from_scene)
	else:
		ServerManager.connect("user_joined", _add_player_to_scene)


func _exit_tree():
	if ServerManager.is_server():
		ServerManager.disconnect("player_joined", _add_networked_player_to_scene)
		ServerManager.disconnect("player_left", _remove_networked_player_from_scene)
	else:
		ServerManager.disconnect("user_joined", _add_player_to_scene)


func _add_player_to_scene(user_id: int):
	user_ids.append(user_id)

	if player == null:
		player = player_scene.instantiate()

	player.name = str(user_id)
	player.user_id = str(user_id)
	player.set_multiplayer_authority(ServerManager.get_network_id())

	environment_items.add_child(player)


@rpc
func _setup_users_on_join(user_ids_from_server, user_pos_json, user_rots_json):
	print_debug("_setup_users_on_join called")

	var user_pos = JSON.parse_string(user_pos_json)
	var user_rots = JSON.parse_string(user_rots_json)

	for user_id in user_ids_from_server:
		var v2 = str_to_var("Vector2" + user_pos["p%s" % user_id])
		var rot = int(user_rots["p%s" % user_id])

		_add_character_to_scene(user_id, v2, rot)


func _add_networked_player_to_scene(user_id: int):
	print_debug("calling _add_networked_player_to_scene")

	var user_pos = {}
	var user_rots = {}

	for existing_player in environment_items.get_children():
		user_pos["p%s" % existing_player.name] = existing_player.position
		user_rots["p%s" % existing_player.name] = existing_player.icon.rotation_degrees

	rpc_id(
		user_id,
		"_setup_users_on_join",
		user_ids,
		JSON.stringify(user_pos),
		JSON.stringify(user_rots)
	)

	rpc("_add_character_to_scene", user_id)
	_add_character_to_scene(user_id)


@rpc("any_peer")
func _add_character_to_scene(user_id: int, pos: Vector2 = Vector2.ZERO, rot: float = 0):
	if (user_id == ServerManager.get_network_id()): return

	print_debug("calling _add_character_to_scene for user_id ", user_id)

	user_ids.append(user_id)

	var player_node = character_scene.instantiate()

	player_node.set_multiplayer_authority(user_id)
	player_node.user_id = str(user_id)
	player_node.name = str(user_id)
	player_node.position = pos
	player_node.find_child("Godot_icon").rotation_degrees = rot

	environment_items.add_child(player_node)


func _remove_networked_player_from_scene(user_id: int):
	print_debug("calling _remove_networked_player_from_scene")

	for uid in user_ids:
		if uid != user_id:
			rpc_id(uid, "_rid_networked_player", user_id)

	_rid_networked_player(user_id)


@rpc("any_peer")
func _rid_networked_player(user_id: int):
	print_debug("calling _rid_networked_player")

	user_ids.erase(user_id)
	environment_items.find_child(str(user_id), true, false).queue_free()


