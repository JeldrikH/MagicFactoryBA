extends PanelContainer
var deletion_index: int
var inventory: Inventory

func _on_confirm_pressed() -> void:
	get_tree().call_group("inventories", "delete_confirmed", inventory, deletion_index)
	visible = false

func _on_cancel_pressed() -> void:
	visible = false

func open_prompt(p_inventory: Inventory, p_deletion_index: int):
	deletion_index = p_deletion_index
	inventory = p_inventory
	visible = true
