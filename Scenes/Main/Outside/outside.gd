extends AreaScene



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUGPORT"):
		get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom/living_room.tscn")
