extends PanelContainer
class_name Inventory

@export var item_grid: Control
@export var grid_size: int
@export var id: StringName
var path: String
var slot_node = preload("res://Scenes/Main/UI/Inventory/slot.tscn")
var inventory_data: InventoryData
var wait_for_next_process = false

func _ready() -> void:
	inventory_data = load(path + id + ".tres")
	create_resource_if_not_exist()
	fill_grid()
	update()
	connect_signals()

func _process(_delta: float)-> void:
	if visible:
		input_handler()
	

func input_handler():
	if Input.is_action_just_released("CLICK") and Globals.mouse_inside_inventory:
		#Call deferred to wait for slot children
		drag_drop.call_deferred()
	
	if Input.is_action_just_pressed("RIGHT_CLICK"):
		for child in item_grid.get_children():
				if child.is_hovered:
					split_stack_half(child.get_index())

##Creates a new inventory resource
func create_resource_if_not_exist():
	if not ResourceLoader.exists(path + id + ".tres"):
		var data = InventoryData.new(grid_size)
		data.save_inventory_data(path, id)
		
func fill_grid():
	for child in item_grid.get_children():
		child.queue_free()
	for i in inventory_data.slot_data_table.size():
		var slot = slot_node.instantiate()
		item_grid.add_child(slot)
		slot.index = i
		
##updates the inventory, call after changes to the inventory have happened
func update():
	for i in range(0, inventory_data.slot_data_table.size()):
		item_grid.get_child(i).set_slot_data(inventory_data.slot_data_table[i])
	inventory_data.save_inventory_data(path, id)

func open():
	if not Globals.is_inventory_opened:
		Globals.is_inventory_opened = true
		Globals.is_ui_opened = true
		visible = true
		update()
		
func close():
	visible = false
	Globals.mouse_inside_inventory = false
	Globals.is_inventory_opened = false
	Globals.is_ui_opened = false
	update()
	
##adds tre specified amount of slots to the inventory
func add_slots(amount: int):
	grid_size += amount
	inventory_data.add_slots(amount)
	
##Splits stack in half on right click
func split_stack_half(index: int):
	inventory_data.split_stack_half(index)
	update()
	
##Adds the specified item to the first free slot
##returns true if successfull
##item_id: i.e "frog_leg"
func add_item(item: Item, quantity: int) -> bool:
	if inventory_data.add_item(item, quantity) != quantity:
		update()
		return true
	print("inventory full")
	return false
	
##adds the specified item to the target index (old entries on that index are overwritten!)
##item_id: i.e "frog_leg"
func add_item_to_index(item: Item, quantity: int, index: int):
	if index >= inventory_data.slot_data_table.size() or index < 0:
		print("invalid index on adding")
		return
	inventory_data.add_item_to_index(item, quantity, index)
	update()

##moves the item to the target index,
##swaps the items if there is another one on the target index
func move_item(start_index: int, target_index: int):
	if (start_index >= inventory_data.slot_data_table.size() or start_index < 0
	or target_index >= inventory_data.slot_data_table.size() or target_index < 0):
		print("invalid index on moving")
		return
	inventory_data.move_item(start_index, target_index)
	update()
	
##Deletes the item at the index
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
		move_item(start_index, target_index)
		return
	update()
		
func delete_confirmed(inventory: Inventory, index: int):
	if inventory == self:
		delete_item(index)
		update()

func _on_mouse_entered() -> void:
	Globals.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		Globals.mouse_inside_inventory = false
