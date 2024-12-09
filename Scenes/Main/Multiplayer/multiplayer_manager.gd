extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var player_scene = preload("res://Scenes/Main/player.tscn")
var _players_spawn_node

var is_host = false
var is_client = false

func manage_multiplayer():
	
	## Living room is loaded by default
	SceneManager.open_scene_background("living_room")
	
	if is_host:
		host()
	elif is_client:
		join()
		
func host():
	
	_players_spawn_node = get_tree().get_current_scene().get_node("LivingRoom")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	SaveManager.load_players()
	_add_player_to_game(1)
	
func join():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	
	
func _add_player_to_game(p_id: int):
	print("Player %s joined the game!"% p_id)
	var player = SaveManager.players.get(str(p_id))
	
	if !player:
		_add_new_player(p_id)
		return
	
	# If player already exists, load him into the scene
	if !SceneManager.is_scene_open(player.current_scene):
		SceneManager.open_scene_background(player.current_scene)

	var parent: Node2D = get_tree().get_current_scene().get_node(player.current_scene)
	player.is_online = true
	parent.add_child(player)
	
func _add_new_player(p_id: int):
	var player = player_scene.instantiate()
	player.player_id = p_id
	player.name = str(p_id)
	player.is_online = true
	player.current_scene = _players_spawn_node.name
	SaveManager.players.get_or_add(str(p_id), player)
	_players_spawn_node.add_child(player, true)
		
func _remove_player_from_game(p_id: int):
	print("Player %s left the game!"% p_id)
	SaveManager.save_players()
	var player: Player = SaveManager.players.get(str(p_id))
	player.is_online = false
	var parent: Node2D = get_tree().get_current_scene().get_node(player.current_scene)
	parent.remove_child(player)
