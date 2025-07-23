extends AreaScene

var container_inventory: PackedScene = preload("res://Scenes/Main/UI/Inventory/container.tscn")
var outside: PackedScene = preload("res://Scenes/Main/Outside/outside.tscn")

func _on_door_body_entered(body: Node2D) -> void:
	if body is Player and multiplayer.is_server():
		body.interaction_stack.add_interaction(Interaction.interaction_types.CHANGE_LOCATION, outside)
		
func _on_door_body_exited(body: Node2D) -> void:
	if body is Player and multiplayer.is_server():
		body.interaction_stack.remove_interaction(outside)

func _on_storage_interaction_player_entered_range(player: Player) -> void:
	var inventory_id := 0 #Default inv
	var grid_size := 50 #Debug make grid_size dynamic?
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, container_inventory, inventory_id, [inventory_id, grid_size])

func _on_storage_interaction_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(container_inventory)
