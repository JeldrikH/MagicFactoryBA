extends MultiplayerSynchronizer

var xAxis
var yAxis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")

func _input(_event):
	# Close UI
	if Globals.is_ui_opened:
		if (
			Input.is_action_just_pressed("INVENTORY") 
			or Input.is_action_just_pressed("CLOSE_UI") 
			or Input.is_action_just_pressed("OPEN_BUILDER")
			):
			Globals.close_all_ui_windows()
			return
			
	# Inventory
	if Input.is_action_just_pressed("INVENTORY"):
		$"..".inventory.open.call_deferred()
	
	# Interactions
	if Input.is_action_just_pressed("INTERACT") and $"..".interaction_stack.interaction_available:
		var interaction = $"..".interaction_stack.get_interaction()
		if interaction.interaction_type == Interaction.interaction_types.OPEN_INVENTORY:
			$"..".inventory.open_with_external_inventory.call_deferred(interaction.value, interaction.args)
	
	builder_input()
	deconstructor_input()

func builder_input():
	if Input.is_action_just_pressed("OPEN_BUILDER") and Builder.is_building_allowed:
		$"../PlayerUI/BuildingUI".open()
	
	if Input.is_action_just_pressed("CLOSE_UI") and Builder.build_mode:
		Builder.deactivate_build_mode()
		
	if Input.is_action_just_pressed("CLICK") and Builder.build_mode and Builder.is_building_allowed:
		Builder.build.rpc_id(1, Builder.building, $"..".current_scene, get_viewport().get_mouse_position())

func deconstructor_input():
	if (Input.is_action_just_pressed("CLOSE_UI")
	or Input.is_action_just_pressed("DECONSTRUCT")) and Deconstructor.deconstruct_mode:
		Deconstructor.deactivate_deconstruct_mode()
		
	elif Input.is_action_just_pressed("DECONSTRUCT") and not Deconstructor.deconstruct_mode:
		Deconstructor.activate_deconstruct_mode()
	
	if Input.is_action_just_pressed("CLICK") and Deconstructor.deconstruct_mode and Builder.selected_building:
			Deconstructor.player_deconstruct(Builder.selected_building, get_parent())
