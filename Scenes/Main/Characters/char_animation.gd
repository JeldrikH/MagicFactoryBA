extends AnimationPlayer

var char_anims

func _ready():
	_create_library()
	_idle_animation()
	
func _enter_tree() -> void:
	if not char_anims:
		return
	_idle_animation()
	
func _idle_animation():
	
	var idle = Animation.new()
	var parent = get_parent()
	var scale_track_id = idle.add_track(Animation.TYPE_VALUE)
	
	idle.length = 6
	idle.track_set_path(scale_track_id, "%s:scale" % parent.get_path())
	
	idle.track_insert_key(scale_track_id, 0, parent.scale)
	idle.track_insert_key(scale_track_id, 2, Vector2(parent.scale.x, parent.scale.y * 1.01))
	idle.track_insert_key(scale_track_id, 4, parent.scale)
	
	char_anims.add_animation("Idle", idle)
	
func _create_library():
	char_anims = AnimationLibrary.new()
	add_animation_library("CharacterAnimations", char_anims)
