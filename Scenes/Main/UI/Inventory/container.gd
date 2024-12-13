extends Inventory
class_name ItemContainer

var player_items: Inventory
##Node to add the player items
@export var inventory_grid: Container

func _ready() -> void:
	path = "res://Resources/Inventories/Containers/"
	
	# Finds the current players inventory
	player_items = get_parent().get_parent().player_items
	
	super._ready()
	visible = false
	

func _process(delta: float) -> void:
	super._process(delta)

func input_handler():
	super.input_handler()
	if Input.is_action_just_pressed("INVENTORY"):
		close()


##updates the inventory, call after changes to the inventory have happened
func update():
	super.update()
	
func open():
	super.open()
	player_items.open()
	

#Transfers a stack from player inventory into the first available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_in(inv_index: int):
	var slot = player_items.inventory_data.slot_data_table[inv_index]
	var remainder = inventory_data.get_add_item_remainder(slot.item, slot.quantity)
	inventory_data.add_item(slot.item, slot.quantity)
	player_items.inventory_data.remove_amount(inv_index, slot.quantity - remainder)
	update_all_inventories()

#Transfers a stack from container inventory out to the first available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_out(container_index: int):
	var slot = inventory_data.slot_data_table[container_index]
	var remainder = player_items.inventory_data.get_add_item_remainder(slot.item, slot.quantity)
	player_items.inventory_data.add_item(slot.item, slot.quantity)
	inventory_data.remove_amount(container_index, slot.quantity - remainder)
	update_all_inventories()

#Transfers from inventory index to container slot index. swaps if the slot is occupied or stacks if possible
@rpc("any_peer", "call_local", "reliable")
func transfer_in_index(inv_index: int, container_index: int):
	var inv_slot = player_items.inventory_data.slot_data_table[inv_index]
	var container_slot = SlotData.new()
	container_slot.item = inventory_data.slot_data_table[container_index].item
	container_slot.quantity = inventory_data.slot_data_table[container_index].quantity
	var remainder = inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, container_index)
	if remainder == -1:
		player_items.inventory_data.add_item_to_index(container_slot.item, container_slot.quantity, inv_index)
	else:
		player_items.inventory_data.remove_amount(inv_index, inv_slot.quantity - remainder)
	update_all_inventories()

#Transfers from container slot index to inventory index. swaps if the slot is occupied or stacks if possible
@rpc("any_peer", "call_local", "reliable")
func transfer_out_index(inv_index: int, container_index: int):
	var inv_slot = SlotData.new()
	inv_slot.item = player_items.inventory_data.slot_data_table[inv_index].item
	inv_slot.quantity = player_items.inventory_data.slot_data_table[inv_index].quantity
	var container_slot = inventory_data.slot_data_table[container_index]
	var remainder = player_items.inventory_data.add_item_to_index(container_slot.item, container_slot.quantity, inv_index)
	if remainder == -1:
		inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, container_index)
	else:
		inventory_data.remove_amount(container_index, container_slot.quantity - remainder)
	update_all_inventories()

func drag_drop():
	var start_is_player_inventory = false
	var target_is_player_inventory = false
	var start_index = -1
	var target_index = -1
	
	for child in item_grid.get_children():
		if start_index < 0 and child.is_selected:
			start_index = child.get_index()
		if target_index < 0 and child.is_drag_drop_target:
			target_index = child.get_index()
			
	for child in player_items.item_grid.get_children():
		if start_index < 0 and child.is_selected:
			start_index = child.get_index()
			start_is_player_inventory = true
		if target_index < 0 and child.is_drag_drop_target:
			target_index = child.get_index()
			target_is_player_inventory = true
	
	#Move items inside Container
	if not start_is_player_inventory and not target_is_player_inventory and start_index >= 0 and target_index >= 0 and start_index != target_index:
		item_grid.get_child(start_index).is_selected = false
		item_grid.get_child(target_index).is_drag_drop_target = false
		move_item.rpc(start_index, target_index)
		return
	
	#Move items inside player inventory
	if start_is_player_inventory and target_is_player_inventory and start_index != target_index:
		player_items.item_grid.get_child(start_index).is_selected = false
		player_items.item_grid.get_child(target_index).is_drag_drop_target = false
		player_items.move_item.rpc(start_index, target_index)
		return
	
	#move item into container
	if start_is_player_inventory and not target_is_player_inventory and target_index >= 0:
		player_items.item_grid.get_child(start_index).is_selected = false
		item_grid.get_child(target_index).is_drag_drop_target = false
		transfer_in_index.rpc(start_index, target_index)
		return
	
	#move item out of the container
	if not start_is_player_inventory and target_is_player_inventory and start_index >= 0:
		item_grid.get_child(start_index).is_selected = false
		player_items.item_grid.get_child(target_index).is_drag_drop_target = false
		transfer_out_index.rpc(target_index, start_index)
		return
	update()
	
#Reconnects signals after updating the inventory
func connect_signals():
	super.connect_signals()
	for child in player_items.item_grid.get_children():
		if not child.is_connected("transfer", transfer_in):
			child.transfer.connect(transfer_in.rpc)
	for child in item_grid.get_children():
		if not child.is_connected("transfer", transfer_out):
			child.transfer.connect(transfer_out.rpc)
