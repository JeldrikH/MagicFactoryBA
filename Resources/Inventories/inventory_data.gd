extends Resource
class_name InventoryData

##Array of slots that can contain items
@export var slot_data_table: Array[SlotData] = []

func _init(inventory_size = 84) -> void:
	_fill_grid(inventory_size)
	

#helper function to fill the inventory with slots
func _fill_grid(inventory_size: int):
	while slot_data_table.size() < inventory_size:
		slot_data_table.append(SlotData.new())
		
##Saves the current state of the inventory with the specified ID
func save_inventory_data(save_folder_path: String = "res://Resources/Inventories/", inventory_id: String = ""):
	if inventory_id != "":
		ResourceSaver.save(self, save_folder_path + inventory_id + ".tres")
	
##Adds the set amount of slots to the inventory
func add_slots(amount: int):
	_fill_grid(slot_data_table.size() + amount)
	
##Adds the specified item to the first free slot
##or stacks Items of the Same Type
##returns the remainder of items not added to the inventory
##returns the full quantity as a remainder if not successfull!
func add_item(item: Item, quantity: int) -> int:
	var remainder = quantity
	for slot_data in slot_data_table:
		if remainder == 0:
			break
		# Fill empty slot
		if slot_data.quantity == 0:
			slot_data.item = item
			slot_data.quantity = min(remainder, SlotData.MAX_STACK_SIZE)
			remainder = remainder - slot_data.quantity
			continue
		# Fill slot with same item
		# calculate the available stack size and fill the stack
		if item.id == slot_data.item.id:
			var available_quantity = SlotData.MAX_STACK_SIZE - slot_data.quantity
			var added_quantity = min(available_quantity, remainder)
			remainder = remainder - added_quantity
			slot_data.quantity += added_quantity
	return remainder

##Adds the specified item to the first free slot
##returns false if not successfull!
func add_item_no_stacking(item: Item, quantity: int) -> int:
	for slot_data in slot_data_table:
		if slot_data.quantity == 0 and quantity > 0:
			slot_data.item = item
			slot_data.quantity = quantity
			return true
	return false
		
##adds the specified item to the target index 
##Stacks up Items of the same type
##returns the quantity remainder of the initial stack
##if the stacks are incompatible returns -1
func add_item_to_index(item: Item, quantity: int, index: int):
	var remainder = quantity
	if item.id == slot_data_table[index].item.id or slot_data_table[index].item.id == "":
			var available_quantity = SlotData.MAX_STACK_SIZE - slot_data_table[index].quantity
			remainder = max(0, remainder - available_quantity)
			quantity -= remainder
			slot_data_table[index].item = item
			slot_data_table[index].quantity += quantity
			return remainder
	slot_data_table[index].item = item
	slot_data_table[index].quantity = quantity
	return -1

func get_items()-> Array[SlotData]:
	var item_list: Array[SlotData] = []
	for slotdata in slot_data_table:
		if slotdata.quantity > 0:
			item_list.append(slotdata)
	return item_list
	
##splits the stack in half and adds the new stack to the first free slot
func split_stack_half(index: int):
	@warning_ignore("integer_division")
	var half = slot_data_table[index].quantity / 2
	if add_item_no_stacking(slot_data_table[index].item, half):
		remove_amount(index, half)
	
##moves the item to the target index,[br]
##swaps the items if there is another one on the target index
func move_item(start_index: int, target_index: int):
	var target_stack = slot_data_table[target_index]
	if _stack(start_index, target_index):
		return
	slot_data_table[target_index] = slot_data_table[start_index]
	slot_data_table[start_index] = target_stack

##If the 2 Stacks can be added to another do so and return true
func _stack(start_index: int, target_index: int) -> bool:
	if (slot_data_table[start_index].item == slot_data_table[target_index].item and 
	slot_data_table[start_index].item.stackable): 
		
		if slot_data_table[target_index].quantity == SlotData.MAX_STACK_SIZE:
			return false
			
		var added_value = slot_data_table[target_index].quantity + slot_data_table[start_index].quantity
		
		if added_value > SlotData.MAX_STACK_SIZE:
			slot_data_table[target_index].quantity = SlotData.MAX_STACK_SIZE
			slot_data_table[start_index].quantity = added_value - SlotData.MAX_STACK_SIZE
		else:
			slot_data_table[target_index].quantity += slot_data_table[start_index].quantity
			slot_data_table[start_index] = SlotData.new()
		return true
	return false

##Removes the given amount from index. If item amount is 0, remove Item from Slot
func remove_amount(index: int, amount: int):
	slot_data_table[index].quantity = max(0, slot_data_table[index].quantity - amount)
	if slot_data_table[index].quantity == 0:
		slot_data_table[index].item = Item.new()
		
##deletes item at given index
func delete_item(index: int):
	slot_data_table[index] = SlotData.new()
