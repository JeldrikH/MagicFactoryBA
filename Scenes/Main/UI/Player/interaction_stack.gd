extends Node
class_name InteractionStack

var interaction_available = false
## An array of the interactions available. Only the top is visible
var interactions: Array[Interaction] = []

## Adds a new interaction to the top of the stack
func add_interaction(p_interaction_type: int, p_value, p_interaction_id: int, p_interaction_args: Array = []):
	var interaction = Interaction.new(p_interaction_type, p_value, p_interaction_id,  p_interaction_args)
	interactions.append(interaction)
	interaction_available = true

## Removes a specified interaction from the stack (not necessarily the top)
func remove_interaction(p_value, p_interaction_id: int):
	for i in interactions.size():
		if interactions[i].value == p_value and interactions[i].interaction_id == p_interaction_id:
			interactions.remove_at(i)
			break
	if interactions.size() == 0:
		interaction_available = false

## Gets the last interaction from the stack
func get_interaction()-> Interaction:
	var i = interactions.size() -1
	return interactions[i]
