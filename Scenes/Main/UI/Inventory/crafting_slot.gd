extends Slot

#Sets the Background Color of the Item Slot
func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
		

#Sets the Item Contents of the Slot
func set_slot_data(slot_data: SlotData):
	set_selected(false)
	is_drag_drop_target = false
	if slot_data.item:
		$SlotMargin/ItemTexture.texture = slot_data.item.icon
		$QuantityLabel.text = str(slot_data.quantity) + "/" + str(slot_data.required_amount)
	else:
		$SlotMargin/ItemTexture.texture = null
	
	if slot_data.quantity >= 1:
		contains_item = true
	else:
		contains_item = false
	
	
		
	
		
