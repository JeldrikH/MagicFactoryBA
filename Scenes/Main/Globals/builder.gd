extends Node2D

##The Building intended to be built
var building: StringName
var building_visual: Sprite2D
##True if build mode is activated
var build_mode: bool

var is_building_allowed = false
var selected_building: Building

@warning_ignore("unused_signal")
signal building_created(building: Building)

func _process(_delta):
	visual_follow_cursor()
	


##Activates the build mode showing the given building
func activate_build_mode(p_building: StringName):
	builder_on_top()
	show_visual(p_building)
	building = p_building
	BuildingGrid.instantiate_grid()
	
	build_mode = true
	if Deconstructor.deconstruct_mode:
		Deconstructor.deactivate_deconstruct_mode()

##deactivates the build mode and removes the building building
func deactivate_build_mode():
	if build_mode:
		build_mode = false
		building_visual.queue_free()
		BuildingGrid.deactivate_grid()

func show_visual(p_building: StringName):
	var temp_building = load("res://Scenes/Main/Buildings/%s.tscn" % p_building).instantiate()
	var building_scale: Vector2 = temp_building.get_node("Sprite2D").scale
	building_visual = Sprite2D.new()
	building_visual.scale = building_scale
	building_visual.texture = load("res://Sprites/Objects/Buildings/%s.png" % p_building)
	add_child(building_visual)
	
##Builds the building in the given parent
@rpc("any_peer", "call_local", "reliable")
func build(p_building: StringName, parent: String, build_position: Vector2, scene_args: Array = []):
	var building_instance = load("res://Scenes/Main/Buildings/%s.tscn" % p_building).instantiate()
	#apply parameters if required
	if scene_args.size() > 0 and building_instance.has_method("scene_parameters"):
		building_instance = building_instance.scene_parameters(scene_args)
	if BuildingGrid.grid_activated:
		build_position = BuildingGrid.get_closest_point(build_position)
	building_instance.position = build_position
	building_instance.build()
	var parent_node = get_tree().get_current_scene().get_node(parent)
	parent_node.find_child("OcclusionObjects").add_child(building_instance, true)
	SaveManager.save_scene(parent)
	
	
##makes the building instance follow the cursor
func visual_follow_cursor():
	if building_visual and build_mode:
		var pos = get_global_mouse_position()
		if BuildingGrid.grid_activated:
			pos = BuildingGrid.get_closest_point(pos)
		building_visual.position = pos
	
##moves the builder to the highest rank to make it visible
func builder_on_top():
	get_parent().move_child(self, get_parent().get_child_count()-1)
