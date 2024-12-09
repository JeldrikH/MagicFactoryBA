extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		SaveManager.load_scene(name)
		Globals.sort_children_by_y_pos(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUGPORT"):
		get_tree().change_scene_to_file("res://Scenes/Main/LivingRoom/living_room.tscn")
