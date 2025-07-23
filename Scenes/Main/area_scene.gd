extends Node2D
class_name AreaScene

@export var is_building_allowed = false
@export var is_camera_enabled = false

@export var building_grid: Node2D

func _ready() -> void:
	hide()
	SaveManager.load_scene(name)
	child_entered_tree.connect(_on_child_entered_tree)
	add_to_group("scenes")


@rpc("any_peer", "call_local", "reliable")
func player_changes_scene(player_id: int, next_area: PackedScene):
	var player = SaveManager.players.get(str(player_id))
	SceneManager.open_packed_scene(next_area)
	var next_area_name = SceneManager.get_scene_name(next_area).to_pascal_case()
	var parent = get_node("/root/Main/%s" % next_area_name)
	player.reparent.call_deferred(parent)
	player.scene_entered.call_deferred()
	player.ready.emit.call_deferred()
	tp_player_to_area_entrance(player_id, "%sFrom%s" % [next_area_name, self.name])
	
func tp_player_to_area_entrance(player_id: int, entrance_name: StringName):
	var player: Player = SaveManager.players.get(str(player_id))
	match entrance_name:
		"LivingRoomFromOutside":
			player.position = get_node("/root/Main/LivingRoom/%s" % entrance_name).get_global_position()
		"OutsideFromLivingRoom":
			player.position = get_node("/root/Main/Outside/%s" % entrance_name).get_global_position()
			
func _on_child_entered_tree(node: Node):
	if node is Building:
		Builder.building_created.emit(node)
