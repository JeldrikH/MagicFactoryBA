extends AreaScene

var container_inventory = preload("res://Scenes/Main/UI/Inventory/container.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	##DEBUG change to false later
	is_building_allowed = true

func _on_door_body_entered(body: Node2D) -> void:
	if body is Player and multiplayer.is_server():
		player_changes_scene(body.player_id, "Outside")
		SaveManager.save_scene(name)

func _on_storage_interaction_player_entered_range(player: Player) -> void:
	#opens the default container inventory data [id = 0, grid_size = 50] #Debug make grid_size dynamic?
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, container_inventory, 0, [0, 50])

func _on_storage_interaction_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(container_inventory, 0)
