extends CharacterBody2D
class_name Player

const SPEED = 400.0

var is_sprinting: bool = false
var is_online = false

var xAxis = 0
var yAxis = 0
var interaction_label_visible := false
## Stack of currently available interactions
var interaction_stack: InteractionStack
var inventory: Inventory
var current_scene: String #Has to be a string to specify for load/save
var current_scene_instance: Node2D


@export var player_id: int = 1:
	set(id):
		player_id = id
		$InputSynchronizer.set_multiplayer_authority(id)
		
		
func _ready():
	inventory = get_node_or_null("/root/Main/PlayerInventories/%s" % name)
	if not inventory:
		create_player_inventory(player_id)
	scene_entered()
		
func scene_entered():
	interaction_stack = InteractionStack.new()
	current_scene_instance = _find_current_scene_instance()
	current_scene = current_scene_instance.name
	if player_id == multiplayer.get_unique_id():
		get_tree().call_group("scenes", "hide")
		current_scene_instance.show()
		Builder.is_building_allowed = current_scene_instance.is_building_allowed
		BuildingGrid.current_scene = current_scene_instance
		$Camera2D.enabled = current_scene_instance.is_camera_enabled
		
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		apply_movement_from_input(delta)
	_apply_animations(delta)
	_show_interaction_label()
	

func _apply_animations(_delta):
	flip_anim()
	walk_anim()

func flip_anim():
	if xAxis > 0:
		$PlayerSprite.flip_h = false
	elif xAxis < 0:
		$PlayerSprite.flip_h = true
	
func walk_anim():
	if velocity.length() > 0:
		# Adjust coefficient to prevent sliding
		var v_coeff = 0.75
		$PlayerSprite.speed_scale = v_coeff * velocity.length()/SPEED
		$PlayerSprite.play("Walking")
		$PlayerAnimation.stop()
	else:
		$PlayerSprite.play("Idle")
		$PlayerAnimation.play("CharacterAnimations/Idle")
		

func apply_movement_from_input(_delta):
	xAxis = $InputSynchronizer.xAxis
	yAxis = $InputSynchronizer.yAxis
	is_sprinting = $InputSynchronizer.is_sprinting
	var speed_multiplier = 1
	if is_sprinting:
		speed_multiplier = 2
	if xAxis or yAxis:
		velocity.x = xAxis * SPEED * speed_multiplier
		velocity.y = yAxis * SPEED * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
 
func create_player_inventory(id: int):
	inventory = load("res://Scenes/Main/UI/Player/player_inventory.tscn").instantiate()
	get_node("/root/Main/PlayerInventories").add_child(inventory, true)
	inventory.name = str(id)
	inventory.player_id = id
	inventory.player_owner = self

func save()-> Dictionary:
	var save_dict = {
		"player_id" : player_id,
		"pos_x" : position.x,
		"pos_y" : position.y,
		"current_scene" : current_scene
	}
	return save_dict
	
func _find_current_scene_instance() -> Node2D:
	var node = self.get_parent()
	while node:
		if node.is_in_group("scenes"):
			return node
		node = node.get_parent()
	return null

func _show_interaction_label():
	if interaction_stack.interaction_available and not interaction_label_visible:
		interaction_label_visible = true
		get_tree().call_group("ui", "show_interaction")
	elif not interaction_stack.interaction_available and interaction_label_visible:
		interaction_label_visible = false
		get_tree().call_group("ui", "hide_interaction")
