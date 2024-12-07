extends Area2D
signal player_entered_range
signal player_left_range

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		player_entered_range.emit()


func _on_body_exited(body: Node2D) -> void:
	if body is Player and body.player_id == multiplayer.get_unique_id():
		player_left_range.emit()
