extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("OPEN_BUILDER"):
		open()
		
func open():
	$"..".close_all_ui_windows()
	visible = true
	Globals.is_ui_opened = true

func close():
	visible = false
	Globals.is_ui_opened = false


func _on_automatic_brewing_pressed() -> void:
	SceneBuilder.activate_build_mode(preload("res://Scenes/Main/Buildings/cauldron.tscn"))
	close()
