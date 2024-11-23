extends Item
class_name Potion

##The effect of the potion
@export var effect_id: StringName
##The amount or value given to the effect
@export var value: int
##The effect duration if applicable
@export var duration: int

func _init(p_id = "", p_name = "", p_icon = null, p_description = "", p_stackable = true, p_effect_id = "", p_value = 0, p_duration = 0):
	self.id = p_id
	self.name = p_name
	self.icon = p_icon
	self.description = p_description
	self.stackable = p_stackable
	self.effect_id = p_effect_id
	self.value = p_value
	self.duration = p_duration
