extends PanelContainer
		
func open():
	InventoryManager.close_all_ui_windows()
	visible = true
	InventoryManager.is_ui_opened = true
	Builder.deactivate_build_mode()
	Deconstructor.deactivate_deconstruct_mode()

func close():
	visible = false
	InventoryManager.is_ui_opened = false


func _on_automatic_brewing_pressed() -> void:
	Builder.activate_build_mode("cauldron")
	close()
