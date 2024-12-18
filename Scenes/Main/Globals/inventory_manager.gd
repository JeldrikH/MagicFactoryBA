extends Node2D


var mouse_inside_inventory = false
var mouse_over_slot = false
var is_inventory_opened = false
var is_ui_opened = false

enum DragDropLocation {INTERNAL, CONTAINER, INPUT, OUTPUT, SPELLSLOT, OUTSIDE, CANCEL}

@warning_ignore("unused_signal")
signal inventory_updated(inventory: Inventory)
@warning_ignore("unused_signal")
signal item_added(inventory: Inventory)
@warning_ignore("unused_signal")
signal item_removed(inventory: Inventory)

func close_all_ui_windows():
	get_tree().call_group("ui", "close")

## If a building gets removed, close all connected inventories
@rpc("any_peer","call_local",)
func close_inventories_with_id(id: StringName):
	var inventories = get_tree().get_nodes_in_group("inventories")
	for inventory in inventories:
		if inventory.id == id:
			inventory.close()
