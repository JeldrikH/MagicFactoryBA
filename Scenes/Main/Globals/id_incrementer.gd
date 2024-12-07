extends Node2D
##Creates a unique id

##Resource that stores the current id counter, do not use, call get_id() instead
var _idresource: ID
 
##Valid types are "crafting" or "container"
func _ready() -> void:
	_idresource = preload("res://Resources/ID/id.tres")
	
func get_id()-> int:
	_idresource.id += 1
	ResourceSaver.save(_idresource, "res://Resources/ID/id.tres")
	return _idresource.id
