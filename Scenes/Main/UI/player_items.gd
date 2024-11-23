extends Inventory

const hotbar_data = preload("res://Resources/Inventories/player_hotbar.tres")

func _ready() -> void:
	path = "res://Resources/Inventories/"
	id = "player_items"
	super._ready()
	
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	#adds the hovered item to the pressed hotbar slot with the corresponding keystroke
	for slot_number in range(0,10):
		if Input.is_action_just_pressed("SLOT_" + str(slot_number+1)):
			for child in get_children():
				if child.is_hovered:
					link_item_to_hotbar(inventory_data.slot_data_table[child.get_index()].item, slot_number)
	
##Links the specified item to the player hotbar
func link_item_to_hotbar(item: Item, hotbar_index: int):
	if item:
		hotbar_data.link_item_to_index(item.id, hotbar_index)
	else:
		hotbar_data.link_item_to_index("", hotbar_index)
