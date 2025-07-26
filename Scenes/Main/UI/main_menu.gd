extends Panel


func load_save() -> void:
	MultiplayerManager.manage_multiplayer()
	


func _on_load_pressed() -> void:
	hide()
	%HUD.show()
	MultiplayerManager.is_host = true
	Identifier.name = "Host"
	load_save()
	


func _on_join_pressed() -> void:
	hide()
	%HUD.show()
	MultiplayerManager.is_client = true
	Identifier.name = "Client"
	load_save()
	


func _on_en_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_ger_pressed() -> void:
	TranslationServer.set_locale("de")
