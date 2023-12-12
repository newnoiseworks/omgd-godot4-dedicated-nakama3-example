extends Node

const PORT = 9999

# NOTE: Godot 4 requires a secure (SSL) context to fully work when deployed. If you use
# websockets, this example will work on localhost / your local machine, but will NOT
# work on a deployed server.
const USE_WEBSOCKETS = false

signal user_joined(id)
signal player_joined(id)
signal player_left(id)


func is_server():
	return "--server" in OS.get_cmdline_args()


func get_network_id():
	return multiplayer.get_unique_id()


func _ready():
	var _gc

	if is_server():
		print_debug("Server")

		_gc = multiplayer.connect("peer_connected", _network_peer_connected)
		_gc = multiplayer.connect("peer_disconnected", _network_peer_disconnected)
	else:
		print_debug("Client")

		_gc = multiplayer.connect("connection_failed", _client_connect_failed)
		_gc = multiplayer.connect("connected_to_server", _client_connect_success)

	
func setup_network_peer():
	if USE_WEBSOCKETS:
		_setup_network_peer_as_ws()
	else:
		_setup_network_peer_as_udp()


func _setup_network_peer_as_ws():
	var peer

	if is_server():
		peer = WebSocketMultiplayerPeer.new()
		peer.create_server(PORT)
		print_debug("WS Server should be setup at port ", PORT)
	else:
		peer = WebSocketMultiplayerPeer.new()
		var url = "ws://%s:%s" % [ServerConfig.dedicated_server_host, PORT]
		print_debug("Attempting connection to ", url)
		peer.create_client(url);

	get_tree().get_multiplayer().multiplayer_peer = peer


func _setup_network_peer_as_udp():
	var peer

	if is_server():
		peer = ENetMultiplayerPeer.new()
		peer.create_server(PORT, 8)
		print_debug("UDP Server should be setup at port ", PORT)
	else:
		peer = ENetMultiplayerPeer.new()
		print_debug("Attempting connection to ", ServerConfig.dedicated_server_host, " at port ", PORT)
		peer.create_client(ServerConfig.dedicated_server_host, PORT)

	get_tree().get_multiplayer().multiplayer_peer = peer


func _exit_tree():
	if is_server():
		get_tree().disconnect("peer_connected", _network_peer_connected)
		get_tree().disconnect("peer_disconnected", _network_peer_disconnected)
	else:
		get_tree().disconnect("connection_failed", _client_connect_failed)
		get_tree().disconnect("connected_to_server", _client_connect_success)


func _client_connect_success():
	print_debug("client connect to server success")
	print_debug("player rpc id: ", get_network_id())
	emit_signal("user_joined", get_network_id())


func _client_connect_failed():
	print_debug("client connect to server failed")


func _network_peer_connected(id):
	print_debug("network peer connected!")
	emit_signal("player_joined", id)
	print_debug(id)


func _network_peer_disconnected(id):
	print_debug("network peer disconnected!")
	emit_signal("player_left", id)
	print_debug(id)


