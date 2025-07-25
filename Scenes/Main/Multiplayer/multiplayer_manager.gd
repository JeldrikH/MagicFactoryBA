extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var player_scene = preload("res://Scenes/Main/Characters/player.tscn")
var _players_spawn_node = "LivingRoom"

var is_host = false
var is_client = false


func manage_multiplayer():
	if is_host:
		host()
	elif is_client:
		join()
	
func host():
	SaveManager.start_autosave()
	
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
	var player: Player = SaveManager.players.get(str(p_id))
	#Open Default scene
	SceneManager.open_scene_by_name(_players_spawn_node)
	
	if !player:
		player = create_new_player(p_id, _players_spawn_node)
	
	SceneManager.open_scene_by_name(player.current_scene)
	var parent: Node2D = get_node("/root/Main/%s/OcclusionObjects" % player.current_scene)
	player.is_online = true
	parent.add_child(player, true)
	
# Only creates player instance, still needs to be added to scene tree
func create_new_player(p_id: int, parent: StringName)-> Player:
	var player = player_scene.instantiate()
	SaveManager.players.get_or_add(str(p_id), player)
	player.player_id = p_id
	player.name = str(p_id)
	player.current_scene = parent
	player.position = get_tree().get_nodes_in_group("spawns").get(0).position #Debug maybe better solution?
	return player
		
func _remove_player_from_game(p_id: int):
	print("Player %s left the game!"% p_id)
	SaveManager.save_players()
	var player: Player = SaveManager.players.get(str(p_id))
	player.is_online = false
	var parent: Node2D = get_tree().get_current_scene().get_node(player.current_scene)
	parent.remove_child(player)
