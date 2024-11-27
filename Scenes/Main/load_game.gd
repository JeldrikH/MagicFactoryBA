extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().change_scene_to_file.bind(SaveManager.current_scene()).call_deferred()
