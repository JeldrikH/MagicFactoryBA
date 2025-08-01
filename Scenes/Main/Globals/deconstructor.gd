extends Node2D

var deconstruct_mode: bool
signal activated
signal deactivated

func activate_deconstruct_mode():
	deconstruct_mode = true
	activated.emit()
	if Builder.build_mode:
		Builder.deactivate_build_mode()
	
func deactivate_deconstruct_mode():
	deconstruct_mode = false
	deactivated.emit()
	
@rpc("any_peer","call_local","reliable")
func deconstruct(building_id: String, scene_name: StringName):
	var building = get_node("/root/Main/%s/OcclusionObjects/%s" % [scene_name, building_id])
	DirAccess.remove_absolute("res://Resources/Inventories/" + building.inventory_resource_folder + str(building.id) + ".tres")
	building.queue_free()
	SaveManager.save_scene(scene_name)

func player_deconstruct(building: Building, player: Player):
	var scene_name = building.get_node("SaveModule").current_scene_instance.name
	transfer_items(building, player)
	deconstruct.rpc_id(1, building.name, scene_name)
	Builder.selected_building = null

func transfer_items(building: Building, player: Player):
	var inventory = player.inventory.add_external_inventory(building.inventory_type, [building.id])
	var building_items = inventory.inventory_data.get_items()
	inventory.queue_free()
	if building_items.size() > 0:
		player.inventory.add_item_list(building_items)
