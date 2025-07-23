extends AreaScene
var living_room := load("res://Scenes/Main/LivingRoom/living_room.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUGPORT"):
		player_changes_scene.rpc_id(1, multiplayer.get_unique_id(), "Outside", "LivingRoom")


func _on_door_interaction_range_body_entered(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		print("test %s" % living_room.resource_path)
		print(living_room.resource_name)
		body.interaction_stack.add_interaction(Interaction.interaction_types.CHANGE_LOCATION, living_room)

func _on_door_interaction_range_body_exited(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		body.interaction_stack.remove_interaction(living_room)
