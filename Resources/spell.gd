##Datatype for Spells used in various tasks like automation, inherits from Item
extends Item
class_name Spell

##The amount of uses the spell has
@export var use_amount: int

func _init(p_id = "", p_name = "", p_icon = null, p_description = "", p_stackable = true, p_use_amount = 1):
	self.id = p_id
	self.name = p_name
	self.icon = p_icon
	self.description = p_description
	self.stackable = p_stackable
	self.use_amount = p_use_amount
