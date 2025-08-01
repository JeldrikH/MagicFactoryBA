extends Node2D
var timer: Timer
var save_interval = 5
var save_folder = "user://savegame/"

var players: Dictionary = {}

func start_autosave():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = save_interval
	timer.connect("timeout", _autosave)
	timer.start()
	
## Load scene from save by path
func load_scene(scene_name: StringName):
	if not MultiplayerManager.is_host:
		return
	scene_name = scene_name.to_snake_case()
	if not FileAccess.file_exists("%s%s.save" % [save_folder, scene_name]):
		return

	##Deletes all unique nodes before loading them from save
	var save_nodes = get_tree().get_nodes_in_group("unique")
	for i in save_nodes:
		i.free()
	
	# Load the Scene
	# Load the file line by line
	var save_file = FileAccess.open("%s%s.save" % [save_folder, scene_name], FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		# Get the data from the JSON object.
		var node_data = json.data

		# create the object, add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		var parent = get_node(node_data["parent"])
		if not parent.has_node("%s" % new_object.name):
			parent.add_child.call_deferred(new_object, true)
	
## Save given scene node
func save_scene(scene_name: StringName):
	scene_name = scene_name.to_snake_case()
	if multiplayer.is_server():
		
		if not DirAccess.dir_exists_absolute(save_folder):
			DirAccess.make_dir_absolute(save_folder)
			
		var save_file = FileAccess.open("%s%s.save" % [save_folder, scene_name], FileAccess.WRITE)
		var save_nodes = get_tree().get_nodes_in_group("persist")
		
		for node in save_nodes:
			
			# Check the node is an instanced scene so it can be instanced again during load.
			if node.scene_file_path.is_empty():
				print("persistent node '%s' is not an instanced scene, skipped" % node.name)
				continue

			# Check the node has a save function.
			if !node.has_method("save"):
				print("persistent node '%s' is missing a save() function, skipped" % node.name)
				continue
			# Check if the node is in the saving scene (TODO: maybe split save groups for better efficiency)
			if node.current_scene_instance.name.to_snake_case() != scene_name:
				continue
			# Call the node's save function.
			var node_data = node.call("save")

			#serialize JSON string.
			var json_string = JSON.stringify(node_data)

			# Store the save dictionary as a new line in the save file.
			save_file.store_line(json_string)


func save_active_scenes():
	for scene in SceneManager.scenes_in_tree.keys():
		save_scene(scene)
	
func load_players():
	if multiplayer.is_server():
		if not FileAccess.file_exists(save_folder + "players.save"):
			return

		# Load the Scene
		# Load the file line by line
		var save_file = FileAccess.open(save_folder + "players.save", FileAccess.READ)
		
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()

			# Check if there is any error while parsing the JSON string, skip in case of failure.
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue

			# Get the data from the JSON object.
			var node_data = json.data

			# create the object, add it to the tree and set its position.
			var player: Player = load("res://Scenes/Main/Characters/player.tscn").instantiate()
			player.position = Vector2(node_data["pos_x"], node_data["pos_y"])

			# set the remaining variables.
			for i in node_data.keys():
				if i == "pos_x" or i == "pos_y":
					continue
				player.set(i, node_data[i])
			player.name = str(player.player_id)
			players.get_or_add(player.name, player)

## Save given scene node
func save_players():
	if multiplayer.is_server():
		
		if not DirAccess.dir_exists_absolute(save_folder):
			DirAccess.make_dir_absolute(save_folder)
			
		var save_file = FileAccess.open(save_folder + "players.save", FileAccess.WRITE)
		var players_to_save = get_tree().get_nodes_in_group("player")
		
		for player in players_to_save:
			# Call the player's save function.
			var player_data = player.call("save")

			#serialize JSON string.
			var json_string = JSON.stringify(player_data)

			# Store the save dictionary as a new line in the save file.
			save_file.store_line(json_string)
			
func _autosave():
	save_active_scenes()
	save_players()
	SceneManager._close_inactive_scenes()
