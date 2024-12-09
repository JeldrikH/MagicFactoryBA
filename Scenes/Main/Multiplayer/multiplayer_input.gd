extends MultiplayerSynchronizer

var xAxis
var yAxis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")

func _process(_delta: float) -> void:
	handle_input()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")

func handle_input():
	if Globals.is_ui_opened:
		if Input.is_action_just_pressed("INVENTORY"):
			Globals.close_all_ui_windows()
	else:
		if Input.is_action_just_pressed("INVENTORY"):
			$"..".inventory.open.call_deferred()
			
	if Input.is_action_just_pressed("INTERACT") and $"..".interaction_stack.interaction_available:
		var interaction = $"..".interaction_stack.get_interaction()
		if interaction.interaction_type == Interaction.interaction_types.OPEN_INVENTORY:
			$"..".inventory.open_with_external_inventory.call_deferred(interaction.value, interaction.args)
