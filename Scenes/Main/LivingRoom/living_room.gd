extends AreaScene

var inventory_type: StringName = "container"

func _ready():
	super._ready()
	
func _enter_tree() -> void:
	#Offset Scene (TODO better location handling)
	position = Vector2(0, 0)
func _on_door_body_entered(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		body.interaction_stack.add_interaction(Interaction.interaction_types.CHANGE_LOCATION, "outside")
		
func _on_door_body_exited(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		body.interaction_stack.remove_interaction("outside")

func _on_storage_interaction_player_entered_range(player: Player) -> void:
	var inventory_id := 0 #Default inv
	var grid_size := 50 #TODO make grid_size dynamic?
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, inventory_type, inventory_id, [inventory_id, grid_size])

func _on_storage_interaction_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(inventory_type)
