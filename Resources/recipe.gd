##Datatype for simple recipes with multiple inputs and one output
extends Resource
class_name Recipe


##The ID of the recipe, same as the resource name
@export var id: StringName
##The name of the recipe shown ingame
@export var name: String
##The Icon of the result of the recipe
@export var result_image: CompressedTexture2D
##An Array of needed items in the recipe. [[item, amount],[...],...]
@export var ingredients: Array[Array]
##An Array with the result of the recipe
@export var output: Array[Array]
##The station required to craft the recipe
@export var station_type: String
##The default Time required to craft the recipe in seconds
@export var duration: int

func _init(p_id = "", p_name = "", p_result_image = null):
	self.id = p_id
	self.name = p_name
	self.result_image = p_result_image
