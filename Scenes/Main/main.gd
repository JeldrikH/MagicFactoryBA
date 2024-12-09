extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TranslationServer.set_locale("en")


func load_save() -> void:
	MultiplayerManager.manage_multiplayer()
	


func _on_load_pressed() -> void:
	$MainMenu.hide()
	MultiplayerManager.is_host = true
	load_save()
	


func _on_join_pressed() -> void:
	$MainMenu.hide()
	MultiplayerManager.is_client = true
	load_save()
	
