extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TranslationServer.set_locale("en")


func load_save() -> void:
	get_tree().change_scene_to_file(SaveManager.current_scene())
	


func _on_load_pressed() -> void:
	$MainMenu.hide()
	load_save()
	MultiplayerManager.is_host = true
	


func _on_join_pressed() -> void:
	$MainMenu.hide()
	load_save()
	MultiplayerManager.is_client = true
	
