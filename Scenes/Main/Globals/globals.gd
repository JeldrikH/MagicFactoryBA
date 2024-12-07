extends Node2D


var mouse_inside_inventory = false
var is_inventory_opened = false
var is_ui_opened = false
var allow_building = false

#bubblesort to sort node children by Y position
func sort_children_by_y_pos(node: Node):
	var sorted_children = node.get_children()
	var i = sorted_children.size() - 1
	while i >= 1:
		var j = 0
		while j < i:
			if "position" in sorted_children[j] and "position" in sorted_children[j+1]:
				if sorted_children[j].position[1] > sorted_children[j+1].position[1]:
					node.move_child(sorted_children[j], sorted_children[j+1].get_index())
					sorted_children = node.get_children()
			j += 1
		i -= 1

func close_all_ui_windows():
	get_tree().call_group("ui", "close")
