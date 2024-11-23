##Datatype for Items
extends Resource
class_name Item

##The ID of the item. Same as the resource name
@export var id: StringName
##The name of the item shown ingame
@export var name: String
##The Icon of the item
@export var icon: CompressedTexture2D
##Tooltip description
@export_multiline var description: String
##Defines whether an item is stackable or not
@export var stackable: bool = true

func _init(p_id = "", p_name = "", p_icon = null, p_description = "", p_stackable = true):
	self.id = p_id
	self.name = p_name
	self.icon = p_icon
	self.description = p_description
	self.stackable = p_stackable
