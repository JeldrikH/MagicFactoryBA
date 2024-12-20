extends Inventory
class_name ItemContainer

##Node to add the player items
@export var inventory_grid: Container

func fill_grid():
	for child in item_grid.get_children():
		child.queue_free()
	for i in inventory_data.slot_data_table.size():
		var slot = slot_node.instantiate()
		slot.slot_type = InventoryManager.DragDropLocation.CONTAINER
		slot.set_slot_data(inventory_data.slot_data_table[i])
		item_grid.add_child(slot, true)
		slot.index = i
		
#Transfers a stack from player inventory into the first available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_in(inv_index: int):
	var slot = player_inventory.inventory_data.slot_data_table[inv_index]
	var remainder = inventory_data.get_add_item_remainder(slot.item, slot.quantity)
	inventory_data.add_item(slot.item, slot.quantity)
	player_inventory.inventory_data.remove_amount(inv_index, slot.quantity - remainder)
	update_all_inventories()

#Transfers a stack from container inventory out to the first available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_out(container_index: int):
	var slot = inventory_data.slot_data_table[container_index]
	var remainder = player_inventory.inventory_data.get_add_item_remainder(slot.item, slot.quantity)
	player_inventory.inventory_data.add_item(slot.item, slot.quantity)
	inventory_data.remove_amount(container_index, slot.quantity - remainder)
	update_all_inventories()
	InventoryManager.item_removed.emit(self)

#Transfers from inventory index to container slot index. swaps if the slot is occupied or stacks if possible
@rpc("any_peer", "call_local", "reliable")
func transfer_in_index(inv_index: int, container_index: int):
	var inv_slot = player_inventory.inventory_data.slot_data_table[inv_index]
	var container_slot = SlotData.new()
	container_slot.item = inventory_data.slot_data_table[container_index].item
	container_slot.quantity = inventory_data.slot_data_table[container_index].quantity
	var remainder = inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, container_index)
	if remainder == -1:
		player_inventory.inventory_data.add_item_to_index(container_slot.item, container_slot.quantity, inv_index)
	else:
		player_inventory.inventory_data.remove_amount(inv_index, inv_slot.quantity - remainder)
	update_all_inventories()

#Transfers from container slot index to inventory index. swaps if the slot is occupied or stacks if possible
@rpc("any_peer", "call_local", "reliable")
func transfer_out_index(inv_index: int, container_index: int):
	var inv_slot = SlotData.new()
	inv_slot.item = player_inventory.inventory_data.slot_data_table[inv_index].item
	inv_slot.quantity = player_inventory.inventory_data.slot_data_table[inv_index].quantity
	var container_slot = inventory_data.slot_data_table[container_index]
	var remainder = player_inventory.inventory_data.add_item_to_index(container_slot.item, container_slot.quantity, inv_index)
	if remainder == -1:
		inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, container_index)
	else:
		inventory_data.remove_amount(container_index, container_slot.quantity - remainder)
	update_all_inventories()
	InventoryManager.item_removed.emit(self)
	

func delete_confirmed(index: int, _slot_type: InventoryManager.DragDropLocation):
	delete_item.rpc(index)
			
#Reconnects signals after updating the inventory
func connect_signals():
	super.connect_signals()
	for child in player_inventory.item_grid.get_children():
		if not child.is_connected("transfer", transfer_in.rpc):
			child.transfer.connect(transfer_in.rpc)
	for child in item_grid.get_children():
		if not child.is_connected("transfer", transfer_out.rpc):
			child.transfer.connect(transfer_out.rpc)

func disconnect_signals():
	for child in player_inventory.item_grid.get_children():
		if child.is_connected("transfer", transfer_in.rpc):
			child.transfer.disconnect(transfer_in.rpc)
