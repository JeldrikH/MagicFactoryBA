extends Area2D
signal interact
var playerEntered = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CauldronSprite.play("Empty")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("INTERACT") and playerEntered:
		interact.emit()

func brew():
	#if $"../InventoryBarPanel/InventoryBarGrid".get_item
	$CauldronSprite.play("Brew")
	$BrewTimer.start()
	

func _on_interaction_range_body_exited(body: Node2D) -> void:
	if body is Player:
		playerEntered = false


func _on_interaction_range_body_entered(body: Node2D) -> void:
	if body is Player:
		playerEntered = true


func _on_brew_timer_timeout() -> void:
	$CauldronSprite.play("Empty")
