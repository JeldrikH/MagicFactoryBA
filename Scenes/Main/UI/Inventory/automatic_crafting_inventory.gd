extends CraftingInventory
class_name AutomaticCraftingInventory

@export var spell_input: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	configure_spell_input()

func update():
	super.update()
	spell_input.set_slot_data(inventory_data.spell_input)
	
func create_resource_if_not_exist():
	if not ResourceLoader.exists(path + str(id) + ".tres"):
		inventory_data = AutomaticCraftingInventoryData.new(type, input_size, output_size)
		if multiplayer.is_server():
			inventory_data.save_inventory_data(id)

func configure_spell_input():
	spell_input.index = 1
	spell_input.slot_type = InventoryManager.DragDropLocation.SPELLSLOT
	connect_spell_input()
	match type:
		"brewing":
			var item = load("res://Resources/Items/automatic_brewing.tres")
			inventory_data.spell_input.item  = item
	

@rpc("any_peer", "call_local", "reliable")
func transfer_in_spell_input(inv_index: int):
	var slot = player_inventory.inventory_data.slot_data_table[inv_index]
	if slot.item is Spell:
		var remainder = inventory_data.add_item_spell_input(slot.item, slot.quantity)
		player_inventory.inventory_data.remove_amount(inv_index, slot.quantity - remainder)
	update_all_inventories()
	
@rpc("any_peer", "call_local", "reliable")
func transfer_out_spell_input(_index: int):
	var spell_input_data = inventory_data.spell_input
	var remainder = player_inventory.inventory_data.get_add_item_remainder(spell_input_data.item, spell_input_data.quantity)
	player_inventory.inventory_data.add_item(spell_input_data.item, spell_input_data.quantity)
	inventory_data.remove_amount_spell_input(spell_input_data.quantity - remainder)
	update_all_inventories()

@rpc("any_peer", "call_local", "reliable")
func transfer_in_input(inv_index: int):
	var slot = player_inventory.inventory_data.slot_data_table[inv_index]
	if slot.item is Spell:
		transfer_in_spell_input(inv_index)
	else:
		super.transfer_in_input(inv_index)
		
@rpc("any_peer", "call_local", "reliable")
func transfer_out_spell_input_to_index(inv_index: int):
	var inv_slot = SlotData.new()
	inv_slot.item = player_inventory.inventory_data.slot_data_table[inv_index].item
	inv_slot.quantity = player_inventory.inventory_data.slot_data_table[inv_index].quantity
	var input_slot = inventory_data.spell_input
	var remainder = player_inventory.inventory_data.add_item_to_index(input_slot.item, input_slot.quantity, inv_index)
	if remainder == -1:
		inventory_data.add_item_to_index(inv_slot.item, inv_slot.quantity, inv_index)
	else:
		inventory_data.remove_amount_spell_input(input_slot.quantity - remainder)
	update_all_inventories()
	
func connect_spell_input():
	spell_input.transfer.connect(transfer_out_spell_input)
