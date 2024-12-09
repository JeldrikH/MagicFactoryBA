extends Node2D
var scene_path = "res://Scenes/Main/"
var scenes_in_tree: Dictionary = {}

func open_scene(scene: StringName)-> bool:
	scene = scene.to_snake_case()
	var scene_opened = false
	var scene_instance = scenes_in_tree.get(scene)
	if !scene_instance:
		scene_instance = load(scene_path + scene + ".tscn").instantiate()
		scene_instance.name = scene.to_pascal_case()
		get_tree().get_current_scene().add_child(scene_instance, true)
		scenes_in_tree.get_or_add(scene, scene_instance)
		if !multiplayer.is_server():
			open_scene_background.rpc_id(1, scene)
		scene_opened =  true
	scene_instance.visible = true
	return scene_opened

@rpc("authority", "call_local", "reliable")
func open_scene_background(scene: StringName):
	scene = scene.to_snake_case()
	if open_scene(scene):
		scenes_in_tree.get(scene).visible = false
	
func close_scene(scene: StringName):
	scene = scene.to_snake_case()
	if is_scene_open(scene):
		get_tree().get_current_scene().get_node(str(scene)).queue_free()
		scenes_in_tree.erase(scene)
	
func is_scene_open(scene: StringName):
	scene = scene.to_snake_case()
	if scenes_in_tree.find_key(scene):
		return true
	return false

## Called after a player joins an area scene to the the correct one
func show_player_scene():
	var player_id = multiplayer.get_unique_id()
	for scene in scenes_in_tree.values():
		if scene.has_node(str(player_id)):
			scene.visible = true
			return
		scene.visible = false
		
## Called by host every autosave
func _close_inactive_scenes():
	for scene in scenes_in_tree.keys():
		var is_scene_active = false
		for player in SaveManager.players.values():
			if player.is_online and player.current_scene == scene:
				is_scene_active = true
				break
		if is_scene_active:
			continue
		close_scene(scene)
