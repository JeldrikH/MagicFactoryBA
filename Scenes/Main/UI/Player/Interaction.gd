extends Node
class_name Interaction

enum interaction_types {OPEN_INVENTORY, PICKUP_ITEM, CHANGE_LOCATION}

var interaction_type: int
## A Scene to open with the interaction
var scene: PackedScene
## id unique together with the interaction Scene (like inventory_id)
var interaction_id: int
## Parameters for the interaction. Need to be used carefully
var args: Array = []



func _init(p_interaction_type: int, p_scene: PackedScene, p_interaction_id: int = 0, p_args = []) -> void:
	interaction_type = p_interaction_type
	scene = p_scene
	interaction_id = p_interaction_id
	args = p_args
