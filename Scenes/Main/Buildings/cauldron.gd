extends Node2D
var inventory: PanelContainer
var id: int
var player_entered: bool = false

func _ready() -> void:
	if id:
		load_inventory()
		
# Called when the building has been built
func build():
	id = IDIncrementer.get_id()
	visible = true
	load_inventory()

func load_inventory():
	inventory = preload("res://Scenes/Main/UI/Inventory/automatic_brewing_inventory.tscn").instantiate().scene_parameters(id)
	inventory.add_to_group("inventories")
	$Inventory.add_child(inventory)
	inventory.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG"):
		inventory.open()


func _on_interaction_range_body_entered(body: Node2D) -> void:
	if typeof(body) == typeof(Player):
		player_entered = true


func _on_interaction_range_body_exited(body: Node2D) -> void:
	if typeof(body) == typeof(Player):
		player_entered = false
