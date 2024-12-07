extends Node
class_name Interaction

enum interaction_types {OPEN_INVENTORY, PICKUP_ITEM}

var interaction_type: int
## A Scene for OPEN_INVENTORY type interactions
var value
## id unique together with the interaction value (like inventory_id)
var interaction_id: int
## Parameters for the interaction. Need to be used carefully
var args: Array = []



func _init(p_interaction_type: int, p_value, p_interaction_id: int, p_args = []) -> void:
	interaction_type = p_interaction_type
	value = p_value
	interaction_id = p_interaction_id
	args = p_args
