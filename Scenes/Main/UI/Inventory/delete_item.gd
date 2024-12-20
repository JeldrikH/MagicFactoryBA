extends PanelContainer
var deletion_index: int
var inventory: Inventory
var slot_type: InventoryManager.DragDropLocation

signal delete_confirmed(inventory: Inventory, index: int, slot_type: InventoryManager.DragDropLocation)

func _on_confirm_pressed() -> void:
	delete_confirmed.emit(inventory, deletion_index, slot_type)
	void_data()
	hide()

func _on_cancel_pressed() -> void:
	void_data()
	hide()

func open_prompt(p_inventory: Inventory, p_deletion_index: int, p_slot_type: InventoryManager.DragDropLocation):
	deletion_index = p_deletion_index
	inventory = p_inventory
	slot_type = p_slot_type
	show()

func void_data():
	deletion_index = -1
	inventory = null
