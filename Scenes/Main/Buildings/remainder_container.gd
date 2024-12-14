extends Building
class_name RemainderContainer

var size: int

func _ready() -> void:
	super._ready()
	check_if_init_done()

## Prevents the Container from deleting itself before items got added
## Only executed on host
func check_if_init_done():
	if multiplayer.is_server():
		Globals.item_added.connect(_connect_inventory)
## Create own inventory instance to check if it is empty and add the items
func _connect_inventory(inventory: Inventory):
	if inventory.id == name:
		Globals.inventory_updated.connect(_inventory_updated)
		Globals.item_removed.connect(_item_removed)
		Globals.item_added.disconnect(_connect_inventory)

func _inventory_updated(inventory: Inventory):
	if inventory.id == name and inventory.inventory_data.get_items().size() == 0:
		Globals.close_inventories_with_id.rpc(inventory.id)
		Deconstructor.deconstruct(name, get_parent().name)

func _item_removed(inventory: Inventory):
	if inventory.id == name:
		inventory.remove_slot.rpc()
