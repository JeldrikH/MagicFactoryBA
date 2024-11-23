extends Resource
class_name HotbarData

const inventory_data = preload("res://Resources/Inventories/player_items.tres")

@export var slot_data_table: Array[SlotData]

func save_hotbar_data():
	ResourceSaver.save(self, "res://Resources/Inventories/player_hotbar.tres")
#updates the quantity of the item slot
func update_quantity():
	for slot in slot_data_table:
		if slot.item:
			slot.quantity = 0
			for item in inventory_data.slot_data_table:
				if item == slot.item:
					slot.quantity += item.quantity
				
#links the specified item to the target hotbar index (old entries on that index are overwritten!)
#item_id: i.e "frog_leg"
func link_item_to_index(item_id: String, index: int):
	if item_id.length() > 0:
		var item_path = "res://Resources/Items/"+item_id+".tres"
		var item = load(item_path)
		slot_data_table[index].item = item
		update_quantity()
	else:
		delete_item(index)
#moves the item to the target index,
#swaps the items if there is another one on the target index
func move_item(start_index: int, target_index: int):
	var swapped_item = slot_data_table[target_index]
	slot_data_table[target_index] = slot_data_table[start_index]
	slot_data_table[start_index] = swapped_item
	update_quantity()

#deletes item at given index
func delete_item(index: int):
	slot_data_table[index].item = null
	update_quantity()
