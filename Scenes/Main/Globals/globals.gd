extends Node2D


var mouse_inside_inventory = false
var is_inventory_opened = false
var is_ui_opened = false
var is_building_allowed = false
var selected_building: Building
var last_created_building: Building
func close_all_ui_windows():
	get_tree().call_group("ui", "close")
