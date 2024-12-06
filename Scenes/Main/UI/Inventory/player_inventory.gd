extends PanelContainer

@onready var player_items = $InventoryMargin/PlayerItems
var player_id:
	set(id):
		$InventoryMargin/PlayerItems.player_id = id
func _ready() -> void:
	visible = false
	
	
func _process(_delta: float) -> void:
	handle_input()

func handle_input():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		if Globals.is_ui_opened:
			if Input.is_action_just_pressed("INVENTORY"):
				Globals.close_all_ui_windows()
		else:
			if Input.is_action_just_pressed("INVENTORY"):
				open.call_deferred()
			
func open():
	if not Globals.is_inventory_opened:
		visible = true
		$InventoryMargin/PlayerItems.open()
		
func close():
	visible = false
	$InventoryMargin/PlayerItems.close()

		
func _on_mouse_entered() -> void:
	Globals.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		Globals.mouse_inside_inventory = false
