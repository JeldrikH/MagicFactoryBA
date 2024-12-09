extends StaticBody2D
class_name Building

@export var building_sprite: Sprite2D
@export var interaction_range: Area2D
@export var hitbox: Area2D
@export var inventory_type: StringName

var id: int
var is_hovered = false
var inventory: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_pickable = true
	connect_signals()
	if !id:
		id = name.to_int()
	if id:
		load_inventory()

func _process(_delta: float) -> void:
	input_handler()
			
func input_handler():
	if is_hovered:
		highlight()
		if Input.is_action_just_pressed("CLICK") and Deconstructor.deconstruct_mode:
			Deconstructor.deconstruct(self)

# Called when the building has been built
func build():
	id = IDIncrementer.get_id()
	name = str(id)
	visible = true
	load_inventory()

func load_inventory():
	inventory = load("res://Scenes/Main/UI/Inventory/" + inventory_type +".tscn")
	
func highlight():
	if Deconstructor.deconstruct_mode:
		building_sprite.modulate = Color.RED
	else:
		building_sprite.modulate = Color.GRAY

func remove_highlight():
	building_sprite.modulate = Color(1,1,1)
	
func connect_signals():
	hitbox.connect("mouse_entered", _on_mouse_entered)
	hitbox.connect("mouse_exited", _on_mouse_exited)
	
func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false
	remove_highlight()

func save()-> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"id" : id
	}
	return save_dict
