extends StaticBody2D
class_name Building

@export var building_sprite: Sprite2D
@export var interaction_range: Area2D
@export var hitbox: Area2D
@export var inventory_type: StringName:
	set(p_inventory_type):
		inventory_type = p_inventory_type
@export_enum("Containers", "CraftingInventories") var inventory_resource_folder: String

var id: int
var current_scene_instance: Node2D
var is_hovered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_pickable = true
	setup_building_synchronization()
	connect_signals()
	current_scene_instance = _find_current_scene_instance()
	_add_to_occlusion_node()

func _process(_delta: float) -> void:
	input_handler()
			
func input_handler():
	if is_hovered:
		highlight()

# Called when the building has been built
func build():
	id = IDIncrementer.get_id()
	name = str(id)
	visible = true
	
	
func highlight():
	Builder.selected_building = self
	if Deconstructor.deconstruct_mode:
		building_sprite.modulate = Color.RED
	else:
		building_sprite.modulate = Color.GRAY

func remove_highlight():
	building_sprite.modulate = Color(1,1,1)
	Builder.selected_building = null
	
func connect_signals():
	hitbox.connect("mouse_entered", _on_mouse_entered)
	hitbox.connect("mouse_exited", _on_mouse_exited)
	interaction_range.connect("player_entered_range", _on_interaction_range_player_entered_range)
	interaction_range.connect("player_left_range", _on_interaction_range_player_left_range)
	
func setup_building_synchronization():
	var synchronizer = MultiplayerSynchronizer.new()
	var config: SceneReplicationConfig = SceneReplicationConfig.new()
	config.add_property(":position")
	config.add_property(":id")
	# ...
	
	synchronizer.set_replication_config(config)
	add_child(synchronizer)
	
func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false
	remove_highlight()

func _on_interaction_range_player_entered_range(player: Player) -> void:
	#opens the default brewing inventory data [id = 0]
	player.interaction_stack.add_interaction(Interaction.interaction_types.OPEN_INVENTORY, inventory_type, id, [id])

func _on_interaction_range_player_left_range(player: Player) -> void:
	player.interaction_stack.remove_interaction(inventory_type, id)
	
func save()-> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"id" : id,
		"name" : name
	}
	return save_dict
	
func _find_current_scene_instance() -> Node2D:
	var node = self.get_parent()
	while node:
		if node.is_in_group("scenes"):
			return node
		node = node.get_parent()
	return null
	
func _add_to_occlusion_node():
	if current_scene_instance.has_node("OcclusionObjects"):
		self.reparent.call_deferred(current_scene_instance.find_child("OcclusionObjects"))
