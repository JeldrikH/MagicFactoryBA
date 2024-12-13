extends SlotData
class_name CraftingSlotData

@export var required_amount: int

func _init(p_item= Item.new(), p_quantity = 0, p_required_amount = 0) -> void:
	super(p_item, p_quantity)
	required_amount = p_required_amount
