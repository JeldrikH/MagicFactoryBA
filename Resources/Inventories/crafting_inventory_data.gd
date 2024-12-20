##Class for a Brewing Inventory
extends InventoryData
class_name CraftingInventoryData

@export var input: Array[CraftingSlotData]
@export var output: Array[CraftingSlotData]
@export var type: StringName
@export var active_recipe: Recipe
var recipe_list: Array[Recipe]

func _init(p_type = "brewing", input_size = 1, output_size = 1) -> void:
	self.type = p_type
	_load_recipes()
	_fill_grid([input_size, output_size])
	
#helper function to fill the inventory with slots
func _fill_grid(inventory_size: Array[int]):
	while input.size() < inventory_size[0]:
		input.append(CraftingSlotData.new())
	while output.size() < inventory_size[1]:
		output.append(CraftingSlotData.new())
		
##Saves the current state of the inventory with the specified ID
@rpc("authority", "call_local", "reliable", 1)
func save_inventory_data(inventory_id: String, save_folder_path: String = "res://Resources/Inventories/CraftingInventories/"):
	ResourceSaver.save(self, save_folder_path + inventory_id + ".tres")
		
##Adds the specified item to the corresponding input slot
##or stacks Items of the Same Type
##returns the remainder of items not added to the slot
##returns the full quantity as a remainder if not successfull!
func add_item(item: Item, quantity: int) -> int:
	var remainder = quantity
	for slot_data in input:
		#calculate the available stack size and fill the stack
		if item.id == slot_data.item.id:
			var available_quantity = SlotData.MAX_STACK_SIZE - slot_data.quantity
			var added_quantity = min(available_quantity, remainder)
			remainder = remainder - added_quantity
			slot_data.quantity += added_quantity
	return remainder

##Removes the given amount from input index. If item amount is 0, keep the item data in slot
##returns false if there aren't enough items to remove
func remove_amount_input(index: int, amount: int)-> bool:
	var result_quantity = input[index].quantity - amount
	if result_quantity < 0:
		return false
	input[index].quantity = result_quantity
	return true
	
##Removes the given amount from input index. If item amount is 0, keep the item data in slot
##returns false if there aren't enough items to remove
func remove_amount_output(index: int, amount: int)-> bool:
	var result_quantity = output[index].quantity - amount
	if result_quantity < 0:
		return false
	output[index].quantity = result_quantity
	return true

func remove_stack_input(index: int):
	input[index].quantity = 0

func remove_stack_output(index: int):
	output[index].quantity = 0
	
func get_items()-> Array[SlotData]:
	var item_list:Array[SlotData] = []
	for slotdata in input:
		if slotdata.quantity > 0:
			item_list.append(slotdata)
	for slotdata in output:
		if slotdata.quantity > 0:
			item_list.append(slotdata)
	return item_list
	
##Selects a recipe and clears input and output
func set_active_recipe(index: int):
	clear_input()
	clear_output()
	active_recipe = recipe_list[index]
	for i in active_recipe.ingredients.size():
		input[i].item = active_recipe.ingredients[i][0]
		input[i].required_amount = active_recipe.ingredients[i][1]
			
	for i in active_recipe.output.size():
		output[i].item = active_recipe.output[i][0]
		output[i].required_amount = active_recipe.output[i][1]

func can_craft()-> bool:
	#quit if input is not enough
	for i in range(active_recipe.ingredients.size()):
		if input[i].quantity < active_recipe.ingredients[i][1]:
			return false
	#quit if output is full
	for i in range(active_recipe.output.size()):
		if output[i].quantity > output[i].MAX_STACK_SIZE - active_recipe.output[i][1]:
			return false
	return true
	
##Crafts the active recipe
func craft():
	#remove items from input
	for i in range(active_recipe.ingredients.size()):
		if not remove_amount_input(i, active_recipe.ingredients[i][1]):
			return false
	
	for i in range(active_recipe.output.size()):
		output[i].quantity += active_recipe.output[i][1]
		
##Clears the input and returns the removed items
func clear_input()-> Array[SlotData]:
	var cleared_input: Array[SlotData] = []
	for i in input.size():
		cleared_input.append(SlotData.new(input[i].item, input[i].quantity))
		input[i] = CraftingSlotData.new()
	return cleared_input

##Clears the output and returns the removed items
func clear_output()-> Array[SlotData]:
	var cleared_output: Array[SlotData] = []
	for i in output.size():
		cleared_output.append(SlotData.new(output[i].item, output[i].quantity))
		output[i] = CraftingSlotData.new()
	return cleared_output

##deletes item at given index
func delete_item_input(index: int):
	input[index].quantity = 0
	
##deletes item at given index
func delete_item_output(index: int):
	output[index].quantity = 0
	
func _load_recipes():
	recipe_list = []
	var recipe: Recipe
	var recipe_folder = DirAccess.get_files_at("res://Resources/Recipes/")
	for recipe_file in recipe_folder:
		recipe = load("res://Resources/Recipes/" + recipe_file)
		if recipe.station_type == type:
			recipe_list.append(recipe)
