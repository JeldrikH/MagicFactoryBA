##Class for a Brewing Inventory
extends Resource
class_name CraftingInventoryData

@export var input: Array[CraftingSlotData]
@export var output: Array[CraftingSlotData]
@export var type: StringName
@export var active_recipe: Recipe
var recipe_list: Array[Recipe]

func _init(p_type = "brewing", input_size = 1, output_size = 1) -> void:
	self.type = p_type
	_load_recipes()
	_fill_grid(input_size, output_size)
	
#helper function to fill the inventory with slots
func _fill_grid(input_size: int, output_size: int):
	while input.size() < input_size:
		input.append(CraftingSlotData.new())
	while output.size() < output_size:
		output.append(CraftingSlotData.new())
		
##Saves the current state of the inventory with the specified ID
func save_inventory_data(inventory_id: String):
	var save_folder_path = "res://Resources/Inventories/CraftingInventories/"
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
	
##Selects a recipe and returns the cleared input and output (Check for quantity to be >0 to avoid bugged items)
func set_active_recipe(recipe: Recipe)-> Array[CraftingSlotData]:
	var cleared_slots = clear_input()
	cleared_slots += clear_output()
	active_recipe = recipe
	for i in recipe.ingredients.size():
		input[i].item = recipe.ingredients[i][0]
		input[i].required_amount = recipe.ingredients[i][1]
			
	for i in recipe.output.size():
		output[i].item = recipe.output[i][0]
		output[i].required_amount = recipe.output[i][1]
	return cleared_slots

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
func clear_input()-> Array[CraftingSlotData]:
	var cleared_input = input.duplicate()
	for i in input.size():
		input[i] = CraftingSlotData.new()
	return cleared_input

##Clears the output and returns the removed items
func clear_output()-> Array[CraftingSlotData]:
	var cleared_output = output.duplicate()
	for i in output.size():
		output[i] = CraftingSlotData.new()
	return cleared_output

func _load_recipes():
	recipe_list = []
	var recipe: Recipe
	var recipe_folder = DirAccess.get_files_at("res://Resources/Recipes/")
	for recipe_file in recipe_folder:
		recipe = load("res://Resources/Recipes/" + recipe_file)
		if recipe.station_type == type:
			recipe_list.append(recipe)
