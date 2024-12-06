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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	xAxis = Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	yAxis = Input.get_axis("MOVE_UP","MOVE_DOWN")
