extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TranslationServer.set_locale("en")


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
	
