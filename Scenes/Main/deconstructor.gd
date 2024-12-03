extends Node2D

var deconstruct_mode: bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("CLOSE_UI")
	or Input.is_action_just_pressed("DECONSTRUCT")) and deconstruct_mode:
		deactivate_deconstruct_mode()
	elif Input.is_action_just_pressed("DECONSTRUCT") and not deconstruct_mode:
		activate_deconstruct_mode()

func activate_deconstruct_mode():
	deconstruct_mode = true
	if Builder.build_mode:
		Builder.deactivate_build_mode()
	
func deactivate_deconstruct_mode():
	deconstruct_mode = false
	
func deconstruct(building: Building):
	transfer_items(building)
	DirAccess.remove_absolute(building.inventory.path + building.inventory.id + ".tres")
	building.queue_free()
	SaveManager.save_scene(get_tree().current_scene.scene_file_path)

func transfer_items(building: Building):
	var building_items = building.inventory.inventory_data.get_items()
	if building_items.size() > 0:
		building.inventory.player_items.add_item_list(building_items)
