extends Inventory
class_name PlayerInventory

const hotbar_data = preload("res://Resources/Inventories/player_hotbar.tres")

signal drag_drop_result_signal(result: Globals.DragDropLocation, index: int)

var external_inventory: PanelContainer

var player_id: int:
	set(id):
		player_id = id
		$InventorySpawner.set_multiplayer_authority(id)
		handle_multiplayer_inventory()
		
func _ready() -> void:
	super._ready()
	visible = false
	connect_slot_signals(self)

func _process(delta: float) -> void:
	super._process(delta)
	add_to_hotbar_with_key()
		
func close():
	if is_instance_valid(external_inventory):
		external_inventory.queue_free()
	super.close()
			
func open_with_external_inventory(inventory_scene: PackedScene, scene_args: Array = [])-> PanelContainer:
	if not Globals.is_ui_opened:
		add_external_inventory(inventory_scene, scene_args)
		external_inventory.show()
	open()
	return external_inventory
	
func add_external_inventory(inventory_scene: PackedScene, scene_args: Array = [])-> PanelContainer:
	external_inventory = inventory_scene.instantiate()
		
	if scene_args.size() > 0 and external_inventory.has_method("scene_parameters"):
		external_inventory = external_inventory.scene_parameters(scene_args)
	external_inventory.name = external_inventory.id
	external_inventory.player_inventory = self
	$InventoryContainer.add_child(external_inventory, true)
	$InventoryContainer.move_child(external_inventory,0)
	connect_slot_signals(external_inventory)
	return external_inventory
	
	#debug change later to dynamic inventory
func handle_multiplayer_inventory():
	if player_id != 1:
		item_grid.name = "PlayerItems2"
	if player_id != multiplayer.get_unique_id():
		remove_from_group("ui")

#Called when Slot gets created to connect signals
func connect_slot_signals(inventory: Inventory):
	for slot in inventory.get_slots():
		if not slot.is_connected("drag_drop_start", drag_drop):
			slot.drag_drop_start.connect(drag_drop)
		if not slot.is_connected("drag_drop_result", drag_drop_result):
			slot.drag_drop_result.connect(drag_drop_result)

	
func drag_drop(start: Globals.DragDropLocation, index: int):
	var result = await drag_drop_result_signal
	var target_index = result[1]
	result = result[0]
	
	# Handle item deletion
	if result == Globals.DragDropLocation.OUTSIDE:
		return
	
	# Check how Drag Drop was performed
	match start:
		Globals.DragDropLocation.INTERNAL when result == Globals.DragDropLocation.INTERNAL:
			move_item.rpc(index, target_index)
			
		Globals.DragDropLocation.INTERNAL when result == Globals.DragDropLocation.CONTAINER:
			external_inventory.transfer_in_index.rpc(index, target_index)
			
		Globals.DragDropLocation.INTERNAL when result == Globals.DragDropLocation.INPUT:
			external_inventory.transfer_in_input.rpc(index)
			
		Globals.DragDropLocation.INTERNAL when result == Globals.DragDropLocation.OUTPUT:
			pass # no insertion to output slot
			
		Globals.DragDropLocation.INTERNAL when result == Globals.DragDropLocation.SPELLSLOT:
			external_inventory.transfer_in_spell_input.rpc(index)
			
		
		Globals.DragDropLocation.CONTAINER when result == Globals.DragDropLocation.INTERNAL:
			external_inventory.transfer_out_index.rpc(target_index, index)
			
		Globals.DragDropLocation.CONTAINER when result == Globals.DragDropLocation.CONTAINER:
			external_inventory.move_item.rpc(index, target_index)
			
			
		Globals.DragDropLocation.INPUT when result == Globals.DragDropLocation.INTERNAL:
			external_inventory.transfer_out_input_to_index.rpc(target_index, index)
			
		Globals.DragDropLocation.OUTPUT when result == Globals.DragDropLocation.INTERNAL:
			external_inventory.transfer_out_output_to_index.rpc(target_index, index)
			
		Globals.DragDropLocation.SPELLSLOT when result == Globals.DragDropLocation.INTERNAL:
			external_inventory.transfer_out_spell_input_to_index.rpc(target_index, index)
		_:
			update_all_inventories()

func drag_drop_result(result: Globals.DragDropLocation, index: int):
	drag_drop_result_signal.emit(result, index)
	
##Links the specified item to the player hotbar
func link_item_to_hotbar(item: Item, hotbar_index: int):
	if item:
		hotbar_data.link_item_to_index(item.id, hotbar_index)
	else:
		hotbar_data.link_item_to_index("", hotbar_index)


##adds the hovered item to the pressed hotbar slot with the corresponding keystroke
func add_to_hotbar_with_key():
	for slot_number in range(0,10):
		if Input.is_action_just_pressed("SLOT_" + str(slot_number+1)):
			for child in get_children():
				if child.is_hovered:
					link_item_to_hotbar(inventory_data.slot_data_table[child.get_index()].item, slot_number)
