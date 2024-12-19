extends Inventory
class_name CraftingInventory

var crafting_slot_node = preload("res://Scenes/Main/UI/Inventory/crafting_slot.tscn")

##Node to add the player items
@export var inventory_grid: Container
##Crafting input/output
@export var input: GridContainer
@export var output: GridContainer
@export var input_size: int = 1
@export var output_size: int = 1

@export var recipe_panel: RecipePanel
@export var recipe_button: Button
@export var crafting_button: Button
@export var type: StringName

func _ready() -> void:
	path = "res://Resources/Inventories/CraftingInventories/"
	super._ready()
	connect_recipe_panel()
	recipe_panel.hide()
		
##To instantiate container with parameters
##args[0] = id
func scene_parameters(args: Array)-> CraftingInventory:
	id = str(args[0])
	return self

func create_resource_if_not_exist():
	if not ResourceLoader.exists(path + id + ".tres"):
		inventory_data = CraftingInventoryData.new(type, input_size, output_size)
		if multiplayer.is_server():
			inventory_data.save_inventory_data(id)
	
func get_slots()-> Array:
	var slots = []
	for slot in input.get_children():
		slots.append(slot)
	for slot in output.get_children():
		slots.append(slot)
	return slots
	
func fill_grid():
	var slot
	for child in input.get_children():
		child.queue_free()
	for child in output.get_children():
		child.queue_free()
		
	for i in inventory_data.input.size():
		slot = crafting_slot_node.instantiate()
		input.add_child(slot)
		connect_input_slot(slot)
		slot.index = i
		slot.slot_type = InventoryManager.DragDropLocation.INPUT
	for i in inventory_data.output.size():
		slot = crafting_slot_node.instantiate()
		output.add_child(slot)
		connect_output_slot(slot)
		slot.index = i
		slot.slot_type = InventoryManager.DragDropLocation.OUTPUT
		

##updates the inventory, call after changes to the inventory have happened
func update():
	for i in range(0, inventory_data.input.size()):
		input.get_child(i).set_slot_data(inventory_data.input[i])
	for i in range(0, inventory_data.output.size()):
		output.get_child(i).set_slot_data(inventory_data.output[i])
	activate_crafting_button()
	if multiplayer.is_server():
		inventory_data.save_inventory_data(id)

#Transfers a stack from player inventory into the first input available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_in_input(inv_index: int):
	var slot = player_inventory.inventory_data.slot_data_table[inv_index]
	var remainder = inventory_data.add_item(slot.item, slot.quantity)
	player_inventory.inventory_data.remove_amount(inv_index, slot.quantity - remainder)
	update_all_inventories()

#Transfers a stack from input inventory out to the first available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_out_input(input_index: int):
	var slot = inventory_data.input[input_index]
	var remainder = player_inventory.inventory_data.get_add_item_remainder(slot.item, slot.quantity)
	player_inventory.inventory_data.add_item(slot.item, slot.quantity)
	inventory_data.remove_amount_input(input_index, slot.quantity - remainder)
	update_all_inventories()

#Transfers a stack from output inventory out to the first available slot
@rpc("any_peer", "call_local", "reliable")
func transfer_out_output(output_index: int):
	var slot = inventory_data.output[output_index]
	var remainder = player_inventory.inventory_data.get_add_item_remainder(slot.item, slot.quantity)
	player_inventory.inventory_data.add_item(slot.item, slot.quantity)
	inventory_data.remove_amount_output(output_index, slot.quantity - remainder)
	update_all_inventories()
	
#Transfers from container slot index to inventory index. swaps if the slot is occupied or stacks if possible
@rpc("any_peer", "call_local", "reliable")
func transfer_out_input_to_index(inv_index: int, input_index: int):
	var inv_slot = SlotData.new()
	inv_slot.item = player_inventory.inventory_data.slot_data_table[inv_index].item
	inv_slot.quantity = player_inventory.inventory_data.slot_data_table[inv_index].quantity
	var input_slot = inventory_data.input[input_index]
	var remainder = player_inventory.inventory_data.add_item_to_index(input_slot.item, input_slot.quantity, inv_index)
	if remainder == -1:
		player_inventory.inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, inv_index)
	else:
		inventory_data.remove_amount_input(input_index, input_slot.quantity - remainder)
	update_all_inventories()

#Transfers from container slot index to inventory index. swaps if the slot is occupied or stacks if possible
@rpc("any_peer", "call_local", "reliable")
func transfer_out_output_to_index(inv_index: int, output_index: int):
	var inv_slot = SlotData.new()
	inv_slot.item = player_inventory.inventory_data.slot_data_table[inv_index].item
	inv_slot.quantity = player_inventory.inventory_data.slot_data_table[inv_index].quantity
	var output_slot = inventory_data.output[output_index]
	var remainder = player_inventory.inventory_data.add_item_to_index(output_slot.item, output_slot.quantity, inv_index)
	if remainder == -1:
		player_inventory.inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, inv_index)
	else:
		inventory_data.remove_amount_output(output_index, output_slot.quantity - remainder)
	update_all_inventories()

func connect_recipe_panel():
	recipe_panel.visible = false
	recipe_panel.back.connect(_on_back_pressed)
	recipe_panel.button_create.connect(_on_recipe_button_created)
	recipe_button.pressed.connect(_on_select_recipe_pressed)
	crafting_button.pressed.connect(_on_crafting_button_pressed)

func _on_select_recipe_pressed() -> void:
	recipe_panel.open()

func _on_recipe_button_created(button: Button, index: int):
	button.pressed.connect(_on_recipe_selected.bind(index, multiplayer.get_unique_id()))


func _on_recipe_selected(index: int, player_id: int):
	return_items_to_player_inventory.rpc_id(1, player_id)
	set_active_recipe.rpc(index)
	recipe_panel.visible = false
	
#To set the recipe on all clients, return is cought on sender only
@rpc("any_peer", "call_local", "reliable")
func set_active_recipe(index: int):
	inventory_data.set_active_recipe(index)
	update_all_inventories()

func _on_back_pressed() -> void:
	recipe_panel.visible = false

##Returns the given item list to the players inventory
@rpc("any_peer", "call_local", "reliable")
func return_items_to_player_inventory(player_id: int):
	var item_list = inventory_data.get_items()
	var p_items = SaveManager.players.get(str(player_id)).inventory
	p_items.add_item_list(item_list)


#Activates the crafting button if the requirements are met
func activate_crafting_button():
	if inventory_data.active_recipe and inventory_data.can_craft():
		crafting_button.disabled = false
	else:
		crafting_button.disabled = true
		

func _on_crafting_button_pressed():
	craft.rpc()
	
@rpc("any_peer", "call_local", "reliable")
func craft():
	inventory_data.craft()
	update_all_inventories()
	
@rpc("any_peer", "call_local", "reliable")
func remove_stack(index: int):
	if index >= inventory_data.input.size() or index < 0:
		print("invalid index")
		return
	inventory_data.remove_stack(index)
	update_all_inventories()

func connect_signals():
	for child in player_inventory.item_grid.get_children():
		if not child.is_connected("transfer", transfer_in_input.rpc):
			child.transfer.connect(transfer_in_input.rpc)
	
			
	if not is_connected("mouse_entered", _on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not is_connected("mouse_exited", _on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func connect_input_slot(slot: Slot):
	slot.transfer.connect(transfer_out_input.rpc)
	
func connect_output_slot(slot: Slot):
	slot.transfer.connect(transfer_out_output.rpc)
	
	super.connect_slot(slot)
func disconnect_signals():
	for child in player_inventory.item_grid.get_children():
		if child.is_connected("transfer", transfer_in_input.rpc):
			child.transfer.disconnect(transfer_in_input.rpc)

func _on_mouse_entered() -> void:
	InventoryManager.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		InventoryManager.mouse_inside_inventory = false
