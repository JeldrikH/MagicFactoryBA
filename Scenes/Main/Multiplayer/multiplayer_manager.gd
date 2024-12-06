extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var player_scene = preload("res://Scenes/Main/player.tscn")
var _players_spawn_node
var host_mode_enabled = false

var is_host = false
var is_client = false
var id

func manage_multiplayer():
	if is_host:
		host()
	elif is_client:
		join()
		
func host():
	host_mode_enabled = true
	_players_spawn_node = get_tree().get_current_scene()
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	
	_add_player_to_game(1)
	
func join():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	
func _add_player_to_game(p_id: int):
	print("Player %s joined the game!"% p_id)
	var player_to_add = player_scene.instantiate()
	player_to_add.player_id = p_id
	player_to_add.name = str(p_id)
	
	_players_spawn_node.add_child(player_to_add, true)
	
func _remove_player_from_game(p_id: int):
	print("Player %s left the game!"% p_id)
	if not _players_spawn_node.has_node(str(p_id)):
		return
	_players_spawn_node.get_node(str(p_id)).queue_free()
