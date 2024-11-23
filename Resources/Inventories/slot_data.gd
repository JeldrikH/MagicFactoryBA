extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 500

@export var item: Item
@export_range(0, MAX_STACK_SIZE) var quantity: int = 0

func _init(p_item= Item.new(), p_quantity = 0) -> void:
	item = p_item
	quantity = p_quantity
	
