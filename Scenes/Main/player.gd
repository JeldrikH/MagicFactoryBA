extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_online = false

var xAxis = 0
var yAxis = 0

## Stack of currently available interactions
var interaction_stack: InteractionStack
@onready var inventory = $PlayerUI/PlayerInventory
var current_scene: String


@export var player_id: int = 1:
	set(id):
		player_id = id
		$InputSynchronizer.set_multiplayer_authority(id)
		$PlayerUI/PlayerInventory.player_id = player_id
		
func _ready():
	interaction_stack = InteractionStack.new()
	inventory.player_items.player_owner = self
	current_scene = get_parent().name
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		Builder.is_building_allowed = get_parent().is_building_allowed
	
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		apply_movement_from_input(delta)
	_apply_animations(delta)
	

func _apply_animations(_delta):
	if xAxis > 0:
		$PlayerSprite.flip_h = false
	elif xAxis < 0:
		$PlayerSprite.flip_h = true
	
func apply_movement_from_input(_delta):
	xAxis = $InputSynchronizer.xAxis
	yAxis = $InputSynchronizer.yAxis
		
	if xAxis or yAxis:
		velocity.x = xAxis * SPEED
		velocity.y = yAxis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
 
func save()-> Dictionary:
	var save_dict = {
		"player_id" : player_id,
		"pos_x" : position.x,
		"pos_y" : position.y,
		"current_scene" : current_scene
	}
	return save_dict
	
