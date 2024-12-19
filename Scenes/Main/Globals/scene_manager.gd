extends Node2D
var scene_path = "res://Scenes/Main/"
var scenes_in_tree: Dictionary = {}

@rpc("any_peer", "call_local", "reliable")
func open_scene(scene: StringName):
	scene = scene.to_snake_case()
	# Check if scene is already open
	var scene_instance = scenes_in_tree.get(scene)
	if !scene_instance: # not open
		scene_instance = load(scene_path + scene + ".tscn").instantiate()
		scene_instance.name = scene.to_pascal_case()
		scenes_in_tree.get_or_add(scene, scene_instance)
		get_tree().get_current_scene().add_child(scene_instance, true)
		
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

## Call after a player joins an area scene to show the correct one
@rpc("authority", "call_local", "reliable")
func show_player_scene(scenes: Array):
	var player_id = multiplayer.get_unique_id()
	var scene_instance
	for scene in scenes:
		scene_instance = get_node("/root/Main/%s" % scene.to_pascal_case())
		if scene_instance.has_node(str(player_id)):
			scene_instance.show()
		else:
			scene_instance.hide()
		
	 
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
		
