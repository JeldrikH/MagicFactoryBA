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
	#add_child(inventory_instance)
	inventory_instance.connect("updated", _inventory_updated)

func _inventory_updated():
	if inventory_instance.inventory_data.get_items().size() == 0 and multiplayer.is_server():
		inventory_instance.close()
		Deconstructor.deconstruct(name, get_parent().name)
