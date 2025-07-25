extends Area2D
var inventory_type = "brewing_inventory"
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
	var inventory_id := 0 # Default
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, inventory_type,inventory_id, [inventory_id])

func _on_interaction_range_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(inventory_type)
