extends Inventory
class_name PlayerInventory


const hotbar_data = preload("res://Resources/Inventories/player_hotbar.tres")

signal drag_drop_result_signal(result: InventoryManager.DragDropLocation, index: int)

var external_inventory: Inventory

var player_id: int:
	set(id):
		player_id = id
		$InventorySpawner.set_multiplayer_authority(id)
		handle_multiplayer_inventory()
		
func _ready() -> void:
	super._ready()
	visible = false
	player_inventory = self
	connect_slot_signals(self)

		
func close():
	if is_instance_valid(external_inventory):
		external_inventory.disconnect_signals()
		external_inventory.free()
		external_inventory = null
	super.close()
			
func open_with_external_inventory(inventory_scene: PackedScene, scene_args: Array = [])-> PanelContainer:
	if not InventoryManager.is_ui_opened:
		add_external_inventory(inventory_scene, scene_args)
		external_inventory.show()
	open()
	return external_inventory
	
func add_external_inventory(inventory_scene: PackedScene, scene_args: Array = [])-> PanelContainer:
	if external_inventory:
		close()
	external_inventory = inventory_scene.instantiate()
		
	if scene_args.size() > 0 and external_inventory.has_method("scene_parameters"):
		external_inventory = external_inventory.scene_parameters(scene_args)
	external_inventory.name = external_inventory.id
	$InventoryMargin/InventoryContainer.add_child(external_inventory, true)
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
			
func delete_confirmed(inventory: Inventory, index: int, slot_type: InventoryManager.DragDropLocation):
	if inventory == self:
		delete_item.rpc(index)
	if inventory == external_inventory:
		external_inventory.delete_confirmed(index, slot_type)
	
func drag_drop(start: InventoryManager.DragDropLocation, index: int):
	var result = await drag_drop_result_signal
	var target_index = result[1]
	result = result[0]
	var location = InventoryManager.DragDropLocation
	# Handle item deletion
	if result == location.OUTSIDE:
		match start:
			location.INTERNAL:
				$DeleteItem.open_prompt(self, index, start)
			_:
				$DeleteItem.open_prompt(external_inventory, index, start)
			
	
	# Check how Drag Drop was performed
	match start:
		location.INTERNAL when result == location.INTERNAL:
			move_item.rpc(index, target_index)
			
		location.INTERNAL when result == location.CONTAINER:
			external_inventory.transfer_in_index.rpc(index, target_index)
			
		location.INTERNAL when result == location.INPUT:
			external_inventory.transfer_in_input.rpc(index)
			
		location.INTERNAL when result == location.OUTPUT:
			pass # no insertion to output slot
			
		location.INTERNAL when result == location.SPELLSLOT:
			external_inventory.transfer_in_spell_input.rpc(index)
			
		
		location.CONTAINER when result == location.INTERNAL:
			external_inventory.transfer_out_index.rpc(target_index, index)
			
		location.CONTAINER when result == location.CONTAINER:
			external_inventory.move_item.rpc(index, target_index)
			
			
		location.INPUT when result == location.INTERNAL:
			external_inventory.transfer_out_input_to_index.rpc(target_index, index)
			
		location.OUTPUT when result == location.INTERNAL:
			external_inventory.transfer_out_output_to_index.rpc(target_index, index)
			
		location.SPELLSLOT when result == location.INTERNAL:
			external_inventory.transfer_out_spell_input_to_index.rpc(target_index)
		_:
			update_all_inventories()

func drag_drop_result(result: InventoryManager.DragDropLocation, index: int):
	drag_drop_result_signal.emit(result, index)
	
##Links the specified item to the player hotbar
func link_item_to_hotbar(item: Item, hotbar_index: int):
	if item:
		hotbar_data.link_item_to_index(item.id, hotbar_index)
	else:
		hotbar_data.link_item_to_index("", hotbar_index)

## To set parameters that cannot be synced
func _on_inventory_container_child_entered_tree(node: Node) -> void:
	if node is Inventory:
		node.player_inventory = self
		$InventoryMargin/InventoryContainer.move_child(node,0)
