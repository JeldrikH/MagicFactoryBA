extends PanelContainer


func _ready() -> void:
	visible = false
	
	
func _process(_delta: float) -> void:
	if Globals.is_inventory_opened:
		if  Input.is_action_just_pressed("INVENTORY"):
			close()
	else:
		if Input.is_action_just_pressed("INVENTORY"):
			open()

func open():
	if not Globals.is_inventory_opened:
		Globals.is_inventory_opened = true
		visible = true
		$InventoryMargin/PlayerItems.update()
		
func close():
	$"..".close_all_inventories()
	Globals.mouse_inside_inventory = false
		
		
func _on_mouse_entered() -> void:
	Globals.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		Globals.mouse_inside_inventory = false
