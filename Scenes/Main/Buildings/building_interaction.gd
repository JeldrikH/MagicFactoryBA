extends Area2D
signal player_entered_range(player: Player)
signal player_left_range(player: Player)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		player_entered_range.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		player_left_range.emit(body)
