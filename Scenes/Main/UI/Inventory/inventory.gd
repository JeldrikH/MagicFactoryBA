extends PanelContainer
class_name Inventory

var player_inventory: Inventory
var path = "res://Resources/Inventories/Containers/"
var player_owner: Player
var slot_node = preload("res://Scenes/Main/UI/Inventory/slot.tscn")
var inventory_data: InventoryData

@export var item_grid: Control
@export var grid_size: int
var id: StringName:
	set(p_id):
		id = p_id
		if ResourceLoader.exists(path + id + ".tres"):
			inventory_data = load(path + id + ".tres")

func _ready() -> void:
	id = name.to_snake_case()
	create_resource_if_not_exist()
	if not inventory_data:
		inventory_data = load(path + id + ".tres")
	fill_grid()
	update()
	connect_signals()
	hide()
	
	
##To instantiate inventory with parameters and a unique id
##args[0] = id
##args[1] = inventory_size
func scene_parameters(args: Array)-> Inventory:
	id = str(args[0])
	if args.size() > 1:
		grid_size = args[1]
	return self
	

##Creates a new inventory resource
func create_resource_if_not_exist():
	if not ResourceLoader.exists(path + id + ".tres"):
		inventory_data = InventoryData.new(grid_size)
		if multiplayer.is_server():
			inventory_data.save_inventory_data(id)
		
func fill_grid():
	for child in item_grid.get_children():
		child.queue_free()
	for i in inventory_data.slot_data_table.size():
		var slot = slot_node.instantiate()
		slot.slot_type = InventoryManager.DragDropLocation.INTERNAL
		slot.set_slot_data(inventory_data.slot_data_table[i])
		item_grid.add_child(slot, true)
		connect_slot(slot)
		slot.index = i
		
func get_slots()-> Array:
	return item_grid.get_children()
	
## Call all inventories to sync multiplayer inventories, called in rpc methods
func update_all_inventories():
	get_tree().call_group("inventories", "update")
	
##updates the inventory, call after changes to the inventory have happened
func update():
	for i in range(0, inventory_data.slot_data_table.size()):
		item_grid.get_child(i).set_slot_data(inventory_data.slot_data_table[i])
	if multiplayer.is_server():
		inventory_data.save_inventory_data(id)
	InventoryManager.inventory_updated.emit(self)

@rpc("any_peer", "call_local", "reliable")
func open():
	if not InventoryManager.is_inventory_opened:
		InventoryManager.is_inventory_opened = true
		InventoryManager.is_ui_opened = true
		Builder.deactivate_build_mode()
		Deconstructor.deactivate_deconstruct_mode()
		show()
		update()

@rpc("any_peer", "call_local", "reliable")
func close():
	hide()
	InventoryManager.mouse_inside_inventory = false
	InventoryManager.is_inventory_opened = false
	InventoryManager.is_ui_opened = false
	
##adds the specified amount of slots to the inventory
@rpc("any_peer", "call_local", "reliable")
func add_slots(amount: int):
	grid_size += amount
	inventory_data.add_slots(amount)
	fill_grid.rpc()
	update_all_inventories()
	
## removes the last slot if it is empty
@rpc("any_peer", "call_local", "reliable")
func remove_slot():
	if inventory_data.slot_data_table[inventory_data.slot_data_table.size() - 1].quantity == 0:
		grid_size -= 1
		inventory_data.slot_data_table.pop_back()
		fill_grid.rpc()
		update_all_inventories()
	
##Splits stack in half on right click
@rpc("any_peer", "call_local", "reliable")
func split_stack_half(index: int):
	inventory_data.split_stack_half(index)
	update_all_inventories()
	
##Adds the specified item to the first free slot (just adds update to the data function)
##returns the remainder if the inventory is full
##item_id: i.e "frog_leg"
@rpc("any_peer", "call_local", "reliable")
func add_item(item_id: StringName, quantity: int):
	var item: Item = load("res://Resources/Items/%s.tres" % item_id)
	inventory_data.add_item(item, quantity)
	update_all_inventories()
	InventoryManager.item_added.emit(self)

func add_item_list(item_list: Array[SlotData]):
	var remainder: Array[SlotData] = []
	for stack in item_list:
		var remainder_quantity = get_add_item_remainder(stack.item, stack.quantity)
		add_item.rpc(stack.item.id, stack.quantity)
		if remainder_quantity > 0:
			remainder.append(SlotData.new(stack.item, remainder_quantity))
			
	if remainder.size() > 0:
		create_remainder_container(remainder)
		

func get_add_item_remainder(item: Item, quantity: int)-> int:
	var remainder = inventory_data.get_add_item_remainder(item, quantity)
	return remainder
	
##Creates a container with leftover items that didnt fit into the inventory and opens it
func create_remainder_container(remainder: Array[SlotData]):
	Builder.building_created.connect(add_items_to_remainder_container.bind(remainder))
	player_owner.inventory.close()
	Builder.build.rpc_id(1, "remainder_container",player_owner.current_scene, player_owner.position)
	
func add_items_to_remainder_container(remainder_container: Building, remainder: Array[SlotData]):
	if remainder_container is RemainderContainer:
		var external_inventory = player_owner.inventory.open_with_external_inventory(remainder_container.inventory_scene, [remainder_container.id, remainder.size()])
		external_inventory.add_item_list.call_deferred(remainder)
		Builder.building_created.disconnect(add_items_to_remainder_container)
	
	
##adds the specified item to the target index (old entries on that index are overwritten!)
##item_id: i.e "frog_leg"
@rpc("any_peer", "call_local", "reliable")
func add_item_to_index(item_id: StringName, quantity: int, index: int):
	if index >= inventory_data.slot_data_table.size() or index < 0:
		print("invalid index on adding")
		return
	var item: Item = load("res://Resources/Items/%s.tres" % item_id)
	inventory_data.add_item_to_index(item, quantity, index)
	update()

##moves the item to the target index,
##swaps the items if there is another one on the target index
@rpc("any_peer", "call_local", "reliable")
func move_item(start_index: int, target_index: int):
	if (start_index >= inventory_data.slot_data_table.size() or start_index < 0
	or target_index >= inventory_data.slot_data_table.size() or target_index < 0):
		print("invalid index on moving")
		return
	inventory_data.move_item(start_index, target_index)
	update()
	
##Deletes the item at the index
@rpc("any_peer", "call_local", "reliable")
func delete_item(index: int):
	if index >= inventory_data.slot_data_table.size() or index < 0:
		print("invalid index on deleting")
		return
	inventory_data.delete_item(index)
	update()

#Called when Inventory gets updated to reconnect signals
func connect_signals():
	if not is_connected("mouse_entered", _on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not is_connected("mouse_exited", _on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func connect_slot(slot: Slot):
	slot.split_stack.connect(split_stack_half)
		
func delete_confirmed(inventory: Inventory, index: int):
	if inventory == self:
		delete_item.rpc(index)
		update()

func _on_mouse_entered() -> void:
	InventoryManager.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		InventoryManager.mouse_inside_inventory = false
