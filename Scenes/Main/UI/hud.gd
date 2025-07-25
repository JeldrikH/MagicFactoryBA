extends Panel

func _ready():
	update_keys()
	hide()


func update_keys():
	_inventory_key()
	_building_key()
	_deconstruct_key()
	

func _inventory_key():
	var key_icon = _get_key_icon("INVENTORY")
	%InventoryKey.texture = key_icon
	
	
func _building_key():
	var key_icon = _get_key_icon("OPEN_BUILDER")
	%BuildingKey.texture = key_icon

func _deconstruct_key():
	var key_icon = _get_key_icon("DECONSTRUCT")
	%DeconstructKey.texture = key_icon
	

func _get_key_icon(action_name: StringName) -> CompressedTexture2D:
	var input_events = InputMap.action_get_events(action_name)
	var key: String = OS.get_keycode_string(input_events[0].physical_keycode)
	return load("res://Sprites/UI/Keys/%s-Key.png" % key)

	
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
