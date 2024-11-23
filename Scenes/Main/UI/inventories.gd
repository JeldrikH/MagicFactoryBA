extends CanvasLayer

func close_all_inventories():
	for child in get_children():
		if child != $StorageContainers:
			child.visible = false
	for child in $StorageContainers.get_children():
		child.visible = false
	Globals.is_inventory_opened = false
