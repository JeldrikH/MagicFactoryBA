extends Node2D
var current_scene_instance
var parent

func _ready() -> void:
	current_scene_instance = _find_current_scene_instance()
	parent = get_parent()

func save()-> Dictionary:
	var save_dict = {
		"filename" : parent.get_scene_file_path(),
		"current_scene" : current_scene_instance.name,
		"parent" : parent.get_parent().get_path(),
		"pos_x" : parent.position.x,
		"pos_y" : parent.position.y,
		"id" : parent.id,
		"name" : parent.name
	}
	return save_dict
	
func _find_current_scene_instance() -> Node2D:
	var node = self.get_parent()
	while node:
		if node.is_in_group("scenes"):
			return node
		node = node.get_parent()
	return null
