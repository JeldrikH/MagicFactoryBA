extends Area2D
var inventory = preload("res://Scenes/Main/UI/Inventory/brewing_inventory.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CauldronSprite.play("Empty")

func brew():
	#if $"../InventoryBarPanel/InventoryBarGrid".get_item
	$CauldronSprite.play("Brew")
	$BrewTimer.start()
	
func _on_brew_timer_timeout() -> void:
	$CauldronSprite.play("Empty")


func _on_interaction_range_player_entered_range(player: Player) -> void:
	#opens the default brewing inventory data [id = 0]
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, inventory, 0, [0])

func _on_interaction_range_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(inventory, 0)
