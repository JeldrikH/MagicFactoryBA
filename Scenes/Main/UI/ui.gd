extends CanvasLayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("CLOSE_UI") and Globals.is_ui_opened:
		close_all_ui_windows()
	
func close_all_ui_windows():
	get_tree().call_group("inventories", "close")
	Globals.is_inventory_opened = false
	$BuildingUI.visible = false
	


func _on_table_interact() -> void:
	pass
	#$Inventories/SpellCraftingInventory.open()


func _on_storage_interaction_interact() -> void:
	$Inventories/ItemContainer0.open()


func _on_cauldron_interact() -> void:
	$Inventories/BrewingInventory.open()
