extends PanelContainer

@export var player_items: Inventory
var external_inventory: PanelContainer

var player_id:
	set(id):
		player_id = id
		player_items.player_id = id
		$InventorySpawner.set_multiplayer_authority(id)
		
func _ready() -> void:
	visible = false
	if player_id != multiplayer.get_unique_id():
		remove_from_group("ui")
	
@rpc("any_peer", "call_local", "reliable")
func open():
	if not Globals.is_inventory_opened:
		show()
		player_items.open()
		
func close():
	if is_instance_valid(external_inventory):
		external_inventory.queue_free()
	hide()
	Globals.mouse_inside_inventory = false
	Globals.is_inventory_opened = false
	Globals.is_ui_opened = false
			
func open_with_external_inventory(inventory_scene: PackedScene, scene_args: Array = [])-> PanelContainer:
	if not Globals.is_ui_opened:
		add_external_inventory(inventory_scene, scene_args)
		external_inventory.show()
	open()
	return external_inventory
	
func add_external_inventory(inventory_scene: PackedScene, scene_args: Array = [])-> PanelContainer:
	external_inventory = inventory_scene.instantiate()
		
	if scene_args.size() > 0 and external_inventory.has_method("scene_parameters"):
		external_inventory = external_inventory.scene_parameters(scene_args)
	external_inventory.name = external_inventory.id
	$InventoryContainer.add_child(external_inventory, true)
	$InventoryContainer.move_child(external_inventory,0)
	return external_inventory
	
func _on_mouse_entered() -> void:
	Globals.mouse_inside_inventory = true

func _on_mouse_exited() -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		Globals.mouse_inside_inventory = false
