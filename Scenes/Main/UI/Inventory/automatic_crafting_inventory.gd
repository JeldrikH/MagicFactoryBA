extends CraftingInventory
class_name AutomaticCraftingInventory

@export var spell_input: Control
var slot_node = preload("res://Scenes/Main/UI/Inventory/slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_resource_if_not_exist()
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func update():
	super.update()
	spell_input.set_slot_data(inventory_data.spell_input)
	
func create_resource_if_not_exist():
	if not ResourceLoader.exists(path + str(id) + ".tres"):
		var data = AutomaticCraftingInventoryData.new(type, input_size, output_size)
		data.save_inventory_data(str(id))
		
func transfer_in_spell_input(inv_index: int):
	var slot = player_items.inventory_data.slot_data_table[inv_index]
	if slot.item is Spell:
		var remainder = inventory_data.add_item_spell_input(slot.item, slot.quantity)
		player_items.inventory_data.remove_amount(inv_index, slot.quantity - remainder)
	update()
	
func transfer_out_spell_input_to_index(inv_index: int):
	var inv_slot = SlotData.new()
	inv_slot.item = player_items.inventory_data.slot_data_table[inv_index].item
	inv_slot.quantity = player_items.inventory_data.slot_data_table[inv_index].quantity
	var input_slot = inventory_data.spell_input
	var remainder = player_items.inventory_data.add_item_to_index(input_slot.item, input_slot.quantity, inv_index)
	if remainder == -1:
		inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, inv_index)
	else:
		inventory_data.remove_amount_spell_input(input_slot.quantity - remainder)
	update()
	
func drag_drop():
	var start_is_spell_input = false
	var target_is_spell_input = false
	var start_index: int = -1
	var target_index: int = -1
	
	if start_index < 0 and spell_input.is_selected:
		start_index = 0
		start_is_spell_input = true
	if target_index < 0 and spell_input.is_drag_drop_target:
		target_index = 0
		target_is_spell_input = true
		
	#Search the player inventory
	for child in player_items.item_grid.get_children():
		if start_index < 0 and child.is_selected:
			start_index = child.get_index()
		if target_index < 0 and child.is_drag_drop_target:
			target_index = child.get_index()
	
	##Transfer in to input
	if not start_is_spell_input and target_is_spell_input and start_index >= 0:
		player_items.item_grid.get_child(start_index).is_selected = false
		spell_input.is_drag_drop_target = false
		transfer_in_spell_input(start_index)
		return
	
	##Transfer out from input
	if start_is_spell_input and not target_is_spell_input and target_index >= 0:
		input.get_child(start_index).is_selected = false
		player_items.item_grid.get_child(target_index).is_drag_drop_target = false
		transfer_out_spell_input_to_index(target_index)
		return
	super.drag_drop()
