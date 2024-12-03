extends Node2D

##The Building intended to be built
var building: PackedScene
var building_visual: Node2D
##True if build mode is activated
var build_mode: bool
var build_parent: Node2D

func _process(_delta):
	visual_follow_cursor()
	input_handler()
	
func input_handler():
	if Input.is_action_just_pressed("CLOSE_UI") and build_mode:
		deactivate_build_mode()
		
	if Input.is_action_just_pressed("OPEN_BUILDER") and build_mode:
		deactivate_build_mode()
		
	if Input.is_action_just_pressed("CLICK") and Builder.build_mode and Globals.allow_building:
		build(building, get_tree().current_scene, get_viewport().get_mouse_position())

##Activates the build mode showing the given building
func activate_build_mode(p_building: PackedScene):
	builder_on_top()
	show_visual(p_building)
	building = p_building
	
	build_mode = true
	if Deconstructor.deconstruct_mode:
		Deconstructor.deactivate_deconstruct_mode()

##deactivates the build mode and removes the building building
func deactivate_build_mode():
	if build_mode:
		build_mode = false
		building_visual.queue_free()

func show_visual(p_building: PackedScene):
	building_visual = p_building.instantiate()
	building_visual.set_collision_layer(0)
	building_visual.remove_from_group("persist")
	add_child(building_visual)
	
##Builds the building in the given parent
func build(p_building: PackedScene, parent: Node2D, build_position: Vector2, scene_args: Array = [])-> Building:
	var building_instance = p_building.instantiate()
	
	#apply parameters if required
	if scene_args.size() > 0 and building_instance.has_method("scene_parameters"):
		building_instance = building_instance.scene_parameters(scene_args)
		
	building_instance.position = build_position
	parent.add_child(building_instance)
	building_instance.build()
	return building_instance
	
	
##makes the building instance follow the cursor
func visual_follow_cursor():
	if building_visual and build_mode:
		building_visual.position = get_viewport().get_mouse_position()
	
##moves the builder to the highest rank to make it visible
func builder_on_top():
	get_parent().move_child(self, get_parent().get_child_count()-1)
