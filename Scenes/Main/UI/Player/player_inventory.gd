extends PanelContainer

@onready var player_items = $HBoxContainer/InventoryMargin/PlayerItems
var external_inventory: PanelContainer

var player_id:
	set(id):
		player_id = id
		$HBoxContainer/InventoryMargin/PlayerItems.player_id = id
		
func _ready() -> void:
	visible = false
	$MultiplayerSpawner.set_multiplayer_authority(player_id)
	
			
func open():
	if not Globals.is_inventory_opened:
		visible = true
		player_items.open()
		
func close():
	visible = false
	player_items.close()
	if is_instance_valid(external_inventory):
		external_inventory.queue_free()

func open_with_external_inventory(inventory_scene: PackedScene, scene_args: Array = []):
	if not Globals.is_ui_opened:
		add_external_inventory(inventory_scene, scene_args)
		open()
	
func add_external_inventory(inventory_scene: PackedScene, scene_args: Array = []):
	external_inventory = inventory_scene.instantiate()
		
	if scene_args.size() > 0 and external_inventory.has_method("scene_parameters"):
		external_inventory = external_inventory.scene_parameters(scene_args)
	external_inventory.name = "ExternalInventory"
	$HBoxContainer.add_child(external_inventory, true)
	$HBoxContainer.move_child(external_inventory,0)
	external_inventory.visible = true
	
func _on_mouse_entered() -> void:
	Globals.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		Globals.mouse_inside_inventory = false
