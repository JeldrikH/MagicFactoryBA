extends Node2D

##The Building intended to be built
var scene_instance: Node2D
var scene_visual: Node2D
##True if build mode is activated
var build_mode: bool
var build_parent: Node2D

func _process(_delta):
	visual_follow_cursor()
	if Input.is_action_just_pressed("CLOSE_UI") and build_mode:
		deactivate_build_mode()

##Activates the build mode showing the given scene
func activate_build_mode(scene: PackedScene):
	builder_on_top()
	scene_instance = scene.instantiate()
	scene_visual = scene.instantiate()
	add_child(scene_visual)
	build_mode = true

##deactivates the build mode and removes the building scene
func deactivate_build_mode():
	build_mode = false
	scene_visual.queue_free()

##Builds the building in the given parent
func build(parent: Node2D):
	scene_instance.position = scene_visual.position
	parent.add_child(scene_instance)
	scene_instance.build()
	deactivate_build_mode()
	
	
##makes the scene instance follow the cursor
func visual_follow_cursor():
	if scene_visual and build_mode:
		scene_visual.position = get_viewport().get_mouse_position()
	
##moves the builder to the highest rank to make it visible
func builder_on_top():
	get_parent().move_child(self, get_parent().get_child_count()-1)
