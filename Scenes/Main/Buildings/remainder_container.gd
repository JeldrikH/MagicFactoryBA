extends Building

var item_list: Array[SlotData]

## takes args: [item_list] (the items added to the inventory)
func scene_parameters(args: Array)-> Building:
	item_list = args[0]
	return self

func load_inventory():
	inventory = load("res://Scenes/Main/UI/Inventory/" + inventory_type +".tscn").instantiate().scene_parameters([id, item_list.size()])
	$Inventory.add_child(inventory)
	inventory.add_item_list.rpc(item_list)
	inventory.visible = false
	inventory.connect("updated", _inventory_updated)

func _inventory_updated():
	if inventory.inventory_data.get_items().size() == 0:
		inventory.close()
		Deconstructor.deconstruct(self)
