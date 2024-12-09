extends PanelContainer
class_name Inventory

@export var item_grid: Control
@export var grid_size: int
@export var id: StringName
var player_owner: Player
var path: String
var slot_node = preload("res://Scenes/Main/UI/Inventory/slot.tscn")
@export var inventory_data: InventoryData
signal updated

func _ready() -> void:
	create_resource_if_not_exist()
	if !inventory_data:
		inventory_data = load(path + id + ".tres")
	fill_grid()
	update()
	connect_signals()

func _process(_delta: float)-> void:
	if visible:
		input_handler()
	
##To instantiate inventory with parameters and a unique id
##args[0] = id
##args[1] = inventory_size
func scene_parameters(args: Array)-> Inventory:
	id = str(args[0])
	grid_size = args[1]
	return self
	
func input_handler():
	if Input.is_action_just_released("CLICK") and Globals.mouse_inside_inventory:
		#Call deferred to wait for slot children
		drag_drop.call_deferred()
	
	if Input.is_action_just_pressed("RIGHT_CLICK"):
		for child in item_grid.get_children():
				if child.is_hovered:
					split_stack_half.rpc(child.get_index())

##Creates a new inventory resource
func create_resource_if_not_exist():
	if not ResourceLoader.exists(path + id + ".tres"):
		inventory_data = InventoryData.new(grid_size)
		if multiplayer.is_server():
			inventory_data.save_inventory_data(path, id)
		
func fill_grid():
	for child in item_grid.get_children():
		child.queue_free()
	for i in inventory_data.slot_data_table.size():
		var slot = slot_node.instantiate()
		slot.set_slot_data(inventory_data.slot_data_table[i])
		item_grid.add_child(slot, true)
		slot.index = i

## Call all inventories to sync multiplayer inventories, called in rpc methods
func update_all_inventories():
	get_tree().call_group("inventories", "update")
	
##updates the inventory, call after changes to the inventory have happened
func update():
	for i in range(0, inventory_data.slot_data_table.size()):
		item_grid.get_child(i).set_slot_data(inventory_data.slot_data_table[i])
	if multiplayer.is_server():
		inventory_data.save_inventory_data(path, id)
	updated.emit()

func open():
	if not Globals.is_inventory_opened:
		Globals.is_inventory_opened = true
		Globals.is_ui_opened = true
		Builder.deactivate_build_mode()
		Deconstructor.deactivate_deconstruct_mode()
		show()
		update()
		
func close():
	hide()
	Globals.mouse_inside_inventory = false
	Globals.is_inventory_opened = false
	Globals.is_ui_opened = false
	
##adds the specified amount of slots to the inventory
@rpc("any_peer", "call_local", "reliable")
func add_slots(amount: int):
	grid_size += amount
	inventory_data.add_slots(amount)
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
	var remainder_container = Builder.build("RemainderContainer",player_owner.current_scene, player_owner.position, [remainder.size()])
	remainder_container.inventory.add_item_list(remainder)
	Globals.close_all_ui_windows()
	player_owner.inventory.add_external_inventory(remainder_container.inventory, [remainder_container.id, remainder.size()])
	player_owner.inventory.open.rpc_id(player_owner.player_id)
	
	
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

#Called when an item gets dragged
func drag_drop():
	var start_index: int = -1
	var target_index: int = -1
	for child in item_grid.get_children():
		if start_index < 0 and child.is_selected:
			start_index = child.get_index()
		if target_index < 0 and child.is_drag_drop_target:
			target_index = child.get_index()
			
	if start_index >= 0 and target_index >= 0 and start_index != target_index:
		item_grid.get_child(start_index).is_selected = false
		item_grid.get_child(target_index).is_drag_drop_target = false
		move_item.rpc(start_index, target_index)
		return
	update()
		
func delete_confirmed(inventory: Inventory, index: int):
	if inventory == self:
		delete_item.rpc(index)
		update()

func _on_mouse_entered() -> void:
	Globals.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		Globals.mouse_inside_inventory = false
