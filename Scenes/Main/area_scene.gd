extends Node2D
class_name AreaScene

@export var is_building_allowed = false

func _ready() -> void:
	SaveManager.load_scene(name)
	sort_children_by_y_pos()
	child_entered_tree.connect(_on_child_entered_tree)
	print(Builder.building_created.get_name())


func _process(_delta: float) -> void:
	_player_occlusion()

#bubblesort to sort node children by Y position
func sort_children_by_y_pos():
	var sorted_children = get_children()
	var i = sorted_children.size() - 1
	while i >= 1:
		var j = 0
		while j < i:
			if "position" in sorted_children[j] and "position" in sorted_children[j+1]:
				if sorted_children[j].position[1] > sorted_children[j+1].position[1]:
					move_child(sorted_children[j], sorted_children[j+1].get_index())
					sorted_children = get_children()
			j += 1
		i -= 1
		
## objects need to be sorted by Y position for this to work.
func _player_occlusion():
	## Skip if player is not in scene
	if !multiplayer.is_server():
		return
	for player in SaveManager.players.values():
		
		if player.current_scene  != name or !player.is_online:
			continue
			
		for child in get_children():
			if "position" in child and is_instance_valid(player):
				move_player.rpc(player.name, child.name)

@rpc("any_peer", "call_local", "unreliable")
func move_player(player_name: String, node_name: String):
	var player = get_node(player_name)
	var node = get_node(node_name)
	if player and node:
		if player.position[1] > node.position[1] and player.get_index() < node.get_index():
			move_child(player, node.get_index())
		elif player.position[1] < node.position[1] and player.get_index() > node.get_index():
			move_child(player, node.get_index()) 
		
@rpc("authority","call_local","reliable")
func player_leaves_area(player_id: int):
	remove_child(get_node(str(player_id)))
	
func _on_child_entered_tree(node: Node):
	sort_children_by_y_pos.call_deferred()
	SceneManager.show_player_scene()
	
	if node is Building:
		Builder.building_created.emit(node)
