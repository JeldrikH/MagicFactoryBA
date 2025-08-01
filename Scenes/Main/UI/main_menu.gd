extends Panel


func load_save() -> Error:
	return MultiplayerManager.manage_multiplayer()
	
	


func _on_load_pressed() -> void:
	MultiplayerManager.is_host = true
	MultiplayerManager.is_client = false
	Identifier.name = "Host"
	var err = load_save()
	if !err:
		hide()
		%HUD.show()


func _on_join_pressed() -> void:
	MultiplayerManager.is_host = false
	MultiplayerManager.is_client = true
	Identifier.name = "Client"
	var err = load_save()
	if !err:
		hide()
		%HUD.show()


func _on_en_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_ger_pressed() -> void:
	TranslationServer.set_locale("de")
