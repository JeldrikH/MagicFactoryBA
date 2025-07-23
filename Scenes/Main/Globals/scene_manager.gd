extends Node2D
var scene_path = "res://Scenes/Main/"
var scenes_in_tree: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func open_scene_by_name(scene: StringName):
	scene = scene.to_snake_case()
	# Check if scene is already open
	var scene_instance = scenes_in_tree.get(scene)
	if !scene_instance: # not open
		scene_instance = load("res://Scenes/Main/%s/%s.tscn" % [scene.to_pascal_case(), scene]).instantiate()
		scene_instance.name = scene.to_pascal_case()
		scenes_in_tree.get_or_add(scene, scene_instance)
		get_tree().get_current_scene().add_child(scene_instance, true)
	scene_instance.hide()
	return scene_instance
	
@rpc("any_peer", "call_local", "reliable")
func open_packed_scene(packed_scene: PackedScene):
	# Check if scene is already open
	var scene_instance = scenes_in_tree.get(packed_scene)
	if !scene_instance: # not open
		scene_instance = packed_scene.instantiate()
		scene_instance.name = get_scene_name(packed_scene).to_pascal_case()
		print(packed_scene.resource_name)
		scenes_in_tree.get_or_add(scene_instance.name, scene_instance)
		get_tree().get_current_scene().add_child(scene_instance, true)
	scene_instance.hide()
	return scene_instance
	
@rpc("authority", "call_local", "reliable")
func close_scene(scene: StringName):
	scene = scene.to_snake_case()
	if is_scene_open(scene):
		get_tree().get_current_scene().get_node(str(scene.to_pascal_case())).queue_free()
		scenes_in_tree.erase(scene)
	
func is_scene_open(scene: StringName):
	scene = scene.to_snake_case()
	if scenes_in_tree.get(scene):
		return true
	return false
		
	 
## Called by host every autosave
func _close_inactive_scenes():
	for scene in scenes_in_tree.keys():
		var is_scene_active = false
		for player in SaveManager.players.values():
			if player.is_online and player.current_scene.to_snake_case() == scene:
				is_scene_active = true
				break
		if not is_scene_active:
			close_scene(scene)
		
func get_scene_name(packed_scene: PackedScene) -> String:
	var path := packed_scene.resource_path
	if path.is_empty():
		# Szenen, die nicht aus einer Datei geladen wurden (z. B. im Script erzeugt)
		return "UnnamedScene_%s" % str(packed_scene.get_instance_id())
	else:
		# Extrahiere den Dateinamen ohne Endung aus dem Pfad
		return path.get_file().get_basename()
