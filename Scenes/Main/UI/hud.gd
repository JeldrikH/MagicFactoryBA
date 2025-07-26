extends Panel

func _ready():
	update_keys()
	hide()


func update_keys():
	_inventory_key()
	_building_key()
	_deconstruct_key()
	

func _inventory_key():
	var key = %UI.get_key("INVENTORY")
	var key_icon = load("res://Sprites/UI/Keys/%s-Key.png" % key)
	%InventoryKey.texture = key_icon
	
	
func _building_key():
	var key = %UI.get_key("OPEN_BUILDER")
	var key_icon = load("res://Sprites/UI/Keys/%s-Key.png" % key)
	%BuildingKey.texture = key_icon

func _deconstruct_key():
	var key = %UI.get_key("DECONSTRUCT")
	var key_icon = load("res://Sprites/UI/Keys/%s-Key.png" % key)
	%DeconstructKey.texture = key_icon

	
func _on_inventory_button_pressed() -> void:
	if not InventoryManager.is_ui_opened:
		get_node("/root/Main/PlayerInventories/%s" % multiplayer.get_unique_id()).open()
	else:
		get_node("/root/Main/PlayerInventories/%s" % multiplayer.get_unique_id()).close()


func _on_building_button_pressed() -> void:
	if not InventoryManager.is_ui_opened and Builder.is_building_allowed:
		$"../BuildingUI".open()
	else:
		$"../BuildingUI".close()


func _on_deconstruct_button_pressed() -> void:
	if not Deconstructor.deconstruct_mode:
		Deconstructor.activate_deconstruct_mode()
	else:
		Deconstructor.deactivate_deconstruct_mode()
