extends AreaScene



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	super._process(_delta)
	if Input.is_action_just_pressed("DEBUGPORT"):
		player_changes_scene.rpc_id(1, multiplayer.get_unique_id(), "Outside", "LivingRoom")
