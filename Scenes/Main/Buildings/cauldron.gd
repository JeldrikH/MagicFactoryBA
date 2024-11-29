extends Building



func _ready() -> void:
	inventory_type = "automatic_brewing_inventory"
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed("DEBUG"):
		inventory.open()
