extends CraftingInventoryData
class_name AutomaticCraftingInventoryData

@export var spell_input: SlotData
@export var use_count: int = 0

func _init(p_type = "brewing", input_size = 1, output_size = 1) -> void:
	super._init(p_type, input_size, output_size)
	spell_input = SlotData.new()
	
##Adds the specified item to the spell input slot
##or stacks Items of the Same Type
##returns the remainder of items not added to the slot
##returns the full quantity as a remainder if not successfull!
func add_item_spell_input(spell: Spell, quantity: int):
	var remainder = quantity
		#calculate the available stack size and fill the stack
	if spell.id == spell_input.spell.id:
		var available_quantity = SlotData.MAX_STACK_SIZE - spell_input.quantity
		var added_quantity = min(available_quantity, remainder)
		remainder = remainder - added_quantity
		spell_input.quantity += added_quantity
	return remainder
	
##Removes the given amount from input index. If item amount is 0, keep the item data in slot
##returns false if there aren't enough items to remove
func remove_amount_spell_input(amount: int)-> bool:
	var result_quantity = spell_input.quantity - amount
	if result_quantity < 0:
		return false
	spell_input.quantity = result_quantity
	return true
	
func remove_stack_spell_input():
	spell_input.quantity = 0
	
## returns all items from every slot
func get_items()-> Array[SlotData]:
	var item_list = super.get_items()
	if spell_input.quantity > 0:
		item_list.append(spell_input)
	return item_list
	
func can_craft()-> bool:
	if not super.can_craft():
		return false
	if use_count == 0 and spell_input.quantity == 0:
		return false
	return true
	
func craft():
	super.craft()
	if use_count <= 0:
		spell_input.quantity -= 1
		use_count = spell_input.item.use_count
	use_count -= 1
