extends MultiplayerSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_multiplayer_authority(1)
