extends Node2D
var timer: Timer
var save_interval = 5
var save_folder = "user://savegame/"

func _ready()-> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = save_interval
	#DEBUGtimer.connect("timeout", autosave)
	timer.start()
	
## Load scene from save by path
func load_scene(scene: String):
	var scene_name_splits = scene.split("/", false)
	var scene_name = scene_name_splits[scene_name_splits.size()-1].trim_suffix(".tscn")
	
	if not FileAccess.file_exists(save_folder + scene_name + ".save"):
		return

	##Deletes all unique nodes before loading them from save
	var save_nodes = get_tree().get_nodes_in_group("unique")
	for i in save_nodes:
		i.free()
	
	# Load the Scene
	# Load the file line by line
	var save_file = FileAccess.open(save_folder + scene_name + ".save", FileAccess.READ)
	
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

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		get_node(node_data["parent"]).add_child(new_object)
	
## Save given scene node
func save_scene(scene: String):
	var scene_name_splits = scene.split("/", false)
	var scene_name = scene_name_splits[scene_name_splits.size()-1].trim_suffix(".tscn")
	
	if not DirAccess.dir_exists_absolute(save_folder):
		DirAccess.make_dir_absolute(save_folder)
		
	var save_file = FileAccess.open(save_folder + scene_name + ".save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	
	if scene != "res://Scenes/Main/main.tscn":
		var current_scene_file = FileAccess.open(save_folder + "current_scene.save", FileAccess.WRITE)
		current_scene_file.store_line(scene)
	
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
			
		# Call the node's save function.
		var node_data = node.call("save")

		#serialize JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func current_scene()-> String:
	if not FileAccess.file_exists(save_folder + "current_scene.save"):
		return "res://Scenes/Main/LivingRoom/living_room.tscn"
	
	var scene = FileAccess.open(save_folder + "current_scene.save", FileAccess.READ)
	return scene.get_line()

func autosave():
	if get_tree().current_scene:
		save_scene(get_tree().current_scene.scene_file_path)
	else:
		print("No active scene, autosave skipped")
