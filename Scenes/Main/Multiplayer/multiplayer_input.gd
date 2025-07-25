extends MultiplayerSynchronizer

var xAxis
var yAxis
var is_sprinting: bool = false
var player : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
	
	player = get_parent()
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")

func _input(_event):
	is_sprinting = Input.is_action_pressed("SPRINT")
	# Close UI
	if InventoryManager.is_ui_opened:
		if (
			Input.is_action_just_pressed("INVENTORY") 
			or Input.is_action_just_pressed("CLOSE_UI") 
			or Input.is_action_just_pressed("OPEN_BUILDER")
			):
			InventoryManager.close_all_ui_windows()
			return
			
	# Inventory
	if Input.is_action_just_pressed("INVENTORY"):
		player.inventory.open.call_deferred()
	
	# Interactions
	if Input.is_action_just_pressed("INTERACT") and player.interaction_stack.interaction_available:
		var interaction = player.interaction_stack.get_interaction()
		match interaction.interaction_type:
			Interaction.interaction_types.OPEN_INVENTORY:
				player.inventory.open_with_external_inventory.call_deferred(interaction.scene, interaction.args)
			Interaction.interaction_types.CHANGE_LOCATION:
				player.current_scene_instance.player_changes_scene.rpc_id(1,multiplayer.get_unique_id(), interaction.scene)
				
	
	builder_input()
	deconstructor_input()
	add_to_hotbar_with_key()

func builder_input():
	if Input.is_action_just_pressed("OPEN_BUILDER") and Builder.is_building_allowed:
		get_node("/root/Main/UI/BuildingUI").open()
	if Input.is_action_pressed("BUILDER_DEACTIVATE_GRID_SNAP") and Builder.build_mode:
		BuildingGrid.deactivate_grid()
	if Input.is_action_just_released("BUILDER_DEACTIVATE_GRID_SNAP") and Builder.build_mode and not BuildingGrid.grid_activated:
		BuildingGrid.instantiate_grid()
	if Input.is_action_just_pressed("CLOSE_UI") and Builder.build_mode:
		Builder.deactivate_build_mode()
		
	if Input.is_action_just_pressed("CLICK") and Builder.build_mode and Builder.is_building_allowed:
		Builder.build.rpc_id(1, Builder.building, $"..".current_scene, get_tree().current_scene.get_global_mouse_position())

func deconstructor_input():
	if (Input.is_action_just_pressed("CLOSE_UI")
	or Input.is_action_just_pressed("DECONSTRUCT")) and Deconstructor.deconstruct_mode:
		Deconstructor.deactivate_deconstruct_mode()
		
	elif Input.is_action_just_pressed("DECONSTRUCT") and not Deconstructor.deconstruct_mode:
		Deconstructor.activate_deconstruct_mode()
	
	if Input.is_action_just_pressed("CLICK") and Deconstructor.deconstruct_mode and is_instance_valid(Builder.selected_building):
			Deconstructor.player_deconstruct(Builder.selected_building, get_parent())

##adds the hovered item to the pressed hotbar slot with the corresponding keystroke #debug change to signal
func add_to_hotbar_with_key():
	for slot_number in range(0,10):
		if Input.is_action_just_pressed("SLOT_" + str(slot_number+1)):
			for child in $"..".inventory.item_grid.get_children():
				if child.is_hovered:
					$"..".inventory.link_item_to_hotbar($"..".inventory.inventory_data.slot_data_table[child.get_index()].item, slot_number)
