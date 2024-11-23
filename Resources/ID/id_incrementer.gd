extends Resource
##Creates a unique id
class_name IDIncrementer
##unique id
var id: int = 1
 
##Valid types are "crafting" or "container"
func _init() -> void:
	id  = preload("res://Resources/ID/id.tres").id
	id += 1
	ResourceSaver.save(self, "res://Resources/ID/id.tres")
	
