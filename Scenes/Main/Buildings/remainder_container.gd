extends Building

var size: int
var inventory_instance
## takes args: [item_list] (the items added to the inventory)
func scene_parameters(args: Array)-> Building:
	size = args[0]
	return self

## Create own inventory instance to check if it is empty and add the items
func create_building_inventory_instance():
	inventory_instance = inventory.instantiate().scene_parameters([id, size])
	inventory_instance.connect("updated", _inventory_updated)
	
func _ready() -> void:
	super._ready()
	

func _inventory_updated():
	if inventory_instance.inventory_data.get_items().size() == 0:
		inventory_instance.close()
		Deconstructor.deconstruct(self)


func _on_interaction_range_player_entered_range(player: Player) -> void:
	#opens the default brewing inventory data [id = 0]
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, inventory, id, [id])

func _on_interaction_range_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(inventory, id)
