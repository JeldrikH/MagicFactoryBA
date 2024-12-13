extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Deconstructor.activated.connect(show)
	Deconstructor.deactivated.connect(hide)
