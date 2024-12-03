extends Node2D

var player: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.load_scene(self.scene_file_path)
	Globals.sort_children_by_y_pos(self)
	##DEBUG change to false later
	Globals.allow_building = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_player_occlusion()

##objects need to be sorted by Y position for this to work.
func _player_occlusion():
	## Skip if player is not in scene
	if !player.is_inside_tree():
		return
	for child in get_children():
		if "position" in child:
			if player.position[1] > child.position[1] and player.get_index() < child.get_index():
				move_child(player, child.get_index())
			elif player.position[1] < child.position[1] and player.get_index() > child.get_index():
				move_child(player, child.get_index())



func _on_door_body_entered(body: Node2D) -> void:
	if body is Player:
		body.position = $EnterRoomPosition.position
		SaveManager.save_scene(self.scene_file_path)
		get_tree().change_scene_to_file.bind("res://Scenes/Main/Outside/outside.tscn").call_deferred()


func _on_child_entered_tree(node: Node) -> void:
	Globals.sort_children_by_y_pos.call_deferred(self)
	if node is Player:
		player = node
