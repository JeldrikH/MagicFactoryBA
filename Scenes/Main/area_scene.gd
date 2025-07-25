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
	_create_player_spawner()
	_create_building_spawner()
	


@rpc("any_peer", "call_local", "reliable")
func player_changes_scene(player_id: int, next_area: StringName):
	var player = SaveManager.players.get(str(player_id))
	var next_area_name = next_area.to_pascal_case()
	SceneManager.open_scene_by_name(next_area_name)
	var parent = get_node("/root/Main/%s/OcclusionObjects" % next_area_name)
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
	
func _create_player_spawner():
	var PlayerSpawner: MultiplayerSpawner = MultiplayerSpawner.new()
	PlayerSpawner.name = "PlayerSpawner"
	PlayerSpawner.add_spawnable_scene("res://Scenes/Main/Characters/player.tscn")
	add_child(PlayerSpawner)
	move_child(PlayerSpawner, 0)
	PlayerSpawner.spawn_path = "../OcclusionObjects"

func _create_building_spawner():
	var BuildingSpawner: MultiplayerSpawner = MultiplayerSpawner.new()
	BuildingSpawner.name = "BuildingSpawner"
	
	#Debug make global list and iterate
	BuildingSpawner.add_spawnable_scene("res://Scenes/Main/Buildings/cauldron.tscn") 
	BuildingSpawner.add_spawnable_scene("res://Scenes/Main/Buildings/remainder_container.tscn")
	add_child(BuildingSpawner)
	move_child(BuildingSpawner, 0)
	BuildingSpawner.spawn_path = "../OcclusionObjects"
	
func _on_child_entered_tree(node: Node):
	if node is Building:
		Builder.building_created.emit(node)
