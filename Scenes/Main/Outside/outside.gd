extends AreaScene

func _ready():
	super._ready()

func _on_door_interaction_range_body_entered(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		body.interaction_stack.add_interaction(Interaction.interaction_types.CHANGE_LOCATION, "living_room")

func _on_door_interaction_range_body_exited(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		body.interaction_stack.remove_interaction("living_room")
