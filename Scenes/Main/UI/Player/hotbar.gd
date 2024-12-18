extends PanelContainer

# Start with Slot x+1 selected
@export var current_selection = 0
@onready var item_grid: GridContainer = $SlotMargin/ItemGrid
var hotbar_data = preload("res://Resources/Inventories/player_hotbar.tres")
enum Change_types {left, right, jump}

func _ready() -> void:
	for slot in $SlotMargin/ItemGrid.get_children():
		if slot.get_index() == current_selection:
			slot.set_selected(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_selection()
	#update_hotbar()
	
			
#updates the selection of the hot bar slots
func update_selection():
	#Update on click
	for slot in $SlotMargin/ItemGrid.get_children():
		if slot.get_index() != current_selection and slot.is_selected:
			change_selection(Change_types.jump, slot.get_index())
			
	#Update on scroll up
	if Input.is_action_just_pressed("HOTBAR_LEFT"):
		change_selection(Change_types.left)
	#Update on scroll down
	if Input.is_action_just_pressed("HOTBAR_RIGHT"):
		change_selection(Change_types.right)
	#Update on number key input
	for slot_number in range(0,10):
		if Input.is_action_just_pressed("SLOT_" + str(slot_number+1)):
			change_selection(Change_types.jump, slot_number)

func update_hotbar():
	for child in item_grid.get_children():
		child.set_slot_data(SlotData.new())
	for index in hotbar_data.slot_data_table.size():
		if hotbar_data.slot_data_table[index]:
			item_grid.get_children()[index].set_slot_data(hotbar_data.slot_data_table[index])
	hotbar_data.save_hotbar_data()
			
	
#changes the selection upon scrolling or pressing a number key or clicking on the slot
func change_selection(change_type: Change_types, slot_number = -1):
	for slot in $SlotMargin/ItemGrid.get_children():
		if slot.get_index() == current_selection and slot.is_selected:
			slot.toggle_selected()
			match change_type:
				Change_types.left:
					current_selection = selection_left()
				Change_types.right:
					current_selection = selection_right()
				Change_types.jump:
					current_selection = slot_number
	
	for slot in $SlotMargin/ItemGrid.get_children():
		if slot.get_index() == current_selection:
			slot.set_selected(true)
	
#Moves the hotbar cursor to the right
func selection_right():
	if current_selection == 9:
		return 0
	return current_selection + 1
			
#Moves the hotbar cursor to the left
func selection_left():
	if current_selection == 0:
		return 9
	return current_selection - 1


func _on_mouse_entered() -> void:
	InventoryManager.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		InventoryManager.mouse_inside_inventory = false
