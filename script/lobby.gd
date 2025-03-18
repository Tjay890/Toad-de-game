extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal update_connected_players

const PORT = 7000
const MAX_CONNECTIONS = 5
var peer_id = 1
var toad_id = 1
var players = {}
var player_list = []
var player_info = {"name": "Name"}
@export var connected_players : Label

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_list.append(1)
	player_connected.emit(1, player_info)
	update_connected_players.emit()

func join_game(address):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_list.append(new_player_id)
	player_connected.emit(new_player_id, new_player_info)
	update_connected_players.emit()

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	
func _on_connected_to_server():
	peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	player_list.append(peer_id)


func _on_connection_failed():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
