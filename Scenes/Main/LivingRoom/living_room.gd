extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.sort_children_by_y_pos(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_player_occlusion()


func _on_cauldron_interact() -> void:
	$"../UI/Inventories/BrewingInventory".open()

	
		
##objects need to be sorted by Y position for this to work.
func _player_occlusion():
	for child in get_children():
		if $Player.position[1] > child.position[1] and $Player.get_index() < child.get_index():
			move_child($Player, child.get_index())
		elif $Player.position[1] < child.position[1] and $Player.get_index() > child.get_index():
			move_child($Player, child.get_index())


func _on_table_interact() -> void:
	$"../UI/Inventories/SpellCraftingInventory".open()


func _on_storage_interaction_interact() -> void:
	$"../UI/Inventories/StorageContainers/ItemContainer0".open()
