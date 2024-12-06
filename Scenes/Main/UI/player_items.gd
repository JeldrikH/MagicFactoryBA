extends Inventory

const hotbar_data = preload("res://Resources/Inventories/player_hotbar.tres")


var player_id

func _ready() -> void:
	path = "res://Resources/Inventories/"
	
	print("player_id_set_in inventory")
	if player_id:
		handle_multiplayer_inventory()
	super._ready()
	
	
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	add_to_hotbar_with_key()
	
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

#debug change later to dynamic inventory
func handle_multiplayer_inventory():
	if player_id == 1:
		id = "player_items"
	else:
		id = "player_items2"
